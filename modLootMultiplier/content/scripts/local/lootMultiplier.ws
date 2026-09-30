/***********************************************************************
 *  Loot Multiplier - множитель ресурсов со всего лута
 *  The Witcher 3: Wild Hunt - Remastered (версия игры 5.00+)
 *
 *  Как работает:
 *  Обёртка над CInventoryComponent.GiveItemTo() - это единственная
 *  функция, через которую предметы физически переезжают из одного
 *  инвентаря в другой (обычный лут из сундука, "взять всё", трупы
 *  монстров, сбор трав, авто-лут модов - всё идёт через неё).
 *
 *  Если источник - контейнер (сундук/бочка/труп/трава/улей), а получатель
 *  - инвентарь игрока, то к переданному количеству докидывается
 *  недостающее до "количество * множитель".
 *
 *  Мод не перезаписывает ни одного ванильного файла (используются
 *  script annotations), поэтому Script Merger для него не нужен.
 *
 *  ВАЖНО: файл должен быть сохранён в UTF-8 (без BOM).
 ***********************************************************************/

// Источник нам подходит? (сундук, бочка, труп, трава, улей и т.п.)
// W3Container - родитель для сундуков/бочек (W3Container),
// трупов (W3ActorRemains), трав и грибов (W3Herb), ульев (CBeehiveEntity).
function LM_IsLootSource( entity : CEntity ) : bool
{
	var container : W3Container;

	container = (W3Container)entity;
	if( container )
	{
		return true;
	}

	return false;
}

// Какой множитель применить к этому источнику
function LM_MultiplierFor( container : W3Container, itemName : name ) : float
{
	// Кроны можно крутить отдельно
	if( LM_UseMoneyMultiplier() && itemName == 'Crowns' )
	{
		return LM_MoneyMultiplier();
	}

	if( !LM_UsePerSource() )
	{
		return LM_GlobalMultiplier();
	}

	if( (W3Herb)container )
	{
		return LM_HerbMultiplier();
	}

	if( (W3ActorRemains)container )
	{
		return LM_CorpseMultiplier();
	}

	return LM_ContainerMultiplier();
}

// Сколько предметов нужно доложить поверх уже полученных
function LM_ExtraCount( moved : int, multiplier : float ) : int
{
	var total, cap, extra : int;

	total = (int)( moved * multiplier );
	if( total < moved + 1 )
	{
		total = moved + 1;
	}

	cap = LM_Cap();
	if( cap > 0 && total > cap )
	{
		total = cap;
	}

	extra = total - moved;
	if( extra < 0 )
	{
		extra = 0;
	}

	return extra;
}

// Сообщение на экране + запись в лог
function LM_Report( target : CInventoryComponent, itemName : name, moved : int, extra : int ) : void
{
	var label, message : string;

	label = target.GetItemLocalizedNameByName( itemName );
	if( StrLen( label ) == 0 )
	{
		label = NameToString( itemName );
	}

	message = "Лут x" + IntToString( moved + extra ) + ": +" + IntToString( extra ) + " " + label;

	if( LM_DebugLog() )
	{
		LogChannel( 'LootMultiplier', "+" + IntToString( extra ) + " x " + NameToString( itemName ) + " (было " + IntToString( moved ) + ")" );
	}

	if( LM_Notify() && GetWitcherPlayer() )
	{
		GetWitcherPlayer().DisplayHudMessage( message );
	}
}

/* ------------------------------ сам хук ------------------------------ */

@wrapMethod( CInventoryComponent )
function GiveItemTo( otherInventory : CInventoryComponent, itemId : SItemUniqueId, optional quantity : int, optional refreshNewFlag : bool, optional forceTransferNoDrops : bool, optional informGUI : bool ) : SItemUniqueId
{
	var newId : SItemUniqueId;
	var container : W3Container;
	var multiplier : float;
	var itemName : name;
	var qtyBefore, qtyAfter, moved, extra : int;
	var apply : bool;

	apply = false;
	multiplier = 1.0;
	qtyBefore = 0;
	moved = 0;
	itemName = '';

	// Решение принимаем ДО передачи: после неё itemId уже может стать
	// невалидным, и теги/имя будет неоткуда взять.
	if( LM_IsEnabled() && thePlayer && otherInventory && otherInventory == thePlayer.GetInventory() )
	{
		container = (W3Container)this.GetEntity();

		if( container
			&& LM_IsLootSource( container )
			&& ( LM_TouchQuestContainers() || !container.HasQuestItem() )
			&& this.IsIdValid( itemId )
			&& !this.IsItemSingletonItem( itemId )	// мечи, броня, книги и пр. не множатся
			&& !this.ItemHasTag( itemId, 'QuestItem' )
			&& !this.ItemHasTag( itemId, 'GwintCard' ) )
		{
			itemName = this.GetItemName( itemId );
			multiplier = LM_MultiplierFor( container, itemName );

			if( multiplier > 1.0 )
			{
				qtyBefore = this.GetItemQuantity( itemId );
				apply = true;
			}
		}
	}

	// Ванильная передача предмета
	newId = wrappedMethod( otherInventory, itemId, quantity, refreshNewFlag, forceTransferNoDrops, informGUI );

	if( apply )
	{
		qtyAfter = this.GetItemQuantity( itemId );
		moved = qtyBefore - qtyAfter;

		// moved <= 0 -> передача не состоялась (NoDrop, перевес и т.п.)
		if( moved > 0 )
		{
			extra = LM_ExtraCount( moved, multiplier );
			if( extra > 0 )
			{
				otherInventory.AddAnItem( itemName, extra, true, false, false );
				LM_Report( otherInventory, itemName, moved, extra );
			}
		}
	}

	return newId;
}

/* --------------------------- отладочная команда ---------------------------
 * Включи консоль (bin/config/base/general.ini -> DBGConsoleOn=true),
 * зайди в игру, нажми ~ и набери:  lm_status()
 */
exec function lm_status()
{
	var message : string;

	message = "Loot Multiplier: ";

	if( LM_IsEnabled() )
	{
		message = message + "вкл";
	}
	else
	{
		message = message + "выкл";
	}

	message = message + " | множитель x" + IntToString( (int)LM_GlobalMultiplier() );

	if( LM_UsePerSource() )
	{
		message = message + " | раздельно: контейнеры x" + IntToString( (int)LM_ContainerMultiplier() );
		message = message + ", трупы x" + IntToString( (int)LM_CorpseMultiplier() );
		message = message + ", травы x" + IntToString( (int)LM_HerbMultiplier() );
	}

	if( LM_UseMoneyMultiplier() )
	{
		message = message + " | кроны x" + IntToString( (int)LM_MoneyMultiplier() );
	}

	LogChannel( 'LootMultiplier', message );

	if( GetWitcherPlayer() )
	{
		GetWitcherPlayer().DisplayHudMessage( message );
	}
}

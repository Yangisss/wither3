/***********************************************************************
 *  Loot Multiplier - чтение настроек из меню "Настройки -> Моды"
 *  The Witcher 3: Wild Hunt - Remastered (версия игры 5.00+)
 *
 *  ВАЖНО: файл должен быть сохранён в UTF-8 (без BOM), иначе в
 *  Remastered он просто не прочитается.
 ***********************************************************************/

// id группы настроек. Должен совпадать с <Group id="..."> в
// bin/config/r4game/user_config_matrix/pc/modLootMultiplier.xml
function LM_GROUP() : name
{
	return 'modLootMultiplier';
}

function LM_GetString( varName : name ) : string
{
	return theGame.GetInGameConfigWrapper().GetVarValue( LM_GROUP(), varName );
}

// Число из меню. Если игрок ещё не открывал меню - значения в конфиге нет,
// тогда подставляем дефолт и сразу пишем его в конфиг, чтобы в меню
// отображался нормальный дефолт, а не "0".
function LM_GetFloat( varName : name, defValue : float ) : float
{
	var raw : string;

	raw = LM_GetString( varName );
	if( StrLen( raw ) == 0 )
	{
		theGame.GetInGameConfigWrapper().SetVarValue( LM_GROUP(), varName, FloatToString( defValue ) );
		return defValue;
	}

	return StringToFloat( raw, defValue );
}

// Переключатель из меню (хранится как строка "true"/"false")
function LM_GetBool( varName : name, defValue : bool ) : bool
{
	var raw : string;

	raw = LM_GetString( varName );
	if( StrLen( raw ) == 0 )
	{
		if( defValue )
		{
			theGame.GetInGameConfigWrapper().SetVarValue( LM_GROUP(), varName, "true" );
		}
		else
		{
			theGame.GetInGameConfigWrapper().SetVarValue( LM_GROUP(), varName, "false" );
		}
		return defValue;
	}

	if( raw == "true" || raw == "True" || raw == "TRUE" || raw == "1" )
	{
		return true;
	}

	return false;
}

// Чтобы кривое значение из меню не сломало игру
function LM_ClampMultiplier( value : float ) : float
{
	if( value < 1.0 )
	{
		return 1.0;
	}
	if( value > 100.0 )
	{
		return 100.0;
	}
	return value;
}

/* -------------------- сами настройки -------------------- */

function LM_IsEnabled() : bool
{
	return LM_GetBool( 'LMEnabled', true );
}

function LM_GlobalMultiplier() : float
{
	return LM_ClampMultiplier( LM_GetFloat( 'LMMultiplier', 3.0 ) );
}

function LM_UsePerSource() : bool
{
	return LM_GetBool( 'LMUsePerSource', false );
}

function LM_ContainerMultiplier() : float
{
	return LM_ClampMultiplier( LM_GetFloat( 'LMMultContainers', 3.0 ) );
}

function LM_CorpseMultiplier() : float
{
	return LM_ClampMultiplier( LM_GetFloat( 'LMMultCorpses', 3.0 ) );
}

function LM_HerbMultiplier() : float
{
	return LM_ClampMultiplier( LM_GetFloat( 'LMMultHerbs', 3.0 ) );
}

function LM_UseMoneyMultiplier() : bool
{
	return LM_GetBool( 'LMUseMoney', false );
}

function LM_MoneyMultiplier() : float
{
	return LM_ClampMultiplier( LM_GetFloat( 'LMMultMoney', 1.0 ) );
}

// Максимум предметов одного вида за один подбор (0 = без лимита)
function LM_Cap() : int
{
	return (int)LM_GetFloat( 'LMCap', 0.0 );
}

function LM_TouchQuestContainers() : bool
{
	return LM_GetBool( 'LMQuestContainers', false );
}

function LM_Notify() : bool
{
	return LM_GetBool( 'LMNotify', true );
}

function LM_DebugLog() : bool
{
	return LM_GetBool( 'LMDebug', false );
}

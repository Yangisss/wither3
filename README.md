# Loot Multiplier — множитель лута для The Witcher 3: Wild Hunt — Remastered

Мод добавляет страницу **Настройки → Моды → Loot Multiplier**, где прямо в игре крутится
множитель ресурсов: поднял 3 медной руды из сундука при ×5 — получил 15.
Работает на всём, что ты подбираешь: сундуки, бочки, ящики, трупы монстров/зверей/людей,
травы и грибы, улья, а также любой авто-лут (моды AutoLoot и similar идут через ту же
функцию передачи предметов).

- Версия игры: **Remastered 5.00+** (сентябрь 2026).
- Платформа: **PC** (см. «Почему не mod.io» ниже).
- **Не требует Script Merger**: мод не перезаписывает ни одного ванильного файла,
  использует script annotations (`@wrapMethod`).

---

## Быстрый старт (3 минуты, ничего больше качать не надо)

1. Скачай `dist/LootMultiplier-install.zip` (это готовый архив в структуре игры).
2. Распакуй его **в папку с игрой** — там, где лежит `witcher3.exe`
   (Windows предложит «заменить/объединить папки» — соглашайся).
   Архив сам разложит всё по местам:
   ```
   <игра>\mods\modLootMultiplier\content\scripts\local\*.ws
   <игра>\bin\config\r4game\user_config_matrix\pc\modLootMultiplier.xml
   ```
3. Остаётся один шаг руками (иначе меню не появится — особенность Next-Gen/Remastered):
   открой блокнотом файл `<игра>\bin\config\r4game\user_config_matrix\pc\dx12filelist.txt`,
   в самый конец добавь новую строку

   ```
   modLootMultiplier.xml;
   ```

   и сохрани. Играешь в DX11 — то же самое сделай в `dx11filelist.txt`
   (можно прописать в оба файла).
4. Запускай игру: **Настройки → Моды → Loot Multiplier**.

Никаких зависимостей, Script Merger, REDkit и прочего не требуется — мод состоит
из двух текстовых файлов скрипта и одного XML меню.

---

## Как это работает

Вся передача предметов между инвентарями в игре идёт через одну функцию:

```ws
CInventoryComponent.GiveItemTo( otherInventory, itemId, quantity, refreshNewFlag, forceTransferNoDrops, informGUI )
```

Через неё проходит обычный лут из сундука, кнопка «взять всё», трупы, сбор трав и
все авто-лут моды. Мод оборачивает её: если **источник** — контейнер
(`W3Container`, а это родитель для сундуков/бочек, `W3ActorRemains` — трупы,
`W3Herb` — травы, `CBeehiveEntity` — улья), а **получатель** — инвентарь игрока,
то после обычной передачи докидывается недостающее количество до
`подобрано × множитель`.

Плюс такого подхода: мод ничего не пишет в сейв, не раздувает инвентарь контейнеров
и не может «накрутиться» при перезагрузке — множитель считается от фактически
переданного количества в момент подбора.

**Что НЕ множится намеренно:**

- мечи, броня, книги, письма, карты Гвинта (нестакуемые вещи — `IsItemSingletonItem`);
- квестовые предметы;
- содержимое квестовых контейнеров (по умолчанию) — включается отдельной галочкой;
- покупки у торговцев, крафт, награды за квесты (это не лут из контейнера).

---

## Установка

### Вариант 1 — автоматически (Windows, PowerShell)

```powershell
powershell -ExecutionPolicy Bypass -File tools\install.ps1
```

Скрипт сам найдёт игру (GOG / Steam), скопирует папку мода и XML меню и пропишет
меню в `dx11filelist.txt` / `dx12filelist.txt`. Путь можно указать руками:

```powershell
powershell -ExecutionPolicy Bypass -File tools\install.ps1 -GamePath "D:\Games\The Witcher 3"
```

<<<<<<< HEAD
### Вариант 2 — руками
=======
### Вариант 2 — руками (Steam-версия)

Точный путь к игре: **Библиотека Steam → ПКМ на «The Witcher 3: Wild Hunt» →
Свойства → Установленные файлы → Обзор локальных файлов**. Откроется папка, где
лежат `bin`, `content`, `dlc` и `witcher3.exe`. Обычно это:

```
C:\Program Files (x86)\Steam\steamapps\common\The Witcher 3\
D:\SteamLibrary\steamapps\common\The Witcher 3\
```

Дальше (ниже `<игра>` = эта папка):

1. Папку `modLootMultiplier` из репозитория скопировать в `<игра>\mods\`
   (папки `mods` может не быть — создай). Итог:
   `<игра>\mods\modLootMultiplier\content\scripts\local\lootMultiplier.ws`
2. Файл `modLootMultiplier.xml` (лежит в `bin\config\r4game\user_config_matrix\pc\`)
   скопировать в `<игра>\bin\config\r4game\user_config_matrix\pc\`.
3. В этой же папке открыть блокнотом `dx12filelist.txt`, в самый конец добавить
   строку `modLootMultiplier.xml;` и сохранить. Играешь в DX11 — то же самое
   в `dx11filelist.txt` (можно прописать в оба файла, хуже не будет).

Нюансы именно Steam-версии:

- Папка мода обязана начинаться с `mod` (`modLootMultiplier`), иначе игра её
  проигнорирует.
- Моды, на которые ты подписан в мастерской Steam, лежат **не** в `<игра>\mods`,
  а в `...\steamapps\workshop\content\292030\` — они этому моду не мешают, но и
  Script Merger их не видит.
- После «Проверить целостность файлов игры» Steam может вернуть оригинальные
  `dx11filelist.txt` / `dx12filelist.txt` — если меню пропало, просто заново
  добавь строку из шага 3.

### Вариант 3 — руками (GOG / Epic, то же самое)
>>>>>>> 913562b (README: ручная установка для Steam-версии + публикация в мастерскую)

1. Папку `modLootMultiplier` целиком скопировать в `<игра>\mods\`
   (должно получиться `<игра>\mods\modLootMultiplier\content\scripts\local\*.ws`).
2. Файл `bin\config\r4game\user_config_matrix\pc\modLootMultiplier.xml`
   скопировать в `<игра>\bin\config\r4game\user_config_matrix\pc\`.
3. В файлах `<игра>\bin\config\r4game\user_config_matrix\pc\dx11filelist.txt` и
   `dx12filelist.txt` **в конце** добавить строку (если её нет):

   ```
   modLootMultiplier.xml;
   ```

   Без этого шага меню в игре не появится — это особенность Next-Gen/Remastered.

Запускай игру → **Настройки → Моды → Loot Multiplier**.

### Проверка, что скрипт загрузился

Включи консоль: `bin\config\base\general.ini` → строка `DBGConsoleOn=true`.
В игре нажми `~` и набери:

```
lm_status()
```

В ответ придёт сообщение с текущими множителями. Если команда unknown — мод
не подхватился (проверь путь `mods\modLootMultiplier\content\scripts\local\`).

---

## Настройки (меню «Настройки → Моды → Loot Multiplier»)

| Параметр | По умолчанию | Что делает |
|---|---|---|
| Включить мод | вкл | Главный тумблер |
| Общий множитель ресурсов (×) | 3 | Один множитель на всё |
| Разные множители по источникам | выкл | Включить отдельные множители ниже |
| Контейнеры: сундуки, бочки, ящики (×) | 3 | — |
| Трупы: монстры, звери, люди (×) | 3 | — |
| Травы и грибы (×) | 3 | — |
| Отдельный множитель для крон | выкл | — |
| Кроны (×) | 1 | Множитель денег, если включено |
| Лимит предметов за раз (0 = без лимита) | 0 | Потолок на итоговое количество одного предмета за подбор |
| Трогать квестовые контейнеры | выкл | Множить ли лут в контейнерах с квестовыми предметами |
| Показывать сообщение при получении | вкл | Сообщение вида «Лут ×9: +6 Медная руда» |
| Писать подробности в лог (отладка) | выкл | Пишет в лог канал `LootMultiplier` |

Дефолты лежат в `modLootMultiplier\content\scripts\local\lootMultiplierConfig.ws` —
меняй вторым аргументом у `LM_GetBool(...)' / 'LM_GetFloat(...)`.

---

## Почему не mod.io (и про консоли)

В Remastered появился встроенный браузер модов на mod.io (PC + PS5/Xbox/Switch 2),
но в нём **запрещены**: mod-меню, правка .ini, кастомные кнопки и .dll-инъекции,
а на консолях запрещены loose-скрипты (нужен `precompiled.rsblob` из REDkit).
Меню настроек внутри игры = mod-меню, поэтому этот мод существует только в
формате «PC + loose-скрипты + XML меню». Если захочешь кроссплатформенную версию,
нужно собрать `precompiled.rsblob` в REDkit и вынести множитель в отдельные
варианты мода (×2/×3/×5/×10) — меню тогда не будет.

---

## Возможные проблемы

**Меню «Моды» не видно / в нём нет Loot Multiplier**
Не добавлена строка `modLootMultiplier.xml;` в `dx11filelist.txt` / `dx12filelist.txt`
(какой именно файл — зависит от того, в DX11 или DX12 ты играешь, пропиши в оба).

**Вместо русских названий — ключи вида `panel_LootMultiplier`**
Ярлык не локализован. Ставь [Custom Localization Fix](https://www.nexusmods.com/witcher3/mods/897)
или [Menu Organizer](https://www.nexusmods.com/witcher3/mods/10519).

**Кракозябры вместо русского текста / ошибка компиляции скриптов**
Все `.ws` и `.xml` файлы должны быть в **UTF-8 без BOM**. В Remastered UTF-16 больше
не поддерживается — если редактор сохранил в UTF-16, пересохрани в UTF-8.

**Множитель не применяется**
Проверь `lm_status()` в консоли, и что папка называется именно `modLootMultiplier`
(игра грузит только папки, начинающиеся с `mod`).

**Слишком жирно**
Поставь «Лимит предметов за раз», например 50, и отдельный множитель на кроны ×1.

---

<<<<<<< HEAD
=======
## Публикация в мастерскую Steam (если хочешь выложить мод)

Для «Ведьмака 3» прямой загрузки через клиент Steam нет — мод публикуется через
**The Witcher 3 REDkit** (бесплатный редактор в Steam): открываешь проект →
вкладка **Publish** → *Save and publish mod project* → заполняешь имя, версию,
описание и превью → в конце жмёшь **Publish to Steam Workshop**
(там же есть *Export zip package* — готовый архив для Nexus Mods, и
*Install project* — установка себе в игру).

Два момента, если пойдёшь этим путём:

- Мастерская ставит моды в `...\steamapps\workshop\content\292030\`, и файл меню
  `modLootMultiplier.xml` (он живёт в `bin\config\...`) мастерская не разложит —
  у подписчиков страницы «Настройки → Моды» не будет. Для мастерской лучше
  собрать пресеты (×2 / ×3 / ×5 / ×10) отдельными вариантами мода.
- Наш мод — это loose-скрипты. REDkit при публикации создаст `precompiled.rsblob`,
  так что в мастерской он будет работать и без `.ws` в открытом виде.

---

>>>>>>> 913562b (README: ручная установка для Steam-версии + публикация в мастерскую)
## Удаление

```powershell
powershell -ExecutionPolicy Bypass -File tools\install.ps1 -Uninstall
```

Или руками: удалить `<игра>\mods\modLootMultiplier`,
`<игра>\bin\config\r4game\user_config_matrix\pc\modLootMultiplier.xml` и строку
`modLootMultiplier.xml;` из `dx11filelist.txt` / `dx12filelist.txt`.
Сейвы не затрагиваются.

---

## Структура репозитория

```
modLootMultiplier\content\scripts\local\
    lootMultiplierConfig.ws   — чтение настроек из игрового меню
    lootMultiplier.ws         — хук GiveItemTo + exec-команда lm_status()
bin\config\r4game\user_config_matrix\pc\
    modLootMultiplier.xml     — страница мода в «Настройки → Моды»
tools\install.ps1             — установка / удаление
docs\remastered-modding-notes.md — конспект по моддингу Remastered
```

Полезные ссылки по теме:
- [What does the remaster mean for modding?](https://mod.io/g/the-witcher-3/r/what-does-the-remaster-mean-for-modding) (mod.io)
- [WS: Script Compilation Errors / annotations](https://cdprojektred.atlassian.net/wiki/spaces/W3REDkit/pages/36241598/WS+Script+Compilation+Errors+overrides) (REDkit)
- [Menus in The Witcher 3](https://witcher-games.fandom.com/wiki/Menus_in_The_Witcher_3) (формат меню)

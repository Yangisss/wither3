# Ведьмак 3: Дикая Охота — Remastered (2026): что важно для модостроения

Источники:
- [What does the remaster mean for modding?](https://mod.io/g/the-witcher-3/r/what-does-the-remaster-mean-for-modding) (mod.io, 28–29.09.2026)
- [Remastered changes (The Witcher 3)](https://witcher.fandom.com/wiki/Remastered_changes_(The_Witcher_3))
- [Witcher 3 REDkit — Installing Mods](https://cdprojektred.atlassian.net/wiki/spaces/W3REDkit/pages/36339714)
- [WS: Create your first script mod](https://cdprojektred.atlassian.net/wiki/spaces/W3REDkit/pages/36241465/WS+Create+your+first+script+mod)

## Контекст
Remastered вышел 29 сентября 2026 на PC, PS5, Xbox Series X|S и Switch 2.
В игру встроен мод-браузер на базе **mod.io** (меню «Mods» в главном меню, вход через CD PROJEKT RED аккаунт).
REDkit получил обновления движка/UI. Версия игры для проверки совместимости — **5.00**.

## Breaking changes
- **UTF-16 → UTF-8** для всех текстовых файлов: `.w3strings`, `.ws`, `.xml`, `.csv` (+ обновить заголовок XML). Старые моды с такими файлами перестают работать.
- **collision.cache** — новый формат, нужно перегенерировать (REDkit / wcc_lite).
- **SpeedTree (.srt)** — добавлен REDengine-заголовок, старые SRT несовместимы.
- **Звук** — Wwise 2023 (не новее 2023.1.17) + Mastering Suite/Motion;soundspc.cache перегенерация.
- Для консолей: `.reddlc` должен монтировать XML **по одному файлу**, а не папкой
  (`CR4DefinitionsDLCMounter`, `CR4DefinitionsNGPlusDLCMounter`). На PC проблемы нет.

## Новые возможности
- Типы `map` и `set` в WitcherScript; Community Patch — Shared Imports встроен в игру.
- **Расширенные аннотации** (`@wrapMethod`, `@addMethod`, `@replaceMethod`): можно оборачивать
  состояния конечных автоматов, глобальные и нативные функции.
- **Scope-based scripting** — добавление функций/переменных/enum-значений в отдельном файле.
- **XML override** через `on_conflict="extend" | "replace"` (работает для `<ability>`, `<item>`,
  `<set>`, `<reward>`, `<res>` и др.; НЕ работает для `<skills>`, `<effects>`, `<mutations>`,
  `<alchemy_recipes>`, `<crafting_schematics>`).
- Новые DLC-маунтеры: экраны загрузки, физические текстуры.
- Упрощённое добавление карт Гвинта (новые параметры `item` и `name` в XML карты).
- Сняты лимиты на количество функций и ID предметов.

## Установка модов (PC)
`<игра>/mods/mod<Имя>/` — папка должна начинаться с `mod`.
Скрипты: `mods/mod<Имя>/content/scripts/local/*.ws`.
Порядок загрузки: `Documents/The Witcher 3/mods.settings` (`[modname] Enabled=, Priority=`).

## Рекомендации авторам
- Использовать XML override + аннотации + scope-based scripting — они бесконфликтны.
- `precompiled.rsblob` обязателен на консолях (Loose Scripts там запрещены); на PC желательно
  поставлять и `.ws` рядом.
- Для mod.io: JSON-файл с именем/версией/описанием/версией игры, все пути в архиве в нижнем регистре.
- Не пройдут модерацию: моды с nudity/violence, шейдерами, .dll-инъекциями, меню-модами и правкой .ini.

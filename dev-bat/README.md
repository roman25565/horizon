# Скрипти для збірки форку Horizon

Поклади цю папку в корінь репозиторію (`F:\MinecraftTools\horizonFork\dev-bat\`). Запускати можна подвійним кліком або з терміналу.

| Файл | Що робить |
| --- | --- |
| `launcher-run.bat` | Збирає (якщо щось змінилось) і запускає лаунчер з окремими dev-папками |
| `launcher-check.bat` | `cargo check` + `cargo test --lib` для лаунчера, швидка перевірка після змін |
| `launcher-build.bat` | Release-збірка лаунчера → `dist\horizon-launcher.exe` |
| `game-prepare.bat <server.jar>` | Один раз: готує ресурси гри з твоєї копії Minecraft 26.3 (потрібен JDK 25) |
| `game-run.bat [аргументи]` | Збирає і запускає гру напряму, офлайн, без лаунчера |
| `game-build.bat` | Release-збірка гри → `dist\horizon-client.exe` |
| `game-import.bat` | Збирає гру й лаунчер і імпортує твою гру в dev-лаунчер як окрему версію |
| `check-all.bat` | `tools\pr_ready.py`: форматування, clippy, тести перед комітом |
| `clean.bat` | Видаляє папки `target` (звільняє гігабайти) |
| `_env.bat` | Спільні налаштування, викликається іншими скриптами |

**Особисті налаштування** поклади в `local.bat` поруч (його не треба комітити):

```
set "HORIZON_MSA_CLIENT_ID=твій-client-id"
set "HORIZON_SERVER_JAR=F:\MinecraftTools\server-26.3.jar"
```

Dev-запуски тримають дані в `<репо>\.dev-data\` (через `HORIZON_LAUNCHER_HOME` і `HORIZON_HOME`), тож справжня установка Horizon не зачіпається. Додай у `.gitignore` рядки `dist/`, `.dev-data/` і `dev-bat/local.bat`.

## Мок входу Microsoft

`mock_ms.py` імітує весь ланцюжок Microsoft → Xbox → XSTS → Minecraft з фейковими токенами. `launcher-run-mock.bat [--name Roman] [--no-own] [--xerr 2148916233]` запускає мок і debug-лаунчер, спрямований на нього, з окремою папкою `.dev-data-mock\`. Потрібна правка `Endpoints::live()` в `launcher/src/account.rs` (змінна `HORIZON_MOCK_AUTH`, працює лише в debug-збірці).

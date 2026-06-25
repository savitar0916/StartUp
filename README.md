# StartUp Shell

一鍵設定全新環境的開機腳本：更新系統、安裝常用套件，並把終端機環境配置成 **zsh + oh-my-zsh + powerlevel10k**。

支援 **Linux (Debian/Ubuntu)** 與 **macOS**，腳本會自動偵測作業系統並選用對應的指令。

## 功能

- 更新系統並安裝基本套件(vim、curl、wget、git)
- (可選)設定時區為 `Asia/Taipei`
- 安裝 zsh(macOS 內建,自動略過)並設為預設 shell
- 安裝 oh-my-zsh
- 安裝外掛:zsh-syntax-highlighting、zsh-autosuggestions
- 安裝 powerlevel10k 主題與 MesloLGS Nerd Font
- 自動寫入 `~/.zshrc`(啟用外掛、設定主題)

## 平台差異(自動處理)

| 項目 | Linux | macOS |
|------|-------|-------|
| 套件管理 | `apt` | Homebrew(未安裝會自動安裝) |
| 時區設定 | `timedatectl` | `systemsetup` |
| 安裝 zsh | `apt install zsh` | 系統內建,略過 |
| 字體目錄 | `~/.local/share/fonts` | `~/Library/Fonts` |
| 字體快取 | `fc-cache` | 自動載入,不需處理 |

> macOS 自 Catalina (10.15) 起預設 shell 即為 zsh;腳本會偵測,已是 zsh 就不重複設定。

## 使用方式

```bash
git clone <this-repo>
cd StartUp
./startup.sh
```

或:

```bash
bash startup.sh
```

> ⚠️ 請使用 `bash` 執行,勿用 `sh startup.sh`。
> 過程中會詢問是否設定時區,並可能要求輸入使用者密碼(設定預設 shell 時)。
> 執行紀錄會寫入 `startup.log`。

## 注意事項

- 結尾會 `exec zsh` 直接切換到 zsh。
- 首次進入 zsh 時 powerlevel10k 會啟動設定精靈;若沒出現可手動執行 `p10k configure`。
- 字體需在終端機(iTerm2 / VS Code 等)手動選用 `MesloLGS NF` 才會正確顯示圖示。

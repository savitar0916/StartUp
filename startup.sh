#!/bin/bash

# 創建或覆蓋 startup.log
echo "腳本開始執行" > startup.log

# ---------------------------------------------------------------------------
# 偵測作業系統 (linux / macos)
# ---------------------------------------------------------------------------
case "$(uname -s)" in
    Linux*)  OS="linux" ;;
    Darwin*) OS="macos" ;;
    *)       echo "不支援的作業系統: $(uname -s)" | tee -a startup.log; exit 1 ;;
esac
echo "偵測到作業系統: $OS" | tee -a startup.log

# 跨平台的 sed -i：BSD (macOS) 需要一個空字串參數，GNU (Linux) 不需要
sed_inplace() {
    if [[ "$OS" == "macos" ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

# ---------------------------------------------------------------------------
# 更新系統 & 安裝基本套件
# ---------------------------------------------------------------------------
if [[ "$OS" == "macos" ]]; then
    # macOS：確保有 Homebrew
    if ! command -v brew >/dev/null 2>&1; then
        echo "安裝 Homebrew..." | tee -a startup.log
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> startup.log 2>&1 && echo "Homebrew 安裝成功！" | tee -a startup.log
        # 將 brew 加入當前 session 的 PATH（Apple Silicon 與 Intel 路徑不同）
        if [[ -x /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi

    echo "更新系統..." | tee -a startup.log
    brew update >> startup.log 2>&1 && brew upgrade >> startup.log 2>&1 && echo "系統更新成功！" | tee -a startup.log

    echo "安裝基本的套件..." | tee -a startup.log
    brew install vim curl wget git >> startup.log 2>&1 && echo "基本套件安裝成功！" | tee -a startup.log
else
    echo "更新系統..." | tee -a startup.log
    sudo apt update >> startup.log 2>&1 && sudo apt upgrade -y >> startup.log 2>&1 && echo "系統更新成功！" | tee -a startup.log

    echo "安裝基本的套件..." | tee -a startup.log
    sudo apt install -y vim curl wget git >> startup.log 2>&1 && echo "基本套件安裝成功！" | tee -a startup.log
fi

# ---------------------------------------------------------------------------
# 詢問是否要配置時區
# ---------------------------------------------------------------------------
read -p "請問是否需要配置時區? (y/n) " configure_timezone
if [[ $configure_timezone == [Yy]* ]]; then
    echo "配置時區..." | tee -a startup.log
    if [[ "$OS" == "macos" ]]; then
        sudo systemsetup -settimezone Asia/Taipei >> startup.log 2>&1 && echo "時區配置成功！" | tee -a startup.log
    else
        sudo timedatectl set-timezone Asia/Taipei >> startup.log 2>&1 && echo "時區配置成功！" | tee -a startup.log
    fi
fi

# ---------------------------------------------------------------------------
# 安裝 zsh（macOS 內建 zsh，免裝）
# ---------------------------------------------------------------------------
if [[ "$OS" == "macos" ]]; then
    echo "macOS 已內建 zsh，略過安裝。" | tee -a startup.log
else
    echo "安裝 zsh..." | tee -a startup.log
    sudo apt install -y zsh >> startup.log 2>&1 && echo "zsh 安裝成功！" | tee -a startup.log
fi

# 安裝 oh-my-zsh
echo "安裝 oh-my-zsh..." | tee -a startup.log
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc >> startup.log 2>&1 && echo "oh-my-zsh 安裝成功！" | tee -a startup.log

# 將 zsh 設置為當前用戶的默認 shell（已經是 zsh 就略過，避免多問一次密碼）
ZSH_PATH="$(which zsh)"
if [[ "$SHELL" == "$ZSH_PATH" ]]; then
    echo "目前預設 shell 已是 zsh，略過設定。" | tee -a startup.log
else
    echo "設置 zsh 為默認 shell ，請輸入使用者密碼:" | tee -a startup.log
    chsh -s "$ZSH_PATH" >> startup.log 2>&1 && echo "zsh 設置為默認 shell 成功！" | tee -a startup.log
fi

# 安裝 zsh-syntax-highlighting 插件
echo "安裝 zsh-syntax-highlighting 插件..." | tee -a startup.log
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting >> startup.log 2>&1 && echo "zsh-syntax-highlighting 插件安裝成功！" | tee -a startup.log

# 安裝 zsh-autosuggestions 插件
echo "安裝 zsh-autosuggestions 插件..." | tee -a startup.log
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions >> startup.log 2>&1 && echo "zsh-autosuggestions 插件安裝成功！" | tee -a startup.log

# 安裝 powerlevel10k 主題
echo "安裝 powerlevel10k 主題..." | tee -a startup.log
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k >> startup.log 2>&1 && echo "powerlevel10k 主題安裝成功！" | tee -a startup.log

# ---------------------------------------------------------------------------
# 安裝 Meslo Nerd Font
# ---------------------------------------------------------------------------
echo "安裝 Meslo Nerd Font..." | tee -a startup.log

## 下載字體檔案
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf >> startup.log 2>&1
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf >> startup.log 2>&1
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf >> startup.log 2>&1
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf >> startup.log 2>&1

## 依平台決定字體目錄並移動字體檔案
if [[ "$OS" == "macos" ]]; then
    FONT_DIR="$HOME/Library/Fonts"
else
    FONT_DIR="$HOME/.local/share/fonts"
fi
mkdir -p "$FONT_DIR"
mv MesloLGS* "$FONT_DIR/" >> startup.log 2>&1

## 更新字體快取（macOS 不需要，會自動載入）
if [[ "$OS" != "macos" ]]; then
    fc-cache -f -v >> startup.log 2>&1
fi

echo "Meslo Nerd Font 安裝完成！" | tee -a startup.log

# ---------------------------------------------------------------------------
# 設定 zsh 插件
# ---------------------------------------------------------------------------
echo "設定zsh插件中..." | tee -a startup.log
sed_inplace 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc >> startup.log 2>&1 && echo "設定zsh插件成功！" | tee -a startup.log

# 檢查並設定 ZSH_THEME
echo "檢查並設定 ZSH_THEME..." | tee -a startup.log
if grep -q 'ZSH_THEME=' ~/.zshrc; then
    sed_inplace 's|ZSH_THEME=".*"|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc >> startup.log 2>&1 && echo "ZSH_THEME 設定成功！" | tee -a startup.log
else
    echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> ~/.zshrc && echo "ZSH_THEME 設定成功！" | tee -a startup.log
fi

# 設定 p10k
# echo "設定 p10k..." | tee -a startup.log
# zsh -c "p10k configure && echo 'p10k 設定成功！' | tee -a startup.log"

# 為用戶切換當前shell
echo "為用戶切換當前 shell..." | tee -a startup.log
exec zsh

# 創建或覆蓋 startup.log
echo "腳本開始執行" > startup.log  

# 更新系統
echo "更新系統..." | tee -a startup.log
sudo apt update >> startup.log 2>&1 && sudo apt upgrade -y >> startup.log 2>&1 && echo "系統更新成功！" | tee -a startup.log

# 安裝基本的套件
echo "安裝基本的套件..." | tee -a startup.log
sudo apt install -y vim curl wget git >> startup.log 2>&1 && echo "基本套件安裝成功！" | tee -a startup.log

# 詢問是否要配置時區
read -p "Do you want to configure the timezone? (y/n) " configure_timezone
if [[ $configure_timezone == [Yy]* ]]; then
    echo "配置時區..." | tee -a startup.log
    sudo timedatectl set-timezone Asia/Taipei >> startup.log 2>&1 && echo "時區配置成功！" | tee -a startup.log
fi

# 安裝 zsh
echo "安裝 zsh..." | tee -a startup.log
sudo apt install -y zsh >> startup.log 2>&1 && echo "zsh 安裝成功！" | tee -a startup.log

# 安裝 oh-my-zsh
echo "安裝 oh-my-zsh..." | tee -a startup.log
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc >> startup.log 2>&1 && echo "oh-my-zsh 安裝成功！" | tee -a startup.log

# 將 zsh 設置為當前用戶的默認 shell
echo "設置 zsh 為默認 shell..." | tee -a startup.log
chsh -s $(which zsh) >> startup.log 2>&1 && echo "zsh 設置為默認 shell 成功！" | tee -a startup.log

# 安裝 zsh-syntax-highlighting 插件
echo "安裝 zsh-syntax-highlighting 插件..." | tee -a startup.log
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting >> startup.log 2>&1 && echo "zsh-syntax-highlighting 插件安裝成功！" | tee -a startup.log

# 安裝 zsh-autosuggestions 插件
echo "安裝 zsh-autosuggestions 插件..." | tee -a startup.log
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions >> startup.log 2>&1 && echo "zsh-autosuggestions 插件安裝成功！" | tee -a startup.log

# 安裝 powerlevel10k 主題
echo "安裝 powerlevel10k 主題..." | tee -a startup.log
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k >> startup.log 2>&1 && echo "powerlevel10k 主題安裝成功！" | tee -a startup.log

# 安裝 Meslo Nerd Font
echo "安裝 Meslo Nerd Font..." | tee -a startup.log

## 下載字體檔案
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf >> startup.log 2>&1
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf >> startup.log 2>&1
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf >> startup.log 2>&1
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf >> startup.log 2>&1

## 創建字體目錄並移動字體檔案
mkdir -p ~/.local/share/fonts
mv MesloLGS* ~/.local/share/fonts/ >> startup.log 2>&1

## 更新字體快取
fc-cache -f -v >> startup.log 2>&1

echo "Meslo Nerd Font 安裝完成！" | tee -a startup.log

# 設定zsh插件
echo "設定zsh插件中..." | tee -a startup.log
sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc >> startup.log 2>&1 && echo "設定zsh插件成功！" | tee -a startup.log

# 檢查並設定 ZSH_THEME
echo "檢查並設定 ZSH_THEME..." | tee -a startup.log
if grep -q 'ZSH_THEME=' ~/.zshrc; then
    sed -i 's|ZSH_THEME=".*"|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc >> startup.log 2>&1 && echo "ZSH_THEME 設定成功！" | tee -a startup.log
else
    echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> ~/.zshrc && echo "ZSH_THEME 設定成功！" | tee -a startup.log
fi

# 設定 p10k
echo "設定 p10k..." | tee -a startup.log
p10k configure && echo "p10k 設定成功！" | tee -a startup.log

# 為用戶切換當前shell
echo "為用戶切換當前 shell..." | tee -a startup.log
exec zsh

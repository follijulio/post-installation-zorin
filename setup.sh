#!/bin/bash

# - - - - - - - - - - - - - - - - - - - - - - -
#   SCRIPT DE PÓS-INSTALAÇÃO PARA ZORIN OS
# - - - - - - - - - - - - - - - - - - - - - - -

# < obrigado @adelsonsljunior :kissing_heart /> 
# adaptei o script do adelson para o meu uso pessoal...
# ROUBEI MESMO (tecnicamente não é roubo, mas fazer o que né... no linux pode ksksksk)


## colores hihihi

GREEN='\e[0;32m' 
BLUE='\e[0;34m'
YELLOW='\e[1;33m'
DEFAULT='\e[0m'


DOWNLOADS_DIRECTORY="/tmp/programas_post_install"
FONTS_DIRECTORY="$HOME/.local/share/fonts"
WALLPAPER_DIRECTORY="$HOME/Imagens/wallpapers"

APT_PROGRAMS=(
    vim
    htop
    tree
    build-essential
    zsh
    tilix
    kitty
    alacritty
    sublime-text
    neovim
    gimp
    inkscape
    krita
    blender
    flameshot
    corectrl
    stacer
    timeshift
    steam
    opera-stable
    vagrant
)

FLATPAK_PROGRAMS=(
    # queria que tivesso o whatsapp, mas n achei... snap arcáico da boba cipó 
    com.obsproject.Studio
    org.telegram.desktop
    dev.vencord.Vesktop
    com.discordapp.Discord
    md.obsidian.Obsidian
    com.logseq.Logseq
    com.spotify.Client
    io.podman_desktop.PodmanDesktop
    com.getpostman.Postman
    rest.insomnia.Insomnia
    dev.k9s.k9s
    com.heroicgameslauncher.hgl
    net.lutris.Lutris
)

DEPENDENCIES=(
    software-properties-common
    apt-transport-https
    zip
    unzip
    dconf-cli
    curl
    git
)

print_section() {
    echo -e "\n${BLUE}=================================================================================${DEFAULT}"
    echo -e "${YELLOW}>> $1${DEFAULT}"
    echo -e "${BLUE}=================================================================================${DEFAULT}"
}

remove_apt_locks() {
    print_section "APT - Removendo locks pendentes (se houver)"
    sudo rm /var/lib/dpkg/lock-frontend &>/dev/null
    sudo rm /var/cache/apt/archives/lock &>/dev/null
}

setup_flatpak() {
    print_section "connfig Flatpak"
    sudo apt install -y flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

install_dependencies() {
    print_section "Instalando dependencias essenciais"
    for dependence in "${DEPENDENCIES[@]}"; do
        echo -e "${GREEN}[INFO] - Instalando ${dependence}.${DEFAULT}"
        sudo apt install -y "$dependence"
    done
}

## isso foi chatgpt... não vou mentir
add_external_repos() {
    print_section "Adicionando repositórios de terceiros" 
    # VS Code
    echo -e "${GREEN}[INFO] - Adicionando repositório do Visual Studio Code.${DEFAULT}"
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

    # Sublime Text
    echo -e "${GREEN}[INFO] - Adicionando repositório do Sublime Text.${DEFAULT}"
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

    # Opera
    echo -e "${GREEN}[INFO] - Adicionando repositório do Opera.${DEFAULT}"
    curl -sSL https://deb.opera.com/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/opera-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/opera-archive-keyring.gpg] https://deb.opera.com/opera-stable/ stable non-free" | sudo tee /etc/apt/sources.list.d/opera-stable.list

    # Vagrant
    echo -e "${GREEN}[INFO] - Adicionando repositório do Vagrant.${DEFAULT}"
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
}
## só até aqui...

install_apt_programs() {
    print_section "Instalando programas via APT"
    APT_PROGRAMS+=(code)
    for program in "${APT_PROGRAMS[@]}"; do
        echo -e "${GREEN}[INFO] - Instalando $program.${DEFAULT}"
        sudo apt install -y "$program"
    done
}

install_flatpak_programs() {
    print_section "Instalando programas via Flatpak"
    for program in "${FLATPAK_PROGRAMS[@]}"; do
        echo -e "${GREEN}[INFO] - Instalando $program.${DEFAULT}"
        flatpak install -y flathub "$program"
    done
}

install_docker() {
    print_section "Instalando Docker e Docker Compose"
    curl -fsSL https://get.docker.com -o get-docker.sh | bash
    
    echo -e "${GREEN}[INFO] - Adicionando seu usuário (${USER}) ao grupo docker.${DEFAULT}"
    sudo usermod -aG docker "$USER"
    echo -e "${YELLOW}AVISO: Você precisa reiniciar o sistema ou fazer logout/login para usar Docker sem 'sudo'.${DEFAULT}"
}

install_portainer() {
    print_section "Subindo contêiner do Portainer"
    sudo docker volume create portainer_data
    sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
}

install_asdf() {
    print_section "Instalando ASDF-VM"
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
    echo -e '\n. "$HOME/.asdf/asdf.sh"' >> ~/.zshrc
    echo -e '\n. "$HOME/.asdf/completions/asdf.bash"' >> ~/.zshrc
    source ~/.zshrc
    asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    asdf plugin-add python
    asdf plugin-add golang https://github.com/asdf-community/asdf-golang.git
    asdf plugin-add rust https://github.com/asdf-community/asdf-rust.git
    asdf install nodejs latest && asdf global nodejs latest
    asdf install python latest && asdf global python latest
    asdf install golang latest && asdf global golang latest
    asdf install rust latest && asdf global rust latest
}

install_dev_tools() {
    print_section "Instalando ferramentas de desenvolvimento adicionais"
    echo -e "${GREEN}[INFO] - Instalando Bun.${DEFAULT}"
    curl -fsSL https://bun.sh/install | bash
    echo -e "${GREEN}[INFO] - Instalando pnpm.${DEFAULT}"
    curl -fsSL https://get.pnpm.io/install.sh | sh
    echo -e "${GREEN}[INFO] - Instalando Yarn.${DEFAULT}"
    corepack enable && corepack prepare yarn@stable --activate
    echo -e "${GREEN}[INFO] - Instalando uv.${DEFAULT}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

install_oh_my_zsh() {
    print_section "Instalando Oh My Zsh e Plugins"
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${YELLOW}[AVISO] - Oh My Zsh já está instalado.${DEFAULT}"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo -e "${GREEN}[INFO] - Configurando o ZSH como shell padrão.${DEFAULT}"
    chsh -s $(which zsh)
}

configure_zsh() {
    print_section "Aplicando configurações ao .zshrc"
    sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc
    echo -e "${YELLOW}AVISO: O arquivo .zshrc foi modificado. Verifique se está tudo certo!${DEFAULT}"
}

configure_git() {
    print_section "Configurando Git"
    git config --global init.defaultBranch main
    echo -e "${YELLOW}Lembre-se de configurar seu nome e email no Git com:${DEFAULT}"
    echo -e "git config --global user.name \"Seu Nome\""
    echo -e "git config --global user.email \"seu-email@exemplo.com\""
}

install_nerd_font() {
    print_section "Instalando a fonte Meslo Nerd Font"
    [[ ! -d "$FONTS_DIRECTORY" ]] && mkdir -p "$FONTS_DIRECTORY"
    curl -fLo "$FONTS_DIRECTORY/MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    curl -fLo "$FONTS_DIRECTORY/MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    curl -fLo "$FONTS_DIRECTORY/MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    curl -fLo "$FONTS_DIRECTORY/MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    fc-cache -fv
}

set_default_terminal() {
    #! isso deveria ser opcional, mas n sei fazer isso ainda, mas como eu quero o tilix como padrão NO MEU ZORIN, n tem problema
    print_section "Definindo Tilix como terminal padrão" 
    sudo update-alternatives --set x-terminal-emulator /usr/bin/tilix
}

final_system_update() {
    print_section "Atualizando o sistema e limpando pacotes desnecessários" ## acho que isso funciona...
    sudo apt update && sudo apt dist-upgrade -y
    sudo apt autoclean -y
    sudo apt autoremove -y
}

main() {
    # sequencia
    remove_apt_locks
    sudo apt update
    install_dependencies
    add_external_repos
    setup_flatpak
    sudo apt update
    install_apt_programs
    install_flatpak_programs
    install_docker
    install_portainer
    install_asdf
    install_dev_tools
    install_oh_my_zsh
    configure_zsh 
    configure_git
    install_nerd_font
    set_default_terminal
    final_system_update
    print_section "SETUP CONCLUÍDO!"
    echo -e "${YELLOW}Reinicie o sistema para aplicar todas as mudanças...${DEFAULT}"
    echo -e "\n${GREEN}newgrp docker${DEFAULT}  <-- Execute esse comando em um novo terminal para ativar o docker na sesão, ou não."
    echo -e "${GREEN}Aproveite seu novo Zorin OS! hihihihihihihihihihihihihihi${DEFAULT}"
}

main

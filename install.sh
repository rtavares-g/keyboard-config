#!/bin/bash
# Aplica o layout de teclado PT (pc105, lv3:lalt_switch para AltGr) no
# sistema e no wayvnc (Raspberry Pi Connect).
# Uso: ./install.sh   (rodar de dentro da pasta clonada do repositorio)

set -e

REPO_URL="https://github.com/rtavares-g/keyboard-config.git"
INSTALL_DIR="$HOME/projetos/keyboard-config"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$SCRIPT_DIR" != "$INSTALL_DIR" ]; then
    if [ ! -d "$INSTALL_DIR" ]; then
        git clone "$REPO_URL" "$INSTALL_DIR"
    fi
    cd "$INSTALL_DIR"
else
    cd "$SCRIPT_DIR"
fi

sudo mkdir -p /etc/rpi-connect
sudo cp wayvnc.config /etc/rpi-connect/wayvnc.config
sudo cp keyboard /etc/default/keyboard

# Teclado virtual (squeekboard): layout BR com fileira Esc/Tab/Ctrl/Alt/Shift
# e layout BR para terminais (o pacote so traz terminal em us/de/es/fr).
# Os br*.yaml do pacote sao desviados com dpkg-divert para sobreviver a updates.
SQUEEK_DIR=/usr/share/misc/squeekboard/keyboards
if [ -d "$SQUEEK_DIR" ]; then
    for f in br.yaml br_wide.yaml; do
        sudo dpkg-divert --quiet --local --rename --divert "$SQUEEK_DIR/$f.distrib" --add "$SQUEEK_DIR/$f"
        sudo install -m 644 "squeekboard/$f" "$SQUEEK_DIR/$f"
    done
    sudo install -m 644 squeekboard/terminal/br.yaml squeekboard/terminal/br_wide.yaml "$SQUEEK_DIR/terminal/"
fi

sudo localectl set-x11-keymap pt pc105 "" lv3:lalt_switch

# Reaplica o layout no wayvnc (Raspberry Pi Connect), se estiver ativo
if systemctl --user is-active --quiet rpi-connect-wayvnc.service 2>/dev/null; then
    # Pode falhar por permissao (ex.: rodando dentro da propria sessao VNC);
    # a configuracao ja foi gravada e vale na proxima conexao.
    systemctl --user restart rpi-connect-wayvnc.service 2>/dev/null \
        || echo "Aviso: nao foi possivel reiniciar o wayvnc agora; o layout vale na proxima conexao do Pi Connect."
fi

echo "Layout de teclado PT (AltGr = lv3:lalt_switch) aplicado."
echo "Teclado virtual: os layouts BR valem a partir do proximo login."

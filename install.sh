#!/bin/bash
# Aplica o layout de teclado PT (pc105, lv3:lalt_switch para AltGr) no
# sistema e no wayvnc (Raspberry Pi Connect).
# Uso: ./install.sh   (rodar de dentro da pasta clonada do repositorio)

set -e

REPO_URL="https://github.com/rtavares-g/keyboard-config.git"
INSTALL_DIR="$HOME/keyboard-config"
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

sudo localectl set-x11-keymap pt pc105 "" lv3:lalt_switch

# Reaplica o layout no wayvnc (Raspberry Pi Connect), se estiver ativo
if systemctl --user is-active --quiet rpi-connect-wayvnc.service 2>/dev/null; then
    systemctl --user restart rpi-connect-wayvnc.service
fi

echo "Layout de teclado PT (AltGr = lv3:lalt_switch) aplicado."

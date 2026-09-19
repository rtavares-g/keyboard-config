# Keyboard Config — Raspberry Pi

Configuração do layout de teclado português (pc105, AltGr via
`lv3:lalt_switch`) para o sistema e para o VNC do Raspberry Pi Connect
(wayvnc).

## Arquivos

| Arquivo neste repo | Destino no sistema | Usado por |
|---|---|---|
| `keyboard` | `/etc/default/keyboard` | console/X11 (console-setup) |
| `wayvnc.config` | `/etc/rpi-connect/wayvnc.config` | wayvnc / Raspberry Pi Connect |

## Instalação

```bash
git clone https://github.com/rtavares-g/keyboard-config.git ~/keyboard-config
cd ~/keyboard-config
./install.sh
```

O script `install.sh`:

1. Copia `wayvnc.config` para `/etc/rpi-connect/wayvnc.config`.
2. Copia `keyboard` para `/etc/default/keyboard`.
3. Roda `sudo localectl set-x11-keymap pt pc105 "" lv3:lalt_switch`.
4. Reinicia o serviço `rpi-connect-wayvnc.service` (usuário), se estiver ativo.

## Instalação manual (passo a passo)

```bash
sudo mkdir -p /etc/rpi-connect
sudo nano /etc/rpi-connect/wayvnc.config
```

```
xkb_layout=pt
xkb_variant=
xkb_model=pc105
xkb_options=lv3:lalt_switch
```

```bash
sudo tee /etc/default/keyboard > /dev/null <<'EOF'
XKBMODEL="pc105"
XKBLAYOUT="pt"
XKBVARIANT=""
XKBOPTIONS="lv3:lalt_switch"
BACKSPACE="guess"
EOF

sudo localectl set-x11-keymap pt pc105 "" lv3:lalt_switch
```

## Reinstalar (ex: cartão SD novo)

```bash
git clone https://github.com/rtavares-g/keyboard-config.git ~/keyboard-config
cd ~/keyboard-config
./install.sh
```

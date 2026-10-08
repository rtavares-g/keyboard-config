# Keyboard Config — Raspberry Pi

Configuração do layout de teclado português (pc105, AltGr via
`lv3:lalt_switch`) para o sistema e para o VNC do Raspberry Pi Connect
(wayvnc).

## Arquivos

| Arquivo neste repo | Destino no sistema | Usado por |
|---|---|---|
| `keyboard` | `/etc/default/keyboard` | console/X11 (console-setup) |
| `wayvnc.config` | `/etc/rpi-connect/wayvnc.config` | wayvnc / Raspberry Pi Connect |
| `squeekboard/br*.yaml` | `/usr/share/misc/squeekboard/keyboards/` (via `dpkg-divert`) | teclado virtual (squeekboard) |
| `squeekboard/terminal/br*.yaml` | `/usr/share/misc/squeekboard/keyboards/terminal/` | teclado virtual (squeekboard) em terminais |
| `espaco/teclado-espaco.service` | `~/.config/systemd/user/` | sobe a janela quando o teclado virtual abre |
| `squeekboard/url/br*.yaml`, `squeekboard/email/br*.yaml` | `/usr/share/misc/squeekboard/keyboards/{url,email}/` | teclado virtual na barra de endereço e em campos de e-mail |

### Teclado virtual (squeekboard)

O teclado virtual segue o layout da sessão (`br`) em campos de texto comuns, mas
em terminais usa um layout especial (com Ctrl, Tab e setas) que o pacote só traz
em `us`, `de`, `es` e `fr`. Sem um layout de terminal `br`, ele cai para inglês.
Os arquivos em `squeekboard/terminal/` são o layout de terminal americano com a
linha `a s d f g h j k l ç` e uma tela de acentos (`Ãã`).

Na barra de endereço do navegador e em campos de e-mail acontece o mesmo: o
pacote só traz esses layouts em `us`. Os arquivos em `squeekboard/url/` e
`squeekboard/email/` são os americanos com o `ç` no fim da linha do meio.
(Número, PIN e emoji não têm letras, então ficam como estão.)

Os arquivos em `squeekboard/br*.yaml` são o layout BR do pacote com uma fileira
extra no topo: `Esc Tab Ctrl Alt Shift ↑ ↓ ← →`. Os originais são desviados com
`dpkg-divert` para `*.distrib`, então atualizações do pacote não sobrescrevem a
versão customizada. Para voltar ao original:

```bash
D=/usr/share/misc/squeekboard/keyboards
for f in br.yaml br_wide.yaml; do sudo rm "$D/$f"; sudo dpkg-divert --local --rename --remove "$D/$f"; done
```

Tudo passa a valer no próximo login (ou reiniciando o squeekboard).

### Janela sobe quando o teclado abre

O squeekboard reserva o espaço dele na tela e o painel sobe, mas o labwc só
ajusta janelas maximizadas; as outras ficam embaixo do teclado. O serviço de
usuário `teclado-espaco` (`espaco/teclado-espaco.py`) observa o teclado pelo
D-Bus (`sm.puri.OSK0`, propriedade `Visible`) e, quando ele abre, leva a janela
em foco até o topo da tela e, se ela não couber acima do teclado, diminui a
altura até caber. Janelas maximizadas ficam como estão (já encolhem sozinhas).
Quando o teclado fecha, a janela fica onde está.

O labwc não tem IPC, então a ação fica num atalho
(`Super+Ctrl+Alt+Shift+F11`, em `espaco/rc-keybinds.xml`) que o script
dispara com `wtype`. O `espaco/aplicar-rc.py` coloca esse atalho no
`~/.config/labwc/rc.xml` entre os comentários `teclado-espaco-inicio` e
`teclado-espaco-fim` (o labwc do Pi roda com `--merge-config`, então os
atalhos do sistema continuam valendo). Para desligar:

```bash
systemctl --user disable --now teclado-espaco
```

## Instalação

```bash
git clone https://github.com/rtavares-g/keyboard-config.git ~/projetos/keyboard-config
cd ~/projetos/keyboard-config
./install.sh
```

O script `install.sh`:

1. Copia `wayvnc.config` para `/etc/rpi-connect/wayvnc.config`.
2. Copia `keyboard` para `/etc/default/keyboard`.
3. Roda `sudo localectl set-x11-keymap pt pc105 "" lv3:lalt_switch`.
4. Instala os layouts PT-BR do teclado virtual (squeekboard): o normal, com a
   fileira Esc/Tab/Ctrl/Alt/Shift, e o de terminal.
5. Liga o serviço `teclado-espaco` e coloca o atalho dele no
   `~/.config/labwc/rc.xml` (janela sobe quando o teclado virtual abre).
6. Reinicia o serviço `rpi-connect-wayvnc.service` (usuário), se estiver ativo.
   Se isso falhar por permissão, o script só mostra um aviso: a configuração já
   foi gravada e passa a valer na próxima conexão.

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
git clone https://github.com/rtavares-g/keyboard-config.git ~/projetos/keyboard-config
cd ~/projetos/keyboard-config
./install.sh
```

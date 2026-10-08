#!/usr/bin/env python3
# Coloca (ou atualiza) os atalhos de rc-keybinds.xml no ~/.config/labwc/rc.xml.
# O labwc do Pi roda com --merge-config, entao os atalhos do sistema continuam.
import os
import re
import sys

rc = os.path.expanduser("~/.config/labwc/rc.xml")
bloco = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "rc-keybinds.xml")).read()
inicio, fim = "    <!-- teclado-espaco-inicio -->\n", "    <!-- teclado-espaco-fim -->\n"
bloco = inicio + bloco + fim

if os.path.exists(rc):
    s = open(rc).read()
else:
    s = '<?xml version="1.0"?>\n<openbox_config xmlns="http://openbox.org/3.4/rc">\n</openbox_config>\n'
s = re.sub(re.escape(inicio) + ".*?" + re.escape(fim), "", s, flags=re.S)
if "</keyboard>" in s:
    s = s.replace("  </keyboard>", bloco + "  </keyboard>", 1)
elif "</openbox_config>" in s:
    s = s.replace("</openbox_config>", "  <keyboard>\n" + bloco + "  </keyboard>\n</openbox_config>", 1)
else:
    sys.exit(f"{rc}: formato inesperado, nada alterado")
os.makedirs(os.path.dirname(rc), exist_ok=True)
open(rc, "w").write(s)

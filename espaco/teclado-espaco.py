#!/usr/bin/env python3
# Quando o teclado virtual (squeekboard) abre, sobe a janela em foco ate o
# topo da tela e, se ela nao couber acima do teclado, diminui ate caber.
#
# O labwc nao tem IPC: a acao fica num atalho do rc.xml (rc-keybinds.xml),
# que este script dispara com wtype.
import subprocess
import time

from gi.repository import Gio, GLib

ATALHO = ["wtype", "-M", "logo", "-M", "ctrl", "-M", "alt", "-M", "shift", "-k", "F11",
          "-m", "shift", "-m", "alt", "-m", "ctrl", "-m", "logo"]


def mudou(_proxy, alteradas, _invalidadas):
    if alteradas.unpack().get("Visible"):
        time.sleep(0.3)  # espera o labwc recalcular a area livre acima do teclado
        subprocess.run(ATALHO, check=False)


def main():
    proxy = Gio.DBusProxy.new_for_bus_sync(
        Gio.BusType.SESSION, Gio.DBusProxyFlags.DO_NOT_AUTO_START, None,
        "sm.puri.OSK0", "/sm/puri/OSK0", "sm.puri.OSK0", None)
    proxy.connect("g-properties-changed", mudou)
    GLib.MainLoop().run()


if __name__ == "__main__":
    main()

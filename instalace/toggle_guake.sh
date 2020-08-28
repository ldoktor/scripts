#!/usr/bin/env python3
# -*- coding: utf-8; -*-
# Copied from https://github.com/Guake/guake/issues/492#issuecomment-324165795
import dbus

try:
    bus = dbus.SessionBus()
    remote_object = bus.get_object('org.guake3.RemoteControl', '/org/guake3/RemoteControl')
    remote_object.show_hide()
except dbus.DBusException as details:
    print(details)

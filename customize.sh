#!/system/bin/sh
#############################################
# Auto_Target Module Permissions Script
#############################################

ui_print "------------------------------------------------"
ui_print "      Auto_Target: Applying Permissions         "
ui_print "------------------------------------------------"

set_perm_recursive $MODPATH 0 0 0755 0644

ui_print "- Fixing main scripts permissions..."
if [ -f "$MODPATH/action.sh" ]; then
    set_perm $MODPATH/action.sh 0 0 0755
fi
if [ -f "$MODPATH/service.sh" ]; then
    set_perm $MODPATH/service.sh 0 0 0755
fi
if [ -f "$MODPATH/uninstall.sh" ]; then
    set_perm $MODPATH/uninstall.sh 0 0 0755
fi

ui_print "- Fixing /scripts/ folder permissions..."
if [ -d "$MODPATH/scripts" ]; then
    for script in $MODPATH/scripts/*.sh; do
        set_perm $script 0 0 0755
    done
fi

ui_print "- Fixing /webroot/ folder permissions..."
if [ -d "$MODPATH/webroot" ]; then
    set_perm_recursive $MODPATH/webroot 0 0 0755 0644
fi

ui_print "------------------------------------------------"
ui_print "      Permissions Set Successfully!             "
ui_print "------------------------------------------------"
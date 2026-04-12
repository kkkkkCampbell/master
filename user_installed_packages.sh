#!/bin/sh

clear

echo
echo "==============================================="
echo "opkg update"

# Получаем самое старое время установки
DISTRI_TIME=$(awk '/Installed-Time/ {print $2}' /usr/lib/opkg/status | sort -n | head -n1)

# Генерируем список пакетов, разделяя на обычные и luci-i18n-
awk -v distri_time="$DISTRI_TIME" '
BEGIN { RS = ""; FS = "\n" }
{
    auto_installed = 0
    pkg_name = ""
    
    for (i = 1; i <= NF; i++) {
        if ($i ~ /^Package: /) {
            pkg_name = substr($i, 10)
        } else if ($i ~ /^Auto-Installed: yes/) {
            auto_installed = 1
        } else if ($i ~ "^Installed-Time: " distri_time "$") {
            auto_installed = 1
        }
    }
    
    if (pkg_name != "" && !auto_installed) {
        if (pkg_name ~ /luci-i18n-/) {
            print "2 " pkg_name  # luci-i18n помечаем "2"
        } else {
            print "1 " pkg_name  # остальные — "1"
        }
    }
}' /usr/lib/opkg/status | sort -k1,1n -k2 | cut -d' ' -f2- | while read pkg; do
    echo "opkg install $pkg"
done

echo "==============================================="

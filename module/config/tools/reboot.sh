MODDIR=/data/adb/modules/akashaProxy
${MODDIR}/config/scripts/clash.service -k && ${MODDIR}/config/scripts/clash.iptables -k
${MODDIR}/config/scripts/clash.service -s && ${MODDIR}/config/scripts/clash.iptables -s
MODDIR=/data/adb/akashaProxy
${MODDIR}/scripts/clash.service -k && ${MODDIR}/scripts/clash.iptables -k
${MODDIR}/scripts/clash.service -s && ${MODDIR}/scripts/clash.iptables -s
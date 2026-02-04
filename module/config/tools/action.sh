MODDIR=/data/adb/modules/akashaProxy
. ${MODDIR}/config/clash.env

pid=$(curl -sL http://127.0.0.1:${kernel_ui_port} | grep mihomo)
if [[ "${pid}" ]]; then
    echo "正在停止akashaProxy."
    ${MODDIR}/config/scripts/clash.service -k && ${MODDIR}/config/scripts/clash.iptables -k
else
    echo "正在启动akashaProxy."
    ${MODDIR}/config/scripts/clash.service -s && ${MODDIR}/config/scripts/clash.iptables -s
fi

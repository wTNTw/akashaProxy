MODDIR=/data/adb/akashaProxy
. ${MODDIR}/clash.env

pid=$(curl -sL http://127.0.0.1:${kernel_ui_port} | grep mihomo)
if [[ "${pid}" ]]; then
    echo "正在停止akashaProxy."
    ${MODDIR}/scripts/clash.service -k && ${MODDIR}/scripts/clash.iptables -k
else
    echo "正在启动akashaProxy."
    ${MODDIR}/scripts/clash.service -s && ${MODDIR}/scripts/clash.iptables -s
fi

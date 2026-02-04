[ -z "$version" ] && . /data/adb/modules/akashaProxy/config/clash.config

pid=$(busybox pidof ${plugins_dir}/ruleconverter/bin/ruleconverter)
if [ -n "${pid}" ]; then
    kill -15 ${pid}
fi
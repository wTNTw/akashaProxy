MODDIR=/data/adb/modules/akashaProxy
[ -z "$version" ] && . ${MODDIR}/config/clash.config

if [ "$ruleconverter" != "true" ]; then
    exit 0
fi

nohup ${plugins_dir}/ruleconverter/bin/ruleconverter -port ${ruleconverter_port} 2>&1 &

log "info: ruleconverter 模块已启动，监听端口: ${ruleconverter_port}."
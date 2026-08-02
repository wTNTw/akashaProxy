MODDIR=/data/adb/akashaProxy
[ -z "$version" ] && . ${MODDIR}/clash.config

if [ "$ruleconverter" != "true" ]; then
    exit 0
fi

nohup ${plugins_dir}/ruleconverter/bin/ruleconverter -port ${ruleconverter_port} > ${run_path}/ruleconverter.log 2>&1 &

log "info: ruleconverter 模块已启动，监听端口: ${ruleconverter_port}."
[ -z "$version" ] && . /data/adb/akashaProxy/clash.config

pid=$(lsof | grep :${ruleconverter_port})

if [ -n "${pid}" ]; then
    kill -15 $(echo ${pid} | awk '{print $2}')
fi


MODDIR=${0%/*}

until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done

until [ -d "/sdcard/Android" ]; do
    sleep 2
done

. ${MODDIR}/config/clash.config

if [ ! -d ${MODDIR}/config/run ]; then
    mkdir -p ${MODDIR}/config/run
fi
crond -c ${MODDIR}/config/run

if [ "${compatible_dashboard}" = "true" ] ; then
    rm -rf /data/clash
    ln -s ${MODDIR}/config /data/clash
fi

if [ "${self_start}" = "true" ] ; then
    nohup ${MODDIR}/config/scripts/clash.service -s && ${MODDIR}/config/scripts/clash.iptables -s & > ${MODDIR}/config/run/run.logs 2>&1 &
fi

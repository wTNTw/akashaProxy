SKIPUNZIP=1

[ -d "/data/adb/modules/Clash_For_Magisk" ] && rm -rf /data/adb/modules/Clash_For_Magisk
system_gid="1000"
system_uid="1000"
data_dir="/data/adb/akashaProxy"

[ -d "${data_dir}" ] || mkdir -p "${data_dir}"
[ -d "${data_dir}/run" ] || mkdir -p "${data_dir}/run"
[ -d "${data_dir}/kernel" ] || mkdir -p "${data_dir}/kernel"
[ -d "${data_dir}/clashkernel" ] && rm -rf "${data_dir}/clashkernel"
[ -d "${data_dir}/module" ] && rm -rf "${data_dir}/module"

unzip -o "${ZIPFILE}" 'bin/*' -d "${TMPDIR}"
unzip -o "${ZIPFILE}" 'src/*' -d "${TMPDIR}"

unzip -o "${ZIPFILE}" -x 'META-INF/*' -d "${MODPATH}"


if [ -f "${data_dir}/kernel/mihomo" ]; then
    ui_print "- 模块已安装,跳过内核安装"
else
    case $(getprop ro.product.cpu.abi) in
        "arm64-v8a")
            ABI="arm64-v8"
            ;;
        "armeabi-v7a")
            ABI="armv7"
            ;;
        "x86")
            ABI="386"
            ;;
        "x86_64")
            ABI="amd64"
            ;;
        *)
            ABI="arm64-v8"
            ui_print "- 未知的架构: $(getprop ro.product.cpu.abi) 使用默认架构: arm64-v8"
            ;;
    esac

    if [ ! -f "${data_dir}/kernel/mihomo" ]; then
        if [ -f "${TMPDIR}/bin/mihomo-android-${ABI}.gz" ]; then
            ui_print "- 正在解压 mihomo 内核..."
            gzip -d "${TMPDIR}/bin/mihomo-android-${ABI}.gz"
            mv -f "${TMPDIR}/bin/mihomo-android-${ABI}" "${data_dir}/kernel/mihomo"
        else
            abort "- 在模块中未找到架构: ${ABI} 请自行下载对应架构的mihomo → https://github.com/MetaCubeX/mihomo/releases"
        fi
    fi
fi


if [ -f "${data_dir}/config.yaml" ]; then
    ui_print "- config.yaml 文件已存在 跳过覆盖."
    rm -rf "${TMPDIR}/src/config.example.yaml"
else
    mv -f "${TMPDIR}/src/config.example.yaml" "${TMPDIR}/src/config.yaml"
fi

if [ -f "${data_dir}/packages.list" ]; then
        ui_print "- packages.list 文件已存在 跳过覆盖."
        rm -rf "${TMPDIR}/src/packages.list"
fi

if [ -f "${data_dir}/clash.config" ]; then
    mode=$(grep -i "^mode" "${data_dir}/clash.config" | awk -F '=' '{print $2}' | sed "s/\"//g")

    oldVersion=$(grep -i "version" "${data_dir}/clash.config" | awk -F '=' '{print $2}' | sed "s/\"//g")
    newVersion=$(grep -i "version" "${TMPDIR}/src/clash.config" | awk -F '=' '{print $2}' | sed "s/\"//g")

    if [ "${oldVersion}" -ge "${newVersion}" ] && [ ! "${oldVersion}" = "" ]; then
        ui_print "- clash.config 文件已存在 跳过覆盖."
        rm -rf "${TMPDIR}/src/clash.config"
    else
        sed -i "s/global/${mode}/g" "${TMPDIR}/src/clash.config"
        cp -Rf "${data_dir}/clash.config" "${data_dir}/clash.config.old"
    fi
fi


cp -Rf "${TMPDIR}"/src/* "${data_dir}/"

ui_print "- 开始设置权限."
set_perm_recursive "${MODPATH}" 0 0 0770 0770
set_perm_recursive "${data_dir}" ${system_uid} ${system_gid} 0770 0770
set_perm_recursive "${data_dir}/scripts" ${system_uid} ${system_gid} 0770 0770
set_perm_recursive "${data_dir}/tools" ${system_uid} ${system_gid} 0770 0770
set_perm_recursive "${data_dir}/kernel" ${system_uid} ${system_gid} 6770 6770
set_perm  "${data_dir}/kernel/mihomo"  ${system_uid}  ${system_gid}  6770
set_perm  "${data_dir}/clash.config" ${system_uid} ${system_gid} 0770
set_perm  "${data_dir}/packages.list" ${system_uid} ${system_gid} 0770


ui_print "
************************************************
使用须知:
1. 拥有自主判断/分析能力
2. 知道如何使用搜索引擎
3. 拥有阅读官方文档的能力
4. 拥有基础的Linux知识
5. 乐于折腾

> 否则不建议您使用本模块

配置目录: ${data_dir}
如何使用本模块清查阅→https://github.com/akashaProxy/akashaProxy
如何使用mihomo以及配置文件文档清查阅→https://wiki.metacubex.one/config
请重命名为 config.yaml 后使用DashBoard启动/停止 或者使用tools文件夹下的start.sh/stop.sh
************************************************
Telegram Channel: https://t.me/akashaProxyci
"

#!/bin/bash
#
# Auto maker Script for FlymeOS patchrom
# Script Start

x=`date +%Y`
y=`date +.%-m.%-d`
z=${x: -1:1}
time=`date +%c`
utc=`date +%s`
build_date=`date +%Y%m%d`

#192.168.88.1 is local address
ping -c 3 -w 5 192.168.88.1
if [[ $? != 0 ]];then
  THREAD=8
  source_dir="/root/flyme7"
  out_dir="/var/www/html/flyme7/ROM"
  flyme_dir="/var/www/html/flyme7/FlymeOfficial"
  flyme_int_dir="/var/www/html/flyme7/FlymeIntOfficial"
  ota_dir="/var/www/html/flyme7/OTA"
  target_dir="/var/www/html/flyme7/target_files"
else
  THREAD=4
  user=`whoami`
  source_dir="/home/$user/flyme7"
  out_dir="/home/$user/flyme/ROM"
  flyme_dir="/home/$user/flyme/FlymeOfficial"
  flyme_int_dir="/home/$user/flyme/FlymeIntOfficial"
  ota_dir="/home/$user/flyme/OTA"
  target_dir="/home/$user/flyme/target_files"
fi

devices_dir="${source_dir}/devices"

function setVersion() {
  cd $source_dir
  clear
  ls $out_dir
  read -p "Please Enter Build Version:" version
  if [ "${version}" = "" ]; then
    export version=$z$y
  else
    export version
  fi
  #if [ ! -f $days ]; then
    #repo sync
    #touch $days
  #fi
  clear
}

function config(){
  FLYME_OFFICIAL=0
  FLYME_INT_NEED=0

  #here is nubia base devices
  if [ $1 == "nx531j_nubia" ];then
  	SUPPORT_OTA=1
	NO_THIRD=1
	SUPPORT_LITTLERABBIT=1
	CM_BASE=0
	NUBIA_BASE=1
	SAM_BASE=0
	MIUI_BASE=0
  elif [ $1 == "nx531j_cm" ];then
	SUPPORT_OTA=1
	NO_THIRD=1
	SUPPORT_LITTLERABBIT=0
	CM_BASE=1
	NUBIA_BASE=0
	SAM_BASE=0
	MIUI_BASE=0
	FLYME_OFFICIAL=1
  elif [ $1 == "heroltexx" ];then
	SUPPORT_OTA=1
	NO_THIRD=0
	SUPPORT_LITTLERABBIT=0
	CM_BASE=1
	NUBIA_BASE=0
	SAM_BASE=0
	MIUI_BASE=0
	FLYME_OFFICIAL=1
    else
	SUPPORT_OTA=1
	NO_THIRD=0
	SUPPORT_LITTLERABBIT=0
	CM_BASE=1
	NUBIA_BASE=0
	SAM_BASE=0
	MIUI_BASE=0
  fi
}

function init(){
	echo ">>> 正在初始化环境 ...    "
	setVersion
#	clear_ds ${source_dir}
	cd ${source_dir}
	source build/envsetup.sh >/dev/null
	echo "<<< 环境初始化完成！     "
	sed -i '/ro\.build\.version\.incremental/d' flyme/release/chinese/arm/SYSTEM/build.prop
	sed -i '/ro\.build\.version\.incremental/d' flyme/release/international/arm/SYSTEM/build.prop
	echo "ro.build.version.incremental=${version}" >> flyme/release/chinese/arm/SYSTEM/build.prop
	echo "ro.build.version.incremental=${version}" >> flyme/release/international/arm/SYSTEM/build.prop
}

function third(){
	cd ${source_dir}
	rm -rf devices/$1/overlay/system/priv-app
	rm -rf devices/$1/overlay/data/app
	mkdir -p devices/$1/overlay/system/priv-app devices/$1/overlay/data/app

	if [ ${NO_THIRD} != "1" ];then
	    cp -rf third-app/app/* devices/$1/overlay/data/app/
	    cp -rf third-app/priv-app/* devices/$1/overlay/system/priv-app/
	fi

	if [ ${SUPPORT_LITTLERABBIT} == "1" ];then
	    cp -rf third-app/ttotoo-app/MiGuard devices/$1/overlay/system/priv-app/
          if [ ${SUPPORT_OTA} == "1" ];then
             cp -rf third-app/ttotoo-app/FlymeUpdater devices/$1/overlay/system/priv-app/
          fi
	fi

	if [ ${CM_BASE} == "1" ];then
	    cp -rf third-app/ttotoo-app/LRSettings devices/$1/overlay/system/priv-app/
	    cp -rf third-app/ttotoo-app/CMParts devices/$1/overlay/system/priv-app/
	fi

	if [ ${NUBIA_BASE} == "1" ];then
			cp -rf third-app/ttotoo-app/StockSettings_Nubia devices/$1/overlay/system/priv-app/
	fi
	echo "<<< 添加推广完成！   "
}

function clean(){
	config $1
	cd ${source_dir}/devices/$1
	make clean
	rm -rf history_package last_target board
	mkdir -p ${target_dir}

  if [ ${SUPPORT_LITTLERABBIT} == "1" ];then
    mkdir -p ${out_dir}/${version}/$1
		mkdir -p ${ota_dir}/$1/${version}
  elif [ ${FLYME_OFFICIAL} == "1" ];then
    mkdir -p ${flyme_dir}/${version}/$1
    mkdir -p ${flyme_int_dir}/${version}/$1
  elif [ ${FLYME_INT_NEED} == "1" ];then
    mkdir -p ${flyme_int_dir}/${version}/$1
    mkdir -p ${out_dir}/${version}/$1
  else
    mkdir -p ${out_dir}/${version}/$1
	fi

	echo "<<< 缓存文件清理完成！   "
}

function fullota(){
	cd ${source_dir}/devices/$1
	echo ">>>  开始${THREAD}线程制作完整刷机包  ...     "

  grep -q "#PRODUCE_INTERNATIONAL_ROM" Makefile
  if [ "$?" != "0" ];then
    sed -i -e "s/PRODUCE_INTERNATIONAL_ROM/#PRODUCE_INTERNATIONAL_ROM/g" Makefile
  fi

	time make fullota -j${THREAD}
	if [ "$?" == "0" ]; then
		echo ">>>  完整刷机包制作完成！ "
	else
		echo "[Flyme CUST] OTA: $1刷机包生成失败，请检查编译日志！ " >> ${source_dir}/${build_date}.log
	fi
	if [ ${FLYME_OFFICIAL} == "1" ];then
		mv out/flyme_*.zip ${flyme_dir}/${version}/$1/
	else
		mv out/flyme_*.zip ${out_dir}/${version}/$1/full-$1-${version}.zip
    rm -rf overlay/system/priv-app
  	rm -rf overlay/data/app
	fi
}

function ota(){
	cd ${source_dir}
	mv ${target_dir}/$1-target-files.zip ${target_dir}/$1-last-target-files.zip
	mv ${source_dir}/devices/$1/out/target_fil*.zip ${target_dir}/$1-target-files.zip
	if [ ${SUPPORT_LITTLERABBIT} == "1" ];then
		./build/tools/releasetools/ota_from_target_files.py -k ./build/security/testkey -i ${target_dir}/$1-last-target-files.zip ${target_dir}/$1-target-files.zip ${ota_dir}/$1/${version}/ota-$1-${version}.zip
	elif [ ${FLYME_OFFICIAL} == "1" ];then
                ./build/tools/releasetools/ota_from_target_files.py -k ./build/security/testkey -i ${target_dir}/$1-last-target-files.zip ${target_dir}/$1-target-files.zip ${flyme_dir}/${version}/$1/ota-$1-${version}.zip
	else
		./build/tools/releasetools/ota_from_target_files.py -k ./build/security/testkey -i ${target_dir}/$1-last-target-files.zip ${target_dir}/$1-target-files.zip ${out_dir}/${version}/$1/ota-$1-${version}.zip
	fi
}

function fullotaInt(){
	cd ${source_dir}/devices/$1
  make clean
  rm -rf history_package last_target board

	echo ">>>  开始${THREAD}线程制作完整刷机包  ...     "

  grep -q "#PRODUCE_INTERNATIONAL_ROM" Makefile
  if [ "$?" == "0" ];then
    sed -i -e "s/#PRODUCE_INTERNATIONAL_ROM/PRODUCE_INTERNATIONAL_ROM/g" Makefile
  fi

	time make fullota -j${THREAD}
	if [ "$?" == "0" ]; then
		echo ">>>  完整刷机包制作完成！ "
	else
		echo "[Flyme CUST] OTA: $1刷机包生成失败，请检查编译日志！ " >> ${source_dir}/${build_date}.log
	fi
	mv out/flyme_*.zip ${flyme_int_dir}/${version}/$1/

  grep -q "#PRODUCE_INTERNATIONAL_ROM" Makefile
  if [ "$?" != "0" ];then
    sed -i -e "s/PRODUCE_INTERNATIONAL_ROM/#PRODUCE_INTERNATIONAL_ROM/g" Makefile
  fi

  rm -rf overlay/system/priv-app
	rm -rf overlay/data/app
}

function build(){
	clean $1
	third $1
	fullota $1
	if [ ${SUPPORT_OTA} == "1" ];then
		ota $1
	fi
  if [ ${FLYME_OFFICIAL} == "1" ]||[ ${FLYME_INT_NEED} == "1" ];then
    #fullotaInt $1
    echo "Fuck Flyme!"
  fi
}


init

if [ "$1" ]; then
	build $1
else
    echo "机型目录:"
    for prj_dir in ${devices_dir}/*
    do
        if [[ ${prj_dir} != *.* ]]&&[[ ${prj_dir} != *base* ]]&&[[ ${prj_dir} != *pre* ]]&&[[ ${prj_dir} != *old_* ]];then
            temp_file=`basename ${prj_dir}`
            echo ${temp_file}
        fi
    done

    echo ""
    echo "请输入不编译机型目录:"
    read no_compile
    clear

    for prj_dir in ${devices_dir}/*
    do
        if [[ ${prj_dir} != *.* ]]&&[[ ${prj_dir} != *base* ]]&&[[ ${prj_dir} != *pre* ]]&&[[ ${prj_dir} != *old_* ]];then
            temp_file=`basename ${prj_dir}`
            if [[ ${no_compile} != *${temp_file}* ]];then
                build ${temp_file}
            fi
        fi
    done
fi

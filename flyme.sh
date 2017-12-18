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

THREAD=`sysctl hw.ncpu|cut -d" " -f2`

source_dir="~/flyme6"
out_dir="~/flyme/ROM"
flyme_dir="~/flyme/FlymeOfficial"
flyme_int_dir="/~/flyme/FlymeIntOfficial"
ota_dir="~/flyme/OTA"
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
  #here is samsung base devices
	elif [ $1 == "herolte" ]||[ $1 == "hero2qlte" ];then
		SUPPORT_OTA=1
		NO_THIRD=1
		SUPPORT_LITTLERABBIT=1
		CM_BASE=0
		NUBIA_BASE=0
		SAM_BASE=1
    MIUI_BASE=0
	elif [ $1 == "herolte_free" ]||[ $1 == "hero2qlte_free" ];then
		SUPPORT_OTA=1
		NO_THIRD=1
		SUPPORT_LITTLERABBIT=0
		CM_BASE=0
		NUBIA_BASE=0
		SAM_BASE=1
    MIUI_BASE=0
		FLYME_OFFICIAL=1
  elif [ $1 == "zerolte" ];then
		SUPPORT_OTA=1
		NO_THIRD=0
		SUPPORT_LITTLERABBIT=0
		CM_BASE=0
		NUBIA_BASE=0
		SAM_BASE=1
    MIUI_BASE=0
		FLYME_OFFICIAL=0
  #here is miui base devices
  elif [ $1 == "scorpio" ]||[ $1 == "capricorn_mi" ]||[ $1 == "natrium" ]||[ $1 == "lithium" ];then
    SUPPORT_OTA=1
    NO_THIRD=0
    SUPPORT_LITTLERABBIT=0
    CM_BASE=0
    NUBIA_BASE=0
    SAM_BASE=0
    MIUI_BASE=1
    FLYME_OFFICIA=0
	elif [ $1 == "nx531j_cm" ];then
		SUPPORT_OTA=1
		NO_THIRD=1
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
	cp -f third-app/ttotoo-app/Flyme_Camera/Camera.apk flyme/release/chinese/arm/SYSTEM/app/Camera/Camera.apk
	cp -f third-app/ttotoo-app/Flyme_Camera/Camera.apk flyme/release/international/arm/SYSTEM/app/Camera/Camera.apk
}

function third(){
	cd ${source_dir}
	rm -rf devices/$1/overlay/system/priv-app
	rm -rf devices/$1/overlay/data/app
	mkdir -p devices/$1/overlay/system/priv-app devices/$1/overlay/data/app devices/$1/overlay/system/supersu
	cp -rf third-app/supersu/* devices/$1/overlay/system/supersu

	if [ ${NO_THIRD} != "1" ];then
	    cp -rf third-app/app/* devices/$1/overlay/data/app/
	    cp -rf third-app/priv-app/* devices/$1/overlay/system/priv-app/
	    cp -rf third-app/ttotoo-app/FlymeCore devices/$1/overlay/system/priv-app/
	fi

	if [ ${SUPPORT_LITTLERABBIT} == "1" ];then
	    cp -rf third-app/ttotoo-app/MiGuard devices/$1/overlay/system/priv-app/
          if [ ${SUPPORT_OTA} == "1" ];then
             cp -rf third-app/ttotoo-app/FlymeUpdater devices/$1/overlay/system/priv-app/
          fi
	fi

	if [ ${CM_BASE} == "1" ];then
	    cp -rf third-app/ttotoo-app/LRSettings devices/$1/overlay/system/priv-app/
	fi

  if [ ${MIUI_BASE} == "1" ];then
	    cp -rf third-app/ttotoo-app/Settings_ex devices/$1/overlay/system/priv-app/
	fi

	if [ ${NUBIA_BASE} == "1" ];then
	    cp -rf third-app/ttotoo-app/Camera devices/$1/overlay/system/priv-app/
			cp -rf third-app/ttotoo-app/StockSettings_Nubia devices/$1/overlay/system/priv-app/
	fi

	if [ ${SAM_BASE} == "1" ];then
    cp -rf third-app/ttotoo-app/Telecom devices/$1/overlay/system/priv-app/
    cp -rf third-app/ttotoo-app/Gallery devices/$1/overlay/system/priv-app/
		if [ ${NO_THIRD} == "0" ];then
			rm -rf devices/$1/overlay/system/supersu
		else
      if [ ${FLYME_OFFICIAL} == "0" ];then
           cp -rf third-app/ttotoo-app/AppCenter devices/$1/overlay/system/app/
           #cp -rf third-app/ttotoo-app/Mms devices/$1/overlay/system/priv-app/
      fi
		fi
	fi
	echo "<<< 添加推广完成！   "
}

function clean(){
	config $1
	cd ${source_dir}/devices/$1
	make clean
	rm -rf history_package last_target board

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

function backup(){
	cd ${source_dir}/devices/$1
	git add -A
	git commit -m "flyme upgrade"

	if [ ${CM_BASE} == "1" ]||[ $1 == "herolte" ]||[ $1 == "capricorn_mi" ];then
		flyme upgrade
    git add -A
    git commit -m "Update Flyme"
	fi

	if [ $1 == "nx531j_nubia" ]||[ $1 == "hero2qlte" ]||[ $1 == "herolte" ]||[ $1 == "scorpio" ];then
		git push --all
	fi

	if [ $1 == "herolte_free" ]||[ $1 == "hero2qlte_free" ];then
		git pull
	fi
}

function fullota(){
  if [ ${SAM_BASE} == "1" ]||[ ${MIUI_BASE} == "1" ];then
    rm -rf ${source_dir}/tools/reverses/apktool.jar
		ln -s ${source_dir}/tools/reverses/apktool_miui.jar ${source_dir}/tools/reverses/apktool.jar
	else
		rm -rf ${source_dir}/tools/reverses/apktool.jar
		ln -s ${source_dir}/tools/reverses/apktool_newest.jar ${source_dir}/tools/reverses/apktool.jar
	fi
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
	cd ${source_dir}/OTA
	mv $1-target-files.zip $1-last-target-files.zip
	mv ../devices/$1/out/target_fil*.zip $1-target-files.zip
	if [ ${SUPPORT_LITTLERABBIT} == "1" ];then
		../build/tools/releasetools/ota_from_target_files.py -k ../build/security/testkey -i $1-last-target-files.zip $1-target-files.zip ${ota_dir}/$1/${version}/ota-$1-${version}.zip
  elif [ ${FLYME_OFFICIAL} == "1" ];then
    ../build/tools/releasetools/ota_from_target_files.py -k ../build/security/testkey -i $1-last-target-files.zip $1-target-files.zip ${flyme_dir}/${version}/$1/ota-$1-${version}.zip
	else
		../build/tools/releasetools/ota_from_target_files.py -k ../build/security/testkey -i $1-last-target-files.zip $1-target-files.zip ${out_dir}/${version}/$1/ota-$1-${version}.zip
	fi
  cd ${source_dir}
}

function fullotaInt(){
	if [ ${SAM_BASE} == "1" ]||[ ${MIUI_BASE} == "1" ];then
    rm -rf ${source_dir}/tools/reverses/apktool.jar
		ln -s ${source_dir}/tools/reverses/apktool_miui.jar ${source_dir}/tools/reverses/apktool.jar
	else
		rm -rf ${source_dir}/tools/reverses/apktool.jar
		ln -s ${source_dir}/tools/reverses/apktool_newest.jar ${source_dir}/tools/reverses/apktool.jar
	fi
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
	backup $1
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

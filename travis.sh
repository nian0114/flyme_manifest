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


THREAD=2
user=`whoami`
source_dir="/home/$user/build/nian0114"
flyme_dir="/home/$user/build/nian0114/flyme/ROM"
target_dir="/home/$user/build/nian0114/flyme/target_files"

devices_dir="${source_dir}/devices"

function setVersion() {
  cd $source_dir
  clear
  ls $out_dir
  export version=$z$y
  sed -i "s/Flyme\ 6.*R/Flyme\ 6.${version}R/g" flyme/release/chinese/arm/SYSTEM/build.prop
  sed -i "s/Flyme\ 6.*R/Flyme\ 6.${version}R/g" flyme/release/international/arm/SYSTEM/build.prop 
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
	NO_THIRD=1
	SUPPORT_LITTLERABBIT=1
	CM_BASE=1
	NUBIA_BASE=0
	SAM_BASE=0
	MIUI_BASE=0
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
	    if [ ${CM_BASE} == "1" ];then
	        cp -rf third-app/ttotoo-app/LRSettings_free devices/$1/overlay/system/priv-app/
	    fi	
	else
	    if [ ${CM_BASE} == "1" ];then
	        cp -rf third-app/ttotoo-app/LRSettings devices/$1/overlay/system/priv-app/
		cp -rf third-app/ttotoo-app/CMParts devices/$1/overlay/system/priv-app/
	    fi
	fi

	if [ ${SUPPORT_LITTLERABBIT} == "1" ];then
	    cp -rf third-app/ttotoo-app/MiGuard devices/$1/overlay/system/priv-app/
          if [ ${SUPPORT_OTA} == "1" ];then
             cp -rf third-app/ttotoo-app/FlymeUpdater devices/$1/overlay/system/priv-app/
          fi
	fi
	
	echo "<<< 添加推广完成！   "
}

function clean(){
	config $1
	cd ${source_dir}/devices/$1
	make clean
	rm -rf history_package last_target board
	mkdir -p ${target_dir} ${flyme_dir}

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
	mv out/flyme_*.zip ${flyme_dir}/
    echo 1 > ${flyme_dir}/donenow
    rm -rf overlay/system/priv-app
  	rm -rf overlay/data/app
}

function ota(){
	cd ${source_dir}
	mv ${source_dir}/devices/$1/out/target_fil*.zip ${target_dir}/$1-target-files.zip
        ./build/tools/releasetools/ota_from_target_files.py -k ./build/security/testkey -i ${target_dir}/$1-last-target-files.zip ${target_dir}/$1-target-files.zip ${flyme_dir}/ota-$1-${version}.zip
}

function build(){
	clean $1
        download $1
	third $1
	fullota $1
	if [ ${SUPPORT_OTA} == "1" ];then
		ota $1
	fi
        if [ -f "${flyme_dir}/donenow" ];then
		qshell $1
	fi
}

function download(){
	wget http://s-addons.ttotoo.com/$1-vendor.tar
	rm -rf $source_dir/devices/$1/vendor
	echo "tar xvf $1-vendor.tar -C $source_dir/devices/$1/"
	tar xvf $1-vendor.tar -C "$source_dir/devices/$1/"
	wget http://s-addons.ttotoo.com/$1-last-target-files.zip -O ${target_dir}
}

function qshell(){
        chmod a+x qshell
	./qshell account ${QINIU_AK} ${QINIU_SK}
        ./qshell delete ttotoo-addons-south $1-last-target-files.zip
        ./qshell rput ttotoo-addons-south $1-last-target-files.zip ${target_dir}/$1-target-files.zip
}

init
build $1

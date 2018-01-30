x=`date +%Y`
y=`date +.%-m.%-d`
z=${x: -1:1}
time=`date +%c`
utc=`date +%s`
build_date=`date +%Y%m%d`

THREAD=`sysctl hw.ncpu|cut -d" " -f2`

source_dir="/Volumes/sources/flyme7"
devices_dir="${source_dir}/devices"

if [ "$1" ]; then
	build $1
else
    for prj_dir in ${devices_dir}/*
    do
        if [[ ${prj_dir} != *.* ]]&&[[ ${prj_dir} != *base* ]]&&[[ ${prj_dir} != *pre* ]]&&[[ ${prj_dir} != *old_* ]];then
            temp_file=`basename ${prj_dir}`
            echo ${temp_file}
        fi
    done

    echo ""
    read no_compile
    clear

    for prj_dir in ${devices_dir}/*
    do
        if [[ ${prj_dir} != *.* ]]&&[[ ${prj_dir} != *base* ]]&&[[ ${prj_dir} != *pre* ]]&&[[ ${prj_dir} != *old_* ]];then
            temp_file=`basename ${prj_dir}`
            if [[ ${no_compile} != *${temp_file}* ]];then
                cd ${prj_dir}
								tar -cvf ${prj_dir}/../../${temp_file}-vendor.tar vendor
                pwd
            fi
        fi
    done
fi

cd ${source_dir}
ls *.tar

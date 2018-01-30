source_dir="/Volumes/sources/flyme7"
devices_dir="${source_dir}/devices"

for prj_dir in ${devices_dir}/*
do
    if [[ ${prj_dir} != *.* ]]&&[[ ${prj_dir} != *base* ]];then
        temp_file=`basename ${prj_dir}`
        cd ${devices_dir}/${temp_file}
        git remote remove oschina_source
        git remote add oschina_source git@gitee.com:imcsg/flyme_source_n.git

    fi
done

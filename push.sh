source_dir="/Volumes/sources/flyme7"
devices_dir="${source_dir}/devices"

function push() {
  cd ${devices_dir}/$1
  if [ $1 == "heroltexx" ];then
    BRANCH='nougat'
  else
    BRANCH='nougat-7.1'
  fi
  git push oschina_source ${BRANCH}:$1 -f
  git push github_source ${BRANCH}:$1 -f
}


push heroltexx
push nx531j_cm

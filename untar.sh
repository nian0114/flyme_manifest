user=`whoami`
source_dir="/home/$user/flyme7"

function untar() {
	echo "tar xvf $1-vendor.tar -C $source_dir/devices/$1/"
	tar xvf $1-vendor.tar -C "$source_dir/devices/$1/"
	#rm -rf  $1-vendor.tar
}

untar heroltexx
untar nx531j_cm
untar nx531j_nubia

sed -i -e "s/ro\.product\.model=.*/ro\.product\.model=SM-G9350/g" $source_dir/devices/heroltexx/vendor/system/build.prop
sed -i -e "s/ro\.product\.device=.*/ro\.product\.device=hero2qltechn/g" $source_dir/devices/heroltexx/vendor/system/build.prop

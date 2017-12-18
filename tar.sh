source_dir="~/flyme6"

function untar() {
	rm -rf $source_dir/devices/$1/vendor
	tar xvf $1-vendor.tar -C $source_dir/devices/$1/
	rm -rf  $1-vendor.tar
}

untar hero2qlte_free
untar hero2qlte
untar herolte_free
untar herolte
untar lithium
untar natrium
untar nx531j_cm
untar nx531j_nubia

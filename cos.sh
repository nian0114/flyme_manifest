wget https://github.com/tencentyun/cosfs/releases/download/v1.0.2/cosfs_1.0.2-ubuntu16.04_amd64.deb
dpkg -i cosfs_1.0.2-ubuntu16.04_amd64.deb

echo flyme6:AKIDLcnKj9hAzdBhH4qi8SyRL3Z9Ypzytant:3zjJhvxnR5nLhsskXCfx3ymbKwPgliTx > /etc/passwd-cosfs
chmod 640 /etc/passwd-cosfs
sudo mkdir /mnt/cos /local_cache_dir
sudo cosfs 1255331134:flyme6 /mnt/cos -ourl=http://cn-east.myqcloud.com -odbglevel=info -ouse_cache=/local_cache_dir

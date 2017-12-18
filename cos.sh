wget https://github.com/tencentyun/cosfs/releases/download/v1.0.2/cosfs_1.0.2-ubuntu16.04_amd64.deb
dpkg -i cosfs_1.0.2-ubuntu16.04_amd64.deb

echo flyme6:AKIDLcnKj9hAzdBhH4qi8SyRL3Z9Ypzytant:3zjJhvxnR5nLhsskXCfx3ymbKwPgliTx > /etc/passwd-cosfs
chmod 640 /etc/passwd-cosfs
mkdir /tmp/cosfs
cosfs 1255331134:flyme6 /tmp/cosfs -ourl=http://cn-east.myqcloud.com -odbglevel=info

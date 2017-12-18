sudo apt-get update
sudo apt-get install git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip openjdk-8-jdk
echo 'https://nian0114:admin12051@github.com
https://imcsg:admin12051@gitee.com' >  ~/.git-credentials
git config --global credential.helper store

mdkir -p flyme6
cd flyme6
repo init -u git@github.com:nian0114/flyme_manifest.git -b marshmallow-6.0
repo sync

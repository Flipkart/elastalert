#!/bin/bash

set -x -e

PACKAGE=elastalert
PACKAGE_ROOT="./elastalertz"
INIT_DIR="/etc/init.d"
echo $PACKAGE_ROOT

VERSION=$VERSION

ARCH=all

mkdir -p $PACKAGE_ROOT
mkdir -p $PACKAGE_ROOT/${INIT_DIR}
mkdir -p $PACKAGE_ROOT/DEBIAN
mkdir -p $PACKAGE_ROOT/etc/init

mkdir -p $PACKAGE_ROOT/usr/share/${PACKAGE}
mkdir -p $PACKAGE_ROOT/usr/share/${PACKAGE}/dist
mkdir -p $PACKAGE_ROOT/usr/share/${PACKAGE}/src
mkdir -p $PACKAGE_ROOT/usr/share/${PACKAGE}-env
mkdir -p $PACKAGE_ROOT/var/log/flipkart/$PACKAGE


cd DEBIAN
perl -p -i -e "s/Version.*/Version: $VERSION/ig" control
perl -p -i -e "s/Package.*/Package: $PACKAGE/ig" control
cp control ../$PACKAGE_ROOT/DEBIAN/control
cp preinst ../$PACKAGE_ROOT/DEBIAN/preinst
cp postinst ../$PACKAGE_ROOT/DEBIAN/postinst

cd ..
cp {config.yaml,requirements.txt,tox.ini,.pre-commit-config.yaml,.travis.yml,Makefile,setup.cfg,setup.py,supervisord.conf.example} $PACKAGE_ROOT/usr/share/${PACKAGE}/
cp -r {docs,elastalert,tests,elastalert.egg-info}/ $PACKAGE_ROOT/usr/share/${PACKAGE}/

cd init
for file in `ls *`
do
   cp $file ../${PACKAGE_ROOT}${INIT_DIR}/$PACKAGE
   chmod +x ../${PACKAGE_ROOT}${INIT_DIR}/$PACKAGE
done
cd -

cd $PACKAGE_ROOT/usr/share/
virtualenv ${PACKAGE}-env
. ${PACKAGE}-env/bin/activate
cd -
pip install -r requirements.txt


dpkg-deb -b $PACKAGE_ROOT
echo "Moving the package to ${PACKAGE}_${VERSION}_${ARCH}"
mv $PACKAGE_ROOT.deb ${PACKAGE}_${VERSION}_${ARCH}.deb

BASE_DIR=.
FILE=${PACKAGE}_${VERSION}_${ARCH}.deb
TEMP_DIR=/tmp/apt-repo
DEPLOYMENT_ENV=$DEPLOYMENT_ENV
echo $FILE
echo $DEPLOYMENT_ENV

if [ $DEPLOYMENT_ENV == 'LOCAL' ]; then
HOSTS="localhost"
elif [ $DEPLOYMENT_ENV == 'STAGING' ]; then
HOSTS="stage-wbuild1.ch.flipkart.com"
elif [ $DEPLOYMENT_ENV == 'PRODUCTION' ]; then
HOSTS=""
elif [ $DEPLOYMENT_ENV == 'MPIE' ]; then
HOSTS="mp-build1.ch.flipkart.com"
elif [ $DEPLOYMENT_ENV == 'MPIE2' ]; then
  HOSTS="mp2-build1.ch.flipkart.com"
elif [ $DEPLOYMENT_ENV == 'SB-CH']; then
  HOSTS="sb-ch-build1.ch.flipkart.com"
else
echo "Unkown environment specified!"
exit 255;
fi

if [ -f $BASE_DIR/$FILE ];
then
# Create the tmp dir
mkdir -p $TEMP_DIR

# Copy the file to temp dir and generate md5
cp $BASE_DIR/$FILE $TEMP_DIR/
rm $BASE_DIR/*.deb
rm -r $PACKAGE_ROOT/
cd $TEMP_DIR
BASE_FILE_NAME=`basename $FILE`

# Create an md5 file in current dir
openssl md5 $BASE_FILE_NAME | cut -f 2 -d " " > $BASE_FILE_NAME.md5

echo 'Upload starting for $FILE'
# Upload the file and md5


for HOST in $HOSTS
do
  echo "Uploading $FILE to $HOST"
ftp $HOST<<END_SCRIPT
  lcd $TEMP_DIR
  put $BASE_FILE_NAME
  put $BASE_FILE_NAME.md5
END_SCRIPT
  echo "Disconnected from ftp server - $HOST. Upload Complete for $FILE"
done
# Delete the md5 file and .deb file
#rm -f $TEMP_DIR/$BASE_FILE_NAME
#rm -f $TEMP_DIR/$BASE_FILE_NAME.md5
#else
#echo "File $BASE_DIR/$FILE does not exist."
#exit 255 #error exit code.
fi

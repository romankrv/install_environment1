#! /bin/bash
NAME_ENV=PROJ_NAME
PROJECT_FOLDER_ROOT=~/
PROJECT_NAME=assmt-web-app
SQLDEVELOPER=~/bin/sqldeveloper
MY_PROXY=" --proxy='http://proxy.softservecom.com:8080/' "
PROXY=""

if [! `type -t alien`]; then
    sudo aptitude install alien
fi

if [! `type -t aptitude`]; then
    sudo aptitude install aptitude
fi

if [! `type -t python-dev`]; then
    sudo aptitude install python-dev
fi

if [! `type -t ruby`]; then
    sudo aptitude install ruby ruby-full rdoc irb libyaml-ruby libzlib-ruby
    sudo aptitude install ri libopenssl-ruby ruby1.8-dev build-essential
fi

if [! `type -t gem`]; then
    wget http://production.cf.rubygems.org/rubygems/rubygems-1.5.2.tgz
    tar -zxf rubygems-1.5.2.tgz
    cd rubygems-1.5.2
    sudo ruby setup.rb
    sudo gem update --system
    sudo ln -s /usr/bin/gem1.8 /usr/bin/gem
fi

sudo pip install --upgrade virtualenvwrapper $MY_PROXY

if [ -d $HOME/VIRTUALENVS ]; then
    export WORKON_HOME=$HOME/VIRTUALENVS
else
    mkdir $HOME/VIRTUALENVS
    export WORKON_HOME=$HOME/VIRTUALENVS
    source /usr/local/bin/virtualenvwrapper.sh
fi

echo "install Oracle client ver == 10.2.0."
file="oracle-instantclient-devel-10.2.0.3-1.i386.rpm"
if [ -e $file ]; then
    sudo alien -i $file
else
    wget http://dl.dropbox.com/u/1155913/Oracle_tools/oracle-instantclient-devel-10.2.0.3-1.i386.rpm
    sudo alien -i $file
fi 

file="oracle-instantclient-basic-10.2.0.3-1.i386.rpm"
if [ -e $file ]; then
    sudo alien -i $file
else
    wget http://dl.dropbox.com/u/1155913/Oracle_tools/oracle-instantclient-basic-10.2.0.3-1.i386.rpm
    sudo alien -i $file
fi 

file="oracle-instantclient-sqlplus-10.2.0.3-1.i386.rpm"
if [ -e $file ]; then
    sudo alien -i $file
else
    wget http://dl.dropbox.com/u/1155913/Oracle_tools/oracle-instantclient-sqlplus-10.2.0.3-1.i386.rpm
    sudo alien -i $file
fi

echo -e "\n#Oracle configuration " >> ~/.profile 
echo export ORACLE_HOME=/usr/lib/oracle/10.2.0.3/client >> ~/.bashrc
echo export PATH=$ORACLE_HOME/bin:$PATH >> ~/.bashrc
echo export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH >> ~/.bashrc
echo export TNS_ADMIN=~/oracle_conf >> ~/.bashrc
source ~/.bashrc
sudo ln -sf $ORACLE_HOME/lib/libclntsh.so.10.1 $ORACLE_HOME/lib/liblclntsh.so
sudo ln -sf $ORACLE_HOME/lib/libocci.so.10.1 $ORACLE_HOME/lib/libocci.so

if [-d $SQLDEVELOPER ]; then
    echo ""
else
    file="sqldeveloper.tar"
    if [-e $file ]; then
	if [ -d sqldeveloper ]; then
            echo ""
	else
            tar -xf $file
	fi 
    else
	wget http://dl.dropbox.com/u/1155913/Oracle_tools/sqldeveloper.tar
	tar -xf $file
    fi
fi

if [-e $SQLDEVELOPER ]; then
    echo ""
else
    cp -a sqldeveloper $SQLDEVELOPER

echo alias sqldeveloper=$SQLDEVELOPER"sqldeveloper/sqldeveloper.sh" >> ~/.bachrc
echo export LANG="ru_RU.utf8" >> ~/.bachrc
#echo export LIBRARY_PATH=$ORACLE_HOME/lib >> ~/.bachrc # if you have error try open this
#echo export CPATH=$ORACLE_HOME/sdk/include >> ~/.bachrc # if you have error try open this
echo workon $NAME_ENV >> ~/.bashrc
echo cd $PROJECT_FOLDER_ROOT$PROJECT_NAME  >> ~/.bashrc

mkvirtualenv $NAME_ENV && workon $NAME_ENV
cd $PROJECT_FOLDER_ROOT
git clone git@dmc120.mc.wgenhq.net:mclass/assmt-web-app $PROJECT_NAME
cd $PROJECT_NAME
pip install --upgrade -r requirements.txt
sudo pon wgen && echo "Press RET key for 5-10 sec" && read
pip install --upgrade -r requirements.txt
pip install -e git://dmc120.mc.wgenhq.net/mclass/mclass-python-common#egg=mclass-python-common
pip install -e git://dmc120.mc.wgenhq.net/wgen/python-repoze.who-plugins#egg=python-repoze.who-plugins
sudo poff wgen

cp -a oracle_conf ~

source ~/.bashrc

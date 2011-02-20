#! /bin/bash
NAME_ENV=PR1
PROJECT_FOLDER_ROOT=~/
PROJECT_NAME=assmt-web-app
SQLDEVELOPER=~/bin/sqldeveloper
FolderVirtualenvWrapper=~/VIRTUALENVS

if [ ! `type -t alien` ]; then
    sudo aptitude install alien
fi

if [ ! `type -t aptitude` ]; then
    sudo apt-get install aptitude
fi

sudo aptitude install python-dev
sudo pip install virtualenvwrapper

file="pip-0.8.2.tar.gz"
if [ ! `type -t pip` ]; then
    wget http://pypi.python.org/packages/source/p/pip/$file
    tar -xf $file 
    cd pip-0.8.2
    sudo python setup.py install
    cd .. && rm $file
fi

if [ ! `type -t ruby` ]; then
    sudo aptitude install ruby ruby-full rdoc irb libyaml-ruby libzlib-ruby
    sudo aptitude install ri libopenssl-ruby ruby1.8-dev build-essential
fi

if [ ! `type -t gem` ]; then
    wget http://production.cf.rubygems.org/rubygems/rubygems-1.5.2.tgz
    tar -zxf rubygems-1.5.2.tgz
    cd rubygems-1.5.2
    sudo ruby setup.rb
    sudo gem update --system
    sudo ln -s /usr/bin/gem1.8 /usr/bin/gem
fi

sudo pip install virtualenvwrapper

if [ -d $FolderVirtualenvWrapper ]; then
    export WORKON_HOME=$FolderVirtualenvWrapper
else
    mkdir $FolderVirtualenvWrapper
    export WORKON_HOME=$FolderVirtualenvWrapper
    source /usr/local/bin/virtualenvwrapper.sh
fi

file="oracle-instantclient-devel-10.2.0.3-1.i386.rpm"
txt=`dpkg -L oracle-instantclient-devel | grep oracle/10.2.0.3/client/cdemo81.c`
if [ -z txt ]; then
    if [ -e $file ]; then
	sudo alien -i $file
    else
        wget http://dl.dropbox.com/u/1155913/Oracle_tools/oracle-instantclient-devel-10.2.0.3-1.i386.rpm
	sudo alien -i $file
    fi
fi

file="oracle-instantclient-basic-10.2.0.3-1.i386.rpm"
txt=`dpkg -L oracle-instantclient-basic | grep oracle/10.2.0.3/client/bin/genezi`
if [ -z txt ]; then
    if [ -e $file ]; then
	sudo alien -i $file
    else
	wget http://dl.dropbox.com/u/1155913/Oracle_tools/oracle-instantclient-basic-10.2.0.3-1.i386.rpm
	sudo alien -i $file
    fi
fi

file="oracle-instantclient-sqlplus-10.2.0.3-1.i386.rpm"
txt=`dpkg -L oracle-instantclient-sqlplus | grep oracle/10.2.0.3/client/lib/glogin.sql`
if [ -z txt ]; then
    if [ -e $file ]; then
	sudo alien -i $file
    else
	wget http://dl.dropbox.com/u/1155913/Oracle_tools/$file
	sudo alien -i $file
    fi
fi

sudo ln -sf $ORACLE_HOME/lib/libclntsh.so.10.1 $ORACLE_HOME/lib/liblclntsh.so
sudo ln -sf $ORACLE_HOME/lib/libocci.so.10.1 $ORACLE_HOME/lib/libocci.so


echo -e "\n#Oracle configuration " >> ~/.bashrc 
echo export ORACLE_HOME=/usr/lib/oracle/10.2.0.3/client >> ~/.bashrc
echo export PATH=$ORACLE_HOME/bin:$PATH >> ~/.bashrc
echo export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH >> ~/.bashrc
echo export TNS_ADMIN=~/oracle_conf >> ~/.bashrc
echo alias sqldeveloper=$SQLDEVELOPER"sqldeveloper/sqldeveloper.sh" >> ~/.bachrc
echo export LANG="ru_RU.utf8" >> ~/.bachrc
echo workon $NAME_ENV >> ~/.bashrc
echo cd $PROJECT_FOLDER_ROOT$PROJECT_NAME >> ~/.bashrc

source ~/.bashrc

if [ -d $SQLDEVELOPER ]; then
    echo ""
else
    file="sqldeveloper.tar"
    if [ -e $file ]; then
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

if [ -e $SQLDEVELOPER ]; then
    echo ""
else
    cp -a sqldeveloper $SQLDEVELOPER
fi


if [ ! -d ~/oracle_conf ]; then
    wget http://dl.dropbox.com/u/1155913/Oracle_tools/oracle_conf.tar.gz
    tar -zxf oracle_conf.tar.gz
    cp -a oracle_conf ~
fi

#echo export LIBRARY_PATH=$ORACLE_HOME/lib >> ~/.bachrc # if you have error try open this
#echo export CPATH=$ORACLE_HOME/sdk/include >>~/.bachrc # if you have error try open this

echo "CREATE VIRTUAL ENVIRONMENT..."
sudo pip install -r requirements.txt
cd $FolderVirtualenvWrapper
virtualenv $NAME_ENV
source $NAME_ENV/bin/activate

echo "Install NAPI requirement"
sudo easy_install assess/lib/wgen.httpconn-development-py2.6.egg
sudo easy_install assess/lib/napiclient-development-py2.6.egg

if [ ! -d $PROJECT_FOLDER_ROOT/$PROJECT_NAME ]; then
    cd $PROJECT_FOLDER_ROOT
    git clone git@mcgit.mc.wgenhq.net:mclass/assmt-web-app $PROJECT_NAME
    cd $PROJECT_FOLDER_ROOT/$PROJECT_NAME
    sudo pip install -r requirements.txt
else
    cd $PROJECT_FOLDER_ROOT/$PROJECT_NAME
    git pull
    sudo pip install -r requirements.txt
fi

source ~/.profile
source ~/.bashrc

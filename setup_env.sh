#! /bin/bash
echo -e "Please checkout that WGEN-VPN is work after it press RETURN-key"
read
NAME_ENV=ASSESS
PROJECT_ROOT=~/
PROJECT_NAME=assmt-web-app
SQLDEVELOPER=~/bin/sqldeveloper
FolderVirt=~/VIRTUALENVS

type -t alien >/dev/null || sudo aptitude install -y alien
type -t aptitude >/dev/null || sudo apt-get install -y aptitude
type -t git >/dev/null || sudo aptitude install -y git gitk git-gui
type -t ruby >/dev/null || sudo aptitude install -y ruby-full libyaml-ruby libzlib-ruby libopenssl-ruby
type -t apache2 >/dev/null || sudo aptitude install -y apache2
type -t libapache2-mod-wsgi >/dev/null || sudo aptitude install -y libapache2-mod-wsgi
type -P python-config >/dev/null || sudo aptitude install -y python-dev
type -P certutil >/dev/null || sudo aptitude install -y libnss3-tools

# build-essential installing
if [ -z `ls /usr/share | grep build-essential` ]; then
	sudo aptitude install -y build-essential
fi

sudo a2enmod proxy
sudo a2enmod proxy_http

file="pip-1.3.1.tar.gz"
if [ ! `type -t pip` ]; then
    wget http://pypi.python.org/packages/source/p/pip/$file
    tar -xf $file
    cd pip-1.3.1
    sudo python setup.py install
    sudo pip install --upgrade
    cd .. && rm $file
fi
sudo pip install virtualenvwrapper

if [ ! `type -t gem` ]; then
    wget http://production.cf.rubygems.org/rubygems/rubygems-2.0.3.tgz
    tar -zxf rubygems-2.0.3.tgz
    cd rubygems-2.0.3
    sudo ruby setup.rb
    sudo gem update --system
    sudo ln -s /usr/bin/gem1.8 /usr/bin/gem
fi

# haml installing
if [[ -z `gem list | grep haml` ]]; then
    sudo gem install haml
fi

file="oracle-instantclient-devel-10.2.0.3-1.i386.rpm"
wget http://dl.dropbox.com/u/1155913/Oracle_tools/$file
sudo alien -i $file

file="oracle-instantclient-basic-10.2.0.3-1.i386.rpm"
wget http://dl.dropbox.com/u/1155913/Oracle_tools/$file
sudo alien -i $file

file="oracle-instantclient-sqlplus-10.2.0.3-1.i386.rpm"
wget http://dl.dropbox.com/u/1155913/Oracle_tools/$file
sudo alien -i $file

sudo ln -sf $ORACLE_HOME/lib/libclntsh.so.10.1 $ORACLE_HOME/lib/liblclntsh.so
sudo ln -sf $ORACLE_HOME/lib/libocci.so.10.1 $ORACLE_HOME/lib/libocci.so

echo -e "\n#Oracle configuration " >> ~/.bashrc 
echo export ORACLE_HOME=/usr/lib/oracle/10.2.0.3/client >> ~/.bashrc
echo export PATH=$ORACLE_HOME/bin:$PATH >> ~/.bashrc
echo export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH >> ~/.bashrc
echo export TNS_ADMIN=~/oracle_conf >> ~/.bashrc
echo alias sqldeveloper=$SQLDEVELOPER"sqldeveloper/sqldeveloper.sh" >> ~/.bachrc
echo export ASSESS_HOME=$PROJECT_ROOT$PROJECT_NAME >> ~/.bashrc
echo export LANG="ru_RU.utf8" >> ~/.bachrc
echo workon $NAME_ENV >> ~/.bashrc
echo cd $PROJECT_ROOT$PROJECT_NAME >> ~/.bashrc

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

# virtualenvwrapper prepare environment
export WORKON_HOME=$FolderVirt
if [ ! -d $FolderVirt ]; then
    mkdir $FolderVirt
    source /usr/local/bin/virtualenvwrapper.sh
fi

# cloning project
if [ ! -d $PROJECT_ROOT/$PROJECT_NAME ]; then
    cd $PROJECT_ROOT
    git clone git@mcgit.mc.wgenhq.net:mclass/assmt-web-app $PROJECT_NAME
    echo "Fix requirement.txt"
    read
else
    cd $PROJECT_ROOT/$PROJECT_NAME
    git pull
fi

# create virtual environment
if [ ! -d $FolderVirt/$NAME_ENV ]; then
    echo "CREATE VIRTUAL ENVIRONMENT ..."
    virtualenv $FolderVirt/$NAME_ENV
    source $FolderVirt/$NAME_ENV/bin/activate
    cd $PROJECT_ROOT/$PROJECT_NAME
    rake setup:nsscert
    echo "Install NAPI requirement..."
    easy_install assess/lib/wgen.httpconn-development-py2.6.egg
    easy_install assess/lib/napiclient-development-py2.6.egg
    pip install -r requirements.txt
    sudo mkdir -p /opt/wgen/log/assess/
    sudo chown -R -L $USER /opt/wgen/log/assess
    export ASSESS_HOME=PROJECT_ROOT/$PROJECT_NAME
else
    echo "UPDATE VIRTUAL ENVIRONMENT via pip install -r [file] ..."
fi

#source ~/.profile
#source ~/.bashrc

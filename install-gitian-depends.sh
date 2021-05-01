#!/usr/bin/env bash

#ENV VARS
OS=$(uname)
OS_VERSION=$(uname -r)
UNAME_M=$(uname -m)
ARCH=$(uname -m)
export OS
export OS_VERSION
export UNAME_M
export ARCH

report() {
if hash mawk 2>/dev/null; then
    AWK=mawk
    export $AWK
fi

echo $OS
echo "$OS" | $AWK '{print tolower($0)}' && echo
echo OS_VERSION:
echo "$OS_VERSION" | $AWK '{print tolower($0)}' && echo
echo UNAME_M:
echo "$UNAME_M" | $AWK '{print tolower($0)}' && echo
echo ARCH:
echo "$ARCH" | $AWK '{print tolower($0)}' && echo
echo OSTYPE:
echo "$OSTYPE" | $AWK '{print tolower($0)}' && echo
echo
echo "\n----------------------------------end report-------------------------------"
}

checkbrew() {

    if hash brew 2>/dev/null; then
        echo brew installed
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        checkbrew
    fi
}
#checkraspi(){
#
#    echo 'Checking Raspi'
#    if [ -e /etc/rpi-issue ]; then
#    echo "- Original Installation"
#    cat /etc/rpi-issue
#    fi
#    if [ -e /usr/bin/lsb_release ]; then
#    echo "- Current OS"
#    lsb_release -irdc
#    fi
#    echo "- Kernel"
#    uname -r
#    echo "- Model"
#    cat /proc/device-tree/model && echo
#    echo "- hostname"
#    hostname
#    echo "- Firmware"
#    /opt/vc/bin/vcgencmd version
#}
if [[ "$OSTYPE" == "linux"* ]]; then
    #CHECK APT
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        if hash apt 2>/dev/null; then
            INSTALL='apt install'
            export INSTALL
            report
            echo 'Using apt...'
            $INSTALL $AWK
            #$INSTALL git apache2 apt-cacher-ng python-vm-builder ruby qemu-utils coreutils
            $INSTALL git apache2 apt-cacher-ng ruby qemu-utils coreutils
        fi
    fi
    if [[ "$OSTYPE" == "linux-musl" ]]; then
    INSTALL=apk add
    export INSTALL
        if hash apk 2>/dev/null; then
            $INSTALL awk
            report
            echo 'Using apk...'
        fi
    fi
    if [[ "$OSTYPE" == "linux-arm"* ]]; then
    INSTALL=apt install
    export INSTALL
    checkraspi
        if hash apt 2>/dev/null; then
            apt install awk
            report
            echo 'Using apt...'
        fi
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    INSTALL=brew install
    export INSTALL
    checkbrew
    if [ ! hash sha256sum 2>/dev/null ]; then
        echo sha256sum
        $INSTALL coreutils
        ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum
    else
        which sha256sum
    fi
    if [ ! hash awk 2>/dev/null ]; then
        brew install awk
    else
        which awk
    fi
    if [ ! hash git 2>/dev/null ]; then
        brew install git
    else
        which git
    fi
    if [ ! hash tar 2>/dev/null ]; then
        brew install tar
    else
        which tar
    fi
    if [ ! hash asciidoc 2>/dev/null ]; then
        brew install asciidoc
    else
        which asciidoc
    fi
    if [ ! hash doxygen 2>/dev/null ]; then
        brew install doxygen
    else
        which doxygen
    fi
    if [ ! hash graphviz 2>/dev/null ]; then
        brew install graphviz
    else
        which graphviz
    fi
    if [ ! hash ruby 2>/dev/null ]; then
        brew install ruby brew-gem
        #brew install ruby@2.6
        #brew install brew-gem
        #echo 'export PATH="/usr/local/opt/ruby@2.6/bin:$PATH"' >> ~/.bash_profile
        #brew unlink ruby@2.4
        #brew unlink ruby@2.5
        #brew unlink ruby@2.6
        #brew unlink ruby@2.7
        #brew link --force  ruby@2.6
        which ruby
        which gem
    else
        which ruby
    fi
    ###if [ ! hash x86-64-w64-mingw32-gcc 2>/dev/null ]; then
    ##    brew tap coso0920/minw_w64
    ##    brew install cosmo0920/mingw_w64/x86-64-w64-mingw32-binutils
    ##    brew install cosmo0920/mingw_w64/x86-64-w64-mingw32-gcc
    ##    brew install cosmo0920/mingw_w64/i686-w64-mingw32-binutils
    ##    brew install cosmo0920/mingw_w64/i686-w64-mingw32-gcc
    ###fi
    if [ ! hash docker 2>/dev/null ]; then
        brew cask install docker && brew link docker
    fi
    if [ ! hash nmap 2>/dev/null ]; then
        brew cask install nmap
        nmap -p 3142 localhost
    fi
elif [[ "$OSTYPE" == "cygwin" ]]; then
    echo TODO add support for $OSTYPE
elif [[ "$OSTYPE" == "msys" ]]; then
    echo TODO add support for $OSTYPE
elif [[ "$OSTYPE" == "win32" ]]; then
    echo TODO add support for $OSTYPE
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    echo TODO add support for $OSTYPE
else
    echo TODO add support for $OSTYPE
fi
install-macports(){

    MOJAVE=$(sw_vers -productVersion | awk '/10.14/'|awk ' {print $1}' | awk 'NR==1')
    if [[ "$MOJAVE" != "" ]]; then
        echo $MOJAVE
    fi
    CATALINA=$(sw_vers -productVersion | awk '/10.15/'|awk ' {print $1}' | awk 'NR==1')
    if [[ "$CATALINA" != "" ]]; then
        echo $CATALINA
    fi
    BIGSUR=$(sw_vers -productVersion | awk '/10.15/'|awk ' {print $1}' | awk 'NR==1')
    if [[ "$BIGSUR" != "" ]]; then
        echo $BIGSUR
    fi


}
if [[ "$OSTYPE" == "darwin"* ]]; then
install-macports
fi

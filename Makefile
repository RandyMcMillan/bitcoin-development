#REF: https://github.com/fanquake/core-review/blob/master/gitian-building/README.md
# PROJECT_NAME defaults to name of the current directory.
PROJECT_NAME							:= $(notdir $(PWD))
export PROJECT_NAME

ifeq ($(builddir),)
BUILDDIR								:= gitian-building
else
BUILDDIR								:= $(builddir)
endif
export BUILDDIR

#GIT CONFIG
GITHUB_USER_NAME						:= $(shell git config user.name)
export GIT_USER_NAME
GIT_USER_EMAIL							:= $(shell git config user.email)
export GIT_USER_EMAIL
GIT_SERVER								:= https://github.com
export GIT_SERVER
GIT_PROFILE								:= bitcoincore-dev
export GIT_PROFILE
GIT_BRANCH								:= $(shell git rev-parse --abbrev-ref HEAD)
export GIT_BRANCH
GIT_HASH								:= $(shell git rev-parse HEAD)
export GIT_HASH
GIT_REPO_ORIGIN							:= $(shell git remote get-url origin)
export GIT_REPO_ORIGIN
GIT_REPO_NAME							:= $(PROJECT_NAME)
export GIT_REPO_NAME
GIT_REPO_PATH							:= ~/$(GIT_REPO_NAME)
export GIT_REPO_PATH
ifeq ($(clone-depth),)
GIT_CLONE_DEPTH								:= 10
else
GIT_CLONE_DEPTH								:= $(git-clone-depth)
endif
export NO_CACHE
ifeq ($(no-cache),true)
NO_CACHE								:= --no-cache
else
NO_CACHE								:=
endif
export NO_CACHE

ifeq ($(verbose),true)
VERBOSE									:= --verbose
else
VERBOSE									:=
endif
export VERBOSE

OS										:=$(shell uname)
export OS
OS_VERSION								:=$(shell uname -r)
export OS_VERSION
ARCH									:=$(shell uname -m)
export ARCH

ifneq ($(docker),true)
USE_DOCKER:=0
else
USE_DOCKER:=1
endif
export USE_DOCKER

.PHONY: help
help: report
	@echo ''
	@echo '	[USAGE]:	make [BUILD] run [EXTRA_ARGUMENTS]	'
	@echo ''
	@echo ''
	@echo '		            	TODO'
	@echo ''

.PHONY: report
report:
	@echo ''
	@echo '	[ARGUMENTS]	'
	@echo '      args:'
	@echo '        - PWD=${PWD}'
	@echo '        - PROJECT_NAME=${PROJECT_NAME}'
	@echo '        - BUILDDIR=${BUILDDIR}'
	@echo '        - GITHUB_USER_NAME=${GITHUB_USER_NAME}'
	@echo '        - GIT_USER_EMAIL=${GIT_USER_EMAIL}'
	@echo '        - GIT_SERVER=${GIT_SERVER}'
	@echo '        - GIT_PROFILE=${GIT_PROFILE}'
	@echo '        - GIT_BRANCH=${GIT_BRANCH}'
	@echo '        - GIT_HASH=${GIT_HASH}'
	@echo '        - GIT_REPO_ORIGIN=${GIT_REPO_ORIGIN}'
	@echo '        - GIT_REPO_NAME=${GIT_REPO_NAME}'
	@echo '        - GIT_REPO_PATH=${GIT_REPO_PATH}'
	@echo '        - GIT_CLONE_DEPTH=${GIT_CLONE_DEPTH}'
	@echo '        - OS=${OS}'
	@echo '        - OS_VERSION=${OS_VERSION}'
	@echo '        - ARCH=${ARCH}'
	@echo '        - USE_DOCKER=${USE_DOCKER}'

.PHONY: all
.ONESHELL:
all: init install-gitian-depends depends

.PHONY: install-gitian-depends
.ONESHELL:
install-gitian-depends:
ifneq ($(shell id -u),0)
	echo "not root"
	sudo make install-gitian-depends
endif
	sudo ./install-gitian-depends.sh

.PHONY: init
.ONESHELL:
init:
	@echo "init start"
	@echo ${PWD}
	@echo ${PWD}/${BUILDDIR}
#ifneq ($(shell id -u),0)
#	echo "not root"
#	sudo make init
#endif

	echo 0
	$(shell [ ! -d '${PWD}/${BUILDDIR}' ]										&& mkdir -p ${PWD}/${BUILDDIR})
	echo 1
	$(shell [ ! -d '${PWD}/${BUILDDIR}/gitian.sigs' ]							&& git clone --depth ${GIT_CLONE_DEPTH} git@github.com:${GITHUB_USER_NAME}/gitian.sigs.git ${PWD}/${BUILDDIR}/gitian.sigs)
	echo 2
	$(shell [ ! -d '${PWD}/${BUILDDIR}/bitcoin' ]								&& git clone --depth ${GIT_CLONE_DEPTH} https://github.com/bitcoin/bitcoin.git ${PWD}/${BUILDDIR}/bitcoin)
	echo 3
	$(shell [ ! -d '${PWD}/${BUILDDIR}/gitian-builder' ]						&& git clone --depth ${GIT_CLONE_DEPTH} https://github.com/devrandom/gitian-builder.git ${PWD}/${BUILDDIR}/gitian-builder)
	echo 4
	$(shell [ ! -d '${PWD}/${BUILDDIR}/bitcoin-detached-sigs' ]					&& git clone --depth ${GIT_CLONE_DEPTH} https://github.com/bitcoin-core/bitcoin-detached-sigs.git ${PWD}/${BUILDDIR}/bitcoin-detached-sigs)
	echo 5

.PHONY: depends
.ONESHELL:
depends: report

#ifneq ($(shell id -u),0)
#	echo "not root"
#	sudo make depends
#endif

	echo 0
	cd ${PWD}/${BUILDDIR}/gitian-builder && make -C ../bitcoin/depends download SOURCES_PATH=${PWD}/cache/common
	echo 1
	cd ${PWD}/${BUILDDIR}/gitian-builder && mkdir -p ${PWD}/${BUILDDIR}/gitian-builder/inputs && wget -P ${PWD}/${BUILDDIR}/gitian-builder/inputs https://bitcoincore.org/cfields/osslsigncode-Backports-to-1.7.1.patch
	echo 2
	cd ${PWD}/${BUILDDIR}/gitian-builder && mkdir -p ${PWD}/${BUILDDIR}/gitian-builder/inputs && wget -O inputs/osslsigncode-2.0.tar.gz https://github.com/mtrojnar/osslsigncode/archive/2.0.tar.gz
	echo 3
	cd ${PWD}/${BUILDDIR}/gitian-builder && mkdir -p ${PWD}/${BUILDDIR}/gitian-builder/inputs && wget -P ${PWD}/${BUILDDIR}/gitian-builder/inputs https://github.com/bitcoin/bitcoin/files/6175295/osslsigncode-1.7.1.tar.gz
	echo 4
	cd ${PWD}/${BUILDDIR}/gitian-builder && mkdir -p ${PWD}/${BUILDDIR}/gitian-builder/inputs && [ ! -d '${PWD}/${BUILDDIR}/gitian-builder/inputs/MacOSX10.14.sdk.tar.gz' ] && wget -P ${PWD}/${BUILDDIR}/gitian-builder/inputs  https://bitcoincore.org/depends-sources/sdks/MacOSX10.14.sdk.tar.gz
	echo 5
	cd ${PWD}/${BUILDDIR}/gitian-builder && mkdir -p ${PWD}/${BUILDDIR}/gitian-builder/inputs && [ ! -d '${PWD}/${BUILDDIR}/gitian-builder/inputs/MacOSX10.11.sdk.tar.gz' ] && wget -P ${PWD}/${BUILDDIR}/gitian-builder/inputs  https://bitcoincore.org/depends-sources/sdks/MacOSX10.11.sdk.tar.gz
	echo 6
	cd ${PWD}/${BUILDDIR}/gitian-builder && mkdir -p ${PWD}/${BUILDDIR}/gitian-builder/inputs && wget -P ${PWD}/${BUILDDIR}/gitian-builder/inputs https://github.com/bitcoin/bitcoin/files/6175295/osslsigncode-1.7.1.tar.gz
	echo 7
	$(shell sudo ufw allow 3142/tcp && ufw reload)
	echo 8
	cd ${PWD}/${BUILDDIR}/gitian-builder && git pull && bin/make-base-vm --suite bionic --arch amd64 --docker
	echo 9
	cd ${PWD}/${BUILDDIR}/gitian-builder && wget -P ${PWD}/${BUILDDIR}/gitian-builder/inputs https://bitcoincore.org/cfields/osslsigncode-Backports-to-1.7.1.patch
	echo 10
	cd ${PWD}/${BUILDDIR}/gitian-builder && wget -P ${PWD}/${BUILDDIR}/gitian-builder/inputs https://github.com/mtrojnar/osslsigncode/archive/2.0.tar.gz)
	echo 11
	cd ${PWD}/${BUILDDIR}/gitian-builder && wget -P ${PWD}/${BUILDDIR}/gitian-builder/inputs https://github.com/bitcoin/bitcoin/files/6175295/osslsigncode-1.7.1.tar.gz)
	echo 12
	cd ${PWD}/${BUILDDIR}/gitian-builder && wget -P ${PWD}/${BUILDDIR}/gitian-builder/inputs https://bitcoincore.org/depends-sources/sdks/Xcode-11.3.1-11C505-extracted-SDK-with-libcxx-headers.tar.gz)
	echo 13

.PHONY: macports-mojave
macports-mojave:
	curl -O https://distfiles.macports.org/MacPorts/MacPorts-2.6.4-10.14-Mojave.pkg
	open MacPorts-2.6.4-10.14-Mojave.pkg
.PHONY: macports-catalina
macports-catalina:
	curl -O https://distfiles.macports.org/MacPorts/MacPorts-2.6.4-10.15-Catalina.pkg
	open MacPorts-2.6.4-10.15-Catalina.pkg
.PHONY: macports-bigsur
macports-bigsur:
	curl -O https://distfiles.macports.org/MacPorts/MacPorts-2.6.4_1-11-BigSur.pkg
	open MacPorts-2.6.4_1-11-BigSur.pkg


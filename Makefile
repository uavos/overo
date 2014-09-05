###########################################################################
#
# OpenEmbedded Overo makefile support
#
###########################################################################
all: image

image: overo-ap-image

kernel: virtual/kernel

kernel-rebuild: 
	@echo "Removing temporary sources..."
	@rm -Rf $(OE_PATH)/sources/git_*
	@echo "update git.."
	@cd $(OE_PATH)/sources/git/www.sakoman.com.git.linux-omap-2.6.git ;\
	git fetch origin
	@make -- "-c clean virtual/kernel"
	@make -- "virtual/kernel"

kernel-config: 
	@make -- "-c menuconfig virtual/kernel"

install: install-scripts install-oe install-tools

.PHONY: install image all kernel kernel-rebuild kernel-config
#---------------------------
# OpenEmbedded
OE_PATH    := $(HOME)/Projects/overo-oe
USERBRANCH := user.collection
OEBRANCH   := org.openembedded.dev


#---------------------------
# scripts to install by default
SCRIPTS = gumnet guminstall
SCRIPTS_PATH = extras
BINDIR  = $(HOME)/bin


#---------------------------
# MicroSD card
MPATH       = $(CURDIR)/mnt
MPATH_BOOT  = $(MPATH)/boot
MPATH_ROOT  = $(MPATH)/rootfs

FEED_PATH  = feeds

FEED_URL    = http://cumulus.gumstix.org/images/angstrom/factory/2011-03-25-1619/
FEED_BOOT   = MLO u-boot.bin uImage
FEED_ROOTFS = omap3-desktop-nand-image-overo-booted.tar.bz2

FEED_FILES = $(FEED_BOOT) $(FEED_ROOTFS)
FEED_SRCS = $(FEED_FILES:%=$(FEED_PATH)/%)

DSCR_PATH = install-scripts-mmc
DEPLOY_PATH  = $(OE_PATH)/tmp/deploy/glibc/images/overo
DEPLOY_FILES = u-boot-overo.bin uImage-overo.bin overo-ap-image-overo.tar.bz2
DEPLOY_SRCS  = $(DEPLOY_FILES:%=$(DEPLOY_PATH)/%)

COPY_PATH = images
COPY_SRCS = $(DEPLOY_FILES:%=$(COPY_PATH)/%)

# guess card drive
ifneq ($(filter card%,$(MAKECMDGOALS)),)
ifeq ($(CARD_DEV),)
CARD_DEV := $(shell [ -e /dev/mmcblk0 ] && echo "/dev/mmcblk0")
endif
ifeq ($(CARD_DEV),)
CARD_DEV := $(shell [ -e /dev/mmcblk1 ] && echo "/dev/mmcblk1")
endif
ifeq ($(CARD_DEV),)
CARD_DEV := $(shell [ -e /dev/sde ] && echo "/dev/sde")
endif
ifeq ($(CARD_DEV),)
CARD_DEV := $(shell [ -e /dev/sdb ] && echo "/dev/sdb")
endif

CARD_DEV := $(shell \
	read -p "Card drive to use [default $(CARD_DEV)]: ";\
	[ -z "$$REPLY" ] && REPLY="$(CARD_DEV)"; \
	[ -e "$$REPLY" ] && echo $$REPLY)
ifeq ($(CARD_DEV),)
$(error "Card not found.")
endif
ifeq ($(CARD_SEP),)
CARD_SEP := $(shell DRIVE=$(CARD_DEV); DRIVE_T=$${DRIVE:(-1)}; [ $$DRIVE_T -eq $$DRIVE_T 2>/dev/null ] && echo "p")
endif
CARD_BOOT := $(CARD_DEV)$(CARD_SEP)1
CARD_ROOT := $(CARD_DEV)$(CARD_SEP)2
endif


#---------------------------
card-mount: card-dev
	@mkdir -p $(MPATH_BOOT) $(MPATH_ROOT) ;\
	sudo mount $(CARD_BOOT) $(MPATH_BOOT) ;\
	sudo mount $(CARD_ROOT) $(MPATH_ROOT) ;\
	mount|grep $(CARD_DEV)
	@echo "Drive mounted."

card-unmount: card-dev
	@echo "Unmounting drive, please wait..."
	@sync
	@sudo umount $(CARD_BOOT) 2>/dev/null
	@sudo umount $(CARD_ROOT) 2>/dev/null
	@rm -Rf $(MPATH) ;\
	echo "Drive unmounted."

card-format: card-dev
	$(if $(shell mount|grep $(CARD_DEV)),$(error "Card mounted."), )
	$(info WARNING: This will destroy all data on your card.)
	$(if $(shell read -p "Are you sure you want to continue (y/n)? "; [ "$$REPLY" == "y" ] && echo "ok"), ,$(error "Cancelled."))
	@sudo dd if=/dev/zero of=$(CARD_DEV) bs=1024 count=1024
	@SIZE=`sudo fdisk -l $(CARD_DEV) | grep Disk | awk '{print $$5}'` ;\
	CYLINDERS=`echo $$SIZE/255/63/512 | bc` ;\
	echo DISK SIZE – $$SIZE bytes ;\
	echo CYLINDERS – $$CYLINDERS ;\
	echo -e ",5,0x0C,*\n,,,-" | sudo sfdisk -D -H 255 -S 63 -C $$CYLINDERS $(CARD_DEV)
	@sudo mkfs.vfat -F 32 -n boot $(CARD_BOOT)
	@sudo mke2fs -j -L rootfs $(CARD_ROOT)
	@echo "MicroSD card formatted."

card-dev:
	@echo "Using drive $(CARD_DEV)"

card-do_update: $(DEPLOY_SRCS)
	@echo "Update user files..."
	@install -Cvt $(MPATH_ROOT)/home/root $(DSCR_PATH)/*
	@install -Cvt $(MPATH_ROOT)/home/root $(DEPLOY_SRCS)
	@mkdir -p $(MPATH_ROOT)/home/root/arm7
	@install -Cvt $(MPATH_ROOT)/home/root/arm7 ../shiva/bin/arm7/shiva
	@install -Cvt $(MPATH_ROOT)/home/root/arm7 ../nodes/bin/arm7/*

card-do_copy: $(COPY_SRCS)
	@echo "Copy user files..."
	@install -Cvt $(MPATH_ROOT)/home/root $(DSCR_PATH)/*
	@install -Cvt $(MPATH_ROOT)/home/root $(COPY_SRCS)
	@mkdir -p $(MPATH_ROOT)/home/root/arm7
	@install -Cvt $(MPATH_ROOT)/home/root/arm7 ../shiva/bin/arm7/shiva
	@install -Cvt $(MPATH_ROOT)/home/root/arm7 ../nodes/bin/arm7/*

card-do_init:
	@echo "Installing boot files..."
	@sudo rm -Rf $(MPATH_BOOT)/*
	@sudo install -Cvt $(MPATH_BOOT) $(FEED_BOOT:%=$(FEED_PATH)/%)
	@echo "Installing rootfs files..."
	@sudo rm -Rf $(MPATH_ROOT)/*
	@sudo tar -C $(MPATH_ROOT) -jxf $(FEED_ROOTFS:%=$(FEED_PATH)/%)
	@sudo chmod -R 777 $(MPATH_ROOT)/home/root
	@echo "Boot & rootfs files installed..."

$(FEED_SRCS):
	@mkdir -p $(FEED_PATH)
	@wget --progress=bar:force -P $(FEED_PATH) $(FEED_URL)$(notdir $@)

$(DEPLOY_SRCS):
	@echo "Building image: $@"
	@make image

$(COPY_SRCS):
	@echo "Required images not found in folder '"$(COPY_PATH)"'"
	@exit 1

#--------------------------
card: $(DEPLOY_SRCS) card-mount card-do_update card-unmount

card-init: $(FEED_SRCS) card-format card-mount card-do_init card-do_update card-unmount

card-copy: $(FEED_SRCS) $(COPY_SRCS) card-format card-mount card-do_init card-do_copy card-unmount

.PHONY: card card-init card-copy

#---------------------------
# install helper scripts (gumnet..)
install-scripts:
	@ln -vsft $(BINDIR)/ $(SCRIPTS:%=$(abspath $(SCRIPTS_PATH)/%))

#---------------------------
# install apt packages
install-tools:
	@sudo apt-get --install-suggests \
	install yakuake kdevelop build-essential \
	qtcreator libqwt-dev libphonon-dev \
	g++-arm-linux-gnueabi libc-dev-armel-cross binutils-arm-linux-gnueabi libstdc++-dev-armel-cross \
	openssh-server bluez-compat qgit gcc-multilib g++-multilib kdiff3 kompare ckermit

install-tools-oe:
	@sudo apt-get update
	@sudo apt-get --install-suggests install \
	sed wget cvs subversion git-core coreutils unzip texi2html texinfo docbook-utils \
	gawk python-pysqlite2 diffstat help2man make gcc build-essential g++ desktop-file-utils chrpath \
	libxml2-utils xmlto docbook
	@sudo dpkg-reconfigure dash

#---------------------------
# install OE
install-oe: install-tools-oe
	@mkdir -p $(OE_PATH)
	#------- bitbake -----------
	@cd $(OE_PATH) ;\
	wget http://download.berlios.de/bitbake/bitbake-1.10.2.tar.gz &&\
	tar -zxvf bitbake-1.10.2.tar.gz && mv bitbake-1.10.2 bitbake &&\
	rm bitbake-1.10.2.tar.gz ;\
	#git clone git://git.openembedded.net/bitbake bitbake ;\
	cd bitbake ;\
	#git checkout 1.10.2
	#------- recipes -----------
	@cd $(OE_PATH) ;\
	git clone git://www.sakoman.com/git/openembedded.git $(OEBRANCH) ;\
	cd $(OEBRANCH) ;\
	git checkout overo

#---------------------------
update-oe:
	#------- bitbake -----------
	#cd $(OE_PATH)/bitbake ;\
	#git pull ;\
	#git checkout 1.10.2
	#------- recipes -----------
	cd $(OE_PATH)/$(OEBRANCH) ;\
	git pull origin overo

#---------------------------
clean-oe:
	@cd $(OE_PATH)/$(OEBRANCH) ;\
	git reset --hard
	@echo "Removing OE temp..."
	@rm -Rf $(OE_PATH)/tmp/*
	@echo "Removing temporary sources..."
	@rm -Rf $(OE_PATH)/sources/git_*
	@echo "OE clean finished."

#---------------------------
# build bitbake targets
%:
	@export OVEROTOP=$(OE_PATH) ;\
	export GUMTOP=$(CURDIR) ;\
	export OEBRANCH=$(OE_PATH)/$(OEBRANCH) ;\
	export USERBRANCH=$(CURDIR)/$(USERBRANCH) ;\
	export PATH="$(OE_PATH)/bitbake/bin:$$PATH" ;\
	export BBPATH="$(CURDIR)/build:$(CURDIR)/$(USERBRANCH):$(OE_PATH)/$(OEBRANCH)" ;\
	export BB_ENV_EXTRAWHITE="MACHINE DISTRO ANGSTROM_MODE OVEROTOP OEBRANCH USERBRANCH" ;\
	umask 0002 ;\
	bitbake $@
#---------------------------






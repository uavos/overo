# based on console image for omap3

inherit image

DEPENDS = "task-base"

IMAGE_EXTRA_INSTALL ?= ""

BASE_INSTALL = " \
  task-base-extended \
 "

FIRMWARE_INSTALL = " \
#  linux-firmware \
  libertas-sd-firmware \
  rt73-firmware \
  zd1211-firmware \
 "

TOOLS_INSTALL = " \
  bash \
  bzip2 \
  ckermit \
  devmem2 \
  dhcp-client \
  dosfstools \
  i2c-tools \
  ksymoops \
  mkfs-jffs2 \
  mtd-utils \
  nano \
  openssh-misc \
  openssh-scp \
  openssh-ssh \
  omap3-writeprom \
  procps \
  socat \
  strace \
  sudo \
  syslog-ng \
  task-proper-tools \
  u-boot-utils \
  mc \
  powertop \
 "

IMAGE_INSTALL += " \
  ${BASE_INSTALL} \
  ${FIRMWARE_INSTALL} \
  ${IMAGE_EXTRA_INSTALL} \
  ${TOOLS_INSTALL} \
 "

IMAGE_PREPROCESS_COMMAND = "create_etc_timestamp"

#ROOTFS_POSTPROCESS_COMMAND += '${@base_conditional("DISTRO_TYPE", "release", "zap_root_password; ", "",d)}'



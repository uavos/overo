

DEPENDS = "task-boot dropbear ${ANGSTROM_FEED_CONFIGS}"
IMAGE_INSTALL = "task-boot dropbear ${ANGSTROM_FEED_CONFIGS}"

export IMAGE_BASENAME = "image"
IMAGE_LINGUAS = ""

inherit image

IMAGE_INSTALL += "kernel-modules mtd-utils ckermit nano"

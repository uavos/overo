require recipes/linux/linux.inc

DESCRIPTION = "Linux kernel for OMAP3 processors"
KERNEL_IMAGETYPE = "uImage"

COMPATIBLE_MACHINE = "overo"

SRCREV = "43a25a09a41ded0cc588dbd4ffd5fe7dcc8a5a7d"

PV = "2.6.38"
MACHINE_KERNEL_PR_append = "-pm"

# The main PR is now using MACHINE_KERNEL_PR, for omap3 see conf/machine/include/omap3.inc

#SRC_URI = "git://git.kernel.org/pub/scm/linux/kernel/git/khilman/linux-omap-pm.git;protocol=git;branch=pm \
SRC_URI = "git://www.sakoman.com/git/linux-omap-2.6.git;branch=pm;protocol=git \
	   file://defconfig \
	   file://usb_off.patch \
	   file://mtd_ECC.patch \
"

S = "${WORKDIR}/git"


do_install_append() {
        install -d ${D}/boot
}

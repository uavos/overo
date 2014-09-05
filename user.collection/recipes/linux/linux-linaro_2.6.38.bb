require recipes/linux/linux.inc

DESCRIPTION = "Linux kernel for OMAP3 processors"
KERNEL_IMAGETYPE = "uImage"

COMPATIBLE_MACHINE = "overo"

SRCREV = "HEAD"

PV = "2.6.38"
MACHINE_KERNEL_PR_append = "-linaro"

SRC_URI = "git://git.linaro.org/kernel/linux-linaro-2.6.38.git;protocol=git;branch=master \
	   file://defconfig \
"

S = "${WORKDIR}/git"


do_install_append() {
        install -d ${D}/boot
}

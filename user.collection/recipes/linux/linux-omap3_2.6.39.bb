require recipes/linux/linux.inc

DESCRIPTION = "Linux kernel for OMAP processors"
KERNEL_IMAGETYPE = "uImage"
COMPATIBLE_MACHINE = "overo"

PV = "2.6.39"

S = "${WORKDIR}/git"

SRCREV = "${AUTOREV}"
SRC_URI = "git://www.sakoman.com/git/linux-omap-2.6.git;branch=omap-2.6.39-pm;protocol=git \
	   file://defconfig \
#	   file://mtd_ECC.patch \
           "

MUSB_MODE ?= "host"

do_configure_prepend() {

        if [ "${MUSB_MODE}" = "host" ]; then
            sed -i 's:CONFIG_USB_GADGET=y:# CONFIG_USB_GADGET is not set:g' ${WORKDIR}/defconfig
            sed -i 's:# CONFIG_USB_MUSB_HOST is not set:CONFIG_USB_MUSB_HOST=y:g' ${WORKDIR}/defconfig
            sed -i 's:CONFIG_USB_MUSB_PERIPHERAL=y:# CONFIG_USB_MUSB_PERIPHERAL is not set:g' ${WORKDIR}/defconfig
            sed -i 's:CONFIG_USB_MUSB_OTG=y:# CONFIG_USB_MUSB_OTG is not set:g' ${WORKDIR}/defconfig
            sed -i 's:# CONFIG_USB_MUSB_HDRC_HCD is not set:CONFIG_USB_MUSB_HDRC_HCD=y:g' ${WORKDIR}/defconfig
            sed -i 's:CONFIG_USB_GADGET_MUSB_HDRC=y:# CONFIG_USB_GADGET_MUSB_HDRC is not set:g' ${WORKDIR}/defconfig
        fi

        if [ "${MUSB_MODE}" = "peripheral" ]; then
            sed -i 's:# CONFIG_USB_GADGET is not set:CONFIG_USB_GADGET=y:g' ${WORKDIR}/defconfig
            sed -i 's:CONFIG_USB_MUSB_HOST=y:# CONFIG_USB_MUSB_HOST is not set:g' ${WORKDIR}/defconfig
            sed -i 's:# CONFIG_USB_MUSB_PERIPHERAL is not set:CONFIG_USB_MUSB_PERIPHERAL=y:g' ${WORKDIR}/defconfig
            sed -i 's:CONFIG_USB_MUSB_OTG=y:# CONFIG_USB_MUSB_OTG is not set:g' ${WORKDIR}/defconfig
            sed -i 's:CONFIG_USB_MUSB_HDRC_HCD=y:# CONFIG_USB_MUSB_HDRC_HCD is not set:g' ${WORKDIR}/defconfig
            sed -i 's:# CONFIG_USB_GADGET_MUSB_HDRC is not set:CONFIG_USB_GADGET_MUSB_HDRC=y:g' ${WORKDIR}/defconfig
        fi

        if [ "${MUSB_MODE}" = "otg" ]; then
            sed -i 's:# CONFIG_USB_GADGET is not set:CONFIG_USB_GADGET=y:g' ${WORKDIR}/defconfig
            sed -i 's:CONFIG_USB_MUSB_HOST=y:# CONFIG_USB_MUSB_HOST is not set:g' ${WORKDIR}/defconfig
            sed -i 's:CONFIG_USB_MUSB_PERIPHERAL=y:# CONFIG_USB_MUSB_PERIPHERAL is not set:g' ${WORKDIR}/defconfig
            sed -i 's:# CONFIG_USB_MUSB_OTG is not set:CONFIG_USB_MUSB_OTG=y:g' ${WORKDIR}/defconfig
            sed -i 's:CONFIG_USB_MUSB_HDRC_HCD=y:# CONFIG_USB_MUSB_HDRC_HCD is not set:g' ${WORKDIR}/defconfig
            sed -i 's:# CONFIG_USB_GADGET_MUSB_HDRC is not set:CONFIG_USB_GADGET_MUSB_HDRC=y:g' ${WORKDIR}/defconfig
        fi
}


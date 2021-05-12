#!/bin/bash

exportdefvar UBOOT_GITURL       ""
exportdefvar UBOOT_GITREPO      ""
exportdefvar UBOOT_BRANCH       ""
exportdefvar UBOOT_PRECOMPILE   ""
exportdefvar UBOOT_RECOMPILE    ""
exportdefvar UBOOT_CLEAN        ""

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_current_task

show_message                                    \
    "UBOOT_GITURL     : ${UBOOT_GITURL}"        \
    "UBOOT_GITREPO    : ${UBOOT_GITREPO}"       \
    "UBOOT_BRANCH     : ${UBOOT_BRANCH}"        \
    "UBOOT_PRECOMPILE : ${UBOOT_PRECOMPILE}"    \
    "UBOOT_RECOMPILE  : ${UBOOT_RECOMPILE}"     \
    "UBOOT_CLEAN      : ${UBOOT_CLEAN}"

show_message_counter "    continue in:"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! ( get_git_pkg "${UBOOT_GITURL}" "${UBOOT_GITREPO}" "${UBOOT_BRANCH}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! pushd "${CACHE}" ; then goto_exit 2 ; fi

    pushd "${USERDIR}"
        if ! [ -z "${UBOOT_PRECOMPILE}" ] ; then
            if ! ( eval ${UBOOT_PRECOMPILE} ) ; then goto_exit 3 ; fi
        fi
    popd

    if ! pushd "${UBOOT_GITREPO}-${UBOOT_BRANCH}" ; then goto_exit 4 ; fi

        if ( [ "${UBOOT_RECOMPILE}" == "y" ] || ! ( [ -f "SPL" ] || [ -f "u-boot.imx" ] || [ -f "u-boot.img" ] ) ) ; then

            if [ "${UBOOT_CLEAN}" != "n" ] ; then make clean ; fi

            if ! ( make ARCH=${ARCH} CROSS_COMPILE="${TOOLCHAIN_PREFIX}" ${NJ} ${UBOOT_CONFIG} ) ; then goto_exit 5 ; fi
            if ! ( make ARCH=${ARCH} CROSS_COMPILE="${TOOLCHAIN_PREFIX}" ${NJ} ) ; then goto_exit 6 ; fi
        fi
    popd

popd

#!/bin/bash

cd $(dirname ${0})

#######################################################################################################################
# check arguments

PLATFORM=${1}
BUILDTARGET=${2}

if [ -z "${PLATFORM}" ] || [ ! -e "plugins-dep/configs/${PLATFORM}_defconfig" ]; then
  echo "Usage: $0 <platform> [build-target]"
  echo "  Where platform can be one of: $(echo $(ls plugins-dep/configs | grep _defconfig | sed 's/_defconfig//g' | sort))"
  exit 1
fi

#######################################################################################################################
# Import common code and variables

source .common

#######################################################################################################################
# download and extract crosstool-ng

if [ ! -f ${TOOLCHAIN_BUILD_DIR}/${CT_NG_VERSION}/configure ]; then
  if [ ! -f ${DOWNLOAD_DIR}/${CT_NG_FILE} ]; then
    wget ${CT_NG_LINK}/${CT_NG_FILE} -O ${DOWNLOAD_DIR}/${CT_NG_FILE}
  fi

  mkdir -p ${TOOLCHAIN_BUILD_DIR}/${CT_NG_VERSION}
  tar xf ${DOWNLOAD_DIR}/${CT_NG_FILE} -C ${TOOLCHAIN_BUILD_DIR}/${CT_NG_VERSION} --strip-components=1

  case "${CT_NG_VERSION}" in
    "crosstool-ng-1.25.0")
      patch -d ${TOOLCHAIN_BUILD_DIR}/${CT_NG_VERSION} -p1 -i ${SOURCE_DIR}/patches/${CT_NG_VERSION}/001_fix-make4.4-build.patch

      cp ${SOURCE_DIR}/patches/${CT_NG_VERSION}/gcc-9.4.0/*.patch ${TOOLCHAIN_BUILD_DIR}/${CT_NG_VERSION}/packages/gcc/9.4.0/
      cp ${SOURCE_DIR}/patches/${CT_NG_VERSION}/glibc-2.34/*.patch ${TOOLCHAIN_BUILD_DIR}/${CT_NG_VERSION}/packages/glibc/2.34/
      cp ${SOURCE_DIR}/patches/${CT_NG_VERSION}/gmp-6.1.2/*.patch ${TOOLCHAIN_BUILD_DIR}/${CT_NG_VERSION}/packages/gmp/6.1.2/
    ;;

    "crosstool-ng-1.28.0")
      cp ${SOURCE_DIR}/patches/${CT_NG_VERSION}/glibc-2.34/*.patch ${TOOLCHAIN_BUILD_DIR}/${CT_NG_VERSION}/packages/glibc/2.34/
    ;;
  esac
fi

#######################################################################################################################
# build crosstool-ng

cd ${TOOLCHAIN_BUILD_DIR}/${CT_NG_VERSION}

if [ ! -f .config ]; then
  cp ${SOURCE_DIR}/toolchain/${TOOLCHAIN_PLATFORM}.config .config
  sed -i -e "s|CT_LOCAL_TARBALLS_DIR=.*|CT_LOCAL_TARBALLS_DIR=\"${DOWNLOAD_DIR}\"|" .config
  sed -i -e "s|CT_PREFIX_DIR=.*|CT_PREFIX_DIR=\"${TOOLCHAIN_DIR}\"|" .config
fi

if [ ! -f .stamp_configured ]; then
  ./configure --enable-local ACLOCAL=aclocal AUTOMAKE=automake
  touch .stamp_configured
fi

if [ ! -f .stamp_built1 ]; then
  make
  touch .stamp_built1
fi

if [ ! -f .stamp_built2 ]; then
  ./ct-ng build
  touch .stamp_built2
fi

#######################################################################################################################
# download, extract and patch buildroot

if [ ! -d ${BUILD_DIR}/${BUILDROOT_VERSION} ]; then
  if [ ! -f ${DOWNLOAD_DIR}/${BUILDROOT_FILE} ]; then
    wget ${BUILDROOT_LINK}/${BUILDROOT_FILE} -O ${DOWNLOAD_DIR}/${BUILDROOT_FILE}
  fi

  tar xf ${DOWNLOAD_DIR}/${BUILDROOT_FILE} -C ${BUILD_DIR}

  case "${BUILDROOT_VERSION}" in
    "buildroot-2023.11.3")
      patch -d ${BUILD_DIR}/${BUILDROOT_VERSION} -p1 -i ${SOURCE_DIR}/patches/${BUILDROOT_VERSION}/001_gcc-15.patch
      patch -d ${BUILD_DIR}/${BUILDROOT_VERSION} -p1 -i ${SOURCE_DIR}/patches/${BUILDROOT_VERSION}/002_fix-finding-ncurses.patch
    ;;
  esac
fi

for dir in `ls ${SOURCE_DIR}/global-packages/${BUILDROOT_VERSION}`; do
  rm -rf ${BUILD_DIR}/${BUILDROOT_VERSION}/package/${dir}
  cp -r ${SOURCE_DIR}/global-packages/${BUILDROOT_VERSION}/${dir} ${BUILD_DIR}/${BUILDROOT_VERSION}/package/${dir}/
done

for dir in `ls ${SOURCE_DIR}/patches/${BUILDROOT_VERSION}/packages`; do
  cp ${SOURCE_DIR}/patches/${BUILDROOT_VERSION}/packages/${dir}/*.patch ${BUILD_DIR}/${BUILDROOT_VERSION}/package/${dir}/
  for subdir in `ls ${SOURCE_DIR}/patches/${BUILDROOT_VERSION}/packages/${dir} | grep -v '.patch'`; do
    cp ${SOURCE_DIR}/patches/${BUILDROOT_VERSION}/packages/${dir}/${subdir}/*.patch ${BUILD_DIR}/${BUILDROOT_VERSION}/package/${dir}/${subdir}/
  done
done

#######################################################################################################################
# buildroot setup

export DOWNLOAD_PATH=${DOWNLOAD_DIR}
export TOOLCHAIN_PATH=${TOOLCHAIN_DIR}

cd ${BUILD_DIR}/${BUILDROOT_VERSION}

#######################################################################################################################
# initial first build

${BR2_MAKE} ${BR2_PLATFORM}_defconfig

if [ "${BUILDTARGET}" = "dev" ]; then
  ${BR2_MAKE} host-openssl
  ${BR2_MAKE} host-python3
  # for mod-host
  ${BR2_MAKE} jack2mod
  ${BR2_MAKE} hylia
  ${BR2_MAKE} lilv
  ${BR2_MAKE} readline
elif [ "${BUILDTARGET}" = "menuconfig" ]; then
  ${BR2_MAKE} menuconfig
  ${BR2_MAKE} savedefconfig
elif [ "${BUILDTARGET}" = "minimal" ]; then
  ${BR2_MAKE} host-cmake
  ${BR2_MAKE} fftw-double
  ${BR2_MAKE} fftw-single
  ${BR2_MAKE} liblo
  ${BR2_MAKE} lv2
  ${BR2_MAKE} darkglass-lv2-extensions
  ${BR2_MAKE} kxstudio-lv2-extensions
  ${BR2_MAKE} alsa-utils
  if [ "${TOOLCHAIN_PLATFORM}" = "generic-x86_64" ]; then
    ${BR2_MAKE} carla-backend
    ${BR2_MAKE} valgrind
  elif [ "${TOOLCHAIN_PLATFORM}" != "generic-aarch64" ]; then
    ${BR2_MAKE} libnickel
  fi
elif [ "${BUILDTARGET}" = "toolchain" ]; then
  ${BR2_MAKE}
else
  ${BR2_MAKE} ${BUILDTARGET}
fi

#######################################################################################################################

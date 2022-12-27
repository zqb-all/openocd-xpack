# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function application_build_versioned_components()
{
  # Don't use a comma since the regular expression
  # that processes this string in the Makefile, silently fails and the
  # bfdver.h file remains empty.
  XBB_BRANDING="${XBB_APPLICATION_DISTRO_NAME} ${XBB_APPLICATION_NAME} ${XBB_REQUESTED_TARGET_MACHINE}"

  XBB_OPENOCD_VERSION="$(echo "${XBB_RELEASE_VERSION}" | sed -e 's|-.*||')"

  XBB_OPENOCD_GIT_COMMIT=${XBB_OPENOCD_GIT_COMMIT:-""}

  XBB_OPENOCD_GIT_URL=${XBB_OPENOCD_GIT_URL:-"https://github.com/xpack-dev-tools/openocd.git"}

  XBB_OPENOCD_GIT_BRANCH=${XBB_OPENOCD_GIT_BRANCH:-"xpack"}
  # XBB_OPENOCD_GIT_BRANCH=${XBB_OPENOCD_GIT_BRANCH:-"xpack-develop"}
  XBB_OPENOCD_GIT_COMMIT=${XBB_OPENOCD_GIT_COMMIT:-"v${XBB_RELEASE_VERSION}-xpack"}

  # Keep them in sync with combo archive content.
  if [[ "${XBB_RELEASE_VERSION}" =~ 0\.11\.0-[5] ]]
  then
    # -------------------------------------------------------------------------
    # Build the native dependencies.

    autotools_build

    # https://ftp.gnu.org/gnu/texinfo/
    texinfo_build "6.8"

    # -------------------------------------------------------------------------
    # Build the target dependencies.

    xbb_reset_env
    xbb_activate_installed_bin
    xbb_set_target "requested"

    # -------------------------------------------------------------------------

    if [ "${XBB_REQUESTED_HOST_PLATFORM}" != "darwin" ]
    then

      # https://ftp.gnu.org/pub/gnu/libiconv/
      libiconv_build "1.17" # "1.16"

    fi

    # -------------------------------------------------------------------------

    # https://sourceforge.net/projects/libusb/files/libusb-1.0/
    libusb1_build "1.0.26"

    if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
    then
      # https://sourceforge.net/projects/libusb-win32/files/libusb-win32-releases/
      libusb_w32_build "1.2.6.0" # ! PATCH & pkgconfig
    else
      # https://sourceforge.net/projects/libusb/files/libusb-compat-0.1/
      # required by libjaylink
      libusb0_build "0.1.5"
    fi

    # http://www.intra2net.com/en/developer/libftdi/download.php
    libftdi_build "1.5" # ! PATCH

    # https://github.com/libusb/hidapi/releases
    hidapi_build "0.12.0" # "0.10.1" # ! pkgconfig/hidapi-*-windows.pc

    # -------------------------------------------------------------------------
    # Build the application binaries.

    xbb_set_executables_install_path "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
    xbb_set_libraries_install_path "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"

    openocd_build "${XBB_OPENOCD_VERSION}"

    # -------------------------------------------------------------------------
  else
    echo "Unsupported ${XBB_APPLICATION_LOWER_CASE_NAME} version ${XBB_RELEASE_VERSION}"
    exit 1
  fi
}

# -----------------------------------------------------------------------------

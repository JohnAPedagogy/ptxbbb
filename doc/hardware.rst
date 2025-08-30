.. _hardware-platforms:

Hardware Platforms
==================

DistroKit supports a range of hardware, supported by the ptxdist
platforms listed below. A platform can be built with one ``ptxdist
images`` and shares the same cross compiler and binary format.

To build a platform, choose the respective platformconfig, e.g.::

   $ ptxdist platform configs/platform-v7a/platformconfig
   info: selected platformconfig:
        'configs/platform-v7a/platformconfig'

If the respective toolchain for the platform is installed from the Debian packages
or tarballs, PTXdist is able to find and select the right toolchain automatically.
Otherwise, select your toolchain by giving its path manually, e.g. with::

   $ ptxdist toolchain /opt/OSELAS.Toolchain-2020.08.0/x86_64-unknown-linux-gnu/gcc-10.2.1-clang-10.0.1-glibc-2.32-binutils-2.35-kernel-5.8-sanitized/bin
   found and using toolchain:
   '/opt/OSELAS.Toolchain-2020.08.0/x86_64-unknown-linux-gnu/gcc-10.2.1-clang-10.0.1-glibc-2.32-binutils-2.35-kernel-5.8-sanitized/bin/'

Then you can build all images with::

   $ ptxdist images


v7a Platform
------------

+-------------------------+-----------------------------------------+
| platformconfig:         | ``configs/platform-v7a/platformconfig`` |
+-------------------------+-----------------------------------------+
| Toolchain architecture: | ``arm-v7a-linux-gnueabihf``             |
+-------------------------+-----------------------------------------+

The v7a platform is made for machines based on the ARMv7-A architecture.
It supports the following hardware:

.. toctree::
   :maxdepth: 1

   hardware_v7a_qemu
   hardware_v7a_beaglebone_white
   hardware_v7a_beaglebone_black
   hardware_v7a_nitrogen6x
   hardware_v7a_riot
   hardware_v7a_rpi
   hardware_v7a_udoo_neo
   hardware_v7a_sama5d2
   hardware_v7a_sama5d4

If you want to get DistroKit running on your ARMv7-A board which is not
listed above, here is a short overview of the generic way:

1. Build the device tree for your board by adding its DTS source file to the
   variable ``PTXCONF_DTC_OFTREE_DTS`` (in ``ptxdist menuconfig platform`` →
   *Build device tree* → *source dts file*).
   The compiled device tree will appear in ``platform-v7a/images/`` after the
   build.

2. Build a bootloader for your board.
   If the hardware is very similar to one of the provided *barebox* packages,
   you can simply adapt their config (``ptxdist menuconfig barebox-TARGET``)
   and the respective rules in ``configs/platform-v7a/rules/barebox-*.make``.
   If your hardware is too different, you can create a new bootloader package
   with ``ptxdist newpackage barebox``.

   Bootloader images can also be found in ``platform-v7a/images/`` after the
   PTXdist build.
   You can use these images to populate your board with a bootloader, for
   example with imx-usb-loader, fastboot, or the tool of choice for your
   respective SoC.

3. Adapt the kernel configuration to include support for your board with
   ``ptxdist menuconfig kernel``.
   After the build, you will find the kernel zImage in
   ``platform-v7a/images/linuximage``.

4. The userland for ARMv7-A is built to ``platform-v7a/images/root.{ext2,tgz}``.
   You can simply use these images too populate your boot media, or boot from
   NFS instead (see section :ref:`nfsroot`).

5. If you want to build a separate hdimage for your board, for example to boot
   barebox and the kernel from an SD card, create a new image package with
   ``ptxdist newpackage image-genimage`` (or fork one of the existing packages
   in ``configs/platform-v7a/``).

6. Send patches to <distrokit@pengutronix.de> :)

Refer to the :ref:`ptx_dev_manual` for a more thorough documentation.

Fast Development via fastboot
-----------------------------

For development, the v7a bootloaders are set-up to support :ref:`fast_development`
out of the box.
Currently this is supported on all v7a boards except AT91 and AM33xx platforms.

The actual partition names might differ between boards.
To get a list of exported partitions, connect the USB OTG connector on the
board, and run on your development host::

   $ fastboot getvar all
   (bootloader) version: 0.4
   (bootloader) bootloader-version: barebox-2023.02.1
   (bootloader) max-download-size: 8388608
   (bootloader) partition-size:mmc1: 00000000
   (bootloader) partition-type:mmc1: unavailable
   (bootloader) partition-size:mmc2: 00000000
   (bootloader) partition-type:mmc2: unavailable
   (bootloader) partition-size:mmc3: e5000000
   (bootloader) partition-type:mmc3: basic
   (bootloader) partition-size:ram-kernel: 00000000
   (bootloader) partition-type:ram-kernel: file
   (bootloader) partition-size:ram-initramfs: 00000000
   (bootloader) partition-type:ram-initramfs: file
   (bootloader) partition-size:ram-oftree: 00000000
   (bootloader) partition-type:ram-oftree: file
   (bootloader) partition-size:bbu-emmc: 000e0000
   (bootloader) partition-type:bbu-emmc: basic

In this example, the exported partition names are *mmc1*, *mmc2*, *mmc3*,
*ram-kernel*, *ram-initramfs*, *ram-oftree* and *bbu-emmc*.
In this example two of the SD cards (*mmc1* and *mmc2*) are not plugged in (i.e.
"unavailable").
Note that the entries starting with *ram-* refer to files in RAM instead of
persistent storage.

.. note:: You need to restart the fastboot usbgadget in barebox or reset the
   board if you swap the SD cards later on.

You can write images to the exported fastboot partitions by running the
``fastboot flash`` command on your development host::

   $ fastboot flash ram-kernel platform-v7a/images/linuximage
   $ fastboot flash ram-oftree platform-v7a/images/imx6dl-riotboard.dtb
   $ fastboot flash ram-initramfs platform-v7a/images/root.cpio.gz

(The Device Tree here is exemplary for the RIoT-Board; use the respective DTB
for your board instead.)

Then instruct barebox to boot from the *ram-fastboot* boot target::

   $ fastboot oem exec -- boot ram-fastboot

You can populate persistent memory like the eMMC as well. But only a whole
memory device can be written, no single partitions, so your image has to
include a partition table if needed::

   $ fastboot flash mmc1 platform-v7a/images/riotboard.hdimg

The mapping of *mmc1*, *mmc2* and *mmc3* depends on the board; see the
documentation for each board above.

.. note:: If you have no USB connection to your board, you can use
          a network connection instead. Run all the 'fastboot' commands
          shown above with the additional option '-s udp:<board IP address>'.

v7a_noneon Platform
-------------------

+-------------------------+------------------------------------------------+
| platformconfig:         | ``configs/platform-v7a_noneon/platformconfig`` |
+-------------------------+------------------------------------------------+
| Toolchain architecture: | ``arm-v7a-linux-gnueabihf``                    |
+-------------------------+------------------------------------------------+

The v7a_noneon platform targets machines based on the ARMv7-A architecture
which don't have support for the NEON SIMD extension.
It supports the following hardware:

.. toctree::
   :maxdepth: 1

   hardware_v7a_noneon_sama5d3


v8a Platform
------------

+-------------------------+-----------------------------------------+
| platformconfig:         | ``configs/platform-v8a/platformconfig`` |
+-------------------------+-----------------------------------------+
| Toolchain architecture: | ``aarch64-v8a-linux-gnu``               |
+-------------------------+-----------------------------------------+

The v8a platform targets the ARMv8-A architecture.

The stuff from the v7a section above applies here accordingly.

Currently, DistroKit supports the following hardware:

.. toctree::
   :maxdepth: 1

   hardware_v8a_espressobin
   hardware_v8a_rock3a
   hardware_v8a_tqma93xxca


rpi1 Platform
-------------

+-------------------------+------------------------------------------+
| platformconfig:         | ``configs/platform-rpi1/platformconfig`` |
+-------------------------+------------------------------------------+
| Toolchain architecture: | ``arm-1136jfs-linux-gnueabihf``          |
+-------------------------+------------------------------------------+

.. note::

  The rpi1 platform is currently not actively maintained,
  as RPi 1 has been superseded by newer models
  which are supported in the v7a platform.
  However, if you are targeting a RPi 1,
  we will be happy to merge your patches anyways.

The rpi1 platform has support for the Raspberry Pi 1 and Raspberry Pi Zero W,
which is based on the Broadcom BCM2835 SoC (ARMv6):

.. toctree::
   :maxdepth: 1

   hardware_rpi1_raspi1


mips Platform
-------------

+-------------------------+------------------------------------------+
| platformconfig:         | ``configs/platform-mips/platformconfig`` |
+-------------------------+------------------------------------------+
| Toolchain architecture: | ``mips-softfloat-linux-gnu``             |
+-------------------------+------------------------------------------+

.. toctree::
   :maxdepth: 1

   hardware_mips_qemu


mips Platform
-------------

+-------------------------+--------------------------------------------+
| platformconfig:         | ``configs/platform-mipsel/platformconfig`` |
+-------------------------+--------------------------------------------+
| Toolchain architecture: | ``mipsel-softfloat-linux-gnu``             |
+-------------------------+--------------------------------------------+

.. toctree::
   :maxdepth: 1

   hardware_mipsel_qemu


x86_64 Platform
---------------

+-------------------------+--------------------------------------------+
| platformconfig:         | ``configs/platform-x86_64/platformconfig`` |
+-------------------------+--------------------------------------------+
| Toolchain architecture: | ``x86_64-unknown-linux-gnu``               |
+-------------------------+--------------------------------------------+

.. toctree::
   :maxdepth: 1

   hardware_x86_64_qemu

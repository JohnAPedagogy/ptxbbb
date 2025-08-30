TQ-Systems i.MX93 TQMa93xxLA/TQMa93xxCA on MBa93xxCA starter kit
================================================================


Boot Media
----------

Booting is available via multiple sources (Compare Table 6: Boot configuration i.MX 93 from TQMa93xxCA UM 0003)

.. csv-table:: Example :rst:dir:`csv-table`
   :header: "Boot Source", "BOOT_MODE2", "BOOT_MODE1", "BOOT_MODE0"

   "Boot from eFuse",               "0", "0", "0"
   "Serial Downloader (USB1)",      "0", "0", "1"
   "Boot from eMMC 5.1",            "0", "1", "0"
   "Boot from SD 3.0 card",         "0", "1", "1"
   "Boot from FlexSPI Serial NOR",  "1", "0", "0"


Booting from USB and NFS
~~~~~~~~~~~~~~~~~~~~~~~~

Upload the bootloader ``platform-v8a/images/barebox-tqma93xx.img`` via USB:

.. code-block:: shell

    platform-v8a/sysroot-host/bin/imx-usb-loader platform-v8a/images/barebox-tqma93xx.img

In Barebox, set the default boot location to nfs:

    nv boot.default nfs://dude06//ptx/work/user/fpg/DistroKit/platform-v8a/root

replace the path to one, where you have compiled your Distrokit


Booting via SD-Card
~~~~~~~~~~~~~~~~~~~

Write the image ``platform-v8a/images/tq-mba93xxca.img`` to a microSD card. Put the
microSD card into the TQMa93xxCA and boot it.


Serial Console
--------------

The serial boot console is available via the microUSB Connector on the board.
It brings 4 UARTS, whereas the first is the Serial console used by kernel and bootloader.

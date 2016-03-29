# ipxe

Contains the main iPXE menu for the new RaBe CentOS-7 stack.

The menu is generated based on the contents of the [kickstart](https://github.com/radiorabe/kickstart) repository in a hacky fashion.

You can regenerate the menu as follows.

```bash
git clone https://github.com/radiorabe/ipxe.git rabe-ipxe
cd rabe-ipxe
bash update.sh
git commit ipxe.menu
git push origin develop
```

It is expected that this gets replaced with a serious menu generator as soon as we have some infrastructure in place.

For now this is used in a github-as-infrastructure fashion with ISC bind as follows.

```
if exists user-class and option user-class = "iPXE" {
      filename "https://raw.githubusercontent.com/radiorabe/ipxe/develop/ipxe.menu";
} else {
      filename "ipxe/undionly.kpxe";
}
```
## CentOS 7 iPXE HTTP installation via text mode over serial console
The [centos7-serial.ipxe](centos7-serial.ipxe) iPXE boot script can be used to boot and install CentOS 7 over HTTP via a serial console. This is usefull for (and was tested on) [PC Engine's APU borads](http://pcengines.ch/apu.htm) or other systems without a video output but PXE/iPXE support.

Follow the steps below to boot the CentOS 7 installer over HTTP.

Open up a serial terminal, for example via minicom: 
```bash
minicom -b 115200 8N1 -D /dev/ttyUSB0
```
Enter the iPXE boot menu, by pressing CTRL-B (on PC Engines APU at least):
```
iPXE 1.0.0+ -- Open Source Network Boot Firmware -- http://ipxe.org                                           
Features: HTTP iSCSI DNS TFTP AoE bzImage ELF MBOOT PXE PXEXT Menu                                            
                                                                                                              
iPXE>
```

Chainload ipxe over ipxe first (as the APU version seems to be buggy and will result in <code>Initramfs unpacking failed: junk in compressed archive</code>)
```
dhcp
chain http://boot.ipxe.org/ipxe.pxe
# CTRL-B
ifconf
chain https://raw.githubusercontent.com/radiorabe/ipxe/master/centos7-serial.ipxe
```


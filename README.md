# CentOS 7 iPXE HTTP installation via text mode over serial console

The [centos7-serial.ipxe](centos7-serial.ipxe) iPXE boot script can be used to boot and install CentOS 7 over HTTP via a serial console. This is useful for (and was tested on) [PC Engine's APU boards](http://pcengines.ch/apu.htm) and [APU2 boards](http://pcengines.ch/apu2.htm) (requires [BIOS version >= 160311](http://pcengines.ch/howto.htm#bios)) or other systems without a video output but PXE/iPXE support.

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
chain http://rabe.hairmare.ch/centos7-serial.ipxe

# If your iPXE supports HTTPS, you can chainload directly from GitHub
chain https://raw.githubusercontent.com/radiorabe/ipxe/master/centos7-serial.ipxe
```
or if you're lazy:
```
# [...]

# URL shortener pointing to http://rabe.hairmare.ch/centos7-serial.ipxe
chain http://bit.ly/2cps3s6

# URL shortener pointing to https://raw.githubusercontent.com/radiorabe/ipxe/master/centos7-serial.ipxe
chain http://bit.ly/1WZH8Nu
```

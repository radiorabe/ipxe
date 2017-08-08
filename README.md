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

## Post installation steps
Before rebooting into the installed system make sure that the installed system can be accessed via serial console. Use the installation console to check the following steps. Alternatively you can also login via SSH as root later on (if you know which IP address your system has configured or obtained).

After the installation, the grub boot loader should already have the necessary kernel options set (the same as used during the installation) so that all the output will be redirected to the serial console (`console=ttyS0,115200n8`).

The configuration is located at `/etc/sysconfig/grub` (within the chroot or the already booted system):
```
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL="serial console"
GRUB_SERIAL_COMMAND="serial --speed=115200"
GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap ipv6.disable console=ttyS0,115200n8"
GRUB_DISABLE_RECOVERY="true"
```

If you need to make changes, re-generate the grub configuration:
```
grub2-mkconfig -o /boot/grub2/grub.cfg
```

To be able to login over the serial console, a getty process needs to be started on the serial console. According to [systemd for Administrators - Gettys on Serial Consoles](http://0pointer.de/blog/projects/serial-console.html), systemd should start a getty process automatically as soon as the kernel console parameter points to a serial console (`console=ttyS0`). However, for some reason systemd didn't start the getty and the service needs to be started and enabled manually:
```bash
systemctl enable serial-getty@ttyS0.service
systemctl start serial-getty@ttyS0.service
```

Afterwards there should be an `agetty` process running and the login should work over the serial console. You might need to send a [break signal](https://en.wikipedia.org/wiki/Universal_asynchronous_receiver/transmitter#Break_condition) first, if there's no prompt visible (within `minicom` use `CTRL-A` then `[Shift] F`).
```bash
ps u -C agetty
```
```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root       655  0.0  0.0 110032   848 tty1     Ss+  18:46   0:00 /sbin/agetty --noclear tty1 linux
root      2424  0.0  0.0 110032   868 ttyS0    Ss+  18:47   0:00 /sbin/agetty --keep-baud 115200 38400 9600 ttyS0 vt220
```

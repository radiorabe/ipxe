# ipxe

Contains the main iPXE M=menu for the new RaBe CentOS-7 stack.

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

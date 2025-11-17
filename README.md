# VaseX - Artix

> Assumes x86_64 UEFI. Bit of weird project: No ISO needed works from any existing Linux installation.
> Deps are listed `vase_os/mindeps` and in `klartix.conf`
```
PKG_MAN="pacman"
PKG_MAN_W="-S"
ARG1="--noconfirm --needed"
```

Setups FDE with GRUB2 LUKS2 (PKBF2) on LVM. 

And keymap support using [ckbcomp](https://aur.archlinux.org/packages/ckbcomp).
Challenge came from the Grub2 [manual](https://www.gnu.org/software/grub/manual/grub/grub.html#Input-terminal) itself:

```
Firmware console on BIOS, IEEE1275 and ARC doesn’t allow you to enter non-ASCII characters. 
EFI specification allows for such but author is unaware of any actual implementations. 
Serial input is currently limited for latin1 (unlikely to change). 
Own keyboard implementations (at_keyboard and usb_keyboard) supports any key but work on one-char-per-keystroke. 
So no dead keys or advanced input method. Also there is no keymap change hotkey. 
In practice it makes difficult to enter any text using non-Latin alphabet. 
Moreover all current input consumers are limited to ASCII. 
```

Using bash only and the official [ArtixBootstrap Tool](https://gitea.artixlinux.org/artix/artix-bootstrap/)

- Modify `vase_os/klar_tix_lvm/klartix.conf`

*On the host*

To edit it directly: `sudo./main -ekc`
- Install base sys: `sudo ./main -k` 

Runtime: 255.33s

*On the target*

Go to `cd VaseX`
Set up plasma & drivers: `sudo ./main -kpe`  
- Install: `sudo ./main -kde` *On the target*

Runtime (Using Klagan mode 430.92 mb plasma install on disk total with drivers, browser, essentials 2.95 GiB on Ext4): about 150 seconds

Useful if your submodules are out of sync
```
  # git submodule update --remote 
  # or reclone everything fresh: rm -rf VaseX
  # git clone --recurse-submodules <repo-url> 
```

## LINKS:

- https://wiki.artixlinux.org/Main/InstallationWithFullDiskEncryption
- https://github.com/paulphys/artix-fde


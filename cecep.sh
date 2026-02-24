read -p "masukan partisi boot: " boot
read -p "masukan partisi root: " root
read -p "masukan partisi home: " home
read -p "masukan username: " username
read -p "masukan hostname: " hostname
read -sp "masukan password: " pw
read -p "masukan nama procesor: " procesor

# root partition
function format {

yes | mkfs.ext4 -b 4096 $root &&
yes | mkfs.vfat -F32 -n BOOT $boot &&
yes | mkfs.ext4 -b 4096 $home

}

# boot partition 
function mounting {

mount $root /mnt &&
mkdir /mnt/boot &&
mkdir /mnt/home &&
mount -o uid=0,gid=0,fmask=0077,dmask=0077 $boot /mnt/boot &&
mount $home /mnt/home

}

# home partition 
#function create_home {

#mkfs.ext4 -b 4096 $home &&
#mkdir /mnt home &&
#mount $home /mnt/home

#}

# packages
function packages {

pacstrap /mnt linux-zen linux-headers linux-firmware-$procesor $procesor-ucode iptables-nft bash-completion base base-devel mkinitcpio git firewalld wget neovim --noconfirm &&
genfstab -U /mnt > /mnt/etc/fstab

}

# network
function network {

cp /etc/systemd/network/* /mnt/etc/systemd/network  &&
mkdir /mnt/var/lib/iwd &&
cp -r /var/lib/iwd /mnt/var/lib/iwd

}

# tampilan
function tampilan {

arch-chroot /mnt pacman -S gnome gdm pipewire pipewire-jack pipewire-alsa pipewire-pulse wireplumber pamixer networkmanager network-manager-applet gnome-keyring --noconfirm

}

# hostname
function hostname {

arch-chroot /mnt echo $hostname > /mnt/etc/hostname

}

# Timezone
function timezone {

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime &&
arch-chroot /mnt hwclock --systohc &&
arch-chroot /mnt sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen &&
arch-chroot /mnt locale-gen &&
arch-chroot /mnt locale > /mnt/etc/locale.conf &&
arch-chroot /mnt sed -i 's/^LANG=C.UTF-8/LANG=en_US.UTF-8/' /etc/locale.conf &&
arch-chroot /mnt sed -i 's/^LC_ALL=/LC_ALL=en_US.UTF-8/' /etc/locale.conf

}

# username
function username {

arch-chroot /mnt useradd -m $username &&
echo "$username:$pw" | arch-chroot /mnt chpasswd &&
arch-chroot /mnt usermod -aG wheel $username

}

# sudoers
function sudoers {

echo "$username ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/nologin
}

# cmdline
function cmdline {

arch-chroot /mnt mkdir -p /mnt/etc/cmdline.d &&
arch-chroot /mnt touch /mnt/etc/cmdline.d/{01-boot.conf,02-mods.conf,03-secs.conf,04-perf.conf,05-nets.conf,06-misc.conf} &&
arch-chroot /mnt echo "root=$root" /mnt/etc/cmdline.d/01-boot.conf &&
arch-chroot /mnt echo "rw" /mnt/etc/cmdline.d/06-misc.conf

}

# mkinitcpio
function mkinticpio {

mv /mnt/etc/mkinitcpio.conf /mnt/etc/mkinitcpio.d/default.conf &&
arch-chroot /mnt sed -i 's/^\#ALL_config="\/etc\/mkinitcpio.conf"/ALL_config="\/etc\/mkinitcpio.d\/default.conf"/' /etc/mkinitcpio.d/linux-zen.preset &&
arch-chroot /mnt sed -i 's/^\#ALL_kver="\/boot\/vmlinuz-linux-zen"/ALL_kver="\/boot\/kernel\/vmlinuz-linux-zen"/' /etc/mkinitcpio.d/linux-zen.preset &&
arch-chroot /mnt sed -i 's/^\#ALL_kerneldest="\/boot\/vmlinuz-linux-zen"/ALL_kerneldest="\/boot\/kernel\/vmlinuz-linux-zen"/' /etc/mkinitcpio.d/linux-zen.preset &&
arch-chroot /mnt sed -i 's/^default_image="\/boot\/initramfs-linux-zen.img"/\#default_image="\/boot\/initramfs-linux-zen.img"/' /etc/mkinitcpio.d/linux-zen.preset &&
arch-chroot /mnt sed -i 's/^\#default_uki="\/efi\/EFI\/Linux\/arch-linux-zen.efi"/default_uki="\/boot\/efi\/Linux\/arch-linux-zen.efi"/' /etc/mkinitcpio.d/linux-zen.preset

}

# boot
function boot {

mkdir /mnt/boot/kernel && mkdir /mnt/boot/efi &&
mv /mnt/boot/$procesor-* /mnt/boot/kernel &&
mv /mnt/boot/vmlinuz-* /mnt/boot/kernel &&
rm -fr /mnt/boot/initramfs-*
arch-chroot /mnt bootctl --path=/boot install
arch-chroot /mnt mkinitcpio -P
umount -R /mnt

}

function runscript {

echo "configure pon"
format
sleep 5

echo "configure cboot"
mounting
sleep 5

echo "configure packages"
packages
sleep 5

echo "configure network"
network
sleep 5

echo "configure tampilan"
tampilan
sleep

echo "configure host"
hostname
sleep 5

echo "configure time"
timezone
sleep 5


echo "configure user"
username
sleep 5

echo "configure sudo"
sudoers
sleep 5

echo "configure cmd"
cmdline
sleep 5

echo "configure mkinit"
mkinitcpio
sleep 5

echo "configure boot"
boot
sleep 5

}

runscript



boot=sda1
root=sda2
home=sda3

# root partition
function create_root {

mkfs.ext4 -b 4096 $root &&
mount $root /mnt

}

# boot partition 
function create_boot {

mkfs.vfat -F32 -n BOOT $boot &&
mkdir /mnt/boot &&
mount -o uid=0,gid=0,fmask=0077,dmask=0077 $boot /mnt/boot

}

# home partition 
function create_home {

mkfs.ext4 -b 4096 $home &&
mkdir /mnt home &&
mount $home /mnt/home

# packages
function packages {

pacstrap /mnt linux-zen linux-headers linux-firmware-intel intel-ucode iptables-nft bash-complation base base-devel mkinitcpio aria2 fuse git iwd firewalld wget impala neovim &&
genfstab -U /mnt > /mnt/etc/fstab

}

# network
function network {

cp /etc/systemd/network/* /mnt/etc/systemd/network  &&
mkdir /mnt/var/lib/iwd &&
cp /var/lib/iwd /mnt/var/lib/iwd

}


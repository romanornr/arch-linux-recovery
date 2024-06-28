# arch-linux-recovery

Following this guide allows you to safely chroot into your Linux system using a bootable Arch Linux USB. If you have any doubts about the integrity of the pre-installed USB, consider downloading the official Arch Linux ISO from the [Arch Linux website](https://archlinux.org/download/) and creating a bootable USB yourself. Use a tool like [Rufus](https://rufus.ie/) to create a bootable Arch Linux disk.


## Boot from USB

creating a bootable USB yourself. Use a tool like rufus to create a bootable Arch Linux disk.

For partition schemes: While MBR theoretically supports both BIOS and UEFI, its compatibility with UEFI almost always leads to problems. In practice, using MBR with UEFI is generally unreliable. MBR on a UEFI system usually leads to the bootable USB and your system might start to give a taper tantrum. Instead, use GPT for a more stable and compatible setup with modern systems. GPT supports larger disks and more partitions, aligning well with UEFI. So use GPT. 

- **FAT32**:
  - **Usage**: Typically used for the EFI System Partition on GPT-partitioned disks.
  - **Compatibility**: Widely supported across different operating systems and firmware.
  - **Recommendation**: Use FAT32 for the EFI System Partition to ensure compatibility with UEFI firmware.


1. **Insert the USB**:
   - Insert the Arch Linux USB into your computer, laptop, or any device running your broken Arch Linux system.

2. **Restart and Boot**:
   - Restart your device and boot from the USB. You may need to change the boot order in your BIOS/UEFI settings to prioritize the USB drive. You know the drill right, turn off fastboot or safeboot in your bios.

## How to identify root and boot partitions

To know which partition is your root partition (`/`) and which is your boot partition (`/boot`)

1. **Check Filesystem Labels and Sizes:**
   - Use `lsblk` with the `-f` option to list filesystems and their labels, which gives more information about the partitions:
     ```bash
     lsblk -f
     ```

2. **Examine Partition Contents:**
   - Mount each partition temporarily and examine their contents. Typically, the root partition (`/`) will contain directories like `bin`, `boot`, `dev`, `etc`, `home`, `lib`, `proc`, `root`, `sbin`, `usr`, `var`, etc. The boot partition (`/boot`) will contain files like `vmlinuz-linux`, `initramfs-linux.img`, and possibly a `grub` directory.

Here's a step-by-step method to identify the partitions:

1. **Mount and Examine Partitions:**
   - Mount `/dev/sda1` and check its contents:
     ```bash
     mount /dev/sda1 /mnt
     ls /mnt
     ```
   - If you see typical root directories, this might be your root partition. If you see only boot-related files, this is your boot partition.
   - Unmount it before trying another:
     ```bash
     umount /mnt
     ```

   - Repeat the process for `/dev/sda2` and other partitions if necessary.

Example of checking which partition is the root and boot:

```bash
# Mount the partition
mount /dev/sda1 /mnt
# List the contents
ls /mnt
# Unmount after examination
umount /mnt

# Repeat for other partitions
mount /dev/sda2 /mnt
ls /mnt
umount /mnt
```

2. **Identify Typical Root and Boot Partition Contents:**
   - **Root Partition**: Will have a comprehensive directory structure including `etc`, `var`, `usr`, `home`, `root`, etc.
   - **Boot Partition**: Typically has files like `vmlinuz-linux`, `initramfs-linux.img`, and a `grub` directory.

3. **Use `blkid` Command:**
   - The `blkid` command can provide more detailed information about each partition, such as labels and UUIDs:
     ```bash
     blkid
     ```

4. **Examine `/etc/fstab` (if accessible):**
   - If you can access the `/etc/fstab` file of your installed system, it lists the partitions and their mount points. You can do this by mounting the root partition and inspecting the file:
     ```bash
     mount /dev/sda2 /mnt  # Assuming /dev/sda2 is your root partition
     cat /mnt/etc/fstab
     umount /mnt
     ```

By carefully with the contents of each partition and using these commands, you can accurately see which partition is the root and which is the boot partition. Once identified, you can proceed with mounting the partitions correctly.


## Mount root and boot partition


1. **Mount the root filesystem:**
   - Once you are in the Arch Linux live environment, you need to mount the root partition of your installed Linux system. First, identify the partition using `lsblk` or `fdisk -l`. For example, if your root partition is `/dev/sda3`, you would mount it like this:
     ```bash
     mount /dev/sda3 /mnt
     ```

2. **Mount the boot partition:**
   ```bash
   mount /dev/sda1 /mnt/boot
   ```

3. **Use `arch-chroot` to chroot into your system:**
   ```bash
   arch-chroot /mnt
   ```

## Create bash script to fix system

1. **Create and execute the script:**
   - Save the script to a file, e.g., `fix_system.sh`, and make it executable:
     ```bash
     nano /root/fix_system.sh  # Use your preferred text editor
     ```
2. **Paste or type out the script content into the file and save it.**

3. **Make the script executable and run it:**
     ```bash
     chmod +x /root/fix_system.sh
     /root/fix_system.sh
     ```

## Exit chroot environment and unmount partitions

1. **Exit the chroot environment:**
   ```bash
   exit
   ```

6. **Unmount the partitions:**
   ```bash
   umount /mnt/boot
   umount /mnt
   ```

7. **Reboot your system:**
   ```bash
   reboot
   ```


##  Script reference 

Here’s the final script for reference:

```bash
#!/bin/bash
# Script to backup, reinstall all packages, and update the system

# Backup the current list of installed packages
echo "Backing up the current list of installed packages..."
pacman -Qqe > /root/package_list_backup.txt

# Reinstall all packages
echo "Reinstalling all packages..."
pacman -Qnq | pacman -S --noconfirm -

# Update the system
echo "Updating the system..."
pacman -Syu --noconfirm

# Regenerate the initramfs image
echo "Regenerating the initramfs image..."
mkinitcpio -P

echo "All done! The list of installed packages has been backed up to /root/package_list_backup.txt. Please exit chroot, unmount the boot partition first, boot partition after and reboot."
```

By using `arch-chroot`, you ensure that the chroot environment is set up correctly and that you can focus on running your maintenance script without worrying about manually mounting all necessary filesystems.
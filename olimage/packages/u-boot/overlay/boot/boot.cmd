# Print boot source
itest.b *0x10028 == 0x00 && echo "U-boot loaded from SD"
itest.b *0x10028 == 0x02 && echo "U-boot loaded from eMMC or secondary SD"
itest.b *0x10028 == 0x03 && echo "U-boot loaded from SPI"

echo "Boot script loaded from ${devtype}"

# Get partuuid
if test "${devtype}" = "mmc"; then part uuid mmc ${mmc_bootdev}:{{ partitions.root }} partuuid; fi

# Set bootargs
setenv bootargs "root=PARTUUID=${partuuid} rootwait{% for key, value in bootargs.items() %} {{ key }}={{ value }}{% endfor %}"

# Load kernel.itb
load mmc ${mmc_bootdev}:{{ partitions.boot }} {{ fit.load }} {% if partitions.boot == partitions.root %}/boot/{% endif %}{{ fit.file }}
bootm {{ fit.load }}

# Recompile with:
# mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr
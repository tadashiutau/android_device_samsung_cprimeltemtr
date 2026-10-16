# Inherit from common
include device/samsung/coreprimelte-common/BoardConfigCommon.mk

LOCAL_PATH := device/samsung/cprimeltemtr

# Asserts
TARGET_OTA_ASSERT_DEVICE := cprimeltemtr,coreprimeltemtr

# Init (adds the SM-G360T1 bootloader prefix; overrides the common file)
TARGET_LIBINIT_MSM8916_DEFINES_FILE := $(LOCAL_PATH)/init/init_cprimeltemtr.cpp

# Kernel
TARGET_KERNEL_VARIANT_CONFIG := msm8916_sec_rossa_tmo_defconfig

# Partition sizes (read from the SM-G360T1 eMMC: boot p16, recovery p17, system p25, cache p26, userdata p27)
BOARD_BOOTIMAGE_PARTITION_SIZE      := 13631488
BOARD_RECOVERYIMAGE_PARTITION_SIZE  := 15728640
BOARD_SYSTEMIMAGE_PARTITION_SIZE    := 1887436800
# userdata minus 16 KiB for the encryption footer
BOARD_USERDATAIMAGE_PARTITION_SIZE  := 5423198208
DEVICE_CACHEIMAGE_PARTITION_SIZE    := 314572800

# Properties
TARGET_SYSTEM_PROP += $(LOCAL_PATH)/system.prop

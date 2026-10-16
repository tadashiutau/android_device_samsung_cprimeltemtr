# The SM-G360T1 has no NFC controller and no CDMA radio
CPRIME_HAS_NFC := false
CPRIME_HAS_CDMA := false

$(call inherit-product-if-exists, vendor/samsung/cprimeltemtr/cprimeltemtr-vendor.mk)
$(call inherit-product, device/samsung/coreprimelte-common/device-common.mk)

LOCAL_PATH := device/samsung/cprimeltemtr

DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

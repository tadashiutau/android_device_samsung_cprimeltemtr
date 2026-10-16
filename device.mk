#Inherit from vendor
$(call inherit-product-if-exists, vendor/samsung/coreprimeltespr/coreprimeltespr-vendor.mk)

# Inherit from common
$(call inherit-product, device/samsung/coreprimelte-common/device-common.mk)

LOCAL_PATH := device/samsung/coreprimeltespr

# Common overlay
DEVICE_PACKAGE_OVERLAYS += device/samsung/coreprimeltespr/overlay

# NFC configs
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/configs/nfc/nfcee_access.xml:system/etc/nfcee_access.xml \
	$(LOCAL_PATH)/configs/nfc/libnfc-sec-hal.conf:system/etc/libnfc-sec-hal.conf \
	$(LOCAL_PATH)/configs/nfc/libnfc-sec.conf:system/etc/libnfc-brcm.conf

# Inherit from common
$(call inherit-product, device/samsung/coreprimelte-common/lineage.mk)

$(call inherit-product, device/samsung/cprimeltemtr/device.mk)

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := cprimeltemtr
PRODUCT_NAME := lineage_cprimeltemtr
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-G360T1
PRODUCT_MANUFACTURER := samsung
PRODUCT_CHARACTERISTICS := phone

PRODUCT_GMS_CLIENTID_BASE := android-samsung

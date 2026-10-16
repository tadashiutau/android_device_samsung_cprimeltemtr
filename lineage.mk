
# Inherit from common
$(call inherit-product, device/samsung/coreprimelte-common/lineage.mk)

$(call inherit-product, device/samsung/coreprimeltespr/device.mk)

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := coreprimeltespr
PRODUCT_NAME := lineage_coreprimeltespr
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-G360P
PRODUCT_MANUFACTURER := samsung
PRODUCT_CHARACTERISTICS := phone

PRODUCT_GMS_CLIENTID_BASE := android-samsung

# android_device_samsung_cprimeltemtr

LineageOS 14.1 (Android 7.1.2) device tree for the Samsung Galaxy Core Prime
**SM-G360T1** (MetroPCS). Bootloader / firmware base: `G360T1UVU2AQD1`.

Based on Galaxy-MSM8916's coreprimeltespr (SM-G360P) tree. Same "rossa" board;
this variant uses the TMO board DT (`msm8916-sec-rossatmo-r00`), the SM5504 MUIC,
the SR544 / SR200PC20 cameras, GSM/WCDMA/LTE radio and no NFC.

| | |
|---:|:---|
| SoC | Qualcomm MSM8916 (Snapdragon 410), 32-bit userspace (armeabi-v7a) |
| GPU | Adreno 306 |
| RAM | 1 GB |
| Storage | 8 GB eMMC |
| Display | 480 x 800, 4.5" (SC7798A panel) |
| Cameras | 5 MP SR544 rear, 2 MP SR200PC20 front |
| SIM | 1x micro-SIM (no eSIM) |
| Shipped | Android 5.1.1 |

## Status

| Area | State |
|---|---|
| Boot, display, touch, setup wizard | Working |
| Wi-Fi | Working (connects, gets an address) |
| Modem / RIL | Starts, baseband reported, searching for networks; calls/SMS/data not yet tested with a SIM |
| Camera | Preview and 2576 x 1932 JPEG capture work; preview banding/color and capture exposure/focus still need work |
| Memory | 512 MiB zRAM verified active after reboot |
| Google apps / authentication | ARM Android 7.1 Open GApps pico installed without wiping data; user confirmed TikTok Lite and ChatGPT login |
| Audio, sensors, GPS, Bluetooth | Not yet tested |

### Bring-up validation

The Rossa camera kernel ABI was adjusted to match the legacy vendor blobs.
Boot image builds and 32-bit ISP/actuator layout comparisons passed. The camera
now opens and saves JPEGs, and a lens-position I2C write succeeded during testing.
Earlier autofocus timeouts and the remaining image-quality issues mean camera
support is still partial.

zRAM is enabled in this device's system properties. The common fstab specifies
536870912 bytes, matching the existing post-boot script; the previous 25% pool
filled during Google apps startup. After a full reboot, `/proc/swaps` reported
524284 KiB on `/dev/block/zram0`. The Rossa kernel configuration also disables
the input event debugger, which otherwise opens input devices and floods logs
with accelerometer events.

Google apps and Brave were installed separately on the test phone; their APKs
are not bundled in the ROM source. Successful login was confirmed by the user.

## Repositories

Use the local manifest from
[tadashiutau/local_manifests](https://github.com/tadashiutau/local_manifests) (branch `lineage-14.1`).
It pulls this tree plus forks of `coreprimelte-common`, the MSM8916 kernel and
`proprietary_vendor_samsung` with the changes this device needs.

## Building

LineageOS 14.1 needs an Ubuntu 18.04-era host (OpenJDK 8, Python 2). A Docker
image works; two things the build needs inside the container:

- `USER` must be set (Jack's launcher script reads `$USER`).
- Jack fails TLS on newer OpenJDK 8 builds: remove `TLSv1, TLSv1.1` from
  `jdk.tls.disabledAlgorithms` in `java.security`.

```bash
source build/envsetup.sh
brunch lineage_cprimeltemtr-userdebug
```

## Installing without a custom recovery

Samsung's Download mode accepts the raw images, so the ROM can be flashed with
Heimdall (or Odin) directly, with no TWRP step:

```bash
heimdall flash --no-reboot \
    --BOOT boot.img --RECOVERY recovery.img \
    --SYSTEM system.img --USERDATA userdata.img --CACHE cache.img
```

`USERDATA` wipes internal storage. Bootloaders, modem, EFS (IMEI and carrier
unlock state), PERSIST and the partition table are not touched.

## Known quirks

### The bootloader sticks to recovery after any recovery boot

After this phone has booted into a recovery (TWRP or LineageOS recovery), the
Samsung bootloader keeps choosing recovery on every following power-on. The kernel
command line then shows `androidboot.boot_recovery=1`, even after a full power-off
and a battery pull.

What was ruled out:
- No `boot-recovery` bootloader message exists on any partition (the device has no
  `misc` partition; `fota` is empty at offset 0).
- The `param` sec_param restart reason is 0; the PMIC reports a plain power-key cold
  boot; IMEM restart_reason is 0; no keys are held.
- Recovery's own "Reboot system now" does not clear it.

What clears it: **any Download-mode session that ends with Heimdall's reboot**,
even a read-only one:

```bash
# phone in Download mode (Vol Down + Home + Power, then Vol Up)
heimdall print-pit
```

The phone then boots Android normally (`androidboot.boot_recovery=0`). Reboots
started from Android do not set the state; only recovery boots do. The state is
probably held in the 16 bytes that change at the end of `param` (offset `0x9ffc00`),
which look encrypted.

After flashing with Heimdall, Samsung's bootloader also boots recovery once before
the first normal boot.

### Boot image tags offset

`msm8916-common`'s custom `mkbootimg.mk` does not pass `BOARD_KERNEL_TAGS_OFFSET`, so
images get mkbootimg's default tags address (`0x80000100`). The ~160 KiB DTB placed
there would overlap the kernel at `0x80008000`. `BoardConfig.mk` passes
`--tags_offset` explicitly so boot and recovery use `0x81e00000`, like stock.

### Blob and RIL fixes

- `libdiag`, `libdsutils`, `libidl`, `libqcci_legacy` and several camera libraries
  must be in the blob list; without `libdiag`, `rild`, `qmuxd`, `time_daemon` and the
  camera daemon fail to link and crash-loop, which also left the screen black after boot.
- `init.qcom.rc` shims `libril.so` with `libril_shim.so`, but nothing in the common
  trees builds it into the image; `device.mk` adds it.
- The data stack (`netmgrd`, `qmuxd`, `libnetmgr`, `libconfigdb`, `librmnetctl`) comes
  from this device's own 5.1.1 firmware: msm8916-common's newer `netmgrd` needs
  `ds_system_call3` from a newer `libdsutils` than this firmware has.

### Display tint

LineageOS's LiveDisplay defaults to Automatic, which tints the screen orange in the
evening. Change it under Settings > Display > LiveDisplay.

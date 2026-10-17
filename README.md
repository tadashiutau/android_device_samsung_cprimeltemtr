<div align="center">

# 📱 Galaxy Core Prime · LineageOS 14.1

**Device tree for the Samsung Galaxy Core Prime SM-G360T1 (MetroPCS) — codename `cprimeltemtr`**

![Android](https://img.shields.io/badge/Android-7.1.2-3DDC84?logo=android&logoColor=white)
![LineageOS](https://img.shields.io/badge/LineageOS-14.1-167C80?logo=lineageos&logoColor=white)
![SoC](https://img.shields.io/badge/SoC-Snapdragon%20410-3253DC?logo=qualcomm&logoColor=white)
![Status](https://img.shields.io/badge/status-bring--up-orange)
![Built with AI](https://img.shields.io/badge/built%20with-AI-8A2BE2)

</div>

---

> [!NOTE]
> This port was made by AI.

> [!WARNING]
> Flashing custom firmware can brick your phone and wipes your data. Back up EFS
> (IMEI and carrier-unlock state) first. No warranty of any kind.

## ✨ At a glance

| | |
|---:|:---|
| **Device** | Samsung Galaxy Core Prime SM-G360T1 (MetroPCS / T-Mobile "Rossa" board) |
| **SoC** | Qualcomm MSM8916 (Snapdragon 410), 32-bit userspace (armeabi-v7a) |
| **GPU** | Adreno 306 |
| **RAM / storage** | 1 GB / 8 GB eMMC |
| **Display** | 4.5" 480 × 800 (SC7798A panel) |
| **Cameras** | 5 MP SR544 rear · 2 MP SR200PC20 front |
| **SIM** | 1× micro-SIM (no eSIM) |
| **Stock firmware** | Android 5.1.1, `G360T1UVU2AQD1` |

Based on Galaxy-MSM8916's `coreprimeltespr` (SM-G360P) tree. Same "Rossa" board, but
this variant uses the TMO board DT (`msm8916-sec-rossatmo-r00`), the SM5504 MUIC, the
SR544 / SR200PC20 cameras, a GSM/WCDMA/LTE radio, and no NFC.

## 🚦 Status

| Area | State |
|---|---|
| Boot, display, touch, setup | ✅ Working |
| Wi-Fi | ✅ Working |
| Memory | ✅ 512 MiB zRAM, verified active after reboot |
| Apps | ✅ Open GApps pico (ARM, 7.1); TikTok Lite and ChatGPT sign-in confirmed |
| Modem / RIL | 🟡 Radio stack runs and reports baseband; calls, SMS and data untested (no SIM yet). VoLTE is unlikely without Samsung's IMS stack, which matters on T-Mobile now that 2G/3G are gone |
| Camera | 🟡 Stills work (2576 × 1932 JPEG). Preview shows an orange tint and a vertical stripe; a fix is committed but **not yet tested**. Autofocus and exposure still need work |
| Audio, sensors, GPS, Bluetooth | ⚪ Not tested yet |

## 📦 Getting the source

Everything is pulled by one local manifest:
[**tadashiutau/local_manifests**](https://github.com/tadashiutau/local_manifests) (branch `lineage-14.1`).

| Path | Repository | Branch |
|---|---|---|
| `device/samsung/cprimeltemtr` | [this repo](https://github.com/tadashiutau/android_device_samsung_cprimeltemtr) | `lineage-14.1` |
| `device/samsung/coreprimelte-common` | [tadashiutau/android_device_samsung_coreprimelte-common](https://github.com/tadashiutau/android_device_samsung_coreprimelte-common) | `cprimeltemtr-14.1` |
| `device/samsung/msm8916-common` | [tadashiutau/android_device_samsung_msm8916-common](https://github.com/tadashiutau/android_device_samsung_msm8916-common) | `cprimeltemtr-14.1` |
| `kernel/samsung/msm8916` | [tadashiutau/android_kernel_samsung_msm8916](https://github.com/tadashiutau/android_kernel_samsung_msm8916) | `cprimeltemtr-14.1` |
| `vendor/samsung` | [tadashiutau/proprietary_vendor_samsung](https://github.com/tadashiutau/proprietary_vendor_samsung) | `cprimeltemtr-14.1` |

```bash
repo init -u https://github.com/LineageOS/android.git -b cm-14.1 --depth=1
mkdir -p .repo/local_manifests
curl -L -o .repo/local_manifests/cprimeltemtr.xml \
  https://raw.githubusercontent.com/tadashiutau/local_manifests/lineage-14.1/cprimeltemtr.xml
repo sync -c --no-tags --no-clone-bundle
# The WebView prebuilts live in Git LFS:
for a in arm arm64 x86 x86_64; do (cd external/chromium-webview/prebuilt/$a && git lfs pull); done
```

## 🔨 Building

LineageOS 14.1 wants an Ubuntu 18.04-era host (OpenJDK 8, Python 2). A Docker container
works well. Two things it needs:

- **`USER` must be set.** Jack's launcher script reads `$USER`, which Docker doesn't set.
- **Jack fails TLS on newer OpenJDK 8.** Remove `TLSv1, TLSv1.1` from
  `jdk.tls.disabledAlgorithms` in `java.security`.

```bash
source build/envsetup.sh
brunch lineage_cprimeltemtr-userdebug
```

## ⚡ Installing (no custom recovery needed)

Samsung's Download mode accepts the raw images, so you can flash straight from
[Heimdall](https://git.sr.ht/~grimler/Heimdall) (or Odin), with no TWRP step:

```bash
# Phone in Download mode: Volume Down + Home + Power, then Volume Up
heimdall flash --no-reboot \
    --BOOT boot.img --RECOVERY recovery.img \
    --SYSTEM system.img --USERDATA userdata.img --CACHE cache.img
```

Then pull the battery and power on. The first boot takes several minutes.

- `USERDATA` **wipes internal storage** (the SD card is not touched).
- Bootloaders, modem, EFS (IMEI and carrier-unlock state), PERSIST and the partition
  table are left alone.
- After a Heimdall flash, Samsung's bootloader boots recovery once before the first
  normal boot. See below.

## 🧩 Known quirks

<details>
<summary><b>The bootloader keeps booting recovery after any recovery boot</b></summary>

After the phone boots into any recovery (TWRP or LineageOS recovery), the Samsung
bootloader keeps choosing recovery on every power-on. The kernel command line shows
`androidboot.boot_recovery=1`, even after a full power-off **and** a battery pull.

**What clears it:** any Download-mode session that ends with Heimdall's reboot, even a
read-only one:

```bash
# Phone in Download mode
heimdall print-pit
```

The phone then boots Android normally (`androidboot.boot_recovery=0`). Reboots started
from Android don't trigger this; only recovery boots do.

**What was ruled out:**
- No `boot-recovery` bootloader message exists on any partition (there's no `misc`
  partition, and `fota` is empty at offset 0).
- The `param` restart reason is 0, the PMIC reports a plain power-key cold boot, the IMEM
  restart reason is 0, and no keys are held.
- Recovery's own "Reboot system now" doesn't clear it.

The state is probably held in the 16 bytes that change at the end of `param` (offset
`0x9ffc00`), which look encrypted.

</details>

<details>
<summary><b>Boot image tags offset</b></summary>

`msm8916-common`'s custom `mkbootimg.mk` never passes `BOARD_KERNEL_TAGS_OFFSET`, so
images got mkbootimg's default tags address (`0x80000100`). The ~160 KiB device tree
placed there would run into the kernel at `0x80008000`. `BoardConfig.mk` passes
`--tags_offset` explicitly, so boot and recovery use `0x81e00000`, like stock.

</details>

<details>
<summary><b>Blobs, RIL and the data stack</b></summary>

- `libdiag`, `libdsutils`, `libidl`, `libqcci_legacy` and several camera libraries must
  be in the blob list. Without `libdiag`, `rild`, `qmuxd`, `time_daemon` and the camera
  daemon fail to link and crash-loop, which also left the screen black after boot.
- `init.qcom.rc` shims `libril.so` with `libril_shim.so`, but nothing in the common trees
  built it into the image. `device.mk` adds it.
- The data stack (`netmgrd`, `qmuxd`, `libnetmgr`, `libconfigdb`, `librmnetctl`) comes from
  this device's own 5.1.1 firmware. `msm8916-common`'s newer `netmgrd` needs
  `ds_system_call3` from a newer `libdsutils` than this firmware has.

</details>

<details>
<summary><b>Camera</b></summary>

- **Kernel ABI:** the Rossa camera interfaces (ISP event numbers, CAMIF config, frame-skip
  patterns, actuator config) are set back to the layout the Lollipop camera blobs were
  built against. This was checked field by field against Samsung's own G360T1 kernel
  headers. With it, the camera opens, saves JPEGs, and moves the lens. Autofocus
  sometimes times out.
- **Preview tint and stripe:** `msm8916-common`'s camera wrapper forces
  `preview-format=yuv420p` for previews up to 720 × 720. This device's camera blob fills
  those buffers with a layout gralloc's YV12 doesn't expect. `BoardConfig.mk` sets
  `TARGET_CAMERA_KEEP_PREVIEW_FORMAT := true` so the HAL keeps its own preview format.
  *Not yet verified on the phone.*

</details>

<details>
<summary><b>Memory (zRAM)</b></summary>

`ro.config.zram=true` turns on compressed swap. The common fstab now uses 512 MiB, the
same as the post-boot script. The old 25% pool filled up while Google apps started.
After a full reboot, `/proc/swaps` shows 524284 KiB on `/dev/block/zram0`. The Rossa
kernel config also turns off the input event debugger, which otherwise floods the log
with accelerometer events.

</details>

<details>
<summary><b>Orange screen in the evening</b></summary>

That's LineageOS's LiveDisplay night mode, which defaults to Automatic. Change it under
**Settings → Display → LiveDisplay**.

</details>

## 🐧 Looking for mainline Linux instead?

This board already has upstream support as `samsung,rossa`
(`msm8916-samsung-rossa.dts`), so **postmarketOS** is the other road. It runs a modern
kernel instead of Samsung's 3.10, though it's not Android. What's still missing upstream
for this exact model: a proximity sensor node, the RT5033 flash LED driver, and drivers
for both camera sensors.

## 🙏 Credits

- [LineageOS](https://lineageos.org) — the OS itself
- [Galaxy-MSM8916](https://github.com/Galaxy-MSM8916) — the MSM8916 / Core Prime trees and kernel this port builds on
- [TeamWin](https://twrp.me) — TWRP, used during bring-up
- Samsung — kernel source, and the stock firmware the blobs come from

<sub>Proprietary blobs are extracted from Samsung's stock firmware and belong to their
respective owners.</sub>

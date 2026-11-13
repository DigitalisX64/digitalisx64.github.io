---
title: "Five more projects using Digitalis"
summary: "Android 17 on a laptop, a Windows app desktop, and three Linux runtimes"
---

OpenBook ships Digitalis in its Android 17 images. DSA makes it the default in its Windows
x64 image. PenguDroid reports an ARM64 game running on it. Shiraz has a developer build and
smoke test, but its AppImage does not include Digitalis yet. apklayer builds Digitalis into
its x86_64 native-bridge path and reports several ARM64 checks passing, though game
compatibility remains incomplete. We have not run these projects; the links below go to
their own notes.

## Android 17 on a laptop

### OpenBook: an Android desktop on the G14

[OpenBook](https://github.com/Mhsbrian/OpenBook) is an Android 17 desktop build for x86_64
laptops; its first hardware target is the ASUS ROG Zephyrus G14. Its
[Digitalis notes](https://github.com/Mhsbrian/OpenBook/blob/main/docs/digitalis.md) say the
source-built bridge ships in both the generic x86_64 image and the G14 image. Their test run
on Cuttlefish passed 14 of 16 ARM-only apps. Separately, ARM64 Chromium renders on the G14.

<figure class="post-figure">
  <img src="https://raw.githubusercontent.com/Mhsbrian/OpenBook/main/assets/readme/hero-light.jpg"
       alt="OpenBook branding beside a laptop showing its Android 17 installer"
       loading="lazy">
  <figcaption>OpenBook's repository banner, featuring its laptop installer.
  From <a href="https://github.com/Mhsbrian/OpenBook/blob/main/assets/readme/hero-light.jpg">the OpenBook repository</a>.</figcaption>
</figure>

OpenBook pins three Digitalis projects in a
[manifest](https://github.com/Mhsbrian/OpenBook/blob/main/manifests/digitalis/digitalis-pinned.xml)
and builds them against its Android 17 tree. Its port fixes ARM ID-register reads,
`FRECPE`/`FRSQRTE` accuracy and the `Build.CPU_ABI` value reported to translated apps. The
matching guest libraries come from the same Android 17 tree. OpenBook is still pre-alpha;
the 14-of-16 app result is from Cuttlefish. On the G14, its notes report Chromium and probe
checks, but not an ARM64 app in an enforcing boot.

## Android apps in Windows

### Desktop Subsystem for Android: an open WSA-shaped system

[Desktop Subsystem for Android](https://github.com/thisisthepy/desktop-subsystem-for-android)
(DSA) runs Android apps in separate Windows windows, with taskbar, input and host-device
integration. Digitalis is the default translator in its Windows 11 x64 image; ARM64 Windows
hosts do not need translation for ARM64 apps.

<figure class="post-figure">
  <img src="https://raw.githubusercontent.com/thisisthepy/desktop-subsystem-for-android/main/docs/site/og.png"
       alt="DSA's social-preview artwork, with the title Desktop Subsystem for Android and an exploded-device illustration"
       loading="lazy">
  <figcaption>DSA's repository social-preview artwork.
  From <a href="https://github.com/thisisthepy/desktop-subsystem-for-android/blob/main/docs/site/og.png">the DSA repository</a>.</figcaption>
</figure>

The [build guide](https://github.com/thisisthepy/desktop-subsystem-for-android/blob/main/dsa/guest/arm-translation/README.md)
shows CI building Digitalis for Android 16 and 17 from pinned revisions, then putting the
package in the x64 image. Users can switch translators or turn translation off. The Windows
releases are previews; Linux and macOS are not released.

## Android apps on Linux, without a full Android system

### Shiraz: ART and Android APIs on the host

[Shiraz](https://github.com/spectre-oss/shiraz) hosts Android's ART runtime and maps Android
APIs onto Linux instead of booting a full Android system. Its
[developer instructions](https://github.com/spectre-oss/shiraz/blob/main/README.md) build
Digitalis and the host-side proxies, select the bridge with `SHIRAZ_DIGITALIS_LIBRARY`, and
run a platform smoke test. The build scripts pin the Digitalis source.

<figure class="post-figure">
  <img src="https://raw.githubusercontent.com/spectre-oss/shiraz/main/landing/src/lib/social-card.svg"
       alt="Shiraz's dark social banner, reading Your Android apps. A little more at home."
       loading="lazy">
  <figcaption>Shiraz's repository social card.
  From <a href="https://github.com/spectre-oss/shiraz/blob/main/landing/src/lib/social-card.svg">the Shiraz repository</a>.</figcaption>
</figure>

Shiraz says Digitalis is not wired into its AppImage packager. This is a developer
integration, not something users get by downloading the app. Shiraz is also experimental and
does not sandbox APKs; they run with the Linux user's permissions.

### PenguDroid: ARM64 games as Linux processes

[PenguDroid](https://github.com/denizomer10/PenguDroid) is a Rust Linux compatibility layer:
Android apps run without a VM, container or booted `system.img`. Its
[status report](https://github.com/denizomer10/PenguDroid/blob/main/docs/STATUS.md) says an
ARM64-only build of Beach Buggy Racing 2 reaches gameplay; NewPipe runs through ART.

The [translator notes](https://github.com/denizomer10/PenguDroid/blob/main/docs/LIMITATIONS.md#24-where-the-translator-stops-precisely)
say it builds `libberberis_arm64.so` from pinned Digitalis sources and stages the matching
ARM64 guest runtime. They describe the guest-linker and TLS fixes that got the game running.
Broader ARM64 coverage remains unfinished. One wrinkle: PenguDroid's README still names
Intel's NDK translator; its newer technical notes and status report name Digitalis.

### apklayer: an x86_64 native bridge on the host

[apklayer](https://github.com/erfanoabdi/apklayer) runs Android apps on Linux without a VM.
Its x86_64 host loads Android's native libraries with a patched `bionic_translation`; for
ARM64-only app libraries, it also builds Digitalis as Android's NativeBridge and stages the
matching guest linker and libraries. The project's
[x86_64 notes](https://github.com/erfanoabdi/apklayer/blob/main/docs/X86_64.md#arm64-only-apps-native-bridge-digitalis)
describe the bridge callbacks and the glibc/Bionic integration work.

The notes report `hello-arm64`, Nextcloud's start screen and OTR2 running through the bridge;
a Vulkan swapchain test presented 600 frames. This is active development, not broad app
compatibility: PGR still shows rendering corruption and later aborts, while Endfield traps
before its first frame. The project is working through those failures with recorded changes
to Digitalis and its supporting native-bridge code.

OpenBook and DSA need guest libraries built for their Android releases. On Linux, Digitalis
has to work with the host's libc, linker and graphics stack as well. Those are different
problems from translating instructions, and the projects expose the seams we need to keep
stable.

We have not run these projects. Questions about them belong with their maintainers; if a bug
comes down to ARM64 translation, we want to hear about it. Digitalis is Apache-2.0, and that
licence governs use of our code.

## Names and trademarks

Digitalis is not affiliated with, endorsed by or sponsored by any of the companies or
projects named in this post, and nothing here is a claim on their names or their software.

- Android is a trademark of Google LLC.
- Windows is a trademark of Microsoft Corporation.
- macOS is a trademark of Apple Inc.
- Linux is a registered trademark of Linus Torvalds in the U.S. and other countries.
- Any other product or company name used here is used only to identify the thing it names.

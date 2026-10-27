---
title: "Eight projects building on Digitalis"
summary: "Windows VR shells, Android in Wayland, and a LoongArch64 backend"
---

Digitalis is Apache-2.0. Anyone can take it, ship it and build on it without asking us, and
that is the whole point of releasing it. We came across a couple of these by chance on
GitHub, then went looking for the rest. There turned out to be more of them than we expected,
doing stranger things with the translator than we had planned for.

Eight, in the end, with about 870 stars between them against our two dozen. Two of them run
Digitalis outside Android entirely, as a plain Windows library. One runs it on a host CPU we
have never built for.

None of these are ours. We have not run any of them. Everything below is quoted from their
own repositories, so you can check it.

## VR and games on the desktop

### Prism: Meta's Horizon OS on a PC

[Prism](https://github.com/MIXIDtheSilly/Prism) is an experimental Horizon OS emulator for
Windows. Meta's own system software, the home environment, system UI, panels and apps, running
on a PC in a desktop window and through SteamVR. It boots to Meta's home environment, opens
the Universal Menu and launches apps.

Essentially all of that is translated code. From its architecture notes:

> Meta apps (VrShell, SystemUX, ...) — Horizon APKs, arm64 code translated to x86_64
>
> Meta native daemons — Horizon arm64 binaries, translated

including "Meta's OpenXR runtime and compositor".

The translator is ours. What interests us is the work they had to do to use it. Prism's base
is Android 14 and we build on Android 16, so their tree carries `tools/translator.py`, which
"adapts the Digitalis ARM64 translator to Prism's Android 14 base", and
`native/berberis_compat/`, which supplies "symbols the Android 16 translator build needs from
Android 14".

### Refract: Quest games on a PC, on our binary distribution

[Refract](https://github.com/MIXIDtheSilly/Refract), from the same author as Prism, started
as a fork of AXRB and has since gone its own way. It runs Meta Quest (Android OpenXR) games on
a Windows or Linux PC by three routes: the Android Emulator on Windows, Waydroid on Linux, and
"Refract Native", which it recommends and describes as running "the game's ARM64 code directly
on the PC".

All three translate with Digitalis, which means three builds of it. Two are Android bundles,
because the bionic layout has to match whatever is underneath: `prebuilts/digitalis` for the
Windows emulator's Android 16 QPR0 image, `prebuilts/digitalis-qpr2` for Waydroid on LineageOS
23.2. The third is a Windows library, and it is the interesting one.

> The Digitalis ARM64 translator (Apache-2.0) is included prebuilt in
> [prebuilts/digitalis/](prebuilts/digitalis/).

That is our binary distribution, used as intended, with the provenance recorded down to the
commit. `target-product: sdk_phone64_x86_64_digitalis`, our `binary_translation` and `digitalis`
SHAs, 74 artifacts. The same manifest then records that they did not simply ship what we
built:

> `system/lib64/libberberis_arm64.so` was rebuilt by Refract with
> `digitalis-performance-fix.patch`, `digitalis-block-chaining.patch` and
> `digitalis-return-prediction.patch` applied

Block chaining and call/return prediction are translator work, not integration glue.

Refract Native drops Android altogether. `native/digitalis/` builds the translator core, the
decoder, interpreter, lite translator, heavy optimizer, backend, assembler and translation
cache, with clang-cl against the MSVC ABI, and swaps out the part that cannot cross: in their
words, "Digitalis' Linux layer (signals, threads, syscalls, exec memory) is replaced by
src/*.cpp".

### AXRB: all three tiers as a native Windows adapter

[AXRB](https://github.com/Android-XR-Bridge/AXRB) runs Android-based OpenXR games, Quest-style
APKs rather than Google's Android XR OS, on Windows through a desktop OpenXR runtime such as
SteamVR. Android runs in an x86_64 emulator and rendering goes to the host GPU.

AXRB has a route of the same shape in its own tree. `direct/digitalis/` is a CMake build of
our
optimizing translator, lite translator and interpreter at a pinned commit, with AXRB's own
patches on top and a `compat/berberis/` shim where the Android glue used to be.

> This is a native Windows adapter, not Android NativeBridge.

No NativeBridge and no bionic. AXRB supplies its own process, syscall, memory, framework and
graphics layers, shared between both CPU backends. An `entry.asm` preserves the Windows
nonvolatile registers around generated code, and unmapped guest accesses return through AXRB's
signal handling. Dynarmic, an ARM dynamic recompiler, stays their default; ours is
selectable with `AXRB_DIRECT_TRANSLATOR=digitalis`.

They kept the testing honest while porting. The CMake build runs the native self-test
"including runs with AVX and block chaining disabled, forced optimization, optimization on the
guest thread, and the lite tier alone", plus a differential test against the interpreter.
Unsupported lite-JIT instructions fall through to our interpreter and "are not silently
delegated to Dynarmic", which is the right call, because a silent fallback would hide
translator bugs.

AXRB also keeps a [comparison document](https://github.com/Android-XR-Bridge/AXRB/blob/main/docs/refract-performance-port.md)
reviewing Refract's optimizations and recording which ones it took. One row:

> Digitalis lite load/store shortcut | Excluded after it crashed
> `Arm64MemoryDifferentialFuzz.TaggedBaseAddressIsIgnored`.

Our own differential fuzzer, catching a bad optimization on its way from one downstream tree
into another.

### AXRB-Linux: the host half aimed at Linux

[AXRB-Linux](https://github.com/goingafk/AXRB-Linux) is a separate repository carrying the
AXRB tree with a different target: "a compatibility layer to run Android OpenXR apps on
Linux". The Android guest and the ARM64 translation stay where they are. What changes is the
host side, where the GPU, the OpenXR session and the headset output now have to come from
Linux instead of Windows.

It is early, and its own tree says so. Roughly a third of AXRB's files, with the README and
most of the scripts still Windows-era, and the Digitalis piece it carries is not the adapter
but the measurement side. `experimental/digitalis/` runs alternating CPU probes over an
emulator, and refuses to run at all unless the AVD is the dedicated test one and
`ro.dalvik.vm.native.bridge` reads `libberberis_arm64.so`. We like that guard. Numbers out of
a harness without one are not worth much.

If it gets as far as the Windows tree has, it would be the first Digitalis-backed OpenXR host
on Linux that does not go through Waydroid.

## Inside Android: emulators, desktops and branches

### Kemu, built on our product target

[Kemu](https://github.com/kuloPo/Kemu) is an open-source, high-performance Android emulator
for Windows, built on AOSP Android 16 and the Android Emulator / QEMU with WHPX acceleration.
Its build instructions give the relationship away in one line:

```sh
lunch sdk_phone64_x86_64_digitalis-trunk_staging-userdebug
```

That is our product target. Around it, Kemu keeps its own trees of the emulator stack: QEMU,
gfxstream, mesa3d, ANGLE, goldfish, the virtual-device kernel modules. Its author is also the
contributor behind our
[heavy-optimizer SVC lowering](https://github.com/DigitalisX64/platform_frameworks_libs_binary_translation/pull/3),
so some of this has already come back to us.

### Droidloom, with Teto doing the translating

[Droidloom](https://github.com/denialwm/droidloom) runs Android apps in separate Linux Wayland
windows, on a shared kernel with a real Android userspace and GPU acceleration. Its repository
description says why translation matters: "running arm64-only apps on x86_64 without closed
source libraries."

The translator lives in its own repository, [Teto](https://github.com/denialwm/teto),
"Translation Engine with Target Optimization", which states it is "derived from DigitalisX64
and AOSP Berberis". Droidloom's
[build guide](https://github.com/denialwm/droidloom/blob/main/docs/BUILDING.md) shows how deep
that goes: builds fetch Teto at a pinned commit, a `--native-bridge-source
/absolute/path/to/digitalis` option builds against a local checkout, the documented setup
keeps `DigitalisX64` as the `upstream` remote, and `droidloom-translation-bench` runs our
`berberis_arm64_host_tests`.

Teto's branch adds Android-compatible memory reservations, FPCR rounding corrections, ARM64
breakpoint and ptrace support, guest JNI function-table isolation, and an
`android-mmap-noreserve` flag driven by `ro.berberis.flags`. Those are glibc-host problems,
the same family as the `glibc-host-thread-id-handoff` flag that reached us from Drion. They
are careful about provenance and honest about maturity: "passing tests and individual app
launches do not establish complete ARM64 architectural correctness."

### berberis-android17, tracking our release branch

This one we found by its source tree, which carries `android_api/digitalis_extra_proxy`.
[`icy-person/berberis-android17`](https://github.com/icy-person/berberis-android17) keeps a
synchronized copy of our translator: its `ARM64_PORT.md` names our `android-latest-release`
branch, the commit it is synchronized to, the seven upstream commits that landed after its
original snapshot, and a `tools/sync-digitalis.sh` helper. The CI initialises our manifest at
that branch, builds and runs `berberis_arm64_host_tests`, and treats a missing test binary as
a failure.

The Android 17 in the name is where it is going; what the tree holds today is a tracked,
CI-gated sync of the branch we ship.

Our own Android 17 port is nearly finished. The tree builds, the sample suite is green, and
the prebuilt app and game gates are running now, so the two efforts should meet in the middle
fairly soon. If you have hit something on 17 that we have not, we would like to know.

### A LoongArch64 backend

This is the one we did not see coming.
[`factfinding/lineage-waydroid-loongarch64`](https://github.com/factfinding/lineage-waydroid-loongarch64)
is a LineageOS 23.2 / Android 16 port to Waydroid on LoongArch64, booting to
`sys.boot_completed=1` on an AOSC OS LoongArch64 host. Its development branch "includes a
region-based ARM64-to-LoongArch64 Lite JIT with interpreter fallback".

Their [fork](https://github.com/factfinding/platform_frameworks_libs_binary_translation/tree/loongarch64/lineage-23.2)
has `enable_arm64_to_loongarch64.mk` sitting next to our `enable_arm64_to_x86_64.mk`. Our
ARM64 frontend, somebody else's host backend, on a CPU we have never built for.

## What we left out

Forks of our own repositories are not on the list. A fork is a starting point rather than a
project to introduce, and a list like this is easy to pad. We did read them, and two of their
authors have sent work back upstream: a
[heavy-optimizer SVC lowering](https://github.com/DigitalisX64/platform_frameworks_libs_binary_translation/pull/3)
and a [set of performance improvements](https://github.com/DigitalisX64/platform_frameworks_libs_binary_translation/pull/4).
Thank you for both.

One of those forks has a product behind it, and it is where the second of those pull requests
came from. Actinis Chimera, announced as "a Native Bridge for Android, in development", keeps
`drion-16` and `perf/gb7` branches beside our release branch, and `perf/gb7` is the branch the
performance work arrived on. The same company makes
[Drion]({% post_url 2026-09-13-drion-runs-android-apps-on-linux-with-digitalis %}), which we
wrote about in September, and the `glibc-host-thread-id-handoff` flag reached us the same
way.

Projects that are still weighing Digitalis up are not on the list either. Whether they adopt
it is theirs to announce, and we would rather write about something once it runs.

## What this changes for us

Most of these run somewhere our gates do not reach. Four of them are on Windows hosts, two in
a Linux desktop session, one on LoongArch64. Our gate is an x86_64 Android emulator on Linux,
so none of that is measured by anything we run.

Our interfaces are load-bearing in places we never planned for, too: the binary distribution
layout Refract ships, the `berberis_*` target names Teto deliberately did not rename, the
`ro.berberis.flags` knobs, the `sdk_phone64_x86_64_digitalis` product target Kemu lunches,
`enable_arm64_to_x86_64.mk` as a template for a second backend, `berberis_arm64_host_tests` as
a bench harness for two separate projects. Those have become contracts, and we should stop
changing them casually.

The usual caveat, the same one we gave for Bass OS and Drion: these are other people's
projects, and questions about them go to them. If a problem narrows down to arm64 translation,
that part is ours and we want to hear about it.

If you are building on Digitalis and would like a link here, we would be glad to add one. You
are under no obligation to tell us anything, though. The licence is there so you can get on
with it.

- Prism: [github.com/MIXIDtheSilly/Prism](https://github.com/MIXIDtheSilly/Prism)
- Refract: [github.com/MIXIDtheSilly/Refract](https://github.com/MIXIDtheSilly/Refract)
- AXRB: [github.com/Android-XR-Bridge/AXRB](https://github.com/Android-XR-Bridge/AXRB)
- AXRB-Linux: [github.com/goingafk/AXRB-Linux](https://github.com/goingafk/AXRB-Linux)
- Kemu: [github.com/kuloPo/Kemu](https://github.com/kuloPo/Kemu)
- Droidloom: [github.com/denialwm/droidloom](https://github.com/denialwm/droidloom) ·
  [Teto](https://github.com/denialwm/teto)
- berberis-android17: [github.com/icy-person/berberis-android17](https://github.com/icy-person/berberis-android17)
- LoongArch64: [github.com/factfinding/lineage-waydroid-loongarch64](https://github.com/factfinding/lineage-waydroid-loongarch64)
- Digitalis source: [github.com/DigitalisX64](https://github.com/DigitalisX64)

## Names and trademarks

Digitalis is not affiliated with, endorsed by or sponsored by any of the companies or
projects named in this post, and nothing here is a claim on their names or their software.

- Android and Android XR are trademarks of Google LLC.
- Meta, Meta Quest and Horizon OS are trademarks of Meta Platforms, Inc.
- Windows is a trademark of Microsoft Corporation.
- SteamVR is a trademark of Valve Corporation.
- LoongArch is a trademark of Loongson Technology Corporation Limited.
- OpenXR is a trademark of The Khronos Group Inc.
- Linux is a registered trademark of Linus Torvalds in the U.S. and other countries.
- LineageOS, Waydroid, AOSC OS and Dynarmic are the marks of their respective projects.
- Any other product or company name used here is used only to identify the thing it names.

The downstream projects above belong to their own authors, under their own licences, and the
quotations are theirs. Digitalis itself is Apache-2.0, and that licence, not this post, is
what governs any use of our code.

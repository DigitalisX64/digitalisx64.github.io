---
title: "Bass OS ships DigitalisX64 in its Android 16 preview"
summary: "The first third-party OS build we know of that integrates Digitalis"
---

[Bass OS](https://bassos.navotpala.tech/), the modular Android distribution built by
Navotpala Tech for x86-64 and ARM hardware, now lists DigitalisX64 as a component of
its Android 16 preview line. From the release listing for **Bass: Lineout (A16)
Desktop**:

> Our Android 16 Lineout builds (Preview) will include our new Linux based installer
> and come with recovery mode (to flash MicroG or Gapps), **DigitalisX64 (ARM64 to
> x86_64 native-bridge solution)**, many bass-addons for configuration and
> customization, as well as on-device documentation.

The build is published as a 3.11 GB x86_64 ISO, version `A16.0.v23.2`, build
`2026073012`, flagged Beta on the Bass OS downloads page.

<figure class="post-figure">
  <img src="https://bassos.navotpala.tech/api/uploads/screenshots/bass-lineout-a16-desktop-20260723-ubpp_1785513539463.png"
       alt="Bass OS Lineout Android 16 desktop with Subway Surfers running in a resizable window" loading="lazy">
  <figcaption>From the Bass: Lineout (A16) Desktop screenshot set on
  <a href="https://bassos.navotpala.tech/#downloads" target="_blank" rel="noopener">bassos.navotpala.tech</a>
  &mdash; Subway Surfers in a desktop window on an x86_64 install. Image &copy; Navotpala Tech.</figcaption>
</figure>

That is a game we track on our own [Verified Apps](/apps.html) page as an
unmodified `arm64-v8a` APK, so it is a fair picture of what the native-bridge path is
for: an ARM64-only app, unrecompiled, in a window on an x86_64 desktop.

## Why this one is interesting to us

Digitalis has so far been exercised where it was written &mdash; on the
`sdk_phone64_x86_64_digitalis` emulator target, against a suite of in-tree samples and
a set of real APKs. A distribution picking the translator up and shipping it in an
installable desktop image is a different kind of test: real x86_64 hardware, a real GPU
stack, a windowed desktop shell, and users who did not build the tree.

To be clear about what this post is and is not: this is Navotpala Tech's build, not
ours. We did not produce it, and we have not run it. Anything that does not work in it
is a question for them first &mdash; though if the cause turns out to be a translation
bug, that is ours to fix, and we would like to hear about it.

- Bass OS downloads: [bassos.navotpala.tech](https://bassos.navotpala.tech/#downloads)
- Bass OS source: [github.com/Bliss-Bass](https://github.com/Bliss-Bass)
- Digitalis source: [github.com/DigitalisX64](https://github.com/DigitalisX64)

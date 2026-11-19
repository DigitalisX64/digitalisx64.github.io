---
title: "Drion runs Android apps on Tesla's MCU stack, with Digitalis translating ARM64"
summary: "Actinis demos Drion on Tesla's x86_64 Linux infotainment software in QEMU"
---

On 18 November, [Actinis](https://actinis.io/) posted a
[one-minute video on X](https://x.com/ActinisHQ/status/2123145456184082460) showing
[Drion](https://actinis.io/drion) running unmodified Android apps inside Tesla's MCU
infotainment software (`2026.26.6.5`). Actinis notes that the clip is not a render, and
that it was recorded on the real MCU software stack emulated in QEMU rather than on
physical vehicle hardware.

<blockquote class="twitter-tweet" data-dnt="true">
  <p lang="en" dir="ltr">Tesla is a truly legendary car, and that&#39;s no news to anyone. But here at Actinis, we&#39;ve noticed that one important thing is still missing... And plenty of Tesla owners would agree, right? We&#39;re talking, of course, about using your favorite mobile apps natively, the way you&#39;re used to. <a href="https://x.com/ActinisHQ/status/2123145456184082460">Watch the demo video on X</a>.</p>
  &mdash; Actinis (@ActinisHQ) <a href="https://x.com/ActinisHQ/status/2123145456184082460">November 18, 2026</a>
</blockquote>
<script async src="https://platform.x.com/widgets.js"></script>

## Launcher and media integration

Android apps sit in the car's own app launcher next to Tesla's built-in apps (the grid
shows Angry Birds 2, Waze, AntennaPod, Instagram, WhatsApp, PlugShare, SpotHero, X and
Conversations). **Twitch** plays a Starship Flight 15 broadcast and **AntennaPod**
plays a podcast (*Houston We Have a Podcast*), with playback state and transport buttons
wired into Tesla's left-side media card.

<figure class="post-figure">
  <img src="{{ '/assets/posts/drion-tesla/launcher.jpg' | relative_url }}"
       alt="Tesla app launcher showing Android apps including Angry Birds 2, Waze, WhatsApp, PlugShare and AntennaPod alongside built-in apps, with Twitch in the left media card"
       loading="lazy">
  <figcaption>Android apps inside Tesla's launcher alongside built-in apps, with Twitch
  in the car's media card. Frame from
  <a href="https://x.com/ActinisHQ/status/2123145456184082460" target="_blank" rel="noopener">@ActinisHQ, 18 November</a>.
  Image &copy; Actinis.</figcaption>
</figure>

## Games in the main pane

**Angry Birds 2** runs live gameplay directly inside the right-hand viewport alongside
the car's status pane and dock.

<figure class="post-figure">
  <img src="{{ '/assets/posts/drion-tesla/angry-birds.jpg' | relative_url }}"
       alt="Angry Birds 2 running live gameplay in the right-hand pane of Tesla's infotainment screen"
       loading="lazy">
  <figcaption>Angry Birds 2 gameplay inside the right-hand screen pane. Frame from
  <a href="https://x.com/ActinisHQ/status/2123145456184082460" target="_blank" rel="noopener">@ActinisHQ, 18 November</a>.
  Image &copy; Actinis.</figcaption>
</figure>

## Gear-driven car mode for navigation

In Park, **OsmAnd** displays its regular phone layout. Shifting into Drive switches
OsmAnd to its simplified car navigation screen without touching the app, and **Waze**
also renders its car navigation screen.

<figure class="post-figure">
  <img src="{{ '/assets/posts/drion-tesla/navigation-car-mode.jpg' | relative_url }}"
       alt="OsmAnd rendering its simplified turn-by-turn car navigation UI in Drive mode beside Tesla's vehicle pane"
       loading="lazy">
  <figcaption>OsmAnd switched automatically into car navigation mode after shifting into
  Drive. Frame from
  <a href="https://x.com/ActinisHQ/status/2123145456184082460" target="_blank" rel="noopener">@ActinisHQ, 18 November</a>.
  Image &copy; Actinis.</figcaption>
</figure>

## Car media browser and driving lockouts

In Drive, **AntennaPod** switches to its car media browser while **Twitch** is blocked
with *"This app isn't available while driving"*. Shifting back into Park restores Twitch
playback automatically.

<figure class="post-figure">
  <img src="{{ '/assets/posts/drion-tesla/driving-lockout.jpg' | relative_url }}"
       alt="Twitch showing This app isn't available while driving in Drive mode while AntennaPod continues playing in Tesla's left media bar"
       loading="lazy">
  <figcaption>Twitch locked out in Drive while AntennaPod remains active in the car's
  media bar. Frame from
  <a href="https://x.com/ActinisHQ/status/2123145456184082460" target="_blank" rel="noopener">@ActinisHQ, 18 November</a>.
  Image &copy; Actinis.</figcaption>
</figure>

## Where Digitalis fits

As covered in [our earlier Drion post](/posts/drion-runs-android-apps-on-linux-with-digitalis/),
Drion runs Android apps directly on Linux without a VM or a full Android OS: a Rust layer
implements Android's system contracts, a hosted ART executes the APK, and **Digitalis**
handles ARM64-to-x86_64 binary translation on Drion's Native Bridge path. That
integration also drove the upstream `glibc-host-thread-id-handoff` runtime flag
([pull request](https://github.com/DigitalisX64/platform_frameworks_libs_binary_translation/pull/2))
so the translator can locate guest thread state on glibc-based Linux hosts.

Tesla's modern infotainment units run x86_64 Linux, so ARM64-only Android apps and games
executing inside Drion on that stack depend on Digitalis to translate their `arm64-v8a`
native libraries to x86_64 at runtime. On our own [Verified Apps](/apps.html) list,
Twitch is tracked as an unmodified `arm64-v8a` APK; running apps like it inside a
non-Android Linux infotainment stack exercises the same translator path outside AOSP's
Bionic and SurfaceFlinger environment.

This demo is Actinis's work, recorded in QEMU rather than on physical car hardware, and
we have not run it. Questions about Drion or the demo go to Actinis; if an issue comes
down to ARM64 translation, that part is ours and we want to hear about it.

- Demo post on X: [@ActinisHQ, 18 November](https://x.com/ActinisHQ/status/2123145456184082460)
- Drion: [actinis.io/drion](https://actinis.io/drion) (`drion@actinis.io`)
- Digitalis source: [github.com/DigitalisX64](https://github.com/DigitalisX64)

## Names and trademarks

Digitalis is not affiliated with, endorsed by or sponsored by Actinis, Tesla or any of
the app developers named above.

- Android is a trademark of Google LLC.
- Linux is a registered trademark of Linus Torvalds in the U.S. and other countries.
- Tesla is a trademark of Tesla, Inc.
- Any other product or company name used here is used only to identify the thing it names.

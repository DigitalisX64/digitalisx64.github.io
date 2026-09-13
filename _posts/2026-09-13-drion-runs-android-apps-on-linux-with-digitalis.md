---
title: "Drion brings Android apps to Linux, with Digitalis translating arm64"
summary: "Actinis' Wine-like Android layer for Steam Deck and Linux desktops, now heading into a Flatpak alpha"
---

[Drion](https://actinis.io/drion), from the Estonian AOSP company
[Actinis](https://actinis.io/), runs Android apps and games directly on Linux. It is not
an emulator, a container of a full Android system, or a VM. Actinis describes it as
"a Wine-like Android compatibility platform": apps keep the contracts they expect
(Binder, activities, services, intents, notifications), the system side is reimplemented
in Rust, and a hosted ART runs the APK. Each app is a sandboxed Linux process with its
own Wayland window, and gets host audio, clipboard and notifications.

Drion's developers have confirmed to us that its arm64-to-x86_64 translation uses
Digitalis. On an x86_64 machine, an arm64-only Android app runs through Drion's Native
Bridge path, and Digitalis executes that app's native code. The work has flowed back
upstream too: the opt-in `glibc-host-thread-id-handoff` runtime flag, which lets the
translator find each thread's guest state when the host C library is glibc rather than
bionic, came from the Drion project ([pull request](https://github.com/DigitalisX64/platform_frameworks_libs_binary_translation/pull/2);
see [runtime flags](https://github.com/DigitalisX64/digitalis/blob/android-latest-release/docs/integrating-digitalis.md)).

## What Actinis has shown so far

Actinis introduced Drion on 29 July with a Steam Deck, a Steam Machine, Ubuntu Touch and
the Linux desktop as targets, and a short pitch:

> No full Android OS. No Waydroid. No VM. Deep host integration.
> Drion. Android apps, Linux-shaped. Coming this year.

<figure class="post-figure">
  <img src="https://pbs.twimg.com/media/HObmcRhWwAABWnP.jpg?name=medium"
       alt="A Steam Deck showing a grid of Android apps and games, including Genshin Impact, CSR Racing 2, Roblox and Twitch, next to a phone playing YouTube"
       loading="lazy">
  <figcaption>Drion's app grid on a Steam Deck, with controller hints, next to a phone.
  From <a href="https://x.com/ActinisHQ/status/2082606212336566513" target="_blank" rel="noopener">@ActinisHQ, 29 July</a>.
  Image &copy; Actinis.</figcaption>
</figure>

Since then they have posted apps running as ordinary desktop windows:

- **Teamfight Tactics**, the latest release, on Linux "even with an Nvidia GPU"
  ([29 August](https://x.com/ActinisHQ/status/2093737771764470201)).
- **YouTube** playing a 4K HDR video, and **YouTube Music**, which "consumes fewer
  resources than the YTM Electron app"
  ([13 August](https://x.com/ActinisHQ/status/2087869042367365529),
  [13 August](https://x.com/ActinisHQ/status/2087807861849980965)).
- **Discord**, working "after a few WebView fixes"
  ([14 August](https://x.com/ActinisHQ/status/2088342137851019681)).

<figure class="post-figure">
  <img src="https://pbs.twimg.com/media/HQ5y21tXAAE0QXK.jpg?name=medium"
       alt="The Teamfight Tactics lobby in a Linux desktop window titled TFT — gpu/nv"
       loading="lazy">
  <figcaption>Teamfight Tactics in its own Linux window on an Nvidia GPU.
  From <a href="https://x.com/ActinisHQ/status/2093737771764470201" target="_blank" rel="noopener">@ActinisHQ, 29 August</a>.
  Image &copy; Actinis.</figcaption>
</figure>

<figure class="post-figure">
  <img src="https://pbs.twimg.com/media/HPmZxZcXYAAKi9-.jpg?name=medium"
       alt="YouTube playing a 4K HDR video in a Linux window beside Drion's launcher with 3DMark, Gemini, Spotify, VLC, Firefox and Twitch"
       loading="lazy">
  <figcaption>YouTube in a desktop window, beside Drion's launcher.
  From <a href="https://x.com/ActinisHQ/status/2087869042367365529" target="_blank" rel="noopener">@ActinisHQ, 13 August</a>.
  Image &copy; Actinis.</figcaption>
</figure>

They are also asking what to bring first: which Android apps
[Steam Deck owners](https://x.com/ActinisHQ/status/2082864459660316843) and
[Ubuntu Touch users](https://x.com/ActinisHQ/status/2083867116533329961) want most, and on
Ubuntu Touch they have shown the latest Android Firefox under test on 24.04-2.0.

A note on where Digitalis fits: translation is only needed where the CPU differs. On x86_64
hosts such as the Steam Deck, the Steam Machine and ordinary PCs, arm64-only apps rely on
it. On arm64 hardware such as Ubuntu Touch phones, Android's arm64 code runs natively and
Drion needs no translator.

## Help test the alpha

Actinis is starting a **closed alpha**. From
[their announcement](https://x.com/ActinisHQ/status/2093738204209840612):

> The alpha version will be distributed as a Flatpak package. Wayland is required.

To sign up, email **[alpha@actinis.io](mailto:alpha@actinis.io)** or send a DM to
[@ActinisHQ](https://x.com/ActinisHQ). For anything else, Actinis is at
[contact@actinis.io](mailto:contact@actinis.io).

As with the Bass OS build, Drion is Actinis' product, not ours, and we have not run it.
Questions about Drion go to them first. If a problem comes down to arm64 translation,
that part is ours, and we would like to hear about it.

- Drion: [actinis.io/drion](https://actinis.io/drion)
- Actinis on X: [@ActinisHQ](https://x.com/ActinisHQ)
- Digitalis source: [github.com/DigitalisX64](https://github.com/DigitalisX64)

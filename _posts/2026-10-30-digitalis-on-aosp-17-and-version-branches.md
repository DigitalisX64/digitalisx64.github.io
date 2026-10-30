---
title: "Digitalis on AOSP 17, and the end of android-latest-release"
summary: "The android17 branch is live, and floating branches are going away"
---

Digitalis builds and runs on AOSP 17 now. There is an `android17` branch on the manifest and
on every repository that makes up a tree, so a 17 checkout is one command:

```sh
repo init -b android17 -u git@github.com:DigitalisX64/manifest.git
repo sync -c -j"$(nproc)"
```

Android 16 has not moved and is still maintained on `android16`. Nothing about a 16 tree
changes because of this.

The second half of this post is about branch names, and it matters more to downstream
projects than the port does: `android-latest-release` is deprecated.

## What 17 actually needed

Almost all the work was in the emulator image, and both problems were graphics.

The Android 17 kernel retires the goldfish pipe, and a Vulkan call over that transport never
gets its reply. On 16 only Vulkan apps took that path. On 17 the GLES driver defaults to
ANGLE, which puts every process on Vulkan, so SystemUI hung on its first window and the
launcher stayed blank. One line fixes it, `hw.gltransport = virtio-gpu-asg`, and it has to
ship with the ANGLE default: either alone gives you a broken image.

Then five unrelated games crashed, all of them playing a video at startup, and the tombstone
was in none of them. Over virtio-gpu the goldfish codec service reaches mesa's logger, which
checks `geteuid`, `getegid` and `getgid`; the codec2 seccomp policy allows only `getuid`, so
minijail killed the media HAL and every app playing a video with it. goldfish has a hook for
a device-specific policy extension, and that is where the fix went.

## What we measured

The sample suite passes 159 of 159. The prebuilt corpus passes 346 launches with no failures:
67 games, 48 apps and 231 in the combined set, each batch on a freshly booted device so that
accumulated memory pressure cannot pass itself off as a translator bug.

Two results from that run are worth repeating because both of them were *our* measurements
being wrong rather than the software being broken. A corpus run once recorded four games as
blank under ANGLE, and that reading is what kept 17 on the older GLES path for two days;
re-measured with the transport fix in place, all four render. And a sweep that reported four
blank games turned out to have run 115 apps inside a single emulator because of a bug in our
own batching script. The lesson we keep relearning is that a failure during a long sweep is a
lead, not a finding, until it reproduces on a rested device.

## android-latest-release is deprecated

We published `android-latest-release` as a convenience. It turned out to be the wrong shape.
A floating branch cannot tell you which AOSP it tracks, so a downstream build that pinned it
would quietly change platform underneath whoever was using it, usually at the least
convenient moment. "Latest" is also a promise about timeliness that a small project should
not be making.

So the rule from here is version branches. Pick the AOSP you are on and pin it:

| your AOSP | branch |
|---|---|
| Android 16 (API 36) | `android16` |
| Android 17 (API 37) | `android17` |

`android-latest-release` is not being deleted. It will be moved by hand to whatever the
newest stable branch is, but not on a schedule and not promptly after a release, so there
will be stretches where it points at the previous version. Treat it as a stale pointer that
occasionally catches up, not as a release channel.

If you maintain something that builds on Digitalis, switch your manifest to `android16` or
`android17` now. It is a one-word change in your `repo init`, and it means a platform bump
happens when you decide it does.

## Names and trademarks

Digitalis is not affiliated with, endorsed by or sponsored by any of the companies or
projects named in this post, and nothing here is a claim on their names or their software.

- Android and the Android Open Source Project are trademarks of Google LLC.
- Vulkan and OpenGL are registered trademarks of The Khronos Group Inc.
- ANGLE, gfxstream, goldfish, minijail and Mesa are the marks of their respective projects.
- Any other product or company name used here is used only to identify the thing it names.

Digitalis itself is Apache-2.0, and that licence, not this post, is what governs any use of
our code.

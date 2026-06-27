# Wheatley Linux

A small, amber-themed Linux distribution.

- **Base:** Artix Linux (Arch-based, **no systemd**) — pick **dinit**, **runit**
  or **OpenRC** at install time
- **Kernel:** `linux-cachyos` (CachyOS performance kernel)
- **Installer:** a light, **online** whiptail TUI — choose **minimal** or
  **desktop**, and which window manager(s) to preinstall: **apeturewm**,
  **atomwm**, or both
- **Desktop (optional):** greeter (greetd + tuigreet), PipeWire audio, and the
  Wheatley-themed **st** terminal — all wired up out of the box
- **Theme:** amber on near-black everywhere — TTY palette, `st`, the WMs, and
  the installer/greeter

Palette: background `#100A02`, secondary/lines `#A66900`, primary text `#F1B00A`.

## What the installer does

`wheatley-install` (runs from the live ISO) walks you through:

1. internet check (wired, or Wi-Fi via `nmtui`)
2. keymap / locale / timezone / hostname
3. root + user account
4. **init system** — `dinit` (default), `runit` or `OpenRC`
5. **network manager** — `NetworkManager` (nmtui + tray applet) or `ConnMan`
6. **install type** — `minimal` (base + kernel + network) or `desktop`
7. **window manager(s)** — checklist: `apeturewm`, `atomwm`
8. **terminal colour** — amber theme, or normal/neutral colours
9. storage — **whole disk** (guided GPT ESP + root, UEFI or BIOS) or
   **keep my data** (pick an existing partition, optional `cfdisk`, choose
   whether to format it — leaves the rest of the disk for dual-boot), optional swap
10. a final summary — nothing is written until you confirm

Then it partitions, `basestrap`s the base + `linux-cachyos`, configures the
chosen init's services, installs GRUB, and — for a desktop install — pulls in
the chosen
WM(s), greetd + tuigreet, the full PipeWire stack, `st-wheatley`, `rofi`,
`dmenu`, `fastfetch` (with the Wheatley logo), and a default app set
(**Firefox**, `mpv`, `zathura`, `feh`, `dunst`, `pavucontrol`, `lf`, `scrot`,
`xclip`), then writes the greeter config so your WM shows up in the login menu.
A **minimal** install gets none of these — just base, kernel and network.

## Layout

```
wheatley-linux/
├── build.sh                 # build the ISO on any Docker host
├── Dockerfile               # Artix + artools + CachyOS build env
├── scripts/make-iso.sh      # runs inside the container: repo + buildiso
├── repo/pacman.conf         # Artix + CachyOS + [wheatley] repos
├── packages/                # custom packages (built into the [wheatley] repo)
│   ├── apeturewm/           # tiling WM (your repo) → /usr, xsession entry
│   ├── atomwm/              # monocle WM (your repo) + session wrapper + .desktop
│   ├── st-wheatley/         # st patched to the Wheatley palette + JetBrains Mono
│   ├── wheatley-installer/  # the TUI installer + bundled pacman.conf
│   └── wheatley-branding/   # amber TTY palette, /etc/issue, os-release
└── iso-profile/wheatley/    # artools profile (package lists + live overlay)
```

## Get the ISO

Two ways:

### 1. Download a prebuilt ISO

Grab the latest `wheatley-runit-*-x86_64.iso` from the
**[Releases page](https://github.com/Vifuddyxg/wheatley-linux/releases)**
(if a release has been published).

### 2. Build it yourself

You need **Docker** (the build runs in an Artix container, so it works from
any distro — including a Gentoo host). The image needs `--privileged` for loop
devices / squashfs; `build.sh` handles that.

```sh
git clone https://github.com/Vifuddyxg/wheatley-linux.git
cd wheatley-linux
./build.sh
```

The whole thing is self-contained: `build.sh` spins up the Artix + artools +
CachyOS container, builds the custom `[wheatley]` packages, and runs `buildiso`.
The custom window managers (`apeturewm`, `atomwm`) are cloned from GitHub during
the build. First run downloads packages and takes a while; re-runs reuse the
`.pkgcache/` so they are much faster.

The finished ISO lands in **`./out/`** (≈1.7 GB).

## Putting the ISO on a USB stick

**Ventoy** (recommended — just copy the file):

```sh
cp out/wheatley-runit-*-x86_64.iso /run/media/<you>/Ventoy/
sync          # IMPORTANT: wait for this to finish before unplugging
```

Or write the whole stick with `dd` (erases it):

```sh
sudo dd if=out/wheatley-runit-*-x86_64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Test it without hardware first:

```sh
qemu-system-x86_64 -enable-kvm -m 4G -bios /usr/share/edk2-ovmf/OVMF_CODE.fd \
    -cdrom out/wheatley-runit-*-x86_64.iso
```

## Trying the pieces without a full ISO build

Each custom package is a normal Arch/Artix `PKGBUILD` — on an Artix box you can
`cd packages/<name> && makepkg -si`. The installer script is plain bash and is
syntax-clean (`bash -n`); read it at `packages/wheatley-installer/wheatley-install`.

## Status / notes

- The custom packages, the installer, and the branding are complete and
  self-contained. The perl color-patch for `st` is tested against st 0.9.2.
- `iso-profile/wheatley/profile.yaml` follows the current Artix `artools`
  iso-profiles (YAML) format. **artools changes these keys between versions** —
  if `buildiso` rejects a key, diff against the official `base` profile that
  `make-iso.sh` clones into place and adjust.
- The installer is **online-only**: it always `basestrap`s a fresh system, so
  it can fit the **CachyOS kernel** and your chosen options (an internet
  connection is required — wired, or Wi-Fi via the built-in `nmtui` step).
- Init system is chosen at install: **dinit** (default), **runit**, or
  **OpenRC**. Service packages use the matching `-dinit` / `-runit` / `-openrc`
  suffix. The live ISO itself runs runit (independent of the target's init).
- The desktop login is **greetd + tuigreet** on a dedicated VT (tty7), so the
  greeter stays clear of kernel/boot console messages. Audio is brought up per
  session (PipeWire) by the WM's session wrapper.
- CachyOS kernel comes from the `[cachyos]` repo, added to pacman in both the
  build env and the installed system.

## The window managers

- **apeturewm** — `~/apeturewm`, tiling (BSP), per-monitor bar, workspaces,
  Wheatley palette baked into `config.h`.
- **atomwm** — `~/atomwm`, the lightest possible monocle WM (raw X11 protocol,
  no libc). Packaged here with `st` as its terminal and a session wrapper so it
  gets a dbus session + audio when launched from the greeter.

Both WMs are cloned from GitHub at build time. The `wheatley-*` PKGBUILDs also
ship a session wrapper that starts X (via `startx`) and PipeWire, so a TUI
greeter like tuigreet can launch them with working audio.

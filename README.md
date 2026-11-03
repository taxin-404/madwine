# Madwine compatibility-layer auto-updater

> **This is an independent community add-on repo, not Madwine itself.**
> Madwine is developed by **[Ring0lw](https://github.com/Ring0lw)** at
> **[github.com/Ring0lw/madwine](https://github.com/Ring0lw/madwine)** — that is the real,
> upstream project. This repository exists only to add one thing Madwine doesn't do on
> its own: keep its **Proton/GE-Proton compatibility layer** up to date.

---

## The problem

Madwine runs Roblox/Madium through a **GE-Proton** compatibility layer (via
[umu](https://github.com/Open-Wine-Components/umu-launcher)), and it **hard-pins one
GE-Proton build**. Madwine's built-in updater only updates the *launcher app* — never the
compatibility layer. So improvements and fixes from newer GE-Proton releases (Wine updates,
input/IME fixes, controller and graphics fixes) never reach your install unless you do it by
hand.

This tool fixes that: it makes Madwine **track the latest GE-Proton automatically**.

## What it does

Every login and once a day, a `systemd --user` timer runs
a small script that:

1. Asks GitHub for the newest
   [GE-Proton](https://github.com/GloriousEggroll/proton-ge-custom) release.
2. Downloads the `x86_64` tarball and verifies it against the release's **SHA-512**.
3. Installs it into Madwine's own proton directory
   (`~/.local/share/madwine/proton/GE-Proton<ver>-x86_64/`).
4. Points Madwine at it by setting the `"proton"` field in
   `~/.config/madwine/config.json` — this is the path Madwine hands to umu as
   `PROTONPATH` — and clears the unused `"reuseSteamProton"` flag.
5. Removes older GE-Proton copies **it manages**, keeping the previously used one as a
   rollback. Layers that are not GE-Proton (e.g. `Proton-CachyOS`) are never touched.

If a newer GE-Proton is already installed, it does nothing. If Madwine/Roblox/Wine is
running, it defers to the next run and never swaps files under a live game.

## Install

```bash
git clone https://github.com/taxin-404/madwine.git
cd madwine
./install.sh
```

That installs `madwine-compat-update` to `~/.local/bin`, installs the timer, enables it, and
runs it once.

> Close Madwine/Roblox first. The first update installs the downloaded GE-Proton; it takes
> effect the next time you launch Madwine.

### Manual use

```bash
madwine-compat-update --check      # show installed vs latest, change nothing
madwine-compat-update --dry-run    # show what it would do
madwine-compat-update              # update now
madwine-compat-update --version GE-Proton11-12   # pin a specific build
```

Logs: `~/.local/state/madwine/compat-update.log`
Timer status: `systemctl --user list-timers madwine-compat-update.timer`
Run now: `systemctl --user start madwine-compat-update.service`

## Requirements

`bash`, `curl`, `jq`, `tar`, `sha512sum`, `flock`, `systemd --user`, and a network
connection. Arch Linux with Omarchy (the setup this was built on) has all of these.

## Safety & reversibility

- Downloads are SHA-512 verified before anything is installed.
- `~/.config/madwine/config.json` is backed up (`.bak.<timestamp>`) before being edited.
- Nothing is written while Madwine/Roblox/Wine is running.
- **Uninstall:** `./uninstall.sh` removes the timer and script.
- **Revert to an earlier layer:** the tool keeps the previously used GE-Proton copy next to
  the new one. Point Madwine back at it by editing `"proton"` in
  `~/.config/madwine/config.json`, or re-run
  `madwine-compat-update --version <tag>` to select a specific build. (A timestamped
  `config.json.bak.*` is written on every change.)

### How it hooks into Madwine

Madwine is closed-source, so this tool drives observable behavior rather than patching it:

- Madwine selects its compatibility layer from the `"proton"` field in `config.json`, and
  exports that path to umu as `PROTONPATH` (visible at runtime, e.g.
  `PROTONPATH=.../madwine/proton/GE-Proton<ver>-x86_64`).
- The `"reuseSteamProton"` setting is **not** honoured for layer selection, so the tool
  rewrites `"proton"` directly (and clears that flag) instead of relying on it.
- Madwine must be fully closed when the config is rewritten, so the tool refuses to touch
  anything while Madwine/Roblox/Wine is running.

## Uninstall

```bash
./uninstall.sh
```

## Credits & license

- **Madwine** — [Ring0lw/madwine](https://github.com/Ring0lw/madwine) (upstream; this repo is
  unrelated to and not endorsed by it).
- **GE-Proton** — [GloriousEggroll/proton-ge-custom](https://github.com/GloriousEggroll/proton-ge-custom).
- **umu-launcher** — [Open-Wine-Components/umu-launcher](https://github.com/Open-Wine-Components/umu-launcher).

Released into the public domain under the [Unlicense](LICENSE).

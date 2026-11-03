#!/usr/bin/env bash
# uninstall.sh — remove the auto-updater and leave Madwine exactly as it was,
# except for the compatibility layer that is already installed.
#
# After this, Madwine keeps using whatever layer is set in the "proton" field of
# ~/.config/madwine/config.json. To go back to an earlier build, point that field
# at the retained previous copy (see README).
set -euo pipefail

bin_dir="${XDG_BIN_HOME:-$HOME/.local/bin}"
unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

say() { printf '%s\n' "$*"; }

say "==> stopping and disabling the timer"
systemctl --user disable --now madwine-compat-update.timer 2>/dev/null || true

say "==> removing systemd user units"
rm -f "$unit_dir/madwine-compat-update.timer" "$unit_dir/madwine-compat-update.service"
systemctl --user daemon-reload 2>/dev/null || true

say "==> removing the updater script"
rm -f "$bin_dir/madwine-compat-update"

say ""
say "Done. Installed GE-Proton copies are left in place so your game keeps working."
say "Madwine keeps using the layer set in ~/.config/madwine/config.json (see README)."

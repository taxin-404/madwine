#!/usr/bin/env bash
# install.sh — install the Madwine compatibility-layer auto-updater as a user service.
set -euo pipefail

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
bin_dir="${XDG_BIN_HOME:-$HOME/.local/bin}"
unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

say() { printf '%s\n' "$*"; }

say "==> installing ${bin_dir}/madwine-compat-update"
mkdir -p "$bin_dir"
install -m 0755 "$here/bin/madwine-compat-update" "$bin_dir/madwine-compat-update"

say "==> installing ${bin_dir}/madwine-fix-input"
install -m 0755 "$here/bin/madwine-fix-input" "$bin_dir/madwine-fix-input"

say "==> installing systemd user units into ${unit_dir}"
mkdir -p "$unit_dir"
install -m 0644 "$here/systemd/madwine-compat-update.service" "$unit_dir/"
install -m 0644 "$here/systemd/madwine-compat-update.timer" "$unit_dir/"

say "==> enabling the daily timer"
systemctl --user daemon-reload
systemctl --user enable --now madwine-compat-update.timer

say "==> running the updater once now"
# The updater exits cleanly (making no changes) if Madwine/Roblox is running.
systemctl --user start madwine-compat-update.service || true

say ""
say "Done. The compatibility layer will be checked on login and daily."
say "  Log:        \${XDG_STATE_HOME:-\$HOME/.local/state}/madwine/compat-update.log"
say "  Status:     systemctl --user list-timers madwine-compat-update.timer"
say "  Update now: systemctl --user start madwine-compat-update.service"
say "  Check only: $bin_dir/madwine-compat-update --check"
say "  Keyboard:   $bin_dir/madwine-fix-input --check  (see README: UseTakeFocus)"
say ""
say "Note: close Madwine/Roblox before the first update takes effect; the tool"
say "      defers automatically while a game is running."

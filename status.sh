#!/bin/sh
# Herdr tab bar HUD: CPU load and battery as neon block meters.
# Herdr shows the last line of output and strips ANSI colors, so the style comes from glyphs.
# CPU is the 1-minute load average as a share of logical cores, capped at 100%.
# The PWR meter is skipped on Macs without a battery; ↯ means plugged in.

bar() { # $1 = percent 0-100 -> five-cell meter
  awk -v p="$1" 'BEGIN { n = int((p + 10) / 20); if (n > 5) n = 5; s = ""; for (i = 1; i <= 5; i++) s = s (i <= n ? "█" : "░"); print s }'
}

ncpu=$(sysctl -n hw.logicalcpu 2>/dev/null)
[ "${ncpu:-0}" -gt 0 ] 2>/dev/null || ncpu=1
load=$(sysctl -n vm.loadavg 2>/dev/null | awk '{ print $2 }')
cpu=$(awk -v l="${load:-0}" -v n="$ncpu" 'BEGIN { p = l / n * 100; if (p > 100) p = 100; printf "%d", p + 0.5 }')
out=$(printf 'CPU %s %3d%%' "$(bar "$cpu")" "$cpu")

batt=$(pmset -g batt 2>/dev/null)
pct=$(printf '%s\n' "$batt" | grep -Eo '[0-9]+%' | head -n 1 | tr -d '%')
if [ -n "$pct" ]; then
  plug=""
  case $batt in *"AC Power"*) plug="↯" ;; esac
  out=$(printf '%s  PWR %s %3d%%%s' "$out" "$(bar "$pct")" "$pct" "$plug")
fi

printf '%s\n' "$out"

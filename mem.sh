#!/bin/sh
# Herdr tab bar HUD: memory pressure gauge and memory in use.
# The gauge follows the kernel's memory pressure level (the same signal as Activity Monitor):
#   󰡵 normal   󰊚 warning   󰡴 critical
# Memory in use = app memory + wired + compressed, matching Activity Monitor's "Memory Used".

case $(sysctl -n kern.memorystatus_vm_pressure_level 2>/dev/null) in
2) gauge='󰊚' ;; # md-gauge       U+F029A
4) gauge='󰡴' ;; # md-gauge_full  U+F0874
*) gauge='󰡵' ;; # md-gauge_low   U+F0875
esac

total=$(sysctl -n hw.memsize 2>/dev/null)
vm_stat 2>/dev/null | awk -v gauge="$gauge" -v total="${total:-0}" '
	/page size of/                  { page = $8 }
	/^Anonymous pages/              { anon = $3 }
	/^Pages purgeable/              { purge = $3 }
	/^Pages wired down/             { wired = $4 }
	/^Pages occupied by compressor/ { comp = $5 }
	END {
		gib = 1024 * 1024 * 1024
		used = (anon - purge + wired + comp) * page / gib
		printf "MEM %s %4.1f/%dG\n", gauge, used, total / gib + 0.5
	}'

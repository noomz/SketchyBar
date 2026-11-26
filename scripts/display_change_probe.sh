#!/bin/sh
# Fire a real display reconfiguration (nudge a non-main display for 1 s and
# restore it), then time how long the bar server stays unresponsive: the
# --query bar answer stays empty while the main thread is stuck.
# usage: display_change_probe.sh <display_nudge binary> <non-main did>
nudge=${1:?display_nudge binary}; did=${2:-1}
"$nudge" "$did" 10 1 || exit 1
start=$(/bin/date +%s)
i=0
while [ $i -lt 900 ]; do
  [ -n "$(sketchybar --query bar 2>/dev/null)" ] && break
  /bin/sleep 0.1; i=$((i + 1))
done
echo "unresponsive after restore: $(( $(/bin/date +%s) - start )) s (empty polls=$i)"

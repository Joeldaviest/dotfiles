#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 0.1; done

# Launch polybar
polybar -c ~/.config/polybar/polybar.ini 2>&1 | tee -a /tmp/polybar.log & disown

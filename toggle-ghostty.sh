#!/usr/bin/env bash

readonly custom_ghostty_class=com.mitchellh.ghostty.quake

active=$(xdotool getactivewindow)
class=$(xprop -id "${active}" | awk -F '"' '/WM_CLASS/ {print $4}')
readonly active class

if [[ "${class}" == "${custom_ghostty_class}" ]]; then
    xdotool windowminimize "${active}"
else
    ids=$(xdotool search --class "${custom_ghostty_class}")
    if [[ -z ${ids} ]]; then
        ghostty --class="${custom_ghostty_class}" &>/dev/null &
    else
        for id in ${ids}; do
            xdotool windowactivate "${id}"
        done
    fi
fi

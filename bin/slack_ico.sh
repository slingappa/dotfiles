#!/bin/bash
ICON=/snap/slack/68/usr/share/pixmaps/slack.png

WINDOWS=(`wmctrl -l | grep "Slack - " | cut -f1 -d' ' | xargs`)
for slack_window in ${WINDOWS[@]}; do
    # Use "xseticon", a compiled C binary, to change the icon of a running program
    ~/bin/xseticon-0.1+bzr14/xseticon -id ${slack_window} $ICON

    # Use "xprop" to set the window state, so that alt+tab works again
    xprop -f _NET_WM_WINDOW_TYPE 32a -set _NET_WM_WINDOW_TYPE _NET_WM_WINDOW_TYPE_NORMAL -id ${slack_window}
done

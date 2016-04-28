#!/bin/sh
export PULSE_RUNTIME_PATH="/run/user/1000/pulse/"
export DISPLAY=:0
read hdmi_status < /sys/class/drm/card0-HDMI-A-1/status
echo $hdmi_status
sleep 1

if [[ $hdmi_status == "connected" ]]; then
    pacmd set-card-profile 0 "output:hdmi-stereo"
else
    pacmd set-card-profile 0 "output:analog-stereo"
fi

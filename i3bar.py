#!/bin/python3
# TODO: look into i3pystatus

from json import dumps as jdumps
from time import sleep
import sys, subprocess

printf = sys.stdout.write
run_cmd = subprocess.getoutput

# colors
red         = '#ff4e00'
blue        = '#00c0ff'
green       = '#20ffa0'
white       = '#e0e0e0'
light_gray  = '#b0b0b0'
dark_gray   = '#555555'

def initialize():
    printf('{ "version": 1 } [')

def output_item(data, color, width=0):
    printf(jdumps({
               "full_text": data,
               "color": color,
               "separator_block_width": width
           }))

def output_separator():
    # assumes between two items
    printf(',')
    output_item(' :: ', dark_gray)
    printf(',')


def internet(link=''):
    if (link == ''):
        eth = run_cmd("ip link show | grep -o enp.*:")[:-1]
        wlan = run_cmd("ip link show | grep -o wlp.*:")[:-1]
        if (eth == '' and wlan == ''):
            return output_item("No link", red)
        link = eth if eth != '' else wlan

    if 'Link detected: no' in run_cmd("ethtool " + link):
        return output_item('Not connected', red)

    if (link[0] == 'w'):
        ssid = run_cmd("iw wlp3s0 link | grep 'SSID' | sed 's/[ \t]*SSID: //g'")
        output_item(ssid + ' ', green)
        printf(',')
        perc = run_cmd("awk 'NR==3 {print substr($3,0,length($3)-1) \"%\"}''' /proc/net/wireless")
        return output_item(perc, white)
    speed = run_cmd("ethtool " + link + " | grep Speed")
    speed = speed[speed.find('Speed:'):][7:]
    return output_item("Ethernet ("+speed+")", green)

def volume():
    vol = run_cmd("amixer -c 0 get Master -M | tail -1")
    num = vol[vol.find('[')+1:vol.find(']')]
    output_item('Volume: ', light_gray)
    printf(',')
    if ('off' in vol):
        return output_item(num, red)
    return output_item(num, white)

def date():
    data = run_cmd("date +'%A, %B %d'")
    return output_item(data, white)

def time():
    data = run_cmd("date +'%H:%M:%S'")
    return output_item(data, white)

def battery():
    data = run_cmd("acpi")
    num = int(data[data.find(',')+2 : data.find('%')])
    if ('Discharging' in data):
        color = white
        if (num <= 20):
            color = red
        return output_item(str(num)+'%', color)
    return output_item(str(num)+'%', blue)

def main():
    initialize()

    while (1):
        printf('[')

        internet()
        output_separator()
        volume()
        output_separator()
        date()
        output_separator()
        time()
        output_separator()
        battery()
        printf(',')
        output_item(' :', dark_gray)

        printf('],')

        sys.stdout.flush()
        sleep(1)

if __name__ == '__main__': main()

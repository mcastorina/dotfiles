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
        if (eth != ''): internet(eth)
        if (wlan != ''):
            if (eth != ''):
                output_separator()
            internet(wlan)
        return

    if 'Link detected: no' in run_cmd("ethtool " + link):
        return output_item('Not connected', red)
    addr = run_cmd("ip route show | grep "+link+" | grep -o 'src .*$'")
    addr = addr[4:addr.find(' ', 5)]

    if (link[0] == 'w'):
        ssid = run_cmd("iw wlp3s0 link | grep 'SSID' | sed 's/[ \t]*SSID: //g'")
        output_item(ssid + ' ', green)
        printf(',')
        output_item('('+addr+') ', light_gray)
        printf(',')
        perc = run_cmd("awk 'NR==3 {print substr($3,0,length($3)-1) \"%\"}''' /proc/net/wireless")
        return output_item(perc, white)
    output_item("Ethernet ", green)
    printf(',')
    return output_item("("+addr+")", light_gray)
def volume():
    vol = run_cmd("pulseaudio-ctl full-status")
    num = vol.split()[0]+'%'
    output_item('Volume: ', light_gray)
    printf(',')
    if ('yes' in vol):
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
def music():
    try:
        data = run_cmd("cat $NOW_PLAYING")
        return cmus(data) or pianobar(data)
    except:
        output_item('Error', red)
        return True
def cmus(data):
    status = run_cmd("cmus-remote -Q | grep status")
    if 'not running' in status: status = ''
    elif 'stopped' in status:   status = red
    elif 'paused' in status:    status = dark_gray
    elif 'playing' in status:   status = white
    else:                       status = ''
    if len(data) > 0 and len(status) > 0:
        length, current = run_cmd("cmus-remote -Q | grep -A 1 duration").split('\n')
        length = int(length.split()[-1])
        current = int(current.split()[-1])
        perc = str(round(100.0 * current / length)).zfill(2)

        output_item(data, status)
        printf(',')
        output_item(' [%s%%]' % perc, light_gray if status == white else dark_gray)
        return True
    return False
def pianobar(data):
    status = run_cmd("ps -e | grep pianobar")
    if len(status) > 0:
        output_item(data, white)
        return True
    return False


def main():
    initialize()

    while (1):
        printf('[')

        if music():
            output_separator()
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

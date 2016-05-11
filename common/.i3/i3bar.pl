#!/usr/bin/env perl
#
use strict;
use POSIX qw(strftime);

my $interval = +$ARGV[0] || 1;

# Don't buffer output
$| = 1;

# array of functions to output
my @order = (
    \&print_music,
    \&print_link,
    \&print_volume,
    \&print_time,
    \&print_battery
);

# colors
my $red         = "#ff4e00";
my $blue        = "#00c0ff";
my $green       = "#20ffa0";
my $white       = "#e0e0e0";
my $light_gray  = "#b0b0b0";
my $dark_gray   = "#555555";

# global vars
my $link_type = 1;

sub print_item {
    my $color = $_[2] || $white;
    my $width = $_[3] || 0;
    print "{\"name\":\"$_[0]\",
            \"full_text\":\"$_[1]\",
            \"color\":\"$color\",
            \"separator_block_width\": $width}\n";
    return 1;
}
sub print_sep {
    # assumes between two items
    my $text = $_[0] || " :: ";
    my $color = $_[1] || $dark_gray;

    print ",";
    print_item("sep", $text, $color);
    print ",";
}
sub print_items {
    # runs every $interval
    print "[";

    for my $i (0 .. $#order-1) {
        if (@order[$i]->()) {
            print_sep();
        }
    }
    @order[-1]->();

    print ",";
    print_item("sep", " : ", $dark_gray);

    print "],";
    alarm $interval;
}


sub print_music {
    try {
        my $data = `cat \$NOW_PLAYING`;
        chop($data);
        return pianobar($data) || mpd();
    }
    catch {
        print_item("music_err", "Error", $red);
        return 1;
    }
}
sub mpd {
    my $status = `mpc status`;
    my @data = split('\n', $status);

    if (index($status, "Connection refused") != -1) {$status = "";}
    elsif (index($status, "paused") != -1)          {$status = $dark_gray;}
    elsif (index($status, "playing") != -1)         {$status = $white;}
    else                                            {$status = "";}

    if (scalar(@data) > 0 && length($status) > 0) {
        my $current = @data[0];
        @data[1] =~ /\((.*)\)/;
        my $perc = $1;

        print_item("mpd", @data[0], $status);
        print ",";
        if ($status eq $white) {$status = $light_gray;}
        else {$status = $dark_gray;}
        print_item("mpd", " [$perc]", $status);
        return 1;
    }
    return 0;
}
sub pianobar {
    my $data = $_[0];
    my $status = `ps -e | grep pianobar`;
    if (length($status) > 1) {
        print_item("pianobar", $data, $white);
        return 1;
    }
    return 0;
}
sub print_link {
    my $link = $_[0];
    if (scalar(@_) == 0) {
        my $eth = `ip link show | grep -o 'enp.*:'`;
        my $wlan = `ip link show | grep -o 'wlp.*:'`;

        chop($eth);
        chop($eth);
        chop($wlan);
        chop($wlan);

        if ($eth eq "" and $wlan eq "") {
            return print_item("link", "No link", $red)
        }

        if (length($eth) != 0) {
            print_link($eth);
        }
        if (length($wlan) != 0) {
            if (length($eth) != 0) {
                print_sep()
            }
            print_link($wlan);
        }
        return 1;
    }
    if (index(`ethtool $link`, "Link detected: no") != -1) {
        return print_item("link", "Not connected", $red);
    }
    my $addr = `ip route show | grep $link | grep -o 'src .*\$'`;
    $addr = (split(' ', $addr))[1];

    if (substr($link, 0, 1) eq "w") {
        my $ssid;
        if ($link_type) {
            $ssid = `iw $link link | grep 'SSID' | sed 's/[ \t]*SSID: //g'`;
        } else {
            $ssid = `curl ipv4.icanhazip.com`;
        }
        chop($ssid);
        print_item("link", "$ssid ", $green);
        print ",";
        print_item("link", "($addr) ", $light_gray);
        print ",";
        my $perc = `awk 'NR==3 {print substr(\$3,0,length(\$3)-1) \"%\"}''' /proc/net/wireless`;
        chop($perc);
        return print_item("link", $perc, $white);
    }
    print_item("link", "Ethernet ", $green);
    print ",";
    return print_item("link", "($addr)", $light_gray);
}
sub print_volume {
    my $vol = `pulseaudio-ctl full-status`;
    my $num = (split(' ', $vol))[0] . "%";
    print_item("vol", "♪ ", $light_gray);
    print ",";
    if (index($vol, "yes") != -1) {
        return print_item("vol", $num, $red);
    }
    return print_item("vol", $num, $white);
}
sub print_time {
    my $time = strftime("%H:%M:%S", localtime(time()));
    my $date = strftime("%A, %B %d", localtime(time()));
    print_item("date", $date);
    print_sep();
    print_item("time", $time);
}
sub print_battery {
    my $data = `acpi`;
    $data =~ /, (.*)%,/;
    my $num = $1;
    if (index($data, "Discharging") != -1) {
        my $color = $white;
        if ($num <= 20) {
            $color = $red;
        }
        return print_item("battery", "$num%", $color);
    }
    return print_item("battery", "$num%", $blue);
}

$SIG{ALRM} = \&print_items;

$SIG{CLD} = sub {
};

print "{\"version\":1, \"click_events\":true}\n";
print "[\n";

print_items();

# get back on schedule
alarm($interval - (time % $interval));

while (<STDIN>) {
    if (/"name":"vol"/ and /"button":([0-9])/) {
        my $button = $1;
        if ($button == 1) {
            `pulseaudio-ctl mute`;
            kill("ALRM", "$$");
        }
        elsif ($button == 4) {
            `pulseaudio-ctl up 2`;
            kill("ALRM", "$$");
        }
        elsif ($button == 5) {
            `pulseaudio-ctl down 2`;
            kill("ALRM", "$$");
        }
    }
    elsif (/"name":"link"/ and /"button":([0-9])/) {
        my $button = $1;
        if ($button == 1) {
            $link_type = not $link_type;
            kill("ALRM", "$$");
        }
    }
    elsif (/"name":"battery"/ and /"button":([0-9])/) {
        my $button = $1;
        if ($button == 1) {
            `notify-send "\$(acpi)"`;
        }
    }
    elsif (/"name":"mpd"/ and /"button":([0-9])/) {
        my $button = $1;
        if ($button == 1) {
            `mpc toggle`;
            kill("ALRM", "$$");
        }
        elsif ($button == 4) {
            `mpc seek +1%`;
            kill("ALRM", "$$");
        }
        elsif ($button == 5) {
            `mpc seek -1%`;
            kill("ALRM", "$$");
        }
    }
}

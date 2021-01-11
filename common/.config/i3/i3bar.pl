#!/usr/bin/env perl
#
use strict;
use POSIX qw(strftime);

my $interval = +$ARGV[0] || 1;

# Don't buffer output
$| = 1;

# array of functions to output (left to right)
my @order = (
    \&print_storror,
    \&print_updates,
    \&print_music,
    \&print_link,
    \&print_time,
    \&print_volume,
);

# colors
my $red         = "#ff4e00";
my $blue        = "#00c0ff";
my $green       = "#20ffa0";
my $white       = "#e0e0e0";
my $light_gray  = "#b0b0b0";
my $dark_gray   = "#555555";

# global vars
my $public_ip = "unknown";
my $link_type = 0;
my $date_type = 0;
my $time_type = 0;

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


sub print_storror {
    try {
        my $data = `cat \$(xdg-user-dir CACHE)/available-tens`;
        if ($? != 0) {
            return 0;
        }
        chop($data);
        if (length($data) > 0) {
            return print_item("storror", "$data", $red);
        }
    }
    catch {}
    return 0;
}
sub print_updates {
    try {
        my $data = `cat \$(xdg-user-dir CACHE)/available-updates | wc -l`;
        if ($? != 0) {
            return 0;
        }
        chop($data);
        if ($data == "1") {
            return print_item("updates", "$data update available", $blue);
        } elsif ($data != "0") {
            return print_item("updates", "$data updates available", $blue);
        }
    }
    catch {}
    return 0;
}
sub print_banner {
    try {
        my $data = `cat \$BANNER | head -1`;
        if ($? != 0) {
            return 0;
        }
        chop($data);
        return print_item("banner", $data, $white);
    }
    catch {
        return 1;
    }
}
sub print_music {
    try {
        my $data = `cat \$(xdg-user-dir CACHE)/now-playing`;
        if ($? != 0) {
            return 0;
        }
        chop($data);
        return pianobar($data) || spotify() || mpd();
    }
    catch {
        print_item("music_err", "Error", $red);
        return 1;
    }
}
my $mpd_ofs = 0;
sub mpd {
    my $status = `mpc status`;
    my @data = split('\n', $status);

    if ($status =~ "Connection refused") {$status = "";}
    elsif ($status =~ "paused")          {$status = $dark_gray;}
    elsif ($status =~ "playing")         {$status = $white;}
    else                                 {$status = "";}

    if (scalar(@data) > 0 && length($status) > 0) {
        my $current = @data[0];
        if (length($current) > 50) {
            $current = "$current    ";
            $current = substr($current, $mpd_ofs, 50);
            if (length($current) != 50) {
                my $amt = 50 - length($current);
                if ($amt < 0) {$amt = 0;}
                $current = $current . substr(@data[0], 0, $amt);
            }
            if ($status eq $white) {
                # rotate only if playing
                $mpd_ofs = ($mpd_ofs + 1) % (length(@data[0]) + 4);
            }
        }
        else {
            $mpd_ofs = 0;
        }
        @data[1] =~ /\((.*)\)/;
        my $perc = $1;

        print_item("mpd", $current, $status);
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
    my $current = $data;
    my $status = `ps -e | grep pianobar`;
    if (length($status) <= 1) {
        return 0;
    }

    if (length($current) > 50) {
        $current = "$current    ";
        $current = substr($current, $mpd_ofs, 50);
        if (length($current) != 50) {
            my $amt = 50 - length($current);
            if ($amt < 0) {$amt = 0;}
            $current = $current . substr($data, 0, $amt);
        }
        $mpd_ofs = ($mpd_ofs + 1) % (length($data) + 4);
    }
    else {
        $mpd_ofs = 0;
    }
    return print_item("pianobar", $current, $white);
}
sub spotify {
    my $status = `ps -e | grep spotify`;
    if (length($status) <= 1) {
        return 0;
    }
    my $color = $white;
    my $data = `spotify-now -i "%artist - %title" -p "paused"`; chop($data);
    if ($data eq "paused") {
        $color = $dark_gray;
    }
    my $data = `spotify-now -i "%artist - %title"`; chop($data);
    my $current = $data;
    if (length($current) > 50) {
        $current = "$current    ";
        $current = substr($current, $mpd_ofs, 50);
        if (length($current) != 50) {
            my $amt = 50 - length($current);
            if ($amt < 0) {$amt = 0;}
            $current = $current . substr($data, 0, $amt);
        }
        $mpd_ofs = ($mpd_ofs + 1) % (length($data) + 4);
    }
    else {
        $mpd_ofs = 0;
    }
    return print_item("spotify", $current, $color);
}
sub print_link {
    my $link = $_[0];
    if (scalar(@_) == 0) {
        # TODO: multiple NICs
        my $eth = `ip link show | grep -o 'enp.*:' | head -1`;
        my $wlan = `ip link show | grep -o 'wlp.*:' | head -1`;

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
    if (`ethtool $link` =~ "Link detected: no") {
        return print_item("link", "Not connected", $red);
    }
    my $addr;
    if ($link_type) {
        # TODO: update cache periodically
        $addr = $public_ip;
    }
    else {
        $addr = `ip route show | grep $link | grep -o 'src .*\$'`;
        $addr = (split(' ', $addr))[1];
    }

    if (substr($link, 0, 1) eq "w") {
        my $ssid = `iw $link link | grep 'SSID' | sed 's/[ \t]*SSID: //g'`;
        chop($ssid);
        print_item("link", "$ssid ", $green);
        print ",";
        print_item("link", "($addr) ", $light_gray);
        print ",";
        my $perc = `awk 'NR==3 {print substr(\$3,0,length(\$3)-1) \"%\"}''' /proc/net/wireless`;
        chop($perc);
        chop($perc);
        my $symbol = "▮";
        if ($perc >= 10) {
            $symbol = "$symbol▮";
            if ($perc >= 35) {
                $symbol = "$symbol▮";
                if ($perc >= 55) {
                    $symbol = "$symbol▮";
                    if ($perc >= 70) {
                        $symbol = "$symbol▮";
                    }
                }
            }
        }
        while (length($symbol) < 15) {
            $symbol = "$symbol▯";
        }
        return print_item("link", $symbol, $white);
    }
    print_item("link", "Ethernet ", $green);
    print ",";
    return print_item("link", "($addr)", $light_gray);
}
sub print_volume {
    my $vol = `pulseaudio-ctl full-status`;
    my $num = (split(' ', $vol))[0];
    if ($vol =~ "yes") {
        print_item("vol", $num, $red);
    }
    else {
        print_item("vol", $num, $white);
    }
    print ",";
    print_item("vol", " ♪", $light_gray);
}
sub print_time {
    my $df;
    my $tf;
    if ($time_type) {
        $tf = "%I:%M %p";
        if (time() % 2 == 0) { $tf = "%I %M %p"; }
    } else { $tf = "%H:%M:%S"; }
    my $time = strftime($tf, localtime(time()));
    if ($date_type) { $df = "%m/%d/%Y"; } else { $df = "%A, %B %d"; }
    my $date = strftime($df, localtime(time()));
    print_item("date", $date);
    print_sep();
    print_item("time", $time);
}
sub print_battery {
    my $data = `acpi`;
    $data =~ /, (.*)%/;
    my $num = $1;
    if ($data =~ "Discharging") {
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
    if ($1 == 3) {
        # toggle visibility
    }
    else {
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
        elsif (/"name":"date"/ and /"button":([0-9])/) {
            my $button = $1;
            if ($button == 1) {
                $date_type = not $date_type;
                kill("ALRM", "$$");
            }
        }
        elsif (/"name":"time"/ and /"button":([0-9])/) {
            my $button = $1;
            if ($button == 1) {
                $time_type = not $time_type;
                kill("ALRM", "$$");
            }
        }
        elsif (/"name":"link"/ and /"button":([0-9])/) {
            my $button = $1;
            if ($button == 1) {
                $link_type = not $link_type;
                if ($link_type) {
                    $public_ip = `curl ipv4.icanhazip.com || echo unknown`;
                    chop($public_ip);
                }
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
        elsif (/"name":"updates"/ and /"button":([0-9])/) {
            my $button = $1;
            if ($button == 1) {
                `\$HOME/bin/check-updates`;
                kill("ALRM", "$$");
            }
        }
        elsif (/"name":"storror"/ and /"button":([0-9])/) {
            my $button = $1;
            if ($button == 1) {
                `firefox https://www.storror.com/store/product/storror-tens-parkour-shoe-black`;
                kill("ALRM", "$$");
            }
        }
        elsif (/"name":"pianobar"/ and /"button":([0-9])/) {
            my $button = $1;
            if ($button == 1) {
                `pianoctl p`;
                kill("ALRM", "$$");
            }
            elsif ($button == 2) {
                `pianoctl q`;
                kill("ALRM", "$$");
            }
            elsif ($button == 3) {
                `pianoctl n`;
                kill("ALRM", "$$");
            }
        }
    }
}

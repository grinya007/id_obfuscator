#!/usr/bin/env perl
use 5.014;
use warnings;

use FindBin qw/$RealBin/;
use lib $RealBin . '/../lib';

use Obfuscator;

my $power = $ARGV[0];
die('give me some int 1..31 as first arg') if (!$power || $power !~ /^\d+$/ || $power > 31);
for (1 .. (2**$power)) {
    print Obfuscator::obfuscate($_), "\n";
}

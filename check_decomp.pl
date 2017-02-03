#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;

use mooss_utils;
use List::MoreUtils qw(uniq);


my $file = shift;

open FILE, '<', $file or die "can't open `$file`";


my $content;
while(<FILE>)
{
    chomp $_;
    $content .= $_;
}


$content =~ s/\(|\)|\{|\}/,/g;

my @tokens = split ",", $content;
map {hard_trim(\$_)} @tokens;
@tokens = uniq @tokens;
@tokens = sort @tokens;
say join "\n", @tokens;

close FILE or die "can't close `$file`";

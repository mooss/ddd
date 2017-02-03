package mooss_utils;
use strict;
use warnings;
use v5.14;
use constant TRUE => 1;
use constant FALSE => 0;

use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/hard_trim/;

#apparently this doesn't exist in perl
sub  hard_trim { my $s = shift; $$s =~ s/^\s+|\s+$//g; };

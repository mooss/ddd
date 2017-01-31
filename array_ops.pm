package array_ops;
use strict;
use warnings;
use v5.14;
use constant TRUE => 1;
use constant FALSE => 0;

use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/is_subset/;

sub is_subset
{
    my ($left, $right) = @_;

    return TRUE if @$left <= 0;

    my @left_copy = @$left;

    
    foreach (@$right)
    {
        for( my $i = 0; $i < @left_copy; ++$i)
        {
            if( $_ ~~ $left_copy[$i])
            {
                splice(@left_copy, $i, 1);
                return TRUE if @left_copy <= 0;
            }
        }
    }
    
    return FALSE;
}

#!/usr/bin/env perl
use strict;
use warnings;
use v5.14;

use schema2;
use array_ops;

# my @lost = ("4", "8", "15", "16", "23", "42");
# my @partial_lost = ("42", "15", "8");
# my @whatever = ("0", "4", "8", "42");

# inclusion_test(\@lost, \@partial_lost);
# say "";
# inclusion_test(\@partial_lost, \@lost);
# say "";
# inclusion_test(\@whatever, \@lost);
# say "";
# inclusion_test(\@whatever, \@partial_lost);

my $schema = schema2->new();
$schema->load_from_file("plain_text_version.txt");

# my $format = "svg";
# foreach ($schema->dependencies())
# {
#     #say $_->to_plain_text();
# }

foreach (@{$schema->{deps}})
{
    my $closure = $schema->closure($_->{lhs});
    say "la fermeture fonctionnelle de \n\t",
        join(", ", @{$_->{lhs}}),
        "\nest :\n\t",
        join(", ", @$closure);
    say"\n#==========================#\n";
}

say "\n dépendances élémentaires :";
say "_t", $schema->armstrong_decomposition()->to_plain_text();

my $test_attribute = ["dateSortie"];
say "dependences determinant ", join(", ", @$test_attribute), "\n\t", $schema->subset_determining($test_attribute)->to_plain_text();

sub inclusion_test
{
    my ($left, $right) = @_;

    my ($strl, $strr) = ( join(", ", @$left),
                        join(", ", @$right) );
    if( is_subset($left, $right))
    {
        say $strl, "\nest inclus dans\n", $strr;
    }
    else
    {
        say $strl, "\nn'est pas inclus dans\n", $strr;
    }
}

#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;

use schema_graphless;

my $schema = schema->new();
$schema->load_from_file("plain_text_version.txt");

my $format = "svg";
foreach ($schema->dependencies())
{
    say $_->to_plain_text();
}

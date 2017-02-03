#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;

use schema2;

my $schema = schema2->new();
my $input = shift || "plain_text_version.txt";
$schema->load_from_file($input);

my $output = shift || "default_output";
my $format = shift || "svg";

$schema->make_graph()->run(format => $format, output_file => "$output.$format");

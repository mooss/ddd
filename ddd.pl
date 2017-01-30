#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;

use schema;

my $schema = schema->new();
$schema->load_from_file("plain_text_version.txt");

my $format = "svg";
$schema->make_graph()->run(format => $format, output_file => "dependencies_output.$format");

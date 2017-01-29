#!/usr/bin/env perl

use strict;
use warnings;
use v5.14;

#use File::Spec;
use GraphViz2;
use Data::Dumper;
use schema;

my $schema = schema->new();
$schema->add(["idCine"], ["adresse", "ville", "nbSalles"]);
$schema->add(["idFilm"], ["nomFilm", "dateSortie"]);
$schema->add(["idPers"], ["nomP", "prenomP"]);
$schema->add(["idPers", "idFilm"], ["role"]);
$schema->add(["idClient"], ["nomC", "prenomC"]);
$schema->add(["idSeance"], ["adresse", "ville", "horaire", "dateSortie", "numSalle"]);

$schema->add(["adresse", "ville"], ["franchise", "nbSalles"]);
$schema->add(["adresse", "ville", "numSalle"],
             ["salleCompatible3D", "nbPlacesStandard", "nbPlacesHandicape", "nbDBox"]);
$schema->add(["nomFilm", "dateSortie"],
             ["public", "idPersASidReal", "duree", "compatible3D"]);
$schema->add(["nomFilm", "dateSortie", "role"], ["idPersASidAct"]);
$schema->add(["adresse", "ville", "horaire", "dateProjection", "numSalle"],
             ["nomFilm", "dateSortie", "diffusionEn3D"]);
$schema->add(["nomC", "prenomC", "numReservation"],
             ["nbPlacesStandardRes", "nbPlacesHandicapeRes", "nbDBoxRes", "nomFilm", "adresse", "ville", "salle", "horaire"]);
$schema->add(["horaire", "nomFilm", "adresse", "ville"],
             ["numSalle"]);

say "nodelist :", join(", ", $schema->node_list());


$schema->make_graph()->run(format => 'svg', output_file => 'dependencies_output.svg');

$schema->write_to_file("plain_text_version.txt");

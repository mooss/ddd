package fundep;
use strict;
use warnings;
use v5.14;
use constant TRUE => 1;
use constant FALSE => 0;

#use List::MoreUtils qw(uniq);

sub new
{
    my ($class, $lhs, $rhs) = @_;
    $class = ref($class) || $class;
    my $this = {};
    bless($this, $class);

    $this->{lhs} = $lhs;
    $this->{rhs} = $rhs;
    return $this;
}

sub print
{
    my $this = shift;
    say $this->to_plain_text();
    # print join(",", @{$this->{lhs}});
    # print " --> ";
    # print join(",", @{$this->{rhs}}), "\n";
}

sub attributes_list
{
    my $this = shift;
    my $result = [@{$this->{lhs}}, @{$this->{rhs}}];
    return $result;
}

sub lhs
{
    my $this = shift;
    return @{$this->{lhs}};
}

sub rhs
{
    my $this = shift;
    return @{$this->{rhs}};
}

sub to_plain_text
{
    my $this = shift;
    return join(",", $this->lhs()) . " --> " . join(",", $this->rhs()) . ";";
}

1;

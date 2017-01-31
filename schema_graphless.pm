package schema;
use strict;
use warnings;
use v5.14;
use constant TRUE => 1;
use constant FALSE => 0;

use fundep;
use List::MoreUtils qw(uniq);
use Data::Dumper;
use colorpalette;

sub new
{
    my ($class) = @_;
    $class = ref($class) || $class;
    my $this = {};
    bless($this, $class);

    $this->{deps} = [];
    return $this;
}

sub dependencies
{
    my $this = shift;
    return @{$this->{deps}};
}


sub add
{
    my ($this, $lhs, $rhs) = @_;
    push @{$this->{deps}}, fundep->new($lhs, $rhs);
}


sub node_list
{
    my $this = shift;
    my @result = ();

    foreach my $el ($this->dependencies())
    {
        push @result, @{$el->attributes_list()};
    }
    return uniq @result;
}

sub save_to_file
{
    my ($this, $file) = @_;
    if(open(FILE, ">$file"))
    {
        foreach my $dep ($this->dependencies)
        {
            print(FILE $dep->to_plain_text() . "\n");
        }
        close(FILE);
    }
    else
    {
        say "unable to write to file: $file";
    }
    
}

sub load_from_file
{
    my ($this, $file) = @_;
    open FILE, '<', $file or die "can't open `$file`";
    
    my $accumulator;
    while(<FILE>)
    {
        chomp;
        $accumulator .= $_;
    }
    close FILE or die "can't close file";
    $this->load_from_text(\$accumulator);
}

sub load_from_text
{
    my ($this, $ref_text) = @_;

    #removing parasite whitespaces
    $$ref_text =~ s/\s+//;

    my @deps = split ';', $$ref_text;

    foreach (@deps)
    {
        my ($lhs, $rhs) = split "-->", $_;
        my @left_attributes = split ',', $lhs;
        my @right_attributes = split ',', $rhs;

        #removing spaces before and after attributes
        map { hard_trim(\$_) } @left_attributes;
        map { hard_trim(\$_) } @right_attributes;

        $this->add(\@left_attributes, \@right_attributes);
    }
}

#apparently this doesn't exist in perl
sub  hard_trim { my $s = shift; $$s =~ s/^\s+|\s+$//g; };
1;

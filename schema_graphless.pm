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
use array_ops;

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

sub add_dependencie
{
    my ($this, $dep) = @_;
    push @{$this->{deps}}, $dep->clone();
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

sub to_plain_text()
{
    my $this = shift;
    
    return join "\n", map {$_->to_plain_text()} $this->dependencies();
}

#apparently this doesn't exist in perl
sub  hard_trim { my $s = shift; $$s =~ s/^\s+|\s+$//g; };



sub couverture_minimale
{
    my $this = shift;
    #$this->rendre_elementaire();

    
    
}

sub closure
{
    my ($this, $original_set) = @_;

    my $result;
    my $has_changed;
    my $dependencies = $this->clone_dependencies();
    @$result = @$original_set;
    
    do
    {
        $has_changed = FALSE;
        for( my $i = 0; $i < @$dependencies; ++$i)
        {
            if( is_subset($dependencies->[$i]->{lhs}, $result))
            {
                push @$result, @{$dependencies->[$i]->{rhs}};
                $has_changed = TRUE;
                splice @$dependencies, $i, 1;
                --$i;
            }
        }
    } while $has_changed;

    return $result;
}

sub elementary # (décomposition d'armstrong)
{
    my $this = shift;
    my $result = $this->new();

    foreach(@{$this->{deps}})
    {
        my @attrs = @{$_->{rhs}};
        my $left_ref = $_->{lhs};
        foreach(@attrs)
        {
            my @left = @$left_ref;
            $result->add(\@left, [$_]);
        }
    }

    return $result;
}

#trouver le plus petit subset de la partie gauche permettant de générer la même partie droite
sub minimal
{
    my $this = shift;
    my $result = $this->elementary();

    my $fermeture_fonctionnelle = $this->closure();

    
    
}

sub subset_determining
{
    my ($this, $attr_ref) = @_;
    my $result = $this->clone();

    my $determine = sub
    {
        return is_subset($attr_ref, $_[0]->{rhs});
    };
    remove_non_conforming($result->{deps}, $determine);
    return $result;
}

sub remove_non_conforming
{
    my ($ref_tab, $predicat) = @_;
    #say Dumper($ref_tab);
    for(my $i = 0; $i < @$ref_tab; ++$i)
    {
        if(! $predicat->($$ref_tab[$i]))
        {
            say "removing " . $$ref_tab[$i];
            splice @$ref_tab, $i, 1;
            --$i;
        }
    }

}
# sub rendre_elementaire
# {
#     my $this = shift;
#     my @non_elem_list;

#     foreach (@{$this->{deps}})
#     {
#         foreach (@{$_->{rhs}})
#         {
            
#         }
#     }
# }

sub clone
{
    my $this = shift;
    my $result = $this->new();
    foreach ($this->dependencies())
    {
        $result->add_dependencie($_);
    }
    return $result;
}

sub clone_dependencies
{
    my $this = shift;
    my $result;
    foreach ($this->dependencies())
    {
        push @$result, $_->clone();
    }

    return $result;
}



1;

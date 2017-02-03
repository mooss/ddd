package schema2;
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
use GraphViz2;
use mooss_utils;


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
    my $attributes_separator = "#";
    my @deps = split ';', $$ref_text;

    foreach (@deps)
    {
        my ($lhs, $rhs) = split "-->", $_;
        my @left_attributes = split $attributes_separator, $lhs;
        my @right_attributes = split $attributes_separator, $rhs;

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

sub armstrong_decomposition # (décomposition d'armstrong)
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
# sub elementary
# {
#     my $this = shift;
#     my $result = $this->armstrong_decomposition();
#     my $fermeture_fonctionnelle = $this->closure( $this->attributes_list());

#     for(my $i = 0; $i < @$result)
    
# }

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

sub make_graph
{
    my $this = shift;
    
    my $result = GraphViz2->new
        (
         edge => {color => 'red'},
         global => {directed => 1},
         node => {shape => 'box'},
         graph =>{
             size => "15, 500!",
             ratio => "compress"},
         
        );

    my $placeholder_num = 0;

    foreach my $node ($this->node_list())
    {
        $result->add_node(name => $node, shape => "box",
            label => labelize($node));
    }

    my $color_palette = colorpalette->new();

    for(my $i = 0; $i < $this->dependencies(); ++$i)
    {
        my $dep = @{$this->{deps}}[$i];
        my $edge_color = $color_palette->next();

        
        if($dep->lhs() > 1)
        {
            my $placeholder = "placeholder_$placeholder_num";
            ++$placeholder_num;
            #utilisation d'un placeholder pour représenter les dépendances ayant plus d'un attribut à gauche
            $result->add_node(name => $placeholder,
                              label => "",
                              shape => "underline",
                              height => 0.01);
            foreach my $attr ($dep->lhs())
            {
                $result->add_edge( from => $attr,
                                   to => $placeholder,
                                   color => $edge_color);
            }
            foreach my $attr (@{$dep->{rhs}})
            {
                $result->add_edge( from => $placeholder,
                                   to => $attr, color =>
                                   $edge_color);
            }
        }
        else # un seul attribut du coté gauche
        {
            my $lhs = $dep->{lhs}[0];
            foreach my $attr (@{$dep->{rhs}})
            {
                $result->add_edge(
                    from => $lhs,
                    to => $attr,
                    color => $edge_color);
            }
        }
    }

    return $result;
}

sub labelize
{
    my $name = shift;
    my $size = shift || 50;
    my $split_char = ",";

    $name =~ s/~retour_ligne~/\n/;
    
    my @decoupe = split $split_char, $name;

    my $accu = "";
    my $result;

    foreach(@decoupe)
    {
        if(length $accu <= $size)
        {
            $accu .= $_ . $split_char;
        }
        else
        {
            $result .= "\n" . $accu;
            $accu = $_;
        }
    }
    $result .= "\n" . $accu;
    $result =~ s/,$//;
    return $result;
    
}

1;

package colorpalette;

use strict;
use warnings;
 
# use Exporter;
# our @ISA = qw/Exporter/;
# our @EXPORT = qw/@color_palette/;

my @color_palette =
(
    "#000000",
    "#FF0000",
    "#00FF00",
    "#0000FF",
    "#FF00FF",
    "#00FFFF",
    "#FFFF00",
    "#70DB93",
    "#B5A642",
    "#5F9F9F",
    "#B87333",
    "#2F4F2F",
    "#9932CD",
    "#871F78",
    "#855E42",
    "#545454",
    "#8E2323",
    "#F5CCB0",
    "#238E23",
    "#CD7F32",
    "#DBDB70",
    "#C0C0C0",
    "#527F76",
    "#9F9F5F",
    "#8E236B",
    "#2F2F4F",
    "#EBC79E",
    "#CFB53B",
    "#FF7F00",
    "#DB70DB",
    "#D9D9F3",
    "#5959AB",
    "#8C1717",
    "#238E68",
    "#6B4226",
    "#8E6B23",
    "#007FFF",
    "#00FF7F",
    "#236B8E",
    "#38B0DE",
    "#DB9370",
    "#ADEAEA",
    "#5C4033",
    "#4F2F4F",
    "#CC3299",
    "#99CC32"
);

sub new
{
    my $class = shift;
    $class = ref($class) || $class;
    my $this = {};
    bless($this, $class);

    $this->{current} = 0;
    return $this;
}

sub next
{
    my $this = shift;
    $this->{current} = ($this->{current} +1) % @color_palette;
    return $color_palette[$this->{current}];
}

sub current
{
    my $this = shift;
    return $color_palette[$this->{current}];
}

1;

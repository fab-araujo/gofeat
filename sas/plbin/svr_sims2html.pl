#!/usr/bin/perl -w

#
# This is a SAS Component
#

=head1 svr_sims2html

Build an HTML page or table from one or more tables of pairwise similarities.

The output is an HTML page.

=head2 Command-Line Options

=over 4

=item -c=color_key_word

Current keywords are: none | gray | hue (D)

=item -d

Assume data are distances (range = zero to infinity), not similarities (range = 1 to 0).  Distances are rescaled to the interval 1 to 0.

=item -f=layout_key_word

Desired format.  Current keywords are: overlay | separate

Overlay can merge 2 or 3 sets of data into a single table.  This is the
default when it is possible.

=item -l

Log transform the similarities.

=item -t

Build one or more tables, not a whole HTML page.

=back

=head2 Output Format

HTML page or tables.

=cut

use strict;
use Getopt::Long;
use gjocolorlib;

my $usage = <<End_of_Usage;

Usage: svr_sims2html [ opts ] < distance_matrix > html

Options:

    -c key    #  Color options: none | gray | hue
              #      Default depends on format
    -d        #  Values are distances, not similarities
    -f key    #  Layout option:  separate | overlay (D for 2 or 3 tables)
    -l        #  Log transform the values
    -t        #  Build a table, not a page

End_of_Usage

my $color  = 'hue';      #  Color type: none | gray | hue
my $dists  = 0;          #  Data are distinaces, not similarities
my $log    = 0;          #  Log transform values
my $table  = 0;          #  Output table, not whole page
my $format = 'overlay';  #  Overlay multiple tables, if possible

my $rc = GetOptions( "c=s" => \$color,
		     "d"   => \$dists,
                     "f=s" => \$format,
                     "l"   => \$log,
		     "t"   => \$table
		   );
$rc or print STDERR $usage and exit;

my @data;
my @orgs;
my @dists;
my $title;

while ( <> )
{
    chomp;
    if ( /^\/\// )
    {
        push @data, [ $title, [@orgs], [@dists] ];
        $title = undef;
        @orgs  = ();
        @dists = ();
    }
    elsif ( ! defined $title )
    {
        $title = $_;
    }
    else
    {
        my ( $org,    @row ) = split /\t/;
        push @orgs,   $org;
        push @dists, \@row;
    }
}

push @data, [ $title, [@orgs], [@dists] ] if @orgs && @data;

@data or exit;

if ( @data == 1 || @data > 3 )
{
    $format = '';
}
elsif ( ! defined $format )
{
    $format = 'overlay';
}

#   Figure out the range of values

my @ranges;
my $minmin =  1e99;
my $maxmax = -1e99;
foreach ( @data )
{
    my $min =  1e99;
    my $max = -1e99;
    my $dists = $_->[2];
    foreach my $row ( @$dists )
    {
        foreach ( @$row ) { $min = $_ if $min > $_; $max = $_ if $max < $_ }
    }
    push @ranges, [ $min, $max, $max-$min ];
    $minmin = $min if $minmin > $min;
    $maxmax = $max if $maxmax > $max;
}


if ( ! $table )
{
    print <<End_of_Head;
<HTML>
<HEAD>
<META http-equiv="Content-Type" content="text/html;charset=UTF-8" />
<TITLE>svr_dists2html</TITLE>
</HEAD>

<BODY>
End_of_Head
}

if ( $format =~ m/^over/i )
{
    my $title = join( '; ', map { $_->[0] } @data );
    my $orgs  = $data[0]->[1];
    my @sims  = map { $_->[2] } @data;

    print "<h2>$title</h2>\n";
    print "<TABLE>\n";
    print "  <TR>\n";
    foreach ( ( ' ', @$orgs ) ) { print "    <TH>$_</TH>\n" }
    print "  </TR>\n";
    for ( my $i = 0; $i < @$orgs; $i++ )
    {
        print "  <TR>\n";
        print "    <TD>$orgs->[$i]</TD>\n";
        for ( my $j = 0; $j < @$orgs; $j++ )
        {
            my @vals = map { $_->[$i]->[$j] } @sims;
            my @c    = $dists ? map { dist_2_sim( $_, $minmin, $maxmax ) } @vals : @vals;
            @c       = map { log_sim( $_ ) } @c if $log;

            if ( @data == 2 )
            {
                printf "    <TD BgColor=%s>%.3f<BR />%.3f</TD>\n", &make_two_tone( @c ), @vals;
            }
            else
            {
                printf "    <TD BgColor=%s>%.3f<BR />%.3f<BR />%.3f</TD>\n", &make_tree_tone( @c ), @vals;
            }
        }
        print "  </TR>\n";
    }
    print "</TABLE>\n";
}
else
{
    foreach ( @data )
    {
        my ( $title, $orgs, $sims ) = @$_;
        
	print "<h2>$title</h2>\n";
        print "<TABLE>\n";
        print "  <TR>\n";
        foreach ( ( ' ', @$orgs ) ) { print "    <TH>$_</TH>\n" }
        print "  </TR>\n";
        for ( my $i = 0; $i < @$orgs; $i++ )
        {
            my $row = $sims->[$i];
            print "  <TR>\n";
            print "    <TD>$orgs->[$i]</TD>\n";
            foreach ( @$row )
            {
                my $c = $dists ? dist_2_sim( $_, $minmin, $maxmax ) : $_;
                $c = log_sim( $c ) if $log;

                if ( $color =~ m/^gr[ae]y/i )
                {
                    printf "    <TD BgColor=%s>%.3f</TD>\n", &make_gray( $c ), $_;
                }
                elsif ( $color =~ m/^hue/i )
                {
                    printf "    <TD BgColor=%s>%.3f</TD>\n", &make_hue( $c ), $_;
                }
                else
                {
                    printf "    <TD>%.3f</TD>\n", $_;
                }
            }
            print "  </TR>\n";
        }
	print "</TABLE>\n";
    }
}

if ( ! $table )
{
    print <<End_of_Body;

</BODY>
</HTML>
End_of_Body
}

exit;


#-------------------------------------------------------------------------------
#  Subroutines
#-------------------------------------------------------------------------------

sub dist_2_sim
{
    my ( $dist, $min, $max ) = @_;
    ( ( $max - $min ) > 0 ) ? ( $max - $dist ) / ( $max - $min ) : 0;
}


sub log_sim
{
    my ( $x ) = @_;
    $x = 0.001 if ( $x < 0.001 );
    return ( -log( $x ) / log( 10 ) ) / 3;
}


sub make_two_tone
{
    my ( $c1, $c2 ) = @_;
    &gjocolorlib::rgb2html( $c1, 0.5*$c1 + 0.5*$c2, $c2 );
}


sub make_tree_tone
{
    &gjocolorlib::rgb2html( @_ );
}


sub make_gray
{
    &gjocolorlib::gray2html( @_ );
}


sub make_hue
{
    my ( $x ) = @_;
    &gjocolorlib::rgb2html( &gjocolorlib::hsb2rgb( 0.75 * $x, 1, 1 ) );
}

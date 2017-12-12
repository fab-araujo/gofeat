use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#

=head1 svr_neighbors_of

    svr_neighbors_of <gene_ids.tbl >neighbor_ids.tbl

Get neighbors of protein-encoding genes (PEGs)

The standard input should be a tab-separated table (i.e., each line 
is a tab-separated set of fields).  Normally, the last field in each
line would contain the PEG for which a list of neighbors is being requested.
If some other column contains the feature IDs, use

    -c n

where n is the column (from 1) that contains the PEG in each case.  You are
allowed to specify the number of neighbors you want using 

     -N n 

where n in this case is the number to each side of a given PEG.  That
is, a value of 5 would lead to a result composed of the 5 genes to the
left and the 5 genes to the right. 

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Command-Line Options

=over 4

=item -c Column

This is used only if the column containing PEGs is not the last.

=item -N number-neighbors

This value is the number to the left and the number to the right of the given gene.
Hence, you would normally get twice this number as the detected set of neighbors.  You
may get less if the given gene occurs near the beginning or end of a contig.

=head2 Output Format

The standard output is a tab-delimited file. It consists of the input
file with an extra column added (i.e., the column containing the comma-separated
list of neighbors).

=back

=cut

use SeedUtils;
use SAPserver;
my $sapObject = SAPserver->new();

my $usage = "usage: svr_neighbors_of [-c column] N";

my $column;
my $N;
while ($ARGV[0] && ($ARGV[0] =~ /^-/))
{
    $_ = shift @ARGV;
    if    ($_ =~ s/^-c//) { $column       = ($_ || shift @ARGV) }
    else                  { die "Bad Flag: $_" }
}
($N = shift @ARGV) || die $usage;

my @lines = map { chomp; [split(/\t/,$_)] } <STDIN>;
if (! $column)  { $column = @{$lines[0]} }
my @pegs = map { $_->[$column-1] } @lines;

my $neighbors = &get_neighbors(\@pegs,$N);
foreach $_ (@lines)
{
    my $neigh = join(",",@{$neighbors->{$_->[$column-1]}});
    print join("\t",(@$_,$neigh)),"\n";
}

sub get_neighbors {
    my($pegs,$N) = @_;

    my $neighbors = {};
    my $pegsH = {map { $_ => 1 } @$pegs};
    my %genomes	 = map { $_ =~ /^fig\|(\d+\.\d+)/; $1 => 1 } @$pegs;
    my @genomesL = keys(%genomes);

    my %by_genome;
    foreach my $genome (@genomesL)
    {
	my $pegHash  = $sapObject->all_features(-ids => $genome, -type => 'peg');
	my $all_pegs = $pegHash->{$genome};
	my $locHash  = $sapObject->fid_locations(-ids => $all_pegs);
	my @peg_loc_tuples_in_genome =
	    sort { &compare_locs($a->[1],$b->[1]) }
	    map { [$_,$locHash->{$_}] }
	    keys(%$locHash);
	&set_neighbors(\@peg_loc_tuples_in_genome,$pegsH,$neighbors,$N);
    }
    return $neighbors;
}

sub compare_locs {
    my($loc1,$loc2) = @_;

    my($contig1,$min1,$max1) = &SeedUtils::boundaries_of($loc1);
    my($contig2,$min2,$max2) = &SeedUtils::boundaries_of($loc2);
    return (($contig1 cmp $contig2) or (($min1+$max1) <=> ($min2+$max2)));
}

sub set_neighbors {
    my($peg_loc_tuples,$pegsH,$neighborsH,$N) = @_;

    my $i;
    for ($i=0; ($i < @$peg_loc_tuples); $i++)
    {
	next if (! $pegsH->{$peg_loc_tuples->[$i]->[0]});

	my($contigI,$minI,$maxI) = &SeedUtils::boundaries_of($peg_loc_tuples->[$i]->[1]);
	$contigI || confess "BAD";
	my $neighbors = [];
	my $j = $i-1;
	while (($j >= 0) && ($j >= ($i-$N)) && 
	       &same_contig($peg_loc_tuples->[$j]->[1],$contigI))
	{
	    $j--;
	}
	$j++;
	while ($j < $i) { push(@$neighbors,$peg_loc_tuples->[$j]->[0]); $j++ }

	$j = $i+1;
	while (($j < @$peg_loc_tuples) && ($j <= ($i+$N)) && 
	       &same_contig($peg_loc_tuples->[$j]->[1],$contigI))
	{
	    push(@$neighbors,$peg_loc_tuples->[$j]->[0]);
	    $j++;
	}
	$neighborsH->{$peg_loc_tuples->[$i]->[0]} = $neighbors;
    }
}

sub same_contig {
    my($entry,$contig) = @_;

    $contig || confess "BAD";
    my($contig1,$minI,$maxI) = &SeedUtils::boundaries_of($entry);
    return ($contig eq $contig1);
}

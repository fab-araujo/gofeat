use Getopt::Long;
use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#


=head1 svr_oligomer_similarity [-min=] [-max=] < ali.fasta > count-matricies

This command goes through an alignment and computes the pairwise fractions
of n-character identities, producing a matrix of values for each string length
specified in the -min to -max parameters.

This tool is used to produce estimates of similarity based on the fraction of
positions in which n-character perfect matches occur between each pair of 
sequences.

The output is a set of matricies written to STDOUT.  The format of each matrix is

N
Id1 Frac1-1 Frac1-2 Frac1-3...
Id2 Frac2-1 Frac2-2 Frac2-3...
.
.
.
//
.
.
.

------
Example: svr_oligomer_similarity -min=2 -max=4 < seqs.fasta > matricies

would produce a set of matricies summarizing the matches of different matricies
------

=head2 Command-Line Options

=over 4

=item -min=M

minimum size of character-strings that match (defaults to 2)

=item -max=N

maximum size of character-strings that match (defaults to 2)

=back

=head2 Output Format

The standard output is a file of matricies.  Each matrix is composed of
a line with the size-of-matches, a set of lines (one line per input sequence)
that give fractions of positions that have identical matches, and a terminating '//'.

=cut


use SeedEnv;
use gjoseqlib;

my $min = 2;
my $max = 2;
my $rc = GetOptions("min=i" => \$min,
                    "max=i" => \$max);

my @ali = &gjoseqlib::read_fasta;
my($i,$j);
my $valsH;
for ($i=0; ($i < $#ali); $i++)
{
    for ($j=$i+1; ($j < @ali); $j++)
    {
	my $options = { min => $min, max => $max };
	my @matches = &gjoseqlib::oligomer_similarity($ali[$i],$ali[$j],$options);
	$valsH->{"$i,$j"} = \@matches;
    }
}

my $N;
for ($N=$min; ($N <= $max); $N++)
{
    print "$N\n";
    for ($i=0; ($i < @ali); $i++)
    {
	print "$ali[$i]->[0]";
	for ($j=0; ($j < @ali); $j++)
	{
	    if ($i == $j)
	    {
		print "\t1";
	    }
	    elsif ($i < $j)
	    {
		print "\t",sprintf("%.4f",$valsH->{"$i,$j"}->[$N-$min]);
	    }
	    else
	    {
		print "\t",sprintf("%.4f",$valsH->{"$j,$i"}->[$N-$min]);
	    }
	}
	print "\n";
    }
    print "//\n";
}

	    

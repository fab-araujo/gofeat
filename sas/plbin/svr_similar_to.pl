#!/usr/bin/perl

use SeedEnv;

#
# This is a SAS Component
#


=head1 svr_similar_to [CutOff] < PEG > PEG1-Sc-PEG

Get similarities for a PEG

Input is PEG id's on STDIN

Output is tab separated list of PEG, Score, PEG on STDOUT

------
Example: svr_similar_to < peg_file
------

=head2 Command-Line Options

=over 4

=item CutOff

An optional cutoff score.

=back

=head2 Output Format

The standard output is a file where each line contains a peg\tscore\tpeg

=cut

my $usage = "usage: svr_similar_to [CutOff] < PEG > PEG1-Sc-PEG";

my($cutoff,$pair,$peg);
$cutoff = shift @ARGV;
$cutoff = defined($cutoff) ? $cutoff : 1.0e-10;

my $id;
@pegs = map { chop; $_ =~ /(\S+)$/; 
	      $id = $1;  
	       ($id =~ /^fig\|/) ? $id : ()
            } <STDIN>;

foreach my $sim (&SeedUtils::sims(\@pegs,300,$cutoff ? $cutoff : 1.0e-5,'fig',10000))
{
    print join("\t",($sim->id1,$sim->psc,$sim->id2)),"\n";
}

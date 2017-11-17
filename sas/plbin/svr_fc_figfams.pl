#!/usr/bin/perl -w
use strict;
use Data::Dumper;

use Getopt::Long;
use SAPserver;
use ScriptThing;
use SeedUtils;

#
#	This is a SAS Component.
#

=head1 svr_fc_figfams

    svr_fc_figfams [-MinSc=n] < table_with_ff_column.tbl  > extended_with_scores_and_ffs.tbl

Output the functionally coupled FIGfams  By specifying a MinSc, you restrict the
output to functionally-coupled FIGfams that co-occur in at least n OTUs.

This script takes as input a tab-delimited file with FIGfam IDs at the end of
each line. For each FIGfam ID, the coupling score and FIGfam ID of
a functionally coupled FIGfam will be appended to the list.

This is a pipe command: the input is taken from the standard input and the
output is to the standard output. Alternatively, a list of FIGfam IDs can be
specified as command-line parameters.

=head2 Command-Line Options

=over 4

=item url

The URL for the Sapling server, if it is to be different from the default.

=item c

Column index. If specified, indicates that the input IDs should be taken from the
indicated column instead of the last column. The first column is column 1.

=back

=cut

# Parse the command-line options.
my $url = '';
my $column = 0;
my $all = 0;
my $MinSc = 0;
my $opted =  GetOptions('url=s' => \$url, 'c=i' => \$column, 'MinSc=i' => \$MinSc );
if (! $opted) {
    print "usage: svr_fc_figfams [--url=http://...] [--c=N]  [MinSc=n] <input >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # Here the user wants selected FIGfams. Find out if we're getting input
    # from STDIN or the command line.
    my $input = (@ARGV ? [@ARGV] : \*STDIN);
    # The main loop processes chunks of input.
    while (my @tuples = ScriptThing::GetBatch($input, undef, $column)) {
        # Ask the server for results.
        my $coupledH = $sapServer->related_figfams(-ids => [map { $_->[0] } @tuples]);
        # Loop through the IDs, producing output.
        for my $tuple (@tuples) {
            my ($id, $line) = @$tuple;
            # Get related FIGfams
	    if (my $relatedL = $coupledH->{$id})
	    {
		foreach my $pair (sort { $b->[1]->[0] <=> $a->[1]->[0] } @$relatedL)
		{
		    my $figfam2 = $pair->[0];
		    my $score   = $pair->[1]->[0];
		    if ($score >= $MinSc)
		    {
			print "$line\t$score\t$figfam2\n";
		    }
                }
            }
        }
    }
}


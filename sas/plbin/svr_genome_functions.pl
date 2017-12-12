#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;
use SeedEnv;

#
#	This is a SAS Component.
#

=head1 svr_genome_functions

    svr_genome_functions genome >genes.tbl

List the location and functional assignment for each gene in a specified genome.

This script takes as input a single genome ID as a positional parameter and
produces a three-column tab-delimited file containing each gene ID, its
L<SAP/Location String>, and its functional assignment. The output is to the
standard output.

=head2 Command-Line Options

=over 4

=item url

The URL for the Sapling server, if it is to be different from the default.

=back

=cut

# Parse the command-line options.
my $url;
my $opted =  GetOptions('url=s' => \$url);
# Get the genome ID.
my $genomeID = $ARGV[0];
# Check for errors.
if (! $opted || ! $genomeID) {
    print "usage: svr_genome_functions [--url=http://...] genomeID >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # Get the list of genes in this genome.
    my $genomeHash = $sapServer->all_features(-ids => $genomeID);
    my @geneList = sort { &SeedUtils::by_fig_id($a,$b) } @{$genomeHash->{$genomeID}};
    # The main loop processes chunks of input, 1000 lines at a time.
    while (my @tuples = ScriptThing::GetBatch(\@geneList, 1000)) {
        # Get the location and function for each ID found.
        my $fidHash = $sapServer->ids_to_data(-ids => [map { $_->[0] } @tuples],
                                              -data => ['location', 'function']);
        # Loop through the IDs, producing output.
        for my $tuple (sort { &SeedUtils::by_fig_id($a->[0],$b->[0]) } @tuples) {
            # Get the ID and the line.
            my ($id, $line) = @$tuple;
            # Get this feature's location and function. We spend a little effort to
            # insure we can recover if no result was found.
            my $locData = $fidHash->{$id};
            my ($loc, $function) = ('', 'unknown');
            if ($locData) {
                ($loc, $function) = @{$locData->[0]};
            }
            # Print the result.
            print join("\t", $line, $loc, $function) . "\n";
        }
    }
}

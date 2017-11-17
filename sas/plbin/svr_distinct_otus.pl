#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_distinct_otus

    svr_distinct_otus <genome_ids.tbl >genome_data.tbl

Classify the incoming genome IDs into organism taxonomic units.

This script takes as input a tab-delimited file with genome IDs at the end of each
line. The output contains only the genome IDs. Genomes belonging to the same OTU will
appear on a single line. Counting the output lines will therefore return the number of
distinct OTUs found in the input.

This is a pipe command: the input is taken from the standard input and the output
is to the standard output. It can optionally take as input a list of genome IDs
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
my $column = '';
my $opted =  GetOptions('url=s' => \$url, 'c=i' => \$column);
if (! $opted) {
    print "usage: svr_distinct_otus [--url=http://...] [--c=N] <input >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # This hash will contain the genomes organized into OTUs by representative genome ID.
    my %retVal;
    # Find out if we're getting input from STDIN or the command line.
    my $input = (@ARGV ? [@ARGV] : \*STDIN);
    # The main loop processes chunks of input.
    while (my @tuples = ScriptThing::GetBatch($input, undef, $column)) {
        # Ask the server for results.
        my $document = $sapServer->representative(-ids => [map { $_->[0] } @tuples]);
        # Loop through the IDs, filling the output hash.
        for my $tuple (@tuples) {
            my ($id, $line) = @$tuple;
            # Get this genome's data.
            my $rep = $document->{$id};
            # Did we get something?
            if ($rep) {
                # Yes. Stash the genome in a list for the appropriate representative
                # genome.
                push @{$retVal{$rep}}, $id;
            }
        }
    }
    # Output the OTU sets.
    for my $rep (sort keys %retVal) {
        print join("\t", @{$retVal{$rep}}) . "\n";
    }
}


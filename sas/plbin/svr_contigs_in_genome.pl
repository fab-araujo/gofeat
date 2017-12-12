#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_contigs_in_genome

    svr_contigs_in_genome <genome_ids.tbl >genome_data.tbl

For each incoming genome ID, return the IDs of its contigs.

This script takes as input a tab-delimited file with genome IDs at the end of each
line. For each genome ID, multiple output lines are produced containing the ID
of each contig in the genome.

This is a pipe command: the input is taken from the standard input and the output
is to the standard output. It can alternatively take as input a list of genome IDs
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
    print "usage: svr_contigs_in_genome [--url=http://...] [--c=N] <input >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # Find out if we're getting input from STDIN or the command line.
    my $input = (@ARGV ? [@ARGV] : \*STDIN);
    # The main loop processes chunks of input.
    while (my @tuples = ScriptThing::GetBatch($input, undef, $column)) {
        # Ask the server for results.
        my $document = $sapServer->genome_contigs(-ids => [map { $_->[0] } @tuples]);
        # Loop through the IDs, producing output.
        for my $tuple (@tuples) {
            my ($id, $line) = @$tuple;
            # Get this genome's data.
            my $genomeData = $document->{$id};
            # Did we get something?
            if (! $genomeData) {
                # No. Write an error notification.
                print STDERR "None found: $id\n";
            } else {
                # Yes. Print the output lines.
                for my $contigID (@$genomeData) {
                    print join("\t", $line, $contigID) . "\n";
                }
            }
        }
    }
}


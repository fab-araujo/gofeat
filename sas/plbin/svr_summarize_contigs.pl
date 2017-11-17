#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_summarize_contigs

    svr_summarize_contigs <genome_ids.tbl >genome_data.tbl

For each incoming genome ID, return statistics about its contigs.

This script takes as input a tab-delimited file with genome IDs at the end of each
line. For each genome ID, a single output line is produced containing statistics
about the genome's contigs.

This is a pipe command: the input is taken from the standard input and the output
is to the standard output.

The data fields produced for each genome (and which are appended to each output
line in this order) are as follows:

=over 4

=item 1

number of contigs

=item 2

mean contig length

=item 3

median contig length

=item 4

total number of base pairs

=item 5

total number of ambiguity characters

=item 6

total number of GC pairs

=back

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
    print "usage: svr_summarize_contigs [--url=http://...] [--c=N] <input >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # The main loop processes chunks of input.
    while (my @tuples = ScriptThing::GetBatch(\*STDIN, undef, $column)) {
        # Ask the server for results.
        my $document = $sapServer->genome_contigs(-ids => [map { $_->[0] } @tuples]);
        # Loop through the IDs, producing output.
        for my $tuple (@tuples) {
            my ($id, $line) = @$tuple;
            # Get this genome's data.
            my $contigList = $document->{$id};
            # Did we get something?
            if (! $contigList) {
                # No. Write an error notification.
                print STDERR "None found: $id\n";
            } else {
                # Yes. Get the DNA for each contig.
                my $contigHash = $sapServer->contig_sequences(-ids => $contigList);
                # We'll accumulate our base-pair totals in here.
                my ($allPairs, $ambigPairs, $gcPairs) = (0, 0, 0);
                # This will contain a list of the contig lengths.
                my @lengths;
                # Loop through the contig DNA.
                for my $contigID (@$contigList) {
                    my $dna = $contigHash->{$contigID};
                    # Record the length.
                    my $length = length $dna;
                    push @lengths, $length;
                    $allPairs += $length;
                    # Record the GC pairs.
                    $gcPairs += $dna =~ tr/gcGC//;
                    # Count the ambiguity letters.
                    $ambigPairs++ while ($dna =~ /[^agctu]/ig);
                }
                # Compute the mean and median contig length.
                my ($mean, $median);
                my $contigCount = scalar @lengths;
                if ($contigCount == 0) {
                    # If there are no contigs, we return 0 for both values.
                    $mean = 0;
                    $median = 0;
                } else {
                    # Here the mean and median have actual values. First, the mean.
                    $mean = $allPairs / $contigCount;
                    # Sort the contig lengths and locate the middle.
                    my @sorted = sort @lengths;
                    my $midPoint = int($contigCount / 2);
                    $median = $sorted[$midPoint];
                    if ($contigCount % 2 == 0) {
                        # We have an even number of contigs, so the median is between the
                        # middle values.
                        $median = ($median + $sorted[$midPoint - 1]) / 2;
                    } else {
                        # Odd number of contigs: the median is the middle value.
                        $median = $sorted[$midPoint];
                    }
                }
                # We have our analysis. Produce the output line for this genome.
                print join("\t", $line, $contigCount, $mean, $median, $allPairs, $ambigPairs, $gcPairs) . "\n";
            }
        }
    }
}


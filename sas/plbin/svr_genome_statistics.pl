#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_genome_statistics

    svr_genome_statistics fld1 fld2 ... fldN <genome_ids.tbl >genome_data.tbl

Get one or more pieces of data about each specified genome.

This script takes as input a tab-delimited file with genome IDs at the end of each
line. For each genome ID, one or more selected data items are appended to each line.

This is a pipe command: the input is taken from the standard input and the output
is to the standard output.

The data items are specified as positional parameters on the command line, and
are appended in the order specified to the output lines. The permissible data items
are as follows.

=over 4

=item complete

C<1> if the genome is more or less complete, else C<0>.

=item contigs

The number of contigs for the genome

=item dna-size

The number of base pairs in the genome

=item domain

The domain of the genome (Archaea, Bacteria, ...).

=item genetic-code

The genetic code used by this genome.

=item pegs

The number of protein encoding genes in the genome.

=item rnas

The number of RNAs in the genome.

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
    print "usage: svr_genome_statistics [--url=http://...] [--c=N] [complete | contigs | dna-size | domain | genetic-code | pegs | rnas] ... <input >output\n";
} else {
    # Get the list of output field names from the remaining positional parameters.
    my @outputs = @ARGV;
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # The main loop processes chunks of input.
    while (my @tuples = ScriptThing::GetBatch(\*STDIN, undef, $column)) {
        # Ask the server for results.
        my $document = $sapServer->genome_data(-ids => [map { $_->[0] } @tuples],
                                               -data => \@outputs);
        # Loop through the IDs, producing output.
        for my $tuple (@tuples) {
            my ($id, $line) = @$tuple;
            # Get this genome's data.
            my $genomeData = $document->{$id};
            # Did we get something?
            if (! $genomeData) {
                # No. Write an error notification.
                print STDERR "Not found: $id\n";
            } else {
                # Yes. Print an output line.
                print join("\t", $line, @$genomeData) . "\n";
            }
        }
    }
}


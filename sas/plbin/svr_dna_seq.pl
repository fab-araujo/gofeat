#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;
use SeedUtils;

#
#	This is a SAS Component.
#

=head1 svr_dna_seq

    svr_dna_seq <ids.tbl >sequences.tbl

Produce DNA strings for contigs, FIG feature IDs, and/or locations.

This script takes as input a tab-delimited file with contig IDs and locations
at the end of each line. For each one, the appropriate DNA or protein sequence
is written to the output file. If the C<--fasta> option is specified, the
sequence is written in FASTA format.

This is a pipe command: the input is taken from the standard input and the
output to the standard output. The columns of data preceding the first will be
supplied as comments to each FASTA string.

=head2 Command-Line Options

=over 4

=item fasta

If specified, the output sequences will be FASTA format, otherwise just simple character strings.
The default is FALSE. In this case the output file will look the same as the
input file but with DNA sequences tacked onto the end of each line.

=item url

The URL for the Sapling server, if it is to be different from the default.

=item c

Column index. If specified, indicates that the input IDs should be taken from the
indicated column instead of the last column. The first column is column 1.

=back

=cut

# Parse the command-line options.
my $column;
my $url;
my $fasta = 0;
my $opted =  GetOptions('fasta' => \$fasta, 'c=i', \$column, 'url=s' => \$url);
if (! $opted) {
    print "usage: svr_dna_seq [--fasta] [--url=http://...] [--c=N] <input >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # The main loop processes chunks of input 10 at a time for DNA. (This is to prevent
    # timeouts, because DNA requires serious work.)
    while (my @tuples = ScriptThing::GetBatch(\*STDIN, 10, $column)) {
        # If we're in FASTA mode, we need to create a comment hash.
        my %comments;
        if ($fasta) {
            %comments = ScriptThing::CommentHash(\@tuples);
        }
        # The Sapling Server method we're using expects a hash of labels to locations,
        # so we create one using the IDs in the input stream.
        my %idHash = map { $_->[0] => $_->[0] } @tuples;
        # Ask the server for results.
        my $document = $sapServer->locs_to_dna(-locations => \%idHash);
        # Loop through the IDs, producing output.
        for my $tuple (@tuples) {
            # Get the ID and the line.
            my ($id, $line) = @$tuple;
            # Get this ID's sequence.
            my $seq = $document->{$id};
            # Did we get something?
            if (! $seq) {
                # No. Write an error notification.
                print STDERR "Not found: $id\n";
            } elsif (! $fasta) {
                # Yes, and it's to be output as a normal sequence.
                print "$line\t$document->{$id}\n";
            } else {
                # Yes, and it's to be output in FASTA format.
                print create_fasta_record($id, $comments{$id}, $document->{$id});
            }
        }
    }
}

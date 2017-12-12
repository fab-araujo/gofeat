#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_fasta

    svr_fasta <gene_ids.tbl >sequences.tbl

Produce DNA or protein strings for genes.

This script takes as input a tab-delimited file with gene IDs at the end of
each line. For each gene ID, the gene's DNA or protein sequence is written to
the output file. If the C<--fasta> option is specified, the sequence is written
in FASTA format.

This is a pipe command: the input is taken from the standard input and the
output to the standard output. The columns of data preceding the first will be
supplied as comments to each FASTA string. In addition, if the incoming ID is
not a FIG ID, the output gene's FIG ID will be prefixed to the comment.

Note that because some gene IDs correspond to multiple genes, there may be
more output items than input lines.

=head2 Command-Line Options

=over 4

=item source

Database source of the IDs specified-- C<SEED> for FIG IDs, C<GENE> for standard
gene identifiers, or C<LocusTag> for locus tags. In addition, you may specify
C<RefSeq>, C<CMR>, C<NCBI>, C<Trembl>, or C<UniProt> for IDs from those databases.
Use C<mixed> to allow mixed ID types (though this may cause problems when the same
ID has different meanings in different databases). Use C<prefixed> to allow IDs with
prefixing indicating the ID type (e.g. C<uni|P00934> for a UniProt ID, C<gi|135813> for
an NCBI identifier, and so forth). The default is C<SEED>.

=item protein

If specified, the output FASTA sequences will be protein sequences; otherwise,
they will be DNA sequences. The default is FALSE.

=item fasta

If specified, the output sequences will be FASTA format, otherwise just simple character strings.
The default is FALSE. In this case the output file will look the same as the
input file but with DNA/protein sequences tacked onto the end of each line.

=item url

The URL for the Sapling server, if it is to be different from the default.

=item c

Column index. If specified, indicates that the input IDs should be taken from the
indicated column instead of the last column. The first column is column 1.

=back

=cut

# Parse the command-line options.
my $protein = '';
my $url;
my $fasta = 0;
my $source = '';
my $column = 0;
my $opted =  GetOptions('protein' => \$protein, 'fasta' => \$fasta,
                        'source=s' => \$source, 'url=s' => \$url,
                        'c=i' => \$column);
if (! $opted) {
    print "usage: svr_fasta [--protein] [--fasta] [--c=N] [--source=SEED] [--url=http://...] <input >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # The main loop processes chunks of input, 1000 lines at a time for proteins, 10 at
    # a time for DNA. (This is to prevent timeouts, because DNA requires more work.)
    my $batchSize = ($protein ? 1000 : 10);
    while (my @tuples = ScriptThing::GetBatch(\*STDIN, $batchSize, $column)) {
        # If we're in normal FASTA mode, we need to create a comment hash.
        my %comments;
        if ($fasta) {
            %comments = ScriptThing::CommentHash(\@tuples, $column);
        }
        # Ask the server for results.
        my $document = $sapServer->ids_to_sequences(-ids => [ map { $_->[0] } @tuples ],
                                                -protein => $protein,
                                                -fasta => $fasta,
                                                -comments => \%comments);


        # Loop through the IDs, producing output.
        for my $tuple (@tuples) {
            # Get the ID and the line.
            my ($id, $line) = @$tuple;
            # Get this feature's sequence.
            my $seq = $document->{$id};
            # Did we get something?
            if (! $seq) {
                # No. Write an error notification.
                print STDERR "Not found: $id\n";
            } elsif (! $fasta) {
                # Yes, and it's stripped. Write it at the end of the input line.
                print "$line\t$seq\n";
            } else {
                # Yes, and it's normal FASTA. Write it unaltered.
                print "$seq";
            }
        }
    }
}

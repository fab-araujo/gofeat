#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_gene_data

    svr_gene_data fld1 fld2 ... fldN <gene_ids.tbl >gene_data.tbl

Get one or more pieces of data about each specified gene.

This script takes as input a tab-delimited file with gene IDs at the end of each
line. For each gene ID, one or more selected data items are appended to each line.

This is a pipe command: the input is taken from the standard input and the output
is to the standard output.

The data items are specified as positional parameters on the command line, and
are appended in the order specified to the output lines. The permissible data items
are as follows.

If a single identifier refers to multiple genes, there will be one output line for
each gene.

=over 4

=item evidence

Comma-delimited list of evidence codes indicating the reason for the gene's
current assignment.

=item fig-id

The FIG ID of the gene.

=item function

Current functional assignment.

=item genome-name

Name of the genome containing the gene.

=item length

Number of base pairs in the gene.

=item location

Comma-delimited list of location strings indicated the location of the gene
in the genome. A location string consists of a contig ID, an underscore, the
starting offset, the strand (C<+> or C<->), and the number of base pairs.

=item publications

Comma-delimited list of PUBMED IDs for publications relating to the gene.

=back

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

=item url

The URL for the Sapling server, if it is to be different from the default.

=item c

Column index. If specified, indicates that the input IDs should be taken from the
indicated column instead of the last column. The first column is column 1.

=back

=cut

# Parse the command-line options.
my $source = 'SEED';
my $url = '';
my $column = '';
my $opted =  GetOptions('source=s' => \$source, 'url=s' => \$url, 'c=i' => \$column);
if (! $opted) {
    print "usage: svr_gene_data [--source=SEED] [--url=http://...] [--c=N] [evidence | fig-id | function | genome-name | length | location | publications] ... <input >output\n";
} else {
    # Get the list of output field names from the remaining positional parameters.
    my @outputs = @ARGV;
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # The main loop processes chunks of input.
    while (my @tuples = ScriptThing::GetBatch(\*STDIN, undef, $column)) {
        # Ask the server for results.
        my $document = $sapServer->ids_to_data(-ids => [map { $_->[0] } @tuples],
                                                -source => $source,
                                                -data => \@outputs);
        # Loop through the IDs, producing output.
        for my $tuple (@tuples) {
            my ($id, $line) = @$tuple;
            # Get this feature's data.
            my $featureData = $document->{$id};
            # Did we get something?
            if (! $featureData) {
                # No. Write an error notification.
                print STDERR "Not found: $id\n";
            } else {
                # Yes. Loop through the tuples, printing output lines.
                for my $tuple (@$featureData) {
                    print join("\t", $line, @$tuple) . "\n";
                }
            }
        }
    }
}


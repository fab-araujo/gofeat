#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_ids_to_figfams

    svr_ids_to_figfams <gene_ids.tbl >figfam_data.tbl 2> lines from input file that have no figfam 

List the FIGfams for each specified gene ID on STDOUT. List on STDERR those lines where the id does not have a FIGFam.

This script takes as input a tab-delimited file with gene IDs at the end of each
line. For each gene ID, the FIGfam containing the gene and that FIGfam's functional
role are appended to the line. The functional role is placed first and the FIGfam
is last.

If the C<--idsOnly> option is specified, then the orginal input is discarded, and
only the FIGfam ID and the role will be output. Duplicate FIGfam IDs will be
conflated, so that you get a complete list of the FIGfams covered by the input
genes.

This is a pipe command: the input is taken from the standard input and the output
is to the standard output.

Note that because some genes belong to multiple FIGfams, there may be more
output items than input lines.

=head2 Command-Line Options

=over 4

=item idsOnly

If specified, only the IDs of the FIGfams found will be output, and duplicate IDs
will be conflated. Use this to get a list of all the FIGfams for a specified
list of genes.

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
my $idsOnly = '';
my $column = 0;
my $opted =  GetOptions('idsOnly' => \$idsOnly, 'source=s' => \$source,
                        'url=s' => \$url, 'c=i' => \$column);
if (! $opted) {
    print "usage: svr_ids_to_figfams [--idsOnly] [--c=N] [--source=SEED] [--url=http://...] <input >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # If we're in ids-only mode, this hash will track the FIGfam IDs found.
    my %figFams;
    # The main loop processes chunks of input, 1000 lines at a time.
    while (my @tuples = ScriptThing::GetBatch(\*STDIN, undef, $column)) {
        # Ask the server for results.
        my $document = $sapServer->ids_to_figfams(-ids => [map { $_->[0] } @tuples],
                                                  -source => $source,
                                                  -functions => 1);
        # Loop through the IDs, producing output.
        for my $tuple (@tuples) {
            my ($id, $line) = @$tuple;
            # Get this feature's FIGfam data.
            my $results = $document->{$id};
            # Did we get something?
            if (! $results) {
                # No. Write an error notification.
                print STDERR "$line\n";
            } else {
                # Loop through the results for this ID.
                for my $result (@$results) {
                    # Get the FIGfam role and ID.
                    my ($figfam, $role) = @$result;
                    # Is this ids-only mode?
                    if ($idsOnly) {
                        # Yes, remember the ID.
                        $figFams{$figfam} = $role;
                    } else {
                        # No, print the output line.
                        print "$line\t$role\t$figfam\n";
                    }
                }
            }
        }
    }
    # We're all done. In IDs-only mode, this is where we output the
    # result.
    if ($idsOnly) {
        for my $figFam (sort keys %figFams) {
            print "$figFams{$figFam}\t$figFam\n";
        }
    }
}


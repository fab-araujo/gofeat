#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_upstream

    svr_upstream <gene_ids.tbl >upstream_dna.fasta

Retrieve upstream regions from the Sapling Server.

This script takes as input a tab-delimited file with feature IDs at the end. For
each feature ID, the upstream DNA is computed and written to the output file in
FASTA format. Sections of DNA that occur inside a feature are shown in upper
case. DNA between known features is shown in lower case.

This is a pipe command. Input is from the standard input and output is to the
standard output.

=head2 Command-Line Options

=over 4

=item skipGene

If specified, then only the upstream region is output. Otherwise, the upstream
region and the feature interior are output together.

=item size

Number of base pairs to show in the upstream region. The default is C<200>.

=item url

The URL for the Sapling server, if it is to be different from the default.

=item c

Column index. If specified, indicates that the input IDs should be taken from the
indicated column instead of the last column. The first column is column 1.

=back

=cut

# Parse the command-line options.
my $skipGene = '';
my $size = 200;
my $url = '';
my $column = 0;
my $opted =  GetOptions('skipGene' => \$skipGene, 'size=i' => \$size, 'url=s' => \$url,
                        'c=i' => \$column);
if (! $opted) {
    print "usage: svr_upstream [--skipGene] [--c=N] [--size=200] [-url=http://...] <input >output\n";
} else {
    # Fix STDIN.
    ScriptThing::AdjustStdin();
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # The main loop processes chunks of input, 1000 lines at a time.
    while (my @tuples = ScriptThing::GetBatch(\*STDIN, undef, $column)) {
        # Compute the comment strings.
        my %comments = ScriptThing::CommentHash(\@tuples);
        # Ask the server for results.
        my $document = $sapServer->upstream(-ids => [ map { $_->[0] } @tuples],
                                            -size => $size,
                                            -fasta => 1,
                                            -comments => \%comments,
                                            -skipGene => $skipGene);
        # Loop through the tuples, producing output.
        for my $tuple (@tuples) {
            # Get the feature ID.
            my $fid = $tuple->[0];
            # Get this feature's FASTA.
            my $fasta = $document->{$fid};
            # Did we get something?
            if (! $fasta) {
                # No. Write an error notification.
                print STDERR "Not found: $fid\n";
            } else {
                # Yes. output the FASTA.
                print "$fasta";
            }
        }
    }
}





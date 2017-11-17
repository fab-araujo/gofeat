#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;
use SeedUtils;

#
#	This is a SAS Component.
#

=head1 svr_figfam_fasta

    svr_figfam_fasta <figfam_ids.tbl >genes.fasta

Produce FASTA strings for FIGfams.

This script takes as input a tab-delimited file with FIGfam IDs at the end of
each line. For each FIGfam ID, all the genes in the FIGfam are written to the
output file in FASTA format. The FIGfam ID will be included as the FASTA
comment.

This is a pipe command: the input is taken from the standard input and the
output is to the standard output.

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
my $column = 0;
my $opted =  GetOptions('url=s' => \$url, 'c=i' => \$column);
if (! $opted) {
    print "usage: svr_figfam_fasta [--url=http://...] [--c=N] <input >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # The main loop processes chunks of input one line at a time.
    while (my @tuples = ScriptThing::GetBatch(\*STDIN, 1, $column)) {
        my $ffid = $tuples[0][0];
        # Ask the server for the FASTA strings.
        my $document = $sapServer->figfam_fids(-id => $ffid,
                                               -fasta => 1);
        # Write out the results.
        print join("", @$document);
    }
}


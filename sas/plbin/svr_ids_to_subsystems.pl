#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_ids_to_subsystems

    svr_ids_to_subsystems <gene_ids.tbl >subsystems.tbl 2> lines from input file having no subsystem match

List the subsystems for each specified gene ID STDOUT. List on STDERR those lines where the id does not have a subsystem.


This script takes as input a tab-delimited file with gene IDs at the end of each
line. For each gene ID, the subsystem containing the gene is appended to the
line.

This is a pipe command: the input is taken from the standard input and the output
is to the standard output.

Note that because some genes belong to multiple subsystems, there may be more
output items than input lines.

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

=item showRoles

Include the subsystem role in the output. The role will appear after the subsystem
name.

=item c

Column index. If specified, indicates that the input IDs should be taken from the
indicated column instead of the last column. The first column is column 1.

=back

=cut

# Parse the command-line options.
my $source = 'SEED';
my $url = '';
my $column = 0;
my $showRoles;
my $opted =  GetOptions('source=s' => \$source, 'url=s' => \$url, 'c=i' => \$column,
                        showRoles => \$showRoles);
if (! $opted) {
    print "usage: svr_ids_to_subsystems [--source=SEED] [--showRoles] [--url=http://...] [--c=N] <input >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # The main loop processes chunks of input, 1000 lines at a time.
    while (my @tuples = ScriptThing::GetBatch(\*STDIN, undef, $column)) {
        # Ask the server for results.
        my $document = $sapServer->ids_to_subsystems(-ids => [map { $_->[0] } @tuples],
                                                     -source => $source);
        # Loop through the IDs, producing output.
        for my $tuple (@tuples) {
            my ($id, $line) = @$tuple;
            # Get this feature's subsystem data.
            my $results = $document->{$id};
            # Did we get something?
            if (! $results) {
                # No. Write an error notification.
                print STDERR "$line\n";
            } else {
                # Loop through the results for this ID.
                for my $result (@$results) {
                    # Get the subsystem ID.
                    my ($role, $subsystem) = @$result;
                    # Add the role if the user wants it.
                    if ($showRoles) {
                        $subsystem .= "\t$role";
                    }
                    # Print the output line.
                    print "$line\t$subsystem\n";
                }
            }
        }
    }
}


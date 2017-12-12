#!/usr/bin/perl -w

use strict;

use SeedEnv;
use Getopt::Long;

#
#	This is a SAS Component.
#

=head1 svr_ach_lookup

    svr_ach_lookup <gene_ids.tbl >assertions.tbl

Find protein assertions from the Annotation Clearinghouse.

This script takes as input a tab-delimited file with gene or protein IDs at the
end of each line. For each ID, the assertions related to the identified protein
sequence are returned in another tab-delimited file. Assertions for all genes
that have the same sequence as the identified protein will be returned.

The IDs should be in prefixed form, e.g. C<cmd|4808340>, C<gi|21221828>,
C<uni|Q9X8I1>.

This is a pipe command: the input is taken from the standard input and the
output is to the standard output. The output columns are

=over 4

=item 1

The incoming ID.

=item 2

The ID of the gene whose assertion was found in the database.

=item 3

The text of the assertion.

=item 4

The source of the assertion, usually a user name or institution identifier.

=item 5

A flag that is TRUE if the assertion is by a human expert, else FALSE.

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

my $url = '';
my $column = 0;
my $opted =  GetOptions('url=s' => \$url, 'c=i' => \$column);
if (! $opted) {
    print "usage: svr_ach_lookup [--url=http://...] [--c=N] <input >output\n";
} else {
    ScriptThing::AdjustStdin();
    my $sap = SAPserver->new(url => $url);
    # The main loop processes chunks of input.
    while (my @tuples = ScriptThing::GetBatch(\*STDIN, undef, $column)) {
        # Ask the server for results.
        my $id_hash = $sap->equiv_sequence_assertions(-ids => [ map { $_->[0] } @tuples ]);
        for my $tuple (@tuples) {
            my ($id, $line) = @$tuple;
            for my $entry (@{$id_hash->{$id}}) {
                print join("\t", $line, @$entry) . "\n";
            }
        }
    }
}


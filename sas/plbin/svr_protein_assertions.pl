#!/usr/bin/perl -w 

use SAPserver;
use Getopt::Long;
use ScriptThing;

# This is a SAS Component

=head1 svr_protein_assertions

    svr_protein_assertions <gene_ids.tbl >assertion_data.tbl

Get a list of Annotation Clearinghouse assertions for the specified proteins.

The standard input should be a tab-delimited file with IDs in the last column.
The IDs should be prefixed protein or gene IDs (e.g. C<uni|AYQ44>,
C<fig|360108.3.peg.1041>, C<md5|4a+6lQzFY8hRkQyWPliFjw>). For each of these
identifiers, this script will search for an identifier in the Annotation
Clearinghouse with an identical protein sequence that has an
associated functional assignment. For that identifier, the
following fields will be returned.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=over 4

=item 1

The identifier found.

=item 2

The scientific name of the associated genome (if any).

=item 3

C<1> if we believe the identifier corresponds to the exact gene identified by
the input identifier, else C<0>. If the input identifier does not specify a
particular gene, this column will always be C<0>.

=item 4

The functional assignment associated with the protein ID.

=item 5

The source of the assignment.

=item 6

C<1> if the assignment is considered expert, else C<0>.

=back

The net effect is that for each identifier, we find the assignments for
protein-equivalent identifiers in the annotation clearinghouse. Because
there are many identifiers that produce the same protein sequence, each
input line will generate multiple output lines.

=head2 Command-Line Options

=over 4

=item url

The URL for the Annotation Clearinghouse server, if it is to be different from the default.

=back

=cut

# Parse the command-line options.
my $url = '';
my $opted =  GetOptions('url=s' => \$url);
if (! $opted) {
    print "usage: svr_protein_assertions [--url=http://...] <input >output\n";
} else {
    # Get the server objects.
    my $achObject = SAPserver->new(url => $url);
    # The main loop processes chunks of input, 100 lines at a time.
    while (my @tuples = ScriptThing::GetBatch(\*STDIN, 100)) {
        # Get the IDs from the input tuples.
        my @ids = map { $_->[0] } @tuples;
        # Get the precisely-equivalent assertions. We use these to build a
        # hash that tells us which identifiers are precisely equivalent to
        # the input identifiers.
        my $precise_hash = $achObject->equiv_precise_assertions(-ids => \@ids);
        my %preciseHash;
        for my $precise_id (keys %{$precise_hash}) {
                my ($newID, $function, $source, $expert) = $precise_hash->{$precise_id}; 
                $preciseHash{$precise_id}{$newID} = 1;
	}	

        # Get the sequence-equivalent assertions. These are our output.
        my $assertionHash = $achObject->equiv_sequence_assertions(-ids => \@ids, -hash => 1);
        # Now we get the genome names for output column 2.
        my @otherIDs;
        for my $assertionList (values %$assertionHash) {
            push @otherIDs, map { $_->[0] } @$assertionList;
        }
        # Generate this batch of output.
        for my $tuple (@tuples) {
            # Get the ID and text for this input line.
            my ($id, $line) = @$tuple;
            # Get the assertions for this ID.
            my $assertions = $assertionHash->{$id};
            if (! $assertions || !@$assertions) {
                print STDERR "No results for $id.\n";
            } else {
                # Loop through the assertions, generating output lines.
                for my $assertion (@$assertions) {
                    my ($newID, $function, $source, $expert, $genomeName) = @$assertion;
                    # To avoid a run-time warning, insure we have a genome name.
                    $genomeName = '' if ! defined $genomeName;
                    # Compute the same-gene flag.
                    my $column3 = ($preciseHash{$id}{$newID} ? 1 : 0);
                    # Assemble this output line.
                    print join("\t", $line, $newID, $genomeName, $column3, $function, $source,
                                     $expert) . "\n";
                }
            }
        }
        # This completes the current batch.
    }
}

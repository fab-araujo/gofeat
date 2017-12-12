use strict;

use Getopt::Long;
use SeedEnv;

#
# This is a SAS Component
#


=head1 svr_close_genomes

List the IDs of the genomes that are functionally close to the input genomes.

    svr_close_genomes < genomes.tbl > close_genomes.tbl

This script takes as input a tab-delimited file with genome IDs at the end of each
line. For each genome ID, multiple output lines are produced containing the ID and
score of each functionally close genome found.

This is a pipe command: the input is taken from the standard input and the output
is to the standard output.

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
    print "usage: svr_close_genomes [--url=http://...] [--c=N] <input >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # The main loop processes chunks of input.
    while (my @tuples = ScriptThing::GetBatch(\*STDIN, 2, $column)) {
        # Ask the server for results.
        my $document = $sapServer->close_genomes(-ids => [map { $_->[0] } @tuples]);
        # Loop through the IDs, producing output.
        for my $tuple (@tuples) {
            my ($id, $line) = @$tuple;
            # Get this genome's data.
            my $genomeData = $document->{$id};
            # Did we get something?
            if (! $genomeData) {
                # No. Write an error notification.
                print STDERR "None found: $id\n";
            } else {
                # Yes. Loop through the genomes found.
                for my $pair (@$genomeData) {
                    # Get the genome ID and score.
                    my ($genomeID, $score) = @$pair;
                    print join("\t", $line, $genomeID, $score) . "\n";
                }
            }
        }
    }
}

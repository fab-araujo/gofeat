#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_subsystem_genome_data

    svr_subsystem_genome_data --genomeFile=genomes.tbl <sub_ids.tbl >sub_data.tbl

Output the features, variants, and roles for one or more subsystems, optionally
filtered by genome ID.

This script takes as input a tab-delimited file with subsystem IDs at the end of each
line. For each subsystem ID, numerous output lines are produced describing the contents
of the subsystem. Each line will consist of

=over 4

=item 1

Subsystem ID

=item 2

Genome ID (possibly with a region code)

=item 3

Code for the variant of this subsystem used by the genome.

=item 4

ID of a subsystem role.

=item 5

ID of a feature performing the role.

=back

This is a pipe command: the input is taken from the standard input and the output
is to the standard output.

=head2 Command-Line Options

=over 4

=item url

The URL for the Sapling server, if it is to be different from the default.

=item c

Column index. If specified, indicates that the input subsystem IDs should be taken from the
indicated column instead of the last column. The first column is column 1.

=item genomeFile

If specified, the name of a tab-delimited file containing genome IDs in the last
column. Only data relating to the specified genomes will be included in the output.


=back

=cut

# Parse the command-line options.
my $url = '';
my $column = '';
my $genomeFile = '';
my $opted =  GetOptions('url=s' => \$url, 'c=i' => \$column, 'genomeFile=s' => \$genomeFile);
if (! $opted) {
    print "usage: svr_subsystem_genome_data [--url=http://...] [--c=N] [--genomeFile=genomes.tbl] <input >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # Get the list of genomes.
    my @genomes;
    if ($genomeFile) {
        open my $ih, "<$genomeFile" || die "Cannot open genome file: $!";
        @genomes = ScriptThing::GetList($ih);
    }
    # The main loop processes chunks of input. We only do 5 at a time because this is a
    # slow process.
    while (my @tuples = ScriptThing::GetBatch(\*STDIN, 5, $column)) {
        # Ask the server for results.
        my $document = $sapServer->pegs_in_variants(-subsystems => [map { $_->[0] } @tuples],
                                                    -genomes => \@genomes);
        # Loop through the IDs, producing output.
        for my $tuple (@tuples) {
            my ($sub, $line) = @$tuple;
            # Get this subsystems's data.
            my $ssData = $document->{$sub};
            # Did we get something?
            if (! $ssData) {
                # No. Write an error notification.
                print STDERR "Not found: $sub\n";
            } else {
                # Yes. We must run through the results producing output.
                for my $genome (sort keys %$ssData) {
                    # Get this genome's row information.
                    my $genomeData = $ssData->{$genome};
                    # Pop off the variant code.
                    my $vc = shift @$genomeData;
                    # Loop through the cells.
                    for my $cell (@$genomeData) {
                        # Get this cell's role.
                        my $role = shift @$cell;
                        # Loop through the features in the cell.
                        for my $fid (@$cell) {
                            print join("\t", $sub, $genome, $vc, $role, $fid) . "\n";
                        }
                    }
                }
            }
        }
    }
}


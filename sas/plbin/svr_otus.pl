use strict;

use Getopt::Long;
use SeedEnv;

#
# This is a SAS Component
#


=head1 svr_otus

List the names and IDs of all the representative genomes for the organism taxonomic units in
the system.

There is no input.  The output is a file of genome names and genome IDs.

------
Example: svr_otus > complete_genomes.tbl

would produce a 2-column table.  The first column would contain the
names of all representative genomes, and the second the IDs of those genomes.
------

=head2 Command-Line Options

=over 4

=item url

The URL for the Sapling server, if it is to be different from the default.

=back

=head2 Output Format

The standard output is a file where each line contains a genome name and a genome ID.

=cut

my $usage    = "usage: svr_otus [--url=http://...] >output\n";
my $url = '';
my $opted    = GetOptions('url=s', \$url);

if (! $opted) {
    print $usage;
} else {
    # Get the OTU mappings.
    my $sapObject  = SAPserver->new(url => $url);
    my $mappings = $sapObject->representative_genomes();
    my $sets = $mappings->[1];
    # Extract the representative genome IDs.
    my @genomes = map { $sets->{$_}->[0] } keys %$sets;
    # Get the genome names.
    my $genomeHash = $sapObject->genome_names(-ids => \@genomes);
    # Output the results.
    for my $genome (sort { $a <=> $b } keys %$genomeHash) {
        print "$genomeHash->{$genome}\t$genome\n";
    }
}

#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_closest_genes

    svr_closest_genes [--protein] genome sequence

Locate genes in a specified genome containing the specified protein or DNA sequence.

The output will be a tab-delimited file. For each gene containing the specified
protein or DNA sequence, a line will be output containing the location of the
gene found, the location of the match, and the FIG ID of the gene.

The specified sequence cannot contain ambiguity characters. In DNA sequences,
C<U> will be translated automatically to C<T>.

=head2 Command-Line Options

=over 4

=item url

The URL for the Sapling server, if it is to be different from the default.

=item protein

If specified, the sequence will be assumed to be a protein sequence; otherwise, it
will be assumed to be a DNA sequence unless it contains characters other than C<A>,
C<C>, C<G>, C<T>, or C<U>.

=back

=cut

# Parse the command-line options.
my $url = '';
my $protein = 0;
my $opted =  GetOptions('url=s' => \$url, 'protein' => \$protein);
# Get the positional parameters.
my ($genome, $sequence) = @ARGV;
if (! $opted || ! $genome || ! $sequence) {
    print "usage: svr_closest_genes [--url=http://...] [--protein] genome sequence >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # Find out if this is a protein.
    if (! $protein && $sequence =~ /[^acgtuACGTU]/) {
        $protein = 1;
    }
    # Ask the sapling server about the sequence.
    my $document = $sapServer->find_closest_genes(-genome => $genome, -protein => $protein,
                                                  -seqs => { seq => $sequence });
    # Get the list of hits.
    my $hitList = $document->{seq};
    # Only proceed if we found some.
    if ($hitList) {
        # Output the hits.
        for my $hit (@$hitList) {
            print join("\t", $hit->[1], $hit->[2], $hit->[0]) . "\n";
        }
    }
}


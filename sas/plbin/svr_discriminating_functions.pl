#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_discriminating_functions

    svr_discriminating_functions genome_ids1.tbl genome_ids2.tbl >role_list.tbl

Analyze two groups of genomes and return a list of the functions that discriminate
between them.

A function discriminates between two groups of genomes if it is common in one and
uncommon in the other.

This script takes as input two tab-delimited files with genome IDs at the end of each
line. It writes out a single tab-delimited file with four columns.

Alternatively, the script can be used as a pipe command. If no positional parameters
are specified, the first group will be taken from the standard input.

If no second group is specified, then the second group will be all complete
genomes not in the first group. Optionally, it can be all prokaryotic complete
genomes not in the first group.

=over 4

=item 1

The FIGfam ID of a function.

=item 2

The function of the identified FIGfam.

=item 3

A score indicating the degree of discrimination. A score of 2 indicates the function
occurs universally in one group and not at all in the other. All scores will be
greater than 1 

=item 4

C<1> if the function tends to be in the first group and C<2> if it tends to be in
the second.

=back

The output will be sorted by the fourth column, so the results will be presented with
the roles discriminating in favor of the first group followed by the roles discriminating
in favor of the second group.

=head2 Command-Line Options

=over 4

=item url

The URL for the Sapling server, if it is to be different from the default.

=item c

Column index. If specified, indicates that the input IDs should be taken from the
indicated column instead of the last column. The first column is column 1. This
parameter applies to both input files.

=item prok

If specified, and if no second group is present, the second group will be limited to
prokaryotic genomes.

=back

=cut

# Parse the command-line options.
my $url = '';
my $column = '';
my $prok;
my $opted =  GetOptions('url=s' => \$url, 'c=i' => \$column, prok => \$prok);
if (! $opted) {
    print "usage: svr_discriminating_functions [--url=http://...] [--c=N] group1 group2 >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # Get the genome lists.
    my ($g1File, $g2File) = @ARGV;
    my ($group1, $group2);
    if ($g1File) {
        # Here the first group is specified in a file.
        $group1 = GetGenomes($g1File, $column);
    } else {
        # Here the first group is taken from the standard input.
        $group1 = [ ScriptThing::GetList(\*STDIN, $column) ];
    }
    if ($g2File) {
        # Here the second group is specified in a file.
        $group2 = GetGenomes($g2File, $column);
    } else {
        # Here the second group is the complement of the first. Get a hash of the genomes
        # in the first group.
        my %g1Hash = map { $_ => 1 } @$group1;
        # Get the list of genomes to be used for the second group.
        my $allGenomes = $sapServer->all_genomes(-prokaryotic => $prok, -complete => 1);
        # The returned list is a hash. Filter its keys to produce group 2.
        $group2 = [ grep { ! $g1Hash{$_ } } keys %$allGenomes ];
    }
    # Compute the discriminating figfams.
    my $groupList = $sapServer->discriminating_figfams(-group1 => $group1,
                                                       -group2 => $group2);
    # Output the groups.
    for my $i (1, 2) {
        # Get the current group's hash.
        my $groupH = $groupList->[$i-1];
        # Get the functions for the indicated FIGfams.
        my $famH = $sapServer->figfam_function(-ids => [keys %$groupH]);
        # Loop through the FIGfams in this section.
        for my $fam (sort keys %$groupH) {
            # Write out this FIGfam's data.
            print join("\t", $fam, $famH->{$fam}, $groupH->{$fam}, $i) . "\n";
        }
    }
}


# Get a genome list.
sub GetGenomes {
    # Get the file name and column ID.
    my ($fileName, $column) = @_;
    # Try to open the file.
    open my $gh, "<$fileName" || die "Genome file error: $!";
    # Get the input data.
    my @retVal = ScriptThing::GetList($gh, $column);
    # Return the result.
    return \@retVal;
}


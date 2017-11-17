#!/usr/bin/perl -w
use strict;
use SeedEnv;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_figfams_to_ids

    svr_figfams_to_ids [Genome1 Genome2 ... GenomeN] < figfams.tbl > with_pegs.tbl 

List the PEGs for each specified FIGfam ID on STDOUT. 

This script takes as input a tab-delimited file with FIGfam IDs at the end of each
line. For each FIGfam ID, the PEGs in the FIGfam (restricted to specified Genomes, if present)
are returned.

This is a pipe command: the input is taken from the standard input and the output
is to the standard output.

Note that because some FIGfams contain multiple PEGs, there may be more
output items than input lines.

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
my $source = 'SEED';
my $url = '';
my $idsOnly = '';
my $column = 0;
my $opted =  GetOptions( 'url=s' => \$url, 'c=i' => \$column);

if (! $opted) {
    print "usage: svr_figfams_to_ids [--c=N] [--url=http://...] [G1 G2 ...] <input >output\n";
} else {
    my %genomes;
    if (@ARGV > 0) { %genomes = map { $_ => 1 } @ARGV }

    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # The main loop processes chunks of input, 1000 lines at a time.
    while (my @tuples = ScriptThing::GetBatch(\*STDIN, undef, $column)) {
	my @tuples1;
	my $seen = {};
	foreach my $request (@tuples)
	{
	    if (! $seen->{$request->[0]}) { push(@tuples1,$request); $seen->{$request->[0]} = 1 }
	}

        # Ask the server for results.
	my $pegHash = $sapServer->figfam_fids_batch(-ids => [map { $_->[0] } @tuples1]);
        for my $tuple (@tuples) {
            my ($ff, $line) = @$tuple;
	    my $pegs = $pegHash->{$ff};
	    foreach my $peg (@$pegs)
	    {
		if ((@ARGV == 0) || $genomes{&SeedUtils::genome_of($peg)})
		{
                        print "$line\t$peg\n";
                }
            }
        }
    }
}


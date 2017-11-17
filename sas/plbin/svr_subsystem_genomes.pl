#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_subsystem_genomes

    svr_subsystem_genomes "subsystem ID" >sub_data.tbl

Output the genomes of a subsystem.

This script takes as input a subsystem name on the command line and produces a
tab-delimited file of all the genomes that use the subsystem and their
variant codes. Each line of the file will contain the genome ID first and then
the variant code. The output will be produced on the standard output.

Note that because the subsystem name likely contains spaces, it will need to be
enclosed in quotes on the command-line.

=head2 Command-Line Options

=over 4

=item url

The URL for the Sapling server, if it is to be different from the default.

=item all

If specified, all genomes associated with the subsystem will be included in the output.
Normally, only genomes that completely implement the subsystem will be listed.

=back

=cut

# Parse the command-line options.
my $url = '';
my $all;
my $opted =  GetOptions('url=s' => \$url, all => \$all);
my $subID = $ARGV[0];
if (! $opted || ! $subID) {
    print "usage: svr_subsystem_genomes [--url=http://...] [--all] \"subsystem name\" >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # Get the roles.
    my $subHash = $sapServer->subsystem_genomes(-ids => $subID, -all => $all);
    # Loop through them, producing output.
    my $genomeHash = $subHash->{$subID};
    if (! $genomeHash) {
        print STDERR "Could not find \"$subID\".\n";
    } else {
        for my $genome (sort { $a <=> $b } keys %$genomeHash) {
            print "$genome\t$genomeHash->{$genome}\n";
        }
    }
}


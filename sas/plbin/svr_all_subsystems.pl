#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SeedEnv;

#
#	This is a SAS Component.
#

=head1 svr_all_subsystems

    svr_all_subsystems >subsystem_list.tbl

Get all the subsystem names.

This script creates a flat file containing all the subsystem names.

=head2 Command-Line Options

=over 4

=item clusterBased

If specified, then cluster-based subsystems will be included in the list.

=item unusable

If specified, then unusable subsystems will be included in the list.

=item url

The URL for the sapling server, if it is to be different from the default.

=back

=cut

# Parse the command-line options.
my $clusterBased = '';
my $unusable = '';
my $url = '';
my $opted =  GetOptions('unusable' => \$unusable, 'clusterBased' => \$clusterBased,
			'url=s' => \$url);
if (! $opted) {
    print "usage: svr_all_subsystems [--unusable] [--clusterBased] [-url=http://...] >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # Compute the exclusion list.
    my $excludes = [];
    if (! $clusterBased) {
	$excludes = ['cluster-based'];
    }
    # Convert the usability flag.
    my $usable = ($unusable ? 0 : 1);
    # Ask the server for results.
    my $document = $sapServer->subsystem_names(-exclude => $excludes,
					       -usable => $usable);
    # Loop through the return list, producing output.
    for my $ssname (sort @$document)
    {
	print "$ssname\n";
    }
}




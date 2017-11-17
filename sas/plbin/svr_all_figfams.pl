#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_all_figfams

    svr_all_figfams >figfam_data.tbl

List all the features in each FIGfam.

This is a very simple script that loops through all the FIGfams locating the features
in each. For each feature found, it will output a line containing the FIGfam ID followed
by the feature ID with an intervening tab.

The output will be large, since every feature in a FIGfam will be listed. A feature
that is in more than one FIGfam (if one exists) will appear once for each FIGfam.

=head2 Command-Line Options

=over 4

=item url

The URL for the Sapling server, if it is to be different from the default.

=back

=cut

# Parse the command-line options.
my $url = '';
my $opted =  GetOptions('url=s' => \$url);
if (! $opted) {
    print "usage: svr_all_figfams [--url=http://...] >output\n";
} else {
    # Get the server object.
    my $sapObject = SAPserver->new(url => $url);
    # Get the complete list of FIGfams.
    my $ffHash = $sapObject->all_figfams();
    # Loop through them in lexical order.
    for my $figfam (sort keys %$ffHash) {
        # Get all the features in this FIGfam.
        my $fidList = $sapObject->figfam_fids(-id => $figfam);
        # Loop through the features, writing them to the output.
        for my $fid (@$fidList) {
            print "$figfam\t$fid\n";
        }
    }
}


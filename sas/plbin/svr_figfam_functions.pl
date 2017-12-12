#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;
use SeedUtils;

#
#	This is a SAS Component.
#

=head1 svr_figfam_functions

    svr_figfam_functions <figfam_ids.tbl >figfam_functions.tbl

Output the functions for the specified FIGfams.

This script takes as input a tab-delimited file with FIGfam IDs at the end of
each line. For each FIGfam ID, the FIGfam's function will be appended to the list.

This is a pipe command: the input is taken from the standard input and the
output is to the standard output. Alternatively, a list of FIGfan IDs can be
specified as command-line parameters.

=head2 Command-Line Options

=over 4

=item url

The URL for the Sapling server, if it is to be different from the default.

=item c

Column index. If specified, indicates that the input IDs should be taken from the
indicated column instead of the last column. The first column is column 1.

=item all

Instead of reading FIGfam IDs from the input, all FIGfams will be listed.

=back

=cut

# Parse the command-line options.
my $url = '';
my $column = 0;
my $all = 0;
my $opted =  GetOptions('url=s' => \$url, 'c=i' => \$column, 'all' => \$all);
if (! $opted) {
    print "usage: svr_figfam_functions [--url=http://...] [--c=N] [--all] <input >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    my $input;
    if ($all) {
        # Here the user wants all the FIGfams. This is accomplished with a different
        # call than the normal script.
        my $ffHash = $sapServer->all_figfams();
        for my $ff (sort keys %$ffHash) {
            print "$ff\t$ffHash->{$ff}\n";
        }
    } else {
        # Here the user wants selected FIGfams. Find out if we're getting input
        # from STDIN or the command line.
        my $input = (@ARGV ? [@ARGV] : \*STDIN);
        # The main loop processes chunks of input.
        while (my @tuples = ScriptThing::GetBatch($input, undef, $column)) {
            # Ask the server for results.
            my $document = $sapServer->figfam_function(-ids => [map { $_->[0] } @tuples]);
            # Loop through the IDs, producing output.
            for my $tuple (@tuples) {
                my ($id, $line) = @$tuple;
                # Get this FIGfam's function.
                my $function = $document->{$id};
                # Did we get something?
                if (! $function) {
                    # No. Write an error notification.
                    print STDERR "Not found: $id\n";
                } else {
                    # Yes. Write it out.
                    print "$line\t$function\n";
                }
            }
        }
    }
}


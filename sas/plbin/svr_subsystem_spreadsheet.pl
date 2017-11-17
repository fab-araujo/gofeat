#!/usr/bin/perl -w
use strict;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_subsystem_spreadsheet

    svr_subsystem_spreadsheet "subsystem ID" >sub_data.tbl

Output a subsystem's spreadsheet.

This script takes as input a subsystem name on the command line and produces a
tab-delimited file that organizes the features of the subsystem by genome and role.
There will be one output line per genome. The first column will contain the genome ID,
the second the relevant variant code, and then each other column will correspond to one
of the subsystem's roles (effectively, a spreadsheet cell). The features performing the
role in the subsystem will be placed in the appropriate position as a comma-delimited list.

Note that because the subsystem name likely contains spaces, it will need to be
enclosed in quotes on the command-line.

=head2 Command-Line Options

=over 4

=item url

The URL for the Sapling server, if it is to be different from the default.

=item aux

If specified, auxiliary roles will be included in the output. Normally these are
excluded.

=back

=cut

# Parse the command-line options.
my $url = '';
my $aux;
my $opted =  GetOptions('url=s' => \$url, aux => \$aux);
my $subID = $ARGV[0];
if (! $opted || ! $subID) {
    print "usage: svr_subsystem_spreadsheet [--url=http://...] [--aux] \"subsystem name\" >output\n";
} else {
    # Get the server object.
    my $sapServer = SAPserver->new(url => $url);
    # Get the roles.
    my $subHash = $sapServer->subsystem_roles(-ids => $subID, -aux => $aux, -abbr => 1);
    my $roles = $subHash->{$subID};
    if (! $roles) {
        print STDERR "Could not find \"$subID\".\n";
    } else {
        # Build a hash that maps role IDs to role indices.
        my %roleHash;
        for (my $i = 0; $i < @$roles; $i++) {
            $roleHash{$roles->[$i][0]} = $i;
        }
        # Now get the subsystem's genomes and features.
        $subHash = $sapServer->pegs_in_variants(-subsystems => $subID);
        # Loop through the genomes, producing spreadsheet rows.
        my $genomeHash = $subHash->{$subID};
        for my $genome (sort { $a <=> $b } keys %$genomeHash) {
            # Get the row for this genome.
            my $ssRow = $genomeHash->{$genome};
            # Yank out the variant code.
            my $variant = shift @$ssRow;
            # The spreadsheet cells will be put in here.
            my @cells;
            # Now we loop through the row, putting feature IDs in cells.
            for my $ssCell (@$ssRow) {
                # Get the role ID and the features;
                my ($role, @fids) = @$ssCell;
                # If this role is one we're interested in, put the features in the cell.
                my $cellIndex = $roleHash{$role};
                if (defined $cellIndex) {
                    $cells[$cellIndex] = join(', ', @fids);
                }
            }
            # Form all the cells into an output line.
            my $line = join("\t", $genome, $variant, map { $_ || '' } @cells);
            print "$line\n";
        }
    }
}

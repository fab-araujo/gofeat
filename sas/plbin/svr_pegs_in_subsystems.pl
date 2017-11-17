#!/usr/bin/perl -w 

use SAPserver;
use Getopt::Long;

# This is a SAS Component

=head1 svr_pegs_in_subsystems

    svr_pegs_in_subsystems genome_ids.tbl <subsystem_ids.tbl >peg_role_data.tbl

Return all genes in one or more subsystems found in one or more genomes.

This script takes a list of genomes and a list of subsystems and returns a list
of the genes represented in each genome/subsystem pair. It takes one positional
parameter-- the name of the file containing the genome IDs, and reads the list
of subsystem IDs from the standard input.

The standard output will be a tab-delimited file, each record containing a
subsystem ID, a functional role in that subsystem, and the ID of a gene with
that role from one of the supplied genomes.

This is a pipe command. The input is from the standard input and the output is
to the standard output.

The following command-line options are supported.

=over 4

=item group

If specified, then each output line will be for a single role, and the gene IDs will
be listed as a single comma-delimited string.

=item noroles

If specified, then the second column in each output line (functional role) will be
omitted from the output.

=item url

The URL for the Sapling server, if it is to be different from the default.

=back

=cut

my $noroles = 0;
my $group = 0;
my $show_owner = 0;
my $oldid = "";
my $url = "";

$0 =~ m/([^\/]+)$/;
my $self = $1;
my $usage = "$self [--noroles --group --url=http://...] GenomeF < SubsystemIDs";

my $rc = GetOptions("noroles" => \$noroles, "group" => \$group, "url=s" => \$url);

if (!$rc) {
    die "\n   usage: $usage\n\n";
}

my $roles = $noroles ? 0 : 1;
my $ss = SAPserver->new(url => $url);

open GENOMES, "<" . $ARGV[$#ARGV] || die "Genome file error: $!";

my @genomes;
my @subs;
while (<GENOMES>) {
    chomp;
    push (@genomes, $_);
}
while (<STDIN>) {
    chomp;
    push (@subs, $_);
}

my $pegs_inss = $ss->pegs_in_subsystems(\@genomes, \@subs);
if ($roles) {
    foreach my $ss_role (@{$pegs_inss}) { #foreach subsystem/role
        #(ss, role, (peg))
        if ($group) {
            print $ss_role->[0], "\t", $ss_role->[1]->[0], "\t", join (",", @{$ss_role->[1]->[1]}), "\n";
        } else {
            foreach my $peg (@{$ss_role->[1]->[1]}) { #foreach peg in this peg list
                print join("\t", ($ss_role->[0], $ss_role->[1]->[0], $peg)), "\n";
            }
        }
    }

} else { # no roles
    my %ss_pegs;
    foreach my $ss_role (@{$pegs_inss}) {
        foreach my $peg (@{$ss_role->[1]->[1]}) {
            $ss_pegs{$ss_role->[0]}{$peg} = 1;
        }
    }
    for my $ss (keys %ss_pegs) {
        if ($group) {
            print $ss, "\t", join(",", keys %{$ss_pegs{$ss}}), "\n";
        } else {
            foreach my $peg (keys %{$ss_pegs{$ss}}) {
                print join("\t", $ss, $peg), "\n";
            }
        }
    }
}


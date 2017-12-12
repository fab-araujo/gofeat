#!/usr/bin/perl

#
#	This is a SAS Component.
#

=head1 svr_determine_sets_of_related_contigs

    svr_determine_sets_of_related_contigs username password <contig_ids.tbl >output.tbl

This takes as input a list of contig IDs. What is the output?

=cut

use Data::Dumper;
use RASTserver;
use strict;

my $username = shift;
my $password = shift;

my $rast = new RASTserver($username, $password);

my @input_ids = <STDIN>;
chomp @input_ids;

my %seen;
for my $id (@input_ids)
{
    next if $seen{$id};

    my $res = $rast->get_contig_ids_in_project_from_entrez({ -contig_id => $id } );
    # print Dumper($res);
    my $project_ids = $res->{ids};
    my $redundancies = $res->{redundancy_report};

#    my($project_ids, $redundancies) = $rast->get_contig_ids_in_project_from_entrez({ -contig_id => $id } );
    if (@$redundancies)
    {
	for my $redundancy (@$redundancies)
	{
	    print STDERR join("\t", @$redundancy), "\n";
	}
    }
    else
    {
	print join(",", @$project_ids), "\n";
	map { $seen{$_} = 1 } @$project_ids;
    }
}

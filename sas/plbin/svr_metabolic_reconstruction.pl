#!/usr/bin/perl -w 

# This is a SAS Component

use ANNOserver;
use Getopt::Long;
use strict;
use SeedAware;

=head1 svr_metabolic_reconstruction

Get a metabolic reconstruction from a set of functional roles.

By a metabolic reconstruction we mean a detailed list of subsystems
that we believe are present in a genome or environmental sample, along
with the specific variant codes that are attached to occurrences of
the specified subsystems.

If you have a file with tab-delimited fields in which the last field
in each line is a functional assignment, then

    svr_metabolic_reconstruction < file > extended.file

will produce a file in which each line contains a functional role that
is part of an active subsystem.  Note that because each functional assignment
can contain multiple functional roles, a single incoming assignment can produce
many such lines. For each such line, two extra columns, the variant code and the
subsystem, will be added. Input lines corresponding to functional roles not
placed in active subsystems will be written to STDERR (and will not appear in
STDOUT).

Thus, if one had a FASTA file of protein sequences from some complete
genome or environmental sample, then

    svr_assign_using_figfams < ProteinSequences | svr_metabolic_reconstruction > reconstruction 2> unplaced.hits

would give you the assignments of function plus the unplaced
sequences.

=cut

my $show_ids;
my $url = "";

my $usage = "Usage: metabolic_reconstruction [--id] < file";

my $rc = GetOptions("id" => \$show_ids,
		    "url=s" => \$url);

if (!$rc || @ARGV > 0)
{
    die "$usage\n";
}

my $ss = ANNOserver->new(url => $url);

my $tmp_dir = SeedAware::location_of_tmp();
my $file = "$tmp_dir/tmpmetabolic.$$";

open(TMP,">$file") || die "could not open $file: $!";

#spool input file to a tmp file. At the end read it back, look up the role in the results hash, write out.
#if no hit in teh result hash, write to stderr

my %roles;

while (<STDIN>)
{
    print TMP $_;
    chomp; 
    my @in = split "\t";
    my $last = $#in;
    if ($show_ids)
    {
	$roles{$in[$last]} = $in[$last - 1];
    }
    else
    {
	$roles{$in[$last]} = 0;
    }
}
close TMP;

my @role_id;
while (my($key, $value) = each %roles) {
	push (@role_id, [$key, $value]);
}

my @res = $ss->metabolic_reconstruction(-roles => \@role_id);
#returns subsys, role, [id] 

my %role_hits;
foreach my $r (@res) {
    foreach my $res (@$r) {
	my $ss_var = $res->[0];
	my $role = $res->[1];
	$role_hits{$role} = $ss_var;
	if (defined($show_ids)) {
	    my $id = $res->[2];
	    $roles{$role} = $id;
	}
    }
}

open(TMP,"<$file") || die "could not open $file: $!";

while (<TMP>) {
    chomp;
    my @in = split "\t";
    my $last = $#in;
    my $role = $in[$last];
	if ($role_hits{$role}) {
	    my $ss_var = $role_hits{$role};
	    $ss_var =~ /(^.*:)(.+)/;
	    my $ss = $1;
	    my $var = $2;
	    $ss =~ s/:$//;
	    print $_;
	    print "\t", $ss, "\t", $var, "\n";
	} else {
	    print STDERR $_, "\n";;
	}
}
close(TMP);

unlink $file;

exit;


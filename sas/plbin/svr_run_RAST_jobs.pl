#!/usr/bin/perl

#
#	This is a SAS Component.
#

use RASTserver;
use strict;
use Data::Dumper;
use Getopt::Long;

my $usage = "Usage: $0 [--determineFamily] [--url server-url] [--nonActive] [--verbose] [--test] username password < contig-id-list\n";

my $verbose;
my $use_test_server = 0;
my $non_active = 0;
my $url;
my $determine_family = 0;
if (!GetOptions('verbose'   => \$verbose,
		"nonActive" => \$non_active,
		"url=s" => \$url,
		"determineFamily" => \$determine_family,
		'test'      => \$use_test_server))
{
    die $usage;
}

@ARGV == 2 or die $usage;

my $username = shift;
my $password = shift;
my $opts = {};
if ($url)
{
    $opts->{-server} = $url;
}
if ($use_test_server)
{
    $opts->{-test} = 1;
}
my $rast = RASTserver->new($username, $password, $opts);

my @input_ids = <STDIN>;
chomp @input_ids;

my @job_sets;
my $redundancies_seen;

my $tmpdir = "/tmp/rast_submit.tmp.$$";
mkdir $tmpdir;

my %seen;
for my $id (@input_ids)
{
    next if $seen{$id};

    my $res = $rast->get_contig_ids_in_project_from_entrez({ -contig_id => $id } );
    # print Dumper($res);
    my $project_ids = $res->{ids};
    my $redundancies = $res->{redundancy_report};

    if (@$redundancies)
    {
	for my $redundancy (@$redundancies)
	{
	    print STDERR join("\t", @$redundancy), "\n";
	    $redundancies_seen++;
	}
    }
    else
    {
	push(@job_sets, $project_ids);
	map { $seen{$_} = 1 } @$project_ids;
    }
}

if ($redundancies_seen)
{
    die "Not submitting jobs, redundancies were found\n";
}

#
# Pull contigs
#

my @jobs;

my $idx = 1;
for my $ids (@job_sets)
{
    print "Retrieve @$ids from Entrez\n";
    my $data = $rast->get_contigs_from_entrez({ -id => $ids });
    my $file= "$tmpdir/data.$idx";
    $idx++;
    open(F, ">", $file) or die "Cannot open $file: $!";
    for my $ent (@$data)
    {
	my $txt = $ent->{contents};
	my $id = $ent->{id};
	$ent->{contents} = '';
	print "Contig information for $id:\n";
	print "\t$_\t$ent->{$_}\n" for keys %$ent;
	print F $txt;
    }
    close(F);
    push(@jobs, { file => $file, data => $data, ids => $ids });
}

#
# Submit to RAST. The data hash looks like this:
# $VAR1 = {
#           'length' => '16660',
#           'project' => '15760',
#           'name' => 'Mycobacterium gilvum PYR-GCK',
#           'contents' => '',
#           'id' => 'NC_009341',
#           'taxonomy_id' => '350054'
#         };
#

for my $jobdata (@jobs)
{
    my($file, $data, $ids) = @$jobdata{qw(file data ids)};

    my @biggest = sort { $b->{length} <=> $a->{length} } @$data;

    my $biggest = $biggest[0];

    my $taxonomy = $biggest->{taxonomy};

    my $submit_params = {
	-filetype => 'genbank',
	-taxonomyID => $biggest->{taxonomy_id},
	-domain => $biggest->{domain},
	-organismName => $biggest->{name},
	-file => $file,
	-geneticCode => $biggest->{genetic_code},
	-keepGeneCalls => 0,
	-geneCaller => 'RAST',
	-nonActive => $non_active,
	-determineFamily => $determine_family,
    };

    print "Submitting job to RAST for contigs @$ids with these parameters:\n";
    print "\t$_\t$submit_params->{$_}\n" for keys %$submit_params;


    my $res = $rast->submit_RAST_job($submit_params);

    if ($res->{status} eq 'ok')
    {
	my $job = $res->{job_id};
	print "Successfully submitted job $job\n";
    }
    else
    {
	print "There was an error on submission: $res->{error_msg}\n";
    }
}


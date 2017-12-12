#!/usr/bin/perl

#
#	This is a SAS Component.
#


use RASTserver;
use strict;
use Getopt::Long;

#
# Usage: svr_status_of_RAST_job username password jobid [, jobid...]
#

my $usage = "Usage: $0 [--url server-url] [--test] [--verbose] username password jobid [ jobid jobid ... ]\n";

my $verbose;
my $is_test;
my $url;
if (!GetOptions('verbose' => \$verbose,
		'test' => \$is_test,
	        'url=s' => \$url))
{
    die $usage;
}

@ARGV > 2 or die $usage;

my $username = shift;
my $password = shift;

my @jobs = @ARGV;

my $opts = {};
if ($url)
{
    $opts->{-server} = $url;
}
if ($is_test)
{
    $opts->{-test} = 1;
}

my $rast = new RASTserver($username, $password, $opts);

my $res = $rast->status_of_RAST_job( { -job => \@jobs } );

for my $job (@jobs)
{
    my $status_hash = $res->{$job};
    my $status = $status_hash->{status};
    my $err_msg = "(error message: $status_hash->{error_msg})" if $status eq 'error';
    print "status for job $job: $status $err_msg\n";
    if ($verbose)
    {
	for my $vs (@{$status_hash->{verbose_status}})
	{
	    my($s, $v) = @$vs;
	    print "$s: $v\n";
	}
    }
}

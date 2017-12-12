#!/usr/bin/perl

#
#	This is a SAS Component.
#

use RASTserver;
use strict;
use Getopt::Long;

#
# Usage: svr_delete_RAST_job username password jobid [, jobid...]
#

my $usage = "Usage: $0 [--verbose] username password jobid [ jobid jobid ... ]\n";

my $verbose;
my $use_test_server = 0;
if (!GetOptions('verbose' => \$verbose,
		'test' => \$use_test_server))
{
    die $usage;
}

@ARGV > 2 or die $usage;

my $username = shift;
my $password = shift;

my @jobs = @ARGV;

my $rast = new RASTserver($username, $password, { -test => $use_test_server } );

my $res = $rast->delete_RAST_job( { -job => \@jobs } );

for my $job (@jobs)
{
    my $jdat = $res->{$job};
    my $status = $jdat->{status};
    my $err_msg = "(error message: $jdat->{error_msg})" if $status eq 'error';
    print "Status from deleting job $job: $status $err_msg\n";
}

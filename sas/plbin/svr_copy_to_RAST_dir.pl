#!/usr/bin/perl

#
#	This is a SAS Component.
#


use RASTserver;
use strict;
use Getopt::Long;
use Data::Dumper;

#
# Usage: svr_copy_to_RAST_dir username password jobid from [to_dir]"
#

my $verbose;
my $use_test_server = 0;
my $url;

my $usage = "Usage: $0 [--verbose] [--test] [--url server-url] username password jobid from [to_dir]\n";

if (!GetOptions('verbose' => \$verbose,
		'url=s' => \$url,
		'test' => \$use_test_server))
{
    die $usage;
}

@ARGV == 4 or @ARGV == 5 or die $usage;

my $username = shift;
my $password = shift;
my $job = shift;
my $from = shift;
my $to = shift;

my $rast = new RASTserver($username, $password, { -test => $use_test_server,
						  (defined($url) ? (-server => $url) : ())
						  } );

my $res = $rast->copy_to_RAST_dir( { -job => $job, -from => $from,
				     (defined($to) ? (-to => $to) : ()) } );

if ($res->{status} eq 'error')
{
    die "Error copying data: $res->{error_msg}\n";
}

#!/usr/bin/perl

#
#	This is a SAS Component.
#


use RASTserver;
use strict;

#
# Usage: svr_retrieve_RAST_job username password jobid format  > output-file
#

@ARGV == 4 or die "Usage: $0 username password jobid format > output-file\n";

my $username = shift;
my $password = shift;
my $job = shift;
my $format = shift;

my $rast = new RASTserver($username, $password);

my $res = $rast->retrieve_RAST_job( { -job => $job, -format => $format, -filehandle => \*STDOUT } );

if ($res->{status} eq 'error')
{
    die "Error retrieving job output: $res->{error_msg}\n";
}

print $res->{contents};

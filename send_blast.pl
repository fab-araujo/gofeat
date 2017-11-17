#!/usr/bin/perl

# $Id: web_blast.pl,v 1.10 2016/07/13 14:32:50 merezhuk Exp $
#
# ===========================================================================
#
#                            PUBLIC DOMAIN NOTICE
#               National Center for Biotechnology Information
#
# This software/database is a "United States Government Work" under the
# terms of the United States Copyright Act.  It was written as part of
# the author's official duties as a United States Government employee and
# thus cannot be copyrighted.  This software/database is freely available
# to the public for use. The National Library of Medicine and the U.S.
# Government have not placed any restriction on its use or reproduction.
#
# Although all reasonable efforts have been taken to ensure the accuracy
# and reliability of the software and data, the NLM and the U.S.
# Government do not and cannot warrant the performance or results that
# may be obtained by using this software or data. The NLM and the U.S.
# Government disclaim all warranties, express or implied, including
# warranties of performance, merchantability or fitness for any particular
# purpose.
#
# Please cite the author in any work or product based on this material.
#
# ===========================================================================
#
# This code is for example purposes only.
#
# Please refer to https://ncbi.github.io/blast-cloud/dev/api.html
# for a complete list of allowed parameters.
#
# Please do not submit or retrieve more than one request every two seconds.
#
# Results will be kept at NCBI for 24 hours. For best batch performance,
# we recommend that you submit requests after 2000 EST (0100 GMT) and
# retrieve results before 0500 EST (1000 GMT).
#
# ===========================================================================
#
# return codes:
#     0 - success
#     1 - invalid arguments
#     2 - no hits found
#     3 - rid expired
#     4 - search failed
#     5 - unknown error
#
# ===========================================================================

use URI::Escape;
use LWP::UserAgent;
use HTTP::Request::Common qw(POST);

$ua = LWP::UserAgent->new;

$argc = $#ARGV + 1;

if ($argc < 3)
    {
    print "usage: web_blast.pl program database query [query]...\n";
    print "where program = megablast, blastn, blastp, rpsblast, blastx, tblastn, tblastx\n\n";
    print "example: web_blast.pl blastp nr protein.fasta\n";
    print "example: web_blast.pl rpsblast cdd protein.fasta\n";
    print "example: web_blast.pl megablast nt dna1.fasta dna2.fasta\n";

    exit 1;
}

$program = shift;
$database = shift;

if ($program eq "megablast")
    {
    $program = "blastn&MEGABLAST=on";
    }

if ($program eq "rpsblast")
    {
    $program = "blastp&SERVICE=rpsblast";
    }

# read and encode the queries
foreach $query (@ARGV)
    {
    open(QUERY,$query);
    while(<QUERY>)
        {
        $encoded_query = $encoded_query . uri_escape($_);
        }
    }

# build the request
$args = "CMD=Put&PROGRAM=$program&DATABASE=$database&QUERY=" . $encoded_query;

$req = new HTTP::Request POST => 'https://blast.ncbi.nlm.nih.gov/blast/Blast.cgi';

$req->content_type('application/x-www-form-urlencoded');
$req->content($args);


# get the response
$response = $ua->request($req);

# parse out the request id
$response->content =~ /^    RID = (.*$)/m;
$rid=$1;

# parse out the estimated time to completion
$response->content =~ /^    RTOE = (.*$)/m;
$rtoe=$1;

print $rid."\n";
print $rtoe."\n";

exit 0;
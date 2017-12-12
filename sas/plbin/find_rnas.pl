#!/usr/bin/perl -w

#
# This is a SAS Component
#

#
# Copyright (c) 2003-2006 University of Chicago and Fellowship
# for Interpretations of Genomes. All Rights Reserved.
#
# This file is part of the SEED Toolkit.
#
# The SEED Toolkit is free software. You can redistribute
# it and/or modify it under the terms of the SEED Toolkit
# Public License.
#
# You should have received a copy of the SEED Toolkit Public License
# along with this program; if not write to the University of Chicago
# at info@ci.uchicago.edu or the Fellowship for Interpretation of
# Genomes at veronika@thefig.info or download a copy from
# http://www.theseed.org/LICENSE.TXT.
#

use strict;
use ANNOserver;
use Getopt::Long;
#use Pod::Usage;

=head1 find_rnas Script

=head2 Introduction

    find_rnas [options]  genus species domain

Call Genes using FF server.

This script takes a FASTA file of contigs from the standard input and writes
the result of finding RNAs using search_for_rnas to the stdout.

=head2 Command-Line Options

=over 4

=item help

Display this command's parameters and options.

=head3 Output Format

The standard output is FASTA file of proteins.

=cut

# Get the command-line options and parameters.
my($genus, $species, $domain);
my $help;
my $man;
my $url;

my $rc = GetOptions("help" => \$help,
		    "url=s" => \$url);

my $usage = [ "$0 [options] genus species domain",
	  "\t-help\tdisplay command-line options", ""];
    


if ($help)
{
    #pod2usage({-exitval => 1, -verbose => 2, -output => \*STDOUT});  
    print join "\n", @$usage;
    exit;
}

if (@ARGV != 3)
{
    print STDERR join "\n", @$usage;
    exit;
}

($genus, $species, $domain) = @ARGV;

# Create a FIGfam server object.

my $ffServer = ANNOserver->new(url => $url);

# Pass the input file to the FIGfam server to get assignments.
my $ret = $ffServer->find_rnas(-input => \*STDIN,
			       -genus => $genus,
			       -species => $species,
			       -domain => $domain);
my ($fa, $encoded_tbl)  = @$ret;

print $fa if defined($fa);
print STDERR join("\t", @$_), "\n" for @$encoded_tbl;


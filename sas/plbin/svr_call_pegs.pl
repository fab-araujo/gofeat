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

=head1 svr_call_pegs Script

=head2 Introduction

    svr_call_pegs [options] 

Call Genes using Annotation server.

This script takes a FASTA file of contigs from the standard input and writes
the result of calling genes using Glimmer to the standard output.

=head2 Command-Line Options

=over 4

=item --geneticCode

A number, generally either 11 or 4, representing the genetic code of the
given contigs.

=item help

Display this command's parameters and options.

=back

=head3 Output Format

The standard output is FASTA file of proteins.

=cut

# Get the command-line options and parameters.
my $genetic_code = 11;
my $help;
my $man;
my $url;

my $rc = GetOptions("geneticCode=i" => \$genetic_code,
		    "url=s" => \$url,
                    "help" => \$help);

if ($help)
{
    #pod2usage({-exitval => 1, -verbose => 2, -output => \*STDOUT});  
    my $usage = [ "$0 [options] <contigs.fasta >pegs.fasta",
		  "\t-geneticCode\tgenetic code for this organism (default 11)",
		  "\t-help\tdisplay command-line options", ""];
    
    print join "\n", @$usage;
    exit;
}

# Create an ANNO server object.
my $ffServer = ANNOserver->new(url => $url);

# Pass the input file to the ANNO server to get assignments.
my $ret = $ffServer->call_genes(-input => \*STDIN,
				-geneticCode => $genetic_code);
my ($fa, $encoded_tbl)  = @$ret;

print $fa;
print STDERR join("\t", @$_), "\n" for @$encoded_tbl;


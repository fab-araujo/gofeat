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
use Data::Dumper;
use ANNOserver;
use Getopt::Long;
#use Pod::Usage;

=head1 svr_assign_using_figfams 

=head2 Introduction

    svr_assign_using_figfams [options] <proteins.fasta >functions.tbl

Assign Using the FIGfams Server

This script takes a FASTA file of proteins from the standard input and writes
the function of each to the standard output. FIGfams are used to determine the
function when possible. When not possible, a message will be written to the
standard error output.

=head2 Command-Line Options

=over 4

=item reliability

A number, generally from 1 to 100, indicating how careful we should be about
making the assignments. A higher number indicates greater care.

=item blastOutput

If this value is nonzero, then when a function is assigned to the sequence, it
will be BLASTed against one or more FIGfams that implement the function, and the
top N results will be displayed, where N is this number.

=item all

Assign to all proteins.

=item otu

Emit the OTU of the hits, as the first column.

=item help

Display this command's parameters and options.

=item url

The URL for the FIGfam server, if it is to be different from the default.

=back

=head3 Output Format

The standard output is a tab-delimited file. If no BLAST output is specified, the
the first column of each record is a feature ID from the FASTA input, and the
second column is the assigned function. If BLAST output is specified, then the BLAST
hits found will be listed after each assignment. The columns in a BLAST hit record
are as follows.

=over 4

=item identifier

ID of the feature hit by the BLAST.

=item percentIdentity

Percentage identity of the matching sequences.

=item beginQuery

Position in the query sequence at which the match starts.

=item endQuery

Position in the query sequence at which the match stops.

=item beginHit

Position in the hit sequence at which the match starts.

=item endHit

Position in the hit sequence at which the match stops.

=item pScore

P-score of the match.

=item bitScore

Bit-score of the match.

=item queryLen

Total length of the query sequence.

=item hitLen

Total length of the hit sequence.

=item FIGfamID

ID of the FIGfam containing the hit sequence.

=back

=cut

# Get the command-line options and parameters.
my $reliability = 3;
my $blastOutput = 0;
my $assignToAll = 0;
my $showOtu = 0;
my $help;
my $man;
my $url = "";
my $kmer = 8;
my $kmerDataset;
my $rc = GetOptions("reliability=i" => \$reliability,
                    "blastOutput=i" => \$blastOutput,
		    "otu" => \$showOtu,
		    "all" => \$assignToAll,
                    "help" => \$help,
		    "kmer=i" => \$kmer,
	 	    "kmerDataset=s" => \$kmerDataset,
		    "url=s" => \$url);

my @kmerDataset = $kmerDataset ? (-kmerDataset => $kmerDataset) : ();

if ($help)
{
    #pod2usage({-exitval => 1, -verbose => 2, -output => \*STDOUT});  
    my $usage = [ "$0 [options]",
		  "\t-reliability\tdesired confidence level for the assignment (default 3)", 
		  "\t-blastOutput\tnumber of BLAST hits to display for each result",
		  "\tOPTIONAL",
		  "\t-all\tassign to all the proteins",
		  "\t-otu\tshow the OTUs for the match",
		  "\t-kmer\tsize of the kmers to use",
		  "\t-kmerDataset\tdata set(s) for the kmers",
		  "\t-url\tANNO server URL",
		  "\t-help\tdisplay command-line options", ""];
    
    print join "\n", @$usage;
    exit;
}

if (!$reliability)
{
    $reliability=3;
}
if (!$blastOutput)
{
    $blastOutput=0;
}


# Create a FIGfam server object.
my $ffServer = ANNOserver->new(url => $url);

# Pass the input file to the FIGfam server to get assignments.
my $resultH = $ffServer->assign_function_to_prot(-input => \*STDIN,
						 -kmer => $kmer,
						 @kmerDataset,
						 -scoreThreshold => $reliability,
						 -assignToAll => ($assignToAll ? 1 : 0));

# Loop through the results. We send good results to the standard output,
# and failures to the standard error file.
while (my $result = $resultH->get_next()) {
    my($id, $function, $otu, $score, $nonoverlap_hits, $overlap_hits, $details) = @$result;
    
    # Did we find a valid result?
    if (! $function) {
	print STDERR "$id was not placed into a FIGfam\n";
    } else {
	# Here we found a result.
	if ($showOtu)
	{
	    $otu = "" unless defined($otu);
	    print "$otu\t$score\t$id\t$function\n";
	}
	else
	{
	    print "$score\t$id\t$function\n";
	}
	
    }
}

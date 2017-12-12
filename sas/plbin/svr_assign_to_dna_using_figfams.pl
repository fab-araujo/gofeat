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
use Data::Dumper;

=head1 svr_assign_to_dna_using_figfams

=head2 Introduction

    svr_assign_to_dna_using_figfams <feature_list.fasta >functions.tbl

Assign Using the FIGfams Server

This script takes a FASTA file of DNA features from the standard input and writes
the function of each to the standard output. FIGfams are used to determine the
function when possible. When not possible, a message will be written to the
standard error output.

This script is substantially different from L<svr_assign_using_figfams.pl> in that
each incoming sequence should be considered as a domain in which results can be
found rather than a single sequence whose function is desired. As a result, the
output will not correspond well to the input. Some sequences will get many hits,
some will have only one, and some may not have any.

=head2 Command-Line Options

=over 4

=item --reliability

A number, generally from 1 to 100, indicating how careful we should be about
making the assignments. A higher number indicates greater care.

=item --maxGap

When looking for a match, if two sequence elements match and are closer than
this distance, then they will be considered part of a single match. Otherwise,
the match will be split.

=item --minSize

When looking for a match, we group together a set that "covers" some region.
The set is not necessarily in a single frame (i.e., we treat the sequence as low
quality and only consider the number of hits in a region on the same strand).  This
parameter forces the size of the region to be above a specified value.  The default
is 6 * the size of the kmers (the 'kmer' parameter).

=item --by_location

Display the hits ordered by location.

=item --help

Display this command's parameters and options.

=back

=head3 Output Format

The standard output is a tab-delimited file. Each output record
consists of the ID of the query sequence, the number of matching
kmers, a location in the sequence, the predicted function, and an
organism name that represents an OTU category.

=cut

# Get the command-line options and parameters.
my $reliability = 3;
my $help;
my $maxGap = 600;
my $url;
my $kmer = 8;
my $kmerDataset;
my $by_location;
my $minSize = ($kmer * 3) * 2;
my $rc = GetOptions("reliability=i" => \$reliability,
                    "maxGap=i" => \$maxGap,
                    "minSize=i" => \$minSize,
                    "help" => \$help,
                    "by_location" => \$by_location,
		    "kmer=i" => \$kmer,
	 	    "kmerDataset=s" => \$kmerDataset,
		    "url=s" => \$url);


if ($help)
{
    #pod2usage({-exitval => 1, -verbose => 2, -output => \*STDOUT});
    my $usage = [ "$0 [options]",
                  "\t-reliability\tdesired confidence level for the assignment (default 3)",
		  "\t-maxGap\tmaximum distance between two hits for them to be viewed as part of the same match",
		  "\t-minSize\tminimum size for a reported region",
		  "\t-by_location\tdisplay results sorted by location",
                  "\t-help\tdisplay command-line options", ""];

    print join "\n", @$usage;
    exit;
}

my @kmerDataset = $kmerDataset ? (-kmerDataset => $kmerDataset) : ();

# Create a FIGfam server object.
my $ffServer = ANNOserver->new(url => $url);

# Pass the input file to the FIGfam server to get assignments.
my $resultH = $ffServer->assign_functions_to_dna(-input => \*STDIN,
						 -kmer => $kmer,
						 @kmerDataset,
						 -minHits => $reliability,
						 -maxGap => $maxGap);

# Loop through the results. We send good results to the standard output,
# and failures to the standard error file.

my @by_loc;
while (my $result = $resultH->get_next()) {
    # Each result contains an input ID and a tuple of data.
    my ($id, $tuple) = @$result;
    
    # The data tuple consists of the start and end points of the match in the
    # query sequence, and the assigned function.
    
    if ($by_location)
    {
	push(@by_loc,[$id,$tuple]);
    }
    else
    {
	&print_tuple($id,$tuple,$minSize);
    }
}

if ($by_location)
{
    my @by_loc = sort { &cmp_loc($a,$b) } @by_loc;
    foreach my $match (@by_loc)
    {
	my($id,$tuple) = @$match;
	&print_tuple($id,$tuple,$minSize);
    }
}

sub print_tuple {
    my($id,$tuple,$minSize) = @_;

    my ($count, $begin, $end, $function, $set) = @$tuple;
    if ((abs($end-$begin) + 1) >= $minSize)
    {
	$set = "" unless defined($set);
	# Here we found a result. First, compute the location string.
	my $locString = "${id}_${begin}_${end}";
	print "$id\t$count\t$locString\t$function\t$set\n";
    }
}

sub cmp_loc {
    my($x,$y) = @_;

    my($id1,$tuple1) = @$x;
    my($id2,$tuple2) = @$y;
    return (($id1 cmp $id2) or ($tuple1->[1] <=> $tuple2->[1]));
}

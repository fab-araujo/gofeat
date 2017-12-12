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

#
# Takes two files on cmd line: metabolic reconstruction output and tab-delimlited tbl output.
# Column 2 of the reconstruction is expected to be a protein ID; append the contig/beg/end  from the tbl
# file after that column.
#

use strict;

@ARGV == 2 or die "Usage: $0 reconstruction-output tbl-output\n";

my $recon = shift;
my $tbl = shift;

open(R, "<", $recon) or die "cannot open $recon: $!";
open(T, "<", $tbl) or die "cannot open $tbl: $!";

my %tbl;
while (<T>)
{
    chomp;
    my(@a) = split(/\t/);
    $tbl{$a[0]} = [@a];
}
close(T);

while (<R>)
{
    chomp;
    my(@a) = split(/\t/);
    my $l = $tbl{$a[1]};
    if ($l)
    {
	splice(@a, 1, 1, @$l);
    }
    print join("\t", @a), "\n";
}

close(R);
    

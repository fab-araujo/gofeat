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

=head1 svr_summarize_MG_output

=head2 Introduction

    svr_summarize_MG_output  < output.from.svr_assign_to_dna_using_figfams

This simple program produces two summaries: one of the functions identified
and one of the OTUs identified.  We represent OTUs with a representative
organism.  The function summary is sent to stdout, while the OTU summary 
is sent to stderr.    

=head3 Output Format

The function summary written to stdout is a 3-column table:

=over 4

=item * the number of hits against the function

=item * the fraction of the total hits this represents

=item * the function

=back

The OTU summary is also a 3-column table:

=over 4

=item * the number of hits against that appear to unquely identify an OTU

=item * the fraction of the total hits this represents

=item * a representative organism for the OTU

=back

=cut

my $totF = 0;
my $totO = 0;
my(%functions,%otus);
while (defined($_ = <STDIN>))
{
    chomp;
    my(undef,undef,undef,$function,$otu) = split(/\t/,$_);
    $totF++;
    $functions{$function}++;
    if ($otu)
    {
	$totO++;
	$otus{$otu}++;
    }
}

foreach my $func (sort { $functions{$b} <=> $functions{$a} } keys(%functions))
{
    print join("\t",($functions{$func},sprintf("%0.6f",$functions{$func}/$totF),$func)),"\n";
}

foreach my $otu (sort { $otus{$b} <=> $otus{$a} } keys(%otus))
{
    print STDERR join("\t",($otus{$otu},sprintf("%0.6f",$otus{$otu}/$totO),$otu)),"\n";
}


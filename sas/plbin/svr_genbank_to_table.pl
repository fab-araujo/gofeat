# -*- perl -*-

#
#       This is a SAS Component.
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

# usage:  svr_genbank_to_table  < genbank.file  > features.tab

use strict;
use warnings;

use SeedUtils;
use gjogenbank;

use Data::Dumper;

my $cds_num = '00000';
my $rna_num = '00000';

print STDOUT (join(qq(\t), (q(#main_id), qw(Gene_Name Locus_Tag Protein_ID DB_Xrefs SEED_loc Assigned_Function)), qq(\n)));

foreach my $accession (gjogenbank::parse_genbank()) {
    my $contig   = $accession->{LOCUS};
    
    foreach my $cds (@ { $accession->{FEATURES}->{CDS} }) {
	++$cds_num;
	my $cds_id = q(CDS_) . $cds_num;
	
	my $gb_loc = gjogenbank::location( $cds, $accession );
	my $locus  = gjogenbank::genbank_loc_2_seed($contig, $gb_loc);
	my $func   = gjogenbank::product( $cds ) || q();
	
	my $gene_name  = defined($cds->[1]->{gene}->[0])       ? $cds->[1]->{gene}->[0]       : q();
	my $locus_tag  = defined($cds->[1]->{locus_tag}->[0])  ? $cds->[1]->{locus_tag}->[0]  : q();
	my $protein_id = defined($cds->[1]->{protein_id}->[0]) ? $cds->[1]->{protein_id}->[0] : q();
	my @db_xrefs   = defined($cds->[1]->{db_xref}->[0])    ? @ { $cds->[1]->{db_xref} }   : ();
	my $db_xrefs   = join(q(,), @db_xrefs);
	
	my @gi_nums    = map { m/GI\:(\d+)/o     ? (q(gi|).$1)     : () } @db_xrefs;
	my @gene_nums  = map { m/GeneID\:(\d+)/o ? (q(GeneID|).$1) : () } @db_xrefs;
	
	my $main_id = $locus_tag || $protein_id || $gi_nums[0] || $gene_nums[0] || $cds_id;
	
	if ($cds_id && $locus && defined($func)) {
	    print (join(qq(\t), ($main_id, $gene_name, $locus_tag, $protein_id, $db_xrefs, $locus, $func)), qq(\n));
	}
	else {
	    die (qq(Could not parse CDS feature in accession '$contig':\n), Dumper($cds));
	}
    }
}

exit(0);

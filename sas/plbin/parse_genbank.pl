# -*- perl -*-

#
# This is a SAS component.
#

########################################################################
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
########################################################################

use SeedUtils;
use Carp;
use Data::Dumper;

my %trans_table;

my $usage = qq(usage: parse_genbank [-i=genbank.entry] [-bioname=GENOME_BIONAME] [-taxonomy=TAXONOMY] [-source=DATA_SOURCE] Taxon_ID Org_Dir < genbank.entry);

my $trouble = 0;
my $force_bioname;
my $force_taxonomy;
my $data_source = qq(Parsed GenBank File);
my $genbank_entry;
while ($ARGV[0] =~ m/^-/)
{
    if    ($ARGV[0] =~ m/^-{1,2}bioname=(\S+)/) {
	$force_bioname =  $1;
	$force_bioname =~ s/^[\'\"]//o;
	$force_bioname =~ s/[\'\"]$//o;
	$force_bioname =~ s/\s+/ /g;
	
	print STDERR qq(\nGenome bioname will be taken as: \"$force_bioname\"\n);
    }
    elsif ($ARGV[0] =~ m/^-{1,2}taxonomy=(\S+)/) {
	$force_taxonomy =  $1;
	$force_taxonomy =~ s/^[\'\"]//o;
	$force_taxonomy =~ s/[\'\"]$//o;
	$force_taxonomy =~ s/\s+/ /g;
	if ($force_taxonomy !~ m/\.$/) { $force_taxonomy .= qq(.); }
	
	print STDERR qq(\nTaxonomy will be taken as: \"$force_taxonomy\"\n);
    }
    elsif ($ARGV[0] =~ m/^-{1,2}source=(\S+)/) {
	$data_source =  $1;
	$data_source =~ s/^[\'\"]//o;
	$data_source =~ s/[\'\"]$//o;
	
	print STDERR qq(Data source string is: \"$data_source\"\n);
    }
    elsif ($ARGV[0] =~ m/^-{1,2}i=(.*)/) {
	$genbank_entry = $1;
    }
    else {
	$trouble = 1;
	die qq(Could not handle $ARGV[0]);
    }
    shift @ARGV;
}

my $input_fh;
if (defined($genbank_entry))
{
    if (!open($input_fh, "<", $genbank_entry))
    {
	die "Could not open genbank entry $genbank_entry: $!";
    }
}
else
{
    $input_fh = \*STDIN;
}

my $taxon_ID;
my $org_dir;
(
 ($taxon_ID = shift(@ARGV)) &&
 ($org_dir    = shift(@ARGV))
)
    || die $usage;

$prefixP = qq(fig|$taxon_ID.peg.);
$prefixR = qq(fig|$taxon_ID.rna.);

#...Create paths down to PEG and RNA dirs
&SeedUtils::verify_dir("$org_dir/Features/peg");
&SeedUtils::verify_dir("$org_dir/Features/rna");

my $fh_contigs;
my $contigs_file = qq($org_dir/contigs);
open($fh_contigs,  qq(>$contigs_file))
    || die qq(could not open $contigs_file);

my $fh_assigned_funcs;
my $assigned_funcs_file = qq($org_dir/assigned_functions);
open($fh_assigned_funcs,  qq(>$assigned_funcs_file))
    || die qq(could not write-open $assigned_funcs_file);

my $fh_annotations;
my $annotations_file = qq($org_dir/annotations);
open($fh_annotations,  qq(>$annotations_file))
    || die qq(could not write-open $annotations_file);

my $fh_ec_nums;
my $ec_nums_file = qq($org_dir/EC_numbers);
open($fh_ec_nums, qq(>$ec_nums_file))
    || die" Could not write-open $ec_nums_file";

my $fh_peg_tbl;
my $peg_tbl_file = qq($org_dir/Features/peg/tbl);
open($fh_peg_tbl,  qq(>$peg_tbl_file))
    || die qq(could not open $peg_tbl_file);

my $fh_peg_fasta;
my $peg_fasta_file = qq($org_dir/Features/peg/fasta);
open($fh_peg_fasta, qq(>$peg_fasta_file))
    || die qq(could not open $peg_fasta_file);

my $fh_rna_tbl;
my $rna_tbl_file = qq($org_dir/Features/rna/tbl);
open($fh_rna_tbl,      qq(>$rna_tbl_file))
    || die qq(could not write-open $rna_tbl_file);

my $fh_rna_fasta;
my $rna_fasta_file = qq($org_dir/Features/rna/fasta);
open($fh_rna_fasta,    qq(>$rna_fasta_file))
    || die qq(could not write-open $rna_fasta_file);


open( TAXONOMY,  qq(>$org_dir/TAXONOMY))  || die qq(could not open $org_dir/TAXONOMY);
open( GENOME,    qq(>$org_dir/GENOME))    || die qq(could not open $org_dir/GENOME);

open( PROJECT,   qq(>$org_dir/PROJECT))   || die qq(could not open $org_dir/PROJECT);
print PROJECT    qq($data_source\n);
close(PROJECT);

my $idNp = 1;
my $idNr = 1;

$/ = qq(\n//\n);
my $record;
my $contigs = {};

while (defined($record = <$input_fh>)) {
    $record =~ s/^\s+//os;
    last unless $record;
    
    if ($record !~ m/LOCUS\s+(\S+)/os) {
	print STDERR qq(No LOCUS line for record begining with:\n)
	    , substr($record, 0, 160), qq(\n\n);
    }
    else {
	my $id = $1;
	if ($record =~ m/\nORIGIN[^\n]*\n(.*?)(\/\/|LOCUS)/os) {
	    my $seq = $1;
	    $seq =~ s/\s//ogs;
	    $seq =~ s/\d//og;
	    undef $contigs;
	    $contigs->{$id} = $seq;
	    &SeedUtils::display_id_and_seq($id, \$seq, $fh_contigs);
	}
	else {
	    warn qq(could not find contig sequence for $id\n);
	    next;
	}
	
	my ($taxon_ID, $taxonomy, $written_genome);
	if ($record =~ /\n {0,4}ORGANISM\s+(\S[^\n]+(\n\s{10,14}\S[^\n]+)*)/os) {
	    my $block = $1;
	    my @lines = split(/\n/,$block);
	    
	    my @genome = ();
	    my @full_tax = ();
	    for ($i=0; ($i < @lines) && ($lines[$i] !~ /;/); $i++) {
		push(@genome,$lines[$i]);
	    }
	    
	    while ($i < @lines) {
		push(@full_tax,$lines[$i]);
		++$i;
	    }
	    
	    $genome = join(qq( ),map { $_ =~ s/^\s*(\S.*\S).*$/$1/; $1 } @genome);
	    $taxonomy    = join(qq( ),map { $_ =~ s/^\s*(\S.*\S).*$/$1/; $1 } @full_tax);
	    
	    $taxonomy =~ s/\n\s+//og;
	    $taxonomy =~ s/ {2,}/ /og;
	    $taxonomy =~ s/\.$//o;
	    $taxonomy = $taxonomy . qq(; $genome);

	    if (! $written_genome) {
		if ($force_bioname) { $genome = $force_bioname; }
		print GENOME qq($genome\n);
		close(GENOME);
		
		if ($force_taxonomy) { $taxonomy = $force_taxonomy; }
		print TAXONOMY qq($taxonomy\n);
		close(TAXONOMY);
		
		$written_genome = qq($taxonomy\t$genome);
	    }
	    elsif (($written_genome ne qq($taxonomy\t$bioname)) && (!$force_bioname || !$force_taxonomy)) {
		print STDERR qq(serious mismatch in GENOME/TAX for $id\n$written_genome\n$taxonomy\t$bioname\n\n);
	    }
	}
	
	while ($record =~ m/\n\s{4,6}CDS\s+([^\n]+(\n {20,}[^\n]*)+)/ogs) {
	    my $cds = $1;
	    if (($cds !~ m/\/pseudo/o) &&
		(($cds !~ m/\/exception/o) || ($cds =~ m/\/translation/o))
		) {
		&process_cds($id, \$cds, $prefixP, \$idNp, $contigs, $fh_peg_tbl, $fh_peg_fasta, $fh_assigned_funcs, $fh_annotations, $fh_ec_nums);
	    }
	}

	while ($record =~ m/\n\s{3,6}(([tr]|misc\_)RNA)\s+([^\n]+(\n\s{20,22}\S[^\n]*)+)/ogs)
	{
	    $type = $2;
	    $rna  = $3;
	    &process_rna($id, $type, \$rna, $prefixR, \$idNr, $contigs, $fh_rna_tbl, $fh_rna_fasta, $fh_assigned_funcs, $fh_annotations);
	}
    }
}
close($fh_contigs);
close($fh_peg_tbl);
close($fh_peg_fasta);
close($fh_rna_tbl);
close($fh_rna_fasta);
close($fh_assigned_funcs);
close($fh_annotations);
close($fh_ec_nums);

if (!-s $assigned_funcs_file)  {
    warn qq(WARNING: no assigned_functions in $org_dir --- deleting\n);
    unlink("$assigned_funcs_file") unless $ENV{DEBUG};
}

if (!-s $annotations_file)  {
    warn qq(WARNING: no annotations in $org_dir --- deleting\n);
    unlink("$annotations_file") unless $ENV{DEBUG};
}

if (!-s $ec_nums_file)  {
    warn qq(WARNING: no EC_numbers in $org_dir --- deleting\n);
    unlink("$ec_nums_file") unless $ENV{DEBUG};
}

if ((!-s $rna_tbl_file) || (!-s $rna_fasta_file)) {
    warn qq(WARNING: no RNAs in $org_dir --- deleting\n);
    system('rm', '-rf',  "$org_dir/Features/rna") unless $ENV{DEBUG};;
}

if ((!-s $peg_tbl_file) || (!-s $peg_fasta_file)) {
    warn qq(WARNING: no PEGs in $org_dir --- deleting\n);
    system('rm', '-rf', "$org_dir/Features/peg") unless $ENV{DEBUG};
}

if ((!-d qq($org_dir/Features/peg)) && (!-d qq($org_dir/Features/peg))) {
    warn qq(WARNING: no Features in $org_dir --- deleting\n);
    system("rmdir", "$org_dir/Features") unless $ENV{DEBUG};;
}

if (!-s $contigs_file) {
    $trouble = 1;
    unlink($contigs_file);
    print STDERR qq(ERROR: No contigs in $org_dir\n);
}

if ($trouble) {
    warn qq(Genome directory $org_dir is corrupt --- deleting\n\n);
    system('rm',  '-rf', $org_dir) unless $ENV{DEBUG};
}

exit($trouble);

sub process_cds {
    my ($contigID, $cdsP, $prefix, $idNp, $contigs, $fh_tbl, $fh_fasta, $fh_assign, $fh_annot, $fh_ec_nums) = @_;
    my ($id, $prot);
    
    ++$recnum;
    my ($loc, $precise)  = &get_loc($contigID,$cdsP);
    my @aliases = &get_aliases($cdsP);
    my @ec_nums = &get_ec_numbers($cdsP);
    my ($func, $notes) = &get_func($cdsP);
    my $trans   = &get_trans($cdsP);
    
    if (not $trans) {
	warn qq(WARNING: Translation missing for CDS $recnum; attempting to generate translation\n) if $ENV{VERBOSE};
	
	if ($loc && $precise) {
	    my $dna = &SeedUtils::extract_seq($contigs,$loc);
	    if ($dna) {
		my $genetic_code = 11;
		if ($$cdsP =~ m/\/transl_table=(\d+)/o) {
		    $genetic_code = $1;
		}
		
		if (not defined($trans_table{$genetic_code})) {
		    $trans_table{$genetic_code} = &SeedUtils::genetic_code($genetic_code);
		}
		
		my $prot = &SeedUtils::translate($dna, $trans_table{$genetic_code}, 1);
		$prot =~ s/\*$//o;
		
		if ($prot !~ m/\*/o) {
		    $trans = $prot;
		}
		else {
		    warn qq(Translation contains STOPs, changing to \'x\'s, for CDS $recnum:\n$$cdsP\n);
		}
	    }
	}
	else {
	    warn (qq(Could not get DNA sequence for CDS at $loc for entry:\n)
		  , q(     CDS             )
		  , $$cdsP
		  , qq(\nof record begining with:\n)
		  , substr($record, 0, 160)
		  , qq(\n\n)
		  );
	}
    }
    
    if ($trans) {
	$id = $prefix . qq($$idNp);
	++$$idNp;
	
	print $fh_tbl qq($id\t$loc\t) . join("\t",@aliases) . "\n";
	
	if ($func) {
	    print $fh_assign qq($id\t$func\n);
	}
	
	if (@ec_nums) {
	    print $fh_ec_nums (join(qq(\t), ($id, @ec_nums)), qq(\n));
	}
	
	foreach my $note (@$notes) {
	    &make_annotation($id, $note, $fh_annot);
	}
	
	&SeedUtils::display_id_and_seq($id, \$trans, $fh_fasta);
    }
    else {
	warn (qq(No translation for CDS --- skipping entry:\n), &Dumper($cdsP), qq(\n));
    }
}

sub get_loc {
    my($contigID,$cdsP) = @_;
    my($beg,$end,$loc,$locS,$iter,$n,$args,@pieces);
    my($precise);
    
    if ($$cdsP =~ m/^(([^\n]+)((\n\s{21,23}[^\/ ][^\n]+)+)?)/os) {
	$locS = $1;
	$locS =~ s/\s//g;
	$precise = ($locS !~ m/[<>]/o);
	
	@pieces = ();
	$n = 0;
	$iter = 500;
	while (($locS !~ m/^\[\d+\]$/o) && $iter)
	{
	    --$iter;
	    if ($locS =~ s/[<>]?(\d+)\.\.[<>]?(\d+)/\[$n\]/o) {
		push(@pieces,["loc",$1,$2]);
		++$n;
	    }
	    
	    if ($locS =~ s/([,\(])(\d+)([,\)])/$1\[$n\]$3/o) {
		push(@pieces,["loc",$2,$2]);
		++$n;
	    }
	    
	    if ($locS =~ s/join\((\[\d+\](,\[\d+\])*)\)/\[$n\]/o) {
		$args = $1;
		push(@pieces,["join",map { $_ =~ /^\[(\d+)\]$/; $1 } split(m/,/,$args)]);
		++$n;
	    }
	    
	    if ($locS =~ s/complement\((\[\d+\](,\[\d+\])*)\)/\[$n\]/og) {
		$args = $1;
		push(@pieces,["complement", map { $_ =~ m/^\[(\d+)\]$/o; $1 } split(m/,/o, $args)]);
		++$n;
	    }
	}
	
	if ($locS =~ m/^\[(\d+)\]$/o) {
	    $loc = &conv(\@pieces,$1,$contigID);
	}
	else {
	    print STDERR &Dumper(["could not parse $locS $iter",$cdsP]);
	    die qq(aborted);
	}
	
	my @locs = split(m/,/o, $loc);
#...STOP is now included, so don't trim it off...
#	&trim_stop(\@locs);
	$loc = join(",",@locs);
    }
    else {
	print STDERR &Dumper($cdsP); die qq(could not parse location);
	die qq(aborted);
    }
    return ($loc,$precise);
}

sub trim_stop {
    my($locs) = @_;
    my($to_trim,$n);
    
    $to_trim = 3;
    while ($to_trim && (@$locs > 0)) {
	$n  = @$locs - 1;
	if ($locs->[$n] =~ m/^(\S+)_(\d+)_(\d+)$/o) {
	    if ($2 <= ($3-$to_trim)) {
		$locs->[$n] = join("_",($1,$2,$3-$to_trim));
		$to_trim = 0;
	    }
	    elsif ($2 >= ($3 + $to_trim)) {
		$locs->[$n] = join("_",($1,$2,$3+$to_trim));
		$to_trim = 0;
	    }
	    else {
		$to_trim -= abs($3-$2) + 1;
		pop @$locs;
	    }
	}
	else {
	    die qq(could not parse $locs->[$n]);
	}
    }
}


sub conv {
    my($pieces,$n,$contigID) = @_;
    
    if ($pieces->[$n]->[0] eq qq(loc)) {
	return join("_",$contigID,@{$pieces->[$n]}[1..2]);
    }
    elsif ($pieces->[$n]->[0] eq qq(join)) {
	return join(",",map { &conv($pieces,$_,$contigID) } @{$pieces->[$n]}[1..$#{$pieces->[$n]}]);
    }
    elsif ($pieces->[$n]->[0] eq qq(complement)) {
	return join(",",&complement(join(",", map { &conv($pieces,$_,$contigID) } @{$pieces->[$n]}[1..$#{$pieces->[$n]}])));;
    }
}

sub complement {
    my($loc) = @_;
    my(@locs);

    @locs = reverse split(/,/,$loc);
    foreach $loc (@locs) {
	if ($loc =~ m/^(\S+)_(\d+)_(\d+)$/o) {
	    $loc = join("_",($1,$3,$2));
	}
	else {
	    confess qq(Bad location: $loc);
	}
    }
    return join(",",@locs);
}

sub get_aliases {
    my($cdsP) = @_;
    my($id, $prefix, $alias, $db_ref);
    
    my @aliases = ();
    while ($$cdsP =~ m/\/(protein_id|gene|locus_tag)=\"([^\"]+)\"/ogs) {
	($type, $alias) = ($1, $2);
	
	# define prefixes for different types of ids
	if ($type eq qq(locus_tag)){
	    $id = qq(locus|$alias);
	}
	elsif ( $type eq qq(protein_id) ) {
	    $id = qq(protein_id|$alias);
	}
	elsif  ( $type eq qq(gene) ){
	    $id = qq(gene_name|$alias);
	}
	else{
	    $id = $alias;
	}
	
	push(@aliases,$id);
    }
    
    while ($$cdsP =~ m/\/db_xref=\"([^\"]+)\"/ogs) {
	$db_ref = $1;
	$db_ref =~ s/[\s\n]+//ogs;
	$db_ref =~ s/^GI:/gi\|/o;
	$db_ref =~ s/^GeneID:/geneID\|/o;
	$db_ref =~ s/SWISS-PROT:/sp\|/o;
	push(@aliases,$db_ref);
    }
    
    return @aliases;
}

sub get_ec_numbers {
    my ($cdsP) = @_;
    my @ec_numbers = ($$cdsP =~ m{/EC_number=\"([0-9]+\.[0-9\-]+\.[0-9\-]+\.[0-9\-]+)\"}ogs);
    return @ec_numbers;
}

sub get_trans {
    my($cdsP) = @_;
    my $tran = qq();
    
    if ($$cdsP =~ m/\/translation=\"([^\"]*)\"/os) {
	$tran = $1;
	$tran =~ s/\s//gs;
    }
    
#     elsif ($$cdsP =~ m/\/protein_id=\"([^\"]+)\"/o) {
# 	$tran = $1;
# 	$tran =~ s/\s//ogs;
#     }
    
    return $tran;
}

sub get_func {
    my($cdsP) = @_;
    
    my $functions  = [];
    my $products   = [];
    my $prot_descs = [];
    my $notes      = [];
    
    print STDERR qq(\nRecord $recnum:\n$$cdsP\n) if $ENV{VERBOSE};
    
    @$functions = map { s/[\s\n]+/ /ogs; $_ } ($$cdsP =~ m/\/function=\"([^\"]*)\"/ogs);
    if ($ENV{VERBOSE} && @$functions) {
        print STDERR (qq(Functions: ), ((@$functions > 1) ? qq(\n) : qq()));
	print STDERR (join(qq(\n), @$functions), qq(\n));
    }
    
    @$products = map { s/[\s\n]+/ /ogs; $_ } ($$cdsP =~ m/\/product=\"([^\"]*)\"/ogs);
    if ($ENV{VERBOSE} && @$products) {
        print STDERR (qq(Products: ), ((@$products > 1) ? qq(\n) : qq()));
	print STDERR (join(qq(\n), @$products), qq(\n));
    }
    
    @$prot_descs = map { s/[\s\n]+/ /ogs; $_ } ($$cdsP =~ m/\/prot_desc=\"([^\"]*)\"/ogs);
    if ($ENV{VERBOSE} && @$prot_descs) {
        print STDERR (qq(Prot_Descs: ), ((@$prot_descs > 1) ? qq(\n) : qq()));
	print STDERR (join(qq(\n), @$prot_descs), qq(\n));
    }
    
    @$notes = map { s/[\s\n]+/ /ogs; $_ } ($$cdsP =~ m/\/note=\"([^\"]*)\"/ogs);
    if ($ENV{VERBOSE} && @$notes) {
        print STDERR (qq(Notes: ), ((@$notes > 1) ? qq(\n) : qq()));
	print STDERR (join(qq(\n), @$notes), qq(\n));
    }
    
    @$products = grep { !m/^hypothetical\s+protein$/io } @$products;
    
    my $func  = qq();
    my $annotations = [];
    if (@$products) {
	$func = join(q( / ), @$products);
	@$annotations = (@$functions, @$prot_descs, @$notes);
    }
    elsif (@$functions) {
	$func =join(q( / ), @$functions);
	@$annotations =(@$prot_descs, @$notes);
    }
    elsif (@$prot_descs) {
	$func =join(q( / ), @$prot_descs);
	@$annotations = @$notes;
    }
    else {
	$func = qq(hypothetical protein);
	@$annotations = @$notes;
    }
    
    return ($func, $annotations);
}

sub fixup_func {
    my($func) = @_;
    
    $func =~ s/^COG\d+:\s+//oi;
    $func =~ s/^ORFID:\S+\s+//oi;
    return $func;
}

sub ok_func {
    my($func) = @_;
    
    return (
            ($func !~ m/^[a-zA-Z]{1,3}\d+[a-zA-Z]{0,3}(\.\d+([a-zA-Z])?)?$/o) &&
            ($func !~ m/^\d+$/o) &&
            ($func !~ m/ensangp/oi) &&
            ($func !~ m/agr_/oi) &&
	    ($func !~ m/^SC.*:/o) &&
	    ($func !~ m/^RIKEN/o) &&
	    ($func !~ m/\slen: \d+/o) &&
	    ($func !~ m/^similar to/oi) &&
	    ($func !~ m/^CPX/oi) &&
	    ($func !~ m/^\S{3,4}( or \S+ protein)?$/oi) &&
	    ($func !~ m/^putative$/o) &&
	    ($func !~ m/\scomes from/oi) &&
	    ($func !~ m/^unknown( function)?$/oi) &&
	    ($func !~ m/^hypothetical( (function|protein))?$/oi) &&
            ($func !~ m/^orf /oi) &&
            ($func !~ m/^ORF\s?\d+[lr]?$/oi) &&
            ($func !~ m/^[a-z]{1,3}\s?\d+$/oi)
	    );
}

sub process_rna {
    my ($contigID, $type, $rnaP, $prefix, $idNr, $contigs, $fh_tbl, $fh_dna, $fh_func, $fh_annot) = @_;
    my ($loc, @aliases, $func, $trans, $id, $precise, $DNA);
    
    ($loc, $precise) = &get_loc($contigID,$rnaP);
    $func            = &get_rna_func($rnaP);
    
    if ($loc && $precise) {
	if ($dna  = &SeedUtils::extract_seq($contigs,$loc)) {
	    $id = $prefix . qq($$idNr);
	    ++$$idNr;
	    
	    if (! $func ) {
		warn qq(WARNING: could not get func $$rnaP\n) if $ENV{VERBOSE};
	    }
	    else {
		print $fh_func   qq($id\t$func\n);
		print $fh_tbl    qq($id\t$loc\t\n);
		
		&make_annotation($id, qq(Set function to\n$func\nInitial import.), $fh_annot);
		&SeedUtils::display_id_and_seq($id, \$dna, $fh_dna);
	    }
	}
	else {
	    warn (qq(Could not get DNA sequence for RNA at \'$loc\' for entry\n),
		  , q(     ), $type, q(            )
		  , $$rnaP
		  , qq(\nof record begining with:\n)
		  , substr($record, 0, 160)
		  , qq(\n\n)
		  );
	}
    }
    else {
	warn (qq(Could not handle RNA at \'$loc\' for entry\n),
		  , q(     ), $type, q(            )
		  , $$rnaP
		  , qq(\nof record begining with:\n)
		  , substr($record, 0, 160)
		  , qq(\n\n)
		  );
    }
}

sub get_rna_func {
    my($cdsP) = @_;
    my $func = qq();
    
    if ($$cdsP =~ m/\/product=\"([^\"]*)\"/os) {
	$func = $1;
	$func =~ s/\s+/ /gs;
    }
    elsif ($$cdsP =~ m/\/gene=\"([^\"]*)\"/os) {
	$func = $1;
	$func =~ s/\s+/ /ogs;
    }
    elsif ($$cdsP =~ m/\/note=\"([^\"]*)\"/os) {
	$func = $1;
	$func =~ s/\s+/ /ogs;
    }
    return $func;
}

sub make_annotation {
    my ($fid, $note, $fh_ann) = @_;
#   print STDERR Dumper($fid, $note, $fh_ann);
    
    print $fh_ann ($fid, qq(\n));
    print $fh_ann (time, qq(\n));
    print $fh_ann qq(parse_genbank\n);
    print $fh_ann ($note, qq(\n));
    print $fh_ann qq(//\n);
    
    return 1;
}

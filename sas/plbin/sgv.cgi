# -*- perl -*-
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

use SeedHTML;
use strict;
use SeedEnv;
use SeedV;
use ProtSims;
use GenoGraphics;

use CGI;
my $cgi = new CGI;

my $sv_url = "http://seed-viewer.theseed.org/";
$GenoGraphics::image_type = "png";
$GenoGraphics::image_suffix = "png";
$GenoGraphics::temp_url = "/FIG-Tmp";
eval {
    require FIG_Config;
    $GenoGraphics::temp_url = $FIG_Config::temp_url;
    $sv_url = "$FIG_Config::cgi_url/seedviewer.cgi";
};

#print STDERR "$_ = $ENV{$_}\n" for sort keys %ENV;

if (0)
{
    my $VAR1;
    eval(join("",`cat /tmp/sgv_parms`));
    $cgi = $VAR1;
#   print STDERR &Dumper($cgi);
}

if (0)
{
    print $cgi->header;
    my @params = $cgi->param;
    print "<pre>\n";
    foreach $_ (@params)
    {
	print "$_\t:",join(",",$cgi->param($_)),":\n";
    }

    if (0)
    {
	if (open(TMP,">/tmp/sgv_parms"))
	{
	    print TMP &Dumper($cgi);
	    close(TMP);
	}
    }
    exit;
}


my $html = [];
unshift @$html, "<TITLE>Simple Genome Viewer</TITLE>\n";

my $dir = $cgi->param('dir');
if ((! $dir) || ($dir !~ /\d+\.\d+$/))
{
    push(@$html,$cgi->h2('You must set dir= to a SEED-format genome directory with a path ending in the genome ID'));
    &SeedHTML::show_page($cgi,$html);
    exit;
}

my $request = $cgi->param('request');
if (! $request)
{
    &start_computing_reference_genome_set($cgi,$dir,$html);
    &make_subsystem_index($cgi,$html,$dir);
    &basic_query($cgi,$html);
}
elsif ($request eq 'basic')
{
    &basic_query($cgi,$html);
}
elsif ($request eq 'id')
{
    &process_id($cgi,$html);
}
elsif ($request eq 'features')
{
    &process_feature_search($cgi,$html);
}
elsif ($request eq 'feature')
{
    &process_feature_display($cgi,$html);
}
elsif ($request eq 'subsystems')
{
    &process_subsystems_search($cgi,$html);
}
elsif ($request eq 'peg2subsystems')
{
    &process_peg2subsystems_search($cgi,$html);
}
elsif ($request eq 'compare')
{
    &comparison($cgi,$html);
}
elsif ($request eq 'corresponding')
{
    &process_corr_search($cgi,$html);
}
elsif ($request =~ 'query_only')
{
    &process_query_only_search($cgi,$html);
}
elsif ($request eq 'reference_only')
{
    &process_ref_only_search($cgi,$html);
}

&SeedHTML::show_page($cgi,$html);


sub make_subsystem_index {
    my($cgi,$html,$dir) = @_;

    my %ss = map { chomp; my($subsys,$var) = split(/\t/,$_); (($var ne "-1") && ($var ne 0)) ? (&fix_ss($subsys) => $var) : () }
             `cat $dir/Subsystems/subsystems`;

    my $sapObject = SAPserver->new;
    my $ssH       = $sapObject->classification_of( -ids => [keys(%ss)]);
    open(INDEX,"| sort > $dir/Subsystems/subsystems.index") || die "could not open $dir/Subsystems/subsystems.index";
    foreach $_ (`cat $dir/Subsystems/bindings`)
    {
	chomp;
	my($subsys,$role,$peg) = split(/\t/,$_);
	$subsys = &fix_ss($subsys);
	if ($ss{$subsys})
	{
	    my $class = ($_ = $ssH->{$subsys}) ? join("; ",@$_) : "";
	    print INDEX join("\t",($class,$subsys,$role,$ss{$subsys},$peg)),"\n";
	}
    }
    close(INDEX);
}

sub id_search_form {
    my($cgi,$dir,$html) = @_;

    my $queryG = $cgi->param('genome');
    push(@$html,$cgi->start_form(), # -action => "sgv.cgi"),
	        '<br><b>Get Protein Page for FIG ID, or ACH Page for non-FIG IDs</b><br><br> ',
	        $cgi->textfield(-name => 'id', -size => 20),
	        $cgi->submit('go'),
	        $cgi->hidden(-name => 'request', -value => 'id', -override => 1),
	        $cgi->hidden(-name => 'dir', -value => $dir, -override => 1),
	        $cgi->end_form,
	        $cgi->hr,$cgi->hr);
}

sub start_computing_reference_genome_set {
    my($cgi,$dir,$html) = @_;
	
    if (! -d "$dir/CorrToReferenceGenomes")
    {
	my $rc = system "$FIG_Config::bin/get_neighbors_and_corr_to_ref $dir &";
    }
}

sub basic_query {
    my($cgi,$html) = @_;

    my $queryG = $cgi->param('genome');
    my $dir    = $cgi->param('dir');

    &id_search_form($cgi,$dir,$html);

    push(@$html,$cgi->start_form(), # -action => "sgv.cgi"),
	        '<b>Query Features in Genome</b>: ',
	        $cgi->textfield(-name => 'pattern', -size => 30),
	        $cgi->submit('go'),
	        $cgi->hidden(-name => 'request', -value => 'features', -override => 1),
	        $cgi->hidden(-name => 'dir',   -value => $dir, -override => 1),
	        $cgi->end_form,
	        $cgi->hr,

	        $cgi->start_form(), # -action => "sgv.cgi"),
	        '<b>Query Subsystems in Genome</b>: ',
	        $cgi->textfield(-name => 'pattern', -size => 30),
	        $cgi->submit('go'),
	        $cgi->hidden(-name => 'request', -value => 'subsystems', -override => 1),
	        $cgi->hidden(-name => 'dir',   -value => $dir, -override => 1),
	        $cgi->end_form,
	        $cgi->hr
	);

    my $cache = "$dir/CorrToReferenceGenomes";
    my @refG;
    if (opendir(CACHE,$cache))
    {
	@refG = map { ((-s "$cache/$_") && ($_ =~ /^(\d+\.\d+$)/)) ? $1 : () } readdir(CACHE);
	closedir(CACHE);
    }
    else
    {
	@refG = ();
    }

    if (@refG > 0)
    {
	my $sapObject = SAPserver->new();
	my($refG,$labels) = &build_labels(\@refG,$sapObject);

	push(@$html,$cgi->start_form(), # -action => "sgv.cgi"),
	            '<b>Compare Genome Against Reference Genome</b>: ',
	            $cgi->scrolling_list( -name     => 'reference',
					  -values   => $refG,
					  -labels   => $labels,
					  -size     => 4),
	            $cgi->submit('go'),
	            $cgi->hidden(-name => 'request', -value => "compare", -override => 1),
	            $cgi->hidden(-name => 'dir',   -value => $dir, -override => 1),
	            $cgi->end_form
            );
    }
}

sub build_labels {
    my($genomes,$sapObject) = @_;

    my $genomesH  = $sapObject->all_genomes(-complete => 1);
    my $metricsH  = $sapObject->genome_metrics(-ids => $genomes);
    my %labels    = map { my($contigs,$sz) = @{$metricsH->{$_}}; 
			  my $lab = $genomesH->{$_} . " ($_): $sz bp, $contigs contigs";
			  $_ => $lab
                        } 
                    @$genomes;

    my @genomes = sort { lc($labels{$a}) cmp lc($labels{$b}) } @$genomes;
    
    return (\@genomes,\%labels);
}

sub process_feature_search {
    my($cgi,$html) = @_;

    my $pattern = $cgi->param('pattern');
    my $dir     = $cgi->param('dir');
    my $file    = "$dir/assigned_functions";
    my @hits    = &process_index($file,$pattern);
    &format_function_table($cgi,$html,\@hits);
}

sub process_subsystems_search {
    my($cgi,$html) = @_;

    my $pattern = $cgi->param('pattern');
    my $dir     = $cgi->param('dir');
    my $file    = "$dir/Subsystems/subsystems.index";
    my @hits    = &process_index($file,$pattern);
    &format_subsystems_table($cgi,$html,\@hits);
}

sub process_peg2subsystems_search {
    my($cgi,$html) = @_;

    my $peg     = $cgi->param('peg');
    my $dir     = $cgi->param('dir');
    my $file    = "$dir/Subsystems/subsystems.index";
    my %subs    = map { $_->[1] => 1 } &process_index($file,$peg);
    my @hits    = sort { ($a->[0] cmp $b->[0]) or ($a->[1] cmp $b->[1]) or ($a->[2] cmp $b->[2])
			     or &SeedUtils::by_fig_id($a->[4],$b->[4]) }
	          map { chop; [split(/\t/,$_)] }
	          grep { ($_ =~ /^[^\t]*\t([^\t]+)/) && $subs{$1} } 
                  `cat $file`;
    &format_subsystems_table($cgi,$html,\@hits);
}

sub comparison {
    my($cgi,$html) = @_;

    my $refG   = $cgi->param('reference');
    my $queryG = $cgi->param('genome');
    my $dir  = $cgi->param('dir');
    push(@$html,$cgi->start_form(), # -action => "sgv.cgi"),
	        '<b>Corresponding Features</b>: ',
	        $cgi->textfield(-name => 'pattern', -size => 30),
	        $cgi->submit('go'),
	        $cgi->hidden(-name => 'request', -value => 'corresponding', -override => 1),
	        $cgi->hidden(-name => 'dir',   -value => $dir, -override => 1),
	        $cgi->hidden(-name => 'reference',   -value => $refG, -override => 1),
	        $cgi->end_form,
	        $cgi->hr,

                $cgi->start_form(), # -action => "sgv.cgi"),
	        '<b>Features in Query, but Not Reference</b>: ',
	        $cgi->textfield(-name => 'pattern', -size => 30),
	        $cgi->submit('go'),
	        $cgi->hidden(-name => 'request', -value => 'query_only', -override => 1),
	        $cgi->hidden(-name => 'dir',   -value => $dir, -override => 1),
	        $cgi->hidden(-name => 'reference',   -value => $refG, -override => 1),
	        $cgi->end_form,
	        $cgi->hr,

                $cgi->start_form(), # -action => "sgv.cgi"),
	        '<b>Features in Reference, but Not Query</b>: ',
	        $cgi->textfield(-name => 'pattern', -size => 30),
	        $cgi->submit('go'),
	        $cgi->hidden(-name => 'request', -value => 'reference_only', -override => 1),
	        $cgi->hidden(-name => 'dir',   -value => $dir, -override => 1),
	        $cgi->hidden(-name => 'reference',   -value => $refG, -override => 1),
	        $cgi->end_form,
	        $cgi->hr
	);
}	 

sub process_corr_search {
    my($cgi,$html) = @_;

    my $pattern = $cgi->param('pattern');
    my $dir     = $cgi->param('dir');
    my $refG    = $cgi->param('reference');
    my $refGgs  = &genus_species($refG);
    my $genome  = $cgi->param('genome');
    my $file    = "$dir/CorrToReferenceGenomes/$refG";
    my @corr    = sort { &SeedUtils::by_fig_id($a->[0],$b->[0]) }
                  map { chomp; [split(/\t/,$_)] } `cat $file`;

    my @genes   = map { ($_->[0],$_->[1]) } @corr;
    my $col_headings = ['PEG','Function','reference','Reference Function','P-sc',
			'BBH','Context-Matches','AliasesR'];
    my $tab = [];
    foreach my $entry (@corr)
    {
	my($pegG,$pegR,$n_context,undef,$funcG,$funcR,$aliasesG,$aliasesR,$bbh,undef,$psc) = @$entry;

	push(@$tab,[&peg_link($cgi,$pegG),$funcG,&ref_peg_link($cgi,$pegR),$funcR,
		    $psc,$bbh,$n_context,$aliasesR]);
    }
    my $filtered = &filter_tab_entries($tab,$pattern);
    push(@$html,&SeedHTML::make_table($col_headings,$filtered,"Correspondences with $refGgs"));
}

sub process_query_only_search {
    my($cgi,$html) = @_;

    my $pattern = $cgi->param('pattern');
    my $dir     = $cgi->param('dir');
    my $refG    = $cgi->param('reference');
    my $refGgs  = &genus_species($refG);
    my $queryG  = $cgi->param('genome');
    my $file    = "$dir/CorrToReferenceGenomes/$refG";
    my %in_corr = map { $_ =~ /^(\S+)/; $1 => 1 } `cat $file`;
    
    my @to_show    = grep { ! $in_corr{$_} } 
                     map { $_ =~ /^(\S+)/; $1 } 
                     `cut -f1 $dir/Features/peg/tbl`;
    my %functionsH = map { $_ =~ /^(\S+)\t(\S.*\S)/; $1 => $2 } `cat $dir/assigned_functions`;
    my $col_hdrs     = ["PEG","Function"];
    my @tab          = map { [&peg_link($cgi,$_),$functionsH{$_} ? $functionsH{$_} : ""] }
                       sort { &SeedUtils::by_fig_id($a,$b) } @to_show;
    my $filtered = &filter_tab_entries(\@tab,$pattern);
    if (@$filtered > 0)
    {
	push(@$html,&SeedHTML::make_table($col_hdrs,$filtered,"Genes Missing in Reference Genome $refGgs"));
    }
    else
    {
	push(@$html,$cgi->h2('No Genes Found only in the Given Genome'));
    }
}

sub process_ref_only_search {
    my($cgi,$html) = @_;

    my $pattern = $cgi->param('pattern');
    my $dir     = $cgi->param('dir');
    my $refG    = $cgi->param('reference');
    my $refGgs  = &genus_species($refG);

    my $queryG  = $cgi->param('genome');
    my $file    = "$dir/CorrToReferenceGenomes/$refG";

    my %in_ref = map { $_ =~ /^\S+\t(\S+)/; $1 => 1 } `cat $file`;
    
    my $sapObject  = SAPserver->new();
    my $genomeH    = $sapObject->all_features(-ids => [$refG], -type => 'peg');
    my @to_show    = grep { ! $in_ref{$_} } @{$genomeH->{$refG}};
    
    my $functionsH   = $sapObject->ids_to_functions(-ids => \@to_show);
    my $col_hdrs     = ["PEG","Function"];
    my @tab          = map { [&ref_peg_link($cgi,$_),$functionsH->{$_} ? $functionsH->{$_} : ""] }
                       sort { &SeedUtils::by_fig_id($a,$b) } @to_show;
    my $filtered = &filter_tab_entries(\@tab,$pattern);
    if (@$filtered > 0)
    {
	push(@$html,&SeedHTML::make_table($col_hdrs,$filtered,"Genes Present Only in Reference Genome $refGgs"));
    }
    else
    {
	push(@$html,$cgi->h2('No Genes Found only in $refGgs'));
    }
}

sub genus_species {
    my($g) = @_;

    my $sapO = SAPserver->new;
    my $gH   = $sapO->genome_names( -ids => $g);
    return $gH->{$g};
}

sub process_index {
    my($file,$pattern) = @_;

    my @lines = `cat $file`;
    if ( ! $pattern)
    {
	return map { chop; [split(/\t/,$_)] } @lines;
    }
    elsif ($pattern =~ /^\s*\/(.*)\/\s*$/)
    {
	return &perl_patmatch(\@lines,$1);
    }
    else
    {
	return &substr_match(\@lines,$pattern);
    }
}

sub perl_patmatch {
    my($lines,$pat) = @_;

    my @lines = grep { $_ =~ /$pat/i } @$lines;
    return map { chop; [split(/\t/,$_)] } @lines;
}

sub substr_match {
    my($lines,$pat) = @_;

    $pat =~ s/^\s+//;
    $pat =~ s/\s+$//;
    my @words = split(/\s+/,$pat);
    my @lines = @$lines;
    foreach my $word (@words)
    {
	@lines = grep { &matchword($word,$_) } @lines;
    }
    return map { chop; [split(/\t/,$_)] } @lines;
}

sub matchword {
    my($word,$str) = @_;

    my $wordL = lc $word;
    my $strL  = lc $str;
    if (index($strL,$wordL) >= 0)
    {
	if  ($wordL =~ /^fig\|\d+\.\d+\.peg\.\d+$/i)
	{
	    my $wordQ = quotemeta $wordL;
	    return ($strL =~ /$wordQ\b/);
	}
	return 1;
    }
    return 0;
}

sub format_function_table {
    my($cgi,$html,$entries) = @_;

    my $col_hdrs = ['ID','Type','Function','Psi-blast','Subsystems'];
    my $tab = [];

    foreach my $entry (@$entries)
    {
	my($fid,$function) = @$entry;
	$fid =~ /fig\|\d+\.\d+\.([^\.]+)\.\d+$/;
	my $type = $1;
	if ($type eq "peg")
	{
	    push(@$tab,[ 			 
		         &comp_reg_link($fid,$cgi), 
			 'peg',
			 $function,
			 &psi_blast_link($fid),
			 &subsys_link($cgi,$fid)
		       ]);
	}
	else
	{
	    push(@$tab,[$fid,$type,$function,"",""]);
	}
    }

    if (@$tab > 0)
    {
	push(@$html,&SeedHTML::make_table($col_hdrs,$tab,"Features"));
    }
    else
    {
	push(@$html,$cgi->h3('no matches'));
    }
    push(@$html,$cgi->hr,&query_link($cgi));
}

sub format_subsystems_table {
    my($cgi,$html,$entries) = @_;

    my $col_hdrs = ['Classification','Subsystem','Role','Variant','PEG'];
    my $tab = [];

    foreach my $entry (@$entries)
    {
	my($class,$subsys,$role,$variant,$peg) = @$entry;
	push(@$tab,[
		    $class,
		    &fix_ss($subsys),
		    $role,
		    $variant,
		    &peg_link($cgi,$peg)
		  ]);
    }
    if (@$tab > 0)
    {
	push(@$html,&SeedHTML::make_table($col_hdrs,$tab,"Subsystems"));
    }
    else
    {
	push(@$html,$cgi->h3('no matches'));
    }
    push(@$html,$cgi->hr,&query_link($cgi));
}

sub url_to_new {
    my($cgi,$fid) = @_;
    
    if ($fid !~ /\.peg\./) { return "" }
    my $dir = $cgi->param('dir');
    my $url   = $cgi->url() . "?request=features&dir=$dir&pattern=$fid";
    return $url;
}

sub url_to_sv {
    my($cgi,$fid) = @_;
    
    if ($fid !~ /\.peg\./) { return "" }
    my $dir = $cgi->param('dir');
    return "$sv_url?page=Annotation;feature=$fid";
}

sub comp_reg_link {
    my($peg,$cgi) = @_;

    my $target = "target.$$";
    my $dir = $cgi->param('dir');
    my $url   = $cgi->url() . "?request=feature&fid=$peg&dir=$dir";
    return "<a target=$target href=$url>$peg</a>";
}

sub psi_blast_link {
    my($peg) = @_;

    my $url = "http://seed-viewer.theseed.org/protein.cgi?prot=$peg&request=use_protein_tool&tool=Psi-Blast";
    my $target = "target.$$";
    return "<a target=$target href=$url>Psi</a>";
}

sub ach_link {
    my($cgi,$peg) = @_;
    my $url = "http://seed-viewer.theseed.org/seedviewer.cgi?page=ACHresults&query=$peg";
    my $target = "target.$$";
    return "<a target=$target href=$url>ACH</a>";
}

sub subsys_link {
    my($cgi,$peg) = @_;

    my $dir    = $cgi->param('dir');
    my $url    = $cgi->url() . "?request=peg2subsystems&dir=$dir&peg=$peg";
    my $target = "target.$$";
    return "<a target=$target href=$url>sub</a>";
}

sub peg_link {
    my($cgi,$peg) = @_;

    my $dir = $cgi->param('dir');
    my $url   = $cgi->url() . "?request=features&dir=$dir&pattern=$peg";
    my $target = "target.$$";
    return "<a target=$target href=$url>$peg</a>";
}

sub ref_peg_link {
    my($cgi,$peg) = @_;


    my $target = "target.$$";
    my $url = "http://seed-viewer.theseed.org/seedviewer.cgi?page=Annotation&feature=$peg";
    return "<a target=$target href=$url>$peg</a>";
}

sub query_link {
    my($cgi) = @_;

    my $dir     = $cgi->param('dir');
    my $url  = $cgi->url() . "?request=basic&dir=$dir";
    return "<a href=$url>Basic Query Form</a>";
}

sub filter_tab_entries {
    my($tab,$pattern) = @_;

    if (! $pattern)  { return $tab }
    
    my $filtered = [];
    foreach my $entry (@$tab)
    {
	my @tmp = &substr_match([join("\t",@$entry)],$pattern);
	if (@tmp > 0)
	{
	    push(@$filtered,$entry);
	}
    }
    return $filtered;
}

sub process_id {
    my($cgi,$html) = @_;

    my $id = $cgi->param('id');
    if ($id =~ /^\s*(fig\|\d+\.\d+\.peg\.\d+)\s*$/)
    {
	my $peg = $1;
	print $cgi->redirect("http://seed-viewer.theseed.org/seedviewer.cgi?page=Annotation&feature=$peg");
	exit;
    }
    elsif ($id =~ /^\s*(\S+)\s*$/)
    {
	print $cgi->redirect("http://seed-viewer.theseed.org/seedviewer.cgi?page=ACHresults&query=$1");
	exit;
    }
    else
    {
	push(@$html,$cgi->h2('Invalid request'));
    }
}

sub process_feature_display {
    my($cgi,$html) = @_;

    my $dir = $cgi->param('dir');
    my $seedV = SeedV->new($dir);
    my $sapObject  = SAPserver->new();

    my $fid = $cgi->param('fid');
    my $func = $seedV->function_of($fid);
    my $loc = $seedV->feature_location($fid);
    my $dna_seq = $seedV->dna_seq($loc);

    my ($contig,$beg,$end);
    if ($loc =~ /^(\S+)_(\d+)_(\d+)$/) 
    { 
	($contig,$beg,$end) = ($1,$2,$3);
	$loc = "contig: $1, from $2 to $3" 
    }
    push(@$html,$cgi->h1("Feature: $fid"),$cgi->h2("Function: $func"),$cgi->h3("Location: $loc"));
    &push_seq($cgi,$html,$fid,$dna_seq);

    if (($fid =~ /\.peg\.\d+$/) && $contig)
    {
	my $pseq = $seedV->get_translation($fid);
	&push_seq($cgi,$html,$fid,$pseq);
	&push_compare_regions($cgi,$html,$fid,$sapObject,$seedV,$contig,$beg,$end);
    }
}

sub push_seq {
    my($cgi,$html,$id,$pseq) = @_;

    push(@$html,"<pre>\n>$id\n");
    my $i;
    for ($i=0; ($i < length($pseq)); $i += 60)
    {
	my $piece = ($i < (length($pseq) - 60)) ? substr($pseq,$i,60) : substr($pseq,$i);
	push(@$html,"$piece\n");
    }
    push(@$html,"</pre>\n");
}

sub push_compare_regions {
    my($cgi,$html,$fid,$sapObject,$seedV,$contig,$beg,$end) = @_;

    my $mid = int(($beg+$end)/2);
    my $min = ($beg < $end) ? ($mid - 4000) : $mid - 4000;
    my $max = ($beg < $end) ? ($mid + 4000) : $mid + 4000;

    my ($genes,$minV,$maxV) = $seedV->genes_in_region($contig,$min,$max);
    my %genesG = map { ($_ => 1 ) } @$genes;
    my %locsG = map { $_ => $seedV->feature_location($_) } @$genes;

    my $dir = $cgi->param('dir');
    my $cache = "$dir/CorrToReferenceGenomes";
    my %connected;
    my %color;      # note that for simplicity, I am using peg ids in the given genome as symbolic colors

    foreach $_ (`cat $cache/* | cut -f1,2`)
    {
	if (($_ =~ /^(\S+)\t(\S+)/) && $genesG{$1})
	{
	    push(@{$connected{$1}},$2);
	    $color{$2} = $1;
	}
    }

    my $pinned = $connected{$fid};
    my $locH   = {};
    if ($pinned)
    {
	my $pinLocH = $sapObject->fid_locations( -boundaries => 1, -ids => $pinned);
	my @locations = map { &format_location($pinLocH->{$_}) } keys(%$pinLocH);
	$locH = $sapObject->genes_in_region( -locations => \@locations, -includeLocation => 1);
    }
#    print &Dumper(\%genesG,\%locsG,$pinned,$locH,\%color);
    my @x = @{&build_maps($seedV,$sapObject,$fid,\%genesG,\%locsG,$pinned,$locH,\%color,$cgi)};
#   print STDERR &Dumper(\@x); die "aborted";
    push(@$html,@{&build_maps($seedV,$sapObject,$fid,\%genesG,\%locsG,$pinned,$locH,\%color,$cgi)});
}

sub format_location {
    my($loc) = @_;

    if ($loc =~ /^(\d+\.\d+):(\S+)_(\d+)([+-])(\d+)$/)
    {
	my($genome,$contig,$beg,$strand,$ln) = ($1,$2,$3,$4,$5);
	
	my($min,$max);
	if ($strand eq "+")
	{
	    $min = &SeedUtils::max(1,$beg-4000);
	    $max = $beg+$ln+4000;
	}
	else
	{
	    $min = &SeedUtils::max(1,$beg-($ln+4000));
	    $max = $beg + 4000;
	}
	return "$genome:$contig\_$min\_$max";
    }
    else
    {
	die "bad location: $loc";
    }
}

sub build_maps {
    my($seedV,$sapObject,$pegG,$genesG,$locsG,$pinned,$locH,$color,$cgi) = @_;

    
    my @genome_ids = map { &SeedUtils::genome_of($_) } @$pinned;
    my $genomeH = $sapObject->genome_names( -ids => \@genome_ids);
#
# first, compute a list of what we use to build each map.  This will include
#
#     [pinned_gene, Contig,Beg,End,GenusSpecies]]
#     [[gene,Contig,Beg,End,color],...]      sorted in order
#
    my @map_data = ();
    push(@map_data,&data_for_given_genome($pegG,$genesG,$locsG,$seedV));

    foreach my $pegR (@$pinned)
    {
	push(@map_data,&data_for_pinned($pegR,$locH,$color,$genomeH));
    }
    &set_colors($pegG,\@map_data);

    my $functionH = &function_hash($sapObject,$seedV,\@map_data);

    my $gg = [];
    my $sz_region = 8500;

    foreach my $map_set (@map_data) 
    {
	my($pin_data,$gene_data) = @$map_set;
	my($peg,$contig,$beg,$end,$genus_species) = @$pin_data;

        if ($contig && $beg && $end) {
            my $mid = int(($beg + $end) / 2);
            my $min = int($mid - ($sz_region / 2));
            my $max = int($mid + ($sz_region / 2));
            my $genes = [];
            foreach my $entry (@$gene_data)
	    {
		my($fid1,$contig1,$beg1,$end1,$color) = @$entry;
                $beg1 = &in_bounds($min,$max,$beg1);
                $end1 = &in_bounds($min,$max,$end1);
                my $function = $functionH->{$fid1};
		if (! $function) { $function = "hypothetical protein" }
                my $info = join('<br/>', "<b>PEG:</b> $fid1",
                                         "<b>Contig:</b> $contig1",
                                         "<b>Begin:</b> $beg1",
                                         "<b>End:</b> $end1",
                                         $function ? "<b>Function:</b> $function" : ()
                               );

		my $shape = "Rectangle";
		if    (($fid1 !~ /\.bs\./) && ($beg1 < $end1))        { $shape = "rightArrow" }
		elsif (($fid1 !~ /\.bs\./) && ($beg1 > $end1))        { $shape = "leftArrow" }

                my $gene_entry = [&min($beg1,$end1),
				  &max($beg1,$end1),
				  $shape,
				  ($fid1 !~ /\.bs\./) ? $color : 'black',
				  undef,,
				  (@$gg == 0) ? &url_to_new($cgi,$fid1) : &url_to_sv($cgi,$fid1),
				  $info
		                ];

		push(@$genes,$gene_entry);
            }

            #  Sequence title can be replaced by [ title, url, popup_text, menu, popup_title ]
	    
            my $desc = "Genome: $genus_species<br />Contig: $contig";
            my $map = [ [ SeedUtils::abbrev( $genus_species ), undef, $desc, undef, 'Contig' ],
			0,
			$max+1 - $min,
			($beg < $end) ? &decr_coords($genes,$min) : &flip_map($genes,$min,$max)
		      ];

            push(@$gg,$map);
        }
    }

    &GenoGraphics::disambiguate_maps($gg);
    return &GenoGraphics::render($gg,700,4,0,2);
}
	    
sub data_for_given_genome {
    my($peg,$pegs,$locs,$seedV) = @_;

    my @gene_data = ();
    foreach my $peg1 (keys(%$pegs))
    {
	push(@gene_data,[$peg1,&split_loc($locs->{$peg1}),$peg1]);
    }
    @gene_data = sort { ($a->[2]+$a->[3]) <=> ($b->[2]+$b->[3]) } @gene_data;
    return [[$peg,&split_loc($locs->{$peg}),$seedV->genus_species],[@gene_data]];
}

sub data_for_pinned {
    my($peg,$locH,$color,$genomeH) = @_;

    my $genome = &SeedUtils::genome_of($peg);
    my @tmp = grep { $locH->{$_}->{$peg} } keys(%$locH);
    my $locH1 = $locH->{$tmp[0]};
    my $pinned_data = [$peg,&split_new_loc($locH1->{$peg}->[0]),$genomeH->{&SeedUtils::genome_of($peg)}];
    my @gene_data   = ();
    foreach my $peg1 (keys(%$locH1))
    {
#	print STDERR &Dumper($peg1,$color->{$peg1}); die "aborted";
	push(@gene_data,[$peg1,&split_new_loc($locH1->{$peg1}->[0]),$color->{$peg1}]);
    }
    @gene_data = sort { ($a->[2]+$a->[3]) <=> ($b->[2]+$b->[3]) } @gene_data;
    return [$pinned_data,[@gene_data]];
}

sub split_loc {
    my($loc) = @_;

    if ($loc && ($loc =~ /^(.*:)?(\S+)_(\d+)_(\d+)$/))
    {
	return ($2,$3,$4);
    }
    die "bad_loc: $loc";
}

sub split_new_loc {
    my($loc) = @_;

    if ($loc =~ /^(\d+\.\d+):(\S+)_(\d+)([+-])(\d+)$/)
    {
	my($genome,$contig,$beg,$strand,$ln) = ($1,$2,$3,$4,$5);
	if ($strand eq "+")
	{
	    return ($contig,$beg,$beg+$ln-1);
	}
	else
	{
	    return ($contig,$beg,$beg-($ln-1));
	}
    }
    die "bad_loc: $loc";
}

sub in_bounds {
    my($min,$max,$x) = @_;

    if     ($x < $min)     { return $min }
    elsif  ($x > $max)     { return $max }
    else                   { return $x   }
}

sub decr_coords {
    my($genes,$min) = @_;
    my($gene);

    foreach $gene (@$genes) {
        $gene->[0] -= $min;
        $gene->[1] -= $min;
    }
    return $genes;
}

sub function_hash {
    my($sapObject,$seedV,$map_data) = @_;

    my $functionH = {};
    my $gene_data = $map_data->[0]->[1];
    foreach my $tuple (@$gene_data)
    {
	my $fid   = $tuple->[0];
	my $func  = $seedV->function_of($fid);
	$functionH->{$fid} = $func;
    }

    my $i;
    my @ids = ();
    for ($i=1; ($i < @$map_data); $i++)
    {
	$gene_data = $map_data->[$i]->[1];
	push(@ids,map { $_->[0] } @$gene_data);
    }

    my $fH = $sapObject->ids_to_functions( -ids => \@ids);
    while (my($id,$func) = each(%$fH))
    {
	$functionH->{$id} = $func;
    }
    return $functionH;
}

sub flip_map {
    my($genes,$min,$max) = @_;
    my($gene);

    foreach $gene (@$genes) {
        ($gene->[0],$gene->[1]) = ($max - $gene->[1],$max - $gene->[0]);
	if      ($gene->[2] eq "rightArrow")  { $gene->[2] = "leftArrow" }
	elsif   ($gene->[2] eq "leftArrow")   { $gene->[2] = "rightArrow" }
    }
    return $genes;
}


sub set_colors {
    my($red_peg,$map_data) = @_;

    my %colors;
    foreach my $map (@$map_data)
    {
	my $genes = $map->[1];
	foreach $_ (@$genes)
	{
	    if ($_->[4])
	    {
		$colors{$_->[4]}++;
	    }
	}
    }
    my @by_occ = sort { $colors{$b} <=> $colors{$a} } keys(%colors);
    my $i;
    my %to_color;
    for ($i=1; ($i <= @by_occ); $i++)
    {
	$to_color{$by_occ[$i-1]} = "color$i";
    }
    $to_color{$red_peg} = "red";
    foreach my $map (@$map_data)
    {
	my $genes = $map->[1];
	foreach $_ (@$genes)
	{
	    if ($_->[4])
	    {
		$_->[4] = $to_color{$_->[4]};
	    }
	    else
	    {
		$_->[4] = 'grey';
	    }
	}
    }
}

sub fix_ss {
    my($ss) = @_;

    $ss =~ s/_/ /g;
    return $ss;
}

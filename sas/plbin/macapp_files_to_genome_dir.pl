#!/usr/bin/perl
use strict;
use Data::Dumper;
use SeedEnv;
use File::Copy;

# This is a SAS component

#
# Convert the raw mac-app output files to a SEED genome directory.
#

my $usage = "macapp_files_to_genome_dir genome-id macapp-data-dir dest-dir";

@ARGV == 3 or die "$usage\n";

my $genome_id = shift;
my $src_dir = shift;
my $dest_dir = shift;


my $genome_dir = "$dest_dir/$genome_id";
-d $genome_dir || mkdir($genome_dir);

my %next_id = (peg => 1, rna => 1);


#
# Start by walking the proteins to create the features directory. We
# assign pegs as well as part of the genome ID we picked.
#

my %id_map;

my $rna_dir = "$genome_dir/Features/rna";
my $peg_dir = "$genome_dir/Features/peg";

SeedUtils::verify_dir($peg_dir);
SeedUtils::verify_dir($rna_dir);

open(AF, ">", "$genome_dir/assigned_functions") or die "Cannot write $genome_dir/assigned_functions: $!";

write_features("$src_dir/call_genes.out", "$src_dir/call_genes.err", "peg", $peg_dir, \*AF);
write_features("$src_dir/find_rnas.out", "$src_dir/find_rnas.err", "rna", $rna_dir, \*AF);

open(AI, "<", "$src_dir/annotation.out") or die "Cannot open $src_dir/annotation.out: $!";
while (<AI>)
{
    chomp;
    my($hits, $id, $func) = split(/\t/);
    my $nid = $id_map{$id};
    print AF join("\t", $nid, $func), "\n";
}
close(AF);

copy("$src_dir/contigs", "$genome_dir/contigs");

SeedUtils::verify_dir("$genome_dir/Subsystems");
open(M, "<", "$src_dir/metabolic_reconstruction.out") or die "Cannot open $src_dir/metabolic_reconstruction.out: $!";
open(B, ">", "$genome_dir/Subsystems/bindings") or die "cannot write $genome_dir/Subsystems/bindings: $!";
open(S, ">", "$genome_dir/Subsystems/subsystems") or die "cannot write $genome_dir/Subsystems/subsystems: $!";

my %ss_seen;
while (<M>)
{
    chomp;
    my($hits, $id, $contig, $beg, $end, $func, $subsystem, $variant) = split(/\t/);

    my $nid = $id_map{$id};

    print B join("\t", $subsystem, $func, $nid), "\n";

    if (!$ss_seen{$subsystem})
    {
	print S join("\t", $subsystem, $variant), "\n";
	$ss_seen{$subsystem}++;
    }
	
}
close(M);
close(B);
close(S);

sub write_features
{
    my($fasta_in, $tbl_in, $type, $out_dir, $assigned_funcs_fh) = @_;
    
    open(G, "<", $fasta_in) or die "Cannot open $fasta_in: $!";
    open(FA, ">", "$out_dir/fasta") or die "Cannot write $out_dir/fasta: $!";

    while (<G>)
    {
	if (/^>(\S+)(.*)/)
	{
	    my $id = $next_id{$type}++;
	    my $fid = "fig|$genome_id.$type.$id";
	    $id_map{$1} = $fid;
	    print FA ">$fid$2\n";
	}
	else
	{
	    print FA $_;
	}
    }
    close(G);
    close(FA);

    open(TI, "<", $tbl_in) or die "Cannot open $tbl_in: $!";
    open(TO, ">", "$out_dir/tbl") or die "Cannot open $out_dir/tbl: $!";

    while (<TI>)
    {
	chomp;
	my($id, $contig, $b, $e, $fun) = split(/\t/);
	my $nid = $id_map{$id};
	my $loc = join("_", $contig, $b, $e);
	print TO join("\t", $nid, $loc, $fun), "\n";
	if ($fun)
	{
	    print $assigned_funcs_fh "$nid\t$fun\n";
	}
    }
    close(TI);
    close(TO);
}



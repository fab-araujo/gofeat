########################################################################

# This is a SAS Component

use SeedHTML;
use strict;
use SeedEnv;
use ProtSims;
use gjoseqlib;
use Data::Dumper;
use SeedAware;

my $usage = "usage: get_neighbors_and_corr_to_ref GenomeDir";
my $gdir;

$| = 1;

my $sapO = SAPserver->new;

($gdir   =  shift @ARGV)
    || die $usage;
($gdir =~ /(\d+\.\d+)$/) || die "Invalid Genome Directory: $gdir";
my $gdir_id = $1;

my @fasta = &gjoseqlib::read_fasta("$gdir/Features/peg/fasta");
my %id2seqH = map { ($_->[2] && (length($_->[2]) > 30)) ? ($_->[0] => $_->[2]) : () } @fasta;

&SeedUtils::verify_dir("$gdir/CorrToReferenceGenomes");
print "Finding neighbors\n";
my @poss_pegs = &prioritize_pegs_used_to_find_neighbors($gdir);
print "found " . scalar(@poss_pegs) . " poss_pegs\n";
my %counts;
my $best  = 0;
my $tuple;
while (($best < 500) && ($tuple = shift @poss_pegs))
{
    my($role,$peg) = @$tuple;
    if ($id2seqH{$peg} && (length($id2seqH{$peg}) > 30))
    {
	&compute_hits_and_set_best($tuple,\%id2seqH,\%counts,\$best);
    }
}
if ($best == 0) { die "$gdir describes a genome without enough RAST-called genes to identify neighbors" }
my @reference = sort { $counts{$b} <=> $counts{$a} } keys(%counts);
if (@reference > 30) { $#reference = 29 }

my $genomesH  = $sapO->all_genomes(-complete => 1);
open(CLOSE,">$gdir/closest.genomes") || die "could not open closest.genomes";
print "Generating correspondences for these genomes:\n";
print "\t$_\n" for @reference;
foreach my $g2 (@reference)
{
    if ($g2 ne $gdir_id)
    {
	print "Generating correspondences for $g2...\n";
	&generate_correspondence_table($g2,$gdir);
	print "Generating correspondences for $g2...done\n";
	print CLOSE join("\t",($g2,$genomesH->{$g2})),"\n";
    }
}
close(CLOSE);

sub generate_correspondence_table {
    my($g2,$gdir) = @_;

    ($gdir =~ /(\d+\.\d+)$/) || die "Invalid Genome Directory: $gdir";
    my $g1 = $1;
    if ($g1 ne $g2)
    {
	my $exe = SeedAware::executable_for("svr_corresponding_genes");
	SeedAware::system_with_redirect([$exe, "-d", $gdir, $g1, $g2],
				    { stdout => "$gdir/CorrToReferenceGenomes/$g2" });
	#system "svr_corresponding_genes -d $gdir $g1 $g2 > $gdir/CorrToReferenceGenomes/$g2";
    }
}

sub prioritize_pegs_used_to_find_neighbors {
    my($gdir) = @_;

    my %by_func;

    my %uniqH;

    my $af_fh;
    if (!open($af_fh, "<", "$gdir/assigned_functions"))
    {
	warn "Cannot open $gdir/assigned_functions: $!";
	return ();
    }

    while (defined(my $line = <$af_fh>))
    {
	if ($line =~ /^(fig\|\d+\.\d+\.peg\.\d+)\t(\S[^\#]+\S)/)
	{
	    $uniqH{$1} = $2;
	}
    }
    close($af_fh);

    foreach my $peg (keys(%uniqH))
    {
	my $func = $uniqH{$peg};
	$func =~ s/\s*\#.*$//;
	push(@{$by_func{$func}},$peg);
    }

    my @synthetases        = map {[$_,$by_func{$_}->[0]] } grep { @{$by_func{$_}} == 1 } grep { $_ =~ /tRNA synthetase/ }   keys(%by_func);
    my @ribosomal_proteins = map {[$_,$by_func{$_}->[0]] } grep { @{$by_func{$_}} == 1 } grep { $_ =~ /ribosomal protein/ } keys(%by_func);
    my @ok_pegs            = map {[$_,$by_func{$_}->[0]] } grep { @{$by_func{$_}} == 1 }                                    keys(%by_func);
    my @prioritized = ();
    my %seen;
    foreach my $tuple (@synthetases,@ribosomal_proteins,@ok_pegs)
    {
	if (! $seen{$tuple->[0]})
	{
	    $seen{$tuple->[0]} = 1;
	    push(@prioritized,$tuple);
	}
    }
    return @prioritized;
}

sub compute_hits_and_set_best {
    my($tuple,$id2seqH,$counts,$bestP) = @_;

    my($role,$peg) = @$tuple;
    print "Get figfam pegs for $role\n";
    my $figfam_pegs = &figfam_pegs_for_role($role);

    print "Compute sims\n";
    my @sims        = &ProtSims::blastP([[$peg,'',$id2seqH->{$peg}]],$figfam_pegs,10);
    print "Computed " . scalar(@sims) . " sims\n";
    my $i;
    for ($i=0; (($i < @sims) && ($i < 50)); $i++)
    {
	my $g2 = &SeedUtils::genome_of($sims[$i]->id2);
	$counts->{$g2} += 50 - $i;
	if ($counts->{$g2} > $$bestP) { $$bestP = $counts->{$g2} }
    }
}

sub figfam_pegs_for_role {
    my($role) = @_;

    my %figfams;

    my $res = $sapO->all_figfams(-roles => $role);
    my @pegs;
    for my $ff (keys %$res)
    {
	my $fids = $sapO->figfam_fids(-id => $ff);
	push(@pegs, @$fids);
    }

    my $idsH = $sapO->ids_to_sequences(-ids => \@pegs, -protein => 1);

    return [map { my $seq = $idsH->{$_}; $seq ? [$_,'',$seq] : () } keys(%$idsH)];
}

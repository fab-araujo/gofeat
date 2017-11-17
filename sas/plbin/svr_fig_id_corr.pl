use SeedEnv;
use strict;
use Data::Dumper;

my $usage = "usage: svr_fig_id_corr [-external] [-precise]";
my $ext = 0;
my $precise = 0;
foreach $_ (@ARGV)
{
    if ($_ =~ /^-e/i)
    {
	print STDERR "keeping only entries that include external references\n";
	$ext = 1;
    }
    elsif ($_ =~ /^-p/)
    {
	print STDERR "keeping only precise equivalences (same genome)\n";
	$precise = 1;
    }
}
my $sapO = new SAPserver;
my $genomeH = $sapO->all_genomes(-complete => 1);
my %seen;
foreach my $genome (sort { $a <=> $b } keys(%$genomeH))
{
#   print STDERR "$genome\n";
    my $featureH = $sapO->all_features(-ids => [$genome], -type => 'peg');
    my $pegs     = $featureH->{$genome};
    my $setsH    = $sapO->equiv_sequence_ids(-ids => $pegs, -precise => $precise);
    foreach my $peg (@$pegs)
    {
	my $set = $setsH->{$peg};
	my @fig = sort { &SeedUtils::by_fig_id($a,$b) } grep { $_ =~ /^fig\|/ } @$set;
	my @non = sort grep { $_ !~ /^fig\|/ } @$set;
	if (! $seen{$fig[0]})
	{
	    if (@fig >= 2)
	    {
		$seen{$fig[0]} = 1;
	    }
	    if ((! $ext) || (@non > 0))
	    {
		print join(",",@fig), "\t", join(",",@non), "\n";
	    }
	}
    }
}

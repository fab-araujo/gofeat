#!/usr/bin/perl -w
use strict;
use SeedEnv;

use Getopt::Long;
use SAPserver;
use ScriptThing;

#
#	This is a SAS Component.
#

=head1 svr_co_occurrence_evidence

    svr_co_occurrence_evidence Obj1 Obj2

Displays instances in which homologs of the two specified PEGs co-occur or members of
two distinct FIGfams tend to co-occur.  Thus you can say

    svr_co_occurrence_evidence 'fig|83333.1.peg.2' 'fig|83333.1.peg.4'
or
    svr_co_occurrence_evidence FIG000885 FIG000134


The evidence is produced as a 2-column table of PEGs that occur close on the chromosome.

=cut

my $url = '';
my $opted =  GetOptions('url=s' => \$url);
if ((! $opted) || (! &ok_args($ARGV[0],$ARGV[1]))) {
    print "usage: svr_co_occurrence_evidence PEG-or-FIGfam1 PEG-or-FIGfam2 [-url=http://...]";
} else {
    if ($ARGV[0] =~ /^fig\|/)
    {
	&process_pegs($ARGV[0],$ARGV[1]);
    }
    else
    {
	&process_ffs($ARGV[0],$ARGV[1]);
    }
}

sub process_pegs {
    my($peg1,$peg2) = @_;

    my $sapServer = SAPserver->new(url => $url);
    my $pairsH = $sapServer->co_occurrence_evidence( -pairs => ["$peg1:$peg2"] );
    
    if (my $x = $pairsH->{"$peg1:$peg2"})
    {
	foreach $_ (@$x)
	{
	    print join("\t",@$_),"\n";
	}
    }
}

sub process_ffs {
    my($ff1,$ff2) = @_;

    my $sapServer = SAPserver->new(url => $url);
    my $pegs1 = $sapServer->figfam_fids(-id => $ff1 );
    my $pegs2 = $sapServer->figfam_fids(-id => $ff2 );
    my %genomes1 = map { $_ =~ /^fig\|(\d+\.\d+)/; $1 => 1 } @$pegs1;
    my %genomes2 = map { $_ =~ /^fig\|(\d+\.\d+)/; $1 => 1 } @$pegs2;
    my @pegs1 = grep { $genomes2{&SeedUtils::genome_of($_)} } @$pegs1;
    my @pegs2 = grep { $genomes1{&SeedUtils::genome_of($_)} } @$pegs2;
    my @pegs  = (@pegs1,@pegs2);
    my $locH = $sapServer->fid_locations( -ids => \@pegs, -boundaries => 1 );
    my %by_genome1;
    my %by_genome2;
    foreach my $peg1 (@pegs1)
    {
	my $g1 = &SeedUtils::genome_of($peg1);
	push(@{$by_genome1{$g1}},$peg1);
    }

    foreach my $peg2 (@pegs2)
    {
	my $g2 = &SeedUtils::genome_of($peg2);
	push(@{$by_genome2{$g2}},$peg2);
    }

    foreach my $g (sort { $a <=> $b } keys(%by_genome1))
    {
	my $x1 = $by_genome1{$g};
	my $x2 = $by_genome2{$g};
	my @pegs_with_locs1 = sort { ($a->[1] cmp $b->[1]) or ($a->[2] <=> $b->[2]) }
	                      map { my $peg = $_; my $loc = $locH->{$peg};
 	                     ($loc =~ /^\d+\.\d+:(\S+)_(\d+)([-+])(\d+)/) ? [$peg,$1,$2,$3,$4] : () } @$x1;
	my @pegs_with_locs2 = sort { ($a->[1] cmp $b->[1]) or ($a->[2] <=> $b->[2]) }
	                      map { my $peg = $_; my $loc = $locH->{$peg};
 	                     ($loc =~ /^\d+\.\d+:(\S+)_(\d+)([-+])(\d+)/) ? [$peg,$1,$2,$3,$4] : () } @$x2;
	my $i1 = 0; 
	my $i2 = 0;
	while (($i1 < @pegs_with_locs1) && ($i2 < @pegs_with_locs2))
	{
	    if (&gap_sz($pegs_with_locs1[$i1],$pegs_with_locs2[$i2]) < 5000)
	    {
		print join("\t",($pegs_with_locs1[$i1]->[0],$pegs_with_locs2[$i2]->[0])),"\n";
	    }
	    ($i1,$i2) = &incr($i1,\@pegs_with_locs1,$i2,\@pegs_with_locs2);
	}
    }
}

sub incr {
    my($i1,$xL1,$i2,$xL2) = @_;

    if (($xL1->[$i1]->[1] lt $xL2->[$i2]->[1]) ||
	(($xL1->[$i1]->[1] eq $xL2->[$i2]->[1]) && ($xL1->[$i1]->[2] < $xL2->[$i2]->[2])))
    {
	return ($i1+1,$i2);
    }
    elsif (($xL1->[$i1]->[1] gt $xL2->[$i2]->[1]) ||
	   (($xL1->[$i1]->[1] eq $xL2->[$i2]->[1]) && ($xL1->[$i1]->[2] > $xL2->[$i2]->[2])))
    {
	return ($i1,$i2+1);
    }
    else
    {
	return ($i1+1,$i2+1);
    }
}

sub gap_sz {
    my($x,$y) = @_;

    if ($x->[1] ne $y->[1]) { return 1000000 }
    my $min = ($x->[3] eq "+") ? ($x->[2] + $x->[4]) : $x->[2];
    my $max = ($y->[3] eq "+") ? $y->[2] : ($y->[2] - $y->[4]);
    return abs($max - $min);
}


sub ok_args {
    my($arg1,$arg2) = @_;

    return (($arg1 =~ /^FIG\d{6}$/) && ($arg2 =~ /^FIG\d{6}$/)) ||
	(($arg1 =~ /^fig\|\d+\.\d+\.peg\.\d+$/) && ($arg2 =~ /^fig\|\d+\.\d+\.peg\.\d+$/));
}

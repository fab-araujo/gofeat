# -*- perl -*-

use SeedEnv;
use strict;
use warnings;

my $usage = "usage: svr_update_assignments [-suggest_only] [-no_blast] SeedDir AssignmentsFile";

my $do_blast = 1;
my $in_place_update = 1;
while (@ARGV && ($ARGV[0] =~ m/^-/)) {
    if    ($ARGV[0] =~ m/-suggest_only/) {
	$in_place_update = 0;
    }
    elsif ($ARGV[0] =~ m/-no_blast/) {
	$do_blast = 0;
    }
    else {
	die "Unknown argument $ARGV[0]\n$usage";
    }
    shift @ARGV;
}

my($dir,$assignmentsF,$fh);
(
 ($dir          = shift @ARGV) && (-d $dir) && open($fh,"<$dir/Features/peg/fasta") &&
 ($assignmentsF = shift @ARGV)
)
    || die $usage;

my %assignments;
if (-s $assignmentsF)
{
    %assignments = map { $_ =~ /^(\S+)\t(\S.*\S)/ ? ($1 => $2) : () } `cat $assignmentsF`;
}

my $annoObject = ANNOserver->new();
my $kmer_func_results_handle  = $annoObject->assign_function_to_prot( -input => $fh, -assignToAll => $do_blast, -kmer => 8);


if ($in_place_update) {
    open(KMEROV,">$dir/Kmer.overrides")
	|| die "Could not write-open Kmer overrides file \'$dir/Kmer.overrides\'";
}

while (my $tuple = $kmer_func_results_handle->get_next)
{
    my($peg, $function, $otu, $score, $non_overlapping,$overlapping) = @$tuple;
    my $old = $assignments{$peg};
    if ((not $old) || (($old ne $function) && ($non_overlapping >= 3)))
    {
	$assignments{$peg} = $function;
	print KMEROV "$peg\t$function\n" if $in_place_update;
    }
}
close(KMEROV) if $in_place_update;

my $assgn_fh = \*STDOUT;
if ($in_place_update) {
    open($assgn_fh, ">$assignmentsF")
	|| die "Could not write-open assignments file \'$assignmentsF\'";
}

foreach my $peg (sort { &SeedUtils::by_fig_id($a, $b) } (keys %assignments)) {
    print $assgn_fh ($peg, "\t", $assignments{$peg}, "\n");
}
close($assgn_fh) if $in_place_update;


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#...Update Subsystems and Bindings...
#-----------------------------------------------------------------------
if ($in_place_update) {
    if (-d "$dir/Subsystems")
    {
	system "/bin/rm -rf $dir/Subsystems";
    }
    mkdir("$dir/Subsystems",0777) || die "could not make $dir/Subsystems";
    
    my @roles = map { [$assignments{$_},$_] } keys(%assignments);
    print STDERR &Dumper(\@roles);
    
    my $reconstruction = $annoObject->metabolic_reconstruction( -roles => \@roles);

    open(BINDINGS,">$dir/Subsystems/bindings") || die "could not open $dir/Subsystems/bindings";
    my %subsys;
    foreach my $tuple (@$reconstruction)
    {
	my($ss_and_var,$role,$peg) = @$tuple;
	if ($ss_and_var =~ /^(.*):([^:]+)$/)
	{
	    my $ss = $1;
	    my $var = $2;
	    $subsys{$ss} = $var;
	    print BINDINGS join("\t",($ss,$role,$peg)),"\n";
	}
    }
    close(BINDINGS);

    open(SS,">$dir/Subsystems/subsystems") || die "could not open $dir/Subsystems/subsystems";
    foreach $_ (sort keys(%subsys))
    {
	print SS join("\t",($_,$subsys{$_})),"\n";
    }
    close(SS);
}


						       

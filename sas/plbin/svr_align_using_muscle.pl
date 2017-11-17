# This is a SAS component
#
use gjoalignment;
use strict;

my $usage = "usage: svr_align_using_muscle [Seqs Alignment]";

my($seqs,$ali);
if (@ARGV > 1)
{
    my $seqs = &gjoalignment::read_fasta_file($ARGV[0]);
    my $ali  = &gjoalignment::align_with_muscle($seqs);
    &gjoalignment::write_fasta_file($ali,0,$ARGV[1]);
}
else
{
    my $seqs = &gjoalignment::read_fasta_file();
    my $ali  = &gjoalignment::align_with_muscle($seqs);
    &gjoalignment::write_fasta_file($ali);
}

#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;

my $file = $ARGV[0];

print "$ARGV[0]\n";

my $seqio = Bio::SeqIO->new(-file => $file, -format => "fasta");
while(my $seq = $seqio->next_seq) {
  # do stuff with sequences...
}
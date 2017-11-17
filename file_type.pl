#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;

my $file = $ARGV[0];

my $seqio = Bio::SeqIO->new(-file => $file, -format => "fasta");
while(my $seq = $seqio->next_seq) {
    if( $seq->alphabet eq 'protein') {
        print "protein";
        last;
    }
    if($seq->alphabet eq 'dna') {
        print "dna";
        last;
    }
  # do stuff with sequences...
}
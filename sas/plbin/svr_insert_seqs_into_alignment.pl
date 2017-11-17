#!/usr/bin/perl -w

#
# This is a SAS Component
#

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

use strict;
use Data::Dumper;
use Carp;
use Getopt::Long;

=head1 svr_insert_seqs_into_alignment 

    svr_insert_seqs_into_alignment [options] Seqs < old_ali.fa > new_ali.fa

This script takes a FASTA file of protein/DNA alignment from the
standard input and the name of a FASTA file of sequences to be
inserted from the command line and writes the resulting alignment to
the standard output. When not possible, a message will be written to
the standard error output.

Seqs is the name of the FASTA file that contains the sequences to be inserted.

=head2 Command-Line Options

=over 4

=item trim

Trim sequence start and end.

=item verbose

Print information messages to the standard error output.

=item stddev

Window of similarity to include in profile (D = 1.5).

=back

=head2 Output Format

The standard output is a FASTA file which contains the inserted sequences.

=cut


use gjoalignment;
use gjoseqlib;

my $usage = "Usage: $0 [--help] [--verbose] [--trim] [--stddev=1.5] Seqs < old_ali.fa > new_ali.fa\n\n";

my $help    = 0;
my $verbose = 0;
my $trim    = 0;
my $stddev  = 1.5;

my $opted   = GetOptions("help"     => \$help,
                         "verbose"  => \$verbose,
                         "trim"     => \$trim,
                         "stddev=f" => \$stddev);

my $seqF    = shift @ARGV;

$seqF && !$help or die $usage;

my $opts = { trim => $trim, silent => !$verbose, stddev => $stddev };

my $seqs = gjoseqlib::read_fasta($seqF);
my $ali  = gjoseqlib::read_fasta(\*STDIN);

$ali = gjoalignment::add_to_alignment_v2($_, $ali, $opts) for @$seqs;

gjoseqlib::print_alignment_as_fasta(\*STDOUT, $ali);


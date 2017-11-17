#!/usr/bin/perl -w 
use strict;
use SAPserver;
use Getopt::Long;

#   This is a SAS component.

=head1 svr_in_runs

    svr_in_runs <groups.tbl >operons.tbl

Make sequences of genes into operons.

This script takes as input groups of genes and finds all the operons containing
genes in each group. For the purposes of this script, an operon is a sequence of
genes that are close together on the same contig and pointing in the same direction.
The operons may contain other genes in the vicinity of the ones specified in the
original input.

The input must be a tab-delimited file. Each group should be the last field on
a line, and must be specified as a comma-separated list of FIG IDs. The operons
will also be rendered as a comma-separated list of FIG IDs. The output will consist
of the input lines with operons tacked onto the end. Since a group may
contain multiple operons, a single input line may produce multiple output lines.

This is a pipe command: the input is taken from the standard input and the output
is to the standard output.

=head2 Command-Line Options

=over 4

=item MaxGap

Maximum number of base pairs that can be between to genes in order for them to
be considered as part of the same operon. The default is 200.

=item JustFirst

If specified, then only the first gene in an operon will be included in the output.

=item url

The URL for the Sapling server, if it is to be different from the default.

=back

=cut

    my $MaxGap = 0;
    my $JustFirst = 0;
    
    $0 =~ m/([^\/]+)$/;
    my $self = $1;
    my $usage = "$self [--MaxGap=N --JustFirst --url=http://... ] <input >output";
    
    my $rc = GetOptions("MaxGap=i" => \$MaxGap, "JustFirst" => \$JustFirst);
    
    if (!$rc) {
        die "\n   usage: $usage\n\n";
    }
    
    my $ss = SAPserver->new();
    
    my %args;
    
    if ($JustFirst) {
        $args{-justFirst} = $JustFirst;
    }
    if ($MaxGap) {
        $args{-maxGap} = $MaxGap;
    }
    
    my $line;
    while (defined($line = <STDIN>)) {
        # Remove the new-line.
        chomp $line;
        # Get the fields in the line.
        my @fields = split /\t/, $line;
        # The last field is the group.
        $args{-groups} = [$fields[$#fields]];
        # Make the runs for this group.
        my $res =  $ss->make_runs(%args);
        # Output the result.
        foreach my $run (@{$res->{0}}) {
            print join("\t", $line, $run) . "\n";
        }
    }



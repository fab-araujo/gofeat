#! /usr/bin/perl
#
# This is a SAS component
#

use gjoseqlib;
use representative_sequences;
use strict;

my $usage = <<"End_of_Usage";

usage: svr_rep_seqs [ opts ] [ rep_seqs_0 ] < new_seqs > rep_seqs

       -b                - order input sequences by size (long to short)
       -c cluster_type   - behavior of clustering algorithm (0 or 1, D=1)
       -d seq_clust_dir  - directory for files of clustered sequencees
       -f id_clust_file  - file with one line per cluster, listing its ids 
       -l log_file       - real-time record of clustering, one line per seq
       -m measure_of_sim - measure of similarity to use:
                               identity_fraction  (default),
                               positive_fraction  (proteins only), or
                               score_per_position (0-2 bits)
       -s similarity     - similarity required to be clustered (D = 0.8)

    Sequences are clustered, with one representative sequence reported for
    each cluster.  rep_seqs_0 is an optional file of sequences to be assigned
    to unique clusters, regardless of their similarities.  Each new sequence
    is added to the cluster with the most similar representative sequence, or,
    if its similarity to any existing representative is less than 'similarity',
    it becomes the representative of a new cluster.  With the -d option,
    each cluster of sequences is written to a distinct file in the specified
    directory.  With the -f option, for each cluster, a tab-separated list
    of ids is written to the specified file.  With the -l option, the id of
    each sequence analyzed is written to the log file, followed by the id of
    the sequence that represents it (when appropriate).

    cluster_type 0 is the original method, which has only the representative
    for each group in the blast database.  This can randomly segregate
    distant members of groups, regardless of the placement of other very
    similar sequences.
    
    cluster_type 1 adds more diverse representatives of a group in the blast
    database.  This is slightly more expensive, but is much less likely to
    split close relatives into different groups.

End_of_Usage

my $by_size       = undef;
my $cluster_type  = 1;
my $seq_clust_dir = undef;
my $id_clust_file = undef;
my $log           = undef;
my $threshold     = 0.80;
my $measure       = 'identity_fraction';

while ( $ARGV[0] =~ /^-/ )
{
    $_ = shift @ARGV;
    if    ($_ =~ s/^-b//) { $by_size       = 1 }
    elsif ($_ =~ s/^-c//) { $cluster_type  = ($_ || shift @ARGV) }
    elsif ($_ =~ s/^-d//) { $seq_clust_dir = ($_ || shift @ARGV) }
    elsif ($_ =~ s/^-f//) { $id_clust_file = ($_ || shift @ARGV) }
    elsif ($_ =~ s/^-l//) { $log           = ($_ || shift @ARGV) }
    elsif ($_ =~ s/^-m//) { $measure       = ($_ || shift @ARGV) }
    elsif ($_ =~ s/^-s//) { $threshold     = ($_ || shift @ARGV) }
    else                  { print STDERR  "Bad flag: '$_'\n$usage"; exit 1 }
}

# Is there a starting set of representative sequences?

my $repF = undef;
my @reps = ();

if ( @ARGV )
{
    ( $repF = shift @ARGV )
        && ( -f $repF )
        && ( @reps = &gjoseqlib::read_fasta( $repF ) )
        && ( @reps )
            or print STDERR "Bad representative sequences starting file: $repF\n"
            and print STDERR $usage
            and exit 1;
}

if ( $log )
{
    open LOG, ">$log"
        or print STDERR "Unable to open log file '$log'\n$usage"
        and exit 1;
}

my @seqs = &gjoseqlib::read_fasta( \*STDIN );
@seqs or print STDERR "Failed to read sequences from stdin\n$usage"
      and exit 1;

my %options = ( max_sim  => $threshold,
                sim_meas => $measure
              );

$options{ by_size } = 1     if $by_size;
$options{ logfile } = \*LOG if $log;

my ( $rep, $reping );

if ( $cluster_type == 1 )
{
    ( $rep, $reping ) = &representative_sequences::rep_seq( ( @reps ? \@reps : () ),
                                                             \@seqs,
                                                             \%options
                                                          );
}
else
{
    ( $rep, $reping ) = &representative_sequences::rep_seq_2( ( @reps ? \@reps : () ),
                                                               \@seqs,
                                                               \%options
                                                            );
}

close( LOG ) if $log;

&gjoseqlib::print_alignment_as_fasta( $rep );

if ( $id_clust_file )
{
    open FILE, ">$id_clust_file"
        or print STDERR "Could not open id_clust_file '$id_clust_file'\n$usage"
        and exit 1;
    foreach ( map { $_->[0] } @$rep )
    {
        print FILE join( "\t", $_, @{ $reping->{$_} } ), "\n";
    }
    close FILE;
}

if ( $seq_clust_dir )
{
    mkdir $seq_clust_dir if ! -d $seq_clust_dir;
    -d $seq_clust_dir
        or print STDERR "Could not make seq_clust_dir '$seq_clust_dir'\n$usage"
        and exit 1;
    chdir $seq_clust_dir;

    my %index = map { $_->[0] => $_ } @reps, @seqs;

    my $file = 'group00000';
    foreach ( map { $_->[0] } @$rep )
    {
        my $cluster = [ map { $index{$_} } $_, @{ $reping->{$_} } ];
        &gjoseqlib::print_alignment_as_fasta( ++$file, $cluster );
    }
}


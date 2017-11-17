########################################################################
#! /usr/bin/perl -w
#
#  svr_tips_of_tree -- Extracts the tips from a file containing trees
#


use strict;
use Data::Dumper;
use gjonewicklib;



=head1 svr_tips_of_tree

=head2 Introduction

    svr_tips_of_tree < tree(s) > tips

Reads a file of one or more trees in Newick format and returns the tips.

=head2 Command-Line Options

=over 4

=item -c=Table

A correspondence table in which the first two columns contain pairs of IDs,
one of which must be a FIG ID.

=back

=head3 Output Format

The generated HTML document is written to STDOUT.

=cut

use Getopt::Long; 
my $corr;

my $rc = GetOptions("-c=s",\$corr);

my %corrH;
if ($corr)
{
    if (-s $corr)
    {
	open(CORR,"<$corr") || die "could not open $corr";
	while ($_ = <CORR>)
	{
	    if ($_ =~ /^(\S+)\s+(\S+)/)
	    {
		my $id1 = $1;
		my $id2 = $2;
		if ($id1 =~ /^fig\|\d+\.\d+\.peg\.\d+/)
		{
		    $corrH{$id2} = $id1;
		}
		elsif ($id2 =~ /^fig\|\d+\.\d+\.peg\.\d+/)
		{
		    $corrH{$id1} = $id2;
		}
	    }
	    else
	    {
		print STDERR "Ignoring: $_";
	    }
	}
	close(CORR);
    }
    else
    {
	die "invalid correspondence table";
    }
}
my @trees = &gjonewicklib::read_newick_trees;

my %tips = map{ $_ => 1 } map { &gjonewicklib::newick_tip_list($_) } @trees;

foreach $_ (sort { lc $a cmp lc $b } keys(%tips))
{
    my $tip = $corrH{$_} ? $corrH{$_} : $_;
    print "$tip\n";
}
    

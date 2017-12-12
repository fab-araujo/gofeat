use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#


=head1 svr_mapped_genomes

Get maps between a reference genome and a set of genomes to which
you wish to compare the reference genome.

------

Example:

    svr_mapped_genomes -g 83333.1 -d Maps < genomes.to.compare.against

would construct a directory of mappings between genes 83333.1 and the genomes
read from standard input.  The maps would come back as files in the directory
"Maps" (which would get created if necessary).

------

The standard input should be a tab-separated table (i.e., each line 
is a tab-separated set of fields).  Normally, the last field in each
line would contain the genome for which functions are being requested.
If some other column contains the genomes, use

    -c N

where N is the column (from 1) that contains the genome in each case.

=head2 Command-Line Options

=over 4

=item -c Column

This is used only if the column containing PEGs is not the last.

=item -g genome

This designates the reference genome

=item -d directory

This designates the directory into which maps are written.  It will be created
if it does not already exist

=back

=head2 Output Format

The output is written as "maps" in the designated directory.  Each map
is a file of 18 fields, tab-separated:

1      The ID of a PEG in genome 1.
2      The ID of a PEG in genome 2 that is our best estimate of a "corresponding gene".
3      Count of the number of pairs of matching genes were found in the context.
4      Pairs of corresponding genes from the contexts.
5      The function of the gene in genome 1.
6      The function of the gene in genome 2.
7      Comma-separated list of aliases for the gene in genome 1 (any protein with an identical sequence is considered an alias, whether or not it is actually the name of the same gene in the same genome).
8      Comma-separated list of aliases for the gene in genome 2 (any protein with an identical sequence is considered an alias, whether or not it is actually the name of the same gene in the same genome).
9      Bi-directional best hits will contain "<=>" in this column; otherwise, "->" will appear.
10     Percent identity over the region of the detected match.
11     The P-score for the detected match.
12     Beginning match coordinate in the protein encoded by the gene in genome 1.
13     Ending match coordinate in the protein encoded by the gene in genome 1.
14     Length of the protein encoded by the gene in genome 1.
15     Beginning match coordinate in the protein encoded by the gene in genome 2.
16     Ending match coordinate in the protein encoded by the gene in genome 2.
17     Length of the protein encoded by the gene in genome 2.
18     Bit score for the match. Divide by the length of the longer PEG to get what we often refer to as a "normalized bit score".

=cut

use SeedUtils;
use SAPserver;
my $sapObject = SAPserver->new();

my $usage = "usage: svr_mapped_genomes -g genome -d directory [-c column]";

my($column,$genome,$directory);
while ($ARGV[0] && ($ARGV[0] =~ /^-/))
{
    $_ = shift @ARGV;
    if    ($_ =~ s/^-c//) { $column       = ($_ || shift @ARGV) }
    elsif ($_ =~ s/^-g//) { $genome       = ($_ || shift @ARGV) }
    elsif ($_ =~ s/^-d//) { $directory    = ($_ || shift @ARGV) }
    else                  { die "Bad Flag: $_" }
}

$genome || die "You need to specify a reference genome";
&SeedUtils::verify_dir($directory);

my @lines = map   { chomp; [split(/\t/,$_)] } <STDIN>;
if (! $column)    { $column = @{$lines[0]} }
my @against = map { $_->[$column-1] } @lines;
foreach my $other (@against)
{
    next if (($other eq $genome) || (-s "$directory/$genome-$other"));
    my $map = $sapObject->gene_correspondence_map( -genome1 => $genome,
						   -genome2 => $other,
						   -fullOutput => 1,
						   -passive => 0 );
    if ($map)
    {
	open(MAP,">","$directory/$genome-$other") || die "could not open $directory/$genome-$other";
	foreach $_ (@$map)
	{
	    print MAP join("\t",@$_),"\n";
	}
	close(MAP);
    }
}

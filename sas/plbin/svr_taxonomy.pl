use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#


=head1 svr_taxonomy

Get taxonomy of genomes

------
Example: svr_taxonomy < file of genome ids > file of genome ids taxonomy

would produce a 2-column table.  The first column would contain
the input genome id, and the second
would contain the taxonomy of that genome

------

The standard input should be a tab-separated table (i.e., each line 
is a tab-separated set of fields).  Normally, the last field in each
line would contain the GENOME for which the taxonomy is being requested.
If some other column contains the Genome id's, use

    -c N

where N is the column (from 1) that contains the ID in each case.

This is a pipe command. The input is taken from the standard input, and the output is to the standard output.

=head2 Command-Line Options

=over 4

=item -c Column

This is used only if the column containing IDs is not the last.

=back

=head2 Output Format

The standard output is a tab-delimited file. It consists of the input
file with an extra column added (the taxonomy  associated with the GENOME).

=cut

use SeedUtils;
use SAPserver;
my $sapObject = SAPserver->new();

my $usage = "usage: svr_taxonomy [-c column]";

my $column;
while ($ARGV[0] && ($ARGV[0] =~ /^-/))
{
    $_ = shift @ARGV;
    if    ($_ =~ s/^-c//) { $column       = ($_ || shift @ARGV) }
    else                  { die "Bad Flag: $_" }
}

my @lines = map { chomp; [split(/\t/,$_)] } <STDIN>;
if (! $column)  { $column = @{$lines[0]} }
my @gids = map { $_->[$column-1] } @lines;

my $taxonomies = $sapObject->taxonomy_of(-ids => \@gids);
foreach $_ (@lines)
{
    print join("\t",@$_,join("; ", @{$taxonomies->{$_->[$column-1]}})),"\n";
}

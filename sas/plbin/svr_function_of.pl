use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#


=head1 svr_function_of

Get functions of protein-encoding genes

------

Example:

    svr_all_features 3702.1 peg | svr_function_of

would produce a 2-column table.  The first column would contain
PEG IDs for genes occurring in genome 3702.1, and the second
would contain the functions of those genes.

------

The standard input should be a tab-separated table (i.e., each line 
is a tab-separated set of fields).  Normally, the last field in each
line would contain the PEG for which functions are being requested.
If some other column contains the PEGs, use

    -c N

where N is the column (from 1) that contains the PEG in each case.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Command-Line Options

=over 4

=item -c Column

This is used only if the column containing PEGs is not the last.

=back

=head2 Output Format

The standard output is a tab-delimited file. It consists of the input
file with an extra column added (the function associated with the PEG).

=cut

use SeedUtils;
use SAPserver;
my $sapObject = SAPserver->new();

my $usage = "usage: svr_function_of [-c column]";

my $column;
while ($ARGV[0] && ($ARGV[0] =~ /^-/))
{
    $_ = shift @ARGV;
    if    ($_ =~ s/^-c//) { $column       = ($_ || shift @ARGV) }
    else                  { die "Bad Flag: $_" }
}

my @lines = map { chomp; [split(/\t/,$_)] } <STDIN>;
if (! $column)  { $column = @{$lines[0]} }
my @fids = map { $_->[$column-1] } @lines;

my $functions = $sapObject->ids_to_functions(-ids => \@fids);
foreach $_ (@lines)
{
    print join("\t",@$_,$functions->{$_->[$column-1]}),"\n";
}

use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#


=head1 svr_by_taxonomy

Separate a list by taxonomy

------

Example: svr_by_taxonomy taxonomy < file of genome taxonomies > has taxonomy 2> does not

would split the incoming file into those containing the given taxonomy and those without

------

The standard input should be a tab-separated table (i.e., each line 
is a tab-separated set of fields).  Normally, the last field in each
line would contain the thing being tested 
If some other column contains the taxonomy, use

    -c N

where N is the column (from 1) that contains the taxonomy in each case.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Command-Line Options

=over 4

=item -c Column

This is used only if the column containing ID's is not the last.

=back

=head2 Output Format

The standard output is an echo of the lines in the incoming file that have the given taxonomy.
Lines are written here only if there is an exact, case-insensitive match to one of the tax components
The standard error file is an echo of the lines in the incoming file that do not have the given taxonomy 

=cut

use SeedUtils;
use SAPserver;
my $sapObject = SAPserver->new();

my $usage = "usage: svr_by_taxonomy [-c column]";

my $column;
while ($ARGV[0] && ($ARGV[0] =~ /^-/))
{
    $_ = shift @ARGV;
    if    ($_ =~ s/^-c//) { $column       = ($_ || shift @ARGV) }
    else                  { die "Bad Flag: $_" }
}

my $tax = shift @ARGV;
if (!$tax) { die "No taxonomy specified\n"}


my @lines = map { chomp; [split(/\t/,$_)] } <STDIN>;
if (! $column)  { $column = @{$lines[0]} }

foreach $_ (@lines)
{
    my @tax = split("; ", $_->[$column-1]);
    if (grep(/^$tax$/i, @tax)) {
    #if ($_->[$column-1] =~ /$tax/) {
	 print join("\t",@$_), "\n";
    } else {
	 print STDERR join("\t",@$_), "\n";
    }
}

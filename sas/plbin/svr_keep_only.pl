use strict;
use SAPserver;
use ScriptThing;

use Data::Dumper;

=head1 svr_keep_only

=head2 Introduction

    svr_keep_only -f='Threonine synthase (EC 4.2.3.1)'  < ids > ids.that.pass 2> ids.that.fail

Reads a stream of PEGs, filtering out those that do not have a desired function or functional role.
Those that are filtered out are written to STDERR.  Those that pass go to STDOUT.

=head2 Command-Line Options

=over 4

=item -f='functions to keep'

Specifies the function that must be on PEGs that are kept

=item -r='functional role to keep'

Specifies a functional role.  All IDs with this role will be kept.

=item -s

Asks for comments to be stripped from the function before checking for a match

=item -d

specifies that the designated criteria is for deletion, not retention

=back

=head2 Command-Line Options

=over 4

=item -url

The URL for the Sapling server, if it is to be different from the default.

=item -c

Column index. If specified, indicates that the input IDs should be taken from the
indicated column instead of the last column. The first column is column 1.

=back

=head3 Output Format

Input lines will be copied to the output (STDOUT) when they pass the criteria for matching.

=cut

my($function,$role);
my $strip = 0;
my $column=0;
my $delete = 0;
my $url = "";

use Getopt::Long;
my $rc =  GetOptions( 'url=s' => \$url, 
		      'c=i'   => \$column,
		      'f=s'   => \$function,
		      'r=s'   => \$role,
		      'd'     => \$delete,
		      's'     => \$strip);

# Get the server object.
my $sapO = SAPserver->new(url => $url);

while (my @tuples = ScriptThing::GetBatch(\*STDIN, undef, $column)) 
{
    my @pegs = map { $_->[0] } @tuples;
    my $funcH = $sapO->ids_to_functions( -ids => \@pegs );
    foreach my $request (@tuples)
    {
	my($peg,$line) = @$request;
	my $func       = $funcH->{$peg};
	if (! $func) { $func = "" }
	if ($strip)  { $func =~ s/\s*\#.*$// }
	my $matches = 0;
	if ($function)
	{
	    $matches = ($function eq $func);
	}
	elsif ($role && $func)
	{
	    foreach my $x (&SeedUtils::roles_of_function($role))
	    {
		if ($x eq $role)
		{
		    $matches = 1;
		}
	    }
	}
	if (($delete && (! $matches)) ||
	    ((! $delete) && $matches))
	{
	    print $line,"\n";
	}
	else
	{
	    print STDERR $line,"\n";
	}
    }
}


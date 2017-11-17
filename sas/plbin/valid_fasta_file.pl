#
# Determine if the given file is a valid fasta file and attempt to
# determine if it contains protein or DNA data.
#
# This is a SAS Component
#

@ARGV == 1 or @ARGV == 2 or die "usage: valid_fasta_file filename [normalized]\n";
$file = shift;
$norm = shift;

open(F, "<", $file) or die "cannot open $file: $!";

my $clean_fh;
if ($norm)
{
    open($clean_fh, ">", $norm) or die "cannot write normalized file $norm: $!";
}

my $state = 'expect_header';
my $cur_id;
my $dna_chars;
my $prot_chars;

{
    while (<F>)
    {
	chomp;
	
	if ($state eq 'expect_header')
	{
	    if (/^>(\S+)/)
	    {
		$cur_id = $1;
		$state = 'expect_data';
		print $clean_fh ">$cur_id\n" if $clean_fh;
		next;
	    }
	    else
	    {
		die "Invalid fasta: Expected header at line $.\n";
	    }
	}
	elsif ($state eq 'expect_data')
	{
	    if (/^>(\S+)/)
	    {
		$cur_id = $1;
		$state = 'expect_data';
		print $clean_fh ">$cur_id\n" if $clean_fh;
		next;
	    }
	    elsif (/^([acgtumrwsykbdhvn]*)\s*$/i)
	    {
		print $clean_fh uc($1) . "\n" if $clean_fh;
		$dna_chars += length($1);
		next;
	    }
	    elsif (/^([*abcdefghijklmnopqrstuvwxyz]*)\s*$/i)
	    {
		print $clean_fh uc($1) . "\n" if $clean_fh;
		$prot_chars += length($1);
		next;
	    }
	    else
	    {
		my $str = $_;
		if (length($_) > 100)
		{
		    $str = substr($_, 0, 50) . " [...] " . substr($_, -50);
		}
		die "Invalid fasta: Bad data at line $.\n$str\n";
	    }
	}
	else
	{
	    die "Internal error: invalid state $state\n";
	}
    }
}

my $what = ($prot_chars > 0) ? "protein" : "dna";
print "$what\n";


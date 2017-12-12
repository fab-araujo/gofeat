use strict;
use Data::Dumper;
use Carp;

use SeedUtils;
use SAPserver;
my $sapObject = SAPserver->new();

#
# This is a SAS Component
#

my $usage = "usage: svr_translations_of [-c column] [-fasta]";

my $column;
my $fasta = 0;

while ($ARGV[0] && ($ARGV[0] =~ /^-/))
{
    $_ = shift @ARGV;
    if    ($_ =~ s/^-c//)   { $column       = ($_ || shift @ARGV) }
    elsif ($_ =~ /-fasta/)  { $fasta = 1 }
    else                  { die "Bad Flag: $_" }
}

my @lines = map { chomp; [split(/\t/,$_)] } <STDIN>;
if (@lines) {
    if (! $column)  { $column = @{$lines[0]} }
    my @fids = map { $_->[$column-1] } @lines;
    
    if (! $fasta) {
	my $seqsH = $sapObject->ids_to_sequences(-ids => \@fids,
						 -protein => 1);
	foreach $_ (@lines)
	{
	    print join("\t",(@$_,$seqsH->{$_->[$column-1]})),"\n";
	}
    } else {
	my $seqsH = $sapObject->ids_to_sequences(-ids => \@fids,
						 -fasta => 1,
						 -protein => 1);
	foreach $_ (@lines)
	{
	    print $seqsH->{$_->[$column-1]};
	}
    }
}
#!/usr/bin/perl

#
# This is a SAS Component
#

my $usage = "usage: svr_tab2html [LINK-TEMPLATE] < tab-separated > html
The LINK-TEMPATE is a URL in which the 3-character string PEG is mapped
to the FIG-ID for any column containing a PEG";

my $url = (@ARGV > 0) ? $ARGV[0] : "";

print "<table>\n";
while (defined($_ = <STDIN>))
{
    chop;
    my @flds = split(/\t/,$_);
    print "<tr>\n";
    foreach $fld (@flds)
    {
	if (($fld =~ /(fig\|\d+\.\d+\.peg\.\d+)/) && $url)
	{
	    my $peg = $1;
	    my $tmp = $url;
	    $tmp =~ s/PEG/$peg/g;
	    $fld = "<a href=$tmp>$fld</a>";
	}
	print "  <td>$fld</td>\n";
    }
    print "</tr>\n";
}
print "</table>\n";

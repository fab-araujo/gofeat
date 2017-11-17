use strict;
use Data::Dumper;
use Carp;
use CGI;

#
# This is a SAS Component
#


use SeedEnv;
my $sapObject = SAPserver->new();

=head1 svr_evidence

Get evidence codes for protein-encoding genes

------
Example: svr_all_features 3702.1 peg | svr_evidence

would produce a 2-column table.  The first column would contain
PEG IDs for genes occurring in genome 3702.1, and the second
would contain the evidence codes  (comma-separated) for those genes.

------

The standard input should be a tab-separated table (i.e., each line 
is a tab-separated set of fields).  Normally, the last field in each
line would contain the PEG for which aliases are being requested.
If some other column contains the PEGs, use

    -c N

where N is the column (from 1) that contains the PEG in each case.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Command-Line Options

=over 4

=item -c Column

This is used only if the column containing PEGs is not the last.

=item -v

The verbose option will cause an english language version of the evidence to be returned in a column after the comma-separated list of evidence codes.  

=item -escape

TRUE if the output text should be escaped for HTML, else FALSE


=back

=head2 Output Format

The standard output is a tab-delimited file. It consists of the input
file with an extra column added (a comma-separated list of aliases), and, if the -v option is used, an extra column consisting of the english language version of the evidence.

=cut


my $usage = "usage: svr_evidence [-c column -v -escape ]";

my $column;
my $verbose;
my $escape;
while ($ARGV[0] && ($ARGV[0] =~ /^-/))
{
    $_ = shift @ARGV;
    if    ($_ =~ s/^-c//) { $column       = ($_ || shift @ARGV) }
    elsif ($_ =~ /^-v/) {$verbose = 1}
    elsif ($_ =~ /^-escape/) {$escape = 1}
    else                  { die "Bad Flag: $_" }
}

ScriptThing::AdjustStdin();
my @lines = map { chomp; [split(/\t/,$_)] } <STDIN>;
if (! $column)  { $column = @{$lines[0]} }
my @fids = map { $_->[$column-1] } @lines;

my $evidenceH = $sapObject->ids_to_data({-ids => \@fids, -data => ["evidence"]});

my $funcH;
my $subH;
my $nameH;

if ($verbose) {
	$funcH = $sapObject->ids_to_functions({-ids => \@fids});
	$subH = $sapObject->ids_to_subsystems({-ids => \@fids, -subsOnly => 1});
        $nameH = $sapObject->all_genomes({});
}

foreach $_ (@lines)
{

    my $se;
    if ($verbose) {
	    $se = to_structured_english($evidenceH->{$_->[$column-1]}[0][0], $_->[$column-1], $funcH->{$_->[$column-1]}, $subH->{$_->[$column-1]}, $escape);
	    print join("\t",@$_,join(",", $evidenceH->{$_->[$column-1]}[0][0]), $se);
    } else {
	    print join("\t",@$_,join(",", $evidenceH->{$_->[$column-1]}[0][0])),"\n";
   }
}



sub to_structured_english {
    my($ev, $peg, $funcSeed, $insubs, $escaped, %options ) = @_;

    my @ev_codes = split(",", $ev);
# evcodes is comma separated list of codes
# peg is the peg id
# funcSeed is the peg function
# insubs is a list of subsystems the peg is in

#1) With dlits:    "The characterization of essentially identical proteins has been discussed in 
#pubmed1 [, pubmed2,... and pubmedn]"  Where the pubmed IDs are links

#2) With ilits:     "The characterization of proteins implementing this function was done in 
#GenusSpecies1 [, GenusSpecies2, ... and GenusSpecies3].  We believe that this protein is an 
#isofunctional homolog of these characterized proteins."

# GenusSpeciesn should not be the whole string returned by $fig->genus_species($genome) -- use only the first two words.

    if (!@ev_codes) {return ("", "", "");}
    my $by_sub = {};
    my $ilit = {};
    my $dlit = {};
    
    # for testing
    #push (@ev_codes, "dlit(8332479);gj");
    #push (@ev_codes, "dlit(1646786);gj");
    #push (@ev_codes, "ilit(1646786);fig|351605.3.peg.2740");
    #push (@ev_codes, "ilit(8332479);fig|351605.3.peg.2740");
    #push (@ev_codes, "ilit(1646787);fig|224308.1.peg.2273");
    #push (@ev_codes, "ilit(1646787);fig|192222.1.peg.543");

    foreach my $code (@ev_codes)
    {
	if ($code =~ /^isu;(\S.*\S)/)                { $by_sub->{$1}->{'isu'} = 1  }
	if ($code =~ /^icw\((\d+)\);(\S.*\S)/)       { $by_sub->{$2}->{'icw'} = $1 }
	if ($code =~ /^ilit\((\d+)\);(\S.*\S)/)       {
		my $gs = &get_gs($2);
		unless (exists $ilit->{$gs}) { $ilit->{$gs} = [];}
		push(@{$ilit->{$gs}}, $1);
	} 
	if ($code =~ /^dlit\((\d+)\);(\S.*\S)/)        { $dlit->{$1} = 1 }
    }

    $peg =~ /^fig\|(\d+\.\d+)\.peg\.\d+$/;
    my $genome = $1;

    my %subs = map { $_ => 1 } @{$insubs};

    my $pieces = [];
    &add_func_assertion($pieces,$funcSeed);
    &add_in_subs($pieces,$insubs);
    my @sub_numbers;

    foreach my $sub (@{$insubs})
    {
    #print STDERR "Sub = $sub\n";
	&add_clustering_and_dup($pieces,$by_sub->{$sub},$sub);
#	if (!$options{-skip_registered_ids})
	#{
	    #push(@sub_numbers, "SS:".$fig->clearinghouse_register_subsystem_id($sub));
	#}
    }

     my @keys =  keys(%$dlit);
     if (@keys) {
    	make_dlit_text($pieces, @keys);
    }
    if (keys(%$ilit)) {
	    make_ilit_text($pieces, $ilit); 
    }

    #return join(",", @ev_codes), join(",", @sub_numbers), &render($pieces, $escaped);
    return &render($pieces, $escaped);
}

sub get_gs {
	my ($peg) = @_;

	$peg =~ /^fig\|(\d+\.\d+)\.peg\.\d+$/;
	my $gs = $nameH->{$1};
	#$fig->genus_species($1);
	#my $gs = $fig->genus_species($1);
	my @words = split /\s+/, $gs;
	if (@words)  {
		$gs = $words[0];
		if (@words > 1)  {
			$gs .= " $words[1]";
		}
	}
	return($gs);
}

sub render {
    my $cgi = new CGI;
    my($pieces, $escaped) = @_;

    my @lines = ();
    my $curr  = "";
    foreach my $piece (@$pieces)
    {
	$piece = "$piece  ";
	$curr = $curr . $piece;

#	while (length($curr) > 100)
	#{
	    #my($p1,$p2) = &split_piece($curr,100);
	    #$p1 =~ s/^\s+//;
	    #push(@lines, $p1);
	    #$curr = $p2;
	#}
    }
    if ($curr) 
    { 
	$curr =~ s/^\s+//; 
	push(@lines,$curr) ;
    }

    if ($escaped) {
    	return  $cgi->escape(join("\n",@lines) . "\n");
    } else {
    	return (join("\n",@lines) . "\n");

    }
}

sub split_piece {
    my($piece,$n) = @_;

    my $i;
    for ($i = $n; ($i > 0) && (substr($piece,$i,1) ne " "); $i--) {}
    if ($i)
    {
	return (substr($piece,0,$i+1),substr($piece,$i+1));
    }
    else
    {
	return ($piece,"");
    }
}

sub make_dlit_text {
	my ($pieces, @dlit) = @_;

	#my $text = "The characterization of essentially identical proteins has been discussed in ".&make_pubmed_link($dlit[0]);
	my $text = "The function of this gene is asserted in ".&make_pubmed_link($dlit[0]);
	shift(@dlit);
	if (@dlit) {
		my $size = @dlit;
		
		while (--$size) {
			my $p = shift(@dlit);
			$text = $text.", ".&make_pubmed_link($p);
		}
		if (@dlit) {
			$text = $text." and ".&make_pubmed_link($dlit[0]);
		}
	}	
	$text .= ".";
	push (@$pieces, $text);
}


sub make_ilit_text {
	my ($pieces, $ilit) = @_;

       my  @keys =  keys(%$ilit);
	my $filler = "";
	#my $text = "The characterization of proteins implementing this function was done in ";
	#my $text = "The function of genes we believe play the same functional roles have been described in ";
	my $text = "The function of genes having the same functional roles have been described in ";
	my $key = shift(@keys);
	$text .= $key.&make_pubmed_list($ilit->{$key});

	if (@keys) {
		$filler.="These are homologous proteins which implement"; 
		my $size =  @keys;
		while(--$size) {
			$key = shift(@keys);
			$text .= ", ".$key.&make_pubmed_list($ilit->{$key});
		}
		if (@keys) {
			$key = shift(@keys);
			$text = $text." and ".$key.&make_pubmed_list($ilit->{$key});
		}	
	} else {	
		$filler.="This is a homologous protein which implements"; 
	}


	#$text = $text.".  We believe that $filler the same function.";
	$text = $text.".  $filler the same function.";
	push (@$pieces, $text);

}

sub make_pubmed_list {

	my ($plst) = @_;

	my $text = " (";
	foreach my $pub (@$plst) {
#		print STDERR $pub, "\n";
		$text .= make_pubmed_link($pub).", ";
	}
	$text =~s/, $/)/;
	return($text);
}


sub make_pubmed_link {
	my ($pubmed) = @_;
	return "<a href='http://www.ncbi.nlm.nih.gov/sites/entrez?cmd=Retrieve&db=PubMed&list_uids=$pubmed&dopt=AbstractPlus' target='_blank'>$pubmed</a>";
}

sub add_clustering_and_dup {
    my($pieces,$by_sub_entry,$sub) = @_;

    if ($by_sub_entry)
    {
	if ($by_sub_entry->{isu} || $by_sub_entry->{icw})
	{
	    my $fixed_sub = &fix_sub_name($sub);
	    push(@$pieces,"In $fixed_sub, " . &isu_and_icw($by_sub_entry->{isu},$by_sub_entry->{icw}));
	}
    }
}

sub isu_and_icw {
    my($isu,$icw) = @_;

    if ($isu && $icw) { return "it appears to play a functional role that we have not associated with any other gene, and it occurs in close proximity on the chromosome with " . (($icw == 1) ? "another gene from the same subsystem." : "$icw other genes from the same subsystem.") }
    if ($isu)         { return "it appears to play a functional role that we have not associated with any other gene." }
    if ($icw)         { "it occurs in close proximity on the chromosome with " . (($icw == 1) ? "another gene from the same subsystem." : "$icw other genes from the same subsystem.") }
}

sub add_func_assertion {
    my($pieces,$funcSeed) = @_;

    my $func_text = &encoded_annotation_to_natural_english($funcSeed);
    push(@$pieces,$func_text);

    return;
}

# this function parses the encoded annotation into a natural english version
sub encoded_annotation_to_natural_english {
  my ($annotation, $return_table_version) = @_;

  # check if we have an annotation to parse
  unless (defined($annotation)) {
    return "";
  }

  my $natural_english = "";
  my $table_version = "";

  my @funcs = ();
  my $introduction = "";
  if ($annotation =~ /(.+?) \/ (.+)/) {
    $introduction = "This feature plays multiple roles which are implemented by distinct domains within the feature. The roles are:";
    $natural_english = "The encoded protein plays multiple roles which are implemented by distinct domains within the feature. The roles are ";
    push(@funcs, $1);
    my $shortened_list = $2;
    while ($shortened_list =~ /(.+?) \/ (.+)/) {
      push(@funcs, $1);
      $shortened_list = $2;
    }
    push(@funcs, $shortened_list);
    for (my $i=0; $i<scalar(@funcs); $i++) {
      if ($i == scalar(@funcs)-1) {
	$natural_english .= " and \"" . $funcs[$i] . "\".";
      } elsif ($i == 0) {
	$natural_english .= "\"" . $funcs[$i] . "\"";
      } else {
	$natural_english .= ", \"" . $funcs[$i] . "\"";
      }
    }
    
  } elsif ($annotation =~ /(.+?) \@ (.+)/) {
    $introduction = "This feature plays multiple roles which are implemented by the same domain with a broad specificity. The roles are:";
    $natural_english = "The encoded protein plays multiple roles which are implemented by the same domain with a broad specificity. The roles are ";
    push(@funcs, $1);
    my $shortened_list = $2;
    while ($shortened_list =~ /(.+?) \@ (.+)/) {
      push(@funcs, $1);
      $shortened_list = $2;
    }
    push(@funcs, $shortened_list);
    for (my $i=0; $i<scalar(@funcs); $i++) {
      if ($i == scalar(@funcs)-1) {
	$natural_english .= " and \"" . $funcs[$i] . "\".";
      } elsif ($i == 0) {
	$natural_english .= "\"" . $funcs[$i] . "\"";
      } else {
	$natural_english .= ", \"" . $funcs[$i] . "\"";
      }
    }
    
  } elsif ($annotation =~ /(.+?); (.+)/) {
    $introduction = "We are uncertain of the precise function of this feature. It is probably one of the following:";
    $natural_english = "We are uncertain of the precise function of the encoded protein. It is probably ";
    push(@funcs, $1);
    my $shortened_list = $2;
    while ($shortened_list =~ /(.+?); (.+)/) {
      push(@funcs, $1);
      $shortened_list = $2;
    }
    push(@funcs, $shortened_list);
    for (my $i=0; $i<scalar(@funcs); $i++) {
      if ($i == scalar(@funcs)-1) {
	$natural_english .= " or \"" . $funcs[$i] . "\".";
      } elsif ($i == 0) {
	$natural_english .= "\"" . $funcs[$i] . "\"";
      } else {
	$natural_english .= ", \"" . $funcs[$i] . "\"";
      }
    }
    
  } else {
    push(@funcs, $annotation);
  }
  
  if (scalar(@funcs)>1) {
    $table_version .= "<td colspan=3><span id='func_english'><table><tr><td>" . $introduction . "</td></tr>";
    
    foreach my $func (@funcs) {
      my $ec_cell = "";
      $table_version .= '<tr>';
      $table_version .= "<td width=400>" . $func . "</td>";
      while ($func =~ /[\[\(]{1}EC (\d+\.\d+\.[\d\-]+\.[\d\-]+)[\)\]]{1}/gi) {
	$ec_cell .= " <a href='http://www.genome.jp/dbget-bin/www_bget?ec:$1' target=outbound>$1</a>,";
      }
      if ($ec_cell) {
	chop $ec_cell;
	$table_version .= "<th>EC Number</th><td>$ec_cell</td>";
      }
      $table_version .= "</tr>";      
    }

    $table_version .= "</table></span><span id='func_code' style='display: none'>$annotation<br><br></span><input type='button' value='show encoded function' onclick=\"if(document.getElementById('func_english').style.display=='none') { document.getElementById('func_english').style.display='inline'; document.getElementById('func_code').style.display='none'; this.value='show encoded function'; } else { document.getElementById('func_english').style.display='none'; document.getElementById('func_code').style.display='inline'; this.value='show natural english'; }\"></td></tr>";

  } else {
    $table_version .= "<td width=400>" . $annotation . "</td>";
    my $ec_cell = "";
    while ($annotation =~ /[\[\(]{1}EC (\d+\.\d+\.[\d\-]+\.[\d\-]+)[\)\]]{1}/gi) {
      $ec_cell .= " <a href='http://www.genome.jp/dbget-bin/www_bget?ec:$1' target=outbound>$1</a>,";
    }
    if ($ec_cell) {
      chop $ec_cell;
      $table_version .= "<th>EC Number</th><td>$ec_cell</td>";
    }
    $table_version .= "</tr>";
    $natural_english .= "We have assigned the function \"$annotation\" to the encoded protein."
  }

  if ($return_table_version) {
    return $table_version;
  }

  return $natural_english;
}

sub add_in_subs {
    my($pieces,$insubs) = @_;

    if (@$insubs > 0)
    {
	my $n = @$insubs;
	#print STDERR "n = $n, insubs = $insubs\n";
	if ($n > 0)
	{
	    my $in_sub_state = "The protein occurs in " .
		               (($n == 1) ? "1 subsystem" : "$n subsystems") . ': ' . &subs($insubs) . ".";
	    push(@$pieces,$in_sub_state);
	}
    }
}

sub subs {
    my($subs) = @_;

    if (@$subs == 1) { return &fix_sub_name($subs->[0]) }
    my @subL = map { &fix_sub_name($_) } @$subs;
    $subL[$#subL] = "and $subL[$#subL]";
    return join(", ",@subL);
}

sub fix_sub_name {
    my($x) = @_;

    $x =~ s/_/ /g;
    return "\"$x\"";
}

#sub evidence_codes {
    #my($fig,$peg) = @_;
#
    #if ($peg !~ /^fig\|\d+\.\d+\.peg\.\d+$/) { return "" }
#
    #my @codes = grep { $_->[1] =~ /^evidence_code/i } $fig->get_attributes($peg);
    #return map { $_->[2] } @codes;
#}

=head3 clearinghouse_register_subsystem_id

    my $tax = FIGRules::clearinghouse_register_subsystem_id($ss_name);

Return a subsystem's short ID. Short IDs are maintained at a special
clearinghouse web site. If the subsystem does not yet have a short ID, a
new one will be assigned by the clearinghouse and returned.

=over 4

=item ss_name

Full name of the relevant subsystem.

=item RETURN

Short ID of the subsystem.

=back

=cut

sub clearinghouse_register_subsystem_id {
    my($ss_name) = @_;

    my $ch_url = "http://clearinghouse.theseed.org/Clearinghouse/clearinghouse_services.cgi";

	return;
#    my $proxy = SOAP::Lite->uri("http://www.soaplite.com/Scripts")->proxy($ch_url);

    #my ($resp, $retVal);
    #eval {
        #$resp = $proxy->register_subsystem_id($ss_name);
    #};
    #if ($@) {
        #Trace("Error on proxy call: $@") if T(0);
        #$retVal = undef;
    #} elsif ($resp->fault) {
        #Trace("Failure on register_subsystem_id($ss_name): " .$resp->faultcode . ": " . $resp->faultstring) if T(0);
        #$retVal = undef;
    #} else {
        #$retVal = $resp->result;
    #}
    #return $retVal;
}


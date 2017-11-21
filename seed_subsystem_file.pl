use lib '/var/www/gofeat/sas/lib/';
use SAPserver;
use Data::Dumper;
my $sapServer = SAPserver->new();
open my $handle, '<', $ARGV[0];
chomp(my @genes = <$handle>);
close $handle;
# Compute the functional roles.
my $results = $sapServer->ids_to_subsystems(-ids => \@genes, -source => 'UniProt');
# Loop through the genes.
for my $gene (@genes) {
    # Did we find a result?
    my $roleData = $results->{$gene};
    if (! @$roleData) {
        # Not in a subsystem: emit a warning.
        print STDERR "$gene is not in a subsystem.\n";
    } else {
        print '{';
        # Yes, print the entries.
        my $i = 0;
        for my $ssData (@$roleData) {
            #print "$gene\t$ssData->[0]\t($ssData->[1])\n";
                my $subsysHash = $sapServer->classification_of(
                            -ids => $ssData->[1]
                        );
                if($i>0){
                    print ",";
                }
                print '"'.$ssData->[1].'":[';
                #print Dumper($subsysHash);
                
                for my $subsys (keys %$subsysHash)
                {
                    my $allsubsys = $subsysHash->{$subsys};
                    print '"';
                    print join '","', @$allsubsys;
                    print '"';
                }
                print "]";
                $i++;
                
        }
        print "}\n";
    }
}
#!/usr/bin/env perl

#
#	This is a SAS Component.
#

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;

use RASTserver;



$0 =~ m/([^\/]+)$/;
my $self = $1;


my $usage = $self  . qq(  --user UserName  --passwd Passwd  (--genbank GenbankFilename | --fasta FASTAfilename) --domain (Bacteria|Archaea)  [--taxon_ID NCBI_taxonomy_ID(def:666666)]  [--bioname "genus species strain" (def: "Unknown sp.")]  [--genetic_code (11|4)] [--gene_caller (rast|glimmer3)] [--determine_family] [--reannotate_only] [--test] [--nonActive]);

if (not @ARGV) {
    warn qq(\n   usage: $usage\n\n);
    exit(0);
}

my $help           = q();
my $trouble        = 0;

my $username       = q();
my $password       = q();
my $genbank_file   = q();
my $fasta_file     = q();
my $domain         = q();
my $taxon_ID       = q();
my $bioname        = q();
my $genetic_code   = 11;
my $gene_caller    = q(RAST);
my $keep_genecalls = 0;
my $use_test_server = 0;
my $determine_family = 0;
my $non_active = 0;
my $rc = GetOptions(
    "help!"            => \$help,
    "user=s"           => \$username,
    "passwd=s"         => \$password,
    "fasta:s"          => \$fasta_file,
    "genbank:s"        => \$genbank_file,
    "bioname=s"        => \$bioname,
    "domain=s"         => \$domain,
    "taxon_ID:s"       => \$taxon_ID,
    "genetic_code:i"   => \$genetic_code,
    "gene_caller:s"    => \$gene_caller,
    "reannotate_only!" => \$keep_genecalls,
    "test"             => \$use_test_server,
    "nonActive"	       => \$non_active,
    "determine_family" => \$determine_family,
    );

print STDERR qq(\nrc=$rc\n\n) if $ENV{VERBOSE};

if (!$rc || $help) {
    warn qq(\n   usage: $usage\n\n);
    exit(0);
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#...Create instance of RASTserver client object...
#-----------------------------------------------------------------------
my $client = RASTserver->new($username, $password, { -test => $use_test_server });



#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#...Construct argument hash-ref
#      -filetype       =>  [Fasta|Genbank]
#      -taxonomyID     =>  number  | -domain => [Archaea | Bacteria]
#      -organismName   =>  string
#      -file          =>  full path to name of file on local machine
#      -keepGeneCalls =>  [0 | 1]
#      -geneCaller    =>  [RAST | Glimmer3]
#       if Fasta && ! TaxonomyID
#           -geneticCode =>  [4 | 11]
#-----------------------------------------------------------------------
my $arg_hashP = { -taxonomyID    => $taxon_ID,
		  -organismName  => $bioname,
		  -keepGeneCalls => $keep_genecalls,
		  -geneticCode   => $genetic_code,
		  -geneCaller    => $gene_caller,
		  -domain	 => $domain,
		  -non_active    => $non_active,
		  -determineFamily => $determine_family,
	      };

#...Assign context-dependent arguments...

if ($genbank_file && $fasta_file) {
    $trouble = 1;
    warn qq(ERROR: GenBank and FASTA submissions are mutually exclusive\n);
}
elsif ($fasta_file) {
    if (-s $fasta_file) {
	$arg_hashP->{-filetype} = q(fasta);
	$arg_hashP->{-file} = $fasta_file;
    }
    else {
	$trouble = 1;
        warn qq(\nFASTA file \'$fasta_file\' does not exists or has zero size.\n\n);
    }
}
elsif ($genbank_file) {
    if (-s $genbank_file) {
	$arg_hashP->{-filetype} = q(Genbank);
	$arg_hashP->{-file} = $genbank_file;
    }
    else {
	$trouble = 1;
	warn qq(\nGenbank file \'$genbank_file\' does not exist or has zero size.\n\n);
    }
}
else {
    $trouble = 1;
    warn qq(ERROR: You must provide either a '--genbank' or a '--fasta' filename argument\n);
}
die qq(   usage: $usage\n\n) if $trouble;

print STDERR Dumper( $arg_hashP ) if $ENV{VERBOSE};


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#...Submit job to RAST...
#-----------------------------------------------------------------------
#
# submits the RAST request, returning a hash of:
#     {jobid} =id
#     {status} = [submitted|error]
#     {error_message} = message

my $result = $client->submit_RAST_job( $arg_hashP );
print STDERR Dumper($result) if $ENV{VERBOSE};

if ($result->{status} eq q(error)) {
    if (not $result->{job_id}) {
	die qq(\nERROR: job creation failed, with error-message: \'$result->{error_message}\'\n\n);
    }
    else {
	die qq(\nERROR: job \'$result->{job_id}\' failed, with error-message: \'$result->{error_message}\'\n\n);
    }
}
else {
    print STDERR qq(\nJob \'$result->{job_id}\' was successfully started\n\n);
}

exit(0);

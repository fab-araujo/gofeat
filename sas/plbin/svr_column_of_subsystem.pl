#! /usr/bin/perl -w
#
#  This is a SAS component
#
use strict;
use SAPserver;
use Data::Dumper;

my $usage = <<End_of_Usage;

Usage:  svr_column_of_subsystem [options] subsystem role1 ... > fids

Options:

  -u  #  Unique entries only

End_of_Usage

my $unique = 0;
while ( @ARGV && $ARGV[0] =~ s/^-// )
{
    $_ = shift @ARGV;
    if ( s/u//g ) { $unique = 1 }
    if ( /./   )
    {
        print STDERR "Bad flag '$_'.\n", $usage;
        exit;
    }
}

my $ssID  = shift @ARGV;
defined $ssID or print STDERR "Missing subsystem name.\n", $usage and exit;
my @roles = @ARGV;
@roles or print STDERR "Missing role(s).\n", $usage and exit;

my $sap = SAPserver->new();
my $roleH  = $sap->pegs_implementing_roles( -subsystem =>  $ssID,
                                            -roles     => \@roles
                                            );

# $roleH = { $role1 => [$fid1a, $fid1b, ...],
#            $role2 => [$fid2a, $fid2b, ...],
#            ... };

# Collect fids with role by genome, so that unique entries can be found.

my %fids_in_genome_with_role;
my $role;
my $gid;
foreach $role ( keys %$roleH )
{
    my %fids_by_genome;
    my @fids = @{ $roleH->{ $role } };
    foreach ( @fids )
    {
        ( $gid ) = /^fig\|(\d+\.\d+)\.[^.]+\.\d+$/;
        push @{$fids_by_genome{ $gid }}, $_ if $gid;
    }
    $fids_in_genome_with_role{ $role } = \%fids_by_genome;
}

#  Collect the nonredundant list of fids

my %fids;
foreach $role ( @roles )
{
    my %fids_with_role_by_genome = %{$fids_in_genome_with_role{ $role }};
    foreach $gid ( keys %fids_with_role_by_genome )
    {
        my $fids = $fids_with_role_by_genome{ $gid };
        next if $unique && @$fids != 1;
        foreach ( @$fids ) { $fids{ $_ } = 1 }
    }
}

foreach ( keys %fids ) { print "$_\n" }

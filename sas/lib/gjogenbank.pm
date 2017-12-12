#
# This is a SAS component.
#
package gjogenbank;

#===============================================================================
#  Parse one or more GenBank entries in a file into perl structures.
#  All of the entries in the file as a list:
#
#      @entries = parse_genbank( )           #  \*STDIN
#     \@entries = parse_genbank( )           #  \*STDIN
#      @entries = parse_genbank( \*FH )
#     \@entries = parse_genbank( \*FH )
#      @entries = parse_genbank(  $file )
#     \@entries = parse_genbank(  $file )
#
#  One entry per call:
#
#      $entry = parse_next_genbank( )         #  STDIN
#      $entry = parse_next_genbank( \*FH )
#      $entry = parse_next_genbank( $file )
#
#  Error or end-of-file returns undef.
#
#  Each entry is a hash with key value pairs, some of which have special
#  processing.
#  
#     Key => Value
#
#     ACCESSION  => [ Accession, ... ]
#     DATE       =>   Date
#     DEFINITION =>   Definition
#     GEOMETRY   =>   Geometry
#     GI         =>   GI_number
#     KEYWORDS   => { Key_phrase => 1, Key_phrase => 1, ... }
#     LOCUS      =>   Locus
#     ORGANISM   =>   Organism_name
#     REFERENCES => [ { Field => Value, Field => Value, ... }, ... ]
#     SEQUENCE   =>   Sequence
#     SOURCE     =>   Source_string
#     TAXONOMY   => [ Taxon, Taxon, ... ]
#     VERSION    => [ Version, Other_information ]
#
#  Feature records are merged by type.  Slash is removed from qualifier name.
#  Surrounding quotation marks are stripped from qualifier values.
#
#     FEATURES   => { Type => [ [ Location, { Qualifier => \@values } ],
#                               [ Location, { Qualifier => \@values } ],
#                               ...
#                             ],
#                     Type => ...
#                   }
#
#
#  Access functions to parts of structure:
#
#     @types = feature_types( $entry );
#    \@types = feature_types( $entry );
#
#     @ftrs = features_of_type( $entry,  @types );
#    \@ftrs = features_of_type( $entry,  @types );
#     @ftrs = features_of_type( $entry, \@types );
#    \@ftrs = features_of_type( $entry, \@types );
#
#  Sequence of a feature, optionally including information on partial ends.
#
#     $seq                           = ftr_dna(  $dna, $ftr )
#     $seq                           = ftr_dna( \$dna, $ftr )
#   ( $seq, $partial_5, $partial_3 ) = ftr_dna(  $dna, $ftr )  # boolean of > or < in location
#   ( $seq, $partial_5, $partial_3 ) = ftr_dna( \$dna, $ftr )
#
#    $ftr_location = location( $ftr )      #  Returns empty string on failure.
#
#  Identify features with partial 5' or 3' ends.
#
#     $partial_5_prime = partial_5_prime( $ftr )
#     $partial_3_prime = partial_3_prime( $ftr )
#
#    \%ftr_qualifiers = qualifiers( $ftr )  #  Returns empty hash reference on failure.
#
#     $gene              = gene( $ftr )
#     @gene_and_synonyms = gene( $ftr )
#
#     $id = CDS_id( $ftr )         #  Prefer protein_id as id:
#     $id = CDS_gi_or_id( $ftr )   #  Prefer gi number as id:
#     $gi = CDS_gi( $ftr )         #  gi number or nothing:
#
#     $product = product( $ftr )
#
#     @EC_number = EC_number( $ftr )
#    \@EC_number = EC_number( $ftr )
#
#     $translation = CDS_translation( $ftr )          # Uses in situ if found
#     $translation = CDS_translation( $ftr,  $dna )   # If not in feature, translate
#     $translation = CDS_translation( $ftr, \$dna )
#     $translation = CDS_translation( $ftr,  $entry )
#
#  Convert GenBank location to [ [ $contig, $begin, $dir, $length ], ... ]
#
#    \@cbdl = genbank_loc_2_cbdl( $loc, $contig_id )
#
#  Convert GenBank location to a SEED or Sapling location string.
#
#     $loc                           = genbank_loc_2_seed( $acc, $loc )
#   ( $loc, $partial_5, $partial_3 ) = genbank_loc_2_seed( $acc, $loc )
#
#     $loc                           = genbank_loc_2_sapling( $acc, $loc )
#   ( $loc, $partial_5, $partial_3 ) = genbank_loc_2_sapling( $acc, $loc )
#
#  Convert a [ [ contig, begin, dir, length ], ... ] location to GenBank.
#
#     $gb_location            = cbdl_2_genbank( \@cbdl )
#   ( $contig, $gb_location ) = cbdl_2_genbank( \@cbdl )
#
#===============================================================================

use strict;

require Exporter;
our @ISA    = qw( Exporter );
our @EXPORT = qw( parse_genbank
                  parse_next_genbank
                  feature_types
                  features_of_type
                );

use Data::Dumper;

#===============================================================================
#
#    @entries = parse_genbank( )           #  \*STDIN
#   \@entries = parse_genbank( )           #  \*STDIN
#    @entries = parse_genbank( \*FH )
#   \@entries = parse_genbank( \*FH )
#    @entries = parse_genbank(  $file )
#   \@entries = parse_genbank(  $file )
#
#===============================================================================
my %genbank_streams;

sub parse_genbank
{
    my $file = shift;

    my ( $fh, $close ) = &input_filehandle( $file );
    $fh or return wantarray ? () : [];

    my @entries;
    while ( my $entry = parse_one_genbank_entry( $fh ) ) { push @entries, $entry }

    close $fh if $close;

    wantarray ? @entries : \@entries;
}


#-------------------------------------------------------------------------------
#  Read and parse a GenBank file, on entry at a time.  Successive calls with
#  same parameter will return successive entries.  Calls to different files
#  can be interlaced.
#
#      $entry = parse_next_genbank( )         #  STDIN
#      $entry = parse_next_genbank( \*FH )
#      $entry = parse_next_genbank( $file )
#
#  Error or end-of-file returns undef.
#-------------------------------------------------------------------------------
sub parse_next_genbank
{
    my $file = shift;

    my $stream = $genbank_streams{ $file || '' };
    if ( ! $stream )
    {
        $stream = [ &input_filehandle( $file ) ];   #  Value is ( $fh, $close )
        $stream->[0] or return undef;               #  Got a file handle?
        $genbank_streams{ $file || '' } = $stream;
    }

    my ( $fh, $close ) = @$stream;
    my $entry = parse_one_genbank_entry( $fh );

    if ( ! $entry ) { close $fh if $close; delete $genbank_streams{ $file || '' }; }

    return $entry;
}


#-------------------------------------------------------------------------------
#  If it should be necessary to close a stream openned by parse_next_genbank()
#  before it reaches the end-of-file, this will do it.
#
#      close_next_genbank( )         # does nothing
#      close_next_genbank( \*FH )
#      close_next_genbank( $file )
#
#-------------------------------------------------------------------------------
sub close_next_genbank
{
    my $file = shift;
    my $stream = $genbank_streams{ $file || '' };
    close $stream->[0] if $stream && ref $stream eq 'ARRAY' && $stream->[1];
}


#-------------------------------------------------------------------------------
#  Parse the next GenBank format entry read from an open file handle.  This is
#  primarily intended as an internal function called through parse_genbank()
#  or parse_next_genbank().
#
#     \%entry = parse_one_genbank_entry( \*FH )
#
#  Error or end-of-file returns undef
#-------------------------------------------------------------------------------
sub parse_one_genbank_entry
{
    my $fh = shift;

    my $state = 0;
    if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }

    #  0 = Looking for LOCUS
    #  1 = Header information
    #  2 = Features
    #  3 = Sequence
    # -1 = Error

    my %entry = ();
    my @sequence;
    
#          1         2         3         4         5         6         7         8
# 12345678901234567890123456789012345678901234567890123456789012345678901234567890
# LOCUS       NC_000909            1664970 bp    DNA     circular BCT 03-DEC-2005
# LOCUS       DGRINCAD_6   9696 BP DS-DNA             SYN       22-AUG-2006
#
    while ( $state == 0 )
    {
        if ( s/^LOCUS\s+// )
        {
            my @parts = split;
            $entry{ LOCUS }    = shift @parts;
            $entry{ DATE }     = pop @parts if $parts[-1] =~ m/^\d+-[A-Z][A-Z][A-Z]-\d+$/i;
            $entry{ DIVISION } = pop @parts;
            $entry{ GEOMETRY } = pop @parts if $parts[-1] =~ m/^(lin|circ)/i;
            $entry{ MOL_TYPE } = pop @parts if $parts[-1] =~ m/na$/i;
            $state = 1;
        }
        if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }
    }

    #  Reading the header requires merging continuations, then dealing
    #  with the data:

    while ( $state == 1 )
    {
        if ( /^FEATURES / )
        {
            $state = 2;
            if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }
        }

        elsif ( /^ORIGIN / )
        {
            $state = 3;
        }

        elsif ( /^REFERENCE / )
        {
            my $ref;
            ( $ref, $state, $_ ) = read_ref( $_, $fh );
            push @{ $entry{ REFERENCES } }, $ref if $ref;
            defined() or $state = -1;
        }

        elsif ( /^(..........)  (.*\S)\s*$/ )  # Any other keyword
        {
            my ( $tag, $value ) = ( $1, $2 );
            $tag =~ s/^ +//;
            $tag =~ s/ +$//;

            # Merge continuations:

            my $sep = ( $tag eq 'ORGANISM' ) ? "\t" :
                      ( $tag eq 'COMMENT'  ) ? "\n" : ' ';

            if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }
            while ( $state >= 0 && s/^ {12}/$sep/ )
            {
                $value .= $_ if length() > 1;
                $sep = ' ' if $sep eq "\t";
                if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }
            }

            #  Special case formats

            if ( $tag eq 'ACCESSION' )
            {
                $entry{ ACCESSION } = [ split / +/, $value ];
            }
            elsif ( $tag eq 'VERSION' )
            {
                my ( $gi ) = $value =~ s/ +GI:(\d+)//;
                $entry{ GI } = $gi if $gi;
                $entry{ VERSION } = [ split / +/, $value ];
            }
            elsif ( $tag eq 'KEYWORDS' )
            {
                $value =~ s/\s*\.$//;
                $entry{ KEYWORDS } = { map { $_ => 1 } split /; */, $value } if $value;
            }
            elsif ( $tag eq 'ORGANISM' )
            {
                $value =~ s/\.$//;
                my ( $org, $tax ) = split /\t/, $value;
                $entry{ ORGANISM } = $org;
                $entry{ TAXONOMY } = [ split /; */, $tax ] if $tax;
            }
            else
            {
                $entry{ $tag } = $value;
            }

            # To know that we are at end of continuations, we must have
            # read another line.

            defined() or $state = -1;
        }

        else  # This is really a format error, but let's skip it.
        {
            if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }
        }
    }

    #  Reading the features requires merging continuations, then dealing
    #  with the data:

    while ( $state == 2 )
    {
        if ( /^ORIGIN/ || /^BASE COUNT/ )
        {
            $state = 3;
        }

        elsif ( /^     (\S+)\s+(\S+)/ )
        {
            my ( $type, $loc ) = ( $1, $2 );
            my ( $qualif, $value, %qualifs );

            #  Collect the rest of the location:

            if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }
            while ( $state >= 0 && /^ {15}/ && ( $_ !~ /^\s*\/\w/ ) )
            {
                s/^ +//;
                $loc .= $_;
                if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }
            }

            #  Collect qualiiers:

            while ( $state == 2 && ( $_ =~ /^\s*\/\w+/ ) )
            {
                #  Qualifiers without = get an undef value (intentionally)

                ( $qualif, undef, $value ) = /^\s*\/(\w+)(=(.*))?/;

                #  Quoted strings can have value lines that start with /, so
                #  we must track quotation marks.

                my $nquote = $value ? $value =~ tr/"// : 0;

                if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }
                while ( $state >= 0 && /^ {15}/ && ( $nquote % 2 || ( ! /^\s*\/\w/ ) ) )
                {
                    s/^ +//;
                    $nquote += tr/"//;
                    $value  .= " $_";
                    if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }
                }

                if ( $nquote % 2 )
                {
                    print STDERR "Feature quotation nesting error: $type, $loc, $qualif=$value\n";
                    exit;
                }

                if ( $qualif )
                {
                    if ( $value && $value =~ /^".*"$/ )
                    {
                        $value =~ s/^"//;
                        $value =~ s/"$//;
                        $value =~ s/""/"/g;
                    }

                    if ( $qualif eq 'translation' ) { $value =~ s/ +//g }

                    push @{ $qualifs{ $qualif } }, $value;
                }
            }

            push @{ $entry{ FEATURES }->{ $type } }, [ $loc, \%qualifs ] if ( $type && $loc );

            defined() or $state = -1;
        }

        elsif ( /^\s{0,4}\S/ )  # Not feature and not origin
        {
            $state = -1;
        }

        else
        {
            if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }
        }
    }

    if ( $state == 3 && s/^BASE COUNT\s+// )
    {
        $entry{ BASE_COUNT } = { reverse split };
        $state = ( defined( $_ = <$fh> ) && /^ORIGIN/ ) ? 3 : -1;
    }

    #  Read the sequence:

    while ( $state == 3 )
    {
        if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }
        while ( $state >= 0 && /^[ 0-9]{10}/ )
        {
            s/[^A-Za-z]+//g;
            push @sequence, $_;
            if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }
        }
        $entry{ SEQUENCE } = join "", @sequence;

        $state = ( $_ eq '//' ) ? 0 : -1 if $state >= 0;
    }

    $state >= 0 ? \%entry : undef;
}


#-------------------------------------------------------------------------------
#  Parse a reference.
#-------------------------------------------------------------------------------
sub read_ref
{
    my ( $line, $fh ) = @_;
    my $state = 1;
    if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }

    my ( $tag, $value );
    my %ref = ();
    while ( ( $state >= 0 ) && /^  / )
    {
        if ( substr( $_, 0, 10 ) =~ /\S/ )
        {
            ( $tag, $value ) = $_ =~ /\s*(\w+)\s+(.*)$/;
        }
        elsif ( /\S/ )
        {
            s/^ +//;
            $value .= " $_" if $_;
        }

        if ( defined( $_ = <$fh> ) ) { chomp } else { $state = -1 }

        if ( ( $state < 0 ) || ( /^ {0,9}\S/ ) )
        {
            if ( $tag && $value )
            {
                $ref{ $tag } = $value;
            }
            $tag = $value = undef;
        }
    }

    ( ( keys %ref ? \%ref : undef ), $state, $_ )
}



#===============================================================================
#  Access methods for some features and feature data
#===============================================================================
#
#     @types = feature_types( $entry );
#    \@types = feature_types( $entry );
#
#     @ftrs = features_of_type( $entry,  @types );
#    \@ftrs = features_of_type( $entry,  @types );
#     @ftrs = features_of_type( $entry, \@types );
#    \@ftrs = features_of_type( $entry, \@types );
#
#-------------------------------------------------------------------------------

sub feature_types
{
    my $entry = shift;
    return wantarray ? () : [] if ! ( $entry && ref $entry eq 'HASH' );

    my $ftrs = $entry->{ FEATURES };
    return wantarray ? () : [] if ! ( $ftrs && ref $ftrs eq 'HASH' );

    my @types = sort { lc $a cmp lc $b } keys %$ftrs;
    wantarray ? @types : \@types;
}


sub features_of_type
{
    my $entry = shift;
    return wantarray ? () : [] if ! ( $entry && ref $entry eq 'HASH' );

    my $ftrs = $entry->{ FEATURES };
    return wantarray ? () : [] if ! ( $ftrs && ref $ftrs eq 'HASH' );

    my @types = ( ! $_[0] )              ? sort { lc $a cmp lc $b } keys %$ftrs
              : ( ref $_[0] eq 'ARRAY' ) ? @{ $_[0] }
              :                            @_;

    my @ftrs = map { @{ $ftrs->{ $_ } || [] } } @types;
    wantarray ? @ftrs : \@ftrs;
}


#-------------------------------------------------------------------------------
#  Sequence of a feature.  In list context, include information on partial ends.
#  Can get extract the data from a DNA string, reference to a string, or from
#  the SEQUENCE in an entry.
#
#     $seq                           = ftr_dna(  $dna,   $ftr )
#     $seq                           = ftr_dna( \$dna,   $ftr )
#     $seq                           = ftr_dna(  $entry, $ftr )
#   ( $seq, $partial_5, $partial_3 ) = ftr_dna(  $dna,   $ftr )
#   ( $seq, $partial_5, $partial_3 ) = ftr_dna( \$dna,   $ftr )
#   ( $seq, $partial_5, $partial_3 ) = ftr_dna(  $entry, $ftr )
#
#-------------------------------------------------------------------------------
sub ftr_dna
{
    my ( $dna, $ftr ) = @_;
    return undef if ! ( $dna && $ftr );

    my $dnaR =   ref $dna eq 'SCALAR'                     ?  $dna
             :   ref $dna eq 'HASH' && $dna->{ SEQUENCE } ? \$dna->{ SEQUENCE }
             : ! ref $dna                                 ? \$dna
             :                                               undef;
    return undef if ! $dnaR;

    my $loc = &location( $ftr );
    $loc or return undef;

    my $loc0 = $loc;
    my $complement = ( $loc =~ s/^complement\((.*)\)$/$1/ );
    $loc =~ s/^join\((.*)\)$/$1/;
    my @spans = split /,/, $loc;
    if ( grep { ! /^<?\d+\.\.>?\d+$/ } @spans )
    {
        print STDERR "*** Feature location parse error: $loc0\n";
        return undef;
    }

    my $partial_5 = $spans[ 0] =~ s/^<//;
    my $partial_3 = $spans[-1] =~ s/\.\.>/../;
    ( $partial_5, $partial_3 ) = ( $partial_3, $partial_5 ) if $complement;

    my $seq = join( '', map { extract_span( $dnaR, $_ ) } @spans );
    $seq = gjoseqlib::complement_DNA_seq( $seq ) if $complement;

    #  Sequences that run off the end can start at other than the first
    #  nucleotide of a codon.

    my $qual = &qualifiers( $ftr );
    my $codon_start = $qual->{ codon_start } ? $qual->{ codon_start }->[0] : 1;
    $seq = substr( $seq, $codon_start-1 ) if $codon_start > 1;

    wantarray ? ( $seq, $partial_5, $partial_3 ) : $seq;
}

sub extract_span
{
    my ( $dnaR, $span ) = @_;
    my ( $beg, $end ) = $span =~ /^<?(\d+)\.\.>?(\d+)$/;
    ( $beg > 0 ) && ( $beg <= $end ) && ( $end <= length( $$dnaR ) ) or return '';

    substr( $$dnaR, $beg-1, $end-$beg+1 );
}


#-------------------------------------------------------------------------------
#  Identify features with partial 5' or 3' ends.
#
#     $partial_5_prime = partial_5_prime( $ftr )
#     $partial_3_prime = partial_3_prime( $ftr )
#
#-------------------------------------------------------------------------------
sub partial_5_prime
{
    my $ftr = shift             or return undef;
    my $loc = &location( $ftr ) or return undef;
    my $complement = ( $loc =~ s/^complement\((.*)\)$/$1/ );
    $loc =~ s/^join\((.*)\)$/$1/;
    my @spans = split /,/, $loc;

    $complement ? $spans[-1] =~ /\.\.>/ : $spans[0] =~ /^</;
}


sub partial_3_prime
{
    my $ftr = shift             or return undef;
    my $loc = &location( $ftr ) or return undef;
    my $complement = ( $loc =~ s/^complement\((.*)\)$/$1/ );
    $loc =~ s/^join\((.*)\)$/$1/;
    my @spans = split /,/, $loc;

    $complement ? $spans[0] =~ /^</ : $spans[-1] =~ /\.\.>/;
}


#-------------------------------------------------------------------------------
#
#    $ftr_location = location( $ftr )   #  Returns empty string on failure.
#
#-------------------------------------------------------------------------------
sub location
{
    my ( $ftr ) = @_;

    ( defined( $ftr )
         && ( ref( $ftr ) eq 'ARRAY' )
         && ( @$ftr > 1 ) )
         ? $ftr->[0]
         : '';
}


#-------------------------------------------------------------------------------
#
#  \%ftr_qualifiers = qualifiers( $ftr )   #  Returns empty hash reference on failure.
#
#-------------------------------------------------------------------------------
sub qualifiers
{
    my ( $ftr ) = @_;
    my $qual;
    ( defined( $ftr )
         && ( ref( $ftr ) eq 'ARRAY' )
         && ( @$ftr > 1 )
         && defined( $qual = $ftr->[1] )
         && ( ref( $qual ) eq 'HASH' ) )
         ? $qual
         : {};
}


#-------------------------------------------------------------------------------
#
#   $gene              = gene( $ftr )
#   @gene_and_synonyms = gene( $ftr )
#
#-------------------------------------------------------------------------------
sub gene
{
    my $qual = &qualifiers( @_ );
    my %seen;
    my @gene = grep { ! $seen{ $_ }++ }
               ( ( $qual->{ gene }         ? @{ $qual->{ gene } }         : () ),
                 ( $qual->{ gene_synonym } ? @{ $qual->{ gene_synonym } } : () )
               );

    wantarray ? @gene : $gene[0];
}


#-------------------------------------------------------------------------------
#  Prefer protein_id as id:
#
#   $id = CDS_id( $ftr )
#
#-------------------------------------------------------------------------------
sub CDS_id
{
    my $qual = &qualifiers( @_ );
    my $id;

    ( $id ) =                                 @{ $qual->{ protein_id } } if          $qual->{ protein_id };
    ( $id ) = map { m/^GI:(.+)$/i ? $1 : () } @{ $qual->{ db_xref } }    if ! $id && $qual->{ db_xref };
    ( $id ) =                                 @{ $qual->{ locus_tag } }  if ! $id && $qual->{ locus_tag };

    $id;
}


#-------------------------------------------------------------------------------
#  Prefer gi number as id:
#
#   $id = CDS_gi_or_id( $ftr )
#
#-------------------------------------------------------------------------------
sub CDS_gi_or_id
{
    my $qual = &qualifiers( @_ );
    my $id;

    ( $id ) = map { m/^GI:(.+)$/i ? $1 : () } @{ $qual->{ db_xref } }    if          $qual->{ db_xref };
    ( $id ) =                                 @{ $qual->{ protein_id } } if ! $id && $qual->{ protein_id };
    ( $id ) =                                 @{ $qual->{ locus_tag } }  if ! $id && $qual->{ locus_tag };

    $id;
}


#-------------------------------------------------------------------------------
#  gi number or nothing:
#
#   $gi = CDS_gi( $ftr )
#
#-------------------------------------------------------------------------------
sub CDS_gi
{
    my $qual = &qualifiers( @_ );

    my ( $id ) = map { m/^GI:(.+)$/i ? $1 : () } @{ $qual->{ db_xref } } if $qual->{ db_xref };

    $id;
}


#-------------------------------------------------------------------------------
#
#   $product = product( $ftr )
#
#-------------------------------------------------------------------------------
sub product
{
    my $qual = &qualifiers( @_ );
    my $prod;

    ( $prod ) = @{ $qual->{ product } }  if            $qual->{ product };
    ( $prod ) = @{ $qual->{ function } } if ! $prod && $qual->{ function };
    ( $prod ) = @{ $qual->{ note } }     if ! $prod && $qual->{ note };

    $prod;
}


#-------------------------------------------------------------------------------
#
#   @EC_number = EC_number( $ftr )
#  \@EC_number = EC_number( $ftr )
#
#-------------------------------------------------------------------------------
sub EC_number
{
    my $qual = &qualifiers( @_ );
    my @EC = $qual->{ EC_number } ? @{ $qual->{ EC_number } } : ();

    wantarray ? @EC : \@EC;
}


#-------------------------------------------------------------------------------
#   This is the in situ translation.  Will extract from the DNA sequence if
#   supplied.
#
#   $translation = CDS_translation( $ftr )
#   $translation = CDS_translation( $ftr,  $dna )
#   $translation = CDS_translation( $ftr, \$dna )
#   $translation = CDS_translation( $ftr,  $entry )
#
#
#-------------------------------------------------------------------------------
sub CDS_translation
{
    my ( $ftr, $dna ) = @_;
    my $qual = &qualifiers( $ftr );

    return $qual->{ translation }->[0] if $qual->{ translation };

    return undef if ! $dna;

    my $have_lib = 0;
    eval { require gjoseqlib; $have_lib = 1; };
    return undef if ! $have_lib;

    my $CDS_dna = ftr_dna( $dna, $ftr ) or return undef;
    my $pep = gjoseqlib::translate_seq( $CDS_dna, ! partial_5_prime( $ftr ) );
    $pep =~ s/\*$// if $pep;

    $pep;
}


#===============================================================================
#  Utilities for locations and location strings.
#===============================================================================
#  Convert GenBank location to a SEED location.
#
#     $loc                           = genbank_loc_2_seed( $acc, $loc )
#   ( $loc, $partial_5, $partial_3 ) = genbank_loc_2_seed( $acc, $loc )
#
#-------------------------------------------------------------------------------
sub genbank_loc_2_seed
{
    my ( $acc, $loc ) = @_;
    $acc && $loc or return undef;
    genbank_loc_2_string( $acc, $loc, 'seed' );
}


#-------------------------------------------------------------------------------
#  Convert GenBank location to a Sapling location.
#
#     $loc                           = genbank_loc_2_sapling( $acc, $loc )
#   ( $loc, $partial_5, $partial_3 ) = genbank_loc_2_sapling( $acc, $loc )
#
#-------------------------------------------------------------------------------
sub genbank_loc_2_sapling
{
    my ( $acc, $loc ) = @_;
    $acc && $loc or return undef;
    genbank_loc_2_string( $acc, $loc, 'sapling' );
}


#-------------------------------------------------------------------------------
#  Convert GenBank location to another location format.
#  At present, only 'sapling' (D) and 'seed' are supported.
#
#     $loc                           = genbank_loc_2_string( $acc, $loc, $format )
#   ( $loc, $partial_5, $partial_3 ) = genbank_loc_2_string( $acc, $loc, $format )
#
#-------------------------------------------------------------------------------
sub genbank_loc_2_string
{
    my ( $acc, $loc, $format ) = @_;
    $acc && $loc or return undef;

    my ( $cbdl, $partial_5, $partial_3 ) = genbank_loc_2_cbdl( $loc, $acc );
    my $str = cbdl_2_string( $cbdl, $format || 'sapling' );

    wantarray ? ( $str, $partial_5, $partial_3 ) : $str;
}


#-------------------------------------------------------------------------------
#  Convert GenBank location to a list of [contig, begin, dir, len ] locations.
#  order() is treated as join().  Nesting is allowed (unlike the standard).
#
#     \@cbdl                           = genbank_loc_2_cbdl( $loc, $accession )
#   ( \@cbdl, $partial_5, $partial_3 ) = genbank_loc_2_cbdl( $loc, $accession )
#
#  Elements are:
#
#   (accession:)?<?\d+..>?\d+                  # range of sites
#   (accession:)?<?\d+^>?\d+                   # site between residues
#   (accession:)?\d+                           # single residue
#   (accession:)?complement\(element\)
#   (accession:)?join\(element,element,...\)
#   (accession:)?order\(element,element,...\)
#
#-------------------------------------------------------------------------------
#  Paterns used in the parsing.  They are in each subroutine due to a very
#  strange initialization issue.
#
#  Because $paranthetical is self-referential, it must be declared before it is
#  defined.
#
#   my $paranthetical;
#      $paranthetical    = qr/\([^()]*(?:(??{$paranthetical})[^()]*)*\)/;
#   my $contigid         = qr/[^\s:(),]+/;
#   my $complement       = qr/(?:$contigid:)?complement$paranthetical/;
#   my $complement_parts = qr/(?:($contigid):)?complement($paranthetical)/;
#   my $join             = qr/(?:$contigid:)?join$paranthetical/;
#   my $join_parts       = qr/(?:($contigid):)?join($paranthetical)/;
#   my $order            = qr/(?:$contigid:)?order$paranthetical/;
#   my $order_parts      = qr/(?:($contigid):)?order($paranthetical)/;
#   my $range            = qr/(?:$contigid:)?<?\d+\.\.>?\d+/;
#   my $range_parts      = qr/(?:($contigid):)?(<?)(\d+)\.\.(>?)(\d+)/;
#   my $site             = qr/(?:$contigid:)?<?\d+^>?\d+/;
#   my $site_parts       = qr/(?:($contigid):)?(<?)(\d+)^(>?)(\d+)/;
#   my $position         = qr/(?:$contigid:)?\d+/;
#   my $position_parts   = qr/(?:($contigid):)?(\d+)/;
#   my $element          = qr/$range|$position|$complement|$join|$order/;
#   my $elementlist      = qr/$element(?:,$element)*/;
#
#-------------------------------------------------------------------------------

sub genbank_loc_2_cbdl
{
    my ( $loc, $acc ) = @_;

    my $contigid = qr/[^\s:(),]+/;

    my $range = qr/(?:$contigid:)?<?\d+\.\.>?\d+/;
    return gb_loc_range( $loc, $acc )      if $loc =~ /^$range$/;

    #  This cannot by part of any other format except complement
    my $site = qr/(?:$contigid:)?<?\d+\^>?\d+/;
    return gb_loc_site( $loc, $acc )       if $loc =~ /^$site$/;

    my $position = qr/(?:$contigid:)?\d+/;
    return gb_loc_position( $loc, $acc )   if $loc =~ /^$position$/;

    my $paranthetical;
       $paranthetical = qr/\([^()]*(?:(??{$paranthetical})[^()]*)*\)/;
    my $complement = qr/(?:$contigid:)?complement$paranthetical/;
    return gb_loc_complement( $loc, $acc ) if $loc =~ /^$complement$/;

    my $join = qr/(?:$contigid:)?join$paranthetical/;
    return gb_loc_join( $loc, $acc )       if $loc =~ /^$join$/;

    #  Treated as a join
    my $order = qr/(?:$contigid:)?order$paranthetical/;
    return gb_loc_order( $loc, $acc )      if $loc =~ /^$order$/;

    return ();
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  A range of positions, with optional accession number prefix, optional less
#  than first position (5' partial), begin, .., optional greater than end
#  position (3' partial), and end position.
#
#    (\S+:)?<?\d+\.\.>?\d+
#
#    ( \@cbdl_list, $partial_5, $partial_3 ) = gb_loc_range( $loc, $acc )
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub gb_loc_range
{
    my ( $loc, $acc ) = @_;

    my $contigid = qr/[^\s:(),]+/;
    my $range_parts = qr/(?:($contigid):)?(<?)(\d+)\.\.(>?)(\d+)/;
    my ( $acc2, $p5, $beg, $p3, $end ) = $loc =~ /^$range_parts$/;
    $beg && $end or return ();
    $acc2 ||= $acc;

    #  GenBank standard is always $beg <= $end.  We will relax that.

    ( [ [ $acc2, $beg, (($end>=$beg)?'+':'-'), abs($end-$beg)+1 ] ], $p5, $p3 );
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  A range of positions, with optional accession number prefix, optional less
#  than first position (5' partial), begin, ^, optional greater than end
#  position (3' partial), and end position.
#
#    (\S+:)?<?\d+^>?\d+
#
#    ( \@cbdl_list, $partial_5, $partial_3 ) = gb_loc_site( $loc, $acc )
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub gb_loc_site
{
    my ( $loc, $acc ) = @_;

    my $contigid = qr/[^\s:(),]+/;
    my $site_parts = qr/(?:($contigid):)?(<?)(\d+)\^(>?)(\d+)/;
    my ( $acc2, $p5, $beg, $p3, $end ) = $loc =~ /^$site_parts$/;
    $beg && $end or return ();
    $acc2 ||= $acc;

    #  GenBank standard is always $beg <= $end.  We will relax that.

    ( [ [ $acc2, $beg, (($end>=$beg)?'+':'-'), abs($end-$beg)+1 ] ], $p5, $p3 );
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  A singe position, with optional accession number prefix.
#
#    (\S+:)?\d+
#
#    ( \@cbdl_list, $partial_5, $partial_3 ) = gb_loc_position( $loc, $acc )
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub gb_loc_position
{
    my ( $loc, $acc ) = @_;

    my $contigid = qr/[^\s:(),]+/;
    my $position_parts = qr/(?:($contigid):)?(\d+)/;
    my ( $acc2, $beg ) = $loc =~ /^$position_parts$/;
    $beg or return ();

    ( [ [ $acc2 || $acc, $beg, '+', 1 ] ], '', '' );
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#    ( \@cbdl_list, $partial_5, $partial_3 ) = gb_loc_complement( $loc, $acc )
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub gb_loc_complement
{
    my ( $loc, $acc ) = @_;

    my $paranthetical;
       $paranthetical    = qr/\([^()]*(?:(??{$paranthetical})[^()]*)*\)/;
    my $contigid         = qr/[^\s:(),]+/;
    my $complement_parts = qr/(?:($contigid):)?complement($paranthetical)/;

    my ( $acc2, $loc2 ) = $loc =~ /^$complement_parts$/;
    $loc2 && $loc2 =~ s/^\(// && $loc2 =~ s/\)$// or return ();
    my ( $locs, $p5, $p3 ) = genbank_loc_2_cbdl( $loc2, $acc2 || $acc );
    $locs && ref( $locs ) eq 'ARRAY' && @$locs or return ();

    ( [ map { complement_cbdl( @$_ ) } reverse @$locs ], $p3, $p5 );
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#    ( \@cbdl_list, $partial_5, $partial_3 ) = gb_loc_join( $loc, $acc )
#
#  There is no warning about partial sequences internal to list.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub gb_loc_join
{
    my ( $loc, $acc ) = @_;

    my $paranthetical;
       $paranthetical    = qr/\([^()]*(?:(??{$paranthetical})[^()]*)*\)/;
    my $contigid         = qr/[^\s:(),]+/;
    my $complement       = qr/(?:$contigid:)?complement$paranthetical/;
    my $join             = qr/(?:$contigid:)?join$paranthetical/;
    my $join_parts       = qr/(?:($contigid):)?join($paranthetical)/;
    my $order            = qr/(?:$contigid:)?order$paranthetical/;
    my $range            = qr/(?:$contigid:)?<?\d+\.\.>?\d+/;
    my $position         = qr/(?:$contigid:)?\d+/;
    my $element          = qr/$range|$position|$complement|$join|$order/;
    my $elementlist      = qr/$element(?:,$element)*/;

    my ( $acc2, $locs ) = $loc =~ /^$join_parts$/;
    $locs && $locs =~ s/^\(// && $locs =~ s/\)$//
          && $locs =~ /^$elementlist$/
          or return ();
    $acc2 ||= $acc;

    my @elements = map { [ genbank_loc_2_cbdl( $_, $acc2 ) ] }
                   $locs =~ m/($element)/g;
    @elements or return ();

    ( [ map { @{ $_->[0] } } @elements ], $elements[0]->[1], $elements[-1]->[2] );
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Ordered list is treated as a join:
#
#    ( \@cbdl_list, $partial_5, $partial_3 ) = gb_loc_order( $loc, $acc )
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub gb_loc_order
{
    my ( $loc, $acc ) = @_;

    my $paranthetical;
       $paranthetical    = qr/\([^()]*(?:(??{$paranthetical})[^()]*)*\)/;
    my $contigid         = qr/[^\s:(),]+/;
    my $complement       = qr/(?:$contigid:)?complement$paranthetical/;
    my $join             = qr/(?:$contigid:)?join$paranthetical/;
    my $order            = qr/(?:$contigid:)?order$paranthetical/;
    my $order_parts      = qr/(?:($contigid):)?order($paranthetical)/;
    my $range            = qr/(?:$contigid:)?<?\d+\.\.>?\d+/;
    my $position         = qr/(?:$contigid:)?\d+/;
    my $element          = qr/$range|$position|$complement|$join|$order/;
    my $elementlist      = qr/$element(?:,$element)*/;

    my ( $acc2, $locs ) = $loc =~ /^$order_parts$/;
    $locs && $locs =~ s/^\(// && $locs =~ s/\)$//
          && $locs =~ /^$elementlist$/
          or return ();

    gb_loc_join( "join($locs)", $acc2 || $acc );
}


#-------------------------------------------------------------------------------
#    $cbdl = complement_cbdl(   $contig, $beg, $dir, $len   )
#    $cbdl = complement_cbdl( [ $contig, $beg, $dir, $len ] )
#-------------------------------------------------------------------------------
sub complement_cbdl
{
    defined $_[0] or return ();
    my ( $contig, $beg, $dir, $len ) = ref( $_[0] ) ? @{$_[0]} : @_;

    ( $dir =~ /^-/ ) ? [ $contig, $beg -= $len - 1, '+', $len ]
                     : [ $contig, $beg += $len - 1, '-', $len ];
}


#-------------------------------------------------------------------------------
#   $loc = cbdl_2_string( \@cbdl, $format )
#-------------------------------------------------------------------------------
sub cbdl_2_string
{
    my ( $cbdl, $format ) = @_;
    $cbdl && ( ref( $cbdl ) eq 'ARRAY' ) or return undef;
    $format = 'sapling' if ! defined $format;
    return cbdl_2_genbank( $cbdl ) if $format =~ m/genbank/i;
    join( ',', map { cbdl_part_2_string( $_, $format ) } @$cbdl );
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Support function for formatting one contiguous part of location.
#
#   $loc_part = cbdl_part_2_string( $cbdl_part, $format )
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub cbdl_part_2_string
{
    my ( $part, $format ) = @_;
    $part && ( ref( $part ) eq 'ARRAY' ) && ( @$part == 4 ) or return ();
    my ( $contig, $beg, $dir, $len ) = @$part;
    $dir = $dir =~ /^-/ ? '-' : '+';

    if ( $format =~ m/seed/i )
    {
        my $n2 = ( $dir eq '+' ) ? $beg + $len - 1 : $beg - $len + 1;
        return join( '_', $contig, $beg, $n2 );
    }

    # Default is sapling:

    return $contig . '_' . $beg . $dir . $len;
}

#-------------------------------------------------------------------------------
#  Convert a [ [ contig, begin, dir, length ], ... ] location to GenBank.
#
#    $gb_location            = cbdl_2_genbank( \@cbdl )
#  ( $contig, $gb_location ) = cbdl_2_genbank( \@cbdl )
#-------------------------------------------------------------------------------
sub cbdl_2_genbank
{
    my ( $cbdl, $contig ) = @_;
    $cbdl && ref( $cbdl ) eq 'ARRAY' && @$cbdl or return '';
    my @cbdl = ref( $cbdl->[0] ) ? @$cbdl : ( $cbdl );
    @cbdl or return '';

    my $dir = $cbdl[0]->[2];
    @cbdl = map { complement_cbdl( $_ ) } reverse @cbdl if $dir =~ /^-/;

    $contig = $cbdl[0]->[0];
    my @gb = map { cbdl_part_2_genbank( $_, $contig ) } @cbdl;

    my $gb = ( @gb > 1 ) ? 'join(' . join( ',', @gb ) . ')' : $gb[0];

    $gb = "complement($gb)" if $dir =~ /^-/;

    return wantarray ? ( $contig, $gb ) : $gb;
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  Support function for formatting one contiguous part of location.
#
#   $loc_part = cbdl_part_2_genbank( $cbdl_part, $contig )
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
sub cbdl_part_2_genbank
{
    my ( $part, $contig0 ) = @_;
    $part && ( ref( $part ) eq 'ARRAY' ) && ( @$part == 4 ) or return ();
    my ( $contig, $beg, $dir, $len ) = @$part;

    my $gb;
    if ( $dir =~ /^-/ )
    {
        my $end = $beg - ( $len-1);
        $gb = "complement($end..$beg)";
    }
    else
    {
        my $end = $beg + ($len-1);
        $gb = "$beg..$end";
    }

    $gb = "$contig:$gb" if $contig0 && $contig ne $contig0;

    return $gb;
}

#===============================================================================
#  Helper function for defining an input filehandle:
#
#     filehandle is passed through
#     string is taken as file name to be openend
#     undef or "" defaults to STDOUT
#
#      \*FH           = input_filehandle( $file );
#    ( \*FH, $close ) = input_filehandle( $file );
#
#===============================================================================
sub input_filehandle
{
    my $file = shift;

    #  Null string or undef

    if ( ! defined( $file ) || ( $file eq '' ) )
    {
        return wantarray ? ( \*STDIN, 0 ) : \*STDIN;
    }

    #  FILEHANDLE?

    if ( ref( $file ) eq "GLOB" )
    {
        return wantarray ? ( $file, 0 ) : $file;
    }

    #  File name

    if ( ! ref( $file ) )
    {
        -f $file or die "Could not find input file \"$file\"\n";
        my $fh;
        open( $fh, "<$file" ) || die "Could not open \"$file\" for input\n";
        return wantarray ? ( $fh, 1 ) : $fh;
    }

    return wantarray ? ( \*STDIN, undef ) : \*STDIN;
}


1;

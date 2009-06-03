package Religion::Bible::Regex::Reference;

use strict;
use warnings;

# Input files are assumed to be in the UTF-8 strict character encoding.
use utf8;
binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

use Carp;
use Storable qw(store retrieve freeze thaw dclone);
use Data::Dumper;

use Religion::Bible::Regex::Config;
use version; our $VERSION = qv('0.8');

##################################################################################
# Configuration options:
# reference.full_book_name: true/false
# reference.abbreviation.map: true/false
# reference.cvs: Chapitre/Verset Separateur
##################################################################################
# Glossaire des abréviations
# $hs  = header space
# $a   = l'espace entre le livre et le chapitre - $d
# $l   = le nom du livre ou abréviation
# $c   = chapitre
# $b   = l'espace entre le chapitre et le chapitre-verset separateur
# $cvs = chapitre ou verset separateur
# $d   = l'espace entre le chapitre-verset separateur et le verset
# $v, $vl_cl_sep
# $ts  = l'espace vers le tail (queue)
# $type = LCV, LCCV, LCVV
##################################################################################

# Defaults and Constants
# our %configuration_defaults = (
#     verse_list_separateur => ', ',
#     chapter_list_separateur => '; ',
#     book_list_separateur => '; ',
# );

# These constants are defined in several places and probably should be moved to a common file
# Move these to Constants.pm
use constant BOOK    => 'BOOK';
use constant CHAPTER => 'CHAPTER';
use constant VERSE   => 'VERSE'; 
use constant UNKNOWN => 'UNKNOWN';
use constant TRUE => 1;
use constant FALSE => 0;

sub new {
    my ($class, $config, $regex) = @_;
    my ($self) = {};
    bless $self, $class;
    $self->{'regex'} = $regex;
    $self->{'config'} = $config;
#    $self->{'reference_config'} = new Religion::Bible::Regex::Config($config->get_formatting_configurations, \%configuration_defaults);
    return $self;
}
# sub _initialize_default_configuration {
#     my $self = shift; 
#     my $defaults = shift; 

#     while ( my ($key, $value) = each(%{$defaults}) ) {    
#        $self->set($key, $value) unless defined($self->{mainconfig}{$key});  
#     }
# }

# Returns a reference to a Religion::Bible::Regex::Builder object.

# Subroutines related to getting information
sub get_regexes {
  my $self = shift;
  confess "regex is not defined\n" unless defined($self->{regex});
  return $self->{regex};
}

# Returns a reference to a Religion::Bible::Regex::Config object.
sub get_configuration {
  my $self = shift;
  confess "config is not defined\n" unless defined($self->{config});
  return $self->{config};
}

sub get_reference_hash { return shift->{'reference'}; }
sub reference { get_reference_hash(@_); }

# sub get_formatting_configuration_hash {
#   my $self = shift;
#   confess "reference is not defined in ReferenceBiblique::Versification\n" unless defined($self->{config}->get_formatting_configurations);
#   return $self->{config}->get_formatting_configurations;
# }

# sub get_versification_configuration_hash {
#   my $self = shift;
#   confess "reference_config is not defined in ReferenceBiblique::Versification\n" unless defined($self->{config}->get_versification_configurations);
#   return $self->{config}->get_versification_configurations;
# }

# Unique key representing the book this reference is from
sub key  { shift->{'reference'}{'data'}{'key'}; }
sub c    { shift->{'reference'}{'data'}{'c'};   }
sub v    { shift->{'reference'}{'data'}{'v'};   }

sub key2 { shift->{'reference'}{'data'}{'key2'}; }
sub c2   { shift->{'reference'}{'data'}{'c2'};   }
sub v2   { shift->{'reference'}{'data'}{'v2'};   }

sub ob   { shift->{'reference'}{'original'}{'b'};  }
sub ob2  { shift->{'reference'}{'original'}{'b2'}; }
sub oc   { shift->{'reference'}{'original'}{'c'};  }
sub oc2  { shift->{'reference'}{'original'}{'c2'}; }
sub ov   { shift->{'reference'}{'original'}{'v'};  }
sub ov2  { shift->{'reference'}{'original'}{'v2'}; }

sub s1   { shift->{'reference'}{'spaces'}{'s1'}; }
sub s2   { shift->{'reference'}{'spaces'}{'s2'}; }
sub s3   { shift->{'reference'}{'spaces'}{'s3'}; }
sub s4   { shift->{'reference'}{'spaces'}{'s4'}; }
sub s5   { shift->{'reference'}{'spaces'}{'s5'}; }
sub s6   { shift->{'reference'}{'spaces'}{'s6'}; }
sub s7   { shift->{'reference'}{'spaces'}{'s7'}; }
sub s8   { shift->{'reference'}{'spaces'}{'s8'}; }
sub s9   { shift->{'reference'}{'spaces'}{'s9'}; }
sub s10   { shift->{'reference'}{'spaces'}{'s10'}; }
sub book { 
    my $self = shift;
    return $self->get_regexes->book($self->key);
}
sub book2 { 
    my $self = shift;
    return $self->get_regexes->book($self->key2);
}
sub abbreviation  {
    my $self = shift;
    return $self->get_regexes->abbreviation($self->key);
}
sub abbreviation2  {
    my $self = shift;
    return $self->get_regexes->abbreviation($self->key2);
}
sub cvs           { shift->{'reference'}{'info'}{'cvs'}; }
sub dash          { shift->{'reference'}{'info'}{'dash'}; }

# Subroutines for book, abbreviation and key conversions
sub abbreviation2book {}
sub book2abbreviation {}
sub key2book {}
sub key2abbreviation {}
sub book2key {}
sub abbreviation2key {}

# Subroutines for setting
sub set_key   {
    my $self = shift; 
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'data'}{'key'} = $e; 
}
sub set_c     {
    my $self = shift;
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'data'}{'c'}   = $e; 
    $self->{'reference'}{'original'}{'c'}   = $e; 
}
sub set_v     {
    my $self = shift;
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'data'}{'v'}   = $e; 
    $self->{'reference'}{'original'}{'v'}   = $e; 
}

sub set_key2  {
    my $self = shift;
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'data'}{'key2'} = $e; 
}
sub set_c2    {
    my $self = shift; 
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'data'}{'c2'}   = $e; 
    $self->{'reference'}{'original'}{'c2'}   = $e; 
}
sub set_v2    {
    my $self = shift;
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'data'}{'v2'}   = $e;
    $self->{'reference'}{'original'}{'v2'}   = $e;  
}

sub set_b    {
    my $self = shift;
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'original'}{'b'}  = $e; 

    # Get the canonical key, bookname and abbreviation
 #   $self->{'reference'}{'data'}{'book'} = $self->get_regexes->book($e);
 #   $self->{'reference'}{'data'}{'abbreviation'} = $self->get_regexes->abbreviation($e);   
    my $key = $self->get_regexes->key($e);;
    unless (defined($key)) {
	print Dumper $self->{'regex'}{'book2key'};
	print Dumper $self->{'regex'}{'abbreviation2key'};
	croak "Key must be defined: $e\n";
    }
    $self->{'reference'}{'data'}{'key'} = $self->get_regexes->key($e);
}
sub set_b2   {
    my $self = shift;
    my $e = shift;
    return unless (_non_empty($e));

    $self->{'reference'}{'original'}{'b2'}  = $e; 
    $self->{'reference'}{'data'}{'key2'} = $self->get_regexes->key($e);
}

# Setors for spaces
# Ge 1:1-Ap 21:22
# This shows how each of the areas that have the potential
# for a space are defined.
# (s1)Ge(s2)1(s3):(s4)1(s5)-(s6)Ap(s7)21(s8):(s9)22(s10)
sub set_s1    {
    my $self = shift;
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'spaces'}{'s1'} = $e; 
}
sub set_s2    {
    my $self = shift; 
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'spaces'}{'s2'} = $e; 
}
sub set_s3    {
    my $self = shift; 
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'spaces'}{'s3'} = $e; 
}
sub set_s4    {
    my $self = shift; 
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'spaces'}{'s4'} = $e; 
}
sub set_s5    {
    my $self = shift; 
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'spaces'}{'s5'} = $e; 
}
sub set_s6    {
    my $self = shift; 
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'spaces'}{'s6'} = $e; 
}
sub set_s7    {
    my $self = shift;
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'spaces'}{'s7'} = $e; 
}
sub set_s8    {
    my $self = shift;
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'spaces'}{'s8'} = $e; 
}
sub set_s9    {
    my $self = shift;
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'spaces'}{'s9'} = $e; 
}
sub set_s10   {
    my $self = shift;
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'spaces'}{'s10'} = $e; 
}


sub set_cvs    {
    my $self = shift;
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'info'}{'cvs'} = $e; 
}
sub set_dash   {
    my $self = shift;
    my $e = shift;
    return unless (_non_empty($e));
    $self->{'reference'}{'info'}{'dash'} = $e; 
}

sub book_type {
    my $self = shift;
    return 'NONE' unless (_non_empty($self->ob));
    return 'CANONICAL_NAME' if ($self->ob =~ m/@{[$self->get_regexes->{'livres'}]}/);
    return 'ABBREVIATION' if ($self->ob =~ m/@{[$self->get_regexes->{'abbreviations'}]}/);
    return 'UNKNOWN';
}

sub formatted_book {
    my $self = shift;
    my $l = '';

    my $book_format = $self->get_configuration->get('reference', 'book_format') || 'ORIGINAL';

    if ($self->is_explicit && (_non_empty($book_format))) {
        if ($book_format eq 'CANONICAL_NAME' || (($book_format eq 'ORIGINAL') && ($self->book_type eq 'CANONICAL_NAME')) ) {
            $l  = $self->book;
        } elsif ($book_format eq 'ABBREVIATION' || (($book_format eq 'ORIGINAL') && ($self->book_type eq 'ABBREVIATION'))) {
            $l  = $self->abbreviation;
        } else {
            carp "Book_format is undefined.  Using the ORIGINAL book name or abbreviation found\n";
        } 
    }

    return $l;
} 

sub formatted_book2 {
    my $self = shift;
    my $l = '';

    my $book_format = $self->get_configuration->get('reference', 'book_format') || 'ORIGINAL';

    if ($self->is_explicit && (_non_empty($book_format))) {
        if ($book_format eq 'CANONICAL_NAME' || (($book_format eq 'ORIGINAL') && ($self->book_type eq 'CANONICAL_NAME')) ) {
            $l = $self->book2;
        } elsif ($book_format eq 'ABBREVIATION' || (($book_format eq 'ORIGINAL') && ($self->book_type eq 'ABBREVIATION'))) {
            $l = $self->abbreviation2;
        } else {
            carp "Book_format is undefined.  Using the ORIGINAL book name or abbreviation found\n";
        } 
    }

    return $l;
} 


sub set {
    my $self = shift;
    my $r = shift;

    # $r must be a defined hash
    return unless(defined($r) && ref($r) eq 'HASH');

    # Set the main part of the reference
    $self->set_b($r->{b});  # Match Book
    $self->set_c($r->{c});   # Chapter
    $self->set_v($r->{v});   # Verse

    # Set the range part of the reference    
    $self->set_b2($r->{b2}); # Match Book
    $self->set_c2($r->{c2});  # Chapter
    $self->set_v2($r->{v2});  # Verse

    # Set the formatting and informational parts
    $self->set_cvs($r->{cvs});   # The Chapter Verse Separtor
    $self->set_dash($r->{dash}); # The reference range operator

    # If this is a book with only one chapter then be sure that chapter is set to '1'
    if(((defined($self->book) && $self->book =~ m/@{[$self->get_regexes->{'livres_avec_un_chapitre'}]}/) ||
       (defined($self->abbreviation) && $self->abbreviation =~ m/@{[$self->get_regexes->{'livres_avec_un_chapitre'}]}/)) &&
	!(defined($self->c) && defined($self->c) && $self->c eq '1')) {
	$self->set_v($self->c);   # Chapter
	$self->set_c('1');   # Chapter
	$self->set_cvs(':');   # Chapter
    }

    # Set the spaces
    # (s1)Ge(s2)1(s3):(s4)1(s5)-(s6)Ap(s7)21(s8):(s9)22(s10)
    $self->set_s1($r->{s1});
    $self->set_s2($r->{s2});
    $self->set_s3($r->{s3});
    $self->set_s4($r->{s4});
    $self->set_s5($r->{s5});
    $self->set_s6($r->{s6});
    $self->set_s7($r->{s7});
    $self->set_s8($r->{s8});
    $self->set_s9($r->{s9});
    $self->set_s10($r->{s10});
}

# Subroutines related to setting information
sub setold {
    my ($self, $r, $oldref) = @_;
    my $context = (_non_empty($oldref)) ? $oldref->get_reference_hash : undef;
#    my $refconfig = $self->reference_config;
    my $regex = $self->get_regexes;
    my %reference = ();

    # Set the Versification that was assumed when the reference was read in and parsed
    # $reference{versification} = $self->config->get('versification', 'source');
    
    # Voici les paramètres par défaut pour une référence
    $reference{book} = _setor( $regex->book($r->{l}), $context->{book} );
    $reference{abbreviation} = _setor( $regex->abbreviation($r->{l}), $context->{abbreviation} );
    $reference{key} = _setor( $regex->key($r->{l}), $context->{key} );
    $reference{l}  = _setor( $r->{l}, $context->{l} );
    $reference{c}  = _setor( $r->{c}, $context->{c} );
    $reference{cr} = _setor( $r->{cr} );
    $reference{v}  = _setor( $r->{v}  );
    $reference{vr} = _setor( $r->{vr} );

    # If the context reference has l2, c2 or cr parts, use them as the context
    # For example, when using the reference 'Ps 34:2-35:3' and combining it with verse '5'
    # the result should be 'Ps 35:5'  The c2 part (35) is used rather than the c part (34).
    if ($self->state_is_verset($r)) {
        $reference{c} = _setor( $context->{c2}, $context->{cr}, $reference{c} );
        $reference{book} = _setor( $context->{book2}, $context->{book} );
        $reference{abbreviation} = _setor( $context->{abbreviation2}, $context->{abbreviation} );
        $reference{key} = _setor( $context->{key2}, $context->{key} );
        $reference{l}  = _setor( $context->{l2},  $context->{l} ); 
    }

    if ($self->state_is_chapitre($r)) {
        $reference{book} = _setor( $context->{book2}, $context->{book} );
        $reference{abbreviation} = _setor( $context->{abbreviation2}, $context->{abbreviation} );
        $reference{key}  = _setor( $context->{key2}, $context->{key} );
        $reference{l}    = _setor( $context->{l2}, $context->{l} ); 
    }

    # If this is a reference with a book with only one chapter like 'Jude 10', then the '10' which
    # is not a chapter, but rather a verse.  Also set the chapter to '1'.
    if(defined($reference{book}) && $reference{book} =~ m/$regex->{'livres_avec_un_chapitre'}/) {
	$reference{vr} = $reference{cr};
	$reference{cr} = ''; 
	$reference{v} =  $reference{c} if ($reference{v} eq '');
	$reference{c} = 1;
    }

    # $reference{cvs}  = (defined($r->{cvs})  ? $r->{cvs}  : '');
    # $reference{cvs2} = (defined($r->{cvs2}) ? $r->{cvs2} : '');

    $reference{book2} = _setor( $regex->book($r->{l2}) );
    $reference{abbreviation2} = _setor( $regex->abbreviation($r->{l2}) );
    $reference{key2} = _setor( $regex->key($r->{l2}), $context->{key2} );
    $reference{l2}  = _setor( $r->{l2} ); 
    
    $reference{c2}  = (defined($r->{c2})  ? $r->{c2}  : '');
    $reference{cr2} = (defined($r->{cr2}) ? $r->{cr2} : '');
    $reference{v2}  = (defined($r->{v2})  ? $r->{v2}  : '');
    $reference{vr2} = (defined($r->{vr2}) ? $r->{vr2} : '');

    # Les Espaces for the first reference
    $reference{hs} = (defined($r->{hs})   ? $r->{hs} : '');
    $reference{a}  = (_non_empty($r->{a})) ? $r->{a}  : (defined($context->{a}) ? $context->{a} : '');
    $reference{b}  = (_non_empty($r->{b})) ? $r->{b}  : '';
    $reference{d}  = (_non_empty($r->{d})) ? $r->{d}  : '';

    # Les Espaces for the second reference
    $reference{hs2} = (defined($r->{hs2}) ? $r->{hs2} : '');
    $reference{a2}  = (defined($r->{a2})  ? $r->{a2}   : '');
    $reference{b2}  = (defined($r->{b2})  ? $r->{b2}   : '');
    $reference{d2}  = (defined($r->{d2})  ? $r->{d2}   : '');

#    ($reference{c}, $reference{dash}, $reference{c2}) = split(/([-–?])/, $r->{cr})  if (_non_empty($r->{cr})); 
#    ($reference{v}, $reference{dash}, $reference{v2}) = split(/([-–?])/, $r->{vr})  if (_non_empty($r->{vr})); 

    if(defined($reference{book2}) && $reference{book2} =~ m/$regex->{'livres_avec_un_chapitre'}/) {
	$reference{v2} =  $reference{c2} if ($reference{v2} eq '');
	$reference{c2} = 1;
    }

    # $reference{cvs} = (_non_empty($reference{c}) && _non_empty($reference{v})) ?
    # 	_non_empty($refconfig->get('cvs')) ? 
    # 	$refconfig->get('cvs') :
    # 	_non_empty($reference{cvs}) ?
    # 	$reference{cvs} :
    # 	':'
    # 	: '';

    # $reference{cvs2} = (_non_empty($reference{c2}) && _non_empty($reference{v2})) ?
    # 	_non_empty($refconfig->get('cvs')) ? 
    # 	$refconfig->get('cvs') :
    # 	_non_empty($reference{cvs2}) ?
    # 	$reference{cvs2} :
    # 	':'
    # 	: '';

    # $reference{dash}   = (_non_empty($reference{c2}) || _non_empty($reference{v2}))  ? '-' : ''; 
    # $reference{cdash}  = (_non_empty($reference{c})  && _non_empty($reference{cr}))  ? '-' : ''; 
    # $reference{vdash}  = (_non_empty($reference{v})  && _non_empty($reference{vr}))  ? '-' : ''; 
    # $reference{cdash2} = (_non_empty($reference{c2}) && _non_empty($reference{cr2})) ? '-' : ''; 
    # $reference{vdash2} = (_non_empty($reference{v2}) && _non_empty($reference{vr2})) ? '-' : ''; 

    # $reference{uses_complete_book_name} = $regex->uses_complete_book_name(_setor($reference{l})) || $context->ref_config->get('uses_complete_book_name');
    
    # 'uses_complete_book_name' specifies whether a reference uses an ABBREVIATION like 'Mt', a COMPLETE_NAME
    # like 'Matthieu' or NONE like 'chapters 5-6'

    # Set NONE by default
    $reference{bookname_type} = 'NONE';

    # If not empty then use  $reference{l}'s type
    my $type = $regex->bookname_type($reference{l});
    if ( _non_empty($type) ) {
	$reference{bookname_type} = $type;
    } elsif ( defined($context) ) {
	# Otherwise is $context is defined uses it's booktype
	$reference{bookname_type} = $context->ref_config->get('bookname_type')
    }

    $self->{'reference'} = \%reference; 
}


##################################################################################
# Reference Parsing
##################################################################################
sub parse {
    my $self = shift; 
    my $token = shift;
    my $state = shift;

    my $r = $self->get_regexes;
    my $spaces = '[\s ]*';
    
    # type: LCVLCV
    if ($token =~ m/($spaces)($r->{'livres_et_abbreviations'})($spaces)($r->{'chapitre'})($spaces)($r->{'cv_separateur'})($spaces)($r->{'verset'})($spaces)($r->{'intervale'})($spaces)($r->{'livres_et_abbreviations'})($spaces)($r->{'chapitre'})($spaces)($r->{'cv_separateur'})($spaces)($r->{'verset'})($spaces)/x) {
        $state = 'match';
        $self->set({s1=>$1, b=>$2, s2=>$3, c=>$4, s3=>$5, cvs=>$6, s4=>$7, v=>$8, s5=>$9, dash=>$10, s6=>$11, b2=>$12, s7=>$13, c2=>$14, s8=>$15, s9=>$17, v2=>$18, s10=>$19});
    }   
 
      # (s1)Ge(s2)1(s3):(s4)1(s5)-(s6)Ap(s7)21(s8):(s9)22(s10)
    # type: LCVLC
    elsif ($token =~ m/($spaces)($r->{'livres_et_abbreviations'})($spaces)($r->{'chapitre'})($spaces)($r->{'cv_separateur'})($spaces)($r->{'verset'})($spaces)($r->{'intervale'})($spaces)($r->{'livres_et_abbreviations'})($spaces)($r->{'chapitre'})($spaces)/x) {
	$state = 'match';
	$self->set({ s1=>$1, b=>$2, s2=>$3, c=>$4, s3=>$5, cvs=>$6, s4=>$7, v=>$8, s5=>$9, dash=>$10, s6=>$11, b2=>$12, s7=>$13, c2=>$14, s8=>$15 });
    }

    # (s1)Ge(s2)1(s3):(s4)1(s5)-(s6)Ap(s7)21(s8):(s9)22(s10)
    # type: LCLCV
    elsif ($token =~ m/($spaces)($r->{'livres_et_abbreviations'})($spaces)($r->{'chapitre'})($spaces)($r->{'intervale'})($spaces)($r->{'livres_et_abbreviations'})($spaces)($r->{'chapitre'})($spaces)($r->{'cv_separateur'})($spaces)($r->{'verset'})($spaces)/x) {
	$state = 'match';
        $self->set({ s1=>$1, b=>$2, s2=>$3, c=>$4, s3=>$5, dash=>$6, s6=>$7, b2=>$8, s7=>$9, c2=>$10, s8=>$11, cvs=>$12, s9=>$13, v2=>$14, s10=>$15 });
    }

    # type: LCVCV
    elsif ($token =~ m/($spaces)($r->{'livres_et_abbreviations'})($spaces)($r->{'chapitre'})($spaces)($r->{'cv_separateur'})($spaces)($r->{'verset'})($spaces)($r->{'intervale'})($spaces)($r->{'chapitre'})($spaces)($r->{'cv_separateur'})($spaces)($r->{'verset'})($spaces)/x) {
	$state = 'match';
        $self->set({ s1=>$1, b=>$2, s2=>$3, c=>$4, s3=>$5, cvs=>$6, s4=>$7, v=>$8, s5=>$9, dash=>$10, s6=>$11, c2=>$12, s8=>$13, s9=>$15, v2=>$16, s10=>$17 });
    }

    # (s1)Ge(s2)1(s3):(s4)1(s5)-(s6)Ap(s7)21(s8):(s9)22(s10)
    # type: LCLC
    elsif ($token =~ m/($spaces)($r->{'livres_et_abbreviations'})($spaces)($r->{'chapitre'})($spaces)($r->{'intervale'})($spaces)($r->{'livres_et_abbreviations'})($spaces)($r->{'chapitre'})($spaces)/x) {
	$state = 'match';
	$self->set({ s1=>$1, b=>$2, s2=>$3, c=>$4, s3=>$5, dash=>$6, s6=>$7, b2=>$8, s7=>$9, c2=>$10, s8=>$11 });
    }

    # type: LCCV
    elsif ($token =~ m/($spaces)($r->{'livres_et_abbreviations'})($spaces)($r->{'chapitre'})($spaces)($r->{'intervale'})($spaces)($r->{'chapitre'})($spaces)($r->{'cv_separateur'})($spaces)($r->{'verset'})($spaces)/x) {
        $state = 'match';
        $self->set({s1=>$1, b=>$2, s2=>$3, c=>$4, s3=>$5, dash=>$6, s6=>$7, c2=>$8, s8=>$9, cvs=>$10, s9=>$11, v2=>$12, s10=>$13});
    }  

    # type: LCVV
    elsif ($token =~ m/($spaces)($r->{'livres_et_abbreviations'})($spaces)($r->{'chapitre'})($spaces)($r->{'cv_separateur'})($spaces)($r->{'verset'})($spaces)($r->{'intervale'})($spaces)($r->{'verset'})($spaces)/x) {
        $state = 'match';
        $self->set({s1=>$1, b=>$2, s2=>$3, c=>$4, s3=>$5, cvs=>$6, s4=>$7, v=>$8, s5=>$9, dash=>$10, s6=>$11, v2=>$12, s7=>$13});
    }

    # type: LCV
    elsif ($token =~ m/($spaces)($r->{'livres_et_abbreviations'})($spaces)($r->{'chapitre'})($spaces)($r->{'cv_separateur'})($spaces)($r->{'verset'})($spaces)/x) {
        $state = 'match';
        $self->set({s1=>$1, b=>$2, s2=>$3, c=>$4, s3=>$5, cvs=>$6, s4=>$7, v=>$8, s5=>$9});
    } 

    # type: LCC
    elsif ($token =~ m/($spaces)($r->{'livres_et_abbreviations'})($spaces)($r->{'chapitre'})($spaces)($r->{'intervale'})($spaces)($r->{'chapitre'})($spaces)/x) {
        $state = 'match';
        $self->set({s1=>$1, b=>$2, s2=>$3, c=>$4, s3=>$5, dash=>$6, s6=>$7, c2=>$8, s7=>$9});
    }

    # type: LC
    elsif ($token =~ m/($spaces)($r->{'livres_et_abbreviations'})($spaces)($r->{'chapitre'})($spaces)/x) {
        $state = 'match';
        $self->set({s1=>$1, b=>$2, s2=>$3, c=>$4, s3=>$5});
    } else {
            $self->parse_chapitre($token, $state);
    } 
    return $self;
}

sub parse_chapitre {
    my $self = shift; 
    my $token = shift;
    my $state = shift;
    my $r = $self->get_regexes;
    my $spaces = '[\s ]*';

    # We are here!

    # (s1)Ge(s2)1(s3):(s4)1(s5)-(s6)Ap(s7)21(s8):(s9)22(s10)
    # type: CVCV
    if ($token =~ m/($spaces)($r->{'chapitre'})($spaces)($r->{'cv_separateur'})($spaces)($r->{'verset'})($spaces)($r->{'intervale'})($spaces)($r->{'chapitre'})($spaces)($r->{'cv_separateur'})($spaces)($r->{'verset'})($spaces)/x) {
        $state = 'match';
        $self->set({ s2=>$1, c=>$2, s3=>$3, cvs=>$4, s4=>$5, v=>$6, s5=>$7, dash=>$8, s6=>$9, c2=>$10, s8=>$11, s9=>$13, v2=>$14, s10=>$15 });
    } 

    # type: CCV
    elsif ($token =~ m/($spaces)($r->{'chapitre'})($spaces)($r->{'intervale'})($spaces)($r->{'chapitre'})($spaces)($r->{'cv_separateur'})($spaces)($r->{'verset'})($spaces)/x) {
        $state = 'match';
        $self->set({ s2=>$1, c=>$2, s3=>$3, dash=>$4, s6=>$5, c2=>$6, s8=>$7, cvs=>$8, s9=>$9, v2=>$10, s10=>$11 });
    } 

    # type: CVV
    elsif ($token =~ m/($spaces)($r->{'chapitre'})($spaces)($r->{'cv_separateur'})($spaces)($r->{'verset'})($spaces)($r->{'intervale'})($spaces)($r->{'verset'})($spaces)/x) {
        $state = 'match';
        $self->set({ s2=>$1, c=>$2, s3=>$3, cvs=>$4, s4=>$5, v2=>$6, s5=>$7, dash=>$8, s6=>$9, v2=>$10, s7=>$11 });
    } 

    # type: CV
    elsif ($token =~ m/([\s ]*)($r->{'chapitre'})([\s ]*)($r->{'cv_separateur'})([\s ]*)($r->{'verset'})([\s ]*)/x) {
        $state = 'match';
        $self->set({ s2=>$1, c=>$2, s3=>$3, cvs=>$4, s4=>$5, v2=>$6, s5=>$7, dash=>$8, s6=>$9, v2=>$10, s7=>$11 });
    }

    # type: CC
    elsif ($token =~ m/($spaces)($r->{'chapitre'})($spaces)($r->{'intervale'})($spaces)($r->{'chapitre'})($spaces)/ && $state eq CHAPTER) {
    # elsif ($token =~ m/($spaces)($r->{'chapitre'})($spaces)($r->{'intervale'})($spaces)($r->{'chapitre'})($spaces)/) {
        $state = 'match';
        $self->set({ s2=>$1, c=>$2, s3=>$3, dash=>$4, s6=>$5, c2=>$6, s7=>$7 });
    } 

    # type: C
    elsif ($token =~ m/([\s ]*)($r->{'chapitre'})([\s ]*)/ && $state eq CHAPTER) {
    # elsif ($token =~ m/([\s ]*)($r->{'chapitre'})([\s ]*)/) {
        $state = 'match';
        $self->set({ s2=>$1, c=>$2, s3=>$3 });
    } 

    # Cet un Verset
    else {
        $self->parse_verset($token, $state);
    }
}

sub parse_verset {
    my $self = shift; 
    my $token = shift;
    my $state = shift;
    my $r = $self->get_regexes;

    my $spaces = '[\s ]*';

    unless (defined($state)) {
        carp "\n\n$token: " .__LINE__ ."\n\n";
    }
    # (s1)Ge(s2)1(s3):(s4)1(s5)-(s6)Ap(s7)21(s8):(s9)22(s10)    
    # type: VV
    if ($token =~ m/($spaces)($r->{'verset'})($spaces)($r->{'intervale'})($spaces)($r->{'verset'})($spaces)/ && $state eq VERSE) {
        $state = 'match';
        $self->set({s2=>$1, v=>$2, s5=>$3, dash=>$4, s6=>$5, v2=>$6, s10=>$7});
    }
    
    # type: V
    elsif ($token =~ m/([\s ]*)($r->{'verset'})([\s ]*)/ && $state eq VERSE) {
        $state = 'match';
        $self->set({s2=>$1, v=>$2, s5=>$3});
    } 

    # Error
    else {
        $self->set({type => 'Error'});
    }
}

################################################################################
# Format Section
# This section provides a default normalize form that is useful for various
# operations with references
################################################################################
sub normalize {
    my $self = shift;
    my $ba = shift || 'ORIGINAL';
    my $ret = '';

    if ($ba eq 'ABBREVIATION' || ($ba eq 'ORIGINAL' && $self->book_type eq 'ABBREVIATION')) {
	$ret .= $self->abbreviation || '';
    } else {
	$ret .= $self->book || '';
    }
    $ret .= $self->s2 || '';
    $ret .= $self->c || '';
    $ret .= (_non_empty($self->c) && _non_empty($self->v)) ? $self->cvs : '';
    $ret .= $self->v || '';
    $ret .= $self->dash || '';

    if ($ba eq 'ABBREVIATION' || ($ba eq 'ORIGINAL' && $self->book_type eq 'ABBREVIATION')) {
	$ret .= $self->abbreviation2 || '';
    } else {
	$ret .= $self->book2 || '';
    }

    $ret .= $self->s7 || '';
    $ret .= $self->c2 || '';
    $ret .= (_non_empty($self->c2) && _non_empty($self->v2)) ? $self->cvs : '';
    $ret .= $self->v2 || '';
    return $ret;
}


##################################################################################
# State Helpers 
#
# The context of a reference refers to the first part of it defined...
# For example: 'Ge 1:1' has its book, chapter and verse parts defined. So its 
#              state is 'explicit'  This means it is a full resolvable reference 
#              '10:1' has its chapter and verse parts defined. So its 
#               context is 'chapitre' 
#              'v. 1' has its verse part defined. So its context is 'verset' 
# 
##################################################################################
sub n { 
    my $self = shift;
    return $self->normalize;
}

sub state_is_verset {
    my $self = shift;
    my $r = shift || $self->reference;
    
    return _non_empty($r->{v}) && !_non_empty($r->{c}) && !$self->is_explicit($r);
}

sub state_is_chapitre {
    my $self = shift;
    my $r = shift || $self->reference;
    
    return _non_empty($r->{c}) && !$self->is_explicit($r);
}

sub state_is_book {
    my $self = shift;
    return $self->is_explicit;
}

sub state {
    my $self = shift;
    return 'BOOK'    if $self->state_is_book;
    return 'CHAPTER' if $self->state_is_chapitre;
    return 'VERSE'   if $self->state_is_verset;
    return 'UNKNOWN';
}

sub is_explicit {
    my $self = shift;
    # Explicit reference must have a book and a chapter
    return (_non_empty($self->key) && _non_empty($self->c));
}

########################################################################
# Helper Functions
#

sub has_interval {
    my $self = shift;
    return (defined($self->key2) || defined($self->c2) || defined($self->v2));
}

sub begin_interval_reference {
    my $self = shift;
    my $ret = new Religion::Bible::Regex::Reference($self->get_configuration, $self->get_regexes); 

    $ret->set({ b => $self->ob, 
		c => $self->oc, 
		v => $self->ov, 
		s1 => $self->s1, s2 => $self->s2, 
		s3 => $self->s3, s4 => $self->s4, 
		s5 => $self->s5, cvs => $self->cvs });

    return $ret;
}
sub end_interval_reference {
    my $self = shift;
    my $ret = new Religion::Bible::Regex::Reference($self->get_configuration, $self->get_regexes); 

    my ($b, $c, $s7);

    if (!defined($self->ob2) && (defined($self->oc2) || defined($self->ov2) )) {
	$b = $self->ob;
	$s7 = $self->s2;
    } else {
	$b = $self->ob2;
	$s7 = $self->s7;
    }

    if (!defined($self->oc2) && ( defined($self->ov2) )) {
	$c = $self->oc;
    } else {
	$c = $self->oc2;
    }
    
    return unless (_non_empty($b) || _non_empty($c) || _non_empty($self->ov2));

    $ret->set({ b => $b,
		c => $c, 
		v => $self->ov2, 
		s1 => $self->s6, s2 => $s7,
		s3 => $self->s8, s4 => $self->s9, 
		s5 => $self->s10, cvs => $self->cvs });

    return $ret;
}

sub interval {
    my $r1 = shift;
    my $r2 = shift;
    
    # References must not be empty
    return unless (_non_empty($r1));
    return unless (_non_empty($r2));

    # To be comparable both references must have the same state
    # ex. 'Ge 1:1' may not be compared to 'chapter 2' or 'v. 4'
    unless ($r1->state eq $r2->state) {
	carp "Attempted to compare two reference that do no have the same state: " . $r1->normalize . " and " . $r2->normalize . "\n";
	return;
    }
    
    my $min = $r1->begin_interval_reference->min($r1->end_interval_reference, $r2->begin_interval_reference, $r2->end_interval_reference);
    my $max = $r1->begin_interval_reference->max($r1->end_interval_reference, $r1->begin_interval_reference, $r2->end_interval_reference);

    my $ret = new Religion::Bible::Regex::Reference($r1->get_configuration, $r1->get_regexes);

    $ret->set({ b => $min->formatted_book, c => $min->c, v => $min->v, 
		b2 => $max->formatted_book, c2 => $max->c, v2 => $max->v2 || $max->v,
		cvs => $min->cvs || $max->cvs, dash => '-',
		s1 => $min->s1, s2 => $min->s2, 
		s3 => $min->s3, s4 => $min->s4, 
		s5 => $min->s5, s6 => $max->s1, 
		s7 => $max->s2, s8 => $max->s3,
		s9 => $max->s4, s10 => $max->s5,
 });

    return $ret;
}
sub min {
    my $self = shift;
    my @refs = @_; 
    my $ret = $self;

    foreach my $r (@refs) {
#	next unless (defined(ref $r));
        if ($ret->gt($r)) {
            $ret = $r;
        }
    }
    return $ret;
} 

sub max {
    my $self = shift;
    my @refs = @_; 
    my $ret = $self;

    foreach my $r (@refs) {
        if ($ret->lt($r)) {
            $ret = $r;
        }
    }
    return $ret;
} 

# References must be of the forms LCV, CV or V
sub compare {
    my $r1 = shift;
    my $r2 = shift;
    
    # References must not be empty
    return unless (_non_empty($r1));
    return unless (_non_empty($r2));

    # To be comparable both references must have the same state
    # ex. 'Ge 1:1' may not be compared to 'chapter 2' or 'v. 4'
    unless ($r1->state eq $r2->state) {
	carp "Attempted to compare two reference that do no have the same state: " . $r1->normalize . " and " . $r2->normalize . "\n";
	return;
    }

    # Messy logic that compares two references with a context of 'BOOK' 
    # ex. 
    # ('Ge 1:1' and 'Ge 2:1'), ('Ge 1:1' and 'Ge 2'), ('Ge 1' and 'Ge 2:1'), ('Ge 1' and 'Ge 2')   
    # ('Ge 1:1' and 'Ex 2:1'), ('Ge 1:1' and 'Ex 2'), ('Ge 1' and 'Ex 2:1'), ('Ge 1' and 'Ex 2')   
    # ('Ex 1:1' and 'Ge 2:1'), ('Ex 1:1' and 'Ge 2'), ('Ex 1' and 'Ge 2:1'), ('Ex 1' and 'Ge 2')   
    if (defined($r1->key) && defined($r2->key)) {
	if (($r1->key + 0 <=> $r2->key + 0) == 0) {
	    if (defined($r1->c) && defined($r2->c)) {
		if (($r1->c + 0 <=> $r2->c + 0) == 0) {
		    if (defined($r1->v) && defined($r2->v)) {
			return ($r1->v + 0 <=> $r2->v + 0);
		    } else {
			return ($r1->c + 0 <=> $r2->c + 0);
		    }
		} else {
		    return ($r1->c + 0 <=> $r2->c + 0);
		}
	    } else {
		return ($r1->key + 0 <=> $r2->key + 0);
	    }
	} else {
	    return ($r1->key + 0 <=> $r2->key + 0);
	}	
    } 
    # Messy logic that compares two references with a context of 'CHAPTER' 
    # ex.  ('1:1' and '2:1'), ('1:1' and '2'), ('1' and '2:1'), ('1' and '2')
    else {
	if (defined($r1->c) && defined($r2->c)) {
	    if (($r1->c + 0 <=> $r2->c + 0) == 0) {
		if (defined($r1->v) && defined($r2->v)) {
		    return ($r1->v + 0 <=> $r2->v + 0);
		} else {
		    return ($r1->c + 0 <=> $r2->c + 0);
		}
	    } else {
		return ($r1->c + 0 <=> $r2->c + 0);
	    }
	} else {
	    if (defined($r1->v) && defined($r2->v)) {
		return ($r1->v + 0 <=> $r2->v + 0);
	    } else {
		return ($r1->c + 0 <=> $r2->c + 0);
	    }
	}
    }

#    return 1 if ((defined($r1->key) && defined($r2->key)) && ($r1->key + 0 > $r2->key + 0));
#    return 1 if ((defined($r1->c) && defined($r2->c)) && ($r1->c + 0 > $r2->c + 0));
#    return 1 if ((defined($r1->v) && defined($r2->v)) && ($r1->v + 0 > $r2->v + 0));
    return;
}
sub gt {
    my $r1 = shift;
    my $r2 = shift;
    
    # References must not be empty
    return unless (_non_empty($r1));
    return unless (_non_empty($r2));

    # To be comparable both references must have the same state
    # ex. 'Ge 1:1' may not be compared to 'chapter 2' or 'v. 4'
    unless ($r1->state eq $r2->state) {
	carp "Attempted to compare two reference that do no have the same state: " . $r1->normalize . " and " . $r2->normalize . "\n";
	return;
    }

    ($r1->compare($r2) == -1) ? return : return 1;

}
sub lt {
    my $r1 = shift;
    my $r2 = shift;
    
    # References must not be empty
    return unless (_non_empty($r1));
    return unless (_non_empty($r2));

    # To be comparable both references must have the same state
    # ex. 'Ge 1:1' may not be compared to 'chapter 2' or 'v. 4'
    unless ($r1->state eq $r2->state) {
	carp "Attempted to compare two reference that do no have the same state: " . $r1->normalize . " and " . $r2->normalize . "\n";
	return;
    }

    my $ret = $r1->compare($r2);
    ($ret == 1) ? return : return 1;

}

sub _non_empty {
    my $value = shift;
    return (defined($value) && $value ne '');
}  

# Returns the first _non_empty value or ''
sub _setor {
    foreach my $v (@_) {
        return $v if _non_empty($v);
    }
    
    # if no value is given the default should be a empty string
    return '';
}

1; # Magic true value required at end of module
__END__

=head1 NAME

Religion::Bible::Regex::Reference -  this Perl object represents a Biblical reference along with the functions that can be applied to it.


=head1 VERSION

This document describes Religion::Bible::Regex::Reference version 0.8


=head1 SYNOPSIS

=over 4

  use Religion::Bible::Regex::Config;
  use Religion::Bible::Regex::Builder;
  use Religion::Bible::Regex::Reference;

  # $yaml_config_file is either a YAML string or the path to a YAML file
  $yaml_config_file = 'config.yml';

  my $c = new Religion::Bible::Regex::Config($yaml_config_file);
  my $r = new Religion::Bible::Regex::Builder($c);
  my $ref = new Religion::Bible::Regex::Reference($r, $c);
    
  $ref->parse('Ge 1:1');

=back

=head1 DESCRIPTION

This class is meant as a building block to enable people and publishing houses 
to build tools for processing documents which contain Bible references.

This is the main class for storing state information about a Bible reference and
can be used to build scripts that perform a variety of useful operations.  
For example, when preparing a Biblical commentary in electronic format a publishing 
house can save a lot of time and manual labor by creating scripts that do 
the following:

=over 4

=item * Automatically find and tag Bible references

=item * Find invalid Bible references

=item * Check that the abbreviations used are consistent throughout the entire book.

=item * Create log files of biblical references that need to be reviewed by a person.

=back

This class is meant to be a very general-purpose so that any type of tool that needs to manipulate Bible references can use it.


=head1 Bible Reference Types

Bible references can be classified into a few different patterns.

Since this code was originally written and commented in French, we've retained
the French abbreviations for these different Bible reference types. 

=over 4

    'L' stands for 'Livre'    ('Book' in English)
    'C' stands for 'Chapitre' ('Chapter' in English)
    'V' stands for 'Verset'   ('Verse' in English)

=back

Here are the different Bible reference types with an example following each one:

=over 4

    # Explicit Bible Reference Types
    LCVLCV Ge 1:1-Ex 1:1
    LCVCV  Ge 1:1-2:1
    LCCV   Ge 1-2:5
    LCVV   Ge 1:2-5
    LCV    Ge 1:1
    LCC    Ge 1-12
    LC     Ge 1        
            
    # Implicit Bible Reference Types
    CVCV   1:1-2:1
    CCV    1-2:5
    CVV    1:2-5
    CV     1:1
    CC     1-12
    C      1
    VV     1-5
    V      1

=back

=head2 Explicit and Implicit Bible Reference Types	

We say the Bible reference is explicit when it has enough information within the 
reference to identify an exact location within the Bible. See above for examples.

We say that a Bible reference is implicit when the reference itself does not 
contain enough information to find its location in the Bible. often times within 
a commentary we will find implicit Bible references that use the context of the text
to identify the Bible reference.

    in Chapter 4
    in verse 17
    see 4:17
    as we see in chapter 5

=head1 INTERFACE 

=head2 new

Creates a new Religion::Bible::Regex::Reference. Requires two parameters a Religion::Bible::Regex::Config object and a Religion::Bible::Regex::Regex object

=head2 get_configuration

Returns the Religion::Bible::Regex::Config object used by this reference.

=head2 get_regexes

Returns the Religion::Bible::Regex::Builder object used by this reference.

=head2 get_reference_hash

Returns the hash that contains all of the parts of the current Bible reference.

=head2 is_explicit

Returns true if all the information is there to reference an exact verse or verses in the Bible.

=head2 set

=head2 key 
=head2 c   
=head2 v   

=head2 key2 
=head2 c2   
=head2 v2   

=head2 ob
=head2 ob2
=head2 oc  
=head2 oc2 
=head2 ov  
=head2 ov2 

=head2 s1 
=head2 s2 
=head2 s3 
=head2 s4 
=head2 s5 
=head2 s6 
=head2 s7 
=head2 s8 
=head2 s9 

=head2 book          
=head2 book2         
=head2 abbreviation  
=head2 abbreviation2 
=head2 cvs           
=head2 dash  

=head2 set_key 
=head2 set_c   
=head2 set_v   

=head2 set_key2 
=head2 set_c2   
=head2 set_v2   

=head2 set_b  
=head2 set_b2 
=head2 set_oc  
=head2 set_oc2 
=head2 set_ov  
=head2 set_ov2 
=head2 set_cvs  
=head2 set_dash 

=head2 set_s1 
=head2 set_s2 
=head2 set_s3 
=head2 set_s4 
=head2 set_s5 
=head2 set_s6 
=head2 set_s7 
=head2 set_s8 
=head2 set_s9 
    
=head2 abbreviation2book
=head2 abbreviation2key
=head2 book2abbreviation
=head2 book2key
=head2 book_type
=head2 formatted_book
=head2 formatted_book2
=head2 key2abbreviation
=head2 key2book
=head2 reference
=head2 set_b
=head2 set_b2
=head2 set_cvs
=head2 set_dash
=head2 set_s10
=head2 setold
=head3 normalize

Requires a hash of values to initalize the Bible reference. Optional argument a previous reference which can provide context for initializing a reference

=head2 state_is_verset

Returns true if the current the state is VERSE

=head2 state_is_chapitre

Returns true if the current the state is CHAPTER

=head2 state_is_book   

Returns true if the current the state is BOOK

=head2	begin_interval_reference
=head2 	has_interval
=head2 parse

=head2 parse_chapitre

=head2 parse_verset

=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
Religion::Bible::Regex::Reference requires no configuration files or environment variables.

=head1 DEPENDENCIES

=over 4

=item * Religion::Bible::Regex::Config

=item * Religion::Bible::Regex::Builder

=back

=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-religion-bible-regex-reference@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Daniel Holmlund  C<< <holmlund.dev@gmail.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Daniel Holmlund C<< <holmlund.dev@gmail.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

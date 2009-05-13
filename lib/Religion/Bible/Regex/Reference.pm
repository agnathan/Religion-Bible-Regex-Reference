#!/usr/bin/perl -w
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

use constant BOOK    => 'BOOK';
use constant CHAPTER => 'CHAPTER';
use constant VERSE   => 'VERSE'; 
use constant UNKNOWN => 'UNKNOWN';
use constant TRUE => 1;
use constant FALSE => 0;

sub new {    
    my ($class, $regex, $config) = @_;
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

# These get functions are here so that I can eliminate silent errrors.
# If the variable asked for is not found we 'confess' it

sub get_regexes {
  my $self = shift;
  confess "regex is not defined in ReferenceBiblique::Versification\n" unless defined($self->{regex});
  return $self->{regex};
}

sub get_configuration {
  my $self = shift;
  confess "config is not defined in ReferenceBiblique::Versification\n" unless defined($self->{config});
  return $self->{config};
}

sub _reference_hash {
    return shift->{'reference'};
}
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

sub set {
    my ($self, $r, $oldref) = @_;
    my $context = (_non_empty($oldref)) ? $oldref->_reference_hash : undef;
#    my $refconfig = $self->reference_config;
    my $regex = $self->get_regexes;
    my %reference = ();

    # Set the Versification that was assumed when the reference was read in and parsed
#    $reference{versification} = $self->config->get('versification', 'source');
    
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
        $reference{key} = _setor( $context->{key2}, $context->{key} );
        $reference{l}  = _setor( $context->{l2}, $context->{l} ); 
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

#    ($reference{c}, $reference{dash}, $reference{c2}) = split(/([-–−])/, $r->{cr})  if (_non_empty($r->{cr})); 
#    ($reference{v}, $reference{dash}, $reference{v2}) = split(/([-–−])/, $r->{vr})  if (_non_empty($r->{vr})); 

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

sub is_explicit {
    my $self = shift;
    my $ref = shift || $self->_reference_hash;
    
    my $any = _non_empty($ref->{l}) || _non_empty($ref->{book}) || _non_empty($ref->{abbreviation}) || _non_empty($ref->{key});

    # Explicit reference must have a book and a chapter
    return ($any && _non_empty($ref->{c}));
}

########################################################################
# Helper Functions
#
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

Religion::Bible::Regex::Reference - [One line description of module's purpose here]


=head1 VERSION

This document describes Religion::Bible::Regex::Reference version 0.0.1


=head1 SYNOPSIS

    use Religion::Bible::Regex::Reference;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=head2 new
    Creates a new Religion::Bible::Regex::Reference.

    Requires two parameters a Religion::Bible::Regex::Config object
    and a Religion::Bible::Regex::Regex object

=head2 get_configuration
=head2 get_regexes
=head2 is_explicit

=head2 set
    Requires a hash of values to initalize the Bible reference
    Optional argument a previous reference which can provide context
    for initializing a reference

=head2 state_is_verset
    Returns true if the current the state is VERSE
=head2 state_is_chapitre
    Returns true if the current the state is CHAPTER

=head2 state_is_book   
    Returns true if the current the state is BOOK

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

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


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


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

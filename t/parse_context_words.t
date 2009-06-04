use t::TestConfig;
use utf8;
use Data::Dumper;
no warnings;

plan tests => 18;
    
my $yaml = <<"YAML";
books:
  1: 
    Match:
      Book: ['Genèse', 'Genese']
      Abbreviation: ['Ge']
    Normalized: 
      Book: Genèse
      Abbreviation: Ge
  2: 
    Match:
      Book: ['Exode']
      Abbreviation: ['Ex']
    Normalized: 
      Book: Exode
      Abbreviation: Ex

regex:
  chapitre_mots: (?:voir aussi|voir|a|ab)
  verset_mots: (?:vv?\.|voir aussi v.)

YAML

my $c = new Religion::Bible::Regex::Config($yaml); 
my $b = new Religion::Bible::Regex::Builder($c);

run {
#  chapitre_mots: (?:voir aussi|voir)
#  verset_mots: (?:vv?\.|du verset|des versets|les versets|voir aussi v.|le verset|aux versets|au verse|les versets suivants)


# regex:
#   chapitre_mots: (?:\(|voir aussi|voir|\(voir|\bde\b|dans|Dans|\[|se rapporte à|voyez également|par ex\.|A partir de|Au verset|au verset|passage de|\(chap\.)
#   verset_mots: (?:vv?\.|du verset|des versets|les versets|voir aussi v.|le verset|aux versets|au verse|les versets suivants \()
    my $block = shift;

    # Initialize two references
    my $r = new Religion::Bible::Regex::Reference($c, $b);

    # Parse the references
    my ($header, $state) = $r->parse_context_words($block->reference);

    chomp $header;

    # Do the testing
    is($header, $block->header, $block->name . ':' . $block->reference);
    is($state,  $block->state,  $block->name . ':' . $block->reference);
};

__END__
=== parse_context_words
--- reference chomp
ab 1:5
--- header chomp
ab
--- state chomp
CHAPTER

=== parse_context_words
--- reference chomp
voir 1:5
--- header chomp
voir
--- state chomp
CHAPTER

=== parse_context_words
--- reference chomp
voir aussi 1:5
--- header chomp
voir aussi
--- state chomp
CHAPTER

=== parse_context_words
--- reference chomp
vv. 1-4
--- header chomp
vv.
--- state chomp
VERSE

=== parse_context_words - 
--- reference chomp
voir aussi v. 1:5
--- header chomp
voir aussi v.
--- state chomp
VERSE

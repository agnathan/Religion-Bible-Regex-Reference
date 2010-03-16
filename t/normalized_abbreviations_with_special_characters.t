use t::TestConfig;
use utf8;
use Data::Dumper;
no warnings;

plan tests => 5;
    
my $yaml = <<"YAML";
books:
  1: 
    Match:
      Book: ['Genèse', 'Genese']
      Abbreviation: ['Ge', 'Ge.']
    Normalized: 
      Book: Genèse
      Abbreviation: Ge
  2: 
    Match:
      Book: ['Exode']
      Abbreviation: ['Ex', 'Ex.']
    Normalized: 
      Book: Exode
      Abbreviation: Ex.
  3: 
    Match:
      Book: ['Lévitique', 'Levitique']
      Abbreviation: ['Lé', 'Le', 'Le.']
    Normalized: 
      Book: Lévitique
      Abbreviation: Lé.

regex:
  chapitre_mots: (?:voir aussi|voir|\\(|voir chapitre|\\bde\\b)
  verset_mots: (?:vv?\.|voir aussi v\.)
  livres_avec_un_chapitre: (?:Ab|Abdias|2Jn|2Jean|Phm|Philemon|Philémon|Jud|Jude|3Jn|3Jean)

YAML

my $c = new Religion::Bible::Regex::Config($yaml); 
my $b = new Religion::Bible::Regex::Builder($c);

run {
    my $block = shift;
    my $r1 = new Religion::Bible::Regex::Reference($c, $b);

    $r1->parse($block->ref1, $block->ref1state);    

    is($r1->formatted_normalize, $block->result, $block->name);
};



__END__
=== search abbreviation with no `special characters, normalized with no special characters
--- ref1 chomp
Ge 4:5
--- result chomp
Ge 4:5

=== search abbreviation with special characters, normalized with no special characters
--- ref1 chomp
Ge. 4:5
--- result chomp
Ge 4:5

=== search abbreviation with no special characters, normalized with special characters
--- ref1 chomp
Le 4:5
--- result chomp
Lé. 4:5

=== search abbreviation with no special characters, normalized with special characters
--- ref1 chomp
Le. 4:5
--- result chomp
Lé. 4:5

=== search abbreviation with special characters in the interval, normalized with no special characters
--- ref1 chomp
Ge 2:5-Ex 6:7
--- result chomp
Ge 2:5-Ex. 6:7


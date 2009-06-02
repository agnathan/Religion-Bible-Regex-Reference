use t::TestConfig;
use Data::Dumper;

plan tests => 1 * blocks();

# filters {
#     init   => [eval],
#     result => [eval]
# };

run {
    my $block = shift;
    my $c = new Religion::Bible::Regex::Config($block->yaml); 
    my $r = new Religion::Bible::Regex::Builder($c);
    my $ref = new Religion::Bible::Regex::Reference($c, $r);
    $ref->parse($block->init, $block->state);
    my $result = $ref->normalize;
#    print Dumper $hash;
    my $expected = $block->result;
    is_deeply($result, $expected, $block->name);
};

__END__
=== Parse LCVLCV - Ge 1:1-Ex 2:5
--- yaml
---
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
  livres_avec_un_chapitre: (?:Ab|Abdias|2Jn|2Jean|Phm|Philemon|Philémon|Jud|Jude|3Jn|3Jean)
reference:
  book_format: ORIGINAL
--- init chomp
Ge 1:1-Ex 2:5
--- result chomp
Ge 1:1-Ex 2:5
=== Parse LCLCV - Ge 1-Ex 2:5
--- yaml
---
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
reference:
  book_format: ORIGINAL

--- init chomp
Ge 1-Ex 2:5
--- result chomp 
Ge 1-Ex 2:5
=== Parse LCLC - Ge 1-Ex 2
--- yaml
---
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
reference:
  book_format: ORIGINAL

--- init chomp
Ge 1-Ex 2
--- result chomp
Ge 1-Ex 2
=== Parse LC - Ge 1
--- yaml
---
books:
  1: 
    Match:
      Book: ['Genèse', 'Genese']
      Abbreviation: ['Ge']
    Normalized: 
      Book: Genèse
      Abbreviation: Ge
reference:
  book_format: ORIGINAL

--- init chomp
Ge 1
--- result chomp
Ge 1
=== Parse LCVCV - Ge 1:1-2:5
--- yaml
---
books:
  1: 
    Match:
      Book: ['Genèse', 'Genese']
      Abbreviation: ['Ge']
    Normalized: 
      Book: Genèse
      Abbreviation: Ge    
reference:
  book_format: ORIGINAL
--- init chomp
Ge 1:1-2:5
--- result chomp
Ge 1:1-2:5
=== Parse LCCV - Ge 1-2:5
--- yaml
---
books:
  1: 
    Match:
      Book: ['Genèse', 'Genese']
      Abbreviation: ['Ge']
    Normalized: 
      Book: Genèse
      Abbreviation: Ge
reference:
  book_format: ORIGINAL
--- init chomp
Ge 1-2:5
--- result chomp 
Ge 1-2:5
=== Parse LCC - Ge 1-2
--- yaml
---
books:
  1: 
    Match:
      Book: ['Genèse', 'Genese']
      Abbreviation: ['Ge']
    Normalized: 
      Book: Genèse
      Abbreviation: Ge
reference:
  book_format: ORIGINAL
--- init chomp
Ge 1-2
--- result chomp
Ge 1-2
=== Parse LC - Ge 1
--- yaml
---
books:
  1: 
    Match:
      Book: ['Genèse', 'Genese']
      Abbreviation: ['Ge']
    Normalized: 
      Book: Genèse
      Abbreviation: Ge
reference:
  book_format: ORIGINAL
--- init chomp
Ge 1
--- result chomp
Ge 1
=== Parse CVCV - 1:1-2:5
--- yaml
---
reference:
  book_format: ORIGINAL
--- init chomp
1:1-2:5
--- state chomp
CHAPTER
--- result chomp
1:1-2:5
=== Parse CCV - 1-2:5
--- yaml
---
books:
  1: 
    Match:
      Book: ['Genèse', 'Genese']
      Abbreviation: ['Ge']
    Normalized: 
      Book: Genèse
      Abbreviation: Ge
reference:
  book_format: ORIGINAL

--- init chomp
1-2:5
--- state chomp
CHAPTER
--- result chomp
1-2:5
=== Parse CC - 1-2
--- yaml
---
reference:
  book_format: ORIGINAL
--- init chomp
1-2
--- state chomp
CHAPTER
--- result chomp
1-2
=== Parse C - 2
--- yaml
---
reference:
  book_format: ORIGINAL
--- init chomp
1
--- state chomp
CHAPTER
--- result chomp
1
=== Parse VV - 1-2
--- yaml
---
reference:
  book_format: ORIGINAL
--- init chomp
1-2
--- state chomp
VERSE
--- result chomp
1-2
=== Parse V - 2
--- yaml
---
reference:
  book_format: ORIGINAL
--- init chomp
1
--- state chomp
VERSE
--- result chomp
1
=== Parse a book that has only one chapter - Jude 4
--- yaml
---
books:
  65: 
    Match:
      Book: ['Jude']
      Abbreviation: ['Ju']
    Normalized: 
      Book: Jude
      Abbreviation: Ju
regex:
  livres_avec_un_chapitre: (?:Ab|Abdias|2Jn|2Jean|Phm|Philemon|Philémon|Jud|Jude|3Jn|3Jean)
reference:
  book_format: ORIGINAL
--- init chomp
Jude 4
--- state chomp
VERSE
--- result chomp
Jude 1:4

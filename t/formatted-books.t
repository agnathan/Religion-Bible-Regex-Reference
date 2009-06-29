use t::TestConfig;
use Data::Dumper;
#use utf8;

plan tests => 1 * blocks();

run {
    my $block = shift;
    my $c = new Religion::Bible::Regex::Config($block->yaml); 
    my $r = new Religion::Bible::Regex::Builder($c);
    my $ref = new Religion::Bible::Regex::Reference($c, $r);
    $ref->parse($block->init);
    my $result = $ref->formatted_book;
    my $expected = $block->result;
    chomp $expected;
    is($result, $expected, $block->name);

};
	
__END__
=== Get books in the correct format LCVCV - Ge 1:1-2:5
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
Ge
=== Get books in the correct format LCCV - Ge 1-2:5
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
Ge
=== Get books in the correct format LCC - Ge 1-2
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
Ge
=== Get books in the correct format LC - Ge 1
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
--- result
Ge

=== Get books in the correct format LCVCV - Genèse 1:1-2:5
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
Genèse 1:1-2:5
--- result chomp
Genèse
=== Get books in the correct format LCCV - Genèse 1-2:5
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
Genèse 1-2:5
--- result chomp
Genèse
=== Get books in the correct format LCC - Genèse 1-2
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
Genèse 1-2
--- result chomp
Genèse
=== Get books in the correct format LC - Genèse 1
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
Genèse 1
--- result
Genèse

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
    my $key = $ref->key;
    my $hash = $ref->{'reference'};
#    print Dumper $hash;
    my $result = $block->result;
    is_deeply($hash, $result, $block->name);
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

--- init chomp
Ge 1:1-Ex 2:5
--- result eval
{
    'data' => {
	'key' => '1',
	'c' => '1',
	'v' => '1',
	'key2' => '2',
	'c2' => '2',
	'v2' => '5',
    },
    'original' => {
	'b'  => 'Ge',
	'c'  => '1',
	'v'  => '1',
	'b2' => 'Ex',	    
	'c2' => '2',
	'v2' => '5',
    },
    'spaces' => {
	's2' => ' ',
	's7' => ' ',
    },
    'info' => {
	'cvs' =>':',
	'dash' => '-',
    }
}
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

--- init chomp
Ge 1-Ex 2:5
--- result eval 
{
    'data' => {
	'key' => '1',
	'c' => '1',
	'key2' => '2',
	'c2' => '2',
	'v2' => '5',
    },
    'original' => {
	'b' => 'Ge',
	'c' => '1',
	'b2' => 'Ex',
	'v2' => '5',
	'c2' => '2'
    },
    'spaces' => {
	's2' => ' ',
	's7' => ' ',
    },
    'info' => {
	'cvs' =>':',
	'dash' => '-',
    }
}

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

--- init chomp
Ge 1-Ex 2
--- result eval
{
    'data' => {
	'key' => '1',
	'c' => '1',
	'key2' => '2',
	'c2' => '2'
    },
    'original' => {
	'b' => 'Ge',
	'c' => '1',
	'b2' => 'Ex',
	'c2' => '2'
    },
    'spaces' => {
	's2' => ' ',
	's7' => ' ',
    },
    'info' => {
	'dash' => '-',
    }
}

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

--- init chomp
Ge 1
--- result eval
{
    'data' => {
	'key' => '1',
	'c' => '1',
    },
    'original' => {
	'b' => 'Ge',
	'c' => '1',
    },
    'spaces' => {
	's2' => ' ',
    },
}
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
--- init chomp
Ge 1:1-2:5
--- result eval
{
    'data' => {
	'key' => '1',
	'c' => '1',
	'v' => '1',
	'c2' => '2',
	'v2' => '5',
    },
    'original' => {
	'b' => 'Ge',
	'c' => '1',
	'v' => '1',
	'v2' => '5',
	'c2' => '2'
    },
    'spaces' => {
	's2' => ' ',
    },
    'info' => {
	'cvs' =>':',
	'dash' => '-',
    }
}
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
--- init chomp
Ge 1-2:5
--- result eval 
{
    'data' => {
	'key' => '1',
	'c' => '1',
	'c2' => '2',
	'v2' => '5',
    },
    'original' => {
	'b' => 'Ge',
	'c' => '1',
	'v2' => '5',
	'c2' => '2'
    },
    'spaces' => {
	's2' => ' ',
    },
    'info' => {
	'cvs' =>':',
	'dash' => '-',
    }
}

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
--- init chomp
Ge 1-2
--- result eval
{
    'data' => {
	'key' => '1',
	'c' => '1',
	'c2' => '2'
    },
    'original' => {
	'b' => 'Ge',
	'c' => '1',
	'c2' => '2'
    },
    'spaces' => {
	's2' => ' ',
    },
    'info' => {
	'dash' => '-',
    }
}

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
--- init chomp
Ge 1
--- result eval
{
    'data' => {
	'key' => '1',
	'c' => '1',
    },
    'original' => {
	'b' => 'Ge',
	'c' => '1',
    },
    'spaces' => {
	's2' => ' ',
    },
}

=== Parse CVCV - 1:1-2:5
--- yaml
---
--- init chomp
1:1-2:5
--- state chomp
CHAPTER
--- result eval
{
    'data' => {
	'c' => '1',
	'v' => '1',
	'c2' => '2',
	'v2' => '5',
    },
    'original' => {
	'c' => '1',
	'v' => '1',
	'c2' => '2',
	'v2' => '5',
    },
    'info' => {
	'cvs' =>':',
	'dash' => '-',
    }
}
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

--- init chomp
1-2:5
--- state chomp
CHAPTER
--- result eval
{
    'data' => {
	'c' => '1',
	'c2' => '2',
	'v2' => '5',
    },
    'original' => {
	'c' => '1',
	'c2' => '2',
	'v2' => '5',
    },
    'info' => {
	'cvs' =>':',
	'dash' => '-',
    }
}
=== Parse CC - 1-2
--- yaml
---
--- init chomp
1-2
--- state chomp
CHAPTER
--- result eval
{
    'data' => {
	'c' => '1',
	'c2' => '2'
    },
    'original' => {
	'c' => '1',
	'c2' => '2'
    },
    'info' => {
	'dash' => '-',
    }
}
=== Parse C - 2
--- yaml
---
--- init chomp
1
--- state chomp
CHAPTER
--- result eval
{
    'data' => {
	'c' => '1',
    },
    'original' => {
	'c' => '1',
    },
}
=== Parse VV - 1-2
--- yaml
---
--- init chomp
1-2
--- state chomp
VERSE
--- result eval
{
    'data' => {
	'v' => '1',
	'v2' => '2',
    },
    'original' => {
	'v' => '1',
	'v2' => '2',
    },
    'info' => {
	'dash' => '-',
    }
}
=== Parse V - 2
--- yaml
---
--- init chomp
1
--- state chomp
VERSE
--- result eval
{
    'data' => {
	'v' => '1',
    },
    'original' => {
	'v' => '1',
    }
}
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
--- init chomp
Jude 4
--- state chomp
VERSE
--- result eval
{
    'data' => {
	'key' => '65',
	'c' => '1',
	'v' => '4',
    },
    'original' => {
	'b'  => 'Jude',
	'c' => '1',
	'v'  => '4',
    },
    'spaces' => {
	's2' => ' ',
    },
    'info' => {
	'cvs' => ':'
    }
}
=== Parse a book that has only one chapter - Jude 1:4
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
--- init chomp
Jude 1:4
--- state chomp
VERSE
--- result eval
{
    'data' => {
        'key' => '65',
        'c' => '1',
        'v' => '4',
    },
    'original' => {
        'b'  => 'Jude',
        'c' => '1',
        'v'  => '4',
    },
    'spaces' => {
        's2' => ' ',
    },
    'info' => {
        'cvs' => ':'
    }
}


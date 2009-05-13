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
    my $ref = new Religion::Bible::Regex::Reference($r, $c);
    $ref->set($block->init);
    my $hash = $ref->{'reference'};
    my $result = $block->result;
    is_deeply($hash, $result, $block->name);
};

__END__
=== Parse LCVCV - Ge 1:1-2:5
--- yaml
---
--- init eval
{l=>'Ge',a=>' ',c=>'1',cvs=>':',v=>'1', dash=>'-',c2=>'2',cvs2=>':',v2=>'5'}
--- result eval
{
  'vr2' => '',
  'd2' => '',
  'a' => ' ',
  'd' => '',
  'c2' => '2',
  'key' => '',
  'bookname_type' => 'ABBREVIATION',
  'a2' => '',
  'cr' => '',
  'key2' => '',
  'hs' => '',
  'cr2' => '',
  'abbreviation2' => '',
  'v' => '1',
  'hs2' => '',
  'l' => 'Ge',
  'c' => '1',
  'l2' => '',
  'b' => '',
  'v2' => '5',
  'vr' => '',
  'book' => '',
  'book2' => '',
  'b2' => '',
  'abbreviation' => ''
};
=== Parse LCCV - Ge 1-2:5
--- yaml
---
--- init eval
{l=>'Ge',a=>' ',c=>'1', dash=>'-',c2=>'2',cvs2=>':',v2=>'5'}
--- result eval
{
  'vr2' => '',
  'd2' => '',
  'a' => ' ',
  'd' => '',
  'c2' => '2',
  'key' => '',
  'bookname_type' => 'ABBREVIATION',
  'a2' => '',
  'cr' => '',
  'key2' => '',
  'hs' => '',
  'cr2' => '',
  'abbreviation2' => '',
  'v' => '',
  'hs2' => '',
  'l' => 'Ge',
  'c' => '1',
  'l2' => '',
  'b' => '',
  'v2' => '5',
  'vr' => '',
  'book' => '',
  'book2' => '',
  'b2' => '',
  'abbreviation' => ''
};
=== Parse LCC - Ge 1-2
--- yaml
---
--- init eval
{l=>'Ge',a=>' ',c=>'1', dash=>'-',c2=>'2'}
--- result eval
{
  'vr2' => '',
  'd2' => '',
  'a' => ' ',
  'd' => '',
  'c2' => '2',
  'key' => '',
  'bookname_type' => 'ABBREVIATION',
  'a2' => '',
  'cr' => '',
  'key2' => '',
  'hs' => '',
  'cr2' => '',
  'abbreviation2' => '',
  'v' => '',
  'hs2' => '',
  'l' => 'Ge',
  'c' => '1',
  'l2' => '',
  'b' => '',
  'v2' => '',
  'vr' => '',
  'book' => '',
  'book2' => '',
  'b2' => '',
  'abbreviation' => ''
};
=== Parse LC - Ge 1
--- yaml
---
--- init eval
{l=>'Ge', a=>' ', c=>'1'}
--- result eval
{
  'vr2' => '',
  'd2' => '',
  'a' => ' ',
  'd' => '',
  'c2' => '',
  'key' => '',
  'bookname_type' => 'ABBREVIATION',
  'a2' => '',
  'cr' => '',
  'key2' => '',
  'hs' => '',
  'cr2' => '',
  'abbreviation2' => '',
  'v' => '',
  'hs2' => '',
  'l' => 'Ge',
  'c' => '1',
  'l2' => '',
  'b' => '',
  'v2' => '',
  'vr' => '',
  'book' => '',
  'book2' => '',
  'b2' => '',
  'abbreviation' => ''
};
=== Parse CVCV - 1:1-2:5
--- yaml
---
--- init eval
{c=>'1',cvs=>':',v=>'1', dash=>'-',c2=>'2',cvs2=>':',v2=>'5'}
--- result eval
{
  'vr2' => '',
  'd2' => '',
  'a' => '',
  'd' => '',
  'c2' => '2',
  'key' => '',
  'bookname_type' => 'NONE',
  'a2' => '',
  'cr' => '',
  'key2' => '',
  'hs' => '',
  'cr2' => '',
  'abbreviation2' => '',
  'v' => '1',
  'hs2' => '',
  'l' => '',
  'c' => '1',
  'l2' => '',
  'b' => '',
  'v2' => '5',
  'vr' => '',
  'book' => '',
  'book2' => '',
  'b2' => '',
  'abbreviation' => ''
};
=== Parse CCV - 1-2:5
--- yaml
---
--- init eval
{c=>'1', dash=>'-',c2=>'2',cvs2=>':',v2=>'5'}
--- result eval
{
  'vr2' => '',
  'd2' => '',
  'a' => '',
  'd' => '',
  'c2' => '2',
  'key' => '',
  'bookname_type' => 'NONE',
  'a2' => '',
  'cr' => '',
  'key2' => '',
  'hs' => '',
  'cr2' => '',
  'abbreviation2' => '',
  'v' => '',
  'hs2' => '',
  'l' => '',
  'c' => '1',
  'l2' => '',
  'b' => '',
  'v2' => '5',
  'vr' => '',
  'book' => '',
  'book2' => '',
  'b2' => '',
  'abbreviation' => ''
};
=== Parse CC - 1-2
--- yaml
---
--- init eval
{c=>'1', dash=>'-',c2=>'2'}
--- result eval
{
  'vr2' => '',
  'd2' => '',
  'a' => '',
  'd' => '',
  'c2' => '2',
  'key' => '',
  'bookname_type' => 'NONE',
  'a2' => '',
  'cr' => '',
  'key2' => '',
  'hs' => '',
  'cr2' => '',
  'abbreviation2' => '',
  'v' => '',
  'hs2' => '',
  'l' => '',
  'c' => '1',
  'l2' => '',
  'b' => '',
  'v2' => '',
  'vr' => '',
  'book' => '',
  'book2' => '',
  'b2' => '',
  'abbreviation' => ''
};
=== Parse C - 2
--- yaml
---
--- init eval
{c=>'1'}
--- result eval
{
  'vr2' => '',
  'd2' => '',
  'a' => '',
  'd' => '',
  'c2' => '',
  'key' => '',
  'bookname_type' => 'NONE',
  'a2' => '',
  'cr' => '',
  'key2' => '',
  'hs' => '',
  'cr2' => '',
  'abbreviation2' => '',
  'v' => '',
  'hs2' => '',
  'l' => '',
  'c' => '1',
  'l2' => '',
  'b' => '',
  'v2' => '',
  'vr' => '',
  'book' => '',
  'book2' => '',
  'b2' => '',
  'abbreviation' => ''
};



=== Parse VV - 1-2
--- yaml
---
--- init eval
{v=>'1', dash=>'-',v2=>'2'}
--- result eval
{
  'vr2' => '',
  'd2' => '',
  'a' => '',
  'd' => '',
  'c2' => '',
  'key' => '',
  'bookname_type' => 'NONE',
  'a2' => '',
  'cr' => '',
  'key2' => '',
  'hs' => '',
  'cr2' => '',
  'abbreviation2' => '',
  'v' => '1',
  'hs2' => '',
  'l' => '',
  'c' => '',
  'l2' => '',
  'b' => '',
  'v2' => '2',
  'vr' => '',
  'book' => '',
  'book2' => '',
  'b2' => '',
  'abbreviation' => ''
};
=== Parse V - 2
--- yaml
---
--- init eval
{v=>'1'}
--- result eval
{
  'vr2' => '',
  'd2' => '',
  'a' => '',
  'd' => '',
  'c2' => '',
  'key' => '',
  'bookname_type' => 'NONE',
  'a2' => '',
  'cr' => '',
  'key2' => '',
  'hs' => '',
  'cr2' => '',
  'abbreviation2' => '',
  'v' => '1',
  'hs2' => '',
  'l' => '',
  'c' => '',
  'l2' => '',
  'b' => '',
  'v2' => '',
  'vr' => '',
  'book' => '',
  'book2' => '',
  'b2' => '',
  'abbreviation' => ''
};

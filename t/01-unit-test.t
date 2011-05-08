#!perl

use strict; use warnings;
use Radio::ProgrammesSchedules::BBC;
use Test::More tests => 15;

my ($bbc);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new(channel => 'radio1'); };
like($@, qr/ERROR: Input param has to be a ref to HASH./);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new({xyz => 'radio2'}); };
like($@, qr/ERROR: Missing key channel./);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new({channel => 'radiox'}); };
like($@, qr/ERROR: Invalid value for channel./);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new({channel => 'radio1'}); };
like($@, qr/ERROR: Invalid number of keys found in the input hash./);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new({channel => 'radio4'}); };
like($@, qr/ERROR: Invalid number of keys found in the input hash./);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new({channel => 'radio1', xyz => 1}); };
like($@, qr/ERROR: Missing key location./);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new({channel => 'radio4', xyz => 1}); };
like($@, qr/ERROR: Missing key frequency./);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new({channel => 'radio1', location => 1}); };
like($@, qr/ERROR: Invalid value for location./);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new({channel => 'radio4', frequency => 1}); };
like($@, qr/ERROR: Invalid value for frequency./);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new({channel => 'radio1', location => 'england', yyyy => 2011}); };
like($@, qr/ERROR: Missing key mm from input hash./);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new({channel => 'radio1', location => 'england', yyyy => 2011, mm => 4}); };
like($@, qr/ERROR: Missing key dd from input hash./);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new({channel => 'radio1', location => 'england', mm => 4}); };
like($@, qr/ERROR: Missing key yyyy from input hash./);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new({channel => 'radio1', location => 'england', yyyy => 2011, mm => 4}); };
like($@, qr/ERROR: Missing key dd from input hash./);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new({channel => 'radio1', location => 'england', dd => 4}); };
like($@, qr/ERROR: Missing key yyyy from input hash./);

eval { $bbc = Radio::ProgrammesSchedules::BBC->new({channel => 'radio1', location => 'england', yyyy => 2011, dd => 11}); };
like($@, qr/ERROR: Missing key mm from input hash./);
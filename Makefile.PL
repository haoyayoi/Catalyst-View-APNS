use inc::Module::Install;
name 'Catalyst-View-APNS';
all_from 'lib/Catalyst/View/APNS.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

requires 'AnyEvent::APNS';
requires 'Catalyst';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;

use inc::Module::Install;
name 'Catalyst-View-APNS';
all_from 'lib/Catalyst/View/APNS.pm';

tests 't/*.t';
author_tests 'xt';

requires 'AnyEvent::APNS';
requires 'Catalyst';

build_requires 'Test::More';

auto_include;
WriteAll;

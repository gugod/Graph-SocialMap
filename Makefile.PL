
use inc::Module::Install;

name            ('Graph-SocialMap');
abstract        ('Easy way to create social map.');
author          ('Kang-min Liu (gugod@gugod.org)');
license         ('perl');
version_from    ('lib/Graph/SocialMap.pm');
requires        ('Spiffy' => 0.18);
requires        ('Graph');
requires        ('GraphViz');
requires        ('Graph::Writer::GraphViz' => 0.03);

&WriteAll;

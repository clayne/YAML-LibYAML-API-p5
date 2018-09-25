#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use YAML::LibYAML::API;
use YAML::LibYAML::API::XS;
use YAML::PP::Parser;

my $yaml = <<'EOM';
%YAML 1.1
---
foo: &ALIAS bar
'alias': *ALIAS
tag: !!int 23
list:
- "doublequoted"
- >
  folded
- |-
  literal
EOM

my $ev = [];
YAML::LibYAML::API::parse_events($yaml, $ev);

my @ts = map { YAML::PP::Parser->event_to_test_suite([ $_->{name} => $_ ]) } @$ev;
my @exp_events = (
    '+STR',
    '+DOC ---',
    '+MAP',
    '=VAL :foo',
    '=VAL &ALIAS :bar',
    "=VAL 'alias",
    '=ALI *ALIAS',
    '=VAL :tag',
    '=VAL <tag:yaml.org,2002:int> :23',
    '=VAL :list',
    '+SEQ',
    '=VAL "doublequoted',
    '=VAL >folded\n',
    '=VAL |literal',
    '-SEQ',
    '-MAP',
    '-DOC',
    '-STR',
);
is_deeply(\@ts, \@exp_events, "parse_events - Test Suite Events match");

@exp_events = (
    { name => 'stream_start_event',
        start => { line => 0, column => 0 },
        end   => { line => 0, column => 0 },
    },
    { name => 'document_start_event',
        start => { line => 0, column => 0 },
        end   => { line => 1, column => 3 },
        version_directive => { major => 1, minor => 1 },
    },
    { name => 'mapping_start_event',
        start => { line => 2, column => 0 },
        end   => { line => 2, column => 0 },
    },
    { name => 'scalar_event', style => ':', value => 'foo',
        start => { line => 2, column => 0 },
        end   => { line => 2, column => 3 },
    },
    { name => 'scalar_event', style => ':', value => 'bar', anchor => 'ALIAS',
        start => { line => 2, column => 5 },
        end   => { line => 2, column => 15 },
    },
    { name => 'scalar_event', style => "'", value => 'alias',
        start => { line => 3, column => 0 },
        end   => { line => 3, column => 7 },
    },
    { name => 'alias_event', value => 'ALIAS',
        start => { line => 3, column => 9 },
        end   => { line => 3, column => 15 },
    },
    { name => 'scalar_event', style => ':', value => 'tag',
        start => { line => 4, column => 0 },
        end   => { line => 4, column => 3 },
    },
    { name => 'scalar_event', style => ':', value => '23', tag => 'tag:yaml.org,2002:int',
        start => { line => 4, column => 5 },
        end   => { line => 4, column => 13 },
    },
    { name => 'scalar_event', style => ':', value => 'list',
        start => { line => 5, column => 0 },
        end   => { line => 5, column => 4 },
    },
    { name => 'sequence_start_event',
        start => { line => 6, column => 0 },
        end   => { line => 6, column => 1 },
    },
    { name => 'scalar_event', style => '"', value => 'doublequoted',
        start => { line => 6, column => 2 },
        end   => { line => 6, column => 16 },
    },
    { name => 'scalar_event', style => '>', value => "folded\n",
        start => { line => 7, column => 2 },
        end   => { line => 9, column => 0 },
    },
    { name => 'scalar_event', style => '|', value => "literal",
        start => { line => 9, column => 2 },
        end   => { line => 11, column => 0 },
    },
    { name => 'sequence_end_event',
        start => { line => 11, column => 0 },
        end   => { line => 11, column => 0 },
    },
    { name => 'mapping_end_event',
        start => { line => 11, column => 0 },
        end   => { line => 11, column => 0 },
    },
    { name => 'document_end_event', implicit => 1,
        start => { line => 11, column => 0 },
        end   => { line => 11, column => 0 },
    },
    { name => 'stream_end_event',
        start => { line => 11, column => 0 },
        end   => { line => 11, column => 0 },
    },
);
is_deeply($ev, \@exp_events, "parse_events - Events match");

my $libyaml_version = YAML::LibYAML::API::XS::libyaml_version();
diag "libyaml version = $libyaml_version";
cmp_ok($libyaml_version, '=~', qr{^\d+\.\d+(?:\.\d+)$}, "libyaml_version ($libyaml_version)");

done_testing;

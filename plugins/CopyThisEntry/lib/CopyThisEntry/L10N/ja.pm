package CopyThisEntry::L10N::ja;

use strict;
use utf8;
use base 'CopyThisEntry::L10N::en_us';
use vars qw( %Lexicon );

%Lexicon = (

## plugins/CopyThisEntry/config.yaml
	'This plugin provides a simple way to copy existing entry.' => 'カスタムフィールドの内容も含めて記事をコピーして、新しい記事を作成します。',

## plugins/CopyThisEntry/lib/CopyThisEntry/Transformer.pm
	'Copy This Entry' => 'この記事をコピーする',
	'Copy of [_1]' => '*コピー* [_1]',

);

1;

#!/bin/sh

exec flutter pub pub run intl_translation:extract_to_arb --output-dir=intl intl/code.dart

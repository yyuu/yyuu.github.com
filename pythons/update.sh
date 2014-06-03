#!/usr/bin/env bash

set -e
set -x

compute_sha2() {
  local output
  if type shasum &>/dev/null; then
    output="$(shasum -a 256 -b)" || return 1
    echo "${output% *}"
  elif type openssl &>/dev/null; then
    output="$(openssl dgst -sha256)" || return 1
    echo "${output##* }"
  elif type sha256sum &>/dev/null; then
    output="$(sha256sum --quiet)" || return 1
    echo "${output% *}"
  else
    return 1
  fi
}

compute_md5() {
  local output
  if type md5 &>/dev/null; then
    md5 -q
  elif type openssl &>/dev/null; then
    output="$(openssl md5)" || return 1
    echo "${output##* }"
  elif type md5sum &>/dev/null; then
    output="$(md5sum -b)" || return 1
    echo "${output% *}"
  else
    return 1
  fi
}

for file in source/*; do
  base="$(basename "$file")"
  md5="$(compute_md5 < "$file")"
  sha="$(compute_sha2 < "$file")"
  ln -f "$file" "$md5"
  ln -f "$file" "$sha"
  sed -i -e "/<a $base<\/a>/s/^.*$/<li><a href=\"$sha\">$base<\/a><\/li>/" index.html
done

# vim:set ft=sh :

#!/usr/bin/env bash

set -e

function runTests {
  echo "==> Checking acceptance test Terraform blocks are formatted..."
  bash ./scripts/terrafmt-acctests.sh
}

function main {
  runTests
}

main

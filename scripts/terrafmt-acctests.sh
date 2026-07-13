#!/usr/bin/env bash

echo "==> Checking acceptance test terraform blocks are formatted..."

files=$(find ./internal -type f -name "*_test.go")
error=false

for f in $files; do
  aqua -c aqua/aqua.yml exec -- terrafmt diff -c -q -f "$f" || error=true
done

if ${error}; then
  echo "------------------------------------------------"
  echo ""
  echo "The preceding files contain terraform blocks that are not correctly formatted or contain errors."
  echo "You can fix this by running just tools and then terrafmt on them."
  echo ""
  echo "to easily fix all terraform blocks:"
  echo "$ just terrafmt"
  echo ""
  echo "format only acceptance test config blocks:"
  echo "$ find msgraph | egrep \"_test.go\" | sort | while read f; do aqua -c aqua/aqua.yml exec -- terrafmt fmt -f \$f; done"
  echo ""
  echo "format a single test file:"
  echo "$ aqua -c aqua/aqua.yml exec -- terrafmt fmt -f ./internal/services/service/tests/resource_test.go"
  echo ""
  echo "on windows:"
  echo "$ Get-ChildItem -Path . -Recurse -Filter \"*_test.go\" | foreach {aqua -c aqua/aqua.yml exec -- terrafmt fmt -f $_.fullName}"
  echo ""
  exit 1
fi

exit 0

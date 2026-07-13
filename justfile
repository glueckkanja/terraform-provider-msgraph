set shell := ["bash", "-euo", "pipefail", "-c"]

test_timeout := "300m"
test_args := env_var_or_default("TESTARGS", "")

# Run unit tests. Acceptance tests are skipped unless TF_ACC is explicitly set.
default: test

test: fmtcheck
  TEST="$(go list ./... | grep -v vendor | grep -v examples)" ./scripts/run-test.sh

# Run acceptance tests.
testacc: fmtcheck
  TF_ACC=1 go test $(go list ./... | grep -v vendor | grep -v examples) -v {{test_args}} -count=1 -timeout {{test_timeout}} -ldflags="-X=github.com/glueckkanja/terraform-provider-msgraph/version.ProviderVersion=acc"

# Check that generated provider documentation is committed.
docs:
  AQUA_CONFIG="{{ justfile_directory() }}/aqua/aqua.yml" go generate ./...
  find docs/data-sources docs/resources -name '*.md' -exec perl -0pi -e 's/[ \t]+(?=\n)//g; s/(?:\n[ \t]*)+\z/\n/' {} +

# Apply Go and Terraform formatting.
fmt:
  find . -name '*.go' -not -path './vendor/*' -print0 | xargs -0 aqua -c aqua/aqua.yml exec -- gofumpt -w
  find . -name '*.go' -not -path './vendor/*' -print0 | xargs -0 gofmt -s -w

terrafmt:
  find examples -name '*.tf' -print0 | xargs -0 -r aqua -c aqua/aqua.yml exec -- terraform fmt
  find internal -name '*_test.go' -print0 | xargs -0 -r aqua -c aqua/aqua.yml exec -- terrafmt fmt -f
  find docs -name '*.md' -print0 | xargs -0 -r aqua -c aqua/aqua.yml exec -- terrafmt fmt
  find templates -type f \( -name '*.tmpl' -o -name '*.md' \) -print0 | xargs -0 -r aqua -c aqua/aqua.yml exec -- terrafmt fmt

# Verify vendored dependency metadata is current.
depscheck:
  go mod tidy
  git diff --exit-code -- go.mod go.sum
  go mod vendor
  git diff --compact-summary --ignore-space-at-eol --exit-code -- vendor

# Run Terraform provider schema and formatting checks.
tflint:
  ./scripts/run-tflint.sh

# Scan reachable Go vulnerabilities.
vuln:
  aqua -c aqua/aqua.yml exec -- govulncheck ./...

# Build and lint the provider.
build:
  go build -v .

lint:
  aqua -c aqua/aqua.yml exec -- golangci-lint run ./...

# Validate source formatting and acceptance-test package conventions.
fmtcheck:
  ./scripts/gofmtcheck.sh
  ./scripts/timeouts.sh
  ./scripts/check-test-package.sh

# Build provider release artifacts without publishing them.
build-snapshot:
  aqua -c aqua/aqua.yml exec -- goreleaser build --clean --snapshot

# Publish a signed release for the current version tag.
release:
  aqua -c aqua/aqua.yml exec -- goreleaser release --clean

# Eagerly install every Aqua-pinned tool.
tools:
  aqua -c aqua/aqua.yml install

# Refresh Aqua package versions and their verified checksums.
update:
  aqua -c aqua/aqua.yml update
  aqua -c aqua/aqua.yml update-checksum --prune
  aqua -c aqua/aqua.yml install

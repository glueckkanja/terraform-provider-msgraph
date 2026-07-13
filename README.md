# Terraform Provider for MSGraph Rest API

The MSGraph provider is a very thin layer on top of the MSGraph REST APIs. Use this new provider to authenticate to and manage MSGraph resources and functionality using the MSGraph APIs directly.

## Get started with MSGraph

* [Microsoft Terraform VSCode Extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureterraform) provides a rich authoring experience to help you use the MSGraph provider.

Also, there is a rich library of [examples](https://github.com/glueckkanja/terraform-provider-msgraph/tree/main/examples) to help you get started.

## Usage Example

The following example shows how to use `msgraph_resource` to manage application resource.

```hcl
terraform {
  required_providers {
    msgraph = {
      source  = "Microsoft/msgraph"
    }
  }
}

provider "msgraph" {
  # More information on the authentication methods supported by
  # the MSGraph Provider can be found here:
  # https://registry.terraform.io/providers/Microsoft/msgraph/latest/docs

  # client_id       = "..."
  # client_secret   = "..."
  # tenant_id       = "..."
}

resource "msgraph_resource" "application" {
  url  = "applications"
  body = {
    displayName = "My Application"
  }
}

```

Further [usage documentation is available on the Terraform website](https://registry.terraform.io/providers/Microsoft/msgraph/latest/docs).

## Developer Requirements

* [Go](https://go.dev/doc/install) version specified in `go.mod`
* [Aqua](https://aquaproj.github.io/) to install the pinned development toolchain

### On Windows

If you're on Windows you'll also need:

* [Git Bash for Windows](https://git-scm.com/download/win)

For *Git Bash for Windows*, at the step of "Adjusting your PATH environment", please choose "Use Git and optional Unix tools from Windows Command Prompt".*

Install Git, Go, and Aqua via [Chocolatey](https://chocolatey.org/install) (`Git Bash for Windows` must be installed per steps above):

```powershell
choco install git golang aqua -y
refreshenv
```

You must run the following commands in `bash` because shell scripts are invoked as part of the recipes.

## Developing the Provider

If you wish to work on the provider, install Go and Aqua, then clone the repository:

```sh
git clone git@github.com:glueckkanja/terraform-provider-msgraph.git
cd terraform-provider-msgraph
```

Install the repository's checksum-verified toolchain, including Just:

```sh
aqua -c aqua/aqua.yml install
```

At this point, compile the provider with Just:

```sh
$ aqua -c aqua/aqua.yml exec -- just build
...
$ ./terraform-provider-msgraph
...
```

You can also cross-compile if necessary:

```sh
GOOS=windows GOARCH=amd64 aqua -c aqua/aqua.yml exec -- just build
```

In order to run the `Unit Tests` for the provider, you can run:

```sh
aqua -c aqua/aqua.yml exec -- just test
```

The majority of tests in the provider are `Acceptance Tests` - which provision real resources in Azure. Run the entire acceptance test suite with `just testacc`; to run a subset:

```sh
TESTARGS='-run=<nameOfTheTest>' aqua -c aqua/aqua.yml exec -- just testacc
```

* `<nameOfTheTest>` should be self-explanatory as it is the name of the test you want to run. An example could be `TestAccGenericResource_basic`. Since `-run` can be used with regular expressions you can use it to specify multiple tests like in `TestAccGenericResource_` to run all tests that match that expression

The following Environment Variables must be set in your shell prior to running acceptance tests:

* `ARM_CLIENT_ID`
* `ARM_CLIENT_SECRET`
* `ARM_TENANT_ID`

**Note:** Acceptance tests create real resources in Azure which often cost money to run.

## Generating Documentation

We use [tfplugindocs](https://github.com/hashicorp/terraform-plugin-docs) to automatically generate documentation for the provider.
Please ensure that the `MarkdownDescription` field is set in the schema for each resource and data source.

To generate the documentation run either:

```sh
aqua -c aqua/aqua.yml exec -- just docs
```

or...

```sh
go generate ./...
```

### Templates

Each resource is documented using a template. The template is located in the `templates` directory. The template is a markdown file with placeholders that are replaced with the actual values from the schema. There is a general template for all resources/data sources, and an optional specific template for each resource/data source where customization is required.

### Guides

Guides should be stored in the `templates/guides` directory. They will be inclided in the documentation and copied to the `docs` directory by the `tfplugindocs` tool.

### Examples

The `examples/resources` and `examples/data-sources` directory contains examples for each resource and data source. The examples are used to generate the documentation for each resource and data source. The examples are written in HCL and must be called `resource.tf` or `data-source.tf`. These are then embedded into the documentation and are used to generate the `Example` section.

---

## Developer: Using the locally compiled Azure Provider binary

When using Terraform 0.14 and later, after successfully compiling the Azure Provider, you must [instruct Terraform to use your locally compiled provider binary](https://www.terraform.io/docs/commands/cli-config.html#development-overrides-for-provider-developers) instead of the official binary from the Terraform Registry.

For example, add the following to `~/.terraformrc` for a provider binary located in `/home/developer/go/bin`:

```hcl
provider_installation {

  # Use /home/developer/go/bin as an overridden package directory
  # for the Microsoft/msgraph provider. This disables the version and checksum
  # verifications for this provider and forces Terraform to look for the
  # msgraph provider plugin in the given directory.
  dev_overrides {
    "Microsoft/msgraph" = "/home/developer/go/bin"
  }

  # For all other providers, install them directly from their origin provider
  # registries as normal. If you omit this, Terraform will _only_ use
  # the dev_overrides block, and so no other providers will be available.
  direct {}
}
```

## Credits

We wish to thank HashiCorp for the use of some MPLv2-licensed code from their open source project [terraform-provider-azuread](https://github.com/hashicorp/terraform-provider-azuread).

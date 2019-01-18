# terraform-database-server

This is a terraform module to spin up a database server, based on the automatically created image.

## Introduction

This module will create a database server with an attached disk.

## Prerequisites

- Terraform 0.11.0+
- __GCLOUD_KEYFILE_JSON__ Environment var set to a Google Cloud service account with correct permissions and the project where you are deploying to.

## File layout

* __variables.tf__ - This file contains all the defaults and overridable values for this module
* __main.tf__ - This file contains all the logic for this module

## Usage

1. Add the following to a terraform.tf file

```shell
module "terraform_database_server" {
  source = "git::git@github.com:boxrick/terraform-database-server.git?ref=v0.1.0"
  variable_one = "test"
}
```

2. Make sure the ```ref``` above is tagged to the latest version, this will be the version the module is pinned at.
3. Place the required variables as referenced in the ```variables.tf``` file
4. Run ```terraform get``` to pull down module(s) locally.
5. Run ```terraform plan``` to test output

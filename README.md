# Terraform Data Lineage Module

## Purpose

The purpose of this module is to build the data lineage solution defined in [this document](https://cloud.google.com/architecture/building-a-bigquery-data-lineage-solution).
With the aim of making this solution as easily repeatable as possible.

## Prerequisites

This module assumes you have already enabled the required Google APIs in any host or logged projects. In summary though the host project needs apis enabling for:

* Bigquery
* Dataflow
* Storage Buckets
* Compute
* Data Catalog
* Cloud Source Repositories

With logged projects requiring at the pubsub API enabled.

This module also assumes you want to attach dataflow to a pre-existing network subnet however if one isn't provided it assumes a default network has been created and tries to put it in a default subnet.

## Main Components

The main components of the solution are:

* A bigquery dataset and table
* A data catalog template
* A cloud source repository to host the code from [Google's repository](https://github.com/GoogleCloudPlatform/bigquery-data-lineage)
* A cloud build trigger to run a maven build and deploy of the dataflow job from the cloud source repository above.
* A dataflow staging bucket
* A couple of pubsub topics, one which aggregates logging from the logged projects

## Deploying Solution

* Integrate this Terraform module into your code.
* Run Terraform apply
* Pull and then push the [Google Data Lineage code](https://github.com/GoogleCloudPlatform/bigquery-data-lineage) into the cloud source repository.
* Trigger dataflow cloud build trigger (assuming pushing the code to the cloud source repository hasn't already).

#!/bin/bash
#
# Define various environment variables corresponding to the production
# instance of Kubeflow's spartakus collector.

export PROJECT=reporting
export NAMESPACE=collector
export CLUSTER=reporting
export ZONE=us-central1-b
export BIGQUERY_SECRET=bigquery
export FQDN=usage-collector.kubeflow.org

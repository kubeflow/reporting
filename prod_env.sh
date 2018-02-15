#!/bin/bash
#
# Define various environment variables corresponding to the production
# instance of Kubeflow's spartakus collector.

export PROJECT=kubeflow-usage
export NAMESPACE=collector
export CLUSTER=reporting
export ZONE=us-central1-c
export BIGQUERY_SECRET=bigquery
export HOSTNAME=stats-collector
export FQDN=stats-collector.kubeflow.org
export SERVICE_ACCOUNT=collector@${PROJECT}.iam.gserviceaccount.com
export DATASET=usage
export TABLE=collector
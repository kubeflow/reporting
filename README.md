## :warning: **kubeflow/reporting is not maintained**

This repository has been deprecated and [archived](https://github.com/kubeflow/community/issues/479) on Nov 30th, 2021. 



# Kubeflow Usage Reporting

This repository is devoted to collection and analysis of Kubeflow usage.

## Deploying Spartakus

We use [spartakus](https://github.com/kubernetes-incubator/spartakus) to report and collect metrics.

The collector is a web service that runs on GKE backed by BigQuery.

Below are instructions describing the process we followed to setup Kubeflow's production
instance of the collector.

Set relevant environment variables

```
. prod_env.sh
```

Create a cluster

```
gcloud container clusters create --project=kubeflow-usage reporting --zone=us-central1-c --machine-type=n1-standard-4
```

Create a static IP address to serve on

```
gcloud gcloud compute --project=${PROJECT} addresses create ${HOSTNAME} --global
```

Configure an A record for the kubeflow.org domain to map `$FQDN` to the static IP address obtained in the previous step.

Create the namespace for the collector.
```
kubectl create namespace kube-lego
kubectl create namespace ${NAMESPACE}
```

Create the BigQuery dataset and table

```
bq mk --project_id=${PROJECT} ${DATASET}
bq mk --project_id=${PROJECT} -t ${DATASET}.${TABLE} ~/git_spartakus/pkg/database/bigquery.schema.json
```

In GCP create a service account and download the private key

```
gcloud --project=${PROJECT} iam service-accounts create collector  --display-name="Spartakus collector."
gcloud projects add-iam-policy-binding ${PROJECT} --member=serviceAccount:${SERVICE_ACCOUNT} --role=roles/bigquery.dataEditor
gcloud --project=${PROJECT} iam service-accounts keys create \
    ${HOME}/secrets/key.${SERVICE_ACCOUNT}.json \
    --iam-account ${SERVICE_ACCOUNT}

kubectl -n ${NAMESPACE} create secret generic ${BIGQUERY_SECRET}  --from-file=bigquery.json=${HOME}/secrets/key.${SERVICE_ACCOUNT}.json
```

Deploy the collector

```
ks param set collector fqdn ${FQDN}
ks param set collector ipName ${HOSTNAME}
ks param set collector namespace ${NAMESPACE}
ks param set collector project ${PROJECT}
ks param set collector dataset ${DATASET}
ks param set collector table ${TABLE}

ks apply prod -c collector
```

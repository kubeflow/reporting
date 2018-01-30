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

Create a static IP address to serve on

```
gcloud gcloud compute --project=${PROJECT} addresses create usage-collector.kubeflow.org --global
```

Configure an A record for the kubeflow.org domain to map `$FQDN` to the static IP address obtained in the previous step.

Create the namespace for the collector.
```
kubectl create namespace ${NAMESPACE}
```

In GCP create a service account and download the private key

```
gcloud --project=${PROJECT} iam service-accounts create collector  --display-name="Spartakus collector."
gcloud --project=${PROJECT} iam service-accounts add-iam-policy-binding SERVICE_ACCOUNT --member=${SERVICE_ACCOUNT} --role=roles/bigquery.dataEditor
gcloud --project=${PROJECT} iam service-accounts keys create \
    ${HOME}/secrets/key.${SERVICE_ACCOUNT}.json \
    --iam-account ${SERVICE_ACCOUNT}

kubectl -n ${NAMESPACE} create secret generic ${SECRET_NAME}  --from-file=bigquery.json=${HOME}/secrets/key.${SERVICE_ACCOUNT}.json
```

Deploy the collector

```
ks apply prod -c collector
```

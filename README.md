# reporting
Repository for collecting and analyzing metrics about Kubeflow usage.

## Deploying Spartakus

We use [spartakus](https://github.com/kubernetes-incubator/spartakus) to report and collect metrics.

The collector is a web service that runs on GKE backed by BigQuery to collect metrics.
Below are instructions for deploying/managing the collector for Kubeflow.

The instructions below describe the process we followed to setup the collector for Kubeflow.

Create a static IP address to serve on

```
PROJECT=reporting
NAMESPACE=collector
CLUSTER=reporting
ZONE=us-central1-b
BIGQUERY_SECRET=bigquery
``````
gcloud gcloud compute --project=${PROJECT} addresses create usage-collector.kubeflow.org --global
```

Configure an A record for the kubeflow.org repo to map `$FQDN` to the static IP address obtained in
the previous step.

Create the namespace for the collector.
```
kubectl create namespace ${NAMESPACE}
```

In GCP create a service account and download the private key

```
ACCOUNT=collector@${PROJECT}.iam.gserviceaccount.com
gcloud --project=${PROJECT} iam service-accounts create collector  --display-name="Spartakus collector."
gcloud --project=${PROJECT} iam service-accounts add-iam-policy-binding SERVICE_ACCOUNT --member=${ACCOUNT} --role=roles/bigquery.dataEditor
gcloud --project=${PROJECT} iam service-accounts keys create \
    ${HOME}/secrets/key.${ACCOUNT}.json \
    --iam-account ${ACCOUNT}

kubectl -n ${NAMESPACE} create secret generic ${SECRET_NAME}  --from-file=bigquery.json=${HOME}/secrets/key.${ACCOUNT}.json
```

Deploy the collector

```
ks apply prod -c collector
```

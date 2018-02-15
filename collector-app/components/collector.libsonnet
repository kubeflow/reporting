{
  parts(namespace):: {
    all(fqdn, ipName, project, dataset, table):: [
      $.parts(namespace).service,
      $.parts(namespace).ingress(fqdn, ipName),
      $.parts(namespace).collector(project, dataset, table),
    ],

    collector(project, dataset, table):: {
      apiVersion: "extensions/v1beta1",
      kind: "Deployment",
      metadata: {
        labels: {
          app: "spartakus-collector",
        },
        name: "spartakus-collector",
        namespace: namespace,
      },
      spec: {
        replicas: 2,
        strategy: {
          rollingUpdate: {
            maxSurge: 1,
            maxUnavailable: 1,
          },
          type: "RollingUpdate",
        },
        template: {
          metadata: {
            labels: {
              app: "spartakus-collector",
            },
          },
          spec: {
            containers: [
              {
                args: [
                  "collector",
                  "--port=8080",
                  "--database=bigquery://" + project + "." + dataset + "." + table,
                ],
                env: [
                  {
                    name: "GOOGLE_APPLICATION_CREDENTIALS",
                    value: "/secrets/bigquery/bigquery.json",
                  },
                ],
                image: "gcr.io/google_containers/spartakus-amd64:v1.0.0",
                livenessProbe: {
                  failureThreshold: 2,
                  httpGet: {
                    path: "/healthz",
                    port: 8080,
                  },
                  initialDelaySeconds: 3,
                  timeoutSeconds: 2,
                },
                name: "spartakus-collector",
                ports: [
                  {
                    containerPort: 8080,
                    protocol: "TCP",
                  },
                ],
                resources: {
                  limits: {
                    cpu: 0.5,
                    memory: "128Mi",
                  },
                },
                volumeMounts: [
                  {
                    mountPath: "/secrets/bigquery",
                    name: "bigquery",
                    readOnly: true,
                  },
                ],
              },
            ],
            terminationGracePeriodSeconds: 30,
            volumes: [
              {
                name: "bigquery",
                secret: {
                  secretName: "bigquery",
                },
              },
            ],
          },
        },
      },
    },  // collector

    // fqdn Fully qualified domain name for the service.
    // ipName name of the GCP static ip to use.
    ingress(fqdn, ipName):: {
      apiVersion: "extensions/v1beta1",
      kind: "Ingress",
      metadata: {
        annotations: {
          "kubernetes.io/ingress.global-static-ip-name": ipName,
          "kubernetes.io/tls-acme": "true",
        },
        labels: {
          app: "spartakus-collector",
        },
        name: "spartakus-collector",
        namespace: namespace,
      },
      spec: {
        rules: [
          {
            host: fqdn,
            http: {
              paths: [
                {
                  backend: {
                    serviceName: "kube-lego",
                    servicePort: "http",
                  },
                  path: "/.well-known/*",
                },
                {
                  backend: {
                    serviceName: "spartakus-collector",
                    servicePort: "http",
                  },
                  path: "/*",
                },
              ],
            },
          },
        ],
        tls: [
          {
            hosts: [
              fqdn,
            ],
            secretName: "spartakus-collector-tls",
          },
        ],
      },
    },  // ingress

    service:: {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        labels: {
          app: "spartakus-collector",
        },
        name: "spartakus-collector",
        namespace: namespace,
      },
      spec: {
        ports: [
          {
            name: "http",
            port: 80,
            targetPort: 8080,
          },
        ],
        selector: {
          app: "spartakus-collector",
        },
        type: "NodePort",
      },
    },  // service
  },  // parts
}

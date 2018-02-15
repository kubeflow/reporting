{
  parts(namespace):: {
    all(email):: [
      $.parts(namespace).configMap(email),
      $.parts(namespace).deployment,
      $.parts(namespace).role,
      $.parts(namespace).roleBinding,
      $.parts(namespace).service,
      $.parts(namespace).serviceAccount,
    ],

    role:: {
      apiVersion: "rbac.authorization.k8s.io/v1beta1",
      kind: "ClusterRole",
      metadata: {
        name: "kube-lego",
      },
      rules: [
        {
          apiGroups: [
            "",
          ],
          resources: [
            "pods",
          ],
          verbs: [
            "get",
            "list",
          ],
        },
        {
          apiGroups: [
            "",
          ],
          resources: [
            "services",
            "endpoints",
          ],
          verbs: [
            "create",
            "get",
            "delete",
            "update",
          ],
        },
        {
          apiGroups: [
            "extensions",
          ],
          resources: [
            "ingresses",
          ],
          verbs: [
            "get",
            "update",
            "create",
            "list",
            "patch",
            "delete",
            "watch",
          ],
        },
        {
          apiGroups: [
            "",
          ],
          resources: [
            "endpoints",
            "secrets",
          ],
          verbs: [
            "get",
            "create",
            "update",
          ],
        },
      ],
    },  // clusterRole

    roleBinding:: {
      apiVersion: "rbac.authorization.k8s.io/v1beta1",
      kind: "ClusterRoleBinding",
      metadata: {
        name: "kube-lego",
        namespace: namespace,
      },
      roleRef: {
        apiGroup: "rbac.authorization.k8s.io",
        kind: "ClusterRole",
        name: "kube-lego",
      },
      subjects: [
        {
          kind: "ServiceAccount",
          name: "kube-lego",
          namespace: namespace,
        },
      ],
    },  // roleBinding

    // TODO(jlewi): This isn't actually used since we set the environment variables directly 
    // on the deloyment.
    configMap(email):: {
      apiVersion: "v1",
      data: {
        "lego.email": email,
        // TODO(jlewi): Switch to prod endpoint once its working
        // "lego.url": "https://acme-v01.api.letsencrypt.org/directory",
        "lego.url": "https://acme-staging.api.letsencrypt.org/directory",
      },
      kind: "ConfigMap",
      metadata: {
        name: "kube-lego",
        namespace: namespace,
      },
    },  // ConfigMap

    deployment:: {
      apiVersion: "extensions/v1beta1",
      kind: "Deployment",
      metadata: {
        name: "kube-lego",
        namespace: namespace,
      },
      spec: {
        replicas: 1,
        template: {
          metadata: {
            labels: {
              app: "kube-lego",
            },
          },
          spec: {
            containers: [
              {
                env: [
                  {
                    name: "LEGO_LOG_LEVEL",
                    value: "debug",
                  },
                  {
                    name: "LEGO_EMAIL",
                    value: "jlewi@google.com",
                  },
                  {
                    name: "LEGO_URL",
                    value: "https://acme-v01.api.letsencrypt.org/directory",
                  },
                  {
                    name: "LEGO_NAMESPACE",
                    valueFrom: {
                      fieldRef: {
                        fieldPath: "metadata.namespace",
                      },
                    },
                  },
                  {
                    name: "LEGO_POD_IP",
                    valueFrom: {
                      fieldRef: {
                        fieldPath: "status.podIP",
                      },
                    },
                  },
                ],
                image: "jetstack/kube-lego:0.1.5",
                imagePullPolicy: "Always",
                name: "kube-lego",
                ports: [
                  {
                    containerPort: 8080,
                  },
                ],
                readinessProbe: {
                  httpGet: {
                    path: "/healthz",
                    port: 8080,
                  },
                  initialDelaySeconds: 5,
                  timeoutSeconds: 1,
                },
              },
            ],
            serviceAccountName: "kube-lego",
          },
        },
      },
    },  // deployment

    serviceAccount:: {
      apiVersion: "v1",
      kind: "ServiceAccount",
      metadata: {
        name: "kube-lego",
        namespace: namespace,
      },
    },  // serviceAccount

    service:: {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        labels: {
          app: "kube-lego",
        },
        name: "kube-lego",
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
          app: "kube-lego",
        },
        type: "NodePort",
      },
    },  // service
  },  // parts
}

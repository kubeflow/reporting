{
  global: {
    // User-defined global parameters; accessible to all component and environments, Ex:
    // replicas: 4,
  },
  components: {
    // Component-level parameters, defined initially from 'ks prototype use ...'
    // Each object below should correspond to a component in the components/ directory
    collector:: {
      ipName: "usage-collector.kubeflow.org",
      namespace: "collector",
      project: "reporting",
      dataset: "usage",
      table: "collector",
    },
  },
}

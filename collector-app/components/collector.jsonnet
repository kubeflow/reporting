local params = std.extVar("__ksonnet/params").components.collector;

local k = import 'k.libsonnet';
local collector = import 'collector.libsonnet';
local lego = import 'kube_lego.libsonnet';
local namespace = params.namespace;

std.prune(k.core.v1.list.new(
  collector.parts(namespace).all(params.fqdn, params.ipName, params.project, params.dataset, params.table) +
  lego.parts(namespace).all(params.kubeLegoEmail),
))

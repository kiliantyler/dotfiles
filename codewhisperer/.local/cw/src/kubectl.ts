// Internal scripts for this spec, not to be confused with the script property
const scripts = {
  types: ["kubectl", "api-resources", "-o", "name"],
  typeWithoutName: function (type, namespace) {
    if (namespace == "all") {
      return "";
    }
    return [
      "kubectl",
      "get",
      type,
      "-n",
      namespace,
      "-o",
      "custom-columns=:.metadata.name",
    ];
  },
  namespaces: [
    "kubectl",
    "get",
    "namespaces",
    "--no-headers",
    "-o",
    "custom-columns=:.metadata.name",
  ],
  getNamespace: function (context) {
    const allIndex = context.indexOf("-A");
    if (allIndex !== -1) {
      return "all";
    }
    const nIndex = context.indexOf("-n");
    if (nIndex !== -1) {
      return context[nIndex + 1];
    }
    const namespaceIndex = context.indexOf("--namespace");
    if (namespaceIndex !== -1) {
      return context[namespaceIndex + 1];
    }
    return "default";
  },
};

const sharedPostProcessChecks = {
  connectedToCluster: (out) => {
    return out.includes("The connection to the server");
  },
  generalError: (out) => {
    return out.includes("error:");
  },
};

const sharedPostProcess: Fig.Generator["postProcess"] = (out) => {
  if (
    sharedPostProcessChecks.connectedToCluster(out) ||
    sharedPostProcessChecks.generalError(out)
  ) {
    return [];
  }
  return out.split("\n").map((item) => ({
    name: item,
    icon: "fig://icon?type=kubernetes",
    priority: item === "kubectl" ? -1 : undefined,
    description: item === "kubectl" ? "kubectl command" : undefined,
  })) as Fig.Suggestion[];
};

const sharedArgs: Record<string, Fig.Arg> = {
  resourcesArg: {
    name: "Resource Type",
    generators: {
      script: scripts.types,
      cache: {
        strategy: "stale-while-revalidate",
        ttl: 1000 * 60 * 60,
      },
      postProcess: sharedPostProcess,
    },
  },
  namespaces: {
    name: "Namespace",
    generators: {
      script: scripts.namespaces,
      postProcess: sharedPostProcess,
    },
  },
  runningPodsArg: {
    name: "Running Pods",
    generators: {
      script: function (context) {
        const index = context.indexOf("-n");
        if (index !== -1) {
          return [
            "kubectl",
            "get",
            "pods",
            "--field-selector=status.phase=Running",
            "-n",
            context[index + 1],
            "-o",
            "name",
          ];
        }
        return [
          "kubectl",
          "get",
          "pods",
          "--field-selector=status.phase=Running",
          "-o",
          "name",
        ];
      },
      postProcess: sharedPostProcess,
    },
  },
  resourceSuggestionsFromResourceType: {
    name: "Resource",
    generators: {
      script: function (context) {
        const resourceType = context[context.length - 2];
        const namespace = scripts.getNamespace(context);
        return scripts.typeWithoutName(resourceType, namespace);
      },
      postProcess: sharedPostProcess,
      cache: {
        strategy: "stale-while-revalidate",
        ttl: 1000 * 60 * 60,
      },
    },
    isOptional: true,
  },
  listKubeConfContexts: {
    name: "Context",
    generators: {
      script: function (context) {
        const index = context.indexOf("--kubeconfig");
        if (index !== -1) {
          return [
            "kubectl",
            "config",
            `--kubeconfig=${context[index + 1]}`,
            "get-contexts",
            "-o",
            "name",
          ];
        }
        return ["kubectl", "config", "get-contexts", "-o", "name"];
      },
      postProcess: sharedPostProcess,
    },
  },
  listDeployments: {
    name: "Deployments",
    generators: {
      script: scripts.typeWithoutName("deployments", "default"),
      postProcess: sharedPostProcess,
      cache: {
        strategy: "stale-while-revalidate",
        ttl: 1000 * 60 * 60,
      },
    },
  },
  listClusters: {
    name: "Cluster",
    generators: {
      script: function (context) {
        const index = context.indexOf("--kubeconfig");
        if (index !== -1) {
          return [
            "kubectl",
            "config",
            `--kubeconfig=${context[index + 1]}`,
            "get-clusters",
          ];
        }
        return ["kubectl", "config", "get-clusters"];
      },
      postProcess: function (out) {
        if (
          sharedPostProcessChecks.connectedToCluster(out) ||
          sharedPostProcessChecks.generalError(out)
        ) {
          return [];
        }
        return out
          .split("\n")
          .filter((line) => line !== "NAME")
          .map((line) => ({
            name: line,
            icon: "fig://icon?type=kubernetes",
          }));
      },
    },
  },
  typeOrTypeSlashName: {
    name: "TYPE | TYPE/NAME",
    generators: {
      script: function (context) {
        const lastInput = context[context.length - 1];
        if (lastInput.includes("/")) {
          return scripts.typeWithoutName(
            lastInput.substring(0, lastInput.indexOf("/")),
            "default"
          );
        }
        return scripts.types;
      },
      postProcess: sharedPostProcess,
      trigger: "/",
      getQueryTerm: "/",
      cache: {
        strategy: "stale-while-revalidate",
        ttl: 1000 * 60 * 60,
      },
    },
  },
  listNodes: {
    name: "Node",
    generators: {
      script: scripts.typeWithoutName("nodes", "default"),
      postProcess: sharedPostProcess,
      cache: {
        strategy: "stale-while-revalidate",
        ttl: 1000 * 60 * 60,
      },
    },
  },
  listClusterRoles: {
    name: "Cluster Role",
    generators: {
      script: scripts.typeWithoutName("clusterroles", "default"),
      postProcess: sharedPostProcess,
      cache: {
        strategy: "stale-while-revalidate",
        ttl: 1000 * 60 * 60,
      },
    },
  },
  listContainersFromPod: {
    name: "Container",
    generators: {
      script: (context) => {
        const podIndex = context.findIndex(
          (i) =>
            i === "pods" ||
            i.includes("pods/") ||
            i === "pod" ||
            i.includes("pod/")
        );
        const podName = context[podIndex].includes("/")
          ? context[podIndex]
          : `${context[podIndex]} + ${context[podIndex + 1]}`;
        return ["kubectl", "get", podName, "-o", "json"];
      },
      postProcess: function (out) {
        if (
          sharedPostProcessChecks.connectedToCluster(out) ||
          sharedPostProcessChecks.generalError(out)
        ) {
          return [];
        }
        return JSON.parse(out).spec.containers.map((item) => ({
          name: item.name,
          description: item.image,
          icon: "fig://icon?type=kubernetes",
        }));
      },
    },
  },
};

const sharedOpts: Record<string, Fig.Option> = {
  filename: {
    name: ["-f", "--filename"],
    description:
      "Filename, directory, or URL to files identifying the resource",
    args: {
      name: "File",
      template: "filepaths",
    },
  },
  kustomize: {
    name: ["-k", "--kustomize"],
    description:
      "Process the kustomization directory. This flag can't be used together with -f or -R",
    args: {
      name: "Kustomize Dir",
      template: "folders",
    },
  },
  output: {
    name: ["-o", "--output"],
    description:
      "Output format. One of: json|yaml|name|go-template|go-template-file|template|templatefile|jsonpath|jsonpath-file",
    args: {
      name: "Output Format",
      suggestions: [
        "json",
        "yaml",
        "name",
        "go-template",
        "go-template-file",
        "template",
        "templatefile",
        "jsonpath",
        "jsonpath-file",
      ],
    },
  },
  resourceVersion: {
    name: "--resource-version",
    requiresSeparator: true,
    description:
      "If non-empty, the annotation update will only succeed if this is the current resource-version for the object. Only valid when specifying a single resource",
    args: {},
  },
  dryRun: {
    name: "--dry-run",
    requiresSeparator: true,
    description:
      'Must be "none", "server", or "client". If client strategy, only print the object that would be sent, without sending it. If server strategy, submit server-side request without persisting the resource',
    args: {
      name: "Strategy",
      suggestions: ["none", "server", "client"],
    },
  },
  fieldSelector: {
    name: "--field-selector",
    requiresSeparator: true,
    description:
      "Selector (field query) to filter on, supports '=', '==', and '!='.(e.g. --field-selector key1=value1,key2=value2). The server only supports a limited number of field queries per type",
    args: {},
  },
  local: {
    name: "--local",
    description:
      "If true, annotation will NOT contact api-server but run locally",
  },
  allResources: {
    name: "--all",
    description:
      "Select all resources, including uninitialized ones, in the namespace of the specified resource types",
  },
  allowMissingTemplateKeys: {
    name: "--allow-missing-template-keys",
    description:
      "If true, ignore any errors in templates when a field or map key is missing in the template. Only applies to golang and jsonpath output formats",
  },
  recursive: {
    name: ["-R", "--recursive"],
    description:
      "Process the directory used in -f, --filename recursively. Useful when you want to manage related manifests organized within the same directory",
  },
  selector: {
    name: ["-l", "--selector"],
    description:
      "Selector (label query) to filter on, not including uninitialized ones, supports '=', '==', and '!='.(e.g. -l key1=value1,key2=value2)",
    args: {},
  },
  template: {
    name: "--template",
    requiresSeparator: true,
    description:
      "Template string or path to template file to use when -o=go-template, -o=go-template-file. The template format is golang templates [http://golang.org/pkg/text/template/#pkg-overview]",
    args: {},
  },
  overwrite: {
    name: "--overwrite",
    description:
      "If true, allow annotations to be overwritten, otherwise reject annotation updates that overwrite existing annotations",
  },
  record: {
    name: "--record",
    description:
      "Record current kubectl command in the resource annotation. If set to false, do not record the command. If set to true, record the command. If not set, default to updating the existing annotation value only if one already exists",
  },
};

const sharedOptsArray = Object.values(sharedOpts);

const completionSpec: Fig.Spec = {
  name: "kubectl",
  description: "",
  subcommands: [
    { name: ["alpha"], // Done
      description:
        "These commands correspond to alpha features that are not enabled in Kubernetes clusters by default",
        priority: 51
    },
    { name: ["get"], // TODO:
      description: "Display one or many resources",
      priority: 51
    },
    { name: ["help"], // TODO: Missing `get`
      description: "Help about any command",
      priority: 51,
      subcommands: [
        { name: ["alpha"], description: "Commands for features in alpha" },
        { name: ["annotate"],
          description: "Update the annotations on a resource",
        },
        { name: ["api-resources"],
          description: "Print the supported API resources on the server",
        },
        { name: ["api-versions"],
          description:
            'Print the supported API versions on the server, in the form of "group/version"',
        },
        { name: ["apply"],
          description:
            "Apply a configuration to a resource by file name or stdin",
          subcommands: [
            { name: ["edit-last-applied"],
              description:
                "Edit latest last-applied-configuration annotations of a resource/object",
            },
            { name: ["set-last-applied"],
              description:
                "Set the last-applied-configuration annotation on a live object to match the contents of a file",
            },
            { name: ["view-last-applied"],
              description:
                "View the latest last-applied-configuration annotations of a resource/object",
            },
          ],
        },
        { name: ["attach"], description: "Attach to a running container" },
        { name: ["auth"],
          description: "Inspect authorization",
          subcommands: [
            { name: ["can-i"],
              description: "Check whether an action is allowed",
            },
            { name: ["reconcile"],
              description:
                "Reconciles rules for RBAC role, role binding, cluster role, and cluster role binding objects",
            },
            { name: ["whoami"],
              description: "Experimental: Check self subject attributes",
            },
          ],
        },
        { name: ["autoscale"],
          description:
            "Auto-scale a deployment, replica set, stateful set, or replication controller",
        },
        { name: ["certificate"],
          description: "Modify certificate resources",
          subcommands: [
            { name: ["approve"],
              description: "Approve a certificate signing request",
            },
            { name: ["deny"],
              description: "Deny a certificate signing request",
            },
          ],
        },
        { name: ["cluster-info"],
          description: "Display cluster information",
          subcommands: [
            { name: ["dump"],
              description:
                "Dump relevant information for debugging and diagnosis",
            },
          ],
        },
        { name: ["completion"],
          description:
            "Output shell completion code for the specified shell (bash, zsh, fish, or powershell)",
        },
        { name: ["config"],
          description: "Modify kubeconfig files",
          subcommands: [
            { name: ["current-context"],
              description: "Display the current-context",
            },
            { name: ["delete-cluster"],
              description: "Delete the specified cluster from the kubeconfig",
            },
            { name: ["delete-context"],
              description: "Delete the specified context from the kubeconfig",
            },
            { name: ["delete-user"],
              description: "Delete the specified user from the kubeconfig",
            },
            { name: ["get-clusters"],
              description: "Display clusters defined in the kubeconfig",
            },
            { name: ["get-contexts"],
              description: "Describe one or many contexts",
            },
            { name: ["get-users"],
              description: "Display users defined in the kubeconfig",
            },
            { name: ["rename-context"],
              description: "Rename a context from the kubeconfig file",
            },
            { name: ["set"],
              description: "Set an individual value in a kubeconfig file",
            },
            { name: ["set-cluster"],
              description: "Set a cluster entry in kubeconfig",
            },
            { name: ["set-context"],
              description: "Set a context entry in kubeconfig",
            },
            { name: ["set-credentials"],
              description: "Set a user entry in kubeconfig",
            },
            { name: ["unset"],
              description: "Unset an individual value in a kubeconfig file",
            },
            { name: ["use", "use-context"],
              description: "Set the current-context in a kubeconfig file",
            },
            { name: ["view"],
              description:
                "Display merged kubeconfig settings or a specified kubeconfig file",
            },
          ],
        },
        { name: ["cordon"], description: "Mark node as unschedulable" },
        { name: ["cp"],
          description: "Copy files and directories to and from containers",
        },
        { name: ["create"],
          description: "Create a resource from a file or from stdin",
          subcommands: [
            { name: ["clusterrole"], description: "Create a cluster role" },
            { name: ["clusterrolebinding"],
              description:
                "Create a cluster role binding for a particular cluster role",
            },
            { name: ["cm", "configmap"],
              description:
                "Create a config map from a local file, directory or literal value",
            },
            { name: ["cj", "cronjob"],
              description: "Create a cron job with the specified name",
            },
            { name: ["deploy", "deployment"],
              description: "Create a deployment with the specified name",
            },
            { name: ["ing", "ingress"],
              description: "Create an ingress with the specified name",
            },
            { name: ["job"],
              description: "Create a job with the specified name",
            },
            { name: ["ns", "namespace"],
              description: "Create a namespace with the specified name",
            },
            { name: ["pdb", "poddisruptionbudget"],
              description:
                "Create a pod disruption budget with the specified name",
            },
            { name: ["pc", "priorityclass"],
              description: "Create a priority class with the specified name",
            },
            { name: ["resourcequota", "quota"],
              description: "Create a quota with the specified name",
            },
            { name: ["role"], description: "Create a role with single rule" },
            { name: ["rolebinding"],
              description:
                "Create a role binding for a particular role or cluster role",
            },
            { name: ["secret"],
              description: "Create a secret using a specified subcommand",
              subcommands: [
                { name: ["docker-registry"],
                  description: "Create a secret for use with a Docker registry",
                },
                { name: ["generic"],
                  description:
                    "Create a secret from a local file, directory, or literal value",
                },
                { name: ["tls"], description: "Create a TLS secret" },
              ],
            },
            { name: ["svc", "service"],
              description: "Create a service using a specified subcommand",
              subcommands: [
                { name: ["clusterip"],
                  description: "Create a ClusterIP service",
                },
                { name: ["externalname"],
                  description: "Create an ExternalName service",
                },
                { name: ["loadbalancer"],
                  description: "Create a LoadBalancer service",
                },
                { name: ["nodeport"],
                  description: "Create a NodePort service",
                },
              ],
            },
            { name: ["sa", "serviceaccount"],
              description: "Create a service account with the specified name",
            },
            { name: ["token"], description: "Request a service account token" },
          ],
        },
        { name: ["debug"],
          description:
            "Create debugging sessions for troubleshooting workloads and nodes",
        },
        { name: ["delete"],
          description:
            "Delete resources by file names, stdin, resources and names, or by resources and label selector",
        },
        { name: ["describe"],
          description:
            "Show details of a specific resource or group of resources",
        },
        { name: ["diff"],
          description:
            "Diff the live version against a would-be applied version",
        },
        { name: ["drain"],
          description: "Drain node in preparation for maintenance",
        },
        { name: ["edit"], description: "Edit a resource on the server" },
        { name: ["events"], description: "List events" },
        { name: ["exec"], description: "Execute a command in a container" },
        { name: ["explain"], description: "Get documentation for a resource" },
        { name: ["expose"],
          description:
            "Take a replication controller, service, deployment or pod and expose it as a new Kubernetes service",
        },
        { name: ["kustomize"],
          description: "Build a kustomization target from a directory or URL",
        },
        { name: ["label"], description: "Update the labels on a resource" },
        { name: ["logs"],
          description: "Print the logs for a container in a pod",
        },
        { name: ["options"],
          description: "Print the list of flags inherited by all commands",
        },
        { name: ["patch"], description: "Update fields of a resource" },
        { name: ["plugin"],
          description: "Provides utilities for interacting with plugins",
          subcommands: [
            { name: ["list"],
              description:
                "List all visible plugin executables on a user's PATH",
            },
          ],
        },
        { name: ["port-forward"],
          description: "Forward one or more local ports to a pod",
        },
        { name: ["proxy"],
          description: "Run a proxy to the Kubernetes API server",
        },
        { name: ["replace"],
          description: "Replace a resource by file name or stdin",
        },
        { name: ["rollout"],
          description: "Manage the rollout of a resource",
          subcommands: [
            { name: ["history"], description: "View rollout history" },
            { name: ["pause"],
              description: "Mark the provided resource as paused",
            },
            { name: ["restart"], description: "Restart a resource" },
            { name: ["resume"], description: "Resume a paused resource" },
            { name: ["status"], description: "Show the status of the rollout" },
            { name: ["undo"], description: "Undo a previous rollout" },
          ],
        },
        { name: ["run"], description: "Run a particular image on the cluster" },
        { name: ["scale"],
          description:
            "Set a new size for a deployment, replica set, or replication controller",
        },
        { name: ["set"],
          description: "Set specific features on objects",
          subcommands: [
            { name: ["env"],
              description: "Update environment variables on a pod template",
            },
            { name: ["image"],
              description: "Update the image of a pod template",
            },
            { name: ["resources"],
              description:
                "Update resource requests/limits on objects with pod templates",
            },
            { name: ["selector"],
              description: "Set the selector on a resource",
            },
            { name: ["sa", "serviceaccount"],
              description: "Update the service account of a resource",
            },
            { name: ["subject"],
              description:
                "Update the user, group, or service account in a role binding or cluster role binding",
            },
          ],
        },
        { name: ["taint"],
          description: "Update the taints on one or more nodes",
        },
        { name: ["top"],
          description: "Display resource (CPU/memory) usage",
          subcommands: [
            { name: ["nodes", "no", "node"],
              description: "Display resource (CPU/memory) usage of nodes",
            },
            { name: ["pods", "po", "pod"],
              description: "Display resource (CPU/memory) usage of pods",
            },
          ],
        },
        { name: ["uncordon"], description: "Mark node as schedulable" },
        { name: ["version"],
          description: "Print the client and server version information",
        },
        { name: ["wait"],
          description:
            "Experimental: Wait for a specific condition on one or many resources",
        },
      ],
    },
    { name: ["options"],
      description: "Print the list of flags inherited by all commands",
      priority: 51
    },
    { name: ["version"],
      description: "Print the client and server version information",
      options: [
        { name: ["--client"],
          description:
            "If true, shows client version only (no server required).",
          priority: 51
        },
        { name: ["--output", "-o"],
          description: "One of 'yaml' or 'json'.",
          args: [ { name: "output",
              suggestions: ["yaml", "json"],
            }
          ],
          priority: 51
        },
      ],
      priority: 51
  },
  ],
  options: [
    { name: ["--as"],
      description:
        "Username to impersonate for the operation. User could be a regular user or a service account in a namespace.",
      isPersistent: true,
      args: [{ name: "as" }],
      priority: 1
    },
    { name: ["--as-group"],
      description:
        "Group to impersonate for the operation, this flag can be repeated to specify multiple groups.",
      isPersistent: true,
      isRepeatable: true,
      args: [{ name: "as-group" }],
      priority: 1
    },
    { name: ["--as-uid"],
      description: "UID to impersonate for the operation.",
      isPersistent: true,
      args: [{ name: "as-uid" }],
      priority: 1
    },
    { name: ["--cache-dir"],
      description: "Default cache directory",
      isPersistent: true,
      args: [{ name: "cache-dir", default: "~/.kube/cache" }],
      priority: 1
    },
    { name: ["--certificate-authority"],
      description: "Path to a cert file for the certificate authority",
      isPersistent: true,
      args: [{ name: "certificate-authority" }],
      priority: 1
    },
    { name: ["--client-certificate"],
      description: "Path to a client certificate file for TLS",
      isPersistent: true,
      args: [{ name: "client-certificate" }],
      priority: 1
    },
    { name: ["--client-key"],
      description: "Path to a client key file for TLS",
      isPersistent: true,
      args: [{ name: "client-key" }],
      priority: 1
    },
    { name: ["--cluster"],
      description: "The name of the kubeconfig cluster to use",
      isPersistent: true,
      args: [{ name: "cluster" }],
      priority: 1
    },
    { name: ["--context"],
      description: "The name of the kubeconfig context to use",
      isPersistent: true,
      args: [{ name: "context" }],
      priority: 49
    },
    { name: ["--disable-compression"],
      description:
        "If true, opt-out of response compression for all requests to the server",
      isPersistent: true,
      priority: 1
    },
    { name: ["--insecure-skip-tls-verify"],
      description:
        "If true, the server's certificate will not be checked for validity. This will make your HTTPS connections insecure",
      isPersistent: true,
      priority: 1
    },
    { name: ["--kubeconfig"],
      description: "Path to the kubeconfig file to use for CLI requests.",
      isPersistent: true,
      args: [{ name: "kubeconfig" }],
      priority: 49
    },
    { name: ["--log-flush-frequency"],
      description: "Maximum number of seconds between log flushes",
      isPersistent: true,
      args: [{ name: "log-flush-frequency", default: "5s" }],
      priority: 1
    },
    { name: ["--match-server-version"],
      description: "Require server version to match client version",
      isPersistent: true,
      priority: 1
    },
    { name: ["--namespace", "-n"],
      description: "If present, the namespace scope for this CLI request",
      isPersistent: true,
      args: sharedArgs.namespaces,
      priority: 49
    },
    { name: ["--password"],
      description: "Password for basic authentication to the API server",
      isPersistent: true,
      args: [{ name: "password" }],
      priority: 1
    },
    { name: ["--profile"],
      description:
        "Name of profile to capture. One of (none|cpu|heap|goroutine|threadcreate|block|mutex)",
      isPersistent: true,
      args: [{ name: "profile", default: "none" }],
      priority: 1
    },
    { name: ["--profile-output"],
      description: "Name of the file to write the profile to",
      isPersistent: true,
      args: [{ name: "profile-output", default: "profile.pprof" }],
      priority: 1
    },
    { name: ["--request-timeout"],
      description:
        "The length of time to wait before giving up on a single server request. Non-zero values should contain a corresponding time unit (e.g. 1s, 2m, 3h). A value of zero means don't timeout requests.",
      isPersistent: true,
      args: [{ name: "request-timeout", default: "0" }],
      priority: 1
    },
    { name: ["--server", "-s"],
      description: "The address and port of the Kubernetes API server",
      isPersistent: true,
      args: [{ name: "server" }],
      priority: 1
    },
    { name: ["--tls-server-name"],
      description:
        "Server name to use for server certificate validation. If it is not provided, the hostname used to contact the server is used",
      isPersistent: true,
      args: [{ name: "tls-server-name" }],
      priority: 1
    },
    { name: ["--token"],
      description: "Bearer token for authentication to the API server",
      isPersistent: true,
      args: [{ name: "token" }],
      priority: 1
    },
    { name: ["--user"],
      description: "The name of the kubeconfig user to use",
      isPersistent: true,
      args: [{ name: "user" }],
      priority: 1
    },
    { name: ["--username"],
      description: "Username for basic authentication to the API server",
      isPersistent: true,
      args: [{ name: "username" }],
      priority: 1
    },
    { name: ["--v", "-v"],
      description: "number for the log level verbosity",
      isPersistent: true,
      args: [{ name: "v", default: "0" }],
      priority: 20
    },
    { name: ["--vmodule"],
      description:
        "comma-separated list of pattern=N settings for file-filtered logging (only works for the default text log format)",
      isPersistent: true,
      args: [{ name: "vmodule" }],
      priority: 1
    },
    { name: ["--warnings-as-errors"],
      description:
        "Treat warnings received from the server as errors and exit with a non-zero exit code",
      isPersistent: true,
      priority: 1
    },
    { name: ["--help", "-h"],
      description: "Display help",
      isPersistent: true,
      priority: 49
    },
  ],
};

export default completionSpec;

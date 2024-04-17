// Kubecolor (https://github.com/kubecolor/kubecolor) takes identical arguments to kubectl with some additions

import completionSpec from "./kubectl"

completionSpec["options"] = completionSpec["options"].concat([
  {
    name: ["--kubecolor-version"],
    description: "Show kubecolor version",
    isPersistent: true,
  },
  {
    name: ["--kubecolor-version"],
    description: "Show kubecolor version",
    isPersistent: true,
  },
  {
    name: ["--light-background"],
    description: "Use light background color scheme",
    isPersistent: true,
  },
  {
    name: ["--force-colors"],
    description: "Force color output even when the tty is non-terminal",
    isPersistent: true,
  },
  {
    name: ["--plain"],
    description: "Disable color output",
    isPersistent: true,
  },
])


export default completionSpec;

const completionSpec: Fig.Spec = {
  name: "aliae",
  description: "",
  subcommands: [
    {
      name: "completion",
      description: "Generate Completions",
      subcommands: [
        {
          name: "bash",
          description: "Get completions for the Bash shell"
        },
        {
          name: "fish",
          description: "Get completions for the Fish shell"
        },
        {
          name: "powershell",
          description: "Get completions for Powershell"
        },
        {
          name: "zsh",
          description: "Get completions for the Zsh shell"
        },
      ],
    },
    {
      name: "get",
      description: "Get a value from aliae",
      subcommands: [
        {
          name: "shell",
          description: "Get the current shell"
        },
      ],
    },
    {
      name: "help",
      description: "Show help for aliae",
    },
    {
      name: "init",
      description: "Print the evals for the specified shell",
      subcommands: [
        {
          name: "bash",
          description: "Print the evals for the Bash shell"
        },
        {
          name: "fish",
          description: "Print the evals for the Fish shell"
        },
        {
          name: "pwsh",
          description: "Print the evals for Powershell"
        },
        {
          name: "zsh",
          description: "Print the evals for the Zsh shell"
        },
        {
          name: "cmd",
          description: "Print the evals for cmdprompt"
        },
        {
          name: "nu",
          description: "Print the evals for nu shell"
        },
        {
          name: "tcsh",
          description: "Print the evals for the tcsh shell"
        },
        {
          name: "xonsh",
          description: "Print the evals for the xonsh shell"
        }
      ]
    },
    {
      name: "version",
      description: "Show version for aliae",
    }
  ],
  options: [{
    name: ["--help", "-h"],
    description: "Show help for aliae",
    isPersistent: true,
  },
  {
    name: ["--version"],
    description: "Show version for aliae",
  },
  {
    name: ["--config", "-c"],
    description: "Path to config file",
    isPersistent: true,
  }
  ],
  // Only uncomment if aliae takes an argument
  // args: {}
};
export default completionSpec;

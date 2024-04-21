const pluginList: Fig.Generator = {
  custom: async (_tokens, executeCommand, context) => {
    try {
      const { stdout } = await executeCommand({
        command: "command",
        args: [
          "ls",
          "-1", `${context.environmentVariables["HOME"]}/.local/share/zinit/plugins`
        ],
      });
      const out = stdout.split("\n");
      // Loop through the Out and replace '--' with '/'
      for (let i = 0; i < out.length; i++) {
        // if the string starts with '_local' remove the entry from the list
        if (out[i].startsWith("_local")) {
          out.splice(i, 1);
        }
        out[i] = out[i].replace("---", "/");
      }
      if (out.length == 0) {
        return [];
      }
      return out.map((plugin) => ({
        name: plugin,
        icon: "fig://icon?type=package",
      }));
    } catch (error) {
      return [{ name: "Error loading plugins" }];
    }
  },
};

// const snippetList: Fig.Generator = {
//   custom: async (_tokens, executeCommand, context) => {
//     try {
//       const { stdout } = await executeCommand({
//         command: "command",
//         args: [
//           "ls",
//           "-1", `${context.environmentVariables["HOME"]}/.local/share/zinit/snippets`
//         ],
//       });
//       const folders = stdout.split("\n");
//       if (folders.length == 0) {
//         return [];
//       }
//       var snippets = []
//       for (let i = 0; i < folders.length; i++) {
//         const { stdout } = await executeCommand({
//           command: "command",
//           args: [
//             "ls",
//             "-1", `${context.environmentVariables["HOME"]}/.local/share/zinit/snippets/${folders[i]}`
//           ]
//         });
//         const out = stdout.split("\n");
//         for (let n = 0; n < out.length; n++) {
//           snippets.push(folders[i].split('--').pop() + "/" + out[n])
//         }
//       }
//       return snippets.map((snippet) => ({
//         name: snippet,
//         icon: "fig://icon?type=package",
//       }));
//     } catch (error) {
//       return [{ name: "Error loading snippets" }];
//     }
//   },
// };

const completionList: Fig.Generator = {
  custom: async (_tokens, executeCommand, context) => {
    try {
      const { stdout } = await executeCommand({
        command: "command",
        args: [
          "ls",
          "-1", `${context.environmentVariables["HOME"]}/.local/share/zinit/completions`
        ],
      });
      const out = stdout.split("\n");
      // Loop through the Out and remove the leading '_'
      for (let i = 0; i < out.length; i++) {
        out[i] = out[i].replace("_", "");
      }
      return out.map((completion) => ({
        name: completion,
        icon: "fig://template?color=2ecc71&badge=_",
      }));
    } catch (error) {
      return [{ name: "Error loading plugins", priority: 1 }];
    }
  },
};

const commandList: Fig.Generator = {
  script: [
    "bash",
    "-c",
    `for i in $(echo $PATH | tr ":" "\n"); do find $i -maxdepth 1 -perm -111 -type f; done`,
  ],
  postProcess: (out) =>
    out
      .split("\n")
      .map((path) => path.split("/")[path.split("/").length - 1])
      .map((pr) => ({ name: pr, description: "Executable file", type: "arg" })),
};

const optsList: Record<string, Fig.Option> = {
  all: {
    name: ["--all", "-a"],
    description: "All plugins and snippets",
  },
  bindKeys: {
    name: ["-b"],
    description: "Load in light mode, however do still track bindkey calls",
  },
  command: {
    name: ["--command", "-x"],
    description: "Load the snippet as a command",
  },
  clean: {
    name: ["--clean", "-c"],
    description: "Delete the currently not loaded plugins and snippets.",
  },
  force: {
    name: ["--force", "-f"],
    description: "Force download of a snippet",
  },
  help: {
    name: ["--help", "-h"],
    description: "Print help information",
  },
  moments: {
    name: ["-m"],
    description: "Show the loading times of an object",
  },
  noPager: {
    name: ["--no-pager", "-n"],
    description: "Disable paging of output",
  },
  quiet: {
    name: ["--quiet", "-q"],
    description: "Silence all output",
    isPersistent: true,
  },
  reset: {
    name: ["--reset", "-r"],
    description: "Reset the repository before updating (or remove the files for single-file snippets and gh-r plugins)."
  },
  parallel: {
    name: ["--parallel", "-p"],
    description: "Turn on concurrent, multi-thread update of all objects"
  },
  plugins: {
    name: ["--plugins", "-L"],
    description: "",
  },
  show: {
    name: ["-s"],
    description: "Show the currently set default ices"
  },
  snippets: {
    name: ["--snippets", "-S"],
    description: "Update only snippets"
  },
  snippetsTime: {
    name: ["--snippets", "-s"],
    description: "Show times in seconds instead of milliseconds"
  },
  urge: {
    name: ["--urge", "-u"],
    description: "Causes hooks like atpull to run even if there are no updates"
  },
  verbose: {
    name: ["--verbose", "-v"],
    description: "Verbose output"
  },
  yes: {
    name: ["--yes", "-y"],
    description: "Automatically confirm any yes/no prompts"
  }
}

const sharedArgs: Record<string, Fig.Arg> = {
  commands: {
    name: "command",
    description: "arbitrary command",
    generators: commandList
  },
  completions: {
    name: "completion",
    description: "Completion installed by zinit",
    generators: completionList
  },
  plugins: {
    name: "plugin",
    description: "Zinit plugin",
    generators: pluginList
  },
  // snippets: {
  //   name: "snippet",
  //   description: "Zinit snippet",
  //   generators: snippetList
  // },
  // pluginsAndSnippets: {
  //   name: "plugin or snippet",
  //   description: "Zinit plugin or snippet",
  //   generators: [
  //     snippetList, pluginList
  //   ]
  // }
}

const subCommands: Record<string, Fig.Subcommand> = {
  // TODO: Annexes
  help: {
    name: "help",
    description: "Print help information"
  },
  test: {
    name: "test",
    description: "Run tests for a plugin"
  },
  bindKeys: {
    name: "bindkeys",
    description: "lists bindkeys set up by each plugin"
  },
  cclear: {
    name: "cclear",
    description: "Delete stray and improper completions",
  },
  cd: {
    name: "cd",
    description: "cd into plugin's directory; also support snippets",
    args: [
      sharedArgs.plugins
    ]
  },
  cdclear: {
    name: "cdclear",
    description: "Clear cd cache",
    options: [
      optsList.help,
      optsList.quiet,
    ]
  },
  cdisable: {
    name: "cdisable",
    description: "Disable a completion",
    args: [
      sharedArgs.completions
    ]
  },
  cdlist: {
    name: "cdlist",
    description: "List all completions",
  },
  cdreplay: {
    name: "cdreplay",
    description: "Runs gathered compdef calls. This allows to run 'compinit' after loading plugins",
    options: [
      optsList.help,
      optsList.quiet,
    ]
  },
  cenable: {
    name: "cenable",
    description: "Enable a completion",
    args: [
      sharedArgs.completions
    ]
  },
  changes: {
    name: "changes",
    description: "Show changes to a plugin",
    args: [
      sharedArgs.plugins
    ]
  },
  compile: {
    name: "compile",
    description: "Compile a plugin/snippet",
    args: [
      sharedArgs.plugins
    ],
    options: [
      optsList.all,
    ],
  },
  compiled: {
    name: "compiled",
    description: "Show compiled completions",
  },
  compinit: {
    name: "compinit",
    description: "Runs 'compdef' for all enabled completions, and delete existing completions that are no longer present",
  },
  create: {
    name: "create",
    description: "Create a plugin",
  },
  creinstall: {
    name: "creinstall",
    description: "(re)Installs completions for plugin. Enables them all",
    args: [
      sharedArgs.plugins
    ]
  },
  csearch: {
    name: "csearch",
    description: "Search for a completion",
    args: [
      sharedArgs.completions
    ]
  },
  cuninstall: {
    name: "cuninstall",
    description: "Uninstalls completions for plugin",
    args: [
      sharedArgs.plugins
    ]
  },
  completions: {
    name: "completions",
    description: "Show installed, enabled or disabled, completions and detect stray and improper ones",
  },
  debug: {
    name: "debug",
    description: "Debug a plugin",
    subcommands: [
      {
        name: "clear",
        description: "Clear debug report"
      },
      {
        name: "report",
        description: "Show debug report"
      },
      {
        name: "revert",
        description: "Revert changes made during debug mode"
      },
      {
        name: "start",
        description: "Start debug mode"
      },
      {
        name: "status",
        description: "Current debug status"
      },
      {
        name: "stop",
        description: "Stop debug mode"
      }
    ]
  },
  delete: {
    name: "delete",
    description: "Delete plugin",
    args: [
      sharedArgs.plugins
    ],
    options: [
      optsList.all,
      optsList.clean,
      optsList.help,
      optsList.quiet,
      optsList.yes,
    ]
  },
  envwhitelist: {
    name: "env-whitelist",
    description: "Allows to specify names (also patterns) of variables left unchanged during an unload",
    options: [
      optsList.help,
      optsList.verbose,
    ]
  },
  light: {
    name: "light",
    description: "Load a plugin in light mode",
    options: [
      optsList.help,
      optsList.bindKeys
    ]
  },
  man: {
    name: "man",
    description: "Print man page for a plugin",
  },
  module: {
    // TODO
    name: "module",
    description: "",
  },
  recall: {
    name: "recall",
    description: "Recall a plugin",
    args: [
      sharedArgs.plugins
    ]
  },
  recently: {
    name: "recently",
    description: "Shows plugins with updates in X time (default `1 week`)",
    args: [
      {
        name: "time",
        description: "Time in seconds (default `1 week`)",
        suggestions: [
          "1 day",
          "5 days",
          "1 week",
          "2 weeks",
          "1 month",
          "3 months",
        ]
      }
    ]
  },
  report: {
    name: "report",
    description: "Full report for a plugin",
    args: [
      sharedArgs.plugins
    ],
    options: [
      optsList.all,
    ]
  },
  run: {
    name: "run",
    description: "Run a command in a plugin directory",
    args: [
      sharedArgs.plugins,
      sharedArgs.commands,
    ],
  },
  selfUpdate: {
    name: "self-update",
    description: "Update zinit to the latest version",
    displayName: "self-update"
  },
  snippet: {
    name: "snippet",
    description: "Load a snippet",
    options: [
      optsList.command,
      optsList.force,
      optsList.help,
    ]
  },
  srv: {
    // TODO
    name: "srv",
    description: "",
  },
  status: {
    name: "status",
    description: "Show status of plugins",
    args: [
      sharedArgs.plugins
    ],
    options: [
      optsList.all
    ]
  },
  stress: {
    name: "stress",
    description: "Stress test a plugin",
    args: [
      sharedArgs.plugins
    ]
  },
  times: {
    name: "times",
    description: "",
    options: [
      optsList.help,
      optsList.moments,
      optsList.show,
    ]
  },
  uncompile: {
    name: "uncompile",
    description: "Uncompile a plugin/snippet",
    args: [
      sharedArgs.plugins
    ],
    options: [
      optsList.all,
    ],
  },
  unload: {
    name: "unload",
    description: "Unload plugin",
    args: [
      sharedArgs.plugins
    ],
    options: [
      optsList.help,
      optsList.quiet,
    ]
  },
  update: {
    name: "update",
    description: "Update plugin to the latest version, assumes --all if no plugin",
    args: [
      sharedArgs.plugins
    ]
    ,
    options: [
      optsList.all,
      optsList.help,
      optsList.noPager,
      optsList.parallel,
      optsList.plugins,
      optsList.quiet,
      optsList.reset,
      optsList.snippets,
      optsList.urge,
      optsList.verbose,
    ]
  },
  version: {
    name: "version",
    description: "Show zinit version"
  },
  zstatus: {
    name: "zstatus",
    description: "Show zinit status",
  }
}

const completionSpec: Fig.Spec = {
  name: "zinit",
  description: "Zinit is a tool for managing zsh plugins",
  options: [
    optsList.quiet,
    optsList.show,
    optsList.verbose,
    optsList.reset,
    optsList.help
  ],
  subcommands: [
    ...Object.values(subCommands),
  ],
}

export default completionSpec

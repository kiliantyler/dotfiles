type Data = {
  name: string;
}

const fetchAnnexSubcommands = () => {
  let annexCommandsCache: Data[] | undefined = undefined;

  return async (
    executeShellCommand: Fig.ExecuteCommandFunction
  ): Promise<Data[] | undefined> => {
    // Return the cached commands if they've already been fetched
    if (annexCommandsCache) {
      return annexCommandsCache;
    }

    try {
      const { stdout } = await executeShellCommand({
        command: "zsh",
        args: [
          "-ic",
          `echo \${ZINIT_EXTS[@]}`
        ],
      });
      const outCommands = stdout.split(' ');
      const annexCommands: Data[] = [];

      for (const command of outCommands) {
        if (command.includes("subcommand:")) {
          const subcommand = command.split(":")[1];
          annexCommands.push({ name: `${subcommand}` });
        }
      }
      annexCommandsCache = annexCommands;
      return annexCommandsCache;
    } catch (error) {
      console.error("Failed to fetch annex subcommands", error);
      return undefined;
    }
  };
};

// Create the memoized function
const getAnnexCommands = fetchAnnexSubcommands();

const fetchPluginsList = () => {
  let pluginListCache: Data[] | undefined = undefined;

  return async (
    executeShellCommand: Fig.ExecuteCommandFunction
  ): Promise<Data[] | undefined> => {
    // Return the cached commands if they've already been fetched
    if (pluginListCache) {
      return pluginListCache;
    }
    try {
      const { stdout } = await executeShellCommand({
        command: "zsh",
        args: [
          "-ic",
          `ls -1 \${ZINIT_HOME}/../plugins`
        ],
      });
      const outList = stdout.substring(19).split('\n');
      const pluginList: Data[] = [];
      for (const plugin of outList) {
        if (plugin == "" || plugin.startsWith('_local')) {
          continue;
        }
        pluginList.push({ name: plugin.replace('---', '/') });
      }
      pluginListCache = pluginList;
      return pluginListCache;
    } catch (error) {
      console.error("Failed to fetch plugin list", error);
      return undefined;
    }
  };
};

// Create the memoized function
const getPluginList = fetchPluginsList();

const pluginList: Fig.Generator = {
  custom: async (_tokens, executeCommand) => {
    const data = await getPluginList(executeCommand);
    if (!data) {
      return [];
    }
    return data.map((plugin) => ({
      name: `${plugin.name}`,
      icon: "fig://icon?type=package",
    }));
  },
};

const fetchSnippetsList = () => {
  let snippetsListCache: Data[] | undefined = undefined;

  return async (
    executeShellCommand: Fig.ExecuteCommandFunction
  ): Promise<Data[] | undefined> => {
    // Return the cached commands if they've already been fetched
    if (snippetsListCache) {
      return snippetsListCache;
    }
    try {
      const { stdout } = await executeShellCommand({
        command: "zsh",
        args: [
          "-ic",
          `ls -1 \${ZINIT_HOME}/../snippets`
        ],
      });
      const outList = stdout.substring(19).split('\n');
      const snippetsList: Data[] = [];
      for (const snippet of outList) {
        if (snippet == "" || snippet.startsWith('_local')) {
          continue;
        }
        snippetsList.push({ name: snippet.replace('---', '/') });
      }
      snippetsListCache = snippetsList;
      return snippetsListCache;
    } catch (error) {
      console.error("Failed to fetch plugin list", error);
      return undefined;
    }
  };
};

// Create the memoized function
const getSnippetsList = fetchSnippetsList();

const snippetsList: Fig.Generator = {
  custom: async (_tokens, executeCommand) => {
    const data = await getSnippetsList(executeCommand);
    if (!data) {
      return [];
    }
    return data.map((snippet) => ({
      name: `${snippet.name}`,
      icon: "fig://icon?type=package",
    }));
  },
};

const fetchCompletionList = () => {
  let completionListCache: Data[] | undefined = undefined;

  return async (
    executeShellCommand: Fig.ExecuteCommandFunction
  ): Promise<Data[] | undefined> => {
    // Return the cached commands if they've already been fetched
    if (completionListCache) {
      return completionListCache;
    }
    try {
      const { stdout } = await executeShellCommand({
        command: "zsh",
        args: [
          "-ic",
          `ls -1 \${ZINIT_HOME}/../completions`
        ],
      });
      const outList = stdout.substring(19).split('\n');
      const completionList: Data[] = [];
      for (const completion of outList) {
        if (completion == "" || completion.startsWith('_local')) {
          continue;
        }
        completionList.push({ name: completion.replace('_', '') });
      }
      completionListCache = completionList;
      return completionListCache;
    } catch (error) {
      console.error("Failed to fetch plugin list", error);
      return undefined;
    }
  };
};

// Create the memoized function
const getCompletionList = fetchCompletionList();

const completionList: Fig.Generator = {
  custom: async (_tokens, executeCommand) => {
    const data = await getCompletionList(executeCommand);
    if (!data) {
      return [];
    }
    return data.map((completion) => ({
      name: `${completion.name}`,
      icon: "fig://icon?type=package",
    }));
  },
};

const fetchCommandsList = () => {
  let combinedListCache: Data[] | undefined = undefined;

  return async (
    executeShellCommand: Fig.ExecuteCommandFunction
  ): Promise<Data[] | undefined> => {
    // Return the cached commands if they've already been fetched
    if (combinedListCache) {
      return combinedListCache;
    }
    try {
      const { stdout: commands } = await executeShellCommand({
        command: "zsh",
        args: [
          "-ic",
          `print -rC1 -- \${(ko)commands}`
        ],
      });
      const outCommandList = commands.substring(19).split('\n');
      const commandList: Data[] = [];
      for (const command of outCommandList) {
        commandList.push({ name: command });
      }

      const { stdout: functions } = await executeShellCommand({
        command: "zsh",
        args: [
          "-ic",
          `print -l -- \${(ok)functions}`
        ],
      });
      const outFunctionList = functions.substring(19).split('\n');
      const functionList: Data[] = [];
      for (const func of outFunctionList) {
        if (func == "" || /^[^a-zA-Z0-9]/.test(func)) {
          continue;
        }
        functionList.push({ name: func });
      }

      const { stdout: aliases } = await executeShellCommand({
        command: "zsh",
        args: [
          "-ic",
          `print -rl -- \${(k)aliases}`
        ],
      });
      const outAliasList = aliases.substring(19).split('\n');
      const aliasList: Data[] = [];
      for (const alias of outAliasList) {
        aliasList.push({ name: alias });
      }

      combinedListCache = commandList;
      return combinedListCache;
    } catch (error) {
      console.error("Failed to fetch plugin list", error);
      return undefined;
    }
  };
};

// Create the memoized function
const getCommandList = fetchCommandsList();

const commandList: Fig.Generator = {
  custom: async (_tokens, executeCommand) => {
    const data = await getCommandList(executeCommand);
    if (!data) {
      return [];
    }
    return data.map((command) => ({
      name: `${command.name}`,
      description: "Executable command",
      type: "arg",
    }));
  },
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
    description: "Execute Command",
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
    generators: pluginList,
    filterStrategy: "fuzzy"
  },
  snippets: {
    name: "snippet",
    description: "Zinit snippet",
    generators: snippetsList
  },
  pluginsAndSnippets: {
    name: "plugin or snippet",
    description: "Zinit plugin or snippet",
    generators: [
      snippetsList, pluginList
    ]
  }
}

const subCommands: Record<string, Fig.Subcommand> = {
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
  },
}

const completionSpec: Fig.Spec = {
  name: ["zinit", "zi"],
  description: "Zinit is a tool for managing zsh plugins",
  options: [
    optsList.quiet,
    optsList.show,
    optsList.verbose,
    optsList.reset,
    optsList.help
  ],
  generateSpec: async (_, executeShellCommand) => {
    const data = await getAnnexCommands(executeShellCommand);
    if (!data) {
      return { name: "" };
    }
    return {
      name: "zinit",
      subcommands: data,
    }
  },
  subcommands: [
    ...Object.values(subCommands),
  ],
}

export default completionSpec

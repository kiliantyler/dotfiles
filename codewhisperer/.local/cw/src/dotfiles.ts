import { filepaths } from "@fig/autocomplete-generators";
import { cwd } from "process";

type Data = {
  name: string;
}

const fetchDotfilesList = () => {
  let dotfilesListCache: Data[] | undefined = undefined;

  return async (
    executeShellCommand: Fig.ExecuteCommandFunction
  ): Promise<Data[] | undefined> => {
    // Return the cached commands if they've already been fetched
    if (dotfilesListCache) {
      return dotfilesListCache;
    }
    try {
      const { stdout } = await executeShellCommand({
        command: "zsh",
        args: [
          "-ic",
          `ls -1 \${HOME}/dotfiles/`
        ],
      });
      const outList = stdout.substring(19).split('\n');
      const dotfilesList: Data[] = [];
      for (const folder of outList) {
        if (folder == "" || folder.startsWith('_local')) {
          continue;
        }
        dotfilesList.push({ name: folder });
      }
      dotfilesListCache = dotfilesList;
      return dotfilesListCache;
    } catch (error) {
      console.error("Failed to fetch plugin list", error);
      return undefined;
    }
  };
};

// Create the memoized function
const getDotfilesList = fetchDotfilesList();

const dotfilesList: Fig.Generator = {
  custom: async (_tokens, executeCommand) => {
    const data = await getDotfilesList(executeCommand);
    if (!data) {
      return [];
    }
    return data.map((plugin) => ({
      name: `${plugin.name}`,
      icon: "fig://icon?type=package",
    }));
  },
};


const completionSpec: Fig.Spec = {
  name: ["dotfiles", "dt"],
  description: "Manage dotfiles",
  subcommands: [
    {
      name: "link",
      description: "Link dotfiles from ~/dotfiles to ${HOME}",
      options: [
        {
          name: ["-d", "--dir"],
          description: "Directory to link dotfiles to",
          args: {
            name: "dotfile folder",
            description: "Dotfile folder to link",
            generators: filepaths({
              rootDirectory: "/Users/kilian/dotfiles",
              showFolders: "only",
              filterFolders: true,
              matches: /^[a-zA-Z0-9]/
            }),
          }
        },
        {
          name: ["-v", "--verbosity"],
          description: "Verbosity level",
          args: {
            name: "level",
            suggestions: ["1", "2", "3", "4", "5", "6", "7"],
          },
        },
      ],
    },
    {
      name: "clean",
      description: "Remove symlinks to dotfiles from ${HOME} that no longer exist",
    },
    {
      name: "edit",
      description: "Edit dotfiles in VSCode"
    },
    {
      name: "help",
      description: "Show help for dotfiles"
    }
  ],
  options: [
  ],
};

export default completionSpec;

const completionSpec: Fig.Spec = {
  name: "eza",
  description: "A modern, maintained replacement for ls",
  options: [
    {
      name: ["--help"],
      description: "show list of command-line options",
    },
    {
      name: ["-v", "--version"],
      description: "show version of eza",
    },
    {
      name: ["-1", "--oneline"],
      description: "display one entry per line",
    },
    {
      name: ["-l", "--long"],
      description: "display extended file metadata as a table",
    },
    {
      name: ["-G", "--grid"],
      description: "display entries as a grid (default)",
    },
    {
      name: ["-x", "--across"],
      description: "sort the grid across, rather than downwards",
    },
    {
      name: ["-R", "--recurse"],
      description: "recurse into directories",
    },
    {
      name: ["-T", "--tree"],
      description: "recurse into directories as a tree",
    },
    {
      name: ["-X", "--dereference"],
      description: "dereference symbolic links when displaying information",
    },
    {
      name: ["-F", "--classify"],
      description: "display type indicator by file names",
      args: {
        name: "WHEN",
        suggestions: ["always", "auto", "never"],
      },
    },
    {
      name: ["--color"],
      description: "when to use terminal colours",
      args: {
        name: "WHEN",
        suggestions: ["always", "auto", "never"],
      },
    },
    {
      name: ["--color-scale"],
      description: "highlight levels of 'field' distinctly",
      args: {
        name: "FIELD",
        suggestions: ["all", "age", "size"],
      },
    },
    {
      name: ["--color-scale-mode"],
      description: "use gradient or fixed colors in --color-scale",
      args: {
        name: "MODE",
        suggestions: ["gradient", "fixed"],
      },
    },
    {
      name: ["--icons"],
      description: "when to display icons",
      args: {
        name: "WHEN",
        suggestions: ["always", "auto", "never"],
      }
    },
    {
      name: ["--no-quotes"],
      description: "don't quote file names with spaces",
    },
    {
      name: ["--hyperlink"],
      description: "display entries as hyperlinks",
    },
    {
      name: ["--absolute"],
      description: "display entries with their absolute path",
      args: {
        suggestions: ["on", "follow", "off"],
      }
    },
    {
      name: ["-w", "--width"],
      description: "set screen width in columns",
      args: {
        name: "COLS",
      },
    },
    {
      name: ["-a", "--all"],
      description: "show hidden and 'dot' files. Use this twice to also show the '.' and '..' directories",
    },
    {
      name: ["-A", "--almost-all"],
      description: "equivalent to --all; included for compatibility with `ls -A`",
    },
    {
      name: ["-d", "--list-dirs"],
      description: "list directories as files; don't list their contents"
    },
    {
      name: ["-L", "--level"],
      description: "limit the depth of recursion",
      args: [
        {
          name: "DEPTH",
        }
      ]
    },
    {
      name: ["-r", "--reverse"],
      description: "reverse the sort order"
    },
    {
      name: ["-s", "--sort"],
      description: "which field to sort by",
      args: {
        name: "FIELD",
        suggestions: ["name", "extension", "size", "type", "modified", "accessed", "created", "inode", "none"],
      },
    },
    {
      name: ["--group-directories-first"],
      description: "list directories before other files"
    },
    {
      name: ["-D", "--only-dirs"],
      description: "list only directories"
    },
    {
      name: ["-f", "--only-files"],
      description: "list only files",
    },
    {
      name: ["-I", "--ignore-glob"],
      description: "glob patterns (pipe-separated) of files to ignore",
      args: {
        name: "GLOB",
      },
    },
    {
      name: ["--git-ignore"],
      description: "ignore files mentioned in '.gitignore'",
    },
    {
      name: ["-b", "--binary"],
      description: "list file sizes with binary prefixes",
    },
    {
      name: ["-B", "--bytes"],
      description: "list file sizes in bytes, without any prefixes",
    },
    {
      name: ["-g", "--group"],
      description: "list each file's group",
    },
    {
      name: ["--smart-group"],
      description: "only show group if it has a different name from owner"
    },
    {
      name: ["-h", "--header"],
      description: "add a header row to each column",
    },
    {
      name: ["-H", "--links"],
      description: "list each file's number of hard links",
    },
    {
      name: ["-i", "--inode"],
      description: "list each file's inode number",
    },
    {
      name: ["-m", "--modified"],
      description: "use the modified timestamp field",
    },
    {
      name: ["-M", "--mounts"],
      description: "show mount details (Linux and Mac only)",
    },
    {
      name: ["-n", "--numeric"],
      description: "list numeric user and group IDs",
    },
    {
      name: ["-O", "--flags"],
      description: "list file flags (Mac, BSD, and Windows only)",
    },
    {
      name: ["-S", "--blocksize"],
      description: "show size of allocated file system blocks",
    },
    {
      name: ["-t", "--time"],
      description: "which timestamp field to list",
      args: {
        name: "FIELD",
        suggestions: ["modified", "accessed", "created"],
      },
    },
    {
      name: ["-u", "--accessed"],
      description: "use the accessed timestamp field",
    },
    {
      name: ["-U", "--created"],
      description: "use the created timestamp field",
    },
    {
      name: ["--changed"],
      description: "use the changed timestamp field",
    },
    {
      name: ["--time-style"],
      description: "how to format timestamps",
      args: {
        name: "STYLE",
        suggestions: ["default", "iso", "long-iso", "full-iso", "relative", "+"],
      },
    },
    {
      name: ["--total-size"],
      description: "show the size of a directory as the size of all files and directories inside (unix only)",
    },
    {
      name: ["--no-permissions"],
      description: "suppress the permissions field",
    },
    {
      name: ["-o", "--octal-permissions"],
      description: "list each file's permission in octal format",
    },
    {
      name: ["--no-filesize"],
      description: "suppress the filesize field",
    },
    {
      name: ["--no-user"],
      description: "suppress the user field",
    },
    {
      name: ["--no-time"],
      description: "suppress the time field",
    },
    {
      name: ["--stdin"],
      description: "read file names from stdin, one per line or other separator specified in environment",
    },
    {
      name: ["--git"],
      description: "list each file's Git status, if tracked or ignored",
    },
    {
      name: ["--no-git"],
      description: "suppress Git status (always overrides --git, --git-repos, --git-repos-no-status)",
    },
    {
      name: ["--git-repos"],
      description: "list root of git-tree status",
    },
    {
      name: ["-@", "--extended"],
      description: "list each file's extended attributes and sizes",
    },
    {
      name: ["-Z", "--context"],
      description: "list each file's security context",
    },
  ],
  args: {
    name: "path",
    template: "filepaths"
  },
}

export default completionSpec;

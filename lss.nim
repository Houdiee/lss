import std/[os, tables, terminal, algorithm, strutils]
import termstyle
import nancy

enableTrueColors()
let terminal_width = terminalWidth()
let current_path = getCurrentDir()
var all_values = newSeq[string]()
var table: TerminalTable

var directories = newSeq[(string, string)]()
var files = newSeq[(string, string)]()

proc iterate_files(hidden: bool, input_path: string) =
  for kind, path in walkDir(input_path):
    let (_, register_name, extension) = splitFile(path)
    let file_format = register_name & extension
    let directory_format = file_format & "/"
    let permissions = try:
                        getFilePermissions(register_name & extension)
                      except:
                        {fpUserRead}

    if hidden and register_name[0] == '.':
      continue

    let file_ext = {
      # Developer / Programming Languages
      ".nim": yellow(" "),
      ".go": blue(" "),
      ".rs": red("󱘗 "),
      ".c": blue(" "),
      ".h": blue("󰙱 "),
      ".cpp": blue(" "),
      ".npm": red(" "),
      ".js": yellow("󰌞 "),
      ".hs": magenta("󰲒 "),
      ".rb": red("󰴭 "),
      ".erb": red("󰴭 "),
      ".scala": red(" "),
      ".jsx": blue("󰜈 "),
      ".zig": yellow(" "),
      ".lua": blue("󰢱 "),
      ".ts": blue("󰛦 "),
      ".py": yellow("󰌠 "),
      ".css": yellow(" "),
      ".html": blue("󰌝 "),
      ".php": magenta("󰌟 "),
      ".r": blue("󰟔 "),
      ".f": blue(" "),
      ".sh": white(" "),
      ".swift": yellow("󰛥 "),
      ".sass": red(" "),
      ".kt": blue("󱈙 "),
      ".kts": yellow("󱈙 "),
      ".eex": magenta(" "),
      ".ex": magenta(" "),
      ".exs": magenta(" "),
      ".json": yellow(" "),
      ".xml": blue("󰗀 "),

      ".fish": green(" "),
      ".zsh": blue(" "),

      # Documents
      ".pdf": red(" "),
      ".epub": yellow(" "),
      ".md": yellow(" "),
      ".mobi": magenta(" "),
      ".djvu": green("󱗖 "),
      ".log": white("󰯃 "),
      ".txt": white(" "),

      # Image format
      ".png": yellow(" "),
      ".jpeg": green(" "),
      ".ico": blue(" "),
      ".svg": yellow("󰜡 "),

      # File compression
      ".zip": red(" "),
      ".gz": red(" "),
      ".tar": red(" "),
      ".7z": red(" "),

      # Fonts
      ".ttf": yellow("󰊄 "),
      ".otf": green("󰊄 "),

      # Distro
      ".deb": red(" "),
      ".rpm": red("󰮤 "),

      # Other
      ".conf": white(" "),
      ".config": white(" "),
      ".ini": white(" "),
      ".cache": white("󰆼 "),
      ".core": white(" "),
      ".dat": white(" "),
    }.toTable()

    let special_names = {
      # User
      "Videos": blue("󰕧 "),
      "Pictures": blue(" "),
      "Downloads": blue("󰇚 "),

      # Developer / Programming Language
      "Makefile": white(" "),
      "rustup": red("󱘗 "),
      ".wine": blue(" "),
      ".i386-wine-pkg": blue(" "),
      ".cargo": blue(" "),
      ".npm": blue(" "),
      ".nimble": blue(" "),
      ".config": blue(" "),
      ".git-credentials": red("󰊢 "),
      ".gitconfig": red("󰊢 "),
      ".gitignore": red("󰊢 "),
      ".vimrc": white(" "),
      "viminfo": white(" "),
      ".git": blue(" "),
      ".vim": blue(" "),

      # Unix
      "fonts": blue(" "),
      ".cache": blue("󰆼 "),
      ".log": blue("󰯃 "),
      ".profile": white(" "),

      # Programs
      ".mozilla": blue(" "),
      ".tor": blue(" "),

      # Other
      "home": blue(" "),
      "TODO": green(" "),
      "ebooks": blue("󱚜 "),
    }.toTable()

    let dir_ext = {
      # Developer / Programming Languages
      ".conf": blue(" "),
    }.toTable()

    type Register = object
      title: string
      icon: string

    var register: Register

    case kind:
      of pcFile:
        register.icon = if not special_names.hasKey(register_name):
                           if file_ext.hasKey(extension):
                             file_ext[extension]
                           else:
                             if file_ext.hasKey(register_name):
                               file_ext[register_name]
                             else:
                               white("󰈔 ")
                         else:
                          special_names[register_name]
        register.title = if not permissions.contains(fpUserExec):
                            file_format
                          else:
                            register.icon = green(" ")
                            green(file_format & "*")

        files.add((register.icon, register.title))

      of pcDir:
        register.icon = if not special_names.hasKey(register_name):
                         if dir_ext.hasKey(extension):
                           dir_ext[extension]
                         else:
                           if dir_ext.hasKey(register_name):
                             dir_ext[register_name]
                           else:
                             blue("󰝰 ")
                       else:
                         special_names[register_name]
        register.title = blue(directory_format)
        directories.add((register.icon,  register.title))

      of pcLinkToDir:
        register.title = green(underline(directory_format) & green(" ->"))
        register.icon = green(" ")
        directories.add((register.icon,  register.title))

      of pcLinkToFile:
        register.title = green(underline(file_format)) & green(" ->")
        register.icon = (green(" "))
        directories.add((register.icon,  register.title))

  proc myCmp(x, y: (string, string)): int = cmp(x[1].toLower(), y[1].toLower())
  directories.sort(myCmp)
  files.sort(myCmp)

  for dir in directories:
    all_values.add(dir[0] & dir[1])

  for fi in files:
    all_values.add(fi[0] & fi[1])

proc print_default(hidden: bool, input_path: string) =
  iterate_files(hidden, input_path)
  let cellsPerRow = int(toFloat(terminal_width) * 0.04)
  var count = 0
  var row = newSeq[string]()
  var rows: seq[seq[string]] = @[]

  try:
    for value in all_values:
      row.add(value)
      count += 1

      if count == cellsPerRow:
        rows.add(row)
        row = newSeq[string]()
        count = 0

    if row.len > 0:
      rows.add(row)

    for r in rows:
      table.add(r)

    table.echoTable(terminal_width, padding=4)
  except:
    discard


proc print_all(hidden: bool, input_path: string) =
  iterate_files(hidden, input_path)
  let cellsPerRow = int(toFloat(terminal_width) * 0.04)
  var count = 0
  var row = newSeq[string]()
  var rows: seq[seq[string]] = @[]

  for value in all_values:
    row.add(value)
    count += 1

    if count == cellsPerRow:
      rows.add(row)
      row = newSeq[string]()
      count = 0

  let single_dir = blue(".") & white("/")
  let double_dir = blue("..") & white("/")

  row.add(single_dir)
  row.add(double_dir)

  if row.len > 0:
    rows.add(row)

  for r in rows:
    table.add(r)

  table.echoTable(terminal_width, padding=4)

proc print_directory(path: string) =
  print_default(false, path)

if paramCount() == 0:
  print_default(true, current_path)
else:
  case paramStr(1):
    of "-a":
      if paramCount() == 1:
        print_all(false, current_path)
      else:
        if paramCount() == 2:
          print_all(true, paramStr(2))
    else:
      print_directory(paramStr(1))

import std/[os, tables, terminal]

enableTrueColors()
let current_path: string = getCurrentDir()
const separator = " "

for kind, path in walkDir(current_path):
  let (_, register_name, extension) = splitFile(path)
  let file_format = register_name & extension
  let directory_format = file_format & "/"

  let file_ext = {
    # Developer / Programming Languages
    ".nim": (" ", fgYellow),
    ".go": (" ", fgBlue),
    ".rs": ("󱘗 ", fgRed),
    ".c": (" ", fgBlue),
    ".cpp": (" ", fgBlue),
    ".npm": (" ", fgRed),
    ".js" : ("󰌞 ", fgYellow),
    ".hs" : ("󰲒 ", fgMagenta),

    # Other
    ".conf": (" ", fgWhite),
    ".config": (" ", fgWhite),
    ".ini": (" ", fgWhite),
  }.toTable()

  let special_names = {
    "Makefile": (" ", fgWhite)
  }.toTable()

  let dir_ext = {
    # Developer / Programming Languages
    ".npm": (" ", fgRed),
    ".conf": (" ", fgBlue),
  }.toTable()

  type RegisterType = enum
    File,
    Directory,

  type Register = object
    register_type: RegisterType
    title: string
    length: int
    icon: string
    icon_color: ForegroundColor
    default_fg: ForegroundColor

  var register: Register

  case kind:
    of pcFile:
      register.register_type = RegisterType.File
      register.title = file_format
      register.length = len(file_format)
      (register.icon, register.icon_color) = if not special_names.hasKey(register_name):
                                               if file_ext.hasKey(extension):
                                                 (file_ext[extension][0], file_ext[extension][1])
                                               else:
                                                 if file_ext.hasKey(register_name):
                                                   (file_ext[register_name][0], file_ext[register_name][1])
                                                 else:
                                                   ("󰈔 ", fgWhite)
                                             else:
                                              (special_names[register_name][0], special_names[register_name][1])
      register.default_fg = fgWhite

    of pcDir:
      register.register_type = RegisterType.Directory
      register.title = directory_format
      register.length = len(file_format)
      (register.icon, register.icon_color) = if not special_names.hasKey(register_name):
                                               if dir_ext.hasKey(extension):
                                                 (dir_ext[extension][0], dir_ext[extension][1])
                                               else:
                                                 if dir_ext.hasKey(register_name):
                                                   (dir_ext[register_name][0], dir_ext[register_name][1])
                                                 else:
                                                   ("󰝰 ", fgBlue)
                                             else:
                                               (special_names[register_name][0], special_names[register_name][1])
      register.default_fg = register.icon_color

    of pcLinkToFile, pcLinkToDir:
      continue

  stdout.styledWrite(register.icon_color, register.icon, register.default_fg, register.title & separator)

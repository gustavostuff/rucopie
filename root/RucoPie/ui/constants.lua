local colors = require 'colors'

local constants = {
  CANVAS_WIDTH = 320,
  CANVAS_HEIGHT = 180,
  -- CANVAS_WIDTH = 400,
  -- CANVAS_HEIGHT = 225,
  MAX_LINE_WIDTH = 220, -- pixels
  MAX_LINE_CHARACTERS = 33,
  PAGE_SIZE = 12,
  CURSOR_SEPARATION = 4,
  RUCOPIE_DIR = '/root/RucoPie/',
  THEMES_DIR = '/root/RucoPie/ui/assets/themes/',
  JOYSTICK_CONFIG_PATH = 'config/joystick.lua',
  ROMS_DIR = '/root/RetroPie/roms/',
  VIRTUAL_KEYBOARD = {
    { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M' },
    { 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' },
    { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm' },
    { 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' },
    { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '@', '.', ',' },
    { ' ', '-', '_', '(', ')', '[', ']', '{', '}', '$', '%', '^', '&' },
    { '*', '+', ';', ':', '?', '!', '<', '>', '/', 'ç', 'Ç', 'ñ', 'Ñ'},
  },
  keys = {
    ENTER = 'return',
    UP = 'up',
    DOWN = 'down',
    ESCAPE = 'escape',
    P = 'p',
    F1 = 'f1'
  },
  systemsLabels = {
    fds = 'Famicom Disk System',
    gb = 'Game Boy',
    gbc = 'Game Boy Color',
    neogeo = 'Neo Geo',
    nes = 'Nintendo',
    snes = 'Super Nintendo',
    ports = 'Ports',
    atari2600 = 'Atari 2600'
  },
  extensionsToRemove = {
    'zip'
  },
  filesToDisplay = {
    gb = { 'gb' },
    nes = { 'nes' },
  }
}

constants.cores = {
  'fceumm',
  'gambatte',
  'fbneo',
  'snes9x',
  'stella2014'
}

local labels = constants.systemsLabels
constants.coreAssociations = {
  ['fceumm'] = labels.nes,
  ['gambatte'] = labels.gb .. '/' .. labels.gbc,
  ['fbneo'] = labels.neogeo,
  ['snes9x'] = labels.snes,
  ['stella2014'] = labels.atari2600,
}

return constants

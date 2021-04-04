local colors = require 'colors'

return {
  CANVAS_WIDTH = 320,
  CANVAS_HEIGHT = 180,
  -- CANVAS_WIDTH = 400,
  -- CANVAS_HEIGHT = 225,
  MAX_LINE_WIDTH = 220, -- pixels
  MAX_LINE_CHARACTERS = 30,
  PAGE_SIZE = 12,
  POINTER_SEPARATION = 4,
  RUCOPIE_DIR = '/root/RucoPie/',
  THEMES_DIR = '/root/RucoPie/ui/assets/themes/',
  JOYSTICK_CONFIG_PATH = 'config/joystick.lua',
  ROMS_DIR = '/root/RetroPie/roms/',
  keys = {
    ENTER = 'return',
    UP = 'up',
    DOWN = 'down',
    ESCAPE = 'escape',
    P = 'p',
    F1 = 'f1'
  },
  captions = {
    [1] = {
      colors.green, 'A: OK',
      colors.red, '  B: Back',
      colors.blue, '  Start: Options'
    },
    [2] = {
      colors.green, 'A: OK',
      colors.red, '  B: Back',
      colors.blue, '  Start: Systems'
    },
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
  cores = {
    'fceumm',
    'gambatte',
    'fbneo',
    'snes9x',
    'stella2014'
  },
  extensionsToRemove = {
    'zip'
  },
  filesToDisplay = {
    'zip',
    'png',
    'jpg',
    'jpeg',
    'gif',
    'mp4',
    'ogg',
    'ogv',
    'mov',
    '3gp'
  }
}

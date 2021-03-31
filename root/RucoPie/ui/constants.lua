local colors = require 'colors'

return {
  CANVAS_WIDTH = 320,
  CANVAS_HEIGHT = 180,
  -- CANVAS_WIDTH = 400,
  -- CANVAS_HEIGHT = 225,
  MAX_LINE_WIDTH = 220,
  PAGE_SIZE = 12,
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
      colors.green, 'A:',
      colors.white, 'OK',
      colors.red, '  B:',
      colors.white, 'Back',
      colors.blue, '  Start:',
      colors.white, 'Options'
    },
    [2] = {
      colors.green, 'A:',
      colors.white, 'OK',
      colors.red, '  B:',
      colors.white, 'Back',
      colors.blue, '  Start:',
      colors.white, 'Systems'
    },
  },
  systemsLabels = {
    fds = 'Famicom Disk System',
    gb = 'Game Boy',
    gbc = 'Game Boy Color',
    neogeo = 'Neo Geo',
    nes = 'Nintendo',
    snes = 'Super Nintendo',
    ports = 'Ports'
  },
  cores = {
    'fceumm',
    'gambatte',
    'fbneo',
    'snes9x'
  },
  RESTART_LABEL = 'Restart',
  SHUTDOWN_LABEL = 'Shutdown',
  VIDEO_OPTIONS_LABEL = 'Video',
  BILINEAR_LABEL = 'Bilinear',
  DEBUG_LABEL = 'Show debug info',
  ADVANCED_LABEL = 'Advanced',
  THEMES_LABEL = 'Themes',
  REFRESH_ROMS_LABEL = 'Refresh game list'
}

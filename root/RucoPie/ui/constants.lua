local colors = require 'colors'

return {
  CANVAS_WIDTH = 320,
  CANVAS_HEIGHT = 180,
  paddingLeft = 24,
  paddingRight = 24,
  paddingTop = 16,
  paddingBottom = 16,
  RUCOPIE_DIR = '/root/RucoPie/',
  JOYSTICK_CONFIG_PATH = 'config/joystick.lua',
  ROMS_DIR = '/root/RetroPie/roms/',
  keys = {
    ENTER = 'return',
    UP = 'up',
    DOWN = 'down',
    ESCAPE = 'escape',
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
  RESTART_LABEL = 'Restart',
  SHUTDOWN_LABEL = 'Shutdown',
  VIDEO_OPTIONS_LABEL = 'Video',
  BILINEAR_LABEL = 'Bilinear',
  DEBUG_LABEL = 'Debug mode',
  ADVANCED_LABEL = 'Advanced'
}

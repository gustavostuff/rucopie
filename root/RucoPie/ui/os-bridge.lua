local utils = require 'utils'
local constants = require 'constants'
local lfs = require 'lfs'

local osBridge = {}

osBridge.readFrom = function(cmd)
  local stream = io.popen(cmd)
  local result = stream:read('*a')
  stream:close()

  return result
end

osBridge.runGame = function (system, path)
  local base = constants.RUCOPIE_DIR .. 'scripts/'

  path = osBridge.readFrom(base .. 'normalize.sh "' .. path .. '"')
  local retroarch = base .. 'run_game.sh ' .. system .. ' ' .. path
  local backToUI = base .. 'start_ui.sh';
  local cmd = 'nohup sh -c "' .. retroarch .. ' && ' .. backToUI .. '" > /dev/null &';
  utils.debug('>> cmd to run retroarch and go back:', cmd)
  io.popen(cmd)
  love.event.quit() -- love app is closed but opened after retroarch closes
end

-- next 2 functions are used for files with no spaces in between the name
osBridge.saveFile = function(content, path)
  -- this is synchronus, love app will be blocked:
  utils.debug('Saving file with content:\n' .. content)
  local file = io.open(constants.RUCOPIE_DIR .. path, 'w')
  file:write(content)
  file:close()
end

osBridge.readFile = function(path)
  -- this is synchronus, love app will be blocked:
  
  local file = assert(io.open(constants.RUCOPIE_DIR .. path, "rb"))
  local content = file:read("*all")
  utils.debug('File being read:\n' .. content)
  file:close()
  return content
end

osBridge.setResolution = function (core, w, h)
  local result = osBridge.readFrom(constants.RUCOPIE_DIR .. 'scripts/set_system_resolution.sh "'
    .. core .. '" "' .. w .. '" "' .. h .. '"')
  return result
end

osBridge.fileExists = function(path)
  local file = io.open(path, 'r')
  if file ~= nil then
    io.close(file)
    return true
  end
  return false
end

osBridge.restart = function ()
  io.popen('reboot')
end

osBridge.shutdown = function ()
  io.popen('poweroff')
end

osBridge.isDirectory = function (path)
  local attr = lfs.attributes(path)
  return attr.mode == 'directory'
end

return osBridge

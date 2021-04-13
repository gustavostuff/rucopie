local utils = require 'utils'
local constants = require 'constants'
local lfs = require 'lfs'
local threadManager = require 'thread-manager'

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

  _G.onHold = true
  love.window.close()
  threadManager:run('open-retroarch', function (value)
    utils.debug('RetroArch is done with:', value)
    love.event.clear()
    -- open window again
    love.window.setMode(constants.CANVAS_WIDTH, constants.CANVAS_HEIGHT)
    _G.onHold = false
  end, { command = retroarch })
end

osBridge.updateConfig = function (core, configName, value)
  local result = osBridge.readFrom(
    constants.RUCOPIE_DIR .. 'scripts/update_retroarch_config.sh "'
      .. core .. '" "'
      .. configName .. '" "'
      .. tostring(value) .. '"'
    )
  return result
end

osBridge.updateConfigs = function (core, configs)
  for configName, value in pairs(configs) do
    osBridge.updateConfig(core, configName, value)
  end
end

osBridge.updateConfigsForAllCores = function (configs)
  for _, core in ipairs(constants.cores) do
    osBridge.updateConfigs(core, configs)
  end
end

-- next 2 functions are used for files with no spaces in between the name
osBridge.saveFile = function(content, path)
  -- this is synchronus, love app will be blocked:
  -- utils.debug('Saving file with content:\n' .. content)
  local file = io.open(constants.RUCOPIE_DIR .. path, 'w')
  file:write(content)
  file:close()
end

osBridge.readFile = function(path)
  -- this is synchronus, love app will be blocked:
  
  local file = assert(io.open(constants.RUCOPIE_DIR .. path, "rb"))
  local content = file:read("*all")
  -- utils.debug('File being read:\n' .. content)
  file:close()
  return content
end

osBridge.saveCustomPreferences = function (preferences)
  osBridge.saveFile(
    'return {' ..
      utils.tableToString(preferences) ..
    '}',
    'config/custom-preferences.lua'
  )
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

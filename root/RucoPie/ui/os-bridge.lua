local utils = require 'utils'
local constants = require 'constants'

local osBridge = {}

osBridge.readFrom = function(cmd)
  local stream = io.popen(cmd)
  local result = stream:read('*a')
  stream:close()

  return result
end

osBridge.generateList = function (folder)
  local rawList = osBridge.readFrom('ls ' .. constants.ROMS_DIR .. folder)
  local list, listToDisplay = utils.split(rawList, '\n'), { index = 1, items = {} }
  
  for i = 1, #list do
    table.insert(listToDisplay.items, { label = list[i] })
  end
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
  os.execute('echo "' .. content .. '" > ' .. constants.RUCOPIE_DIR .. path)
end

osBridge.readFile = function(path)
  -- this is synchronus, love app will be blocked:
  local content = osBridge.readFrom('cat ' .. constants.RUCOPIE_DIR .. path)
  utils.debug('File being read:\n' .. content)
  return content
end

osBridge.fileExists = function(path)
  local result = osBridge.readFrom(constants.RUCOPIE_DIR .. 'scripts/file_exists.sh "' .. path .. '"')
  return result:find('true')
end

osBridge.restart = function ()
  io.popen('reboot')
end

osBridge.shutdown = function ()
  io.popen('poweroff')
end

osBridge.isDirectory = function (path)
  local result = osBridge.readFrom(constants.RUCOPIE_DIR .. 'scripts/is_dir.sh "' .. path .. '"')
  if result:find('file') then
    utils.debug('*DIR ' .. path)
    return true
  elseif result:find('directory') then
    utils.debug('>> FILE ' .. path)
    return false
  else
    utils.debug('** NOT VALID >> ' .. path)
    return false
  end
end

return osBridge

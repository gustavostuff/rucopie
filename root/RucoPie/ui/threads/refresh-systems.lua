local constants = require '../constants'
local osBridge = require '../os-bridge'
local utils = require '../utils'

local function createSystemsTree(path, parentList, level)
  level = level or 1
  path = path or constants.ROMS_DIR
  local rawList = osBridge.readFrom('ls "' .. path .. '"')
  local list, parentList = utils.split(rawList, '\n'), parentList or { index = 1, items = {} }
  if level == 1 then parentList.isRoot = true end
  
  for i = 1, #list do
    local item = list[i]
    
    if osBridge.isDirectory(path .. item) then
      local childList = {
        label = item,
        items = {},
        index = 1,
        isDir = true,
        isSystem = level == 1,
        page = utils.initPage()
      }
      createSystemsTree(path .. item .. '/', childList, level + 1)
      table.insert(parentList.items, childList)
      parentList.page = utils.initPage()
    else
      table.insert(parentList.items, { label = item })
    end
  end
  
  return parentList
end

local tree = createSystemsTree()
local stringTree = 'return { ' .. utils.tableToString(tree) .. '}'
osBridge.saveFile(stringTree, 'cache/games.lua')
love.thread.getChannel(...):push(stringTree)

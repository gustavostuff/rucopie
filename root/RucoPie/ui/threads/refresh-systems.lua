local constants = require '../constants'
local osBridge = require '../os-bridge'
local utils = require '../utils'
local lfs = require 'lfs'
local channel = ({...})[1]
local totalGames = 0

local function createSystemsTree(path, parentList, level)
  path = path or constants.ROMS_DIR
  parentList = parentList or { index = 1, items = {}, isRoot = true }
  level = level or 1

  local elements = {}
  for file in lfs.dir(path) do
    table.insert(elements, file)
  end
  -- alphabeticall order
  table.sort(elements)
  
  for _, file in ipairs(elements) do
    if file ~= "." and file ~= ".." then
      local fullPath = path .. '/' .. file
      
      if osBridge.isDirectory(fullPath) then
        local childList = {
          label = file,
          items = {},
          index = 1,
          isDir = true,
          isSystem = level == 1,
          page = utils.initPage()
        }
        createSystemsTree(fullPath .. '/', childList, level + 1)
        table.insert(parentList.items, childList)
        parentList.page = utils.initPage()
      else
        totalGames = totalGames + 1
        table.insert(parentList.items, { label = file })
      end
    end
  end

  return parentList
end

local tree = createSystemsTree()
tree.totalGames = totalGames
local stringTree = 'return { ' .. utils.tableToString(tree) .. '}'
osBridge.saveFile(stringTree, 'cache/games-tree.lua')

constants.tree = loadstring(stringTree)()

love.thread.getChannel(channel):push({
  stringTree = stringTree,
  totalGames = totalGames
})

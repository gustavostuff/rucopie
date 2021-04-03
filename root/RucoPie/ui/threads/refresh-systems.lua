require 'love.graphics'

local constants = require '../constants'
local osBridge = require '../os-bridge'
local utils = require '../utils'
local lfs = require 'lfs'
local channel = ({...})[1]
local data = ({...})[2]
local totalGames = 0

local function clipLargeLine(item)
  if (#item.displayLabel * data.characterW) > constants.MAX_LINE_WIDTH then
    item.clipped = true
  end
end

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
      local elementToInsert

      if osBridge.isDirectory(fullPath) then
        elementToInsert = {
          displayLabel = utils.getDisplayLabel(file),
          internalLabel = file,
          items = {},
          index = 1,
          isDir = true,
          isSystem = level == 1,
          page = utils.initPage()
        }
        createSystemsTree(fullPath .. '/', elementToInsert, level + 1)
        clipLargeLine(elementToInsert)
        table.insert(parentList.items, elementToInsert)
        parentList.page = utils.initPage()
      else
        totalGames = totalGames + 1
        elementToInsert = {
          displayLabel = utils.getDisplayLabel(file),
          internalLabel = file
        }
        clipLargeLine(elementToInsert)
        table.insert(parentList.items, elementToInsert)
      end
    end
  end

  return parentList
end

local tree = createSystemsTree()
tree.totalGames = totalGames
local stringTree = 'return { ' .. utils.tableToString(tree) .. '}'
osBridge.saveFile(stringTree, 'cache/games-tree.lua')

love.thread.getChannel(channel):push({
  stringTree = stringTree,
  totalGames = totalGames
})

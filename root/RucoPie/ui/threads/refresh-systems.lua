require 'love.graphics'

local constants = require '../constants'
local osBridge = require '../os-bridge'
local utils = require '../utils'
local lfs = require 'lfs'
local channel = ({...})[1]
local data = ({...})[2]
local totalGames = 0

local function clipLargeLine(item)
  if #item.displayLabel > constants.MAX_LINE_CHARACTERS then
    item.clipped = true
  end
end

local function validExtension(systemName, file)
  -- allowing all zip files for all systems, for now
  if file:find('.zip$') then return true end

  -- for system, extensions in pairs(constants.filesToDisplay) do
  --   for _, ext in ipairs(extensions) do
  --     if file:find('.' .. ext .. '$', '') then
  --       return true
  --     end
  --   end
  -- end

  -- return false
end

local function createSystemsTree(path, parentList, level)
  path = path or constants.ROMS_DIR
  parentList = parentList or {
    index = 1,
    items = {},
    isRoot = true,
    page = utils.initPage()
  }
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
          systemName = ((level == 1) and file) or nil,
          page = utils.initPage()
        }
        createSystemsTree(fullPath .. '/', elementToInsert, level + 1)
        clipLargeLine(elementToInsert)
        table.insert(parentList.items, elementToInsert)
        parentList.page = utils.initPage()
      else
        if not validExtension(systemName, file) then
          goto continue
        end

        totalGames = totalGames + 1
        elementToInsert = {
          displayLabel = utils.getDisplayLabel(file),
          internalLabel = file
        }
        clipLargeLine(elementToInsert)
        table.insert(parentList.items, elementToInsert)

        ::continue::
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

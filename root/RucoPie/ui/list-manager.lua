
local constants = require 'constants'
local colors = require 'colors'
local utils = require 'utils'
local themeManager = require 'theme-manager'

local listManager = {}
listManager.pageSize = (_G.currentTheme and _G.currentTheme.pageSize) or constants.PAGE_SIZE

local pointer = love.graphics.newImage('assets/img/default-pointer.png')
pointer:setFilter('nearest', 'nearest')

function listManager:setCurrentList(list)
  self.currentList = list
end

function listManager:getTotalPages()
  return math.ceil(#self.currentList.items / self.pageSize)
end

function listManager:getItemsAtCurrentPage()
  local totalPages = self:getTotalPages()
  local _, n, _ = self:getCommon()
  return self.pageSize - ((totalPages * self.pageSize) - n)
end

function listManager:getSelectedItem()
  local list = self.currentList
  local item = list.items[list.index]
  if not item then error('No item at index ' .. list.index) end
  return item
end

function listManager:getCommon()
  local list = self.currentList
  local n = #list.items
  local totalPages = math.ceil(n / self.pageSize)

  return list, n, totalPages
end

function listManager:draw(isSystemsList)
  local list = self.currentList

  if not list then return end
  local from = 1 + (list.page.pageNumber - 1) * self.pageSize
  local to = from + self.pageSize - 1
  local yPosition = 0
  local lineHeight = love.graphics.getFont():getHeight() + 1
  for i = from, to do
    local item = list.items[i]
    if not item then goto continue end
    love.graphics.setColor(colors.white)
    if isSystemsList then
      if item.isDir and not item.isSystem then
        love.graphics.setColor(colors.blue)
      end
    else
      love.graphics.setColor(item.color or colors.white)
    end

    utils.pp(constants.systemsLabels[item.label] or item.label,
      constants.PADDING_LEFT,
      constants.PADDING_TOP + yPosition * lineHeight
    )

    if yPosition == (list.page.indexAtCurrentPage - 1) then
      love.graphics.setColor(colors.white)
      love.graphics.draw(pointer,
        constants.PADDING_LEFT - pointer:getWidth(),
        math.floor(
          constants.PADDING_TOP +
          yPosition * lineHeight
        )
      )
    end
    yPosition = yPosition + 1

    ::continue::
  end
end

function listManager:back(value, listsStack, pathStack, currentScreen)
  local currentListsStack = listsStack[currentScreen]
  local currentPathStack = pathStack[currentScreen]

  if #currentListsStack > 1 then
    table.remove(currentListsStack)
    table.remove(currentPathStack)
    self.currentList = currentListsStack[#currentListsStack]
    if currentListsStack == listsStack[_G.screens.systems] and #currentListsStack == 1 then
      _G.systemSelected = nil
    end
  end
end

function listManager:handleLastPage()
  local list, n, totalPages = self:getCommon()
  local itemsAtCurrentPage = self:getItemsAtCurrentPage()
  if list.page.pageNumber == totalPages then
    if list.page.indexAtCurrentPage > itemsAtCurrentPage then
      list.page.indexAtCurrentPage = itemsAtCurrentPage
    end
    list.index = (totalPages - 1) * self.pageSize + list.page.indexAtCurrentPage
  end
end

function listManager:left()
  local list, n, totalPages = self:getCommon()
  if totalPages == 1 then return end

  list.index = list.index - self.pageSize
  list.page.pageNumber = list.page.pageNumber - 1

  if list.page.pageNumber < 1 then
    list.page.pageNumber = totalPages
  end
  self:handleLastPage()
end

function listManager:right()
  local list, n, totalPages = self:getCommon()
  if totalPages == 1 then return end

  list.index = list.index + self.pageSize
  list.page.pageNumber = list.page.pageNumber + 1

  if list.index > n then
    list.index = 1
  end
  if list.page.pageNumber > totalPages then
    list.page.pageNumber = 1
  end
  self:handleLastPage()
end

function listManager:up()
  local list, n, totalPages = self:getCommon()
  -- internal index
  list.index = list.index - 1
  list.page.indexAtCurrentPage = list.page.indexAtCurrentPage - 1

  if list.index < 1 then
    list.index = n
  end

  -- index to display
  if list.page.indexAtCurrentPage < 1 then
    -- handle first page
    local itemsInCurrentPage = self.pageSize
    if list.page.pageNumber == 1 then
      itemsInCurrentPage = self.pageSize - ((totalPages * self.pageSize) - n)
    end
    
    list.page.indexAtCurrentPage = itemsInCurrentPage
    list.page.pageNumber = list.page.pageNumber - 1

    -- going beyond the last page
    if list.page.pageNumber < 1 then
      list.page.pageNumber = totalPages
    end
  end
end

function listManager:down()
  local list, n, totalPages = self:getCommon()
  -- internal index
  list.index = list.index + 1
  list.page.indexAtCurrentPage = list.page.indexAtCurrentPage + 1

  if list.index > n then
    list.index = 1
  end

  -- handle last page
  local itemsInCurrentPage = self.pageSize
  if list.page.pageNumber == totalPages then
    itemsInCurrentPage = self.pageSize - ((totalPages * self.pageSize) - n)
  end

  -- index to display
  if list.page.indexAtCurrentPage > itemsInCurrentPage then
    list.page.indexAtCurrentPage = 1
    list.page.pageNumber = list.page.pageNumber + 1

    -- going beyond the last page
    if list.page.pageNumber > totalPages then
      list.page.pageNumber = 1
    end
  end
end

function listManager:performAction(listsStack, pathStack, cb)
  local item = self:getSelectedItem()
  local currentListsStack = listsStack[currentScreen]
  local currentPathStack = pathStack[currentScreen]

  if item.items and #item.items > 0 then
    table.insert(currentListsStack, item)
    table.insert(currentPathStack, item.label)
    if item.isSystem then -- set selected system (gb, nes, etc.)
      _G.systemSelected = item.label
    end
    self.currentList = item
  else 
    cb(item)
  end
end

return listManager

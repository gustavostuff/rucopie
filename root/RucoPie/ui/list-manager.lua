
local constants = require 'constants'
local colors = require 'colors'
local utils = require 'utils'

return {
  draw = function (listToDisplay, isSystemsList, pageSize)
    if not listToDisplay then return end
    local from = 1 + (listToDisplay.page.pageNumber - 1) * pageSize
    local to = from + pageSize - 1
    local yPosition = 0
    for i = from, to do
      local item = listToDisplay.items[i]
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
        constants.PADDING_TOP + yPosition * love.graphics.getFont():getHeight()
      )

      if yPosition == (listToDisplay.page.gameIndex - 1) then
        love.graphics.setColor(colors.white)
        love.graphics.circle('fill',
          constants.PADDING_LEFT - 10,
          math.floor(constants.PADDING_TOP + yPosition * love.graphics.getFont():getHeight()) + 5,
          5
        )
      end
      yPosition = yPosition + 1

      ::continue::
    end
  end
}

local utils = require 'utils'
local osBridge = require 'os-bridge'
local constants = require 'constants'

local joystickManager = {
  generalMapping = {
    ['hat'] = {
      index = 1,
      done = false,
      labels = {
        'Left', 'Right', 'Up', 'Down'
      },
      map = {}
    },
    ['buttons'] = {
      index = 1,
      done = false,
      labels = {
        'A', 'B', 'Start'
      },
      map = {}
    }
  },
  generalMappingIndex = 1,
  isCurrentlyMapping = false,
  configLoaded = false
}

joystickManager.orderOfMapping = { 'hat', 'buttons' }

-- this iterates over 1 hat and the buttons, in the same order as above^
function joystickManager:mapRequestedInput(value)
  local mappingItem = self.generalMapping[self.orderOfMapping[self.generalMappingIndex]]
  if mappingItem.done then return end

  local index = mappingItem.index

  if index <= #mappingItem.labels then
    mappingItem.map[mappingItem.labels[mappingItem.index]] = value
    mappingItem.index = mappingItem.index + 1

    if mappingItem.index > #mappingItem.labels then
      mappingItem.done = true
      self.generalMappingIndex = self.generalMappingIndex + 1
      if self:allSet() then
        self.generalMappingIndex = 1
        self.isCurrentlyMapping = false
        osBridge.saveFile(
          'return {\n' ..
            utils.tableToString(self.generalMapping) ..
          '}',
          constants.JOYSTICK_CONFIG_PATH
      )
      end
    end
  end
end


function joystickManager:getButton(buttonLabel)
  return self.generalMapping['buttons'].map[buttonLabel]
end

function joystickManager:getHat(hatLabel)
  return self.generalMapping['hat'].map[hatLabel]
end

function joystickManager:getInputBeingMapped()
  local mappingItem = self.generalMapping[self.orderOfMapping[self.generalMappingIndex]]
  return mappingItem.labels[mappingItem.index]
end

function joystickManager:allSet()
  local done = true
  for i = 1, #self.orderOfMapping do
    if not self.generalMapping[self.orderOfMapping[i]].done then
      return false
    end
  end
  return done
end

return joystickManager

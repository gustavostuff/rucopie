local utils = require 'utils'

local threadManager = {
  list = {},
  index = 1
}

-- file is relative to ~/RucoPie/ui/threads/
-- data must be a plain table
function threadManager:run(file, cb, data, times)
  data = data or {}
  times = times or -1

  local threadInfo = {
    name = name,
    cb = cb or (function() end),
    times = times,
    timesCounter = 0,
  }
  threadInfo.channel = 'channel-' .. self.index
  threadInfo.thread = love.thread.newThread('threads/' .. file .. '.lua')
  threadInfo.thread:start(threadInfo.channel, data)
  self.list[self.index] = threadInfo
  self.index = self.index + 1
end

function threadManager:update(dt)
  for name, item in pairs(self.list) do
    local error = item.thread:getError()
    assert(not error, error)

    local value = love.thread.getChannel(item.channel):pop()

    if value then
      item.cb(value)
      item.timesCounter = item.timesCounter + 1
      if item.timesCounter ~= -1 and (item.timesCounter >= item.times) then
        -- remove item
        self.list[name] = nil
        -- at this point thread execution should be done
      end
    end
  end
end

return threadManager

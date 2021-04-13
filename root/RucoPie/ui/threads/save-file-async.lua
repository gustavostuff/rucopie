local constants = require 'constants'

local channel = ({...})[1]
local data = ({...})[2]

local file = io.open(constants.RUCOPIE_DIR .. data.path, 'w')

file:write(data.content)
file:close()

love.thread.getChannel(channel):push('file-saved')

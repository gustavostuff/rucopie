local utils = require '../utils'

local channel = ({...})[1]
local data = ({...})[2]

utils.debug('Connecting to Wifi with:', data.command)
os.execute(data.command)
love.thread.getChannel(channel):push('connection-attempt-done')

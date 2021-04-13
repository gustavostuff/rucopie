local utils = require '../utils'

local channel = ({...})[1]
local data = ({...})[2]

utils.debug('Executing RetroArch with command:', data.command)
os.execute(data.command)
love.thread.getChannel(channel):push('retroarch-done')

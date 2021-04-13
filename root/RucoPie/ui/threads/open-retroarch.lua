local utils = require '../utils'

local channel = ({...})[1]
local data = ({...})[2]

utils.debug('Executing RetroArch with command:', data.command)
os.execute(data.command)
utils.debug('RetroArch has been closed.')
utils.debug('Returning value in channel:', channel)
love.thread.getChannel(channel):push('retroarch-done')

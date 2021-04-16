local osBridge = require 'os-bridge'
local resolutionManager = {}
-- resolutions provided by retroarch cores:
local resolutions =  {
  gambatte = { w = 160, h = 144 },
  fceumm = { w = 256, h = 224 },
  snes9x = { w = 256, h = 224 },
  fbneo = { w = 304, h = 224 },
  stella2014 = { w = 320, h = 210 },
}


-- sets optimal resolution for this core
function resolutionManager.calculate(core)
  local xResolution, yResolution = resolutions[core].w, resolutions[core].h
  local xOriginal, yOriginal = resolutions[core].w, resolutions[core].h
  local scale = 1

  repeat
    scale = scale + 1
    xResolution = xOriginal * scale
    yResolution = yOriginal * scale
  until yResolution >= love.graphics.getHeight() -- limit to screen's height

  scale = scale - 1
  return scale, xOriginal * scale, yOriginal * scale
end

function resolutionManager.saveScaleForCore(core, w, h)
  local result = osBridge.updateConfigs(core, {
    custom_viewport_width = w,
    custom_viewport_height = h
  })

  local screenW = love.graphics.getWidth()
  local screenH = love.graphics.getHeight()
  osBridge.saveFile(
    'This file means RucoPie has been executed in this resolution.',
    'cache/' .. screenW .. 'x' .. screenH .. '.lock'
  )

  return result
end

return resolutionManager

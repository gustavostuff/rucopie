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

function resolutionManager.calculate(core)
  local xResolution, yResolution = resolutions[core].w, resolutions[core].h
  local xOriginal, yOriginal = resolutions[core].w, resolutions[core].h
  local scale = 1

  repeat
    scale = scale + 1
    xResolution = xOriginal * scale
    yResolution = yOriginal * scale
  until yResolution >= love.graphics.getHeight()

  local result = osBridge.udpateConfigs(core, {
    custom_viewport_width = xOriginal * (scale - 1),
    custom_viewport_height = yOriginal * (scale - 1)
  })
  return result
end

return resolutionManager

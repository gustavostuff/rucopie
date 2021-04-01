-- using colors from https://lospec.com/palette-list/dawnbringer-32
local colors = {
  white  = {1, 1, 1},
  black  = {0, 0, 0},
  red    = {0.851, 0.341, 0.388},
  blue   = {0.373, 0.804, 0.894},
  purple = {0.247, 0.247, 0.455},
  yellow = {0.984, 0.949, 0.212},
  green  = {0.416, 0.745, 0.188},
  orange = {0.875, 0.443, 0.149},
}

-- tweak for older versions of LOVE
-- for k, c in pairs(colors) do
--   colors[k] = { c[1] * 255, c[2] * 255, c[3] * 255 }
-- end

return colors

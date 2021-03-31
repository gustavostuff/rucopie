local imgFolder = 'assets/img/'
local iconsFolder = imgFolder .. 'icons/'

local images = {
  icons = {
    folder = love.graphics.newImage(iconsFolder .. 'folder.png'),
    cog = love.graphics.newImage(iconsFolder .. 'cog.png')
  }
}

for k, img in pairs(images.icons) do
  img:setFilter('nearest', 'nearest')
end

return images


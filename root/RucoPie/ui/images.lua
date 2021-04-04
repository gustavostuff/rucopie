local imgFolder = 'assets/img/'
local iconsFolder = imgFolder .. 'icons/'

local images = {
  icons = {
    defaultPointer = love.graphics.newImage(iconsFolder .. 'default-pointer.png'),
    folder = love.graphics.newImage(iconsFolder .. 'folder.png'),
    checkboxOff = love.graphics.newImage(iconsFolder .. 'checkbox-off.png'),
    checkboxOn = love.graphics.newImage(iconsFolder .. 'checkbox-on.png'),
    cog = love.graphics.newImage(iconsFolder .. 'cog.png')
  }
}

for k, img in pairs(images.icons) do
  img:setFilter('nearest', 'nearest')
end

return images


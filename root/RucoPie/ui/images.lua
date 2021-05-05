local imgFolder = 'assets/img/'
local iconsFolder = imgFolder .. 'icons/'
local videoModePreviewsFolder = imgFolder .. 'video-mode-previews/'

local function loadImages(dir)
  local items = {}
  for file in lfs.dir('/root/RucoPie/ui/' .. dir) do
    if file ~= "." and file ~= ".." then
      items[file] = love.graphics.newImage(dir .. file)
    end
  end

  return items
end

local images = {
  icons = loadImages(iconsFolder),
  videoModePreviews = loadImages(videoModePreviewsFolder),
  cursor = love.graphics.newImage(imgFolder .. 'default-cursor.png')
}

for section, item in pairs(images) do
  if type(item) == 'table' then
    for k, img in pairs(item) do
      img:setFilter('nearest', 'nearest')
    end
  else
    item:setFilter('nearest', 'nearest')
  end
end

return images


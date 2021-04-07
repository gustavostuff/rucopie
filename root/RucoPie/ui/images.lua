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
  videoModePreviews = loadImages(videoModePreviewsFolder)
}

for section, list in pairs(images) do
  for k, img in pairs(list) do
    img:setFilter('nearest', 'nearest')
  end
end

return images


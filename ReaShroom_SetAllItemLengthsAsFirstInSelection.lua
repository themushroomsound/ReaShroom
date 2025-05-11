
reaper.ClearConsole()
local errors = {}
    
-- Get the first selected item
local firstItem = reaper.GetSelectedMediaItem(0, 0)
if firstItem == nil then return end -- Exit if no item is selected

-- Get the length of the first selected item
local firstItemLength = reaper.GetMediaItemInfo_Value(firstItem, "D_LENGTH")

-- Iterate through all selected items starting from the second one
for i = 1, reaper.CountSelectedMediaItems(0) - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    if item then
        -- Set the length of the current item to match the first item's length
        reaper.SetMediaItemInfo_Value(item, "D_LENGTH", firstItemLength)
    end
end

-- Update the arrange view
reaper.UpdateArrange()

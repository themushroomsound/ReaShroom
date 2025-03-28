-- Get the number of selected items
local numSelectedItems = reaper.CountSelectedMediaItems(0)

-- Check if there are selected items
if numSelectedItems < 1 then
	reaper.ShowMessageBox("No items are selected.", "Info", 0)
	return
end

reaper.ClearConsole()
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()

-- Iterate through the selected items
for i = 0, numSelectedItems - 1 do

	-- Get the selected item at index 'i'
	local selectedItem = reaper.GetSelectedMediaItem(0, i)
	
	-- Get the name of the selected item
	local _, itemNotes = reaper.GetSetMediaItemInfo_String(selectedItem, "P_NOTES", "", false)
	local itemTake = reaper.GetMediaItemTake(selectedItem, 0)
	local regionName
	if itemTake then
		local _, itemTakeName = reaper.GetSetMediaItemTakeInfo_String(itemTake, "P_NAME", "_", false)
		regionName = itemTakeName
	else
		regionName = itemNotes
	end
	local itemColor = reaper.GetMediaItemInfo_Value(selectedItem, "I_CUSTOMCOLOR")
	local itemStart = reaper.GetMediaItemInfo_Value(selectedItem, "D_POSITION")
	local itemLength = reaper.GetMediaItemInfo_Value(selectedItem, "D_LENGTH")
	
	-- Create the region
	reaper.AddProjectMarker2(0, true, itemStart, itemStart + itemLength, regionName, -1, itemColor)
end

reaper.Undo_EndBlock("Regions to items", -1)
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)

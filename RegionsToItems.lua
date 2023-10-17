-- Create a table to store the region information
local regions = {}

-- Get the total number of regions
local numTotal,numMarkers,numRegions = reaper.CountProjectMarkers(0)

reaper.ShowConsoleMsg("Total markers & regions: " .. numTotal .. "\n", "Info", 0)
reaper.ShowConsoleMsg("Total regions: " .. numRegions .. "\n", "Info", 0)
reaper.ShowConsoleMsg("Total markers: " .. numMarkers .. "\n", "Info", 0)

if numRegions == 0 then
    reaper.ShowMessageBox("No regions found in the project.", "Info", 0)
	return
end

reaper.ClearConsole()

for i = 0, numTotal - 1 do
	local _, isRegion, regionStart, regionEnd, regionName, regionIdx, regionColor = reaper.EnumProjectMarkers3(0, i)
	if isRegion then
		table.insert(regions, {name = regionName, start = regionStart, endd = regionEnd, color = regionColor})
	end
end

-- Sort the regions by name and start time
table.sort(regions, function(a, b)
	return a.name < b.name or (a.name == b.name and a.start < b.start)
end)

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()

-- Write the regions to new tracks as items
local prevRegionName = ""
local trackCpt = 0
local itemCpt = 0
local newTrack, newItem

for _, region in ipairs(regions) do

	-- Create track for each distinct region name
	if region.name ~= prevRegionName then
		prevRegionName = region.name
		
		-- Create a new track
		reaper.InsertTrackAtIndex(trackCpt, false)
		newTrack = reaper.GetTrack(0, trackCpt)
		
		-- Name the new track
		reaper.GetSetMediaTrackInfo_String(newTrack, "P_NAME", region.name, true)

		trackCpt = trackCpt + 1
		itemCpt = 0		
	end
		
	-- Create item for each region
	local newItem = reaper.AddMediaItemToTrack(newTrack)
	reaper.SetMediaItemPosition(newItem, region.start, false)
	reaper.SetMediaItemLength(newItem, region.endd - region.start, false)
	reaper.GetSetMediaItemInfo_String(newItem, "P_NOTES", region.name, true)
	reaper.SetMediaItemInfo_Value(newItem, "I_CUSTOMCOLOR", region.color)
	
	itemCpt = itemCpt + 1
end	

reaper.Undo_EndBlock("Regions to items", -1)
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
-- Build a dictionary of all tracks in a project keyed by GUID.
-- @param proj ReaProject (use 0 for current project)
-- @param include_master boolean (true to include master track)
-- @return dict table where dict[guid_string] = MediaTrack userdata
-- @return order table array of GUIDs in enumeration order (optional convenience)
function BuildTrackDictByGUID(proj, include_master)
    proj = proj or 0
    include_master = (include_master == nil) and false or include_master

    local dict = {}
    local order = {}

    -- Optionally include Master track
    if include_master then
        local master = reaper.GetMasterTrack(proj)
        if master then
            local guid = reaper.GetTrackGUID(master) -- string GUID
            dict[guid] = master
            order[#order + 1] = guid
        end
    end

    -- Normal tracks
    local track_count = reaper.CountTracks(proj)
    for i = 0, track_count - 1 do
        local tr = reaper.GetTrack(proj, i)
        if tr then
            local guid = reaper.GetTrackGUID(tr)
            dict[guid] = tr
            order[#order + 1] = guid
        end
    end

    return dict, order
end

-- Get the number of selected items
local numSelectedItems = reaper.CountSelectedMediaItems(0)

-- Check if there are selected items, abort if none
if numSelectedItems < 1 then
	reaper.ShowMessageBox("No items are selected.", "Info", 0)
	return
end

reaper.ClearConsole()
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()

-- Build a dictionary of all GUID -> Track
local tracksByGUID, order = BuildTrackDictByGUID(0, true)

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
	local newRegionIdx = reaper.AddProjectMarker2(0, true, itemStart, itemStart + itemLength, regionName, -1, itemColor)

	-- Get render tracks string from the Media
	local _, renderTracksStr = reaper.GetSetMediaItemInfo_String(selectedItem, "P_EXT:ReaShroomRtI:RenderTracks", "", false)

	-- For all found render tracks
	for renderTrackGUID in string.gmatch(renderTracksStr, "([^,]+)") do
		
		-- Find the actual track handle based on its GUID
		local renderTrack = tracksByGUID[renderTrackGUID]

		-- If found
		if renderTrack then
			reaper.SetRegionRenderMatrix(0, newRegionIdx, renderTrack, 1)
		end
	end
end

reaper.Undo_EndBlock("Regions to items", -1)
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)

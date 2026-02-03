-- Bootstrap
local sep = package.config:sub(1, 1)
local script_path = ({reaper.get_action_context()})[2]:match("(.*" .. sep .. ")")
package.path = script_path .. "Lib" .. sep .. "?.lua;" .. package.path

-- Dependency
package.loaded["ReaShroom_RegionsToItems_Module"] = nil -- to remove
local RtI = require("ReaShroom_RegionsToItems_Module")
RtI.msg("Loaded RegionsToItems LUA module")

-- Get the number of regions, abort if none
local numRegions = RtI.GetNbRegions()

if numRegions == 0 then
    reaper.ShowMessageBox("No regions found in the project.", "Info", 0)
    return
end

reaper.ClearConsole()

-- Create a table to store the region information
local regions = RtI.GetRegionsData()

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
	RtI.CreateRegionItem(newTrack, region)

    itemCpt = itemCpt + 1
end

reaper.Undo_EndBlock("Regions to items", -1)
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)

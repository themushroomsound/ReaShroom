local RtI = {}

-- prints to reaper console
function RtI.msg(s)
    reaper.ShowConsoleMsg(tostring(s) .. "\n")
end

-- gets the total number of markers and regions in the project
function RtI.GetNbMarkersAndRegions(proj)
    proj = proj or 0
    return ({reaper.CountProjectMarkers(proj)})[1]
end

-- gets the total number of markers and regions in the project
function RtI.GetNbRegions(proj)
    proj = proj or 0
    return ({reaper.CountProjectMarkers(proj)})[3]
end

-- gets the list of tracks to render for a region
function RtI.GetRenderTracksForRegion(proj, regionIndex)
    proj = proj or 0
    local tracks, i = {}, 0
    while true do
        local tr = reaper.EnumRegionRenderMatrix(proj, regionIndex, i)
        if not tr then
            break
        end
        tracks[#tracks + 1] = tr
        i = i + 1
    end
    return tracks
end

-- gets all regions informations
function RtI.GetRegionsData(proj)
    proj = proj or 0

    -- Create a table to store the region information
    local regions = {}
    local numTotal = RtI.GetNbMarkersAndRegions(proj)
    
    -- Enumerate all markers and regions
    for i = 0, numTotal - 1 do
        local _, isRegion, regionStart, regionEnd, regionName, regionIdx, regionColor = reaper.EnumProjectMarkers3(0, i)

        -- Ignore markers
        if not isRegion then goto continue end

        -- Give a name to unnamed regions
        if regionName == "" then
            regionName = "Unnamed Region"
        end

        -- Add that region's data to the list
        regions[#regions+1] = {
            name  = regionName,
            start = regionStart,
            endd  = regionEnd,
            color = regionColor,
            renderTracks = RtI.GetRenderTracksForRegion(proj, regionIdx)
        }
        ::continue::
    end

    -- Sort the regions list by name and start time
    table.sort(regions, function(a, b)
        return a.name < b.name or (a.name == b.name and a.start < b.start)
    end)

    return regions
end

-- gets a list of a region's render tracks GUIDs as a concatenated string
function RtI.GetRenderTracksGUIDs(regionData)
    local GUIDs = {}
    for _, track in ipairs(regionData.renderTracks) do
        GUIDs[#GUIDs+1] = reaper.GetTrackGUID(track)
    end    
    return table.concat(GUIDs, ",")
end

-- creates a new item on a track from a region's data
function RtI.CreateRegionItem(track, regionData)
    local newItem = reaper.AddMediaItemToTrack(track)
    local newTake = reaper.AddTakeToMediaItem(newItem)
    reaper.GetSetMediaItemTakeInfo_String(newTake, "P_NAME", regionData.name, true)
    reaper.SetMediaItemPosition(newItem, regionData.start, false)
    reaper.SetMediaItemLength(newItem, regionData.endd - regionData.start, false)
    reaper.SetMediaItemInfo_Value(newItem, "I_CUSTOMCOLOR", regionData.color)
    reaper.SetMediaItemInfo_Value(newItem, "I_CURTAKE", 0)
    
    -- save this region's render tracks in the item's metadata
    reaper.GetSetMediaItemInfo_String(newItem, "P_EXT:ReaShroomRtI:RenderTracks", RtI.GetRenderTracksGUIDs(regionData), true)
end

return RtI
local function parseSettings(retvalsCsv)
    local minCentsStr, maxCentsStr = retvalsCsv:match("^%s*([^,]+)%s*,%s*([^,]+)%s*$")
    if not minCentsStr or not maxCentsStr then
        return nil, nil, "- Min and max cents are required"
    end

    local minCents = tonumber(minCentsStr)
    local maxCents = tonumber(maxCentsStr)
    local errors = {}

    if minCents == nil then
        errors[#errors + 1] = "- Minimum cents needs to be a number"
    end

    if maxCents == nil then
        errors[#errors + 1] = "- Maximum cents needs to be a number"
    end

    if minCents ~= nil and maxCents ~= nil and minCents > maxCents then
        errors[#errors + 1] = "- Minimum cents needs to be less than or equal to maximum cents"
    end

    if #errors > 0 then
        return nil, nil, table.concat(errors, "\n")
    end

    return minCents, maxCents, nil
end

local function promptForSettings(defaultMinCents, defaultMaxCents)
    local defaultValues = string.format("%s,%s", defaultMinCents, defaultMaxCents)

    while true do
        local confirmed, retvalsCsv = reaper.GetUserInputs(
            "Randomize Selected Items Pitch",
            2,
            "Minimum cents,Maximum cents",
            defaultValues
        )

        if not confirmed then
            return nil, nil, true
        end

        local minCents, maxCents, errorMessage = parseSettings(retvalsCsv)
        if errorMessage == nil then
            return minCents, maxCents, false
        end

        reaper.ShowMessageBox(errorMessage, "Errors", 0)
        defaultValues = retvalsCsv
    end
end

local function getSelectedActiveTakes(selectedItemCount)
    local takes = {}

    for index = 0, selectedItemCount - 1 do
        local item = reaper.GetSelectedMediaItem(0, index)
        if item then
            local take = reaper.GetActiveTake(item)
            if take then
                takes[#takes + 1] = take
            end
        end
    end

    return takes
end

local selectedItemCount = reaper.CountSelectedMediaItems(0)
if selectedItemCount < 1 then
    reaper.ShowMessageBox("No items are selected.", "Info", 0)
    return
end

math.randomseed(os.time())

local selectedTakes = getSelectedActiveTakes(selectedItemCount)
if #selectedTakes < 1 then
    reaper.ShowMessageBox("No active takes were found in the selected items.", "Info", 0)
    return
end

local minCents, maxCents, cancelled = promptForSettings(-100, 100)
if cancelled then
    return
end

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

for index = 1, #selectedTakes do
    local take = selectedTakes[index]
    local randomValue = math.random()
    local cents = minCents + ((maxCents - minCents) * randomValue)
    local currentPlayrate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
    local playrateMultiplier = 2 ^ (cents / 1200)
    local playrate = currentPlayrate * playrateMultiplier

    reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE", playrate)
    reaper.SetMediaItemTakeInfo_Value(take, "B_PPITCH", 0)
end

reaper.Undo_EndBlock2(0, "Randomize selected items pitch", -1)
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
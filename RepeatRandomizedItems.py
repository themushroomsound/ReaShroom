from reaper_python import *
import random

RPR_ClearConsole()
errors = []

# Get selected items count
selItemsCount = RPR_CountSelectedMediaItems(0)
if( selItemsCount < 1 ):
    errors.append("- You must select one or more items")

# Get time selection
timeRange = RPR_GetSet_LoopTimeRange(False, False, 0, 0, False)
if( timeRange[2] == timeRange[3] ):
    errors.append("- You must select a time range to define the start and end of the sequence")

# Check for errors
if( len(errors) > 0 ):
    msg = ""
    for error in errors:
        msg += error + "\n"
    RPR_ShowMessageBox(msg, "Errors", 0)

# If no errors...
else:

    # Randomly choose next item to place (avoiding same as last one placed)
    def chooseItem():
        global items, shuffledItems, lastItem
        if( lastItem is None):
            lastItem = items[0]
        if( len(shuffledItems) == 0 ):
            shuffledItems = items[:]
            while( "1st element in shuffled array is the same as last placed item" ): # do...while
                random.shuffle(shuffledItems)
                if( shuffledItems[0] != lastItem or len(items) < 2 ):
                    break;
        lastItem = shuffledItems.pop(0)
        return lastItem

    # Duplicate and place an item
    def duplicateItem(sourceItem, position):
        RPR_ShowConsoleMsg("placing item " + str(sourceItem) + " at position " + str(position) + "\n")
        RPR_SetMediaItemSelected(sourceItem, True)
        RPR_ApplyNudge(0, 1, 5, 1, position, False, 1);
        RPR_SetMediaItemSelected(sourceItem, False)
        return

    # Get selected items
    items = []
    for i in range(0, selItemsCount):
        items.append( RPR_GetSelectedMediaItem(0, i) )
    for item in items:
        RPR_SetMediaItemSelected(item, False)

    # Get user input (period between items positions)
    period = None
    margin = None
    cancel = False
    while( (period is None or period <= 0) and not cancel ):
        res = RPR_GetUserInputs("Settings", 2, "Repeat time (s),Error margin (s)", "1.0,0", 20)

        # check if cancelled
        if( res[0] == 0 ):
            cancel = True
            RPR_ShowConsoleMsg("Cancelled operation\n")

        periodStr, marginStr = res[4].split(",")

        errors = []
        try:
            period = float(periodStr)
        except ValueError:
            errors.append("- Repeat time needs to be a number (in seconds)")

        if( period <= 0 ):
            errors.append("- Repeat time needs to be > 0")

        try:
            margin = float(marginStr)
        except ValueError:
            errors.append("- Error margin needs to be a number (in seconds)")

        if( margin < 0 ):
            errors.append("- Error margin needs to be >= 0")

        if( len(errors) > 0 ):
            msg = ""
            for error in errors:
                msg += error + "\n"
            RPR_ShowMessageBox(msg, "Errors", 0)

    if( not cancel ):

        RPR_PreventUIRefresh(1)
        RPR_Undo_BeginBlock()

        # Insert Items
        cursor = timeRange[2]
        lastItem = None
        shuffledItems = []
        while cursor <= timeRange[3]:
            duplicateItem( chooseItem(), cursor)
            cursor += period + random.uniform(-margin/2, margin/2)

        for item in items:
            RPR_SetMediaItemSelected(item, True)

        RPR_Undo_EndBlock("Repeat randomized items", -1)
        RPR_UpdateArrange()
        RPR_PreventUIRefresh(-1)

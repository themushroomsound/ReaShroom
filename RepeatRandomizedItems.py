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
    while( period is None or period <= 0):
        res = RPR_GetUserInputs("Time between items positions (in seconds)", 1, "", "", 20)
        periodErrors = []
        try:
            period = float(res[4])
        except ValueError:
            periodErrors.append("- Time between items positions needs to be number (in seconds)")
        if( period <= 0 ):
            periodErrors.append("- Time between items positions needs to be greater than 0")
        if( len(periodErrors) > 0 ):
            msg = ""
            for error in periodErrors:
                msg += error + "\n"
            RPR_ShowMessageBox(msg, "Errors", 0)

    # Insert Items
    cursor = timeRange[2]
    lastItem = None
    shuffledItems = []
    while cursor <= timeRange[3]:
        duplicateItem( chooseItem(), cursor)
        cursor += period

    for item in items:
        RPR_SetMediaItemSelected(item, True)

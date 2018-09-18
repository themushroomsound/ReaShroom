from reaper_python import *

errors = []

# Get time selection
timeRange = RPR_GetSet_LoopTimeRange(False, False, 0, 0, False)
if( timeRange[2] == timeRange[3] ):
    errors.append("- You must select a time range to divide")

# Check for errors
if( len(errors) > 0 ):
    msg = ""
    for error in errors:
        msg += error + "\n"
    RPR_ShowMessageBox(msg, "Errors", 0)

# If no errors...
else:

    # Get user input (divisions)
    denominator = None
    while( denominator is None or denominator <= 0):
        res = RPR_GetUserInputs("Enter denominator", 1, "", "", 20)
        denominatorErrors = []
        try:
            denominator = int(res[4])
        except ValueError:
            denominatorErrors.append("- Denominator needs to be an integer")
        if( denominator <= 0 ):
            denominatorErrors.append("- Denominator needs to be greater than 0")

        if( len(denominatorErrors) > 0 ):
            msg = ""
            for error in denominatorErrors:
                msg += error + "\n"
            RPR_ShowMessageBox(msg, "Errors", 0)

    timeRangeLength = timeRange[3] - timeRange[2]
    divisionLength = timeRangeLength / denominator

    markerPos = timeRange[2]
    while markerPos < timeRange[3]:
        markerPos += divisionLength
        RPR_AddProjectMarker(0, False, markerPos, 0, "", -1)

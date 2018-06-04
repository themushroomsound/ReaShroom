from reaper_python import *

# get selected tracks count
nbSelectedTracks = RPR_CountSelectedTracks(0)

if nbSelectedTracks < 2:
    RPR_ShowConsoleMsg("Please select multiple tracks first")

else:
    # get selected tracks names
    trackNames = []
    for trackidx in range(0, nbSelectedTracks):
        curSelectedTrack = RPR_GetSelectedTrack(0, trackidx)
        trackNames.append(RPR_GetSetMediaTrackInfo_String(curSelectedTrack, "P_NAME", "", False)[3])

    # find out length of similar prefix
    letterIndex = 0
    sameLetterAcrossAllNames = True
    similarPrefix = ""

    # iterate over tracks names characters as long as they're similar across all selected tracks
    while sameLetterAcrossAllNames and letterIndex < len(trackNames[0]):
        curLetter = trackNames[0][letterIndex]
        for trackidx in range(1, len(trackNames)):
            if trackNames[trackidx][letterIndex] != curLetter:
                sameLetterAcrossAllNames = False
        if sameLetterAcrossAllNames:
            similarPrefix += curLetter
        letterIndex += 1

    similarPrefixLength = letterIndex - 1
    RPR_ShowConsoleMsg("Removing prefix: " + similarPrefix + " (length: " + str(similarPrefixLength) + ")")

    # set selected tracks names
    for trackidx in range(0, nbSelectedTracks):
        curSelectedTrack = RPR_GetSelectedTrack(0, trackidx)
        newTrackName = trackNames[trackidx][similarPrefixLength:]
        RPR_GetSetMediaTrackInfo_String(curSelectedTrack, "P_NAME", newTrackName, True)

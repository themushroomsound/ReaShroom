# ReaShroom
A collection of Reaper scripts. 
Some were written in Python 2.7. In order to get these to work, you have to install Python and point Reaper to its location (see Reaper's documentation on the subject: https://www.reaper.fm/sdk/reascript/reascript.php#reascript_req_py).

## 1. RemoveStemTracksPrefixes (python)

Removes a common prefix from the names of selected tracks. When you import music stems you often get a number of tracks with names like "MyAwesomeTune_Drums", "MyAwesomeTune_Bass", "MyAwesomeTune_Vocals", etc. You know your tune is awesome, so all you really want to see as tracks names is "Drums", "Bass", "Vocals", etc. That's what this script does.

*How to use it*

Simply select the tracks you want the script to operate on and execute it.

## 2. RepeatRandomizedItems (python)

Generates evenly spaced items chosen randomly from a set of selected items on the same track. This is useful for laying down footstep SFXs on a walking/running animation (if the walking/running is regular). The items sequence is randomized in a way that prevents the same item from being repeated twice in a row.

*How to use it*

1. Place the source items on a track
2. Measure the time between 2 footsteps in your animation cycle
3. Select the time range on which to lay the footsteps
4. Select your source items
5. Execute this script
6. When prompted, enter the time you measured

![repeatrandomizeditems](https://user-images.githubusercontent.com/5003391/43946914-e4ef0c30-9c86-11e8-9202-a846ab055734.gif)

## 3. DivideTimeSelection (python)

Divides a time selection in equal sections, placing a marker at the start of each section.

*How to use it*

1. Select a time range
2. Execute this script
3. When prompted, enter the number of sections into which you would like to divide your time selection

## 4. Regions to Items (lua)

Creates items for all regions in the project (keeping their names and colors), as a form of backup if too many regions make the project hard to read. The script creates tracks for all region names, and regions of the same name are then grouped as items on the same track. Careful when deleting regions afterwards, the region render matrix information is not saved to the newly created items.

## 5. Items to Regions (lua)

Creates regions for all selected items (keeping their names and colors), typically to restore previously saved regions using the previous script.

Enjoy!

Overview

Songbook is a plugin for browsing your abc song files and playing them with a click of a button. The plugin consists of two parts, an in-game plugin which displays the song library, and an external windows program that generates a list of your abc song files in a format that the plugin can read (Songbooker).

Features

-Browse all your abc files in-game
-Toggle music mode
-Select and play a song just by clicking with your mouse
-Support for starting synced play and making a ready check
-Moveable and resizable window
-Support for subdirectories
-Support for songs with multiple parts
-Display of actual song names and not just the filename
-Complimentary multi part abc file, Oolannin sota!
-Optional song parts display which can be used to view and directly select parts.
-Support for German and French clients
-Search feature
-Custom commands for pasting song information to a chat channel
-Slots for instruments or other items/skills (which are saved per character)
-Chief mode to enable band leader functionality

New in version 0.98a:
Several functions to support bands and band leaders
-Automatic assignment of parts to players based on skills and preferences
-Announcement of parts assignment to group/raid chat (selectable)
-Song-specific instrument dropdown list to facilitate finding and selecting the right instrument
-View/edit of instruments skills of band members
-View/edit of instrument preferences of band members
-Transmit instrument skills to band leader
-Manual addition/removal of players to compensate for corrupted group information


Installation

-If you haven't used plugins before it's good to read this post first: http://forums.lotro.com/showthread.php?354331-Introduction-to-Lua-UI-scripts
-Unzip the plugin to your 'Documents/The Lord of the Rings Online/Plugins' folder.
-If you have upgraded from a previous version, you probably have to run Songbooker before your song library works again. See instructions below.

How to use

-IMPORTANT - Download the Songtools (Songbooker and Songbrowser) to quickly generate and maintain your library.
-IMPORTANT - Before loading the plugin, use Songbooker to build your library. Run it whenever you have made changes to your song library.
-To load the plugin type '/plugins load songbookbb'.
-Click M button to toggle music mode (make sure you have an instrument equipped).
-Select a song by clicking it and then press play button to start playing. There's also buttons for readying for synced play and starting sync play.
-Click and drag from the bottom right corner of the window to resize it.
-Click and drag the title bar to move the window.
-Closing the window will save its position and size, as well as the settings and instrument assignment data.
-Drag the separator lines to scale the sizes of directory, song, and part lists.
-If the song has multiple parts, you can enable the song parts display (in the settings) and directly select parts from there.
-Answers to commonly asked questions can be found here: https://www.linawillow.org/home/plugins-2/songbook/

Command line options

-/songbookbb show - shows the Songbook window
-/songbookbb hide - hides the Songbook window
-/songbookbb toggle - toggles the Songbook window
-/songbookbb - lists command line options

Known issues and comments

-Songs with special characters, such as accents, in their file names will not play with the plugin. This seems to be a problem with the plugin API.
- The player list may get corrupted. In such a case, the only way to get a correct player list again is to disband and reform the group/raid. (Note that With the manual add/remove feature, you can re-create the correct group setting without disbanding the group.)


Future plans

- Allow band leader to temporarily disable instruments that players have forgotten on that day
- Not only remember the last assigned instrument, but keep a history of assigned instruments to minimize instrument changes
- Keep a backup of the settings to prevent full data loss due to corruption (e.g., due to link loss during saving the settings)

Future future plans

- Allow to have more than one instrument preference list to support band leaders with multiple bands with members with different preferences in different bands


Version history

0.98a (11/05/2023) - Nimelia

- Support for the band leader in generating instrument assignments for bands
  - View/edit instrument skills of all band members
  - View/edit instrument preferences for all band members
  - Exchange of instrument skill data among players (enable via settings)
  - Automatic assignment of parts to band members according to their skills and preferences
  - The band leader can assign singing duty to some members (they will not be assigned wind instruments)
  - The band leader can exclude some members from assignment (in case they are afk)
  - Support for manual pre-assignment of some parts to specific players before automatic assignment
  - Players keep their last assigned instruments into the next assignment if possible
  - Announcement of the parts assignment in chat (fellowship, raid or custom chat)
  - Announcements can be sorted by parts or by player names
  - Announcements can be reduced to include only some players (who need a reminder)
  - Players can be manually added/removed from the player list in case the player list is corrupted

- Interface improvements
  - When a song is selected, instruments from the quickslots that are identified in track names can be accessed via a dropdown list for easy switch
    (no more frantic fiddle search...)
  - Better visual and placement of Start-Sync button to decrease likelihood of accidental use by band members
  - Top button bar by default only selects the M, Play, Sync-Ready, Start-Sync buttons (the others can be enabled/disabled in settings)
  - Number of players in fellowship/raid is displayed on the Players button
  - Song timer is now more prominent and flashes for the last ten seconds of the song
  - When wrong instrument is readied, the required instrument text is more prominent and flashes for several seconds
  - Currently equipped instrument is shown
  - Default settings (after a fresh installation) have been adapted to the typical needs of bands

- Other
 - All instruments currently available in the game are recognized
 - Reload of songbook library possible from within the Songbook plugin


0.95b (12/01/2018) - Zedrock

- New Instruments Slots container with two display mode : 
  * Free sizeable Instrument Slots container.
  * Horizontal forced with horizontal scrollbar to access to instruments without resizing Songbook window width.

- New Instrument equip guessing :  
  * Adding Fiddle and Bassoon recognition.
  * Accurate recognition for Instrument Name which following the LOTRO-Maestro typos. Especially for kind of bassoon, kind of fiddle, kind of harp, kind of cowbell and kind of lute.

- Filters and Players list splited.

- Timer position / Wrong Instrument warning Messages changing from Track list separator to new line added upon the Dir list header.

- Minor changes : 
  * Fix : bug when switching local FR/DE client in EN language.
  * Main songbook window minimum size changes.
  * Avoid songbook window to be resized beyond the user screen width and height.
  * Hack : refresh the Players list when starting Songbook.
  * User Players list is now refreshing when user leave himself or join himself a fellowship.
  * Display the Fellowship leader with different font text in Players list.
  * Hack : maintain aligned to right tracks list when scrolled.

0.94 (1/10/2015) The Brandy Badger Chapter - Nimelia
- Support for different band sizes
  - Songtools (Songbooker and Songbrowser, extra download) to specify instrument line-ups for different band sizes
    (use Songbrowser to create line-ups, Songbooker to create the Songbook library)
  - Players list indicating each band member's play ready state by color or separate indicator column
  - Special column next to the parts list to select instrument line-ups for different band sizes
  - Search filters and tags 

- Interface changes
  - If wrong instrument is selected when readying a part, a warning is displayed
  - When the song starts playing, a timer shows the progress in the song (up/down can be chosen via settings; song duration is taken from the song title)

- Some minor fixes

0.92 (15/07/2013) - Chiran (all below are also Chiran)
-Fixed account name reading for library generator (hta/exe)

0.91 (21/05/2013)
-Fixed button opacity

0.90 (12/01/2013)
-Added option to change button opacity
-Added option to add or remove instrument slots
-Added checks to keep window inside game window
-Pressing enter on search field should start search
-Fixed a crash with empty song list
-Added localization fixes
-Plugin outputs version on load
-Added icon for plugin manager

0.83 (03/10/2011)
-new setting for displaying song description first
-localization fix for instrument slots
-French and German text fixes

0.82 (27/06/2011)
-Added German translations for instrument slots
-Fixed a crash with slots and items that are no longer in inventory

0.81 (14/06/2011)
-fixed error with loading instrument settings
-fixed search and song description setting not saving correctly

0.80 (14/06/2011)
-added 8 slots for instruments or other items/skills (saved per character)
-added an option to show full description in the song list
-songbook button can no longer be moved outside the screen

0.74 (05/06/2011)
-fixed a nasty bug with directory list code
-removed forced z-order setting

0.73 (02/06/2011)
-now the directory list works more like a real directory browser
-corrected sync keyword with French translation

0.72 (24/2/2011)
-.ABC extension no longer shown in song list
-fixed a problem with tracks that have multiple T: lines
-tried to fix problems with string conversions of settings
-settings are now saved on unload
-made the launch button semi-transparent when not active
-.hta file now finds files with .txt extension
-window can be closed with esc (but it might still show game menu as well)

0.71 (29/11/2010)
-button location is now saved with other settings

0.70 (29/11/2010)
-new feature: Search
-new feature: Custom commands *experimental*
-support for Nov 29 patch
-added a movable start button/icon
-new settings window
-list labels now display the number of list items
-made song part arrow buttons larger
-fixed hta parsing for songs with .ABC extension
-made hta a bit clearer when username is not found
-plugin now uses native ClearItems and CheckBox
-plugin now hides when F12 is pressed

0.61 (08/11/2010)
-support for German clients (big thanks to Thorsongori for translations and testing!)
-support for French clients (big thanks to Vevenalia for translations and testing!)
-fixed a bug with part change arrows
-clicking track change arrow also changes the focus on the parts list
-fixed button corner transparency
-initial support for Lotro Mod Manager 1.0.5

0.60 (13/10/2010)
-song parts now support any numbering schemes, this required a change in the database structure
-added a toggleable song parts display
-cleaned up user interface scaling code, and fixed some bugs with it
-added titles to list boxes

0.54 (03/10/2010)
-fixed another bug with empty root directory
-included an icon for the hta file (thanks Balgosa!)
-fixed an issue with some abc files causing database corruption (the dreaded unable to parse file error)

0.53 (23/09/2010)
-fixed one more bug with arrows *slaps himself*

0.52 (23/09/2010)
-vbs script now replaced with hta file (basically vbscript embedded in html document)
-the script should now automatically detect all the needed information (that is, lotro directory and lotro user name)
-abc comment markings are now filtered out
-songs with spaces in their filenames work now
-fixed a bug with part change arrows
-complimentary song!

0.51 (22/09/2010)
-Fixed a bug with empty root directory

0.50 (21/09/2010)
-Support for sub directories!
-Support for songs with multiple parts!
-The selected song now displays the real name of the song/part, not filename
-Removed .abc from song names, they weren't really needed
-Added more feedback to vbs script in case of problems

0.22 (18/09/2010)
-vbs script bug fix

0.21 (18/09/2010)
-Removed unnecessary debug output from vbs script

0.20 (18/09/2010)
-Support for synced play
-Button for making a ready check
-Refreshed UI
-VBScript now supports Windows XP and 2000
-VBScript now checks for required directories and also creates the plugin data directory if needed
-VBScript allows a second parameter for overriding the location of Documents folder

0.10 (17/09/2010)
-Initial release

Have fun!

-Chiran, Laurelin (EU)


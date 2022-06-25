Overview

Songbook is a plugin for browsing your abc song files and playing them with a click of a button. The plugin consists of two parts, an in-game plugin which displays the song library, and an external windows program that generates a list of your abc song files in a format that the plugin can read. The external program is realized as a HTA file (VBScript) so that it's fairly easy to check for safety.

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
-Support for German clients (big thanks to Thorsongori for translations and testing!)
-Support for French clients (big thanks to Vevenalia for translations and testing!)
-Search feature
-Custom commands for pasting song information to a chat channel *experimental*
-Slots for instruments or other items/skills (which are saved per character)

Installation

-If you haven't used plugins before it's good to read this post first: http://forums.lotro.com/showthread.php?354331-Introduction-to-Lua-UI-scripts
-Unzip the plugin to your 'Documents/The Lord of the Rings Online/Plugins' folder.
-If you have upgraded from a previous version, you probably have to run the songbook.hta file before your song library works again. See instructions below.

How to use

-IMPORTANT - Before loading the plugin, use the supplied songbook.hta file to build your library. Double click the file to run it, or just make a shortcut to it and place it anywhere you want. Run it whenever you have made changes to your song library. You can also use a great tool by Arnho (http://lotro.hanft.de/wansongbookfiller/), especially if you have problems with building being slow.
-To load the plugin type '/plugins load songbook'.
-Click M button to toggle music mode (make sure you have an instrument equipped).
-Select a song by clicking it and then press play button to start playing. There's also buttons for synced play and making a ready check.
-Click and drag from the bottom right corner of the window to resize it.
-Click and drag the title bar to move the window.
-Closing the window will save its position and size.
-Drag the separator lines to scale the sizes of directory, song, and part lists.
-If the song has multiple parts, you can click little arrows next to the part number (marked X:) to switch selected part. You can also enable the new song parts display and directly select parts from there.
-Custom commands can be cycled with the mouse wheel when the mouse is over the "S" (short for Share) button
-Answers to commonly asked questions can be found here: http://chiran.lotrointerface.com/portal.php?id=32&a=faq

Command line options

-/songbook show - shows the Songbook window
-/songbook hide - hides the Songbook window
-/songbook toggle - toggles the Songbook window
-/songbook - lists command line options

Known issues and comments

-Songs with special characters, such as accents, in their file names will not play with the plugin. This seems to be a problem with the plugin API.

Future plans

-Playlist/Favorites

Version history

0.92 (15/07/2013)
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


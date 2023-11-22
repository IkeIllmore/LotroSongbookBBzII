import "Turbine.UI";
import "Turbine.UI.Lotro";
import "Turbine.Gameplay" -- needed for access to party object
-- Some global variables to differentiate between the patch version and the alternate (BB) version

gPlugin = "SongbookBB"
gDir = "ChiranBB/SongbookBB/"
gSettings = "SongbookSettingsBB"
SongbookDataTag = "SongbookBB"

import "ChiranBB.SongbookBB.Class"; -- Turbine library included so that there's no outside dependencies
import "ChiranBB.SongbookBB.ToggleWindow";
import "ChiranBB.SongbookBB.SettingsWindow";
import "ChiranBB.SongbookBB.SongbookLang";
import "ChiranBB.SongbookBB.Instrumentsz"; -- ZEDMOD
import "ChiranBB.SongbookBB.InstrumentAssignments"; -- Nim
import "ChiranBB.SongbookBB.InstrAssignWindow"; -- Nim
import "ChiranBB.SongbookBB";

VERBOSITY = 10
function WRITE( s, v ) v = v or 0; if VERBOSITY > v then Turbine.Shell.WriteLine( s ); end; end
if not TRACE then
	if not TRACE then TRACE = function(s,v) end; end
	if not CTRACE then CTRACE = function(c,s,v) end; end
	if not INFO then INFO = function(v) end; end
	if not DEBUG_Prep then DEBUG_Prep = function( ) end; end
end

songbookWindow = ChiranBB.SongbookBB.SongbookWindow();
if ( Settings.WindowVisible == "yes" ) then
	songbookWindow:SetVisible( true );
else
	songbookWindow:SetVisible( false );
end

settingsWindow = ChiranBB.SongbookBB.SettingsWindow();
settingsWindow:SetVisible( false );

-- Nim: Added auto assignment windows
skillsWindow = ChiranBB.SongbookBB.InstrSkillsWindow( Settings.Assign.wndSkills, g_cfgUI.wndSkills );
skillsWindow:SetVisible( Settings.Assign.wndSkills.visible == "yes" );

assignWindow = ChiranBB.SongbookBB.InstrAssignWindow( Settings.Assign.wndAssign, g_cfgUI.wndAssign );
assignWindow:SetVisible( Settings.Assign.wndAssign.visible == "yes" );

priosWindow = ChiranBB.SongbookBB.InstrPrioWindow( Settings.Assign.wndPrios, g_cfgUI.wndPrios );
priosWindow:SetVisible( Settings.Assign.wndPrios.visible == "yes" );

WindowsInitialized()
-- Nim end

toggleWindow = ChiranBB.SongbookBB.ToggleWindow();
if ( Settings.ToggleVisible == "yes" ) then
	toggleWindow:SetVisible( true );
else 
	toggleWindow:SetVisible( false );
end
songbookCommand = Turbine.ShellCommand();
function songbookCommand:Execute( cmd, args )
	if ( args == Strings["sh_show"] ) then
		songbookWindow:SetVisible( true );
	elseif ( args == Strings["sh_hide"] ) then
		songbookWindow:SetVisible( false );
	elseif ( args == Strings["sh_toggle"] ) then
		songbookWindow:SetVisible( not songbookWindow:IsVisible() );
	elseif ( args ~= nil ) then
		songbookCommand:GetHelp();
	end
end
function songbookCommand:GetHelp()
	Turbine.Shell.WriteLine( Strings["sh_help1"] );
	Turbine.Shell.WriteLine( Strings["sh_help2"] );
	Turbine.Shell.WriteLine( Strings["sh_help3"] );
end
Turbine.Shell.AddCommand( "songbookBB", songbookCommand );
Turbine.Shell.WriteLine( "SongbookBB v"..Plugins["SongbookBB"]:GetVersion().." (Chiran, The Brandy Badgers, Zedrock)" );
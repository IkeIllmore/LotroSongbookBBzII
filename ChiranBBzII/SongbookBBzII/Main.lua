import "Turbine.UI";
import "Turbine.UI.Lotro";
import "Turbine.Gameplay" -- needed for access to party object
-- Some global variables to differentiate between the patch version and the alternate (BB) version
gPlugin = "SongbookBBzII"
gDir = "ChiranBBzII/SongbookBBzII/"
gSettings = "SongbookSettingsBBz"
import "ChiranBBzII.SongbookBBzII.Class"; -- Turbine library included so that there's no outside dependencies
import "ChiranBBzII.SongbookBBzII.ToggleWindow";
import "ChiranBBzII.SongbookBBzII.SettingsWindow";
import "ChiranBBzII.SongbookBBzII.SongbookLang";
import "ChiranBBzII.SongbookBBzII.Instrumentsz"; -- ZEDMOD
import "ChiranBBzII.SongbookBBzII";

songbookWindow = ChiranBBzII.SongbookBBzII.SongbookWindow();
if ( Settings.WindowVisible == "yes" ) then
	songbookWindow:SetVisible( true );
else
	songbookWindow:SetVisible( false );
end
settingsWindow = ChiranBBzII.SongbookBBzII.SettingsWindow();
settingsWindow:SetVisible( false );
toggleWindow = ChiranBBzII.SongbookBBzII.ToggleWindow();
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
Turbine.Shell.AddCommand( "songbookbbzii", songbookCommand );
Turbine.Shell.WriteLine( "SongbookBBzII v"..Plugins["SongbookBBzII"]:GetVersion().." (0.92 Chiran + 0.01a The Brandy Badgers + 0.01b Zedrock)" );
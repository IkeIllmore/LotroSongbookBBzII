SongbookWindow = class( Turbine.UI.Window );

-- Fix to prevent Vindar patch from messing up anything since it's not needed
SongbookLoad = Turbine.PluginData.Load;
SongbookSave = Turbine.PluginData.Save;

-- Listbox
ListBoxScrolled = class( Turbine.UI.ListBox ); -- Listbox with child scrollbar and separator
ListBoxCharColumn = class( ListBoxScrolled ); -- Listbox with single char column

SuccessRGB = "<rgb=#00FF00>"
FailRGB = "<rgb=#FF0000>"

function SetDefault_AssignWnd( settings )
	if settings.Assign.wndAssign == nil then
		settings.Assign.wndAssign =
		{
			pos = { Left = "430", Top = "0", Width = "400", Height = "300" },
			visible = "no",
			targetChat = "g",
			listOrderBy = "n"
		}
	end
end
function SetDefault_AssignSkills( settings )
	if settings.Assign.wndSkills == nil then
		settings.Assign.wndSkills =
		{
			pos = { Left = "430", Top = "300", Width = "400", Height = "550" },
			visible = "no"
		}
	end
end
function SetDefault_AssignPrios( settings )
	if settings.Assign.wndPrios == nil then
		settings.Assign.wndPrios =
		{
			pos = { Left = "830", Top = "0", Width = "400", Height = "300" },
			visible = "no",
			playerFilter = "c"
		}
	end
end
function AmendSettings_BBz( settings )
	if not settings then return; end
	if not settings.Assign then settings.Assign = { }; end
	SetDefault_AssignWnd( settings )
	SetDefault_AssignSkills( settings )
	SetDefault_AssignPrios( settings )
end
function AmendSettings_BB( settings )
	if not settings then return; end
	AmendSettings_BBz( settings ) -- add assignment settings
	settings.InstrsHeight = "40"
	if not settings.DirHeight then settings.DirHeight = "95"; end
	if not settings.TracksHeight then settings.TracksHeight = "215"; end
	local th = tonumber( settings.TracksHeight )
	local dh = tonumber( settings.DirHeight )
	local wh = tonumber( settings.WindowPosition.Height )
	if th and dh and wh then settings.SongsHeight = tostring( wh - 240 - th - dh - 40 )
	else settings.SongsHeight = "150"; end
end

function Settings_Mod( wndPos, f )
	wndPos.Left = f( wndPos.Left )
	wndPos.Top = f( wndPos.Top )
	wndPos.Width = f( wndPos.Width )
	wndPos.Height = f( wndPos.Height )
end
function ModifySettings( settings, f ) 
	Settings_Mod( settings.Assign.wndAssign.pos, f )
	Settings_Mod( settings.Assign.wndSkills.pos, f )
	Settings_Mod( settings.Assign.wndPrios.pos, f )
end

-- Deferred creation of windows which need settings to be loaded  TODO: use constructor parameter instead
function WindowsInitialized( )
	assignWindow:Create( )
	skillsWindow:Create( )
	priosWindow:Create( )
	if wndPlaylist then wndPlaylist:Create( ); end
	songbookWindow:Initialized( )
end

-- Notify windows they are about to be destroyed, so they can save state to Settings 
function DestroyWindows( )
	assignWindow:Save()
	skillsWindow:Save()
end

-- Settings Default Values
-- ZEDMOD: Adding SongsHeight and InstrsHeight default values
Settings = { 
	Version = "0.98",
	WindowPosition = { 
		Left = "0", -- ZEDMOD: OriginalBB value: 700
		Top = "0", -- ZEDMOD: OriginalBB value: 20
		Width = "430", -- ZEDMOD: OriginalBB value: 342
		Height = "750" -- ZEDMOD: OriginalBB value: 398
		}, 
	WindowVisible = "yes", -- ZEDMOD: OriginalBB value: no
	WindowOpacity = "0.9", 
	DirHeight = "95", -- BB, was 40 ZEDMOD: OriginalBB value: 100
	SongsHeight = "155", -- BB, was 40 ZEDMOD
	TracksHeight = "215", -- BB, was 40 ZEDMOD: OriginalBB value: 50
	InstrsHeight = "40", -- ZEDMOD
	TracksVisible = "yes", -- ZEDMOD: OriginalBB value: no
	ToggleVisible = "yes", 
	ToggleLeft = tostring( Turbine.UI.Display.GetWidth() - 75 ), -- ZEDMOD: OriginalBB value -55
	ToggleTop = "0", 
	ToggleOpacity = "1", -- ZEDMOD: OriginalBB value 0.25
	SearchVisible = "yes", 
	DescriptionVisible = "no", 
	DescriptionFirst = "no",
	};

-- Lang
-- if ( ( lang == "de" ) or ( lang == "fr") ) then
	-- if ( ( Turbine.Engine.GetLocale() == "de" ) or ( Turbine.Engine.GetLocale() == "fr" ) ) then
		-- Settings.WindowOpacity = "0,9";
	-- end
-- end

euroFormat = ( tonumber( "1,000" ) == 1 );
if ( euroFormat ) then
	Settings.WindowOpacity = "0,9";
	--Settings.ToggleOpacity = "0,25"; -- ZEDMOD: OriginalBB
else
	Settings.WindowOpacity = "0.9";
	--Settings.ToggleOpacity = "0.25"; -- ZEDMOD: OriginalBB
end

-- Dir
selectedDir = "/"; -- set the default dir
dirPath = {}; -- table holding directory path
dirPath[1] = "/"; -- set first item as root dir

-- Library Size
librarySize = 0;

-- Song
selectedSong = ""; -- set the default song
selectedSongIndex = 1;

-- Track
selectedTrack = 1; -- set the default track

-- Char settings
CharSettings = {};

-- Song DB
SongDB = {
	Directories = {},
	Songs = {}
};

	
local function Update( self )
	if self.bCounterActive then self:UpdateCounter( ); end
	if self.bPeriodicActive then self:UpdatePeriodic( ); end
end

local function LoadEvHandlerSongDB( d )
	if not d or #d.Songs <= 0 then
		WRITE( FailRGB..Strings["SongsReloadFail"].."</rgb>" )
		songbookWindow:SongsLoadFail( )
		return; end
	SongDB = d
	WRITE( SuccessRGB..Strings["SongsReloadOk"].."</rgb>" )
	selectedDir = "/"
	songbookWindow:InitListsForSongDB( )
end


function SongbookWindow:ReloadSongDB( )
	SongbookLoad( Turbine.DataScope.Account, "SongbookData", LoadEvHandlerSongDB )
end


function SongbookWindow:LoadCharSettings( )
	local charSets = SongbookLoad( Turbine.DataScope.Character, gSettings )
	if not charSets or not charSets.Version then -- old version, see if there are newer ones
		local BBzT = SongbookLoad( Turbine.DataScope.Character, "SongbookSettingsBBzT" )
		if BBzT then WRITE("Loaded BBzT version of CharSettings." ); return BBzT; end
		local BBz = SongbookLoad( Turbine.DataScope.Character, "SongbookSettingsBBz" )
		if BBz then WRITE("Loaded BBz version of CharSettings." ); return BBz; end
	else return charSets; end
	if charSets then WRITE( "Loaded original BB version of CharSettings." )
	else WRITE( "No CharSettings file found, using defaults." ); end
	return charSets	
end

function SongbookWindow:LoadSettings( )
	ServerData:Load( SongbookDataTag )
	if not ServerData:IsValid( ) then ServerData:Load( "SongbookBBzT" ); end
	ServerData:Verify( )
	SkillsData:CopyFromSD( );
	PriosData:CopyFromSD( );
	
	local settings = SongbookLoad( Turbine.DataScope.Account, "SongbookSettingsBB" )
	if not settings or not settings.Version then
WRITE( "No current BB settings file found, trying BBzT version." )
		local BBzT = SongbookLoad( Turbine.DataScope.Account, "SongbookSettingsBBzT" ) -- Try test version settings first
		if BBzT then
WRITE( "BBzT version found, attempting to convert skills/preferences." )
			SkillsData:CheckVersion( BBzT ); PriosData:CheckVersion( BBzT ) -- convert old data if present
			settings = BBzT -- BBzT version supersedes old BB version
		else
WRITE( "No BBzT settings file found, trying BBz." )
			local BBz = SongbookLoad( Turbine.DataScope.Account, "SongbookSettingsBBz" ) -- BBz closer than BB, still needs to be amended
			if BBz then settings = BBz; AmendSettings_BBz( settings )
WRITE( "BBz version found, amending settings." )
			elseif settings then
				WRITE( "BBz version not found, amending old BB version.\n" ); AmendSettings_BB( settings )
			end
		end
	end
	if not settings then
		settings = SongbookLoad( Turbine.DataScope.Account, "SongbookSettings" )
		if settings then WRITE( "Original Songbook settings found, amending.\n" );
		else settings = Settings; WRITE( "No settings file found, using defaults.\n" ); end
		AmendSettings_BB( settings )
	end
	SkillsData:Init( )
	PriosData:Init( )
	return settings
end

--------------------------
-- Songbook Main Window --
--------------------------
-- Songbook Window : Constructor
function SongbookWindow:Constructor()
	Turbine.UI.Lotro.Window.Constructor( self );
	
	Instruments:Setup( )
	-- Song Database : Load
	SongDB = SongbookLoad( Turbine.DataScope.Account, "SongbookData" ) or SongDB;
	
	-- Settings : Load
	Settings = self:LoadSettings( )
	if not Settings.Assign then AmendSettings_BB( Settings ); end
	Settings.Version = "1.0"
	
--	Settings = SongbookLoad( Turbine.DataScope.Account, gSettings ) or Settings;
--	AmendSettings_BBz( Settings ) -- Nim: Add the default settings for the auto assignment feature
	
	-- ZEDMOD: Fix Local and Langue when FR/DE Lotro client switched in EN Language; Nim: Split up combined function
	Settings.ToggleOpacity = FixLocLangFormat( euroFormat, Settings.ToggleOpacity );
	Settings.WindowOpacity = FixLocLangFormat( euroFormat, Settings.WindowOpacity );
	
	-- Character Settings : Load
	CharSettings = self:LoadCharSettings( ) or CharSettings
	CharSettings.Version = "1.0"
	
	-- Badger Variables for Filters, Players list, Setups
	self.player = nil
	self.party = nil
	self.sFilterPartcount = nil; -- A char for every acceptable part count, with 'A' being solo, 'B' two parts, etc.
	self.maxTrackCount = 25; -- Assumed maximum number of track setups (adjust if necessary)
	self.bFilter = false; -- show/hide filter UI -- ZEDMOD: Now,separate to Players list
	self.bChiefMode = true; -- enables sync start shortcut, uses party object ( seems to work for FS leader )
	self.bShowAllBtns = false; -- show/hide R, S, and track selector
	self.bShowPlayers = true; -- show/hide players listbox (used to auto-hide, but disabled for now)
	self.aFilteredIndices = {}; -- Array for filtered indices, k = display index; v = SongDB index
	self.aPlayers = {}; -- k = player name, v = ready track, 0 if no track ready
	self.nPlayers = 0; -- number of players (unfortunately not as simple as #self.aPlayers)
	self.sPlayerName = nil; -- name of player
	self.sLeaderName = nil; -- name of FS/Raid leader
	self.aCurrentSongReady = {}; -- k = player name; v = track ready state (see GetTrackReadyState())
	self.aReadyTracks = ""; -- indicates which tracks are ready (A = 1st, B = 2nd, etc). Used for setup checks
	self.aSetupTracksIndices = {}; -- when tracks are filtered for a setup, this array contains track indices
	self.aSetupListIndices = {}; -- list index for tracks that are part of the currently selected setup
	self.iCurrentSetup = nil; -- indicates which setup is currently selected
	self.selectedSetupCount = 'A'; -- Stores the code of the current setup to select it on song change, if available
	self.maxPartCount = nil; -- the number of parts to use as filter (nil if not filtering, else player count)
	self.alignTracksRight = false; -- if true, track names are listed right-aligned (resize will reset to left aligned)
	self.listboxSetupsWidth = 20; -- width of the setups listbox (to the left of the tracks list)
	self.setupsWidth = self.listboxSetupsWidth + 10; -- total width of setup list including scrollbar
	self.bShowSetups = false; -- show/hide setups (autohide for songs with no setups defined)
	self.bCheckInstrument = true;
	self.bInstrumentOk = true;
	self.bDisplayTimer = false;
	self.bTimerCountdown = false;
	self.bShowReadyChars = true;
	self.bHighlightReadyCol = false;
	self.chNone = " ";
	self.chReady = "~";
	self.chWrongSong = "S";
	self.chWrongPart = "P";
	self.chMultiple = "M";
	
	self.colorListFrame = Turbine.UI.Color( 1, 0.15, 0.15, 0.15 )
	-- Badger Colours for the different Track/Player Ready States in the Track and Player Listboxes
	self.colourDefaultHighlighted = Turbine.UI.Color( 1, 0.15, 0.95, 0.15 ); -- Green Light
	self.colourReadyHighlighted = Turbine.UI.Color( 1, 0.15, 0.60, 0.15 ); -- Green Dark
	self.colourReadyMultipleHighlighted = Turbine.UI.Color( 1, 0.7, 0.7, 1 ); -- Purple Light
	self.colourDefault = Turbine.UI.Color( 1, 1, 1, 1 ); -- White
	self.colourReady = Turbine.UI.Color( 1, 0.4, 0.4, 0 ); -- Green Yellow
	self.colourReadyMultiple = Turbine.UI.Color( 1, 0.6, 0.6, 0.95 ); -- Purple
	self.colourDifferentSong = Turbine.UI.Color( 1, 0, 0 ); -- Red
	self.colourDifferentSetup = Turbine.UI.Color( 1, 0.6, 0 ); -- Orange
	self.colourWrongInstrument = Turbine.UI.Color( 1, 0.6, 0 ); -- Orange
	self.backColourDefault = Turbine.UI.Color( 1, 0, 0, 0 ); -- Black
	self.backColourHighlight = Turbine.UI.Color( 1, 0.1, 0.1, 0.1 ); -- Grey
	self.colourActive = Turbine.UI.Color( 1, 0.92, 0.80, 0.55 ) --0.91, 0.67, 0.24 );
	self.colorBlack = Turbine.UI.Color( 1, 0, 0, 0 ); -- Black
	
	self.ButtonRow = { xPos = 30, wiReload = 28, wiSettings = 70, wiInform = 80, wiAssign = 75, height = 20, spacing = 5, btmIndent = 11 }

	self.bParty = false; -- ZEDMOD: show/hide party UI
	
	-- ZEDMOD: New Instrument Slots Settings
	self.bInstrumentsVisible = false; -- Instrument Slots Visible Horizontal
	self.bInstrumentsVisibleHForced = false; -- Instrument Slots Visible Horizontal
	
	--************
	--* Settings *
	--************
	-- Legacy fixes
	self:FixIfNotSettings( Settings, SongDB, CharSettings );
	
	-- Unstringify Settings values
	Settings.WindowPosition.Left = tonumber( Settings.WindowPosition.Left );
	Settings.WindowPosition.Top = tonumber( Settings.WindowPosition.Top );
	Settings.WindowPosition.Width = tonumber( Settings.WindowPosition.Width );
	Settings.WindowPosition.Height = tonumber( Settings.WindowPosition.Height );
	Settings.ToggleTop = tonumber( Settings.ToggleTop );
	Settings.ToggleLeft = tonumber( Settings.ToggleLeft );
	Settings.DirHeight = tonumber( Settings.DirHeight );
	Settings.SongsHeight = tonumber( Settings.SongsHeight ); -- ZEDMOD
	Settings.TracksHeight = tonumber( Settings.TracksHeight );
	Settings.InstrsHeight = tonumber( Settings.InstrsHeight ); -- ZEDMOD
	Settings.WindowOpacity = tonumber( Settings.WindowOpacity );
	Settings.ToggleOpacity = tonumber( Settings.ToggleOpacity );
	CharSettings.InstrSlots["number"] = tonumber( CharSettings.InstrSlots["number"] );
	ModifySettings( Settings, tonumber )
	--CheckSettings_Assignment( Settings )

	-- Fix to prevent window or toggle to travel outside of the screen
	self:ValidateWindowPosition( Settings.WindowPosition );
	--self:FixWindowSettings( Settings.WindowPosition ); -- ZEDMOD: OriginalBB disabled
	self:FixToggleSettings( Settings.ToggleTop, Settings.ToggleLeft ); -- ZEDMOD: Moved original code in function
	
	--CreateWindows()
	
	--*******************************
	--* Hide UI when F12 is pressed *
	--*******************************
	local hideUI = false;
	local wasVisible;
	self:SetWantsKeyEvents( true );
	self.KeyDown = function( sender, args )
		if ( args.Action == 268435635 ) then
			if ( not hideUI ) then
				hideUI = true;
				if ( self:IsVisible() ) then
					wasVisible = true;
					self:SetVisible( false );
				else
					wasVisible = false;
				end
				settingsWindow:SetVisible( false );
				assignWindow:SetVisible( false );
				skillsWindow:SetVisible( false );
				toggleWindow:SetVisible( false );
			else
				hideUI = false;
				if ( wasVisible ) then
					self:SetVisible( true );
					settingsWindow:SetVisible( false );
					assignWindow:SetVisible( false );
					skillsWindow:SetVisible( false );
				end
				if ( Settings.ToggleVisible == "yes" ) then
					toggleWindow:SetVisible( true );
				end
			end
		end
	end
	
	--************************
	--* Songbook Main Window *
	--************************
	-- Songbook Window Set Position
	self:SetPosition( Settings.WindowPosition.Left, Settings.WindowPosition.Top );
	
	-- Songbook Window Set Size
	self:SetSize( Settings.WindowPosition.Width, Settings.WindowPosition.Height );
	
	-- Songbook Window Set Z Order
	--self:SetZOrder( 10 );
	
	-- Songbook Window Set Opacity
	self:SetOpacity( Settings.WindowOpacity );
	
	-- Songbook Window Set Text
	self:SetText( "Songbook " .. Plugins[gPlugin]:GetVersion() .. Strings["title"] );
	
	-- Songbook Window Min and Max values
	local displayWidth, displayHeight = Turbine.UI.Display.GetSize();
	self.minWidth = 323; -- ZEDMOD: OriginalBB value: 342
	self.minHeight = 294; -- ZEDMOD: OriginalBB value: 308
	self.maxWidth = displayWidth;
	self.maxHeight = displayHeight;
	
	-- Songbook Window X Coords for ListFrame and ListContainer
	self.lFXmod = 20; -- listFrame x coord modifier -- ZEDMOD: OriginalBB value: 23
	self.lCXmod = 24; -- listContainer x coord modifier ( old value: 42) -- ZEDMOD: OriginalBB value: 28
	
	--[[ ZEDMOD: OriginalBB disabled
	-- Instruments Slots Container
	--if (CharSettings.InstrSlots["visible"] == "yes") then
		--self.lFYmod = 214; -- listFrame y coord modifier = difference between bottom pixels and window bottom
		--self.lCYmod = 233; -- listContainer y coord modifier = difference between bottom pixels and window bottom
	--else
		--self.lFYmod = 169; -- listFrame y coord modifier = difference between bottom pixels and window bottom
		--self.lCYmod = 188; -- listContainer y coord modifier = difference between bottom pixels and window bottom
	--end
	]]--
	
	-- ZEDMOD: Add Songbook Window Y Coords for ListFrame and ListContainer
	self.lFYmod = 169; -- listFrame y coord modifier = difference between bottom pixels and window bottom
	self.lCYmod = 188; -- listContainer y coord modifier = difference between bottom pixels and window bottom
	
	--**************
	--* List Frame *
	--**************
	-- List Frame
	self.listFrame = Turbine.UI.Control();
	self.listFrame:SetParent( self );
	self.listFrame:SetBackColor( self.colorListFrame );
	self.yListFrame = 134 -- also used for msg
	self.listFrame:SetPosition( 10, self.yListFrame ); -- ZEDMOD: OriginalBB value: ( 12, 134 )
	--self.listFrame:SetSize( self:GetWidth() - self.lFXmod, self:GetHeight() - self.lFYmod );
	
	-- Liste Frame Header
	self.listFrame.heading = Turbine.UI.Label();
	self.listFrame.heading:SetParent( self.listFrame );
	self.listFrame.heading:SetLeft( 5 );
	self.listFrame.heading:SetSize( self.listFrame:GetWidth(), 13 );
	self.listFrame.heading:SetFont( Turbine.UI.Lotro.Font.TrajanPro13 );
	--self.listFrame.heading:SetText( Strings["ui_dirs"] ); -- ZEDMOD: OriginalBB
	self.listFrame.heading:SetText( "" );
	
	-- ZEDMOD: Create Message Txt box for timer and instruments
	self:CreateInstrLabel( ) -- (Nim) Added instrument indicator
	self:CreateAlertLabel(); -- Adding message for timer and instruments to header
	self:CreateTimerLabel() -- (Nim) split off separate label for the timer
	
	--******************
	--* List Container *
	--******************
	-- List Container
	self.listContainer = Turbine.UI.Control();
	self.listContainer:SetParent( self );
	self.listContainer:SetBackColor( Turbine.UI.Color( 1, 0, 0, 0 ) );
	self.listContainer:SetPosition( 12, 147 ); -- ZEDMOD: OriginalBB value ( 18, 147 )
	--self.listContainer:SetSize( self:GetWidth() - self.lCXmod, self:GetHeight() - self.lCYmod );
	
	--*******************
	--* List Separators *
	--*******************
	-- ZEDMOD: Dir Header Separator
	self.sepDirs = self:CreateMainSeparator( 13 );
	self.sepDirs:SetVisible( true );
	self.sepDirs.heading = self:CreateSeparatorHeading( self.sepDirs, Strings["ui_dirs"] ); -- ZEDMOD
	
	-- Separator1 : sepDirsSongs : between Dir List and Song List (0, DirHeight)
	-- ZEDMOD: OriginalBB Separator1 renamed as sepDirsSongs
	--self.separator1 = self:CreateMainSeparator( Settings.DirHeight ); -- ZEDMOD: OriginalBB
	self.sepDirsSongs = self:CreateMainSeparator( Settings.DirHeight ); -- ZEDMOD
	--self.separator1:SetVisible(true); -- ZEDMOD: OriginalBB
	self.sepDirsSongs:SetVisible( true ); -- ZEDMOD
	--self.separator1.heading = self:CreateSeparatorHeading( self.separator1, Strings["ui_songs"] ); -- ZEDMOD: OriginalBB
	self.sepDirsSongs.heading = self:CreateSeparatorHeading( self.sepDirsSongs, Strings["ui_songs"] ); -- ZEDMOD
	self.sArrows1 = self:CreateSeparatorArrows( self.sepDirsSongs );
	
	-- Separator2 : sepSongsTracks : between Song List and Track List
	--self.sepSongsTracks = self:CreateMainSeparator( self.listContainer:GetHeight() - Settings.TracksHeight - 13 ); -- ZEDMOD: OriginalBB
	self.sepSongsTracks = self:CreateMainSeparator( Settings.DirHeight + 13 + Settings.SongsHeight ); -- ZEDMOD
	self.sepSongsTracks:SetVisible( false );
	self.sepSongsTracks.heading = self:CreateSeparatorHeading( self.sepSongsTracks, Strings["ui_parts"] );
	self.sArrows2 = self:CreateSeparatorArrows( self.sepSongsTracks );
	
	-- ZEDMOD: Add separator between Tracks and Instruments
	-- Separator3 : sepTracksInstrs : between Track List and Instrument List (SongsHeight + 13, TracksHeight)
	self:CreateTrackInstrSep( )
	
	--***********
	--* Tooltip *
	--***********
	self.tipLabel = Turbine.UI.Label();
	self.tipLabel:SetParent( self );
	self.tipLabel:SetPosition( self:GetWidth() - 270, 27 );
	self.tipLabel:SetSize( 245, 30 );
	self.tipLabel:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleRight );
	self.tipLabel:SetText( "" );
	
	--***********
	--* Buttons *
	--***********
	-- Nim: Moved the sync start button to the right and changed to signal
	-- colour, so users don't mix it up with sync

	-- x positions of buttons
	local posBtnMusic = 20
	local posBtnPlay = 60
	local posBtnReady = 100 -- orig 120, Zed 110
	local posBtnSync = 140 -- orig 161, Zed 151
	local posBtnTrack = 190 -- orig 247, Zed 237
	local posBtnShare = 230 -- orig 287, Zed 270
	local posBtnSyncStart = 280 -- orig 202, Zed 192
	
	-- Music mode button
	self.musicSlot = self:CreateMainShortcut(posBtnMusic); -- Nim: orig 20
	-- Trying to fix the problem with unresponsive buttons. Haven't found out yet how to disable
	-- dragging from a quickslot altogether, so for now this just restores the shortcut.
	self.musicSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_music"]);
	self.musicSlot.DragDrop =
	function( sender, args )
		if( self.musicSlotShortcut ) then
			self.musicSlot:SetShortcut( self.musicSlotShortcut ); -- restore shortcut
		end
	end
	self.musicSlot:SetShortcut( self.musicSlotShortcut );
	self.musicSlot:SetVisible( true );
	
	-- Play button
	-- NOTE: since the cmd depends on the track name, the shortcut is created below in SelectTrack()
	self.playSlot = self:CreateMainShortcut(posBtnPlay); -- Nim: orig 60
	self.playSlot.DragDrop =
	function( sender, args )
		if( self.playSlotShortcut ) then
			self.playSlot:SetShortcut( self.playSlotShortcut ); -- restore shortcut
		end
	end
	
	-- Ready check button
	self.readySlot = self:CreateMainShortcut(posBtnReady); -- Nim: orig 120
	self.readySlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_ready"]));
	self.readySlot:SetVisible( self.bShowAllBtns );
	
	-- Sync button, NOTE: as for play, shortcut is created below in SelectTrack()
	self.syncSlot = self:CreateMainShortcut(posBtnSync); -- Nim: orig 161
	self.syncSlot.DragDrop =
	function( sender, args )
		if( self.syncSlotShortcut ) then
			self.syncSlot:SetShortcut( self.syncSlotShortcut ); -- restore shortcut
		end
	end
	
	-- Share button
	self.shareSlot = self:CreateMainShortcut(posBtnShare); -- Nim: orig 287
	if (Settings.Commands[Settings.DefaultCommand]) then
		self.shareSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, self:ExpandCmd(Settings.DefaultCommand)));
	end

	-- Sync start button
	-- Nim: Moved all the way to the right so it is less often accidentally clicked instead of sync
	self.syncStartSlot = self:CreateMainShortcut(posBtnSyncStart); -- Nim: orig 202
	self.syncStartSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_start"] );
	self.syncStartSlot.DragDrop =
	function( sender, args )
		if( self.syncStartSlotShortcut ) then
			self.syncStartSlot:SetShortcut( self.syncStartSlotShortcut ); -- restore shortcut
		end
	end
	self.syncStartSlot:SetShortcut(self.syncStartSlotShortcut);
	
	
		-- Track label
	self.trackLabel = Turbine.UI.Label();
	self.trackLabel:SetParent( self );
	self.trackLabel:SetPosition(posBtnTrack, 63); -- Nim: orig 247
	self.trackLabel:SetSize(30, 12);
	self.trackLabel:SetZOrder(200);
	self.trackLabel:SetText("X:");

	-- Track number
	self.trackNumber = Turbine.UI.Label();
	self.trackNumber:SetParent( self );
	self.trackNumber:SetPosition(posBtnTrack+15, 63);
	self.trackNumber:SetWidth(20);
	
	-- Track up arrow
	self.trackPrev = Turbine.UI.Control();
	self.trackPrev:SetParent( self );
	self.trackPrev:SetPosition(posBtnTrack+5, 51);
	self.trackPrev:SetSize(12, 8);
	self.trackPrev:SetBackground(gDir .. "arrowup.tga");
	self.trackPrev:SetBackground(gDir .. "arrowup.tga");
	self.trackPrev:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.trackPrev:SetVisible( false );
	
	-- Track down arrow
	self.trackNext = Turbine.UI.Control();
	self.trackNext:SetParent( self );
	self.trackNext:SetPosition(posBtnTrack+5, 78);
	self.trackNext:SetSize(12, 8);
	self.trackNext:SetBackground(gDir .. "arrowdown.tga");
	self.trackNext:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.trackNext:SetVisible( false );
	
	self.trackLabel:SetVisible( self.bShowAllBtns )
	self.trackNumber:SetVisible( self.bShowAllBtns )

	-- Track actions for track change
	self.trackPrev.MouseClick = function( sender, args )
		if ( args.Button == Turbine.UI.MouseButton.Left ) then
			self:SelectTrack( selectedTrack - 1 );
		end
	end
	
	-- Track actions for track change
	self.trackNext.MouseClick = function( sender, args )
		if ( args.Button == Turbine.UI.MouseButton.Left ) then
			self:SelectTrack( selectedTrack + 1 );
		end
	end
	
	--****************
	--* Mouse Events *
	--****************
	
	-- Music Slot : Mouse Enter
	self.musicSlot.MouseEnter = function( sender, args )
		self.musicIcon:SetBackground( gDir .. "icn_m_hover.tga" );
		self.tipLabel:SetText( Strings["tt_music"] );
	end
	
	-- Music Slot : Mouse Leave
	self.musicSlot.MouseLeave = function( sender, args )
		self.musicIcon:SetBackground( gDir .. "icn_m.tga" );
		self.tipLabel:SetText( "" );
	end
	
	-- Play Slot : Mouse Enter
	self.playSlot.MouseEnter = function( sender, args )
		self.playIcon:SetBackground( gDir .. "icn_p_hover.tga" );
		self.tipLabel:SetText( Strings["tt_play"] );
	end
	
	-- Play Slot : Mouse Leave
	self.playSlot.MouseLeave = function( sender, args )
		self.playIcon:SetBackground( gDir .. "icn_p.tga" );
		self.tipLabel:SetText( "" );
	end
	
	-- Ready Slot : Mouse Enter
	self.readySlot.MouseEnter = function( sender, args )
		self.readyIcon:SetBackground( gDir .. "icn_r_hover.tga" );
		self.tipLabel:SetText( Strings["tt_ready"] );
	end
	
	-- Ready Slot : Mouse Leave
	self.readySlot.MouseLeave = function( sender, args )
		self.readyIcon:SetBackground( gDir .. "icn_r.tga" );
		self.tipLabel:SetText( "" );
	end
	
	-- Sync Slot : Mouse Enter
	self.syncSlot.MouseEnter = function( sender, args )
		self.syncIcon:SetBackground( gDir .. "icn_s_new_hover.tga" );
		self.tipLabel:SetText( Strings["tt_sync"] );
	end
	
	-- Sync Slot : Mouse Leave
	self.syncSlot.MouseLeave = function( sender, args )
		self.syncIcon:SetBackground( gDir .. "icn_s_new.tga" );
		self.tipLabel:SetText( "" );
	end
	
	-- Sync Start Slot : Mouse Enter
	self.syncStartSlot.MouseEnter = function( sender, args )
		self.syncStartIcon:SetBackground( gDir .. "icn_ss_hover.tga" );
		self.tipLabel:SetText( Strings["tt_start"] );
	end
	
	-- Sync Start Slot : Mouse Leave
	self.syncStartSlot.MouseLeave = function( sender, args )
		self.syncStartIcon:SetBackground( gDir .. "icn_ss.tga" );
		self.tipLabel:SetText( "" );
	end
	
	-- Share Slot : Mouse Enter
	self.shareSlot.MouseEnter = function( sender, args )
		self.shareIcon:SetBackground( gDir .. "icn_sh_hover.tga" );
		if ( Settings.Commands[Settings.DefaultCommand].Title ) then
			self.tipLabel:SetText( Settings.Commands[Settings.DefaultCommand].Title );
		end
	end
	
	-- Share Slot : Mouse Leave
	self.shareSlot.MouseLeave = function( sender, args )
		self.shareIcon:SetBackground( gDir .. "icn_sh.tga" );
		self.tipLabel:SetText( "" );
	end
	
	-- Share Slot : Mouse Wheel
	self.shareSlot.MouseWheel = function( sender, args )
		local nextCmd = tonumber( Settings.DefaultCommand ) - args.Direction;
		local size = SettingsWindow:CountCmds();
		
		if ( nextCmd == 0 ) then
			Settings.DefaultCommand = tostring( size );
		elseif ( nextCmd > size ) then
			Settings.DefaultCommand = "1";
		else
			Settings.DefaultCommand = tostring( nextCmd );
		end
		self.shareSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, self:ExpandCmd( Settings.DefaultCommand ) ) );
		self.shareSlot:SetVisible( self.bShowAllBtns );
	end
	
	-- Track Label : Mouse Click
	self.trackLabel.MouseClick = function( sender, args )
		if ( args.Button == Turbine.UI.MouseButton.Left ) then
			self:ToggleTracks();
		end
	end
	
	--********************
	-- Icons for Buttons *
	--********************
	-- icons that hide default quick slots
	self.musicIcon = self:CreateMainIcon( posBtnMusic, "icn_m" );
	self.playIcon = self:CreateMainIcon( posBtnPlay, "icn_p" );
	self.readyIcon = self:CreateMainIcon( posBtnReady, "icn_r" ); -- ZEDMOD: 110, OriginalBB value: 120
	self.syncIcon = self:CreateMainIcon( posBtnSync, "icn_s_new" ); -- ZEDMOD: 151, OriginalBB value: 161
	self.shareIcon = self:CreateMainIcon( posBtnShare, "icn_sh" ); -- ZEDMOD: 270, OriginalBB value: 287
	self.syncStartIcon = self:CreateMainIcon( posBtnSyncStart, "icn_ss" ); -- ZEDMOD: 192, OriginalBB value: 202
	self.readyIcon:SetVisible( self.bShowAllBtns );
	self.shareIcon:SetVisible( self.bShowAllBtns );
	
	
	--**************
	--* Song Title *
	--**************
	-- selected song display
	self.songTitle = Turbine.UI.Label();
	self.songTitle:SetParent( self );
	self.songTitle:SetFont( Turbine.UI.Lotro.Font.Verdana16 );
	self.songTitle:SetForeColor( self.colourDefaultHighlighted );
	self.songTitle:SetPosition( 23, 90 );
	self.songTitle:SetSize( self:GetWidth() - 35, 16 ); -- ZEDMOD: OriginalBB values ( -52, 16 )

	self:CreateButtonRow( )
	
	--***************************************
	--* Songbook Main Window Resize Control *
	--***************************************
	self.resizeCtrl = Turbine.UI.Control();
	self.resizeCtrl:SetParent( self );
	self.resizeCtrl:SetSize( 20, 20 );
	self.resizeCtrl:SetZOrder( 200 );
	self.resizeCtrl:SetPosition( self:GetWidth() - 20, self:GetHeight() - 20 );
	
	--******************************
	--* Main Window Closing Action *
	--******************************
	-- Action for closing window and saving position
	self.Closed = function( sender, args )
		self:SaveSettings();
		self:SetVisible( false );
	end
	
	--**************
	--* Search Box *
	--**************
	-- search field
	self.wiSearchInput = 135
	self.wiSearchButtons = 65
	self.searchInput = Turbine.UI.Lotro.TextBox();
	self.searchInput:SetParent( self );
	self.searchInput:SetPosition( 10, 110 ); -- ZEDMOD: OriginalBB value: ( 17, 110 )
	self.searchInput:SetSize( self.wiSearchInput, 20 ); -- ZEDMOD: OriginalBB value: ( 150, 20 ), nim: reduced further from 145 to make room for timer
	self.searchInput:SetFont( Turbine.UI.Lotro.Font.Verdana14 );
	self.searchInput:SetMultiline( false );
	self.searchInput:SetVisible( false );
	local searchFocus = false;
	self.searchInput.KeyDown = function( sender, args )
		if ( args.Action == 162 ) then
			if ( searchFocus ) then
				self:SearchSongs();
			end
		end
	end
	self.searchInput.FocusGained = function( sender, args )
		searchFocus = true;
	end
	self.searchInput.FocusLost = function( sender, args )
		searchFocus = false;
	end
	
	-- search button
	self.searchBtn = Turbine.UI.Lotro.Button();
	self.searchBtn:SetParent( self );
	self.searchBtn:SetPosition( self.wiSearchInput + 15, 110 ); -- ZEDMOD: OriginalBB value: ( 172, 110 )
	self.searchBtn:SetSize( self.wiSearchButtons, 20 ); -- Nim: reduced from 80 to make room for timer
	self.searchBtn:SetText( Strings["ui_search"] );
	self.searchBtn:SetVisible( false );
	self.searchBtn.MouseClick = function( sender, args )
		self:SearchSongs();
	end
	
	-- clear search button
	self.clearBtn = Turbine.UI.Lotro.Button();
	self.clearBtn:SetParent( self );
	self.clearBtn:SetPosition( self.wiSearchInput + 15 + self.wiSearchButtons, 110 ); -- ZEDMOD: OriginalBB value: ( 255, 110 ), Nim: now 
	self.clearBtn:SetSize( self.wiSearchButtons, 20 );
	self.clearBtn:SetText( Strings["ui_clear"] );
	self.clearBtn:SetVisible( false );
	self.clearBtn.MouseClick = function( sender, args )
		self.searchInput:SetText( "" );
		self.songlistBox:ClearItems();
		self:LoadSongs();
		self.songlistBox:SetSelectedIndex( 1 ); -- ZEDMOD
		self:SelectSong( 1 );
	end
	
	-- hide search components if not toggled
	if ( Settings.SearchVisible == "yes" ) then
		self.searchInput:SetVisible( true );
		self.searchBtn:SetVisible( true );
		self.clearBtn:SetVisible( true );
	--end -- ZEDMOD: OriginalBB
	else -- ZEDMOD
		-- adjust to search visibility
		--if ( Settings.SearchVisible == "no" ) then -- ZEDMOD: OriginalBB
		self:ToggleSearch( "off" );
	end
	
	--*****************
	--* Chief Minimum *
	--*****************
	self:SetChiefMode( Settings.ChiefMode == "true" );
	self:ShowAllButtons( Settings.ShowAllBtns == "true" )
	
	--************
	--* Timer UI *
	--************
	self.Update = Update
	self.currentTime = -1
	self.bDisplayTimer = ( Settings.TimerState == "true" );
	self.bTimerCountdown = ( Settings.TimerCountdown == "true" );
	self.bCounterActive = false
	
	self.aPeriodic	= {}
	self.bPeriodicActive = false
	--******************
	--* Directory List *
	--******************
	self.dirlistBox = ListBoxScrolled:New( 10, 10, false );
	self.dirlistBox:SetParent( self.listContainer );
	self.dirlistBox:SetVisible( true );
	
	--**************
	--* Filters UI *
	--**************
	self:CreateFilterUI(); -- Creates the UI elements for the filters
	
	-- Show Filters UI
	self:ShowFilterUI( Settings.FiltersState == "true" );
	
	--*************
	--* Song List *
	--*************
	self.songlistBox = ListBoxScrolled:New( 10, 10, false );
	self.songlistBox:SetParent( self.listContainer );
	self.songlistBox:SetVisible( true );

	
	--*******************
	--* Players list UI *
	--*******************
	self:CreatePartyUI(); -- Creates the UI elements for the players list
	
	self.bShowReadyChars = ( Settings.ReadyColState == "true" );
	self.bHighlightReadyCol = ( Settings.ReadyColHighlight == "true" );
	
	-- Show Player list UI
	self:ShowPartyUI( Settings.PartyState == "true" );
	
	-- Players List
	self.listboxPlayers:EnableCharColumn( self.bShowReadyChars ); -- Create the Players Column
	self:RefreshPlayerListbox(); -- lists the current party members; more will be added through chat messages
	
	--**************
	--* Track List *
	--**************
	self.tracklistBox = ListBoxCharColumn:New( 10, 10, false, 20 );
	self.tracklistBox:SetParent( self.listContainer );
	
	self.tracklistBox:EnableCharColumn( self.bShowReadyChars );
	self:HightlightReadyColumns( self.bHighlightReadyCol );
	
	-- Adjust Tracklist Left Position
	--self:AdjustTracklistLeft( ); -- ZEDMOD: OriginalBB
	
	-- Show Tracklist if Toggled On/Off
	self:ShowTrackListbox( Settings.TracksVisible == "yes" )
	
	--*************
	--* Setups UI *
	--*************
	self:CreateSetupsUI();
	
	-- ZEDMOD: New Instrument Slot List
	--*******************
	--* Instrument List *
	--*******************
	self.instrlistBox = ListBoxScrolled:New( 10, 10, true );
	self.instrlistBox:SetParent( self.listContainer );
	self.instrlistBox:SetVisible( false );
	
	--********************
	--* Instrument Slots *
	--********************
	self.instrSlot = {};
	local instrdrag = false;
	
	-- Set Instruments Slots
	for i = 1, CharSettings.InstrSlots["number"] do
		self.instrSlot[i] = Turbine.UI.Lotro.Quickslot();
		--self.instrSlot[i]:SetParent( self.instrContainer ); -- ZEDMOD: OriginalBB
		self.instrSlot[i]:SetParent( self.instrlistBox ); -- ZEDMOD
		--self.instrSlot[i]:SetPosition( 40 * ( i - 1 ), 0 ); -- ZEDMOD: OriginalBB
		self.instrSlot[i]:SetSize( 35, 40 ); -- ZEDMOD: OrignalBB value: ( 37, 37 )
		self.instrSlot[i]:SetZOrder( 100 );
		self.instrSlot[i]:SetAllowDrop( true );
		self.instrlistBox:AddItem( self.instrSlot[i] ); -- ZEDMOD
		if ( CharSettings.InstrSlots[tostring( i )].data ~= "" ) then
			pcall( function()
				local sc = Turbine.UI.Lotro.Shortcut( CharSettings.InstrSlots[tostring( i )].qsType, CharSettings.InstrSlots[tostring( i )].qsData );
				self.instrSlot[i]:SetShortcut( sc );
			end );
		end
		self.instrSlot[i].ShortcutChanged = function( sender, args )
			pcall( function() 
				local sc = sender:GetShortcut();
				CharSettings.InstrSlots[tostring( i )].qsType = tostring( sc:GetType() );
				CharSettings.InstrSlots[tostring( i )].qsData = sc:GetData();
			end );
		end
		self.instrSlot[i].DragLeave = function( sender, args )
			if ( instrdrag ) then
				CharSettings.InstrSlots[tostring( i )].qsType ="";
				CharSettings.InstrSlots[tostring( i )].qsData = "";
				local sc = Turbine.UI.Lotro.Shortcut( "", "" );
				self.instrSlot[i]:SetShortcut( sc );
				instrdrag = false;
			end
		end
		self.instrSlot[i].MouseDown = function( sender, args )
			if ( args.Button == Turbine.UI.MouseButton.Left ) then
				instrdrag = true;
			end
		end
	end
	
	--*************************************************
	--* Instrument Slots Visible Forced to Horizontal *
	--*************************************************
	-- Set Instrument Slots Visible Forced Horizontal
	if ( CharSettings.InstrSlots["visHForced"] == "true" ) then
		self.bInstrumentsVisibleHForced = true;
	end
	
	-- show instruments if toggled
	self:ShowInstrListbox( CharSettings.InstrSlots["visible"] == "yes" );
	
	--************
	--* Database *
	--************
	-- initialize list items from song database
	self:InitListsForSongDB( )
	-- Action for Dir List : Selecting a Dir
	self.dirlistBox.SelectedIndexChanged = function( sender, args )
		self:SelectDir( sender:GetSelectedIndex() );
	end
	-- Action for Song List : Selecting a Song
	self.songlistBox.SelectedIndexChanged = function( sender, args )
		self:SelectSong( sender:GetSelectedIndex() );
	end
	-- Action for Track List : Selecting a Track
	self.tracklistBox.SelectedIndexChanged = function( sender, args )
		self:SelectTrack( sender:GetSelectedIndex() );
	end
	-- Action for Track List : Realign Tracks Names
	self.tracklistBox.MouseClick = function( sender, args )
		if ( args.Button == Turbine.UI.MouseButton.Right ) then
			self:RealignTracknames();
		end
	end
	
	-- ZEDMOD: Hack to maintain tracks align to right when alignTracksRight is true
	local updateFlag = 0;
	self.tracklistBox.scrollBarv.MouseEnter = function( sender, args )
		if ( self.alignTracksRight == true ) then
			self.tracklistBox:SetWantsUpdates( true );
		else
			self.tracklistBox:SetWantsUpdates( false );
		end
	end
	self.tracklistBox.scrollBarv.MouseLeave = function( sender, args )
		if ( self.alignTracksRight == true ) then
			if ( updateFlag == 1 ) then
				self.tracklistBox:SetWantsUpdates( true );
			else
				self.tracklistBox:SetWantsUpdates( false );
			end
		else
			self.tracklistBox:SetWantsUpdates( false );
		end
	end
	self.tracklistBox.scrollBarv.MouseDown = function( sender, args )
		if ( self.alignTracksRight == true ) then
			updateFlag = 1;
		else
			updateFlag = 0;
		end
	end
	self.tracklistBox.scrollBarv.MouseHover = function( sender, args )
		if ( self.alignTracksRight == true ) then
			self.tracklistBox:SetWantsUpdates( false );
		else
			self.tracklistBox:SetWantsUpdates( false );
		end
	end
	self.tracklistBox.scrollBarv.MouseUp = function( sender, args )
		if ( self.alignTracksRight == true ) then
			self.tracklistBox:SetWantsUpdates( false );
		else
			self.tracklistBox:SetWantsUpdates( false );
		end
	end
	self.tracklistBox.Update = function( sender, args )
		if ( self.alignTracksRight == true ) then
			alignment = Turbine.UI.ContentAlignment.MiddleRight;
			left = self.tracklistBox:GetWidth() - 1010;
			for i = 1, self.tracklistBox:GetItemCount() do
				local item = self.tracklistBox:GetItem( i );
				item:SetLeft( left );
				item:SetTextAlignment( alignment );
			end
		end
		updateFlag = 0;
	end
	-- /ZEDMOD
	
	-- Action for Separator between Song List and Track List
	self.sepSongsTracks.MouseClick = self.tracklistBox.MouseClick;
	-- Action for Separator between Track List and Instrument List
	self.sepTracksInstrs.MouseClick = self.instrlistBox.MouseClick; -- ZEDMOD

	-- Main Window Resize Control : Mouse Down
	self.resizeCtrl.MouseDown = function( sender, args )
		sender.dragStartX = args.X;
		sender.dragStartY = args.Y;
		sender.dragging = true;
	end
	
	-- Main Window Resize Control : Mouse Up
	self.resizeCtrl.MouseUp = function( sender, args )
		sender.dragging = false;
		Settings.WindowPosition.Width = self:GetWidth(); -- Update Window Settings Width
		Settings.WindowPosition.Height = self:GetHeight(); -- Update Window Settings Height
	end
	
	-- ZEDMOD: Main Window Resize Control : Mouse Move
	self.resizeCtrl.MouseMove = function( sender, args )
		
		-- Get Main Window Width and Height
		local width, height = self:GetSize();
		
		-- Set Minimum Height Value
		local minheight = self:GetMinHeight();
		
		-- ZEDMOD: Get Main Window Height and Container Height
		local windowHeight = self:GetHeight();
		
		local containerHeight = self.listContainer:GetHeight();
		
		local unallowedHeight = windowHeight - containerHeight;
		
		if ( sender.dragging ) then
			width = width + args.X - sender.dragStartX;
			height = height + args.Y - sender.dragStartY;
			
			-- Set Main Window Minimum Width
			if ( width < self.minWidth ) then
				width = self.minWidth;
			elseif ( width > self.maxWidth - self:GetLeft() ) then
				width = self.maxWidth - self:GetLeft();
			end
			
			-- Set Main window Minimum Height
			if ( height < minheight ) then
				height = minheight;
			elseif ( height > self.maxHeight - self:GetTop() ) then
				height = self.maxHeight - self:GetTop();
			end
			
			-- Main Window Resize
			self:SetSize( width, height );
			
			-- Resize All Elements
			self:SetContainer();
			self:SetSBControls();
			
			-- Get New Container Height
			local newcontainerHeight = self.listContainer:GetHeight();
			
			-- If Mouse Up
			if ( newcontainerHeight < containerHeight ) then
				-- Resize Dirlist
				self:ResizeDirlist();
				
				-- Resize Songlist
				self:ResizeSonglist();
				
			-- If Mouse Down
			else
				
				-- Resize Songlist
				self:ResizeSonglist();
				
				-- Resize Dirlist
				self:ResizeDirlist();
			end
			
			if ( ( Settings.TracksVisible == "yes" ) and ( CharSettings.InstrSlots["visible"] == "no") ) then
				
				-- Get Track list Height
				local tracklistheight = self:TracklistGetHeight();
				
				-- Set Track list Height
				self.listboxPlayers:SetHeight( self.songlistBox:GetHeight() - 20 );
				self.tracklistBox:SetHeight( tracklistheight );
				self.listboxSetups:SetHeight( tracklistheight );
				
				-- Set Track list Position
				local tracklistpos = self.listContainer:GetHeight() - tracklistheight - 13;
				
				-- Adjust Track list Position
				self:AdjustTracklistPosition( tracklistpos );
				
			elseif ( ( Settings.TracksVisible == "yes" ) and ( CharSettings.InstrSlots["visible"] == "yes") ) then
			
				-- Get Track list Height
				local tracklistheight = self:TracklistGetHeight();
				
				-- Set Track list Height
				self.tracklistBox:SetHeight( tracklistheight );
				self.listboxPlayers:SetHeight( self.songlistBox:GetHeight() - 20 );
				self.listboxSetups:SetHeight( tracklistheight );
				
				-- Get Instrument list Height
				local instrlistheight = self:InstrlistGetHeight();
				
				-- Set Instrument list Height
				self.instrlistBox:SetHeight( instrlistheight );
				
				-- Set Track list Position
				local tracklistpos = self.listContainer:GetHeight() - tracklistheight - 13 - instrlistheight - 13;
				if ( self.bInstrumentsVisibleHForced == true ) then
					tracklistpos = tracklistpos - 10;
				end
				
				-- Adjust Track list Position
				self:AdjustTracklistPosition( tracklistpos );
				
				-- Set Instrument list Position
				local instrlistpos = self.listContainer:GetHeight() - instrlistheight - 13;
				if ( self.bInstrumentsVisibleHForced == true ) then
					instrlistpos = instrlistpos - 10;
				end
				
				-- Adjust Instrument list Position
				self:AdjustInstrlistPosition( instrlistpos );
				
				-- Adjust Instrument Slot
				self:AdjustInstrumentSlots();
				
			elseif ( ( Settings.TracksVisible == "no" ) and ( CharSettings.InstrSlots["visible"] == "yes") ) then
				
				-- Get Instrument ist Height
				local instrlistheight = self:InstrlistGetHeight();
				
				-- Set Instrument list Height
				self.instrlistBox:SetHeight( instrlistheight );
				
				-- Set Instrument list Position
				local instrlistpos = self.listContainer:GetHeight() - instrlistheight - 13;
				if ( self.bInstrumentsVisibleHForced == true ) then
					instrlistpos = instrlistpos - 10;
				end
				
				-- Adjust Instrument list Position
				self:AdjustInstrlistPosition( instrlistpos );
				
				-- Adjust Instrument Slot
				self:AdjustInstrumentSlots();
			end
		end
		sender:SetPosition( self:GetWidth() - sender:GetWidth(), self:GetHeight() - sender:GetHeight() );
	end
	
	--*****************************************************
	--* Dir list and Song list Separator Position Control *
	--*****************************************************
	-- Dir list and Song list ratio adjust
	--self.separator1.MouseDown = function( sender, args ) -- OriginalBB
	self.sepDirsSongs.MouseDown = function( sender, args ) -- ZEDMOD
		sender.dragStartX = args.X;
		sender.dragStartY = args.Y;
		sender.dragging = true;
	end
	
	-- Separator 1 : Mouse Up
	--self.separator1.MouseUp = function( sender, args ) -- OriginalBB
	self.sepDirsSongs.MouseUp = function( sender, args ) -- ZEDMOD
		sender.dragging = false;
		Settings.DirHeight = self.dirlistBox:GetHeight(); -- Update Settings.DirHeight
		Settings.SongsHeight = self.songlistBox:GetHeight(); -- ZEDMOD: Update Settings.SongsHeight
	end
	
	-- ZEDMOD: Separator 1 : Mouse Move
	self.sepDirsSongs.MouseMove = function( sender, args )
		if ( sender.dragging ) then
			local y = self.sepDirsSongs:GetTop();
			local h = self.songlistBox:GetHeight() - args.Y + sender.dragStartY;
			
			-- Mouse Down
			if ( h < 40 ) then
				h = 40 ;
			end
			
			-- Get Dir list Height
			local dirlistheight = self:DirlistGetHeight() + self.songlistBox:GetHeight() + 13 - h - 13;
			if ( dirlistheight < 40 ) then
				dirlistheight = 40;
			end
			
			-- Set Dir list Height
			self.dirlistBox:SetHeight( dirlistheight );
			
			--self:DirlistBoxSetScrollBarH();
			
			-- Adjust FilterUI
			self:AdjustFilterUI();
			
			-- Mouse Up
			
			-- Get Song list Height
			local songlistheight = self:SonglistGetHeight();
			
			-- Set Song list Height
			self.songlistBox:SetHeight( songlistheight );
			
			-- Adjust Song list Left
			--self:AdjustSonglistLeft();
			
			-- Set Players list Height
			self.listboxPlayers:SetHeight( songlistheight - 20 );
			
			-- Set Song list Position
			local songlistpos = self.dirlistBox:GetHeight() + 13;
			
			-- Adjust Song list Position
			self:AdjustSonglistPosition( songlistpos );
			
			-- Adjust PartyUI
			--self:AdjustPartyUI();
		end
	end
	
	--*******************************************************
	--* Song list and Track list Separator Position Control *
	--*******************************************************
	-- Song list and Track list Ratio Adjust
	-- Separator Songs-Tracks Mouse Down
	self.sepSongsTracks.MouseDown = function( sender, args )
		sender.dragStartX = args.X;
		sender.dragStartY = args.Y;
		sender.dragging = true;
	end
	
	-- Separator Songs-Tracks Mouse Up
	self.sepSongsTracks.MouseUp = function( sender, args )
		sender.dragging = false;
		Settings.TracksHeight = self.tracklistBox:GetHeight(); -- Update Settings Tracks Height
	end
	
	-- ZEDMOD: Separator Songs-Tracks Mouse Move
	self.sepSongsTracks.MouseMove = function( sender, args )
		if ( sender.dragging ) then
			local y = self.sepSongsTracks:GetTop();
			local h = self.tracklistBox:GetHeight() - args.Y + sender.dragStartY;
			
			-- Mouse Down
			if ( h < 40 ) then
				h = 40;
			end
			
			-- Get Song list Height
			local songlistheight = self:SonglistGetHeight() + self.tracklistBox:GetHeight() + 13 - h - 13;
			if ( songlistheight < 40 ) then
				songlistheight = 40;
			end
			
			-- Set Song list Height
			self.songlistBox:SetHeight( songlistheight );
			
			-- Adjust Song list Left
			--self:AdjustSonglistLeft();
			
			-- Set Players list Height
			self.listboxPlayers:SetHeight( songlistheight - 20 );
			
			-- Get Track list Height
			local tracklistheight = self:TracklistGetHeight();
			
			-- Set Track list Height
			self.tracklistBox:SetHeight( tracklistheight );
			self.listboxSetups:SetHeight( tracklistheight );
			
			-- Set Track list Position
			local tracklistpos = self.dirlistBox:GetHeight() + 13 + self.songlistBox:GetHeight() + 13;
			
			-- Adjust Track list Position
			self:AdjustTracklistPosition( tracklistpos );
		end
	end
	
	--*************************************************************
	--* Track list and Instrument list Separator Position Control *
	--*************************************************************
	-- ZEDMOD: NEW Separator between Tracks List and Instruments List
	-- Track list and Instrument list Ratio Adjust
	-- Separator Tracks-Instruments Mouse Down
	self.sepTracksInstrs.MouseDown = function( sender, args )
		sender.dragStartX = args.X;
		sender.dragStartY = args.Y;
		sender.dragging = true;
	end
	
	-- Separator Tracks-Instruments Mouse Up
	self.sepTracksInstrs.MouseUp = function( sender, args )
		sender.dragging = false;
		Settings.InstrsHeight = self.instrlistBox:GetHeight(); -- Update Settings Instruments Height
	end
	
	-- Separator Tracks-Instruments Mouse Move
	self.sepTracksInstrs.MouseMove = function( sender, args )
		if ( self.bInstrumentsVisibleHForced == false ) then
			if ( sender.dragging ) then
				local y = self.sepTracksInstrs:GetTop();
				local h = self.instrlistBox:GetHeight() - args.Y + sender.dragStartY;
				
				-- Mouse Down
				if ( h < 40 ) then
					h = 40;
				end
					
				if ( Settings.TracksVisible == "yes" ) then
					-- Get Track list Height
					local tracklistheight = self:TracklistGetHeight() + self.instrlistBox:GetHeight() + 13 - h - 13;
					if ( tracklistheight < 40 ) then
						tracklistheight = 40;
					end
					
					-- Set Track list Height
					self.tracklistBox:SetHeight( tracklistheight );
					self.listboxSetups:SetHeight( tracklistheight );
					
					-- Set Track list Position
					local tracklistpos = self.dirlistBox:GetHeight() + 13 + self.songlistBox:GetHeight() + 13;
					
					-- Adjust Track list Position
					self:AdjustTracklistPosition( tracklistpos );
					
					-- Get Instrument list Height
					local instrlistheight = self:InstrlistGetHeight();
					
					-- Set Instrument list Height
					self.instrlistBox:SetHeight( instrlistheight );
					
					-- Set Instrument list Position
					local instrlistpos = self.dirlistBox:GetHeight() + 13 + self.songlistBox:GetHeight() + 13 + self.tracklistBox:GetHeight() + 13;
					
					-- Adjust Instrument list Position
					self:AdjustInstrlistPosition( instrlistpos );
					
					-- Adjust Instrument Slot
					self:AdjustInstrumentSlots();
					
				else
					-- Get Song list Height
					local songlistheight = self:SonglistGetHeight() + self.instrlistBox:GetHeight() + 13 - h - 13;
					if ( songlistheight < 40 ) then
						songlistheight = 40;
					end
						
					-- Set Song list Height
					self.songlistBox:SetHeight( songlistheight );
					
					-- Adjust Song list Left
					self:AdjustSonglistLeft();
					
					-- Set Players list Height
					self.listboxPlayers:SetHeight( songlistheight - 20 );
					
					-- Get Instrument list Height
					local instrlistheight = self:InstrlistGetHeight();
					
					-- Set Instrument list Height
					self.instrlistBox:SetHeight( instrlistheight );
					
					-- Set Instrument list Position
					local instrlistpos = self.dirlistBox:GetHeight() + 13 + self.songlistBox:GetHeight() + 13;
					
					-- Adjust Instrument list Position
					self:AdjustInstrlistPosition( instrlistpos );
					
					-- Adjust Instrument Slot
					self:AdjustInstrumentSlots();
					
				end
			end
		end
	end
	
	-- ZEDMOD: Set List boxes height
	self.dirlistBox:SetHeight( Settings.DirHeight );
	self.songlistBox:SetHeight( Settings.SongsHeight );
	self.tracklistBox:SetHeight( Settings.TracksHeight );
	self.instrlistBox:SetHeight( Settings.InstrsHeight );
	
	-- Resize All
	self:ResizeAll(); -- Adjust variable sizes and positions to current main window size
	
	-- Callback
	AddCallback( Turbine.Chat, "Received", ChatHandler ); -- installs handler for chat messages (to catch ready messages)
	
	--*******************
	--* Songbook Unload *
	--*******************
	if ( Plugins["Songbook"] ~= nil ) then
		Plugins["Songbook"].Unload = function( sender, args )
			self:SaveSettings();
			RemoveCallback( Turbine.Chat, "Received", ChatHandler );
			self:SetWantsUpdates( false )
		end
	end
	
	-- ZEDMOD: Hack to refresh Playerslist box when 1rst launch
	self:RefreshPlayerListbox(); -- lists the current party members; more will be added through chat messages
	
end -- SongbookWindow:Constructor()

function SongbookWindow:InitListsForSongDB( )
	librarySize = #SongDB.Songs;
	if librarySize ~= 0 and not SongDB.Songs[1].Realnames then
		self.tracklistBox:ClearItems( )
		self.dirlistBox:ClearItems( )
		self.songlistBox:ClearItems( )
		for i = 1, #SongDB.Directories do
			local dirItem = Turbine.UI.Label();
			local _, dirLevel = string.gsub( SongDB.Directories[i], "/", "/" );
			if ( dirLevel == 2 ) then
				dirItem:SetText( string.sub( SongDB.Directories[i], 2 ) );
				dirItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
				dirItem:SetSize( 1000, 20 );
				self.dirlistBox:AddItem( dirItem );
			end
		end
		self.sepDirs.heading:SetText( Strings["ui_dirs"] .. " (" .. selectedDir .. ")" );
		if ( self.dirlistBox:ContainsItem( 1 ) ) then
			local dirItem = self.dirlistBox:GetItem( 1 );
			dirItem:SetForeColor( self.colourDefaultHighlighted );
		end
		-- Load Content to Song Listbox
		self:LoadSongs();
		-- Set first Item as initial Selection
		local found = self.songlistBox:GetItemCount();
		if ( found > 0 ) then
			self.songlistBox:SetSelectedIndex( 1 );
			self:SelectSong( 1 );
		else
			self:ClearSongState();
		end
		-- Set Text to Separator1
		self.sepDirsSongs.heading:SetText( Strings["ui_songs"] .. " (" .. found .. ")" );
		
		self:SetStateForSongDB( true )
		
		if self.emptyLabel then self.emptyLabel:SetParent( nil ); self.emptyLabel = nil; end
		return true
	end
		
	self:SongsLoadFail( )
	-- show message when library is empty or database format has changed
	return false
end		

function SongbookWindow:SongsLoadFail( )
	self:SetStateForSongDB( false )
	if self.emptyLabel then return; end
	self.emptyLabel = Turbine.UI.Label();
	self.emptyLabel:SetParent( self );
	self.emptyLabel:SetPosition( 30, 165 );  -- ZEDMOD: OriginalBB value ( 30, 155 )
	self.emptyLabel:SetSize( 220, 240 );
	self.emptyLabel:SetText( Strings["err_nosongs"] );
end

function SongbookWindow:SetStateForSongDB( b )
	self.sepDirsSongs:SetVisible( b );
	self.sepSongsTracks:SetVisible( b );
	self.sepTracksInstrs:SetVisible( b ); -- ZEDMOD
	self.sepDirs.heading:SetVisible( b )
	self.tracklistBox:SetVisible( b )
	self.dirlistBox:SetVisible( b )
	self.songlistBox:SetVisible( b )
	self:ShowFilterUI( b )
	self:ShowPartyUI( b )
	self:ShowInstrLabel( b )
	self:ShowInstrListbox( b );
	self.listFrame.heading:SetText( "" );
end		

function SongbookWindow:Initialized( )
--TRACE( "LUA version: "..tostring(_VERSION) )
	self:SetPlayerEvents( )
	local s = Instruments:SetInstrCBs( self.SetEquippedInstrument, self.SetEquippedInstrument )
	if self.lblInstr then self.lblInstr:SetText( "Equipped: "..s ); end
end

local function InstrSlotsMenu( sender, args )
	if args.Button ~= Turbine.UI.MouseButton.Right then return; end
	
	local contextMenu = Turbine.UI.ContextMenu()
	local menuItems = contextMenu:GetItems( )
	
	menuItems:Add( ListBox.CreateMenuItem( "List Shortcuts", nil,
		function( s, a ) if songbookWindow then songbookWindow:PrintInstrShortcuts( ); end; end ) )

	menuItems:Add( ListBox.CreateMenuItem( "Refresh Shortcuts", nil,
		function( s, a ) if songbookWindow then songbookWindow:RestoreInstrumentSlots( ); end; end ) )

	contextMenu:ShowMenu( )
end

local function InstrSlotsEnter( sender, args ) sender:SetBackColor( songbookWindow.colourActive ); end
local function InstrSlotsLeave( sender, args ) sender:SetBackColor( songbookWindow.colorListFrame ); end
	

function SongbookWindow:CreateTrackInstrSep( )
	self.sepTracksInstrs = self:CreateMainSeparator( Settings.DirHeight + 13 + Settings.SongsHeight + 13 + Settings.TracksHeight );
	self.sepTracksInstrs:SetVisible( false );
	self.sepTracksInstrs.heading = self:CreateSeparatorHeading( self.sepTracksInstrs, Strings["ui_instrs"] );
	self.sepTracksInstrs.heading:SetMouseVisible( true );
	self.sepTracksInstrs.heading.MouseClick = InstrSlotsMenu
	self.sArrows3 = self:CreateSeparatorArrows( self.sepTracksInstrs );
end

function SongbookWindow:PrintInstrShortcuts( )
	local aSlotData = CharSettings.InstrSlots
	local aInfo = {}
	for i = 1, self.instrlistBox:GetItemCount( ) do -- CharSettings.InstrSlots["number"]
		local qs = self.instrSlot[ i ]
		local sIdx = tostring( i )
		if aSlotData[ sIdx ] and aSlotData[ sIdx ].data ~= "" and aSlotData[ sIdx ].qsType then
			local sc = qs:GetShortcut( )
			if sc then
				local item = sc:GetItem( )
				local sItem = item and item:GetName( ) or "-"
				aInfo[ #aInfo + 1 ] = 
					sIdx..": "..tostring(aSlotData[ sIdx ].qsType)..", "..tostring(aSlotData[ sIdx ].qsData).." ("..sItem..")"
			end
		end
	end
	if #aInfo > 0 then WRITE( "Instrument Shortcuts:\n"..table.concat( aInfo, "\n" ) )
	else WRITE( "All instrument slots are empty." ); end
end

function SongbookWindow:RestoreInstrumentSlots( )
	local aSlotData = CharSettings.InstrSlots
	for i = 1, self.instrlistBox:GetItemCount( ) do -- CharSettings.InstrSlots["number"]
		local qs = self.instrSlot[ i ]
		local sIdx = tostring( i )
		if aSlotData[ sIdx ] and aSlotData[ sIdx ].data ~= "" and aSlotData[ sIdx ].qsType then
			pcall( function()
				local sc = Turbine.UI.Lotro.Shortcut( aSlotData[ sIdx ].qsType, aSlotData[ sIdx ].qsData );
				qs:SetShortcut( sc ); end )
		end
	end
end

function SongbookWindow.SetEquippedInstrument( item )
	if songbookWindow.lbSlots and songbookWindow.lbSlots:IsVisible( ) then songbookWindow.lbSlots:SetVisible( false ); end
	if item then songbookWindow.lblInstr:SetText( "Equipped: "..item:GetName( ) ); end; end

function SongbookWindow:CreateInstrSelectList( )
	self.lbSlots = ListBoxScrolled:New( 10, 10, false )
	self.lbSlots:SetParent( self )
	self.lbSlots:SetVisible( false )
	self.lbSlots:SetBackColor( Turbine.UI.Color( 1, 0.1, 0.1, 0.1 ) )
	self.lbSlots:SetZOrder( 320 )
end

function SongbookWindow:ListInstruments( )
	if not self.aUix then
		local song = SongDB.Songs[ selectedSongIndex ]
		if song then self.aUix = Assigner:GetSongUix( song, self.iCurrentSetup ); end; end --iSetup
	if not self.aUix then return; end
	if not self.lbSlots then self:CreateInstrSelectList( ); end
	local n = Instruments:ListRelevantSlots( self.aUix, self.lbSlots )
	if n <= 0 then return; end
	local height = 40 * n + 10
	local heightLimit = self.listFrame:GetTop( ) + self.listFrame:GetHeight( ) - self.lblInstr:GetTop( ) - self.lblInstr:GetHeight( )
	if height > heightLimit then height = heightLimit; end
	self.lbSlots:SetSize( 225, height )
	local x = self:GetWidth() - 22 - self.lbSlots:GetWidth( )
	local y = self.yListFrame + 8 + self.lblInstr:GetHeight( )
	self.lbSlots:SetPosition( x, y )
	self.lbSlots:SetVisible( true )
end

-- Used to create the buttons along the bottom border
function SongbookWindow:CreateButton( parent, sCode, funcMouseClick, xPos, yPos, width, height )

	--* Settings button *
	local button = Turbine.UI.Lotro.Button();
	button:SetParent( parent );
	button:SetPosition( xPos, yPos );
	button:SetSize( width, height );
	if sCode then button:SetText( Strings[sCode] ); end
	button.MouseClick = funcMouseClick
	return button
end


local function InformLeader( s, a )
	if a.Button ~= Turbine.UI.MouseButton.Left then return; end
	songbookWindow:CreateInformQS( )
end


local function InformTB_Show( self, parent, sTxt, x, y, w, h )
	if not self.tb then
		self.tb = Turbine.UI.Lotro.TextBox()
		self.tb:SetParent( parent )
		self.tb:SetFont( Turbine.UI.Lotro.Font.Verdana14 )
		self.tb:SetBackColor( songbookWindow.colorBlack )
		self.tb:SetMultiline( true )
		self.tb:SetReadOnly( true )
		self.tb.FocusLost = function(s,a) s:SetVisible( false ); end
	end
	self.tb:SetText( sTxt )
	self.tb:SetPosition( x, y )
	self.tb:SetSize( w, h )
	self.tb:SetVisible( true )
end

local function InformTB_Activate( self, parent, sTxt, f, ctrl, w, h )
	if self:IsActive( ) then f( ); self.tb:SetVisible( false ); return; end
	local x, y = ctrl:GetLeft( ), ctrl:GetTop( ) - h - 5
	if w > parent:GetWidth( ) then w = parent:GetWidth( ); end
	if h > parent:GetHeight( ) then h = parent:GetHeight( ); end
	if x + w > parent:GetWidth( ) then x = parent:GetWidth( ) - w; end
	if y + h > parent:GetHeight( ) then y = parent:GetHeight( ) - h; end
	self:Show( parent, sTxt, x, y, w, h )
	self.tb:Focus( )
end

InformTB =
{
	tb = nil,
	btn = nil,
	wBtn = 70, hBtn = 20,
	New = function( self ) local obj = {}; setmetatable( obj, self ); self.__index = self; return obj; end,
	Show = InformTB_Show,
	Activate = InformTB_Activate,
	IsActive = function( self ) return self.tb and self.tb:IsVisible( ); end,
	Hide = function( self, parent ) if self.qs and self.qs:HasFocus( ) then parent:Focus( ); end; end,
}

function SongbookWindow:PlaceInformTB( )
	local w, h = self.instrlistBox:GetLeft( ) + self.instrlistBox:GetWidth( ) - self.ButtonRow.xPos, 100
	local xPos = self.ButtonRow.xPos
	local yPos = self:GetHeight() - self.ButtonRow.height - self.ButtonRow.btmIndent - h - 10
	self.tb:SetPosition( xPos, yPos )
	self.tb:SetSize( w, h )
end

function SongbookWindow:CreateInformTB( )
	if self.tb then self.tb:SetVisible( true ); self:PlaceInformTB( ); return; end
	self.tb = Turbine.UI.Lotro.TextBox()
	self.tb:SetParent( self )
	self:PlaceInformTB( )
	self.tb:SetFont( Turbine.UI.Lotro.Font.Verdana14 )
	self.tb:SetBackColor( self.colorBlack )
	self.tb:SetMultiline( true )
	self.tb:SetReadOnly( true )
	self.tb:SetVisible( true )
end

function SongbookWindow:CreateInformQS( )
	local player = self:GetPlayer( ) --Turbine.Gameplay.LocalPlayer:GetInstance();
	if not player then return; end
	local party = player:GetParty( );
	if not party then WRITE( Strings["asn_needFsOrRaid"] ); return; end
	local leader = party:GetLeader( )
	if not leader then return; end
	local sPlayer = player:GetName( )
	if not Instruments:SlotsToSkills( self.instrSlot, sPlayer ) then return; end
	self:CreateInformTB( )
	self.tb:SetText( Strings["asn_postSkills1"]..tostring( leader:GetName( ) )..Strings["asn_postSkills2"]..
		"\n\n"..Strings["asn_postSkills3"] )
	if not self.floatSC then
		self.floatSC = FloatSC:New( 57, 18, "icn_btnSend", "icn_btnSend_a" ); end
	local sCmd = skillsWindow:PrepareData( player:GetName( ), leader:GetName( ) )
	if not sCmd then return; end
	local x = self.tb:GetWidth( ) - self.floatSC.width - 3
	local y = self.tb:GetHeight( ) - self.floatSC.height - 3
	self.floatSC:Activate( self.tb, sCmd, x, y, self.tb )
	skillsWindow:UpdateSkills( sPlayer )
end


function SongbookWindow:CreateIconButton( parent, f, x, y, w, h, sImg, sImgActive )
	local iconBtn = CreateIcon( parent, sImg )
	iconBtn:SetPosition( x, y )
	iconBtn:SetSize( w, h )
	iconBtn:SetMouseVisible( true )
	iconBtn.sIcon = sImg
	iconBtn.sIcon_a = sImgActive
	iconBtn.MouseClick = f
	iconBtn.MouseEnter = function(s,a) s:SetBackground( gDir..s.sIcon_a..".tga" ); end
	iconBtn.MouseLeave = function(s,a) s:SetBackground( gDir..s.sIcon..".tga" ); end
	return iconBtn
end

-- Create the buttons at the bottom of the main window
function SongbookWindow:CreateButtonRow( )

	local cfg = self.ButtonRow
	local yPos = self:GetHeight() - cfg.height - cfg.btmIndent
	local xPos = cfg.xPos
	
	if not self.informTB then self.informTB = InformTB:New( ); end
	local fRel = function(s,a) songbookWindow:ReloadSongDB( ); end
	--local fRel = function(s,a) WRITE( "Reload"); end
	local fTb = function(s,a)
		if a.Button == Turbine.UI.MouseButton.Left then
			self.informTB:Activate( self, Strings["reloadMsg"], fRel, self.btnReload, 300, 110 ); end; end
	self.btnReload = self:CreateIconButton( self, fTb, xPos, yPos, cfg.wiReload, cfg.height, "icn_reload", "icn_reload_a" )
	--self.btnReload = self:CreateButton( self, nil, f, xPos, yPos, cfg.wiReload, cfg.height )

	xPos = xPos + cfg.wiReload + cfg.spacing
	local f = function(s,a) if a.Button == Turbine.UI.MouseButton.Left then settingsWindow:SetVisible( true ) end; end
	self.btnSettings = self:CreateButton( self, "ui_settings", f, xPos, yPos, cfg.wiSettings, cfg.height )

	xPos = xPos + cfg.wiSettings + cfg.spacing * 2
	self.btnInform = self:CreateButton( self, "informBtn", InformLeader, xPos, yPos, cfg.wiInform, cfg.height )

	xPos = xPos + cfg.wiInform + cfg.spacing
	f = function(s,a) if a.Button == Turbine.UI.MouseButton.Left then songbookWindow:LaunchAssignWindow( ); end; end
	self.btnAssign = self:CreateButton( self, "assignBtn", f, xPos, yPos, cfg.wiAssign, cfg.height )

	self.MouseClick = function( s, a )
		if s.floatSC then s.floatSC:Hide( s );end
		if s.informTB and s.informTB.tb then s.informTB.tb:SetVisible( false ); end; end
end


function SongbookWindow:SongAndSetupSelected( )
	return selectedSongIndex and selectedSongIndex > 0 and self.iCurrentSetup and self.iCurrentSetup > 0; end

function SongbookWindow:SelectSetupForCount( c )
	if selectedSongIndex <= 0 then return false; end
	local iSetup = self:SetupIndexForCount( selectedSongIndex, c )
	if not iSetup then return false; end
	self:SelectSetup( iSetup )
	self.iCurrentSetup = iSetup
	return true
end

function SongbookWindow:LaunchAssignWindow( )
	DEBUG_Prep( ) --TODO: REMOVE
	assignWindow:Launch( )
end


-- Reposition the buttons on window resize
function SongbookWindow:MoveButtonRow( )

	local right = self:GetWidth() - 25
--WRITE( "Window width="..tostring(self:GetWidth())..", left="..self:GetLeft() )
	local yPos = self:GetHeight() - self.ButtonRow.height - self.ButtonRow.btmIndent
	
	local xPos = self.ButtonRow.xPos
	self.btnReload:SetPosition( xPos, yPos )

	xPos = xPos + self.ButtonRow.wiReload + self.ButtonRow.spacing
	self.btnSettings:SetPosition( xPos, yPos )

	xPos = right - self.ButtonRow.wiAssign
	self.btnAssign:SetPosition( xPos, yPos )
	
	xPos = xPos - self.ButtonRow.wiInform - self.ButtonRow.spacing
	self.btnInform:SetPosition( xPos, yPos )
end


---------------------
-- Songbook Window --
---------------------
-- Songbook Window : Resize All
function SongbookWindow:ResizeAll()
	
	-- ZEDMOD: Set Container and Frame Size
	self:SetContainer();
	
	-- Set Instrument Container Top
	--self.instrContainer:SetTop( self:GetHeight() - 75 ); -- ZEDMOD: OriginalBB
	
	-- ZEDMOD: Get Main Window Height and Container Height
	local windowHeight = self:GetHeight();
	local containerHeight = self.listContainer:GetHeight();
	local unallowedHeight = windowHeight - containerHeight;
	
	-- ZEDMOD: Set Position
	local posrep = 0;
	
	--************
	--* DIR List *
	--************
	-- Get Dir list Height
	--local dirlistheight = Settings.DirHeight; -- ZEDMOD: OriginalBB
	local dirlistheight = self:DirlistGetHeight(); -- ZEDMOD
	
	-- Set Dir List Height
	--self.dirlistBox:SetHeight( Settings.DirHeight ); -- ZEDMOD: OriginalBB
	self.dirlistBox:SetHeight( dirlistheight ); -- ZEDMOD
	
	-- Adjust Dir List Position
	--self:AdjustDirlistPosition(); -- ZEDMOD: OriginalBB
	self:AdjustDirlistPosition( posrep ); -- ZEDMOD
	
	-- ZEDMOD: Update Position
	posrep = posrep + dirlistheight + 13;
	
	-- ZEDMOD: Update Settings Dir list Height
	Settings.DirHeight = self.dirlistBox:GetHeight();
	
	--*************
	--* Song list *
	--*************
	-- Get Song List Height
	local songlistheight = self:SonglistGetHeight(); -- ZEDMOD
	
	-- Set Song List Height
	-- self:AdjustSonglistHeight(); -- ZEDMOD: OriginalBB
	self.songlistBox:SetHeight( songlistheight ); -- ZEDMOD
	
	-- ZEDMOD: Set Songlist Left
	--self:AdjustSonglistLeft();
	
	-- ZEDMOD: Set Players List
	self.listboxPlayers:SetHeight( songlistheight - 20 );
	
	-- ZEDMOD: Set Position
	local songlistpos = posrep;
	
	-- Adjust Song List Position
	--self:AdjustSonglistPosition(); -- ZEDMOD: OriginalBB
	self:AdjustSonglistPosition( songlistpos ); -- ZEDMOD
	
	-- ZEDMOD: Update Position
	posrep = posrep + 13 + songlistheight;
	
	-- ZEDMOD: Update Settings Song List Height
	Settings.SongsHeight = self.songlistBox:GetHeight();
	
	--************************************
	--* Tracks List and Instruments List *
	--************************************
	-- ZEDMOD:
	if ( ( Settings.TracksVisible == "yes" ) and ( CharSettings.InstrSlots["visible"] == "no") ) then
		
		-- Get Track List Height
		local tracklistheight = self:TracklistGetHeight();
		
		-- Set Track List Height and Width
		self:AdjustTracklistLeft();
		self:AdjustTracklistWidth();
		self.tracklistBox:SetHeight( tracklistheight );
		self.listboxSetups:SetHeight( tracklistheight );
		
		-- Set Position
		local tracklistpos = posrep;
		
		-- Adjust Track List Position
		self:AdjustTracklistPosition( tracklistpos );
		
		-- Update Position
		posrep = posrep + 13 + tracklistheight;
		
		-- Update Settings Track List Height
		Settings.TracksHeight = self.tracklistBox:GetHeight();
		
		-- Update Main Window and Container Size
		self:UpdateContainer( posrep );
		self:UpdateMainWindow( unallowedHeight );
		self:SetContainer();
		
	elseif ( ( Settings.TracksVisible == "yes" ) and ( CharSettings.InstrSlots["visible"] == "yes") ) then
	
		-- Get Track List Height
		local tracklistheight = self:TracklistGetHeight();
		
		-- Set Track List Height and Width
		self:AdjustTracklistLeft();
		self:AdjustTracklistWidth();
		self.tracklistBox:SetHeight( tracklistheight );
		self.listboxSetups:SetHeight( tracklistheight );
		
		-- Set Position
		local tracklistpos = posrep;
		
		-- Adjust Track List Position
		self:AdjustTracklistPosition( tracklistpos );
		
		-- Update Position
		posrep = posrep + 13 + tracklistheight;
		
		-- Update Settings Track List Height
		Settings.TracksHeight = self.tracklistBox:GetHeight();
		
		-- Get Instrument List Height
		local instrlistheight = self:InstrlistGetHeight();
		
		-- Set Instrument List Height
		self.instrlistBox:SetHeight( instrlistheight );
		
		-- Set Position
		local instrlistpos = posrep;
		
		-- Adjust Instrument List Position
		self:AdjustInstrlistPosition( instrlistpos );
		
		-- Adjust Instrument Slot
		self:AdjustInstrumentSlots();
		
		-- Update Position
		posrep = posrep + 13 + instrlistheight;
		
		-- Update Settings Instrument List Height
		Settings.InstrsHeight = self.instrlistBox:GetHeight();
		
		-- Update Main Window and Container Size
		if ( self.bInstrumentsVisibleHForced == false ) then
			self:UpdateContainer( posrep );
		else
			self:UpdateContainer( posrep + 10 );
		end
		self:UpdateMainWindow( unallowedHeight );
		self:SetContainer();
		
	elseif ( ( Settings.TracksVisible == "no" ) and ( CharSettings.InstrSlots["visible"] == "yes") ) then
		
		-- Get Instrument List Height
		local instrlistheight = self:InstrlistGetHeight();
		
		-- Set Instrument List Height
		self.instrlistBox:SetHeight( instrlistheight );
		
		-- Set Position
		local instrlistpos = posrep;
		
		-- Adjust Instrument List Position
		self:AdjustInstrlistPosition( instrlistpos );
		
		-- Adjust Instrument Slot
		self:AdjustInstrumentSlots();
		
		-- Update Position
		posrep = posrep + 13 + instrlistheight;
		
		-- Update Settings Instrument List Height
		Settings.InstrsHeight = self.instrlistBox:GetHeight();
		
		-- Update Main Window and Container Size
		if ( self.bInstrumentsVisibleHForced == false ) then
			self:UpdateContainer( posrep );
		else
			self:UpdateContainer( posrep + 10 );
		end
		self:UpdateMainWindow( unallowedHeight );
		self:SetContainer();
	else
		-- Update Main Window and Container Size
		if ( self.bInstrumentsVisibleHForced == false ) then
			self:UpdateContainer( posrep );
		else
			self:UpdateContainer( posrep + 10 );
		end
		self:UpdateMainWindow( unallowedHeight );
		self:SetContainer();
	end
	-- /ZEDMOD
	
	--********************
	--* Adjust Filter UI *
	--********************
	self:AdjustFilterUI();
	
	--********************
	--* Adjust Party UI *
	--********************
	self:AdjustPartyUI();
end

-------------------------------------
-- ZEDMOD: Adjust Instrument Slots --
-------------------------------------
function SongbookWindow:AdjustInstrumentSlots( args )
	if ( self.bInstrumentsVisibleHForced == false ) then
		self.instrlistBox:SetOrientation( Turbine.UI.Orientation.Horizontal );
	else
		self.instrlistBox:SetOrientation( Turbine.UI.Orientation.Vertical );
	end
	local width, height = self.instrlistBox:GetSize();
	local itemWidth = 35;
	local itemHeight = 40;
	local listWidth = width;
	local listHeight = height;
	local itemsPerRowV = listWidth / itemWidth;
	local itemsPerRowH = listHeight / itemHeight;
	if ( self.bInstrumentsVisibleHForced == false ) then
		self.instrlistBox:SetMaxItemsPerLine( itemsPerRowV );
	else
		self.instrlistBox:SetMaxItemsPerLine( itemsPerRowH );
	end
end

-----------------------------------
-- Validate Main Window Position --
-----------------------------------
-- TODO: add complete set of checks
function SongbookWindow:ValidateWindowPosition( winPos )
	local displayWidth, displayHeight = Turbine.UI.Display.GetSize();
	-- Max Width
	if ( winPos.Width > displayWidth ) then
		winPos.Width = displayWidth;
	end
	-- Max Height
	if ( winPos.Height > displayHeight ) then
		winPos.Height = displayHeight;
	end
	-- Any value < 0
	if ( winPos.Left < 0 or winPos.Top < 0 or winPos.Width < 0 or winPos.Height < 0 ) then
		winPos.Left = 0; -- ZEDMOD : OLD 700 Default Settings Left Value
		winPos.Top = 0; -- ZEDMOD : OLD 20 Default Settings Top Value
		winPos.Width = 323; -- ZEDMOD : OLD 342 Default Settings Width Value
		winPos.Height = 400; -- ZEDMOD : OLD 398 Default Settings Height Value
	end
	-- Max Width + Left
	if ( winPos.Left + winPos.Width - 1 > displayWidth ) then
		winPos.Left = 0;
		winPos.Width = winPos.Width;
	end
	-- Max Height + Top
	if ( winPos.Top + winPos.Height - 1 > displayHeight ) then
		winPos.Top = 0;
		winPos.Height = winPos.Height;
	end
end

function SongbookWindow:FixToggleSettings( tglTop, tglLeft )
	local displayWidth, displayHeight = Turbine.UI.Display.GetSize();
	-- Out of Bottom
	if ( tglTop + 35 > displayHeight ) then
		tglTop = displayHeight - 35;
	end
	-- Toggle Top
	if ( tglTop < 0 ) then
		tglTop = 0;
	end
	-- Out of Right
	if ( tglLeft + 35 > displayWidth ) then
		tglLeft = displayWidth - 35;
	end
	-- Toggle Left
	if ( tglLeft < 0 ) then
		tglLeft = 0;
	end
end

-- Fix values settings to default values when no settings for
function SongbookWindow:FixIfNotSettings( Settings, SongDB, CharSettings )
	if ( not Settings.DirHeight ) then
		Settings.DirHeight = "40"; -- ZEDMOD: OriginalBB value: 100
	end
	if ( not Settings.TracksHeight ) then
		Settings.TracksHeight = "40";
	end
	if ( not Settings.TracksVisible ) then
		Settings.TracksVisible = "yes"; -- ZEDMOD: OriginalBB value: no
	end
	if ( not Settings.WindowVisible ) then
		Settings.WindowVisible = "yes"; -- ZEDMOD: OriginalBB value: no
	end	
	if ( not Settings.SearchVisible ) then
		Settings.SearchVisible = "yes";
	end
	if ( not Settings.DescriptionVisible ) then
		Settings.DescriptionVisible = "no";
	end
	if ( not Settings.DescriptionFirst ) then
		Settings.DescriptionFirst = "no";
	end
	if ( not Settings.ToggleOpacity ) then
		Settings.ToggleOpacity = "1"; -- ZEDMOD: OriginalBB value 1/4
	end
	if not Settings.FiltersState then Settings.FiltersState = "true"; end
	if not Settings.ChiefMode then Settings.ChiefMode = "true"; end
	if not Settings.ShowAllBtns then Settings.ShowAllBtns = "false"; end
	if not Settings.TimerState then Settings.TimerState = "true"; end -- ZEDMOD: OriginalBB value: false
	if not Settings.TimerCountdown then Settings.TimerCountdown = "true"; end
 	if not Settings.ReadyColState then Settings.ReadyColState = "true"; end
 	if ( not Settings.ReadyColHighlight ) then
		Settings.ReadyColHighlight = "false";
	end
	-- ZEDMOD: Adding Songs Height default value
	if ( not Settings.SongsHeight ) then
		Settings.SongsHeight = "40";
	end
	-- ZEDMOD: Adding Instruments Height default value
	if ( not Settings.InstrsHeight ) then
		Settings.InstrsHeight = "40";
	end
	-- ZEDMOD: Party on/off
	if not Settings.PartyState then Settings.PartyState = "true"; end -- ZEDMOD: OriginalBB value: false
	
	if ( not SongDB.Songs ) then
		SongDB = {
			Directories = {},
			Songs = {}
		};
	end
	
	if ( not Settings.Commands ) then
		Settings.Commands = {};
		Settings.Commands["1"] = { Title = Strings["cmd_demo1_title"], Command = Strings["cmd_demo1_cmd"] };
		Settings.Commands["2"] = { Title = Strings["cmd_demo2_title"], Command = Strings["cmd_demo2_cmd"] };
		Settings.Commands["3"] = { Title = Strings["cmd_demo3_title"], Command = Strings["cmd_demo3_cmd"] };
		Settings.DefaultCommand = "1";
	end
	
	-- Instruments Slots
	if ( not CharSettings.InstrSlots ) then
		CharSettings.InstrSlots = {};
		CharSettings.InstrSlots["visible"] = "yes"; -- ZEDMOD: OriginalBB value: yes
		CharSettings.InstrSlots["visHForced"] = "false"; -- ZEDMOD
		CharSettings.InstrSlots["number"] = 16; -- ZEDMOD: OriginalBB value 8
		for i = 1, CharSettings.InstrSlots["number"] do
			CharSettings.InstrSlots[tostring( i )] = { qsType = "", qsData = "" };
		end
	end
	
	if ( not CharSettings.InstrSlots["number"] ) then
		CharSettings.InstrSlots["number"] = 16; -- ZEDMOD: OriginalBB value 8
	end
	for i = 1, CharSettings.InstrSlots["number"] do
		CharSettings.InstrSlots[tostring( i )].qsType = tonumber( CharSettings.InstrSlots[tostring( i )].qsType );
	end
	
	-- ZEDMOD
	if ( not CharSettings.InstrSlots["visible"] ) then
		CharSettings.InstrSlots["visible"] = "yes"; -- ZEDMOD: OriginalBB value: no
	end
	-- ZEDMOD: if Instrument Slots is visible, force to one horizontal line
	if ( not CharSettings.InstrSlots["visHForced"] ) then
		CharSettings.InstrSlots["visHForced"] = "false";
	end
end

---------------------------
-- Database : Select Dir --
---------------------------
-- action for selecting a directory
function SongbookWindow:SelectDir( iDir )
	local selectedItem = self:SetListboxColours( self.dirlistBox ); --, iDir )
	if ( not selectedItem ) then
		return;
	end
	if ( selectedItem:GetText() == ".." ) then
		selectedDir = "";
		table.remove( dirPath, #dirPath );
		for i = 1, #dirPath do
			selectedDir = selectedDir .. dirPath[i];
		end
	else
		selectedDir = selectedDir .. selectedItem:GetText();
		dirPath[#dirPath + 1] = selectedItem:GetText();
	end
	if ( string.len( selectedDir ) < 31 ) then
		--self.listFrame.heading:SetText( Strings["ui_dirs"] .. " (" .. selectedDir .. ")" ); -- ZEDMOD: OriginalBB
		self.sepDirs.heading:SetText( Strings["ui_dirs"] .. " (" .. selectedDir .. ")" ); -- ZEDMOD
	else
		--self.listFrame.heading:SetText( Strings["ui_dirs"] .. " (" .. string.sub( selectedDir, string.len( selectedDir ) - 30 ) .. ")" ); -- ZEDMOD: OriginalBB
		self.sepDirs.heading:SetText( Strings["ui_dirs"] .. " (" .. string.sub( selectedDir, string.len( selectedDir ) - 30 ) .. ")" ); -- ZEDMOD
	end
	-- Refresh Dir List
	self.dirlistBox:ClearItems();
	local dirItem = Turbine.UI.Label();
	if ( selectedDir ~= "/" ) then
		dirItem:SetText( ".." ); -- first item as link to previous directory
		dirItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
		dirItem:SetSize( 1000, 20 );
		self.dirlistBox:AddItem( dirItem );
	end
	for i = 1, #SongDB.Directories do
		dirItem = Turbine.UI.Label();
		local _, dirLevelIni = string.gsub( selectedDir, "/", "/" );
		local _, dirLevel = string.gsub( SongDB.Directories[i], "/", "/" );
		if ( dirLevel == dirLevelIni + 1 ) then
			if ( selectedDir ~= "/" ) then
				local matchPos,_ = string.find( SongDB.Directories[i], selectedDir, 0, true );
				if ( matchPos == 1 ) then
					local _,cutPoint = string.find( SongDB.Directories[i], dirPath[#dirPath], 0, true );
					dirItem:SetText( string.sub( SongDB.Directories[i], cutPoint + 1 ) );
					dirItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
					dirItem:SetSize( 1000, 20 );
					self.dirlistBox:AddItem( dirItem );
				end
			else
				dirItem:SetText( string.sub( SongDB.Directories[i], 2 ) );
				dirItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
				dirItem:SetSize( 1000, 20 );
				self.dirlistBox:AddItem( dirItem );
			end
		end
	end
	-- Refresh Song List
	self.songlistBox:ClearItems();
	self:LoadSongs();
	self:InitSonglist();
end

---------------------------------------
-- Database : Load Songs to Songlist --
---------------------------------------
-- load content to song list box
function SongbookWindow:LoadSongs()
	local nFiltered = 0;
	for i = 1, librarySize do
		local songItem = Turbine.UI.Label();
		-- Added function to filter song data
		if ( SongDB.Songs[i].Filepath == selectedDir and self:ApplyFilters( SongDB.Songs[i] ) ) then
			if ( Settings.DescriptionVisible == "yes" ) then
				if ( Settings.DescriptionFirst == "yes" ) then
					songItem:SetText( SongDB.Songs[i].Tracks[1].Name .. " / " .. SongDB.Songs[i].Filename );
				else
					songItem:SetText( SongDB.Songs[i].Filename .. " / " .. SongDB.Songs[i].Tracks[1].Name );
				end
			else
				songItem:SetText( SongDB.Songs[i].Filename );
			end
			songItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
			songItem:SetSize( 1000, 20 );
			self.songlistBox:AddItem( songItem );
			nFiltered = nFiltered + 1;
			self.aFilteredIndices[nFiltered] = i; -- Create filtered index
		end
	end
end


function SongbookWindow:GetSongName( iSong )
	iSong = iSong or selectedSongIndex
--	if ( SongDB.Songs[iSong].Tracks[1].Name ~= "" ) then
--		return SongDB.Songs[iSong].Tracks[1].Name
--	end
	return SongDB.Songs[iSong].Filename
end

---------------------------
-- Database : Select Song -
---------------------------
-- Action for selecting a song -
function SongbookWindow:SelectSong( iSong )
	if ( ( iSong < 1 ) or ( iSong > self.songlistBox:GetItemCount() ) ) then
		return;
	end
	selectedTrack = 1;
	self.aSetupTracksIndices = {};
	self.aSetupListIndices = {};
	self.iCurrentSetup = nil;
	-- clear focus
	self:SetListboxColours( self.songlistBox ); --, iSong )
	selectedSongIndex = self.aFilteredIndices[iSong];
	selectedSong = SongDB.Songs[selectedSongIndex].Filename;
	if ( SongDB.Songs[selectedSongIndex].Tracks[1].Name ~= "" ) then
		self.songTitle:SetText( SongDB.Songs[selectedSongIndex].Tracks[1].Name );
	else
		self.songTitle:SetText( SongDB.Songs[selectedSongIndex].Filename );
	end
	self.trackNumber:SetText( SongDB.Songs[selectedSongIndex].Tracks[1].Id );
	self.trackPrev:SetVisible( false );
	if ( #SongDB.Songs[selectedSongIndex].Tracks > 1 ) then
		self.trackNext:SetVisible( self.bShowAllBtns );
	else
		self.trackNext:SetVisible( false );
	end
	self:ListTracks( selectedSongIndex );
	self:ClearPlayerReadyStates();
	self:SelectTrack( selectedTrack );
	self:SetPlayerColours();
	self:ListSetups( selectedSongIndex );
	self.iCurrentSetup = self:SetupIndexForCount( selectedSongIndex, self.selectedSetupCount );
	self:SelectSetup( self.iCurrentSetup );
	self:UpdateSetupColours();
	local found = self.tracklistBox:GetItemCount();
	self.sepSongsTracks.heading:SetText( Strings["ui_parts"] .. " (" .. found .. ")" );
	if assignWindow then assignWindow:NewSongSelected( iSong ); end
end

------------------------------
-- Database : Selected Track -
------------------------------
-- Track list : Selected Track Index
function SongbookWindow:SelectedTrackIndex( iList )
	if ( not iList ) then
		iList = selectedTrack;
	end -- use global selected track index if none provided
	if ( ( self.iCurrentSetup ) and ( self.aSetupTracksIndices[iList] ) ) then
		return self.aSetupTracksIndices[iList];
	end
	return iList;
end

-- Track list action for repopulating the track list when song is changed
function SongbookWindow:ListTracks( songId )
	self.tracklistBox:ClearItems();
	for i = 1, #SongDB.Songs[songId].Tracks do
		self:AddTrackToList( songId, i );
	end
	--Turbine.Chat.Received = self.ChatHandler; -- Enable chat monitoring for ready messages to update track colours
end

-- Track list : Create Track List Item
function SongbookWindow:CreateTracklistItem( sText )
	local trackItem = Turbine.UI.Label();
	trackItem:SetMultiline( false );
	trackItem:SetText( sText );
	trackItem.MouseClick = self.sepSongsTracks.MouseClick;
	trackItem:SetForeColor( self.colourDefault );
	return trackItem;
end

-- Track list : Add Track to List
function SongbookWindow:AddTrackToList( iSong, iTrack )
	local sTerseName = self:TerseTrackname( SongDB.Songs[iSong].Tracks[iTrack].Name );
	local trackItem = self:CreateTracklistItem( "[" .. SongDB.Songs[iSong].Tracks[iTrack].Id .. "]" .. sTerseName );
	trackItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
	trackItem:SetSize( 1000, 20 );
	self.tracklistBox:AddItem( trackItem );
end

-- Track list : Right-align track names (so user can quickly check then end of the track name)
function SongbookWindow:RealignTracknames()
	local alignment, left;
	if ( self.alignTracksRight == false ) then
		self.alignTracksRight = true;
		alignment = Turbine.UI.ContentAlignment.MiddleRight;
		left = self.tracklistBox:GetWidth() - 1010;
	else
		self.alignTracksRight = false;
		alignment = Turbine.UI.ContentAlignment.MiddleLeft;
		if ( self.bShowReadyChars ) then
			left = 20;
		else
			left = 0;
		end
	end
	for i = 1, self.tracklistBox:GetItemCount() do
		local item = self.tracklistBox:GetItem( i );
		item:SetLeft( left );
		item:SetTextAlignment( alignment );
	end
end

-- Track list : action for changing track selection (trackid is listbox index)
function SongbookWindow:SelectTrack( trackId )
	if ( self.bShowReadyChars ) then
		trackId = math.floor( ( trackId + 1 ) / 2 );
	end
	selectedTrack = trackId;
	local iTrack = self:SelectedTrackIndex( trackId );
	local trackcount = #SongDB.Songs[selectedSongIndex].Tracks;
	if ( selectedTrack > 1 ) then
		if ( selectedTrack == trackcount ) then
			self.trackPrev:SetVisible( self.bShowAllBtns );
			self.trackNext:SetVisible( false );
		else
			self.trackPrev:SetVisible( self.bShowAllBtns );
			self.trackNext:SetVisible( self.bShowAllBtns );
		end
	end
	if ( selectedTrack == 1 ) then
		self.trackPrev:SetVisible( false );
		if ( trackcount == 1 ) then
			self.trackNext:SetVisible( false );
		else
			self.trackNext:SetVisible( self.bShowAllBtns );
		end
	end
	self.trackNumber:SetText( SongDB.Songs[selectedSongIndex].Tracks[iTrack].Id );
	self.songTitle:SetText( SongDB.Songs[selectedSongIndex].Tracks[iTrack].Name );
	self.playSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_play"] .. " \"" .. SongDB.Songs[selectedSongIndex].Filepath .. selectedSong .. "\" " .. SongDB.Songs[selectedSongIndex].Tracks[iTrack].Id );
	self.playSlot:SetShortcut( self.playSlotShortcut );
	self.playSlot:SetVisible( true );
	self.syncSlotShortcut = Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, Strings["cmd_play"] .. " \"" .. SongDB.Songs[selectedSongIndex].Filepath .. selectedSong .. "\" " .. SongDB.Songs[selectedSongIndex].Tracks[iTrack].Id .. " " .. Strings["cmd_sync"] );
	self.syncSlot:SetShortcut( self.syncSlotShortcut );
	self.syncSlot:SetVisible( true );
	self.shareSlot:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, self:ExpandCmd( Settings.DefaultCommand ) ) );
	self.shareSlot:SetVisible( self.bShowAllBtns );
	self:SetTrackColours( selectedTrack );
end

-- Track list : action for setting focus on the track list
function SongbookWindow:SetTrackColours( iSelectedTrack )
	if ( ( not self.tracklistBox ) or ( self.tracklistBox:GetItemCount() < 1 ) ) then
		return;
	end
	self:ClearPlayerReadyStates(); -- Clear ready states for currently displayed song
	for iTrack = 1, #SongDB.Songs[selectedSongIndex].Tracks do
		if ( ( self.iCurrentSetup ) and ( not self.aSetupListIndices[iTrack] ) ) then
			self:GetTrackReadyState( SongDB.Songs[selectedSongIndex].Tracks[iTrack].Name, 3 );
		else
			local iList = iTrack;
			if ( self.aSetupListIndices[iTrack] ) then
				iList = self.aSetupListIndices[iTrack];
			end
			local item = self.tracklistBox:GetItem( iList );
			local readyState = self:GetTrackReadyState( SongDB.Songs[selectedSongIndex].Tracks[iTrack].Name );
			item:SetForeColor( self:GetColourForTrack( readyState, iList == iSelectedTrack ) );
			item:SetBackColor( self:GetBackColourForTrack( readyState ) );
			self:SetTrackReadyChar( iList, readyState );
		end
	end
end

-- Track list : return track colour based on readyState retrieved from GetTrackReadyState(...)
function SongbookWindow:GetColourForTrack( readyState, bSelectedTrack )
	if ( bSelectedTrack ) then
		if ( not readyState ) then -- track not ready
			return self.colourDefaultHighlighted;
		elseif ( readyState == 0 ) then -- track is ready by more than one player
			return self.colourReadyMultipleHighlighted;
		else -- track ready by one player
			return self.colourReadyHighlighted;
		end
	else
		if ( not readyState ) then
			return self.colourDefault;
		elseif ( readyState == 0 ) then
			return self.colourReadyMultiple;
		else
			return self.colourReady;
		end
	end
end

-- Track list : background colour indicates the track one has ready
-- TODO: blue (multiple ready track) overrides wrong instrument indicator
function SongbookWindow:GetBackColourForTrack( readyState )
	if ( not readyState or readyState ~= self.sPlayerName ) then
		return self.backColourDefault;
	end
	return self.backColourHighlight;
	--if self.bInstrumentOk then return self.backColourHighlight; end
	--return self.backColourWrongInstrument
end

-- Track list : set track ready indicator
function SongbookWindow:SetTrackReadyChar( iList, readyState )
	if ( not readyState ) then -- track not ready
		self.tracklistBox:SetColumnChar( iList, self.chNone, false );
	elseif ( readyState == 0 ) then -- track is ready by more than one player
		self.tracklistBox:SetColumnChar( iList, self.chMultiple, true );
	else -- track ready by one player
		self.tracklistBox:SetColumnChar( iList, self.chReady, false );
	end
end

-----------------
-- Message Box --
-----------------

local function LblInstr_Click( s, a )
	if a.Button ~= Turbine.UI.MouseButton.Left then return; end
	if songbookWindow.lbSlots and songbookWindow.lbSlots:IsVisible( ) then
		songbookWindow.lbSlots:SetVisible( false )
	else
		songbookWindow:ListInstruments( )
	end
end

function SongbookWindow:CreateInstrLabel( )
	self.lblInstr = Turbine.UI.Label();
	self.lblInstr:SetParent( self ); -- self.listFrame
	self.lblInstr:SetVisible( true );
	self.lblInstr:SetMultiline( false );
	--self.lblInstr:SetSize( 300, 28 );
	self.lblInstr:SetSize( -10 + self:GetWidth( ) - 2 - 12 - 13, 18 )
	self.lblInstr:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleRight );
	self.lblInstr:SetZOrder( 360 );
	self.lblInstr:SetPosition( 10, self.yListFrame + 9 );
	--self.lblInstr:SetPosition( self:GetWidth( ) - 22 - self.lblInstr:GetWidth(), self.yListFrame + 9 ); -- ,0
	self.lblInstr.MouseClick = LblInstr_Click
	self:SetTextModeNormal( self.lblInstr )
	
	self.instrSelDrop = Turbine.UI.Control( );
	self.instrSelDrop:SetParent( self );
	self.instrSelDrop:SetSize( 14, 9 );
	self.instrSelDrop:SetPosition( 11 + self.lblInstr:GetWidth( ), self.yListFrame + 13 );
	self.instrSelDrop.MouseClick = LblInstr_Click
	self.instrSelDrop:SetBackground( gDir.."droparrow_a.tga" ) -- now hiding it when inactive, so only active state needed
	--self.instrSelDrop:SetBackground( gDir .. "droparrow.tga" );
	self.instrSelDrop:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.instrSelDrop:SetZOrder( 360 );
	self.instrSelDrop:SetVisible( true );
end

function SongbookWindow:ShowInstrLabel( b )
	self.lblInstr:SetVisible( b )
	self.instrSelDrop:SetVisible( b );
end

function SongbookWindow:SetInstrLabelActive( b, s )
	self.instrSelDrop:SetVisible( b )
	if b then
		self.lblInstr:SetForeColor( self.colourActive )
	else
		self.lblInstr:SetForeColor( self.colourDefault )
	end
end
		

-- ZEDMOD: Create Message
function SongbookWindow:CreateAlertLabel( )
	self.lblInstrAlert = Turbine.UI.Label();
	self.lblInstrAlert:SetParent( self ); -- self.listFrame
	self.lblInstrAlert:SetVisible( true );
	self.lblInstrAlert:SetMultiline( false );
	self.lblInstrAlert:SetSize( -10 + self:GetWidth( ) - 13, 17 );
	self.lblInstrAlert:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleRight );
	self.lblInstrAlert:SetZOrder( 360 );
	--self.lblInstrAlert:SetPosition( self:GetWidth( ) - 22 - self.lblInstrAlert:GetWidth(), self.yListFrame - 9 ); -- ,0
	self.lblInstrAlert.MouseClick = function( s, a ) s:SetVisible( false ); end
	self:SetTextModeNormal( self.lblInstrAlert )
end

-- (Nim) split up the message/timer label into one for alerts and one for the timer
function SongbookWindow:CreateTimerLabel( )
	self.lblTimer = Turbine.UI.Label();
	self.lblTimer:SetParent( self ); -- self.listFrame
	self.lblTimer:SetMultiline( false );
	self.lblTimer:SetSize( 40, 28 );
	self.lblTimer:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleRight );
	self.lblTimer:SetZOrder( 350 );
	self.lblTimer:SetPosition( self:GetWidth() - 10 - self.lblTimer:GetWidth(), self.yListFrame - 28 )
	self.lblTimer:SetVisible( false );
	self:SetTimerModeNormal( self.lblTimer )
end

function SongbookWindow:SetTextModeNormal( lbl )
	lbl:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 ) --TrajanPro16  BookAntiquaBold22
	lbl:SetForeColor( Turbine.UI.Color( 1, 1, 1, 1 ) )
	--lbl:SetBackColor( self.colorListFrame )
end

function SongbookWindow:SetTextModeWarn( lbl )
	lbl:SetFont( Turbine.UI.Lotro.Font.TrajanProBold16 )--TrajanPro19 ) --BookAntiquaBold26 )
	lbl:SetForeColor( Turbine.UI.Color( 1, 1, 0.3, 0.3 ) )
	--lbl:SetBackColor( self.colorListFrame )
end

function SongbookWindow:SetTextModeAlert( lbl )
	lbl:SetFont( Turbine.UI.Lotro.Font.TrajanProBold22 )--TrajanPro20 ) --BookAntiquaBold26 )
	lbl:SetForeColor( Turbine.UI.Color( 1, 1, 0.3, 0.4 ) )
	--lbl:SetBackColor( Turbine.UI.Color( 1, 0.9, 0.9, 0.9 ) )
end


-----------
-- Timer --
-----------

function SongbookWindow:SetTimerModeNormal( lbl )
	lbl:SetFont( Turbine.UI.Lotro.Font.TrajanPro21 ) --TrajanPro16  BookAntiquaBold22
	lbl:SetForeColor( Turbine.UI.Color( 1, 1, 1, 1 ) )
end

function SongbookWindow:SetTimerModeAlert( lbl )
	lbl:SetFont( Turbine.UI.Lotro.Font.TrajanProBold24 ) --TrajanPro16  BookAntiquaBold22
	lbl:SetForeColor( Turbine.UI.Color( 1, 1, 0.3, 0.3 ) )
end

-- Print the given current time in seconds to the timer label
function SongbookWindow:WriteTimeMsg( tCurrent )
	local mins = math.floor( tCurrent / 60 );
	local secs = tCurrent - mins * 60
	self.lblTimer:SetText( string.format( "%u:%02u", mins, secs ) ); -- ZEDMOD
	return mins == 0 and secs < 10 -- return true if in last seconds
end

function SongbookWindow:AddDelayedCall( nSecs, fCallback )
	songbookWindow:AddPeriodic( 1, nSecs, fCallback, nil )
end


-- Activate timer count in Update(); call SetWantsUpdates if necessary
function SongbookWindow:StartCounter( )
	self.startTimer = Turbine.Engine.GetLocalTime();
	
	self.songDuration = self:GetRunningTime( )
	
	if ( ( self.bTimerCountdown == true ) and ( self.songDuration > 0 ) ) then
		self.currentTime = self.songDuration;
	else
		self.currentTime = 0;
	end
	
	self:WriteTimeMsg( self.currentTime );
	self.lblTimer:SetVisible( true )
	
	self:StartTimer( )
	self.bCounterActive = true
end

function SongbookWindow:UpdateCounter( )
	if not self.lblTimer then return; end
	local time = Turbine.Engine.GetLocalTime() - self.startTimer
	if time == self.currentTime then return; end
	self.currentTime = time --Turbine.Engine.GetLocalTime() - self.startTimer
	
	local bKeepRunning = ( self.songDuration == 0 or self.currentTime <= self.songDuration )
	if self.bTimerCountdown == true and self.songDuration > 0 then
		self.currentTime = self.songDuration - self.currentTime
		bKeepRunning = self.currentTime >= 0
	end
	
	if bKeepRunning then
		self:WriteTimeMsg( self.currentTime )
		if self.currentTime < 10 and self.bTimerCountdown then self:SetTimerModeAlert( self.lblTimer ); end
	else
		self:StopCounter();
		if self.bTimerCountdown then self:SetTimerModeNormal( self.lblTimer ); end
	end
end

function SongbookWindow:StopCounter( )
	self.bCounterActive = false
	self:StopTimer( )

	self.lblTimer:SetVisible( false )
end

function SongbookWindow:ActivateCounter( bActivate )
	self.bDisplayTimer = bActivate;
	if not bActivate and self.bCounterActive then self:StopCounter( ); end
end


function SongbookWindow:AddPeriodic( nCycles, time, f1, f2, ft, fe )
	local nt = Turbine.Engine.GetGameTime() + time
	self.aPeriodic[ #self.aPeriodic + 1 ] = { ["nt"]=nt, ["n"]=nCycles, ["t"]=time, ["f1"]=f1, ["f2"]=f2, ["ft"]=ft, ["fe"]=fe }
	self:StartPeriodic( )
end

function SongbookWindow:StartPeriodic( )
	self:StartTimer( )
	self.bPeriodicActive = true
end

function SongbookWindow:UpdatePeriodic( )
	local bAllDone = true
	for i = #self.aPeriodic, 1, -1 do
		local p = self.aPeriodic[ i ]
		if p.fe and p.fe( ) then
			if p.ft then p.ft(); end;
			table.remove( self.aPeriodic, i ); break; end
		local ct = Turbine.Engine.GetGameTime()
		if ct > p.nt then
			p.nt = ct + p.t
			p.f1( ); p.f1, p.f2 = p.f2, p.f1
			p.n = p.n - 1
			if p.n <= 0 then table.remove( self.aPeriodic, i ); break; end
		end
		bAllDone = false
	end
	if bAllDone then self:StopPeriodic( ); end
end

function SongbookWindow:StopPeriodic( )
	self.bPeriodicActive = false
	self:StopTimer( )
end

-- Activate message blinking in Update(); call SetWantsUpdates if necessary
function SongbookWindow:StartMessageBlink( )
	local f1 = function( ) self.lblInstrAlert:SetVisible( false ); end
	local f2 = function( ) self.lblInstrAlert:SetVisible( true ); end
	songbookWindow:AddPeriodic( 10, 0.25, f1, f2, f1, function() return self.bInstrumentOk; end )
end

-- Start Timer
function SongbookWindow:StartTimer()
	if not self.bCounterActive and not self.bPeriodicActive then self:SetWantsUpdates( true ); end
end

-- Stop Timer
function SongbookWindow:StopTimer()
	if not self.bCounterActive and not self.bPeriodicActive then self:SetWantsUpdates( false ); end
end

-- Scan track names for durations; take the longest
function SongbookWindow:GetRunningTime()
	local songDuration = 0;
	local item, songTime;
	for i = 1, self.tracklistBox:GetItemCount() do
		item = self.tracklistBox:GetItem( i ); -- attempt to extract a running time from the track name
		local sMinutes, sSeconds = string.match( item:GetText(), ".*%((%d+):(%d+)%).*" ); -- try (mm:ss)
		if ( ( not sMinutes ) or ( not sSeconds ) ) then
			sMinutes, sSeconds = string.match( item:GetText(), ".*(%d+):(%d+).*" ); -- no luck, try just mm:ss, should still be safe
		end
		if ( ( sMinutes ) and ( sSeconds ) and ( tonumber( sMinutes ) < 60 ) and ( tonumber( sSeconds ) < 60 ) ) then
			songTime = sMinutes * 60 + sSeconds;
			if ( songTime > songDuration ) then  -- need longest track
				songDuration = songTime;
			end
		end
	end
	return songDuration
end


------------
-- Search --
------------
-- action to search songs
function SongbookWindow:SearchSongs()
	self.songlistBox:ClearItems();
	local matchFound;
	local nFound = 0;
	self.aFilteredIndices = {};
	for i = 1, librarySize do
		matchFound = false;
		if ( self:ApplyFilters( SongDB.Songs[i] ) == true ) then -- filters are matched, now look for search input
			if ( string.find( string.lower( SongDB.Songs[i].Filename ), string.lower( self.searchInput:GetText() ) ) ~= nil ) then
				matchFound = true;
			elseif SongDB.Songs[i].Tracks then
				for j = 1, #SongDB.Songs[i].Tracks do
					if ( string.find( string.lower( SongDB.Songs[i].Tracks[j].Name ), string.lower( self.searchInput:GetText() ) ) ~= nil ) then
						matchFound = true;
						break;
					end
				end
			end
		end
		if ( matchFound == true ) then
			local songItem = Turbine.UI.Label();
			if ( Settings.DescriptionVisible == "yes" ) then
				songItem:SetText( SongDB.Songs[i].Filename .. " / " .. SongDB.Songs[i].Tracks[1].Name );
			else
				songItem:SetText( SongDB.Songs[i].Filename );
			end
			songItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
			songItem:SetSize( 1000, 20 );
			self.songlistBox:AddItem( songItem );
			nFound = nFound + 1;
			self.aFilteredIndices[nFound] = i; -- Create index redirect table
		end
	end
	--local found = self.songlistBox:GetItemCount();
	if ( nFound > 0 ) then
		self.songlistBox:SetSelectedIndex( 1 ); -- ZEDMOD
		self:SelectSong( 1 );
	else
		self:ClearSongState();
	end
	-- self.separator1.heading:SetText( Strings["ui_songs"] .. " (" .. nFound .. ")" ); -- ZEDMOD: OriginalBB
	self.sepDirsSongs.heading:SetText( Strings["ui_songs"] .. " (" .. nFound .. ")" ); -- ZEDMOD
end

-- action for toggling search function on and off
function SongbookWindow:ToggleSearch( mode )
	if ( ( Settings.SearchVisible == "yes" ) or ( mode == "off" ) ) then
		Settings.SearchVisible = "no";
		self:SetSearch( -20, false );
	else
		Settings.SearchVisible = "yes";
		self:SetSearch( 20, true );
	end
end

function SongbookWindow:SetSearch( delta, bShow )
	self.searchInput:SetVisible( bShow );
	self.searchBtn:SetVisible( bShow );
	self.clearBtn:SetVisible( bShow );
	self.lFYmod = self.lFYmod + delta;
	self.lCYmod = self.lCYmod + delta;
	self.listFrame:SetTop( self.listFrame:GetTop() + delta );
	self.listContainer:SetTop( self.listContainer:GetTop() + delta );
	local windowHeight = self:GetHeight() + delta; -- ZEDMOD
	local containerHeight = self.listContainer:GetHeight(); -- ZEDMOD
	local unallowedHeight = windowHeight - containerHeight; -- ZEDMOD
	self:UpdateMainWindow( unallowedHeight ); -- ZEDMOD
	--self:SetSonglistHeight( self.songlistBox:GetHeight() - delta ); -- ZEDMOD: OriginalBB
	--self:MoveTracklistTop( -delta ); -- ZEDMOD: OriginalBB
end

----------------------
-- Song Description --
----------------------
-- action for toggling description on and off
function SongbookWindow:ToggleDescription()
	if ( Settings.DescriptionVisible == "yes" ) then
		Settings.DescriptionVisible = "no";
	else
		Settings.DescriptionVisible = "yes";
	end
	self.songlistBox:ClearItems();
	self:LoadSongs();
	local found = self.songlistBox:GetItemCount();
	if ( found > 0 ) then
		self.songlistBox:SetSelectedIndex( 1 ); -- ZEDMOD
		self:SelectSong( 1 );
	else
		self:ClearSongState();
	end
end

-- action for toggling description on and off
function SongbookWindow:ToggleDescriptionFirst()
	if ( Settings.DescriptionFirst == "yes" ) then
		Settings.DescriptionFirst = "no";
	else
		Settings.DescriptionFirst = "yes";
	end
	if ( Settings.DescriptionVisible == "yes" ) then
		self.songlistBox:ClearItems();
		self:LoadSongs();
		local found = self.songlistBox:GetItemCount();
		if ( found > 0 ) then
			self.songlistBox:SetSelectedIndex( 1 ); -- ZEDMOD
			self:SelectSong( 1 );
		else
			self:ClearSongState();
		end
	end
end

------------
-- Tracks --
------------
-- action for toggling tracks display on and off
function SongbookWindow:ToggleTracks()
	-- Get Window height and Container height
	local windowHeight = self:GetHeight();
	local containerHeight = self.listContainer:GetHeight();
	local unallowedHeight = windowHeight - containerHeight;
	
	-- If track list is visible
	if ( Settings.TracksVisible == "yes" ) then
		Settings.TracksVisible = "no";
		
		-- Get listboxes height
		local height = self.dirlistBox:GetHeight() + 13 + self.songlistBox:GetHeight() + 13;
		if ( CharSettings.InstrSlots["visible"] == "yes") then
			height = height + self.instrlistBox:GetHeight() + 13;
		end
		
		-- If container height got enough space
		
		if ( height < containerHeight ) then
			-- if songlist height got enough space
			if ( self.bInstrumentsVisibleHForced == false ) then
				if ( self.songlistBox:GetHeight() - 13 - self.tracklistBox:GetHeight() - 13 > 40 ) then
					-- Set songlist height
					local songheight = self.songlistBox:GetHeight() + 13 + self.tracklistBox:GetHeight() + 13;
					self.songlistBox:SetHeight( songheight );
					
					-- ZEDMOD: Set Players list Height
					self.listboxPlayers:SetHeight( songheight - 20 );
					
				-- if songlist height got not enough space
				else
					-- Update window height and container height with more space
					self:UpdateContainer( height );
					self:UpdateMainWindow( unallowedHeight );
					self:SetContainer();
				end
			else
				if ( self.songlistBox:GetHeight() - 13 - self.tracklistBox:GetHeight() - 13 > 40 ) then
					-- Set songlist height
					local songheight = self.songlistBox:GetHeight() + 13 + self.tracklistBox:GetHeight() + 13;
					self.songlistBox:SetHeight( songheight );
					
					-- ZEDMOD: Set Players list Height
					self.listboxPlayers:SetHeight( songheight - 20 );
					
				-- if songlist height got not enough space
				else
					-- Update window height and container height with more space
					self:UpdateContainer( height );
					self:UpdateMainWindow( unallowedHeight );
					self:SetContainer();
				end
			end
		end
		
		-- Set Song List Height
		--self:SetSonglistHeight(self.listContainer:GetHeight() - self.dirlistBox:GetHeight() - 13); -- ZEDMOD: OriginalBB
		
		-- Hide Tracklist
		self:ShowTrackListbox( false );
		
		-- Hide Setups
		self.listboxSetups:SetVisible( false );
		
		-- Set Message Position
		--self.tracksMsg:SetPosition( self.dirlistBox:GetLeft() + self.dirlistBox:GetWidth() - 150, self.dirlistBox:GetTop() + self.dirlistBox:GetHeight() ); -- ZEDMOD: OriginalBB
		
	-- If track list is not visible
	else
		-- Show Tracklist
		Settings.TracksVisible = "yes";
		self:ShowTrackListbox( true );
		
		-- Show Setups
		self.listboxSetups:SetVisible( self.bShowSetups ); -- ZEDMOD: OriginalBB
		
		-- ZEDMOD: Get Song List Height
		local height = self.dirlistBox:GetHeight() + 13 + self.songlistBox:GetHeight() + 13 + self.tracklistBox:GetHeight() + 13;
		if ( CharSettings.InstrSlots["visible"] == "yes" ) then
			height = height + self.instrlistBox:GetHeight() + 13;
		end
	end
	
	-- ZEDMOD: Resize All Elements
	self:ResizeAll();
end

-- ZEDMOD
-----------------
-- Instruments --
-----------------
-- Action for toggling instruments display on and off
function SongbookWindow:ToggleInstruments( bChecked )
	self.bInstrumentsVisible = bChecked;
	
	-- Get Window height and Container height
	local windowHeight = self:GetHeight();
	local containerHeight = self.listContainer:GetHeight();
	local unallowedHeight = windowHeight - containerHeight;
	
	-- If instrument list is visible
	if ( self.bInstrumentsVisible == false ) then
		CharSettings.InstrSlots["visible"] = "no";
		
		-- Get listboxes height
		local height = self.dirlistBox:GetHeight() + 13 + self.songlistBox:GetHeight() + 13;
		if ( Settings.TracksVisible == "yes") then
			height = height + self.tracklistBox:GetHeight() + 13;
		end
		
		-- If container height got enough space
		if ( height < containerHeight ) then
		
		-- if songlist height got enough space
			if ( self.bInstrumentsVisibleHForced == false ) then
				if ( self.songlistBox:GetHeight() - 13 - self.instrlistBox:GetHeight() - 13 > 40 ) then
					-- Set songlist height
					local songheight = self.songlistBox:GetHeight() + 13 + self.instrlistBox:GetHeight() + 13;
					self.songlistBox:SetHeight( songheight );
					
					-- ZEDMOD: Set Players list Height
					self.listboxPlayers:SetHeight( songheight - 20 );
					
				-- if songlist height got not enough space
				else
					-- Update window height and container height with more space
					self:UpdateContainer( height );
					self:UpdateMainWindow( unallowedHeight );
					self:SetContainer();
				end
			else
				if ( self.songlistBox:GetHeight() - 13 - self.instrlistBox:GetHeight() - 13 > 45 ) then
					-- Set songlist height
					local songheight = self.songlistBox:GetHeight() + 13 + self.instrlistBox:GetHeight() + 13;
					self.songlistBox:SetHeight( songheight );
					
					-- ZEDMOD: Set Players list Height
					self.listboxPlayers:SetHeight( songheight - 20 );
					
				-- if songlist height got not enough space
				else
					-- Update window height and container height with more space
					self:UpdateContainer( height );
					self:UpdateMainWindow( unallowedHeight );
					self:SetContainer();
				end
			end
		end
		
		-- Hide Instrlist
		self:ShowInstrListbox( false );
		
	-- If instrument list is not visible
	else
	-- Show Instrlist
		CharSettings.InstrSlots["visible"] = "yes";
		self:ShowInstrListbox( true );
		
		-- ZEDMOD: Get Song List Height
		local height = self.dirlistBox:GetHeight() + 13 + self.songlistBox:GetHeight() + 13 + self.instrlistBox:GetHeight() + 13;
		if ( Settings.TracksVisible == "yes") then
			height = height + self.tracklistBox:GetHeight() + 13;
		end
		
		-- if containerlist got not enough space
		if ( height > containerHeight ) then
			
			-- if songlist got not enough space
			if ( self.songlistBox:GetHeight() == 40 ) then
				-- Update Window height and Container height with more space
				self:UpdateContainer( height );
				self:UpdateMainWindow( unallowedHeight );
				self:SetContainer();
			end
		end
	end
	-- ZEDMOD: Resize All Elements
	self:ResizeAll();
end

-----------------------
-- Instruments Slots --
-----------------------

function SongbookWindow:ClearSlots()
	for i = 1, CharSettings.InstrSlots["number"] do
		CharSettings.InstrSlots[tostring( i )].qsType ="";
		CharSettings.InstrSlots[tostring( i )].qsData = "";
		local sc = Turbine.UI.Lotro.Shortcut( "", "" );
		self.instrSlot[i]:SetShortcut( sc );
	end
end

function SongbookWindow:AddSlot()
	--if ( self:GetWidth() > 10 + ( CharSettings.InstrSlots["number"] + 1 ) * 40 ) then -- ZEDMOD: OriginalBB
	local newslot = tonumber( CharSettings.InstrSlots["number"] ) + 1;
	CharSettings.InstrSlots["number"] = newslot;
	local sNewslot = tostring( newslot )
	self.instrSlot[newslot] = Turbine.UI.Lotro.Quickslot();
	self.instrSlot[newslot]:SetParent( self.instrContainer );
	--self.instrSlot[newslot]:SetPosition( 40 * ( newslot - 1 ), 0 ); -- ZEDMOD: OriginalBB
	self.instrSlot[newslot]:SetSize( 35, 40 ); -- ZEDMOD: OriginalBB value: ( 37, 37 )
	self.instrSlot[newslot]:SetZOrder( 100 );
	self.instrSlot[newslot]:SetAllowDrop( true );
	--self.instrContainer:SetWidth( self.instrContainer:GetWidth() + 40 ); -- ZEDMOD: OriginalBB
	self.instrlistBox:AddItem( self.instrSlot[newslot] ); -- ZEDMOD
	local sc = Turbine.UI.Lotro.Shortcut( "", "" );
	self.instrSlot[newslot]:SetShortcut( sc );
	CharSettings.InstrSlots[sNewslot] = { qsType = "", qsData = "" };
	self.instrSlot[newslot].ShortcutChanged = function( sender, args )
		pcall( function()
			local sc = sender:GetShortcut();
			CharSettings.InstrSlots[sNewslot].qsType = tostring( sc:GetType() );
			CharSettings.InstrSlots[sNewslot].qsData = sc:GetData();
		end );
	end
	self.instrSlot[newslot].DragLeave = function( sender, args )
		if ( instrdrag ) then
			CharSettings.InstrSlots[sNewslot].qsType ="";
			CharSettings.InstrSlots[sNewslot].qsData = "";
			local sc = Turbine.UI.Lotro.Shortcut( "", "" );
			self.instrSlot[newslot]:SetShortcut( sc );
			instrdrag = false;
		end
	end
	self.instrSlot[newslot].MouseDown = function( sender, args )
		if ( args.Button == Turbine.UI.MouseButton.Left ) then
			instrdrag = true;
		end
	end
	--end -- ZEDMOD: OriginalBB
end

function SongbookWindow:DelSlot()
	CharSettings.InstrSlots["number"] = tonumber( CharSettings.InstrSlots["number"] );
	if ( CharSettings.InstrSlots["number"] > 1 ) then
		local delslot = CharSettings.InstrSlots["number"];
		CharSettings.InstrSlots["number"] = CharSettings.InstrSlots["number"] - 1;
		--self.instrContainer:SetWidth( self.instrContainer:GetWidth() - 40 ); -- ZEDMOD: OriginalBB
		self.instrlistBox:RemoveItemAt( delslot ); -- ZEDMOD
		self.instrSlot[delslot] = nil;
		CharSettings.InstrSlots[tostring( delslot )] = nil;
	end
end

--------------------
-- Expand Command --
--------------------
function SongbookWindow:ExpandCmd( cmdId )
	local selTrack = self:SelectedTrackIndex();
	if ( librarySize ~= 0 ) then
		local cmd = Settings.Commands[cmdId].Command;
		if ( SongDB.Songs[selectedSongIndex].Tracks[selTrack] ) then
			cmd = string.gsub( cmd, "%%name", SongDB.Songs[selectedSongIndex].Tracks[selTrack].Name );
			cmd = string.gsub( cmd, "%%file", SongDB.Songs[selectedSongIndex].Filename );
			if ( selTrack ~= 1 ) then
				cmd = string.gsub( cmd, "%%part", selTrack );
			else
				cmd = string.gsub( cmd, "%%part", "" );
			end
		elseif ( SongDB.Songs[selectedSongIndex].Filename ) then
			cmd = string.gsub( cmd, "%%name", SongDB.Songs[selectedSongIndex].Filename );
			cmd = string.gsub( cmd, "%%file", SongDB.Songs[selectedSongIndex].Filename );
			if ( selTrack ~= 1 ) then
				cmd = string.gsub( cmd, "%%part", selTrack );
			else
				cmd = string.gsub( cmd, "%%part", "" );
			end
		else
			cmd = "";
		end
		return cmd;
	end
end

-------------------
-- Save Settings --
-------------------
function SongbookWindow:SaveSettings()
	Settings.WindowPosition.Left = tostring( self:GetLeft() );
	Settings.WindowPosition.Top = tostring( self:GetTop() );
	Settings.WindowPosition.Width = tostring( self:GetWidth() );
	Settings.WindowPosition.Height = tostring( self:GetHeight() );
	Settings.ToggleTop = tostring( Settings.ToggleTop );
	Settings.ToggleLeft = tostring( Settings.ToggleLeft );
	--Settings.DirHeight = tostring( Settings.DirHeight ); -- ZEDMOD: OriginalBB
	Settings.DirHeight = tostring( self.dirlistBox:GetHeight() ); -- ZEDMOD
	--Settings.SongsHeight = tostring( Settings.SongsHeight ); -- ZEDMOD
	Settings.SongsHeight = tostring( self.songlistBox:GetHeight() ); -- ZEDMOD
	--Settings.TracksHeight = tostring( Settings.TracksHeight ); -- ZEDMOD: OriginalBB
	Settings.TracksHeight = tostring( self.tracklistBox:GetHeight() ); -- ZEDMOD
	--Settings.InstrsHeight = tostring( Settings.InstrsHeight ); -- ZEDMOD
	Settings.InstrsHeight = tostring( self.instrlistBox:GetHeight() ); -- ZEDMOD
	Settings.WindowOpacity = tostring( Settings.WindowOpacity );
	Settings.ToggleOpacity = tostring( Settings.ToggleOpacity );
	Settings.FiltersState = tostring( self.bFilter );
	Settings.ChiefMode = tostring( self.bChiefMode );
	Settings.ShowAllBtns = tostring( self.bShowAllBtns );
	Settings.TimerState = tostring( self.bDisplayTimer );
	Settings.TimerCountdown = tostring( self.bTimerCountdown );
	Settings.ReadyColState = tostring( self.bShowReadyChars );
	Settings.ReadyColHighlight = tostring( self.bHighlightReadyCol );
	Settings.PartyState = tostring( self.bParty ); -- ZEDMOD
	for i = 1, CharSettings.InstrSlots["number"] do
		CharSettings.InstrSlots[tostring( i )].qsType = tostring( CharSettings.InstrSlots[tostring( i )].qsType );
	end
	CharSettings.InstrSlots["number"] = tostring( CharSettings.InstrSlots["number"] );
	CharSettings.InstrSlots["visHForced"] = tostring( self.bInstrumentsVisibleHForced ); -- ZEDMOD
	ModifySettings( Settings, tostring )

	SongbookSave( Turbine.DataScope.Account, gSettings, Settings,
		function( result, message )
			if ( result ) then
				Turbine.Shell.WriteLine( SuccessRGB.." Account : " .. Strings["sh_saved"] .. "</rgb>" );
			else
				Turbine.Shell.WriteLine( FailRGB.." Account : " .. Strings["sh_notsaved"] .. " " .. message .. "</rgb>" );
			end
		end );
	SongbookSave( Turbine.DataScope.Character, gSettings, CharSettings,
		function( result, message )
			if ( result ) then
				Turbine.Shell.WriteLine( SuccessRGB.." Character : " .. Strings["sh_saved"] .. "</rgb>" );
			else
				Turbine.Shell.WriteLine( FailRGB.." Character : " .. Strings["sh_notsaved"] .. " " .. message .. "</rgb>" );
			end
		end );
	
	SkillsData:CopyToSD( )
	PriosData:CopyToSD( )
	ServerData:Save( )
end

-------------
-- Filters --
-------------
-- Parse filter string entered by the user.
function SongbookWindow:ParsePartsFilter( sText )
	local sPattern = "[";
	local iEnd = 0;
	local number, numberTo, iEndTo, temp;
	for maxTracks = 1, self.maxTrackCount do
		iEnd = iEnd + 1;
		temp, iEnd, number = string.find( sText, "%s*(%d+)%s*", iEnd );
		if ( iEnd == nil ) then
			break;
		end
		iEnd = iEnd + 1;
		if ( string.sub( sText, iEnd, iEnd ) == "-" ) then
			temp, iEndTo, numberTo = string.find( sText, "%s*(%d+)%s*", iEnd + 1 );
			if ( iEndTo == nil ) then
				numberTo = self.maxTrackCount;
			else
				iEnd = iEndTo + 1;
			end
		else
			numberTo = number;
		end
		for temp = number, numberTo do
			sPattern = sPattern .. string.char( 0x40 + temp ); -- 0x40 is ASCII-code 'A' - 1
		end
	end
	if ( sPattern == "[" ) then
		self.sFilterPartcount = "[a-z]";
	else
		self.sFilterPartcount = sPattern .. "]";
	end
end -- ParsePartsFilter

-- return true if at least one word is in both string lists 
function SongbookWindow:MatchStringList( list1, list2 )
	for word1 in string.gmatch( list1, "%a+" ) do
		for word2 in string.gmatch( list2, "%a+" ) do
			if ( word1 == word2 ) then
				return true;
			end
		end
	end
	return false;
end

-- Check whether the given song fits all the filters that are currently set 
function SongbookWindow:ApplyFilters( songData )
	if ( songData == nil ) then
		return false;
	end
	if ( ( self.cbComposer ) and ( self.cbComposer:IsChecked() ) ) then
		if ( songData.Artist == nil ) then
			return false;
		end
		local sFilter = string.lower( self.editComposer:GetText() );
		if ( ( sFilter ~= "" ) and ( string.find( string.lower( songData.Artist ), sFilter ) == nil ) ) then
			return false;
		end
	end
	if ( ( self.cbPartcount ) and ( self.cbPartcount:IsChecked() ) ) then
		local sFilter = self.editPartcount:GetText();
		if ( sFilter == "" ) then
			if ( not self.maxPartCount ) then
				return true;
			else
				sFilter = "1-" .. tostring( self.maxPartCount );
			end
		end
		if ( songData.Partcounts == nil ) then
			return false;
		end
		self:ParsePartsFilter( sFilter );
		if ( string.match( songData.Partcounts, self.sFilterPartcount ) == nil ) then
			return false; -- Song does not have a setup with an acceptable number of players
		end
	end
	if ( ( self.cbGenre ) and ( self.cbGenre:IsChecked() ) ) then
		if ( songData.Genre == nil ) then
			return false;
		end
		local sFilter = string.lower( self.editGenre:GetText() );
		if ( ( sFilter ~= "" ) and ( not self:MatchStringList( sFilter, string.lower( songData.Genre ) ) ) ) then
		--if ( ( sFiler ~= "" ) and ( string.find( string.lower( songData.Genre ), sFilter ) == nil ) ) then
			return false;
		end
	end
	if ( ( self.cbMood ) and ( self.cbMood:IsChecked() ) ) then
		if ( songData.Mood == nil ) then
			return false;
		end
		local sFilter = string.lower( self.editMood:GetText() );
		if ( ( sFilter ~= "" ) and ( not self:MatchStringList( sFilter, string.lower( songData.Mood ) ) ) ) then
		--if ( ( sFilter ~= "" ) and ( string.find( sFilter, string.lower( songData.Mood ) ) == nil ) ) then
			return false;
		end
	end
	if ( ( self.cbAuthor ) and ( self.cbAuthor:IsChecked() ) ) then
		if ( songData.Transcriber == nil ) then
			return false;
		end
		local sFilter = string.lower( self.editAuthor:GetText() );
		if ( ( sFilter ~= "" ) and ( string.find( sFilter, string.lower( songData.Transcriber ) ) == nil ) ) then
			return false;
		end
	end
	return true;
end -- ApplyFilters

---------------
-- Song List --
---------------
-- Song List : Update
function SongbookWindow:UpdateSongs()
	self.songlistBox:ClearItems();
	local sSearch = self.searchInput:GetText();
	if ( ( sSearch ) and ( sSearch ~= "" ) ) then
		self:SearchSongs();
	else
		self:LoadSongs();
	end
	self:InitSonglist();
end

-- Song List : Initialize Song - List tracks, set/clear chat handler, set headings
function SongbookWindow:InitSonglist()
	local nSongs = self.songlistBox:GetItemCount();
	if ( nSongs > 0 ) then
		self.songlistBox:SetSelectedIndex( 1 ); -- ZEDMOD
		self:SelectSong( 1 );
	else
		self.tracklistBox:ClearItems();
		self:ClearSongState();
		--Turbine.Chat.Received = nil; -- No tracks listed, so deactivate player ready indicator
		self.sepSongsTracks.heading:SetText( Strings["ui_parts"] .. " (0)" );
	end
	self.sepDirsSongs.heading:SetText( Strings["ui_songs"] .. " (" .. nSongs .. ")" );
end

-- Song List : Clear Song State
function SongbookWindow:ClearSongState()
	self.aReadyTracks = "";
	self:ClearPlayerStates();
	self:ClearSetups();
	self:SetTrackColours( selectedTrack );
	self:SetPlayerColours();
end

----------------
-- Track Name --
----------------
-- Create compact track name by removing the title.
-- Note: Many of our older songs have quite different naming schemes; not sure if it's even worth parsing.
function SongbookWindow:TerseTrackname( sTrack )
	return sTrack; -- disabled for now.
end

----------
-- Song --
----------
function SongbookWindow:SongStarted()
	self:ClearSongState();
	if ( self.bInstrumentOk == false ) then
		--self.tracksMsg:SetForeColor( self.colourDefault ); -- ZEDMOD: OriginalBB
		self.lblInstrAlert:SetForeColor( self.colourDefault ); -- ZEDMOD
		--self.trackMsg:SetVisible( false ); -- ZEDMOD: OriginalBB
		self.lblInstrAlert:SetVisible( false ); -- ZEDMOD
		self.bInstrumentOk = true;
	end
	if ( self.bDisplayTimer ) then
		self:StartCounter();
	--else
		--self:StopTimer(); -- in case it is still counting ...
	end
end

------------------
-- Chat Handler --
------------------
-- Handler for chat messages to indicate players readying tracks
function ChatHandler( sender, args )
	local sMessage = args.Message;
	
	if ( args.ChatType == Turbine.ChatType.Tell ) then
		if sMessage:match( "^SB~Sk0~" ) and skillsWindow then skillsWindow:ReceiveData( sMessage ); end
		return
	end
	
	if ( args.ChatType ~= Turbine.ChatType.Standard ) then
		return; -- Player ready messages appear in the standard chat
	end
	
	-- Play Begin or Play Begin Self
	if string.find( sMessage, Strings["chat_playBegin"] ) or string.find( sMessage, Strings["chat_playBeginSelf"] ) then
		songbookWindow:SongStarted();
		return;
	end
	
	-- Player Join
	if ( string.find( sMessage, Strings["chat_playerJoin"] ) ~= nil ) then
		songbookWindow:PlayerJoined( sMessage );
		return;
	end
	
	-- Player Leave
	if ( string.find( sMessage, Strings["chat_playerLeave"] ) ~= nil ) then
		songbookWindow:PlayerLeft( sMessage );
		return;
	end
	
	-- ZEDMOD: Added Player Join Self and Player Leave Self
	-- Player Join Self
	if ( string.find( sMessage, Strings["chat_playerJoinSelf"] ) ~= nil ) then
		songbookWindow:PlayerJoinedSelf( sMessage );
		return;
	end
	
	-- Player Leave Self
	if ( string.find( sMessage, Strings["chat_playerLeaveSelf"] ) ~= nil ) then
		songbookWindow:PlayerLeftSelf( sMessage );
		return;
	end
	
	-- (Nim) added player dismissed case (TODO: This message parsing really needs to be simplified)
	if ( string.find( sMessage, Strings["chat_playerDismissSelf"] ) ~= nil ) then
		songbookWindow:PlayerDismissedSelf( sMessage )
		return;
	end
	if ( string.find( sMessage, Strings["chat_playerDismiss"] ) ~= nil ) then
		songbookWindow:PlayerDismissed( sMessage )
		return;
	end
	
	if ( string.find( sMessage, Strings["chat_playerLinkDead"] ) ~= nil ) then
		songbookWindow:PlayerLinkDead( sMessage )
		return;
	end
	
	local temp, sPlayerName, sTrackName;
	temp, temp, sPlayerName, sTrackName = string.find( sMessage, Strings["chat_playReadyMsg"] );
	if ( ( not sPlayerName ) or ( not sTrackName ) ) then
		
		-- Get Local Player Instance
		--sPlayerName = songbookWindow.sPlayerName -- ZEDMOD: OriginalBB
		if ( songbookWindow ~= nil ) then
			sPlayerName = songbookWindow.sPlayerName -- ZEDMOD: OriginalBB
		end
		temp, temp, sTrackName = string.find( sMessage, Strings["chat_playSelfReadyMsg"] ); -- ZEDMOD: OriginalBB
	end
	
	if ( ( sPlayerName ) and ( sTrackName ) and ( songbookWindow.aPlayers ) ) then
		if ( ( sPlayerName == songbookWindow.sPlayerName ) and ( songbookWindow.sPlayerName ) ) then
			--songbookWindow:StopTimer(); -- in case it is still counting ...
			sPlayerName = songbookWindow.sPlayerName;
			if ( ( songbookWindow.bCheckInstrument ) and ( sTrackName ) ) then
				--songbookWindow:CheckInstrument( sTrackName ); -- ZEDMOD: OriginalBB
				CheckInstruments( sTrackName ); -- ZEDMOD: in instrumentsz.lua
			end
		end
		if ( not songbookWindow.aPlayers[sPlayerName] ) then -- Player not yet registered 
			songbookWindow.nPlayers = songbookWindow.nPlayers + 1;
			songbookWindow:AddPlayerToList( sPlayerName ); -- add to player listbox
			songbookWindow:UpdateMaxPartCount();
		end
		songbookWindow.aPlayers[sPlayerName] = sTrackName; -- and to player array with the track name
		songbookWindow:SetTrackColours( selectedTrack );
		songbookWindow:SetPlayerColours();
		songbookWindow:UpdateSetupColours();
	end
end


--------------
-- Party UI --
--------------
-- ZEDMOD: Create the Party UI elements: Edit boxes for player count
function SongbookWindow:CreatePartyUI( args )
	self:CreatePartyListbox();
end

---------------
-- Setups UI --
---------------
function SongbookWindow:CreateSetupsUI( args )
	self:CreateSetupsListbox();
end

---------------
-- Filter UI --
---------------
-- Create the filter UI elements: Edit boxes for player count, transcriber, mood, genre
function SongbookWindow:CreateFilterUI()
	self.editPartcount = self:CreateFilterEdit( 13 );
	self.cbPartcount = self:CreateFilterCheckbox( 13, Strings["filterParts"] );
	self.cbPartcount.CheckedChanged = function( sender, args )
		--self:SetMaxPartCount( sender:IsChecked() );
		self:UpdateSongs();
	end
	self.editComposer = self:CreateFilterEdit( 33 );
	self.cbComposer = self:CreateFilterCheckbox( 33, Strings["filterArtist"] );
	self.editGenre = self:CreateFilterEdit( 53 );
	self.cbGenre = self:CreateFilterCheckbox( 53, Strings["filterGenre"] );
	self.editMood = self:CreateFilterEdit( 73 );
	self.cbMood = self:CreateFilterCheckbox( 73, Strings["filterMood"] );
	self.editAuthor = self:CreateFilterEdit( 93 );
	self.cbAuthor = self:CreateFilterCheckbox( 93, Strings["filterAuthor"] );
	-- Separator filters - dir listbox
	self.separatorFilters = Turbine.UI.Control();
	self.separatorFilters:SetParent( self.listContainer );
	self.separatorFilters:SetBackColor( self.colorListFrame );
	self.separatorFilters:SetPosition( 156, self.dirlistBox:GetTop() + 13 );
	self.separatorFilters:SetSize( 10, self.dirlistBox:GetHeight() );
	self.separatorFilters:SetVisible( false );
	
	-- Listbox
	--self:CreatePartyListbox(); -- ZEDMOD: OriginalBB
	--self:CreateSetupsListbox(); -- ZEDMOD: OriginalBB
end

-- create a filter edit
function SongbookWindow:CreateFilterEdit( par_yPos, par_fn )
	local edit = Turbine.UI.Lotro.TextBox();
	edit:SetParent( self.listContainer );
	edit:SetPosition( 0, par_yPos );
	edit:SetSize( 80, 20 );
	edit:SetFont( Turbine.UI.Lotro.Font.Verdana14 );
	edit:SetMultiline( false );
	edit:SetVisible( false );
	--edit.FocusLost = par_fn;
	edit.KeyDown = function( sender, keyargs )
		if ( keyargs.Action == 162 ) then
			--if ( edit:HasFocus() ) then
			self:UpdateSongs();
			--end
		end
	end
	return edit;
end

-- Create a filter checkbox
function SongbookWindow:CreateFilterCheckbox( par_yPos, par_sText )
	-- search button
	local cb = Turbine.UI.Lotro.CheckBox();
	cb:SetParent( self.listContainer );
	cb:SetPosition( 82, par_yPos );
	cb:SetSize( 80, 20 );
	cb:SetText( par_sText );
	cb.CheckedChanged = function( sender, args )
		self:UpdateSongs();
	end
	cb:SetVisible( false );
	return cb;
end

-- Switch between filter UI display (true) and track listbox (false)
function SongbookWindow:ShowFilterUI( bFilter )
	self.bFilter = bFilter;
	
	self.editPartcount:SetVisible( bFilter );
	self.cbPartcount:SetVisible( bFilter );
	self.editComposer:SetVisible( bFilter );
	self.cbComposer:SetVisible( bFilter );
	self.editGenre:SetVisible( bFilter );
	self.cbGenre:SetVisible( bFilter );
	self.editMood:SetVisible( bFilter );
	self.cbMood:SetVisible( bFilter );
	self.editAuthor:SetVisible( bFilter );
	self.cbAuthor:SetVisible( bFilter );
	
	self.separatorFilters:SetVisible( bFilter );
	
	self:AdjustFilterUI();
	self:AdjustDirlistPosition( 0 );
end

-- ZEDMOD: Show Players list Party UI
function SongbookWindow:ShowPartyUI( bParty )
	self.bParty = bParty;
	--self.separatorParty:SetVisible( bParty ); -- ZEDMOD: OriginalBB
	self.btnParty:SetVisible( bParty );
	self.listboxPlayers:SetVisible( bParty );
	self.btnbox:SetVisible( bParty ); -- ZEDMOD
	self:AdjustPartyUI();
	self:AdjustSonglistPosition( self.dirlistBox:GetHeight() + 13 );
	--self:ResizeAll(); -- ZEDMOD: OriginalBB
end

-- Reposition the filter UI for dir listbox size changes
function SongbookWindow:AdjustFilterUI()
	if ( not self.bFilter ) then
		return;
	end
	local dirHeight = self.dirlistBox:GetHeight();
	if ( dirHeight < 40 ) then
		dirHeight = 40;
	end
	self.editAuthor:SetVisible( dirHeight >= 93 );
	self.cbAuthor:SetVisible( dirHeight >= 93 );
	self.editMood:SetVisible( dirHeight >= 73 );
	self.cbMood:SetVisible( dirHeight >= 73 );
	self.editGenre:SetVisible( dirHeight >= 53 );
	self.cbGenre:SetVisible( dirHeight >= 53 );
	self.separatorFilters:SetHeight( dirHeight );
end

-- Reposition the Party UI for song listbox size changes
function SongbookWindow:AdjustPartyUI()
	if ( not self.bParty ) then
		return;
	end
	--if ( not self.cbFilters:IsChecked() ) then
		--return;
	--end
	local songheight = self.songlistBox:GetHeight();
	if ( songheight < 40 ) then
		songheight = 40;
	end
	--self.separatorParty:SetHeight( songheight ); -- ZEDMOD: OriginalBB
end

-------------------------------
-- Set Instrument Message    --
-------------------------------
function SongbookWindow:SetInstrumentMessage( sInstr )
	if ( self.bInstrumentOk or sInstr == nil ) then
		self:SetTextModeNormal( self.lblInstrAlert )
		self.lblInstrAlert:SetVisible( false ); -- ZEDMOD
	else
		self:SetTextModeAlert( self.lblInstrAlert )
		--self.lblInstrAlert:SetForeColor( self.colourWrongInstrument ); -- ZEDMOD
		self.lblInstrAlert:SetText( Strings["instr"]..sInstr ); -- ZEDMOD
		self.lblInstrAlert:SetVisible( true ); -- ZEDMOD
		self:StartMessageBlink( )
	end
end

------------
-- Player --
------------

function SongbookWindow:UpdatePlayerCount( )
	self.nPlayers = self.listboxPlayers:GetItemCount()
	self.btnParty:SetText( tostring( self.nPlayers ).." "..Strings["players"] )
	PartyMembers:Update( self.aPlayers )
end

local function PartyPlayerMenu( sender, args )
	local lbParent = songbookWindow.listboxPlayers
	if args.Button ~= Turbine.UI.MouseButton.Right then return; end
	
	local contextMenu = Turbine.UI.ContextMenu();
	local menuItems = contextMenu:GetItems( )
	local id = lbParent:IndexOfItem( sender )
	
	menuItems:Add( ListBox.CreateMenuItem( Strings["asn_addPlayer"], id,
		function( s, a ) ListBox.PlayerEntry( lbParent, 100, 20 ); end ) )

	menuItems:Add( ListBox.CreateMenuItem( Strings["asn_removePlayer"], id,
		function( s, a ) songbookWindow:RemovePlayerAt( s.ID ); songbookWindow:UpdatePlayerCount( ); end ) )

	contextMenu:ShowMenu( )
end

-- Add player to the fellowship list
function SongbookWindow:AddPlayerToList( sPlayername )
	if self.listboxPlayers == nil then return; end -- Listbox not created yet
	
	local memberItem = Turbine.UI.Label();
	memberItem:SetText( sPlayername );
	memberItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
	memberItem:SetSize( 100, 20 );
	memberItem.MouseClick = PartyPlayerMenu
	if sPlayername == self.sLeaderName then memberItem:SetFont( Turbine.UI.Lotro.Font.TrajanPro14 ); end
	self.listboxPlayers:AddItem( memberItem );
end

-- Remove player from the fellowship list
function SongbookWindow:RemovePlayerFromList( sPlayername )
	if self.listboxPlayers == nil then return; end -- Listbox not created yet
	local iDel, item = self:GetItemFromList( self.listboxPlayers, sPlayername );
	if not iDel then return; end
	self.listboxPlayers:RemoveItemAt( iDel );
end

-- Get index and item for player name from player listbox
function SongbookWindow:GetItemFromList( listbox, sText )
	local item;
	for i = 1, listbox:GetItemCount() do
		item = listbox:GetItem( i );
		if ( item:GetText() == sText ) then
			return i, item;
		end
	end
	return nil, nil;
end

----------------------------
-- Player : Ready Columns --
----------------------------
-- Enable Ready Columns
function SongbookWindow:EnableReadyColumns( bOn )
	self.listboxPlayers:EnableCharColumn( bOn );
	self.tracklistBox:EnableCharColumn( bOn );
end

-- Show Ready Columns
function SongbookWindow:ShowReadyColumns( bShow )
	if ( self.bShowReadyChars == bShow ) then
		return;
	end
	self.bShowReadyChars = bShow;
	self:EnableReadyColumns( bShow );
	if ( selectedSongIndex ) then
		--self:ListTracks( selectedSongIndex );
		--self:RefreshPlayerListbox();
		self:SetTrackColours( selectedTrack );
		self:SetPlayerColours();
	end
end

-- Hightlight Ready Columns
function SongbookWindow:HightlightReadyColumns( bOn )
	self.listboxPlayers.bHighlightReadyCol = bOn;
	self.tracklistBox.bHighlightReadyCol = bOn;
end

---------------------------
-- Player : Party Member --
---------------------------
-- Read party member names and add them to the party members listbox
-- TODO: Party object does not seem to report party members correctly?
function SongbookWindow:RefreshPlayerListbox()
	if ( self.listboxPlayers == nil ) then return; end
	
	self.listboxPlayers:ClearItems();
	
	local player = self:GetPlayer( ) --Turbine.Gameplay.LocalPlayer:GetInstance();
	if ( self.sPlayerName == nil ) then self.sPlayerName = player:GetName(); end
	
	local party = player:GetParty();
	if ( party == nil or party:GetMemberCount() <= 0 ) then
		self:AddPlayerToList( self.sPlayerName );
		self.aPlayers[ self.sPlayerName ] = 0;
		self:UpdatePlayerCount( )
		return;
	end
	
	-- ZEDMOD: Player Party : Get Leader
	local partyLeader = party:GetLeader();
	self.sLeaderName = partyLeader:GetName();
	
	--if ( self.bChiefMode ) then
	if self.sPlayerName == self.sLeaderName then
		self.aPlayers = {};
		self.aCurrentSongReady = {};
	else
		self:ListKnownPlayers( party );
	end
	
	self:ListPartyObjectPlayers( party )
		
	self:SetPlayerColours(); -- restore current states
	self:UpdateMaxPartCount();
	if ( self.maxPartCount ) then
		self:UpdateSongs();
	end
	self:UpdateSetupColours();
	self:UpdatePlayerCount( )
end


local function PartyChanged( s, a ) if songbookWindow then songbookWindow:PartyChanged( a ); end; end
local function RaidChanged( s, a ) if songbookWindow then songbookWindow:RaidChanged( a ); end; end
local function IsLinkDeadChanged( s, a ) if songbookWindow then songbookWindow:IsLinkDeadChanged( a ); end; end

function SongbookWindow:SetPlayerEvents( )
	self.player = self:GetPlayer( )
	if not self.player then return; end
	self.player.PartyChanged = PartyChanged
	self.player.RaidChanged = RaidChanged
	self.player.IsLinkDeadChanged = IsLinkDeadChanged
	self:GetParty( )
	if self.party then self:SetPartyEvents( ); end
end

function SongbookWindow:PartyChanged( args )
	local bHadParty = self.party ~= nil
	self.party = self:RenewParty( )
	
	if self.party then self:PartyJoinedEvent( ); if bHadParty then self:RaidSwitch( ); end
	else self:PartyLeftEvent( ); self:ResetParty( ); end
INFO( "+++ PartyChanged" )
	self:RelistPlayers( )
end

function SongbookWindow:RaidChanged( args )
	local raid = self:GetRaid( )
INFO( "+++ RaidChanged" )
end

function SongbookWindow:RaidSwitch( )
INFO( "+++ RaidSwitch" ); 
end

function SongbookWindow:IsLinkDeadChanged( args )
INFO( "+++ LinkDeadChanged" )
end

local function LeaderChanged( s, a ) if songbookWindow then songbookWindow:ChangeLeader( ); end; end
local function MemberAdded( s, a ) if songbookWindow then songbookWindow:MemberAdded( a ); end; end
local function MemberRemoved( s, a ) if songbookWindow then songbookWindow:MemberRemoved( a ); end; end

function SongbookWindow:SetPartyEvents( )
	self.party = self.party or self:GetParty( )
	if not self.party then return; end
	self.party.LeaderChanged = LeaderChanged
	self.party.MemberAdded = MemberAdded
	self.party.MemberRemoved = MemberRemoved
end

function SongbookWindow:ChangeLeader( )
	local party = self:GetParty( )
	if not party or not party:GetLeader( ) then return; end
	local sNewLeader = party:GetLeader( ):GetName( )
	
	for i = 1, self.listboxPlayers:GetItemCount( ) do
		local item = self.listboxPlayers:GetItem( i )
		if item then
			if item:GetText( ) == sNewLeader then
				item:SetFont( Turbine.UI.Lotro.Font.TrajanPro14 ); item:SetText( sNewLeader )
			elseif item:GetText( ) == self.sLeaderName then
				item:SetFont( Turbine.UI.Lotro.Font.LucidaConsole12 ); item:SetText( self.sLeaderName )
			end
		end
	end
	self.sLeaderName = sNewLeader
end

function SongbookWindow:MemberAdded( args )
INFO( "+++ MemberAdded" )--..PrintTable(self.player) )--.."\n args were "..PrintTable(args) )
end

function SongbookWindow:MemberRemoved( args )
INFO( "+++ MemberRemoved" )--..PrintTable(self.player) )--.."\n args were "..PrintTable(args) )
end

function SongbookWindow:PartyJoinedEvent( )
INFO( "+++ Party joined" )
end

function SongbookWindow:PartyLeftEvent( )
INFO( "+++ Party left" )
end

function SongbookWindow:RaidChanged( )
INFO( "+++ RaidChanged" )
	self:RefreshPlayerListbox( )
end

function SongbookWindow:IsLinkDeadChanged( )
INFO( "+++ IsLinkDeadChanged" )
	self:RelistPlayers( )
end


function SongbookWindow:GetPlayer( )
	self.player = self.player or Turbine.Gameplay.LocalPlayer:GetInstance()
	if not self.player then 
INFO( "### WARN: LocalPlayer:GetInstance failed." )
		return nil
	end
	if not self.sPlayerName then self.sPlayerName = self.player:GetName( ); end
	return self.player
end

function SongbookWindow:GetParty( )
	self:GetPlayer( )
	if not self.player then self:ResetParty( ); return nil; end
	self.party = self.party or self.player:GetParty( )
	if self.party then return self.party; end
--INFO( "### WARN: GetParty failed." )
	return nil
end

function SongbookWindow:RenewParty( )
	self:GetPlayer( )
	if not self.player then self:ResetParty( ); return nil; end
	if self.party then
		self:ResetParty( )
	end
	self.party = self.player:GetParty( )
	if not self.party then
--INFO( "### WARN: player:GetParty failed." )
		return nil
	end
	self:SetPartyEvents( )
	self:ListPartyObjectPlayers( )
	return self.party
end

function SongbookWindow:ResetParty( )
--INFO( "+++ Party reset" )
	self.party = nil
	self.aPlayers = {};
	self.aCurrentSongReady = {};
end

function SongbookWindow:ListPartyObjectPlayers( party )
	party = party or self:GetParty( )
	for iPlayer = 1, party:GetMemberCount( ) do
		local member = party:GetMember( iPlayer );
		local sName = member:GetName( );
		if ( self.aPlayers[ sName ] == nil ) then self:AddPlayer( sName )
		end
	end
end

function SongbookWindow:RelistPlayers( ) -- from aPlayers
	if not self.listboxPlayers then return; end
	self.listboxPlayers:ClearItems();
	
	local player = self:GetPlayer( ) --Turbine.Gameplay.LocalPlayer:GetInstance();
	if not player then return; end
	
	local party = player:GetParty(); -- TODO: is this necessary?
	if not party or party:GetMemberCount() <= 0 then
		self:AddPlayerToList( self.sPlayerName );
		self.aPlayers[self.sPlayerName] = 0;
		self:UpdatePlayerCount( )
		return;
	end
	
	self:ListKnownPlayers( party );
	
	self:SetTrackColours( selectedTrack );
	self:SetPlayerColours(); -- restore current states
	self:UpdateMaxPartCount();
	if ( self.maxPartCount ) then
		self:UpdateSongs();
	end
	self:UpdateSetupColours();
	self:UpdatePlayerCount( )
end

-- Add player to arrays
function SongbookWindow:AddPlayer( sName )
	if self.aPlayers[ sName ] then return; end
	self.aCurrentSongReady[ sName ] = false;
	self:AddPlayerToList( sName );
	self.aPlayers[ sName ] = 0;
end

-- Remove player from arrays
function SongbookWindow:RemovePlayer( sName )
	if ( not self.aPlayers[sName] ) then
		return;
	end
	self.aCurrentSongReady[ sName ] = nil;
	self:RemovePlayerFromList( sName );
	self.aPlayers[ sName ] = nil;
end

function SongbookWindow:RemovePlayerAt( i )
	if not self.listboxPlayers then return; end
	local item = self.listboxPlayers:GetItem( i )
	if item then self:RemovePlayer( item:GetText( ) ); end
end

-- Write known players to player listbox
function SongbookWindow:ListKnownPlayers( party )
	if ( not self.aPlayers ) then
		return;
	end
	
	for key, value in pairs( self.aPlayers ) do
		self:AddPlayerToList( key );
	end
	self:UpdatePlayerCount( )
end

-- Parse player join message, add player
function SongbookWindow:PlayerJoined( sMsg )
	local sPlayerName = string.match( sMsg, "(%a+)"..Strings["chat_playerJoin"] );
	if sPlayerName then self:AddPlayer( sPlayerName ); end
	self:RelistPlayers( );
end

-- ZEDMOD:
function SongbookWindow:PlayerJoinedSelf( sMsg )
	local _, _, sPlayerName = string.find( sMsg, "(%a+)" .. Strings["chat_playerJoinSelf"] );
	self:RefreshPlayerListbox( )
end

-- Parse player left message, remove player
function SongbookWindow:PlayerLeft( sMsg )
	local _, _, sPlayerName = string.find( sMsg, "(%a+)" .. Strings["chat_playerLeave"] );
	if sPlayerName then self:RemovePlayer( sPlayerName ); end
	self:RelistPlayers( );
end

-- 'you dismissed player'
function SongbookWindow:PlayerDismissedSelf( sMsg )
	local sPlayerName = string.match( sMsg, Strings["chat_playerDismissSelf"].."(%a+)" );
	if sPlayerName then self:RemovePlayer( sPlayerName ); end
	self:RelistPlayers( );
end

-- 'player was dismissed'
function SongbookWindow:PlayerDismissed( sMsg )
	local sPlayerName = string.match( sMsg, "(%a+)"..Strings["chat_playerDismiss"] );
	if sPlayerName then self:RemovePlayer( sPlayerName ); end
	self:RelistPlayers( );
end

function SongbookWindow:PlayerLinkDead( sMsg )
	local sPlayerName = string.match( sMsg, "(%a+)"..Strings["chat_playerLinkDead"] )
	if sPlayerName and assignWindow then
		local iPlayer = Players:Index( sPlayerName )
		assignWindow.lbAssigns:MarkPlayer( iPlayer, Marks.tag.inactive )
	end
end

-- ZEDMOD:
-- Parse player left message, remove player
function SongbookWindow:PlayerLeftSelf( sMsg )
	local temp, sPlayerName, sTrackName;
	temp, temp, sPlayerName = string.find( sMsg, "(%a+)" .. Strings["chat_playerLeaveSelf"] );
	self:RefreshPlayerListbox( );
end


-- Clear the ready states for players
function SongbookWindow:ClearPlayerStates()
	if ( not self.aPlayers ) then
		return;
	end
	for key in pairs( self.aPlayers ) do
		self.aPlayers[key] = 0; -- present, no song ready
	end
end

-- Update item colours in party listbox to indicate ready states
function SongbookWindow:SetPlayerColours()
	if ( ( not self.aPlayers ) or ( not self.listboxPlayers ) ) then
		return;
	end
	for iMember = 1, self.listboxPlayers:GetItemCount() do
		local item = self.listboxPlayers:GetItem( iMember );
		if ( self.aPlayers[item:GetText()] == nil ) then -- should not happen
			item:SetForeColor( self.colourDefault );
			if ( self.bShowReadyChars ) then
				self.listboxPlayers:SetColumnChar( iMember, self.chNone, false );
			end
		elseif ( self.aPlayers[item:GetText()] == 0 ) then -- present, but no song ready
			item:SetForeColor( self.colourDefault );
			if ( self.bShowReadyChars ) then
				self.listboxPlayers:SetColumnChar( iMember, self.chNone, false );
			end
		elseif ( ( self.aCurrentSongReady ) and ( self.aCurrentSongReady[item:GetText()] == 1 ) ) then
			item:SetForeColor( self.colourReady ); -- Track from the currently displayed song ready
			if ( self.bShowReadyChars ) then
				self.listboxPlayers:SetColumnChar( iMember, self.chReady, false );
			end
		elseif ( ( self.aCurrentSongReady ) and ( self.aCurrentSongReady[item:GetText()] == 2 ) ) then
			item:SetForeColor( self.colourReadyMultiple ); -- Correct song, but same track as another player
			if ( self.bShowReadyChars ) then
				self.listboxPlayers:SetColumnChar( iMember, self.chMultiple, true );
			end
		elseif ( ( self.aCurrentSongReady ) and ( self.aCurrentSongReady[item:GetText()] == 3 ) ) then
			item:SetForeColor( self.colourDifferentSetup ); -- Correct song, but track not in current setup
			if ( self.bShowReadyChars ) then
				self.listboxPlayers:SetColumnChar( iMember, self.chWrongPart, true );
			end
		else
			item:SetForeColor( self.colourDifferentSong ); -- Track ready, but different song
			if ( self.bShowReadyChars ) then
				self.listboxPlayers:SetColumnChar( iMember, self.chWrongSong, true );
			end
		end
	end
end


local function PartyListboxMenu( sender, args )
	if args.Button ~= Turbine.UI.MouseButton.Right then return; end
	
	local contextMenu = Turbine.UI.ContextMenu()
	local menuItems = contextMenu:GetItems( )
	
	menuItems:Add( ListBox.CreateMenuItem( Strings["asn_addPlayer"], nil,
		function( s, a ) ListBox.PlayerEntry( sender, 100, 20 ); end ) )

	contextMenu:ShowMenu( )
end


local function LbPlayers_LbCb_AddPlayer( self, sPlayer )
	songbookWindow:AddPlayer( sPlayer )
end

local function LbPlayers_LbCb_PlayersEntered( self, n )
	songbookWindow:UpdatePlayerCount( )
end

local function LbPlayer_AddPlayer( self, sPlayer )
	local item = Turbine.UI.Label();
	item:SetText( sPlayer );
	item:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
	item:SetSize( 100, 20 );
	item.MouseClick = PartyPlayerMenu
	self:AddItem( item )
	return item
end

-- Create party member listbox
function SongbookWindow:CreatePartyListbox()
	local songHeight = self.songlistBox:GetHeight();
	local songTop = self.songlistBox:GetTop();
	self.listboxPlayers = ListBoxCharColumn:New( 10, 10, false, 20 );
	self.listboxPlayers:SetParent( self.listContainer );
	self.listboxPlayers:SetSize( 80, songHeight - 20 );
	self.listboxPlayers:SetPosition( 2 , songTop + 20 );
	self.listboxPlayers:SetVisible( false );
	self.listboxPlayers.MouseClick = PartyListboxMenu
	self.listboxPlayers.AddPlayer = LbPlayer_AddPlayer
	self.listboxPlayers.LbCb_AddPlayer = LbPlayers_LbCb_AddPlayer
	self.listboxPlayers.LbCb_PlayersEntered = LbPlayers_LbCb_PlayersEntered
	
	-- ZEDMOD: Add a background control with grey color
	self.btnbox = Turbine.UI.Control();
	self.btnbox:SetParent( self.listContainer );
	self.btnbox:SetPosition( 0 , songTop );
	self.btnbox:SetSize( 92, 20);
	self.btnbox:SetBackColor( self.colorListFrame );
	self.btnbox:SetVisible( false );
	
	-- Button to update party member list
	self.btnParty = Turbine.UI.Lotro.Button();
	self.btnParty:SetParent( self.listContainer ); -- ZEDMOD: Original
	self.btnParty:SetPosition( 2, songTop ); -- ZEDMOD: Original value: ( 0, songTop )
	self.btnParty:SetSize( 80, 20 ); -- ZEDMOD: Original value: ( 92, 20 )
	self.btnParty:SetText( Strings["players"] );
	self.btnParty:SetVisible( false );
	self.btnParty.MouseClick = function( sender, args )
		self:RefreshPlayerListbox( );
	end
	self:AdjustPartyUI();
	self:AdjustSonglistPosition( songTop );
end

-- Use the number of currently listed players as limit for part counts
function SongbookWindow:SetMaxPartCount( bActivate )
	--self:RefreshPlayerListbox();
	if ( ( bActivate ) and ( self.listboxPlayers ) ) then
		self.maxPartCount = self.listboxPlayers:GetItemCount();
	else
		self.maxPartCount = nil;
	end
end

-- Due to party object issues, we only increase partcount here
function SongbookWindow:UpdateMaxPartCount()
	if ( ( self.maxPartCount ) and ( self.listboxPlayers ) and ( self.maxPartCount < self.listboxPlayers:GetItemCount() ) ) then
		self.maxPartCount = self.listboxPlayers:GetItemCount();
	end
end

--------------------
-- listbox Setups --
--------------------
-- Create listbox to show the possible setup counts
function SongbookWindow:CreateSetupsListbox()
	self.listboxSetups = ListBoxScrolled:New( 10 );
	self.listboxSetups:SetParent( self.listContainer );
	self.listboxSetups:SetSize( self.listboxSetupsWidth - 0, self.tracklistBox:GetHeight() );
	self.listboxSetups:SetPosition( 0, self.tracklistBox:GetTop() );
	self.listboxSetups:SetVisible( self.bShowSetups );
	self.listboxSetups.SelectedIndexChanged = function( sender, args )
		self:ListTracksForSetup( sender:GetSelectedIndex() );
	end
end

-- Select Setup
function SongbookWindow:SelectSetup( iSetup )
	if ( not self.listboxSetups ) then
		return;
	end
	if ( ( not iSetup ) or ( iSetup > self.listboxSetups:GetItemCount() ) ) then
		iSetup = self.listboxSetups:GetItemCount();
	end
	self.listboxSetups:SetSelectedIndex( iSetup );
	self:ListTracksForSetup( iSetup );

	if not songbookWindow then return; end
	local song = SongDB.Songs[ selectedSongIndex ]
	self.aUix = nil
	if song then self.aUix = Assigner:GetSongUix( song, nil, true ); end
	self:SetInstrLabelActive( self.aUix ~= nil, "SelectSetup("..tostring(iSetup)..")" )
	--if iSetup == self.listboxSetups:GetItemCount( ) then ; end
end

-- List Tracks for Setup
function SongbookWindow:ListTracksForSetup( iSetup )
	local song = SongDB.Songs[selectedSongIndex]
	if not song or not song.Setups then return; end
	for iItem = 1, self.listboxSetups:GetItemCount() do
		self.listboxSetups:GetItem( iItem ):SetBackColor( self.backColourDefault );
	end
	local selTrack = self.tracklistBox:GetSelectedIndex();
	self.aSetupTracksIndices = {};
	self.aSetupListIndices = {};
	self.iCurrentSetup = nil;
	if not iSetup or iSetup >= self.listboxSetups:GetItemCount() then
		self:ListTracks( selectedSongIndex );
		self.selectedSetupCount = nil;
	else
		self.iCurrentSetup = iSetup;
		self.tracklistBox:ClearItems();
		for i = 1, #song.Setups[iSetup] do
			local iTrack = song.Setups[iSetup]:byte( i ) - 64;
			self.aSetupTracksIndices[i] = iTrack;
			self.aSetupListIndices[iTrack] = i;
			self:AddTrackToList( selectedSongIndex, iTrack );
		end
		self.selectedSetupCount = #song.Setups[iSetup];
		self.aUix = Assigner:GetSongUix( song, iSetup )
	end
	local selItem = self.listboxSetups:GetSelectedItem( );
	if ( selItem ) then
		selItem:SetBackColor( self.backColourHighlight );
	end
	self:SelectTrack( 1 );
	self:SetPlayerColours();
	local found = self.tracklistBox:GetItemCount();
	self.sepSongsTracks.heading:SetText( Strings["ui_parts"] .. " (" .. found .. ")" );
	self:SetInstrLabelActive( self.aUix ~= nil, "ListTracksForSetup" ) --iSetup ~= self.listboxSetups:GetItemCount( )
end

function SongbookWindow:HasSetups( iSong )
	iSong = iSong or selectedSongIndex
	return SongDB.Songs[iSong] and SongDB.Songs[iSong].Setups
end

function SongbookWindow:SetupIndexForCount( iSong, setupCount )
	if ( ( not setupCount ) or ( not SongDB.Songs[iSong] ) or ( not SongDB.Songs[iSong].Setups ) ) then
		return nil;
	end
	for i = 1, #SongDB.Songs[iSong].Setups do
		if ( setupCount == #SongDB.Songs[iSong].Setups[i] ) then
			return i;
		end
	end
	return nil;
end

-- Update Setup Colours
function SongbookWindow:UpdateSetupColours()
	if ( ( not self.listboxSetups ) or ( not SongDB.Songs[selectedSongIndex] ) or ( not SongDB.Songs[selectedSongIndex].Setups ) ) then
		return;
	end
	self:UpdateTrackReadyString();
	local item, matchPattern, antiMatchPattern, _
	local matchLength = 0
	for i = 1, self.listboxSetups:GetItemCount() - 1 do
		item = self.listboxSetups:GetItem( i );
		local sSetup = SongDB.Songs[selectedSongIndex].Setups[i]
		if not sSetup or #sSetup == 0 then break; end
		matchPattern = "[" .. sSetup .. "]";
		antiMatchPattern = "[^" .. sSetup .. "]";
		_, matchLength = string.gsub( self.aReadyTracks, matchPattern, " " );
		if ( SongDB.Songs[selectedSongIndex].Setups[i] == self.aReadyTracks ) then
			item:SetForeColor( self.colourReady );
		elseif ( string.match( self.aReadyTracks, antiMatchPattern ) ) then
			item:SetForeColor( Turbine.UI.Color( 0.7, 0, 0 ) );
		elseif ( ( matchLength ) and ( matchLength + 1 == #SongDB.Songs[selectedSongIndex].Setups[i] ) ) then
			item:SetForeColor( Turbine.UI.Color( 0, 0.7, 0 ) );
		else
			item:SetForeColor( self.colourDefault );
		end
	end
end

-- Clear Setups
function SongbookWindow:ClearSetups()
	if ( not self.listboxSetups ) then
		return;
	end
	local selItem = self:SetListboxColours( self.listboxSetups, true );
	if ( selItem ) then
		selItem:SetBackColor( self.backColourHighlight );
	end
end

-- Update Track Ready String
function SongbookWindow:UpdateTrackReadyString()
	self.aReadyTracks = "";
	for iList = 1, self.tracklistBox:GetItemCount() do
		local i = self:SelectedTrackIndex( iList );
		if ( self:GetTrackReadyState( SongDB.Songs[selectedSongIndex].Tracks[i].Name ) ) then
			self.aReadyTracks = self.aReadyTracks .. string.char( 0x40 + i );
		end
	end
end

-- Add an item with the given text to the given listbox
function SongbookWindow:AddItemToList( sText, listbox, width )
	if ( listbox == nil ) then
		return;
	end -- Listbox not created yet
	local item = Turbine.UI.Label();
	item:SetText( sText );
	item:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleCenter );
	item:SetSize( width, 20 );
	listbox:AddItem( item );
end

-- List Setups
function SongbookWindow:ListSetups( songID )
	if ( ( not self.listboxSetups ) or ( not self.listboxPlayers ) ) then
		return;
	end
	self.listboxSetups:ClearItems();
	if ( ( not SongDB ) or ( not SongDB.Songs[songID] ) or ( not SongDB.Songs[songID].Setups ) ) then
		self:ShowSetups( false );
		return;
	end
	if ( self.tracklistBox:IsVisible() ) then
		self:ShowSetups( true );
	else
		self.bShowSetups = true;
	end
	local playerCount;
	if ( not self.maxPartCount ) then
		playerCount = 1000;
	else
		playerCount = self.maxPartCount;
	end
	--playerCount = 6;
	local countInSetup;
	for i = 1, #SongDB.Songs[songID].Setups do
		countInSetup = #SongDB.Songs[songID].Setups[i];
		if ( countInSetup <= playerCount ) then
			self:AddItemToList( countInSetup, self.listboxSetups, self.listboxSetupsWidth );
		end
	end
	--self:AddItemToList( "#P", self.listboxSetups, self.listboxSetupsWidth );
	self:AddItemToList( "A", self.listboxSetups, self.listboxSetupsWidth );
end

-- Get Track Ready State
-- Return a track state indicator:
-- nil = track not ready, name of a player = ready by this player, 0 = ready by more than one player
function SongbookWindow:GetTrackReadyState( sTrackName, indicator )
	local found = nil;
	local readyIndicator = 1;
	if ( indicator ) then
		readyIndicator = indicator;
	end
	if ( self.aPlayers ~= nil ) then
		for key, value in pairs( self.aPlayers ) do
			if ( value == string.sub( sTrackName, 1, 63 ) ) then
				if ( found == nil ) then
					found = key;
					self.aCurrentSongReady[key] = readyIndicator; -- track ready
				else
					self.aCurrentSongReady[key] = 2; -- track ready, but by other player too
					if ( found ~= 0 ) then
						self.aCurrentSongReady[found] = 2; -- set for other player as well
						found = 0;
					end
				end
			end
		end
	end
	return found; -- nil if not ready, player name if ready once, 0 if ready more than once
end

-- Clear Player Ready States
function SongbookWindow:ClearPlayerReadyStates()
	if ( self.aPlayers ~= nil ) then
		for key, value in pairs( self.aPlayers ) do
			self.aCurrentSongReady[key] = false;
		end
	end
end

--------------------
-- Set Chief Mode --
--------------------
function SongbookWindow:SetChiefMode( bState )
	self.bChiefMode = ( bState == true );
	self.syncStartSlot:SetVisible( self.bChiefMode );
	self.syncStartIcon:SetVisible( self.bChiefMode );
	self.btnAssign:SetVisible( self.bChiefMode )
end

function SongbookWindow:ShowAllButtons( bState )
	self.bShowAllBtns = bState
	self.shareSlot:SetVisible( bState )
	self.shareIcon:SetVisible( bState )
	self.readySlot:SetVisible( bState )
	self.readyIcon:SetVisible( bState )
	self.trackLabel:SetVisible( bState )
	self.trackNumber:SetVisible( bState )
	
	local song = SongDB.Songs[selectedSongIndex]
	if not song or not selectedTrack then return; end
	self.trackPrev:SetVisible( bState and ( selectedTrack > 1 ) )
	self.trackNext:SetVisible( bState and ( selectedTrack < #song.Tracks ) )
end	

-- ZEDMOD
-------------------------------------------
-- Instruments Visible Horizontal Forced --
-------------------------------------------
function SongbookWindow:InstrumentsVisibleHForced( bOn )
	
	-- Get Main Window Height and Container Height
	local windowHeight = self:GetHeight();
	local containerHeight = self.listContainer:GetHeight();
	local unallowedHeight = windowHeight - containerHeight;
	self.bInstrumentsVisibleHForced = bOn;
	if ( self.bInstrumentsVisibleHForced == false ) then
		self.sArrows3:SetVisible( true );
		self.instrlistBox.scrollBarv:SetVisible( true );
		self.instrlistBox.scrollBarh:SetVisible( false );
		
		-- Get Container Height
		containerHeight = containerHeight - 10;
		
		-- Set Container Height
		self.listContainer:SetHeight( containerHeight );
		
		-- Get New Window Height
		local newwindowHeight = self.listContainer:GetHeight() + unallowedHeight;
		
		-- Set New Window Height
		self:SetHeight( newwindowHeight );
		
		-- Set Controls
		self:SetSBControls();
		
		-- Set Container
		self:SetContainer();
		
		-- Adjust Instrument Slot
		self:AdjustInstrumentSlots();
		
	else
		self.sArrows3:SetVisible( false );
		self.instrlistBox.scrollBarv:SetVisible( false );
		self.instrlistBox.scrollBarh:SetVisible( true );
		self:ResizeAll();
	end
end

---------------------
-- ListBoxScrolled --
---------------------
-- Listbox with scrollbar and separator
-- Listbox Scrolled : New
function ListBoxScrolled:New( scrollWidth, scrollHeight, bOrientation, listbox )
	listbox = listbox or ListBoxScrolled( scrollWidth, scrollHeight, bOrientation );
	setmetatable( listbox, self );
	self.__index = self;
	return listbox;
end

-- Listbox Scrolled : Constructor
function ListBoxScrolled:Constructor( scrollWidth, scrollHeight, bOrientation )
	Turbine.UI.ListBox.Constructor( self );
	self:SetMouseVisible( true ); -- Turbine.UI.ListBox.SetMouseVisible( self, true );
	self:CreateChildScrollbar( scrollWidth, scrollHeight, bOrientation );
	self:CreateChildSeparator( scrollWidth, scrollHeight, bOrientation );
end

-- 
function ListBoxScrolled:Initialize( listbox, scrollWidth, scrollHeight, bOrientation )
	self.CreateChildScrollbar( listbox, scrollWidth, scrollHeight, bOrientation );
	self.CreateChildSeparator( listbox, scrollWidth, scrollHeight, bOrientation );
end

-- Listbox Scrolled : Child Scrollbar
function ListBoxScrolled:CreateChildScrollbar( width, height, bOrientation )
	self.scrollBarv = Turbine.UI.Lotro.ScrollBar();
	self.scrollBarv:SetParent( self:GetParent() );
	self.scrollBarv:SetOrientation( Turbine.UI.Orientation.Vertical );
	self.scrollBarv:SetZOrder( 320 );
	self.scrollBarv:SetWidth( width );
	self.scrollBarv:SetTop( 0 );
	self.scrollBarv:SetValue( 0 );
	self:SetVerticalScrollBar( self.scrollBarv );
	self.scrollBarv:SetVisible( false );
	
	-- ZEDMOD: Horizontal Scrollbar for Instrument Slots
	if ( bOrientation ) then
		self.scrollBarh = Turbine.UI.Lotro.ScrollBar();
		self.scrollBarh:SetParent( self:GetParent() );
		self.scrollBarh:SetOrientation( Turbine.UI.Orientation.Horizontal );
		self.scrollBarh:SetZOrder( 320 );
		self.scrollBarh:SetHeight( height );
		self.scrollBarh:SetTop( height );
		self.scrollBarh:SetValue( 0 );
		self:SetHorizontalScrollBar( self.scrollBarh );
		self.scrollBarh:SetVisible( false );
	end
end

-- Listbox Scrolled : Child Separator
function ListBoxScrolled:CreateChildSeparator( width, height, bOrientation )
	self.separatorv = Turbine.UI.Control();
	self.separatorv:SetParent( self:GetParent() );
	self.separatorv:SetZOrder( 310 );
	self.separatorv:SetWidth( width );
	self.separatorv:SetTop( 0 );
	self.separatorv:SetBackColor( Turbine.UI.Color(1, 0.15, 0.15, 0.15) );
	self.separatorv:SetVisible( false );
	
	-- ZEDMOD: Horizontal Separator for Instrument Slots
	if ( bOrientation ) then
		self.separatorh = Turbine.UI.Control();
		self.separatorh:SetParent( self:GetParent() );
		self.separatorh:SetZOrder( 310 );
		self.separatorh:SetHeight( height );
		self.separatorh:SetTop( height );
		self.separatorh:SetBackColor( Turbine.UI.Color(1, 0.15, 0.15, 0.15) );
		self.separatorh:SetVisible( false );
	end
end

-- Listbox Scrolled : Set Left Position (x Position)
function ListBoxScrolled:SetLeft( xPos )
	Turbine.UI.ListBox.SetLeft( self, xPos );
	self.scrollBarv:SetLeft( xPos + self:GetWidth() );
	self.separatorv:SetLeft( xPos + self:GetWidth() );
	
	-- ZEDMOD: Horizontal Scrollbar
	if ( self.scrollBarh ) then
		self.scrollBarh:SetLeft( xPos );
		self.separatorh:SetLeft( xPos );
	end
end

-- Listbox Scrolled : Set Top Position (y Position)
function ListBoxScrolled:SetTop( yPos )
	Turbine.UI.ListBox.SetTop( self, yPos );
	self.scrollBarv:SetTop( yPos );
	self.separatorv:SetTop( yPos );
	
	-- ZEDMOD: Horizontal Scrollbar
	if ( self.scrollBarh ) then
		self.scrollBarh:SetTop( yPos + self:GetHeight() );
		self.separatorh:SetTop( yPos + self:GetHeight() );
	end
end

-- Listbox Scrolled : Set Position
function ListBoxScrolled:SetPosition( xPos, yPos )
	self:SetLeft( xPos );
	self:SetTop( yPos );
end

-- Listbox Scrolled : Set Width
function ListBoxScrolled:SetWidth( width )
	Turbine.UI.ListBox.SetWidth( self, width );
	self.scrollBarv:SetLeft( self:GetLeft() + width );
	self.separatorv:SetLeft( self:GetLeft() + width );
	
	-- ZEDMOD: Horizontal Scrollbar
	if ( self.scrollBarh ) then
		self.scrollBarh:SetLeft( self:GetLeft() );
		self.scrollBarh:SetWidth( width );
		self.separatorh:SetLeft( self:GetLeft() );
		self.separatorh:SetWidth( width );
	end
end

-- Listbox Scrolled : Set Height
function ListBoxScrolled:SetHeight( height )
	Turbine.UI.ListBox.SetHeight( self, height );
	self.scrollBarv:SetHeight( height );
	self.separatorv:SetHeight( height );
	
	-- ZEDMOD: Horizontal Scrollbar
	if ( self.scrollBarh ) then
		self.scrollBarh:SetTop( height );
		self.separatorh:SetTop( height );
	end
end

-- Listbox Scrolled : Set Size
function ListBoxScrolled:SetSize( width, height )
	self:SetWidth( width );
	self:SetHeight( height );
end

-- Listbox Scrolled : Set Visible
function ListBoxScrolled:SetVisible( bVisible )
	Turbine.UI.ListBox.SetVisible( self, bVisible );
	self.scrollBarv:SetVisible( bVisible );
	self.separatorv:SetVisible( bVisible );
	
	-- ZEDMOD: Horizontal Scrollbar
	if ( self.scrollBarh ) then
		self.scrollBarh:SetVisible( bVisible );
		self.separatorh:SetVisible( bVisible );
	end
	
	if ( bVisible ) then
		self.scrollBarv:SetParent( self:GetParent() );
		if ( self.scrollBarh ) then
			self.scrollBarh:SetParent( self:GetParent() );
		end
	else
		self.scrollBarv:SetParent( self );
		if ( self.scrollBarh ) then
			self.scrollBarh:SetParent( self );
		end
	end
end

-- Listbox Scrolled : Set Parent
function ListBoxScrolled:SetParent( parent )
--Turbine.Shell.WriteLine( "ListBoxScrolled:SetParent" );
	Turbine.UI.ListBox.SetParent( self, parent );
	self.scrollBarv:SetParent( parent );
	self.separatorv:SetParent( parent );
	
	-- ZEDMOD: Horizontal Scrollbar
	if ( self.scrollBarh ) then
		self.scrollBarh:SetParent( parent );
		self.separatorh:SetParent( parent );
	end
end

-----------------------------
-- ListBox Ready Indicator
-- A scroll listbox with an optional single-char column before the main column
-----------------------------
-- Listbox Char Column : New
function ListBoxCharColumn:New( scrollWidth, scrollHeight, bOrientation, readyColWidth, listbox )
	listbox = listbox or ListBoxCharColumn( scrollWidth, scrollHeight, bOrientation, readyColWidth );
	setmetatable( listbox, self );
	self.__index = self;
	return listbox;
end

-- Listbox Char Column : Constructor
function ListBoxCharColumn:Constructor( scrollWidth, scrollHeight, bOrientation, readyColWidth )
	ListBoxScrolled.Constructor( self, scrollWidth, scrollHeight, bOrientation ); -- , readyColWidth
	self.readyColWidth = readyColWidth;
	self.bShowReadyChars = false;
	self.bHighlightReadyCol = false;
end

-- Listbox Char Column : Enable Char Column
function ListBoxCharColumn:EnableCharColumn( bColumn )
	if ( self.bShowReadyChars == bColumn ) then
		return;
	end
	self.bShowReadyChars = bColumn;
	if ( ListBoxScrolled.GetItemCount( self ) == 0 ) then
		return;
	end
	local itemCount = ListBoxScrolled.GetItemCount( self );
	if ( bColumn ) then -- Add a char item before every item in the list
		for iList = 1, itemCount * 2, 2 do
			local chItem = self:CreateCharItem();
			ListBoxScrolled.InsertItem( self, iList, chItem );
		end
		self:SetMaxItemsPerLine( 2 );
	else -- remove every item with odd index (the char items)
		for iList = 1, itemCount / 2 do
			ListBoxScrolled.RemoveItemAt( self, iList );
		end
		self:SetMaxItemsPerLine( 1 );
	end
end

-- Listbox Char Column : Get Item
function ListBoxCharColumn:GetItem( iLine )
	if self.bShowReadyChars then
		iLine = iLine * 2;
	end
	return ListBoxScrolled.GetItem( self, iLine );
end

-- Listbox Char Column : Get Char Column Item
function ListBoxCharColumn:GetCharColumnItem( iLine )
	if ( not self.bShowReadyChars ) then
		return nil;
	end
	return ListBoxScrolled.GetItem( self, iLine * 2 - 1 );
end

function ListBoxCharColumn:IndexOfItem( item )
	local i = ListBoxScrolled.IndexOfItem( self, item )
	if not i then return nil; end
	return self.bShowReadyChars and math.floor( i / 2 ) or i
end

-- Listbox Char Column : Set Column Char
function ListBoxCharColumn:SetColumnChar( iLine, ch, bHighlight )
	local charItem = self:GetCharColumnItem( iLine );
	if ( charItem ) then
		self:ApplyHighlight( charItem, bHighlight );
		charItem:SetText( ch );
	end
end

-- Listbox Char Column : Apply Highlight
function ListBoxCharColumn:ApplyHighlight( charItem, bHighlight )
	if ( ( bHighlight ) and ( self.bHighlightReadyCol ) ) then
		charItem:SetForeColor( Turbine.UI.Color( 1, 0, 0, 0 ) );
		charItem:SetBackColor( Turbine.UI.Color( 1, 0.7, 0.7, 0.7 ) );
	else
		charItem:SetForeColor( Turbine.UI.Color( 1, 1, 1, 1 ) );
		charItem:SetBackColor( Turbine.UI.Color( 1, 0, 0, 0 ) );
	end
end

-- Listbox Char Column : Get Item Count
function ListBoxCharColumn:GetItemCount()
	if ( self.bShowReadyChars ) then
		return math.floor( ListBoxScrolled.GetItemCount( self ) / 2 );
	end
	return ListBoxScrolled.GetItemCount( self );
end

-- Listbox Char Column : Clear Items
function ListBoxCharColumn:ClearItems()
	ListBoxScrolled.ClearItems( self );
	if ( self.bShowReadyChars ) then 
		self:SetMaxItemsPerLine( 2 );
	else
		self:SetMaxItemsPerLine( 1 );
	end
	self:SetOrientation( Turbine.UI.Orientation.Horizontal );
end

-- Listbox Char Column : Create Char Item
function ListBoxCharColumn:CreateCharItem()
	local charItem = Turbine.UI.Label();
	charItem:SetMultiline( false );
	charItem:SetSize( self.readyColWidth, 20 );
	charItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleCenter );
	self:ApplyHighlight( charItem, false );
	return charItem;
end

-- Listbox Char Column : Add Item
function ListBoxCharColumn:AddItem( item )
	if ( self.bShowReadyChars ) then -- add ready indicator (single char in first column)
		local charItem = self:CreateCharItem();
		ListBoxScrolled.AddItem( self, charItem );
	end
	ListBoxScrolled.AddItem( self, item );
end

-- Listbox Char Column : Remove Item At
function ListBoxCharColumn:RemoveItemAt( i )
	if ( self.bShowReadyChars ) then
		ListBoxScrolled.RemoveItemAt( self, i * 2 );
		ListBoxScrolled.RemoveItemAt( self, i * 2 - 1 );
	else
		ListBoxScrolled.RemoveItemAt( self, i );
	end
end

function ListBoxCharColumn:RemoveItem( item )
	self:RemoveItemAt( self:IndexOfItem( item ) )
end

-- Listbox : Set Colours
function SongbookWindow:SetListboxColours( listbox, bNoSelectionHighlight )
	for i = 1, listbox:GetItemCount() do
		local item = listbox:GetItem( i );
		item:SetForeColor( self.colourDefault );
	end
	if ( bNoSelectionHighlight ) then
		return nil;
	end 
	local selectedItem = listbox:GetSelectedItem();
	if ( selectedItem ) then
		selectedItem:SetForeColor( self.colourDefaultHighlighted );
	end
	return selectedItem;
end

-----------------------
-- Listbox Separator --
-----------------------
-- Listbox : Create Main Separator
function SongbookWindow:CreateMainSeparator( top )
	return self:CreateSeparator( 0, top, self.listContainer:GetWidth(), 13 );
end

-- Listbox : Create Separator
function SongbookWindow:CreateSeparator( left, top, width, height )
	local separator = Turbine.UI.Control();
	separator:SetParent( self.listContainer );
	separator:SetZOrder( 310 );
	separator:SetBackColor( self.colorListFrame );
	separator:SetPosition( left, top );
	separator:SetSize( width, height );
	separator:SetVisible( false );
	return separator;
end

-- Listbox : Create Separator Heading
function SongbookWindow:CreateSeparatorHeading( parent, sText )
	local heading = Turbine.UI.Label();
	heading:SetParent( parent );
	heading:SetLeft( 0 );
	heading:SetSize( 100, 13 );
	heading:SetFont( Turbine.UI.Lotro.Font.TrajanPro13 );
	heading:SetText( sText );
	heading:SetMouseVisible( false );
	return heading;
end

-- Listbox : Create Separator Arrows
function SongbookWindow:CreateSeparatorArrows( parent )
	local arrows = Turbine.UI.Control();
	arrows:SetParent( parent );
	arrows:SetZOrder( 300 );
	arrows:SetBackground( gDir .. "arrows.tga" );
	arrows:SetSize( 20, 10 );
	arrows:SetPosition( parent:GetWidth() / 2 - 10, 1 );
	arrows:SetMouseVisible( false );
	return arrows;
end

----------------------------
-- Button : Main Shortcut --
----------------------------
-- Create Main Shorcut
function SongbookWindow:CreateMainShortcut( left )
	local slot = Turbine.UI.Lotro.Quickslot();
	slot:SetParent( self );
	slot:SetPosition( left, 50 );
	slot:SetSize( 32, 30 );
	slot:SetZOrder( 100 );
	slot:SetAllowDrop( false );
	slot:SetVisible( true );
	return slot;
end
------------------------
-- Button : Main Icon --
------------------------
-- Listbox : Create Main Icon
function SongbookWindow:CreateMainIcon( left, sImageName )
	local icon = Turbine.UI.Control();
	icon:SetParent( self );
	icon:SetPosition( left, 50 );
	icon:SetSize( 35, 35 );
	icon:SetZOrder( 110 );
	icon:SetMouseVisible( false );
	icon:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	icon:SetBackground( gDir .. sImageName .. ".tga" );
	return icon;
end


--------------
-- Dir List --
--------------

-- Listbox : Adjust Dirlist Position
function SongbookWindow:AdjustDirlistPosition( dirlistpos )
	local xPos = 0;
	if ( self.bFilter ) then
		xPos = xPos + 170;
	end
	self.sepDirs:SetTop( dirlistpos ); -- ZEDMOD
	self.sepDirs:SetWidth( self.listContainer:GetWidth() ); -- ZEDMOD
	self.dirlistBox:SetPosition( xPos , dirlistpos + 13 ); -- ZEDMOD
	self.dirlistBox:SetWidth( self.listContainer:GetWidth() - xPos - 10 );
end

----------------
-- Songs List --
----------------

-- ZEDMOD
-- Listbox : Adjust Songlist Position
function SongbookWindow:AdjustSonglistPosition( songlistpos )
	local xPos = 0;
	if ( self.bParty ) then
		xPos = xPos + 95;
	end
	self.sepDirsSongs:SetTop( songlistpos );
	self.sepDirsSongs:SetWidth( self.listContainer:GetWidth() );
	self.sArrows1:SetLeft( self.sepDirsSongs:GetWidth() / 2 - 10 );
	self.songlistBox:SetPosition( xPos , songlistpos + 13 );
	self.songlistBox:SetWidth( self.listContainer:GetWidth() - xPos - 10 );
	self.btnParty:SetTop( songlistpos + 13 );
	self.listboxPlayers:SetTop( songlistpos + 33 );
	self.btnbox:SetTop( songlistpos + 13 );
end

-- Listbox : Adjust Songlist Left
function SongbookWindow:AdjustSonglistLeft()
	local xPos = 0;
	if ( ( self.bParty ) and ( self.bShowPlayers ) ) then
		xPos = xPos + 95;
	end
	self.songlistBox:SetLeft( xPos );
	self.songlistBox:SetWidth( self.listContainer:GetWidth() - xPos - 10 );
end

-----------------
-- Tracks List --
-----------------
-- ZEDMOD
function SongbookWindow:AdjustTracklistPosition( tracklistpos )
	local width = self.listContainer:GetWidth() - 10;
	if ( self.bShowSetups ) then
		width = width - self.setupsWidth;
	end
	self.sepSongsTracks:SetTop( tracklistpos );
	self.sepSongsTracks:SetWidth( self.listContainer:GetWidth() );
	self.sArrows2:SetLeft( self.sepSongsTracks:GetWidth() / 2 - 10 );
	if ( self.alignTracksRight == true ) then
		self:RealignTracknames();
	end
	self.listboxSetups:SetTop( tracklistpos + 13 );
	self.tracklistBox:SetTop( tracklistpos + 13 );
	self.tracklistBox:SetWidth( width );
end

-- Listbox : Show Tracklist Listbox
function SongbookWindow:ShowTrackListbox( bShow )
	self.tracklistBox:SetVisible( bShow );
	self.sepSongsTracks:SetVisible( bShow );
	self.sArrows2:SetVisible( bShow );
end

-- Listbox : Adjust Tracklist Left
function SongbookWindow:AdjustTracklistLeft()
	if ( self.bShowSetups ) then
		self.tracklistBox:SetLeft( self.setupsWidth );
	else
		self.tracklistBox:SetLeft( 0 );
	end
end

-- Listbox : Adjust Tracklist Width
function SongbookWindow:AdjustTracklistWidth()
	local width = self.listContainer:GetWidth() - 10;
	if ( self.bShowSetups ) then
		width = width - self.setupsWidth;
	end
	self.tracklistBox:SetWidth( width );
	if ( self.alignTracksRight == true ) then
		self:RealignTracknames();
	end
	self.sepSongsTracks:SetWidth( self.listContainer:GetWidth() );
	self.sArrows2:SetLeft( self.sepSongsTracks:GetWidth() / 2 - 10 );
	--self.tracksMsg:SetLeft( self.tracklistBox:GetLeft() + width - self.tracksMsg:GetWidth() ) -- ZEDMOD: OriginalBB
end

----------------------
-- Instruments List --
----------------------
-- ZEDMOD: Adjust Instrument list Position
function SongbookWindow:AdjustInstrlistPosition( instrlistpos )
	self.sepTracksInstrs:SetTop( instrlistpos );
	self.sepTracksInstrs:SetWidth( self.listContainer:GetWidth() );
	self.sArrows3:SetLeft( self.sepTracksInstrs:GetWidth() / 2 - 10 );
	self.instrlistBox:SetTop( instrlistpos + 13 );
	self.instrlistBox:SetWidth( self.listContainer:GetWidth() - 10 );
end

-- ZEDMOD: Show Instrument list
function SongbookWindow:ShowInstrListbox( bShow )
	self.instrlistBox:SetVisible( bShow );
	self.sepTracksInstrs:SetVisible( bShow );
	if ( self.bInstrumentsVisibleHForced == false ) then
		self.sArrows3:SetVisible( true );
		self.instrlistBox.scrollBarv:SetVisible( true );
		self.instrlistBox.scrollBarh:SetVisible( false );
	else
		self.sArrows3:SetVisible( false );
		self.instrlistBox.scrollBarv:SetVisible( false );
		self.instrlistBox.scrollBarh:SetVisible( true );
	end
end

-- ZEDMOD: Move Instrumentlist Top when Toggle Search On/Off
function SongbookWindow:MoveInstrlistTop( delta )
	self:SetInstrlistTop( self.instrlistBox:GetTop() + delta );
end

-- ZEDMOD: Set Instrumentlist Top when Toggle Search On/Off
function SongbookWindow:SetInstrlistTop( top )
	self.instrlistBox:SetTop( top );
	self.sepTracksInstrs:SetTop( top - 13 );
	self.listboxSetups:SetTop( top );
end

--------------------------
-- Setups : Show Setups --
--------------------------
function SongbookWindow:ShowSetups( bShow )
	if ( ( bShow ) and ( not self.bShowSetups ) ) then
		self.bShowSetups = true;
		self.listboxSetups:SetVisible( true );
		self:AdjustTracklistLeft();
		self:AdjustTracklistWidth();
	elseif ( ( not bShow ) and ( self.bShowSetups ) ) then
		self.bShowSetups = false;
		self.listboxSetups:ClearItems();
		self.listboxSetups:SetVisible( false );
		self:AdjustTracklistLeft();
		self:AdjustTracklistWidth();
	end
end

-----------------------------
-- ZEDMOD: Dir list Resize --
-----------------------------
function SongbookWindow:ResizeDirlist()
	-- Get Dir list Height
	local dirlistheight = self:DirlistGetHeight();
	
	-- Set Dir list Height
	self.dirlistBox:SetHeight( dirlistheight );
	
	-- Adjust Dir list Position
	self:AdjustDirlistPosition( 0 );
	
	-- Adjust FilterUI
	self:AdjustFilterUI();
end

------------------------------
-- ZEDMOD: Song list Resize --
------------------------------
function SongbookWindow:ResizeSonglist()
	-- Get Song list Height
	local songlistheight = self:SonglistGetHeight();
	
	-- Set Song list Height
	self.songlistBox:SetHeight( songlistheight );
	
	-- Adjust Song list Left
	--self:AdjustSonglistLeft();
	
	-- Set Players list Height
	self.listboxPlayers:SetHeight( songlistheight - 20 );
	
	-- Set Song list Position
	local songlistpos = self.dirlistBox:GetHeight() + 13;
	
	-- Adjust Song list Position
	self:AdjustSonglistPosition( songlistpos );
end

----------------------------
-- ZEDMOD: Get Min Height --
----------------------------
function SongbookWindow:GetMinHeight()
	local minheight = 0;
	if ( ( Settings.TracksVisible == "yes" ) and ( CharSettings.InstrSlots["visible"] == "no" ) ) then
		minheight = self.minHeight + 53; -- (40+13) result = 347
	elseif ( ( Settings.TracksVisible == "yes" ) and ( CharSettings.InstrSlots["visible"] == "yes" ) ) then
		if ( self.bInstrumentsVisibleHForced == false ) then
			minheight = self.minHeight + 106; -- (40+13+40+13) result = 400
		else
			minheight = self.minHeight + 116; -- (40+13+50+13) result = 410
		end
	elseif ( ( Settings.TracksVisible == "no" ) and ( CharSettings.InstrSlots["visible"] == "yes" ) ) then
		if ( self.bInstrumentsVisibleHForced == false ) then
			minheight = self.minHeight + 53; -- (40+13) result = 347
		else
			minheight = self.minHeight + 63; -- (50+13) result = 357
		end
	else
		minheight = self.minHeight; -- result = 304
	end
	return minheight;
end

---------------------------------
-- ZEDMOD: Get Dir list Height --
---------------------------------
function SongbookWindow:DirlistGetHeight()
	local dirlistheight = self.listContainer:GetHeight() - 13 - self.songlistBox:GetHeight() - 13;
	if ( ( Settings.TracksVisible == "yes" ) and ( CharSettings.InstrSlots["visible"] == "no") ) then
		dirlistheight = dirlistheight - self.tracklistBox:GetHeight() - 13;
	elseif ( ( Settings.TracksVisible == "yes" ) and ( CharSettings.InstrSlots["visible"] == "yes") ) then
		dirlistheight = dirlistheight - self.tracklistBox:GetHeight() - 13 - self.instrlistBox:GetHeight() - 13;
	elseif ( ( Settings.TracksVisible == "no" ) and ( CharSettings.InstrSlots["visible"] == "yes") ) then
		dirlistheight = dirlistheight - self.instrlistBox:GetHeight() - 13;
	end
	if ( ( self.bInstrumentsVisibleHForced == true ) and ( CharSettings.InstrSlots["visible"] == "yes" ) ) then
		dirlistheight = dirlistheight - 10;
	end
	if ( dirlistheight < 40 ) then
		dirlistheight = 40;
	end
	return dirlistheight;
end

----------------------------------
-- ZEDMOD: Get Song list Height --
----------------------------------
function SongbookWindow:SonglistGetHeight()
	local songlistheight = self.listContainer:GetHeight() - 13 - self.dirlistBox:GetHeight() - 13 ;
	if ( ( Settings.TracksVisible == "yes" ) and ( CharSettings.InstrSlots["visible"] == "no") ) then
		songlistheight = songlistheight - self.tracklistBox:GetHeight() - 13;
	elseif ( ( Settings.TracksVisible == "yes" ) and ( CharSettings.InstrSlots["visible"] == "yes") ) then
		songlistheight = songlistheight - self.tracklistBox:GetHeight() - 13 - self.instrlistBox:GetHeight() - 13;
	elseif ( ( Settings.TracksVisible == "no" ) and ( CharSettings.InstrSlots["visible"] == "yes") ) then
		songlistheight = songlistheight - self.instrlistBox:GetHeight() - 13;
	end
	if ( ( self.bInstrumentsVisibleHForced == true ) and ( CharSettings.InstrSlots["visible"] == "yes" ) ) then
		songlistheight = songlistheight - 10;
	end
	if ( songlistheight < 40 ) then
		songlistheight = 40;
	end
	return songlistheight;
end

-----------------------------------
-- ZEDMOD: Get Track list Height --
-----------------------------------
function SongbookWindow:TracklistGetHeight()
	local tracklistheight = self.listContainer:GetHeight() - 13 - self.dirlistBox:GetHeight() - 13 - self.songlistBox:GetHeight() - 13;
	if ( CharSettings.InstrSlots["visible"] == "yes" ) then
		tracklistheight = tracklistheight - self.instrlistBox:GetHeight() - 13;
	end
	if ( ( self.bInstrumentsVisibleHForced == true ) and ( CharSettings.InstrSlots["visible"] == "yes" ) ) then
		tracklistheight = tracklistheight - 10;
	end
	if ( tracklistheight < 40 ) then
		tracklistheight = 40;
	end
	return tracklistheight;
end

----------------------------------------
-- ZEDMOD: Get Instrument list Height --
----------------------------------------
function SongbookWindow:InstrlistGetHeight()
	local instrlistheight = self.listContainer:GetHeight() - 13 - self.dirlistBox:GetHeight() - 13 - self.songlistBox:GetHeight() - 13;
	if ( Settings.TracksVisible == "yes" ) then
		instrlistheight = instrlistheight - self.tracklistBox:GetHeight() - 13;
	end
	if ( ( instrlistheight < 40 ) or ( self.bInstrumentsVisibleHForced == true ) ) then
		instrlistheight = 40;
	end
	return instrlistheight;
end

---------------------------------------------------------------------
-- ZEDMOD: Set Main Window Elements Position after a window resize --
---------------------------------------------------------------------
function SongbookWindow:SetSBControls()
	--self.resizeCtrl:SetPosition( self:GetWidth() - 20, self:GetHeight() - 20 );
	self:MoveButtonRow() --self.btnSettings:SetPosition( self:GetWidth() / 2 - 55, self:GetHeight() - 30 );
	--self.cbFilters:SetPosition( self:GetWidth() / 2 + 65, self:GetHeight() - 30 );
	self.tipLabel:SetLeft( self:GetWidth() - 270 );
	--self.songTitle:SetWidth( self:GetWidth() - 50 ); -- ZEDMOD: OriginalBB
	self.songTitle:SetWidth( self:GetWidth() - 35 ); -- ZEDMOD;
	self.lblInstrAlert:SetWidth( -10 + self:GetWidth( ) - 10 );
	self.lblInstrAlert:SetPosition( 10, self.yListFrame - 7 );
	self.lblInstr:SetWidth( -10 + self:GetWidth( ) - 2 - 12 - 13 )
	self.lblInstr:SetPosition( 10, self.yListFrame + 9 );
	self.instrSelDrop:SetPosition( 11 + self.lblInstr:GetWidth( ) + 2, self.yListFrame + 14 );
	self.lblTimer:SetPosition( self:GetWidth() - 10 - self.lblTimer:GetWidth(), self.yListFrame - 28 )
end

--------------------------------------------------------------------------
-- ZEDMOD: Set List Frame and List Container size after a window resize --
--------------------------------------------------------------------------
function SongbookWindow:SetContainer()
	-- Set Lists Frame Size
	self.listFrame:SetSize( self:GetWidth() - self.lFXmod, self:GetHeight() - self.lFYmod );
	
	-- Set Lists Container Size
	self.listContainer:SetSize( self:GetWidth() - self.lCXmod, self:GetHeight() - self.lCYmod );
	
	-- Set List Frame Header Size
	self.listFrame.heading:SetSize( self.listFrame:GetWidth(), 13 );
end

------------------------------------------------------------------------
-- ZEDMOD: Update Main Window Height and Position after window resize --
------------------------------------------------------------------------
function SongbookWindow:UpdateMainWindow( unallowedHeight )
	local newwindowHeight = self.listContainer:GetHeight() + unallowedHeight;
	self:SetHeight( newwindowHeight );
	self:SetSBControls();
	self.resizeCtrl:SetPosition( self:GetWidth() - 20, self:GetHeight() - 20 );
end

------------------------------------------
-- ZEDMOD: Update List Container Height --
------------------------------------------
function SongbookWindow:UpdateContainer( posrep )
	local newcontainerHeight = posrep;
	self.listContainer:SetHeight( newcontainerHeight );
end


----------------------------------------------------------------------------
-- Zed: Fix Local and Langue when FR/DE Lotro client switched in EN Language
-- Nim: Split up combined function 
----------------------------------------------------------------------------
function FixLocLangFormat( eFormat, floatValue )
	if ( eFormat ) then
		floatValue = string.gsub( floatValue, "%.", ",");
	else
		floatValue = string.gsub( floatValue, ",", ".");
	end
	return floatValue;
end

--------------
-- Callback --
--------------
-- Add Callback
function AddCallback( object, event, callback )
	if ( object[event] == nil ) then
		object[event] = callback;
	else
		if ( type( object[event] ) == "table" ) then
			table.insert( object[event], callback );
		else
			object[event] = { object[event], callback };
		end
	end
	return callback;
end

-- Remove Callback
function RemoveCallback( object, event, callback )
	if ( object[event] == callback ) then
		object[event] = nil;
	else
		if ( type( object[event] ) == "table" ) then
			local size = table.getn( object[event] );
			for i = 1, size do
				if ( object[event][i] == callback ) then
					table.remove( object[event], i );
					break;
				end
			end
		end
	end
end


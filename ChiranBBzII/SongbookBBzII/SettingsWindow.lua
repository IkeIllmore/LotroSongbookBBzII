SettingsWindow = class( Turbine.UI.Lotro.Window );

function CreateGroupLabelPos( parent, stringCode, xPos, yPos, width )
	local label = CreateGroupLabel( parent, stringCode )
	label:SetPosition( xPos, yPos );
	label:SetWidth( width );
	return label;
end

function SettingsWindow:NextPos( delta )
	delta = delta or 20;
	self.yPos = self.yPos + delta;
	return self.yPos;
end

function SettingsWindow:CreateCheckBox( stringCode, yPos, state, func, width, xPos )
	width = width or 300;
	xPos = xPos or 25;
	local cb = Turbine.UI.Lotro.CheckBox();
	cb:SetParent( self );
	cb:SetPosition( xPos, yPos );
	cb:SetSize( width, 20 );
	cb:SetText( " " .. Strings[stringCode] );
	cb:SetChecked( ( state == "yes" ) or ( state == "true" ) );
	cb.CheckedChanged = func;
	return cb;
end

function SettingsWindow:Constructor()
	Turbine.UI.Lotro.Window.Constructor( self );
	local sCmd = 0;
	
	local xPos, yPos;
	local wndHeight = 585;
	local displayWidth, displayHeight = Turbine.UI.Display.GetSize();
	if ( Settings.WindowPosition.Left < 300 ) then
		xPos = 0;
	else
		xPos = Settings.WindowPosition.Left - 300;
	end
	if ( Settings.WindowPosition.Top + 100 + wndHeight > displayHeight ) then
		yPos = displayHeight - wndHeight;
	else
		yPos = Settings.WindowPosition.Top + 100;
	end
	self:SetPosition( xPos, yPos );
	
	self:SetSize( 370, wndHeight );
	self:SetZOrder( 20 );
	self:SetText( Strings["ui_settings"] );
	self.yPos = 20;
	
	-- General Settings Label
	self.genLabel = CreateGroupLabelPos( self, "ui_general", 20, self:NextPos( 20 ), 300 );
	
	-- Checkbox : Track Display
	self.trackCheck = self:CreateCheckBox( "cb_parts", self:NextPos( 20 ), Settings.TracksVisible, 
	function( sender, args )
		songbookWindow:ToggleTracks();
	end );
	
	-- Checkbox : Search Function
	self.searchCheck = self:CreateCheckBox( "cb_search", self:NextPos(), Settings.SearchVisible, 
	function( sender, args )
		songbookWindow:ToggleSearch();
	end );
	
	-- Checkbox : Show Description in Songlist
	self.descCheck = self:CreateCheckBox( "cb_desc", self:NextPos(), Settings.DescriptionVisible, 
	function( sender, args )
		songbookWindow:ToggleDescription();
	end );
	
	-- Checkbox : Show Description First in Songlist
	self.descFirstCheck = self:CreateCheckBox( "cb_descfirst", self.yPos, Settings.DescriptionFirst, 
	function( sender, args )
		songbookWindow:ToggleDescriptionFirst();
	end, 150, 250 );
	
	-- Checkbox : Window Visibility on load
	self.visibleCheck = self:CreateCheckBox( "cb_windowvis", self:NextPos(), Settings.WindowVisible, 
	function( sender, args )
		self:ChangeVisibility();
	end );
	
	-- Badger Settings
	self.badgerLabel = CreateGroupLabelPos( self, "ui_badger", 20, self:NextPos( 20 ), 300 );
	
	-- Checkbox : Chief mode - uses party object, enables sync start quickslot
	self.chiefCheck = self:CreateCheckBox( "cb_chief", self:NextPos(), Settings.ChiefMode, 
	function( sender, args )
		songbookWindow:SetChiefMode( sender:IsChecked() );
	end, 120 );
	
	-- Show or hide R,S buttons and track selector
	self.showAllBtns = self:CreateCheckBox( "cb_buttons", self.yPos, Settings.ShowAllBtns, 
	function( sender, args )
		songbookWindow:ShowAllButtons( sender:IsChecked() );
	end, 140, 170 );
	
	-- Checkbox : Badger Filters On/Off
	self.filterCheck = self:CreateCheckBox( "filters", self:NextPos(), Settings.FiltersState, 
	function( sender, args )
		songbookWindow:ShowFilterUI( sender:IsChecked() );
	end, 120 );
	
	-- ZEDMOD: Checkbox : Players list On/Off 
	self.partyCheck = self:CreateCheckBox( "playerlist", self.yPos, Settings.PartyState, 
	function( sender, args )
		songbookWindow:ShowPartyUI( sender:IsChecked() );
	end, 140, 170 );
	
	-- Checkbox : Countdown timer ( if song duration available )
	self.countdownCheck = self:CreateCheckBox( "cb_timerDown", self:NextPos(), Settings.TimerCountdown, 
	function( sender, args )
		songbookWindow.bTimerCountdown = sender:IsChecked();
	end, 150, 170 );
	
	-- Checkbox : Timer Display On/Off
	self.timerCheck = self:CreateCheckBox( "cb_timer", self.yPos, Settings.TimerState, 
	function( sender, args )
		self:ToggleTimer( sender:IsChecked() );
	end, 120 );
	if ( Settings.TimerState ~= "true" ) then
		self.countdownCheck:SetVisible( false );
	end
	
	-- Checkbox : Hightlight Issues in Ready Column ( White background )
	self.readyHighlightCheck = self:CreateCheckBox( "cb_rdyColHL", self:NextPos(), Settings.ReadyColHighlight, 
	function( sender, args )
		songbookWindow:HightlightReadyColumns( sender:IsChecked() );
	end, 150, 170 );
	
	-- Checkbox : Additional Ready State Indicators
	self.readyColumnCheck = self:CreateCheckBox( "cb_rdyCol", self.yPos, Settings.ReadyColState, 
	function( sender, args )
		self:ToggleReadyCol( sender:IsChecked() );
	end, 145 );
	if ( Settings.ReadyColState ~= "true" ) then
		self.readyHighlightCheck:SetVisible( false );
	end
	-- /Badger settings
	
	-- Songbook button settings
	self.sbbtnLabel = CreateGroupLabelPos( self, "ui_icon", 20, self:NextPos( 20 ), 300 );
	
	-- Checkbox : Songbook Button Visibility
	self.toggleCheck = self:CreateCheckBox( "cb_iconvis", self:NextPos( 20 ), Settings.ToggleVisible, 
	function( sender, args )
		self:ChangeToggleVisibility();
	end );
	
	-- Controls : Toggle Songbook Button Opacity
	self.toggleOpacityLabel = Turbine.UI.Label();
	self.toggleOpacityLabel:SetParent( self );
	self.toggleOpacityLabel:SetPosition( 45, self:NextPos( 30 ) );
	self.toggleOpacityLabel:SetWidth( 300 );
	self.toggleOpacityLabel:SetText( Strings["ui_btn_opacity"] );
	
	self.toggleOpacityScroll = Turbine.UI.Lotro.ScrollBar();
	self.toggleOpacityScroll:SetParent( self );
	self.toggleOpacityScroll:SetOrientation( Turbine.UI.Orientation.Horizontal );
	self.toggleOpacityScroll:SetPosition( 45, self:NextPos( 15 ) );
	self.toggleOpacityScroll:SetSize( 220, 10 );
	self.toggleOpacityScroll:SetValue( 100 * Settings.ToggleOpacity );
	self.toggleOpacityScroll:SetMaximum( 100 );
	self.toggleOpacityScroll:SetMinimum( 0 );
	self.toggleOpacityScroll:SetSmallChange( 1 );
	self.toggleOpacityScroll:SetLargeChange( 5 );
	self.toggleOpacityScroll.ValueChanged = function( sender, args )
		newvalue = sender:GetValue() / 100;
		Settings.ToggleOpacity = newvalue;
		self.toggleOpacityInd:SetText( newvalue );
		toggleWindow:SetOpacity( newvalue );
	end
	
	self.toggleOpacityInd = Turbine.UI.Label();
	self.toggleOpacityInd:SetParent( self );
	self.toggleOpacityInd:SetPosition( 280, self.yPos );
	self.toggleOpacityInd:SetWidth( 30 );
	self.toggleOpacityInd:SetForeColor( Turbine.UI.Color( 1, 0.77, 0.64, 0.22 ) );
	self.toggleOpacityInd:SetText( Settings.ToggleOpacity );
	
	-- Instruments Slots Settings
	self.instrLabel = CreateGroupLabelPos( self, "ui_instr", 20, self:NextPos( 20 ), 300 );
	
	-- ZEDMOD: Checkbox : Instrumentlist Visibility Force Horizontal
	self.instrVisHForced = self:CreateCheckBox( "cb_instrvisHForced", self:NextPos( 20 ), CharSettings.InstrSlots["visHForced"], 
	function( sender, args )
		songbookWindow:InstrumentsVisibleHForced( sender: IsChecked() );
	end, 100, 210 );
	
	-- ZEDMOD: Checkbox : Instrumentlist Visibility On/Off
	self.instrCheck = self:CreateCheckBox( "cb_instrvis", self.yPos, CharSettings.InstrSlots["visible"], 
	function( sender, args )
		self:ToggleInstruments( sender:IsChecked() );
	end, 165 );
	if ( CharSettings.InstrSlots["visible"] ~= "yes" ) then
		self.instrVisHForced:SetVisible( false );
	end
	
	-- Button : Clear Instrumentlist Slots
	self.clrSlotsBtn = Turbine.UI.Lotro.Button();
	self.clrSlotsBtn:SetParent( self );
	self.clrSlotsBtn:SetPosition( 20, self:NextPos() );
	self.clrSlotsBtn:SetSize( 155, 20 );
	self.clrSlotsBtn:SetText( Strings["ui_clr_slots"] );
	self.clrSlotsBtn.MouseDown = function( sender, args )
		songbookWindow:ClearSlots();
	end
	
	-- Button : Add Instrument Slot
	self.addSlotBtn = Turbine.UI.Lotro.Button();
	self.addSlotBtn:SetParent( self );
	self.addSlotBtn:SetPosition( 180, self.yPos );
	self.addSlotBtn:SetSize( 85, 20 );
	self.addSlotBtn:SetText( Strings["ui_add_slot"] );
	self.addSlotBtn.MouseDown = function( sender, args )
		songbookWindow:AddSlot();
	end
	
	-- Button : Remove Instrument Slot
	self.delSlotBtn = Turbine.UI.Lotro.Button();
	self.delSlotBtn:SetParent( self );
	self.delSlotBtn:SetPosition( 270, self.yPos );
	self.delSlotBtn:SetSize( 75, 20 );
	self.delSlotBtn:SetText( Strings["ui_del_slot"] );
	self.delSlotBtn.MouseDown = function( sender, args )
		songbookWindow:DelSlot();
	end
	
	-- Custom Commands 
	self.cmdLabel = CreateGroupLabelPos( self, "ui_custom", 20, self:NextPos( 30 ), 300 );
	
	-- Button : Add Command
	self.addBtn = Turbine.UI.Lotro.Button();
	self.addBtn:SetParent( self );
	self.addBtn:SetPosition( 20, self:NextPos( 20 ) );
	self.addBtn:SetSize( 85, 20 );
	self.addBtn:SetText( Strings["ui_cus_add"] );
	self.addBtn.MouseDown = function( sender, args )
		if ( args.Button == Turbine.UI.MouseButton.Left ) then
			self:ShowAddWindow( 0 );
		end
	end
	
	-- Button : Edit Command
	self.editBtn = Turbine.UI.Lotro.Button();
	self.editBtn:SetParent( self );
	self.editBtn:SetPosition( 115, self.yPos );
	self.editBtn:SetSize( 70, 20 );
	self.editBtn:SetText( Strings["ui_cus_edit"] );
	self.editBtn:SetEnabled( false );
	self.editBtn.MouseDown = function( sender, args )
		if ( args.Button == Turbine.UI.MouseButton.Left ) then
			self:ShowAddWindow( sCmd );
		end
	end
	
	-- Button : Del Command
	self.delBtn = Turbine.UI.Lotro.Button();
	self.delBtn:SetParent( self );
	self.delBtn:SetPosition( 195, self.yPos );
	self.delBtn:SetSize( 75, 20 );
	self.delBtn:SetText( Strings["ui_cus_del"] );
	self.delBtn:SetEnabled( false );
	self.delBtn.MouseDown = function( sender, args )
		if ( args.Button == Turbine.UI.MouseButton.Left ) then
			self.cmdlistBox:RemoveItemAt( sCmd );
			local size = self:CountCmds();
			for i = sCmd, size do
				if ( i == size ) then
					Settings.Commands[tostring( i )] = nil;
				else
					Settings.Commands[tostring( i )].Title = Settings.Commands[tostring( i + 1 )].Title;
					Settings.Commands[tostring( i )].Command = Settings.Commands[tostring( i + 1 )].Command;
				end
			end
			sCmd = 0;
			self.editBtn:SetEnabled( false );
			self.delBtn:SetEnabled( false );
		end
	end
	
	-- Control : Commandlist Frame
	self.listFrame = Turbine.UI.Control();
	self.listFrame:SetParent( self );
	self.listFrame:SetPosition( 20, self:NextPos( 30 ) );
	self.listFrame:SetSize( self:GetWidth() - 40, 99 );
	self.listFrame:SetBackColor( Turbine.UI.Color( 1, 0.15, 0.15, 0.15 ) );
	
	-- Label : Commandlist Frame
	self.listFrame.heading = Turbine.UI.Label();
	self.listFrame.heading:SetParent( self.listFrame );
	self.listFrame.heading:SetLeft( 0 );
	self.listFrame.heading:SetSize( 100, 13 );
	self.listFrame.heading:SetFont( Turbine.UI.Lotro.Font.TrajanPro13 );
	self.listFrame.heading:SetText( Strings["ui_cmds"] );
	
	-- Control : Commandlist Frame Background
	self.listBg = Turbine.UI.Control();
	self.listBg:SetParent( self.listFrame );
	self.listBg:SetPosition( 0, 15 );
	self.listBg:SetSize( self.listFrame:GetWidth() - 19, self.listFrame:GetHeight() - 19 );
	self.listBg:SetBackColor( Turbine.UI.Color( 1, 0, 0, 0 ) );
	
	-- Listbox : Commandlist
	self.cmdlistBox = Turbine.UI.ListBox();
	self.cmdlistBox:SetParent( self.listFrame );
	self.cmdlistBox:SetPosition( 5, 15 );
	self.cmdlistBox:SetSize( self.listFrame:GetWidth() - 23, self.listFrame:GetHeight() - 19 );
	
	-- Refresh Commands
	self:RefreshCmds();
	
	-- Scrollbar : Commandlist
	self.cmdScroll = Turbine.UI.Lotro.ScrollBar();
	self.cmdScroll:SetParent( self );
	self.cmdScroll:SetOrientation( Turbine.UI.Orientation.Vertical );
	self.cmdScroll:SetPosition( self.listFrame:GetLeft() + self.listFrame:GetWidth() -12, self.listFrame:GetTop() + 13 );
	self.cmdScroll:SetSize( 10, self.cmdlistBox:GetHeight() );
	self.cmdScroll:SetValue( 0 );
	self.cmdlistBox:SetVerticalScrollBar( self.cmdScroll );
	self.cmdScroll:SetVisible( false );
	
	-- Commandlist : Selected Index Changed
	self.cmdlistBox.SelectedIndexChanged = function( sender, args )
		self:ChangeCmd( sender:GetSelectedIndex() );
	end
	
	-- Songbook : Change Visibility
	function self:ChangeVisibility()
		if ( Settings.WindowVisible == "yes" ) then
			Settings.WindowVisible = "no";
		else
			Settings.WindowVisible = "yes";
		end
	end
	
	-- Songbook : Change Toggle Visibility
	function self:ChangeToggleVisibility()
		if ( Settings.ToggleVisible == "yes" ) then
			Settings.ToggleVisible = "no";
			toggleWindow:SetVisible( false );
		else
			Settings.ToggleVisible = "yes";
			toggleWindow:SetVisible( true );
		end
	end
	
	-- Timer : Toggle Timer
	function self:ToggleTimer( bChecked )
		songbookWindow:ActivateCounter( bChecked )
		self.countdownCheck:SetVisible( bChecked )
	end
	
	-- Ready Column : Toggle Ready Column
	function self:ToggleReadyCol( bChecked )
		songbookWindow:ShowReadyColumns( bChecked )
		self.readyHighlightCheck:SetVisible( bChecked )
	end
	
	-- ZEDMOD: Instrument Slots : Toggle Instruments
	function self:ToggleInstruments( bChecked )
		songbookWindow:ToggleInstruments( bChecked )
		self.instrVisHForced:SetVisible( bChecked )
	end
	
	-- Command : Change Command
	function self:ChangeCmd( cmdId )
		self.editBtn:SetEnabled( true );
		self.delBtn:SetEnabled( true );
		local selectedItem = self.cmdlistBox:GetItem( cmdId );
		sCmd = cmdId;
		self:SetCmdFocus( sCmd );
	end
	
	-- Command : Set Command Focus
	function self:SetCmdFocus( cmdId )
		for i = 1, self.cmdlistBox:GetItemCount() do
			local item = self.cmdlistBox:GetItem( i );
			if ( i == cmdId ) then
				item:SetForeColor( Turbine.UI.Color( 1, 0.15, 0.95, 0.15 ) );
			else
				item:SetForeColor( Turbine.UI.Color( 1, 1, 1, 1 ) );
			end
		end
	end
	
	-- Button : Save Settings
	self.saveBtn = Turbine.UI.Lotro.Button();
	self.saveBtn:SetParent( self );
	self.saveBtn:SetPosition( self:GetWidth() / 2 - 50, self:GetHeight() - 35 );
	self.saveBtn:SetSize( 100, 20 );
	self.saveBtn:SetText( Strings["ui_save"] );
	self.saveBtn.MouseDown = function( sender, args )
		if ( args.Button == Turbine.UI.MouseButton.Left ) then
			songbookWindow:SaveSettings();
			self:SetVisible( false );
		end
	end
	
	-- Command : Show Additional Command Edit Window
	function self:ShowAddWindow( cmdId )
		self.addWindow = Turbine.UI.Lotro.Window();
		self.addWindow:SetPosition( self:GetLeft() - 50, self:GetTop() + 50 );
		self.addWindow:SetSize( 315, 300 );
		self.addWindow:SetZOrder( 21 );
		self.addWindow:SetVisible( true );
		if ( cmdId == 0 ) then
			self.addWindow:SetText( Strings["ui_cus_winadd"] );
		else
			self.addWindow:SetText( Strings["ui_cus_winedit"] );
		end
		
		-- Additional Command Edit Window : Title label
		self.addWindow.titleLabel = Turbine.UI.Label();
		self.addWindow.titleLabel:SetParent( self.addWindow );
		self.addWindow.titleLabel:SetPosition( 20, 45 );
		self.addWindow.titleLabel:SetSize( 100, 20 );
		self.addWindow.titleLabel:SetFont( Turbine.UI.Lotro.Font.Verdana14 );
		self.addWindow.titleLabel:SetText( Strings["ui_cus_title"] );
		
		-- Additional Command Edit Window : Text Input for Command Title
		self.addWindow.titleInput = Turbine.UI.Lotro.TextBox();
		self.addWindow.titleInput:SetParent( self.addWindow );
		self.addWindow.titleInput:SetPosition( 20, 60 );
		self.addWindow.titleInput:SetSize( 270, 20 );
		self.addWindow.titleInput:SetMultiline( false );
		self.addWindow.titleInput:SetFont( Turbine.UI.Lotro.Font.Verdana14 );
		if ( cmdId == 0 ) then
			self.addWindow.titleInput:SetText( "" );
		else
			self.addWindow.titleInput:SetText( Settings.Commands[tostring( cmdId )].Title );
		end
		
		-- Additional Command Edit Window : Edit label
		self.addWindow.editLabel = Turbine.UI.Label();
		self.addWindow.editLabel:SetParent( self.addWindow );
		self.addWindow.editLabel:SetPosition( 20, 85 );
		self.addWindow.editLabel:SetSize( 100, 20 );
		self.addWindow.editLabel:SetFont( Turbine.UI.Lotro.Font.Verdana14 );
		self.addWindow.editLabel:SetText( Strings["ui_cus_command"] );
		
		-- Additional Command Edit Window : Text Input for Command title
		self.addWindow.editInput = Turbine.UI.Lotro.TextBox();
		self.addWindow.editInput:SetParent( self.addWindow );
		self.addWindow.editInput:SetPosition( 20, 100 );
		self.addWindow.editInput:SetSize( 270, 20 );
		self.addWindow.editInput:SetMultiline( false );
		self.addWindow.editInput:SetFont( Turbine.UI.Lotro.Font.Verdana14 );
		if ( cmdId == 0 ) then
			self.addWindow.editInput:SetText( "" );
		else
			self.addWindow.editInput:SetText( Settings.Commands[tostring( cmdId )].Command );
		end
		
		-- Additional Command Edit Window : Error label
		self.addWindow.error = Turbine.UI.Label();
		self.addWindow.error:SetParent( self.addWindow );
		self.addWindow.error:SetPosition( 20, 260 );
		self.addWindow.error:SetSize( 280, 50 );
		self.addWindow.error:SetForeColor( Turbine.UI.Color( 1, 1, 0, 0 ) );
		self.addWindow.error:SetText( "" );
		
		-- Additional Command Edit Window : OK Button for saving
		self.addWindow.okBtn = Turbine.UI.Lotro.Button();
		self.addWindow.okBtn:SetParent( self.addWindow );
		self.addWindow.okBtn:SetPosition( 20, 130 );
		self.addWindow.okBtn:SetSize( 100, 20 );
		self.addWindow.okBtn:SetText( Strings["ui_ok"] );
		self.addWindow.okBtn.MouseDown = function( sender, args )
			if ( args.Button == Turbine.UI.MouseButton.Left ) then
				if ( ( self.addWindow.titleInput:GetText() ~= "" ) and ( self.addWindow.editInput:GetText() ~= "") ) then
					if ( cmdId == 0 ) then
						newId = tostring( self:CountCmds() + 1 );
						Settings.Commands[newId] = {};
						Settings.Commands[newId].Title = self.addWindow.titleInput:GetText();
						Settings.Commands[newId].Command = self.addWindow.editInput:GetText();
					else
						cmdId = tostring( cmdId );
						Settings.Commands[tostring( cmdId )].Title = self.addWindow.titleInput:GetText();
						Settings.Commands[tostring( cmdId )].Command = self.addWindow.editInput:GetText();
					end
					self.addWindow.error:SetText( "" );
					self.addWindow:Close();
					self:RefreshCmds();
				else
					self.addWindow.error:SetText( Strings["ui_cus_err"] );
				end
			end
		end
		
		-- Additional Command Edit Window : Cancel Button
		self.addWindow.cancelBtn = Turbine.UI.Lotro.Button();
		self.addWindow.cancelBtn:SetParent( self.addWindow );
		self.addWindow.cancelBtn:SetPosition( 150, 130 );
		self.addWindow.cancelBtn:SetSize( 100, 20 );
		self.addWindow.cancelBtn:SetText( Strings["ui_cancel"] );
		self.addWindow.cancelBtn.MouseDown = function( sender, args )
			if ( args.Button == Turbine.UI.MouseButton.Left ) then
				self.addWindow.error:SetText( "" );
				self.addWindow:Close();
			end
		end
		
		-- Additional Command Edit Window : Help label
		self.addWindow.help = Turbine.UI.Label();
		self.addWindow.help:SetParent( self.addWindow );
		self.addWindow.help:SetPosition( 20, 170 );
		self.addWindow.help:SetSize( 300, 200 );
		self.addWindow.help:SetFont( Turbine.UI.Lotro.Font.Verdana14 );
		self.addWindow.help:SetText( Strings["ui_cus_help"] );
	end
end

function SettingsWindow:RefreshCmds()
	local size = self.cmdlistBox:GetItemCount();
	self.cmdlistBox:ClearItems();
	for i = 1, self:CountCmds() do
		local cmdItem = Turbine.UI.Label();
		cmdItem:SetText( Settings.Commands[tostring( i )].Title );
		cmdItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
		cmdItem:SetSize( 1000, 20 );
		self.cmdlistBox:AddItem( cmdItem );
	end
	sCmd = 0;
	self.editBtn:SetEnabled( false );
	self.delBtn:SetEnabled( false );
end

function SettingsWindow:CountCmds()
	local cSize = 0;
	for key, value in pairs( Settings.Commands ) do
		cSize = cSize + 1;
	end
	return cSize;
end
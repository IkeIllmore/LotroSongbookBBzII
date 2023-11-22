BaseWindow = class( Turbine.UI.Lotro.Window );
InstrAssignWindow = class( BaseWindow );
InstrSkillsWindow = class( BaseWindow );
InstrPrioWindow = class( BaseWindow );
LBScroll = class( Turbine.UI.ListBox ); -- Listbox with child scrollbar and separator
ListBoxInstrSkills = class( LBScroll ); -- listbox showing a matrix of skill checkboxes for players/instruments
ListBoxInstrAssign = class( LBScroll ); -- listbox showing the parts assignment (player - part)
ListBoxPrioEdit = class( LBScroll ); -- listbox with an edit box per instrument to enter priorities
ListBoxPrioPlayers = class( LBScroll ); -- listbox with an edit box per instrument to enter priorities

g_cfgUI =
{	-- default sizes for various UI elements
	siLbl = { x = 0, y = 20 }, -- category label (x=0 means expand to max width)
	lblHdgGap = 2,
	colorDefault = Turbine.UI.Color( 1, 1, 1, 1 ),
	colorDefaultBack = Turbine.UI.Color( 0.9, 0, 0, 0 ),
	colorLbHdg = Turbine.UI.Color( 1, 0.15, 0.15, 0.15 ),
	colorLbItem = Turbine.UI.Color( 1, 0.0, 0.0, 0.0 ),
	colorLbItemSelected = Turbine.UI.Color( 1, 0.20, 0.20, 0.20 ),
	fontNormal = Turbine.UI.Lotro.Font.LucidaConsole12,
	wndAssign = 
	{
		siCbChat = { x = 75, y = 20 }, -- size of chat checkboxes
		wiEditCustomChat = 40, -- width of the custom chat edit
		btnRow = {
			wiCreate = 55, wiAnn = 80, wiSkills = 60, wiPrios = 95, height = 15, spacing = 5,
			MinWidth = function(self) return self.wiCreate+self.wiAnn+self.wiSkills+self.wiPrios+3*self.spacing; end, },
		siMin = { x = 100, y = 200 },
		siMax = { x = 50000, y = 50000 },
		lbParts =
		{
			wiLblPlayer = 100, -- column heading 'Player' for assignment listbox
			wiLblInstr = 200, -- column heading 'Part/Instrument' for assignment listbox
			wiMinPlayer = 30, wiMinPart = 60,
			wiMaxPlayer = 150,
			colorHdgText = Turbine.UI.Color( 1, 1, 1, 1 ),
			colorHdgTextSelected = Turbine.UI.Color( 1, 0.96, 0.87, 0.57 ),
			colorPlayerInactive = Turbine.UI.Color( 1, 0.80, 0.80, 0.80 ),
			colorPlayerReannounce = Turbine.UI.Color( 1, 0.80, 0.80, 0.80 ),
			--wiDist = { 1, 1 },
			heLbItem = 20,
			MinSizeX = function( self ) return self.wiMinPlayer + self.wiMinPart; end,
			ComputeSizeX = function( self, width )
				if width > self.wiMaxPlayer * 3 then self.wiLblPlayer = self.wiMaxPlayer
				else self.wiLblPlayer = math.floor( width / 3 ); end
				self.wiLblInstr = width - self.wiLblPlayer; end
		},
		Init = function(self)
			self.siMin.x = self.btnRow:MinWidth( ) + layout:HorIndent()
			self.siMax.x = self.btnRow:MinWidth( ) * 2 + layout:HorIndent(); end,
		SizeLimitsX = function( self, nCols, delta ) -- delta is additional width specified by caller
			self.siMin.x = self.siLblLeftHdg.x + nCols * self.siLblHdg.x + delta
			self.siMax.x = self.siLblLeftHdg.x + nCols * self.wiMaxLblHdg + delta; end,
		UpdateSizeLimitsY = function( self, nCols, delta )
			self.siMin.x = self.siLblLeftHdg.x + nCols * self.siLblHdg.x + delta
			self.siMax.x = self.siLblLeftHdg.x + nCols * self.wiMaxLblHdg + delta; end,
		UpdateSizeLimits = function( self, nCols, xDelta, yDelta ) self:UpdateSizeLimitsX( nCols, xDelta ); self:UpdateSizeLimitsY( nCols, yDelta ); end,
	},
	wndSkills = 
	{
		siLblHdg = { x = 65, y = 20 }, -- column heading for skills listbox
		siLblLeftHdg = { x = 180, y = 20 }, -- row heading for skills listbox
		wiEditCb = 80, wiReceiveCb = 90,
		wiLblHdg = 65, -- current width of skill listbox column heading
		wiMinLblHdg = 30, -- its minimum
		wiMaxLblHdg = 120, -- and its maximum width
		colorLbLine = Turbine.UI.Color( 1, 0.10, 0.10, 0.10 ), -- reading aid coloring of alternate crows
		colorHdgChanged = Turbine.UI.Color( 1, 0.30, 0.10, 0.10 ),
		btnRow = { wiSave = 70, wiRevert = 70, wiPrios = 70, height = 15, spacing = 15 },
		siMin = { x = 20, y = 20 }, -- min size of listbox
		siMax = { x = 50000, y = 50000 }, -- max listbox size
		SetLblHdgWidth = function( self, wi ) self.wiLblHdg = wi; end,
		StaticSizeX = function( self ) return self.siLblLeftHdg.x; end,
		StaticSizeY = function( self ) return self.siLblLeftHdg.x; end,--TODO: update for y
		UpdateSizeLimitsX = function( self, nCols, delta ) -- delta is additional width specified by caller
			self.siMin.x = self:StaticSizeX() + nCols * self.wiMinLblHdg + delta
			self.siMax.x = self:StaticSizeX() + nCols * self.wiMaxLblHdg + delta; end,
		UpdateSizeLimitsY = function( self, nCols, delta ) --TODO: update for y
			self.siMin.x = self:StaticSizeX() + nCols * self.siLblHdg.x + delta
			self.siMax.x = self:StaticSizeX() + nCols * self.wiMaxLblHdg + delta; end,
		UpdateSizeLimits = function( self, nCols, delta ) self:UpdateSizeLimitsX( nCols, delta ); self:UpdateSizeLimitsY( nCols, delta ); end
	},
	wndPrios = 
	{
		siCbFilter =  { x = 120, y = 20 }, -- size of filter checkboxes
		--btnRow = { wiCreate = 60, wiCfg = 60, wiAnn = 80, height = 15, spacing = 15 },
		siMin = { x = 20, y = 20 }, -- min size of listbox
		siMax = { x = 50000, y = 50000 }, -- max listbox size
		wiMaxPlayer = 250, wiMaxPrios = 500,
		Init = function(self)
			self.siMin.x=self.siCbFilter.x*2+layout:HorIndent()
			self.siMax.x=self.siCbFilter.x*6+layout:HorIndent(); end,
		UpdateWidths = function( self, width )
			if width > self.wiMaxPlayer * 3 then self.lbPlayers.siLbItem.x = self.wiMaxPlayer
			else self.lbPlayers.siLbItem.x = math.floor( width / 3 ); end
			self.lbPrios.wiLabel = width - self.lbPlayers.siLbItem.x - self.lbPrios.wiEdit
			end,
		lbPlayers =
		{
			lbDetails = nil, -- prios listbox that is called with the new name upon selection change
			iSelected = nil, -- the selected item
			iSelected = nil, -- the selected item
			filter = nil,
			colorActive = Turbine.UI.Color( 1, 0.55, 1.00, 0.55 ),
			fontActive = Turbine.UI.Lotro.Font.VerdanaBold16,
			siLbItem = { x = 120, y = 20 },
			Width = function( self ) return self.siLbItem.x; end,
		},
		lbPrios =
		{
			sPlayer = "", -- the player currently selected in the players priorities list
			maxPrio = 5,
			wiLabel = 180, wiEdit = 20, heLbItems = 20,
			validChars = "012345",
			Width = function( self ) return self.wiLabel + self.wiEdit; end,
			LineCount = function( self ) return Instruments:Count(); end,
			LabelText = function( self, i ) return Instruments:Name( i ); end,
			EditContent = function( self, i )
				local prio = PriosData:ForUixPlayer( Instruments:Uix( i ), self.sPlayer )
				if prio then return tostring( prio ) else return ""; end; end,
			EditColor = function( self, sText )
				if sText and sText ~= "" then return Turbine.UI.Color( 1, 0.2, 0.30, 0.20 ); end
				return Turbine.UI.Color( 1, 0.1, 0.1, 0.1 ); end,
			ContentOK = function( self, i, s ) return s == "" or #s == 1 and self.validChars:find( s:sub( 1, 1 ) ); end,
			SaveEntry = function( self, i, sContent ) return PriosData:SetForPlayer( Instruments:Uix( i ), self.sPlayer, tonumber( sContent ) ); end,
		},
	},
}


--------------------------------------------------------------------------------
-- Data structure to support item positioning

layout =
{
	indent = { left = 20, top = 40, right = 20, bottom = 40 },
	spacing = { x = 20, y = 10 },
	defaultSpacing = { x = 20, y = 20 },
	limit = { x = 0, y = 0 },
	curPos = { x = 20, y = 20 },
	savedPos = { x = 20, y = 20 },
	ySkip = 0,
	pos = { x = 20, y = 20 },
	size = { x = 70, y = 20 }
}

function layout:DefaultSpacing( ) self.spacing = table.Copy(self.defaultSpacing); end
function layout:DefaultSpacingX( ) self.spacing.x = self.defaultSpacing.x; end
function layout:DefaultSpacingY( ) self.spacing.y = self.defaultSpacing.y; end
function layout:SetSpacing( s ) s = s or {x=0,y=0}; self.spacing = table.Copy(s); end
function layout:SetSpacingX( x ) x = x or 0; self.spacing.x = x; end
function layout:SetSpacingY( y ) y = y or 0; self.spacing.y = y; end
function layout:SavePos( ) self.savedPos = table.Copy(self.curPos); end
function layout:SavePosX( ) self.savedPos.x = self.curPos.x; end
function layout:SavePosY( ) self.savedPos.y = self.curPos.y; end
function layout:RestorePos( ) self.curPos = table.Copy(self.savedPos); end
function layout:RestorePosX( ) self.curPos.x = self.savedPos.x; end
function layout:RestorePosY( ) self.curPos.y = self.savedPos.y; end
function layout:HorIndent( ) return self.indent.left + self.indent.right; end
function layout:VerIndent( ) return self.indent.top + self.indent.bottom; end
-- Generate the position for a new UI element in a new line
function layout:Reset( xLimit, yLimit )
	self.limit = { x = xLimit - self.indent.right, y = yLimit - self.indent.bottom }
	self.curPos = { x = self.indent.left, y = self.indent.top }
	self.pos = { x = self.indent.left, y = self.indent.top }
	return self
end

-- for debugging
function layout:PrintCurPos() Turbine.Shell.WriteLine( "curPos = ("..self.curPos.x..","..self.curPos.y..")" ); end
function layout:PrintLimit() Turbine.Shell.WriteLine( "limit = ("..self.limit.x..","..self.limit.y..")" ); end
function layout:PrintPos() Turbine.Shell.WriteLine( "pos = ("..self.pos.x..","..self.pos.y..")" ); end
function layout:PrintSize() Turbine.Shell.WriteLine( "size = ("..self.size.x..","..self.size.y..")" ); end
function layout:PrintIndent() Turbine.Shell.WriteLine( "indent = ("..self.indent.left..","..self.indent.top..","..self.indent.right..","..self.indent.bottom..")" ); end

function layout:SetX( x ) self.pos.x = x; end
function layout:SetY( y ) self.pos.y = y; end
function layout:SetPos( x, y ) self:SetX( x ); self:SetY( y ); end
function layout:GetX( ) return self.pos.x; end
function layout:GetY( ) return self.pos.y; end
function layout:GetPos( ) return self.pos; end

function layout:SetWidth( w ) if not w or w<=0 then self:SetMaxWidth(); else self.size.x = w; end; return self; end
function layout:SetWidthR(w) if not w or w<=0 then self:SetMaxWidth(); else self.size.x=w; self.pos.x=self.pos.x-w; end; return self; end
function layout:SetHeight( h ) if not h or h<=0 then self:SetMaxHeight(); else self.size.y = h; end; return self; end
function layout:SetSizes( w, h ) self:SetWidth( w ); self:SetHeight( h ); return self; end
function layout:SetSize( s ) self:SetSizes( s.x, s.y ); return self; end
function layout:SameSize( ) return self; end
function layout:AdjustSize( item ) self.size.x = item:GetWidth(); self.size.y = item:GetHeight(); return self; end
function layout:SetMaxWidth( item ) self.size.x = self.limit.x - self.pos.x; return self; end
function layout:SetMaxHeight( item ) self.size.y = self.limit.y - self.pos.y; return self; end
function layout:SetMaxSize( item ) self:SetMaxWidth( item ); self:SetMaxHeight( item ); return self; end

function layout:Shift( dx, dy ) self.pos.x = self.pos.x + dx; self.pos.y = self.pos.y + dy; return self; end
function layout:ToLeft( dist ) dist = dist or self.spacing.x; self.pos.x = self.pos.x - dist; return self; end
function layout:ToRight( dist ) dist = dist or self.spacing.x; self.pos.x = self.pos.x + self.size.x + dist; return self; end
function layout:Above( dist ) dist = dist or self.spacing.y; self.pos.y = self.pos.y - self.size.y - dist; return self; end
function layout:Below( dist ) dist = dist or self.spacing.y; self.pos.y = self.pos.y + self.size.y + dist; return self; end
function layout:ToLeftBorder( ) self.pos.x = self.indent.left; return self; end
function layout:ToRightBorder( ) self.pos.x = self.limit.x; return self; end

function layout:PlaceItem( item, dLeft, dTop, dRight, dBottom )
	dLeft = dLeft or 0; dTop = dTop or 0; dRight = dRight or 0; dBottom = dBottom or 0
	item:SetPosition( self.pos.x + dLeft, self.pos.y + dTop );
	item:SetSize( self.size.x + dRight, self.size.y + dBottom );
	return self
end
function layout:PlaceItemEnlarged( item, xInc, yInc )
	xInc = xInc or 0; yInc = yInc or 0
	item:SetPosition( self.pos.x - xInc, self.pos.y - yInc );
	item:SetSize( self.size.x + 2 * xInc, self.size.y + 2 * yInc );
	return self
end


--------------------------------------------------------------------------------
-- Functions to create basic UI elements

function CreateGroupLabel( parent, stringCode )
	local label = Turbine.UI.Label( );
	label:SetParent( parent );
	label:SetForeColor( Turbine.UI.Color( 1, 0.77, 0.64, 0.22 ) );
	label:SetFont( Turbine.UI.Lotro.Font.TrajanPro16 );
	label:SetText( Strings[stringCode] );
	return label;
end

function CreateHdgLabel( parent, text, fnMouseClick, id )
	local label = Turbine.UI.Label( );
	label:SetParent( parent );
	label:SetMultiline( false );
	label:SetBackColor( g_cfgUI.colorLbHdg );
	label:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleCenter );
	label:SetText( text );
	if fnMouseClick then label.MouseClick = fnMouseClick; end
	if id then label.ID = id; end
	return label;
end

function CreateCBnoState( parent, stringCode, func )
	local cb = Turbine.UI.Lotro.CheckBox();
	cb:SetParent( parent );
	cb:SetText( " "..Strings[stringCode] );
	cb.CheckedChanged = func;
	return cb;
end

function CreateCB( parent, stringCode, bState, func )
	local cb = CreateCBnoState( parent, stringCode, func )
	cb:SetChecked( bState );
	return cb;
end

function CreateCheckBox( parent, stringCode, yPos, state, func, width, xPos )
	return CreateCB( parent, stringCode, yPos, ( state == "yes" ) or ( state == "true" ), func, width, xPos )
end


-- Create a pushbutton
function CreateButton( parent, sCode, fnMouseClick )
	local button = Turbine.UI.Lotro.Button();
	button:SetParent( parent );
	button:SetText( Strings[sCode] );
	button.MouseClick = fnMouseClick
	return button
end

-- Create shortcut button
function CreateShortcut( parent )
	local shortcut = Turbine.UI.Lotro.Quickslot();
	shortcut:SetParent( parent );
	shortcut:SetZOrder( 350 );
	shortcut:SetAllowDrop( false );
	shortcut:SetVisible( true );
	return shortcut;
end

function CreateIcon( parent, sImageName )
	local icon = Turbine.UI.Control();
	icon:SetParent( parent );
	icon:SetZOrder( 360 );
	icon:SetMouseVisible( false );
	icon:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	icon:SetBackground( gDir .. sImageName .. ".tga" );
	return icon;
end

-------------------------------------------------------------------------------
-- Listbox with scrollbar and separator

function LBScroll:New( scrollWidth, scrollHeight, bOrientation, listbox )
	listbox = listbox or LBScroll( scrollWidth, scrollHeight, bOrientation );
	setmetatable( listbox, self );
	self.__index = self;
	self.aPlayers = nil
	return listbox;
end

-- Listbox Scrolled : Constructor
function LBScroll:Constructor( scrollWidth, scrollHeight, bOrientation )
	Turbine.UI.ListBox.Constructor( self );
	self:SetMouseVisible( true ); 
	self:CreateChildScrollbar( scrollWidth, scrollHeight, bOrientation );
	self:CreateChildSeparator( scrollWidth, scrollHeight, bOrientation );
end

-- Listbox Scrolled : Child Scrollbar
function LBScroll:CreateChildScrollbar( width, height, bOrientation )
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
function LBScroll:CreateChildSeparator( width, height, bOrientation )
	self.separatorv = Turbine.UI.Control();
	self.separatorv:SetParent( self:GetParent() );
	self.separatorv:SetZOrder( 310 );
	self.separatorv:SetWidth( width );
	self.separatorv:SetTop( 0 );
	self.separatorv:SetBackColor( Turbine.UI.Color( 1, 0.15, 0.15, 0.15 ) );
	self.separatorv:SetVisible( false );
	
	-- ZEDMOD: Horizontal Separator for Instrument Slots
	if ( bOrientation ) then
		self.separatorh = Turbine.UI.Control();
		self.separatorh:SetParent( self:GetParent() );
		self.separatorh:SetZOrder( 310 );
		self.separatorh:SetHeight( height );
		self.separatorh:SetTop( height );
		self.separatorh:SetBackColor( Turbine.UI.Color( 1, 0.15, 0.15, 0.15 ) );
		self.separatorh:SetVisible( false );
	end
end

-- Listbox Scrolled : Set Left Position (x Position)
function LBScroll:SetLeft( xPos )
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
function LBScroll:SetTop( yPos )
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
function LBScroll:SetPosition( xPos, yPos )
	self:SetLeft( xPos );
	self:SetTop( yPos );
end

-- Listbox Scrolled : Set Width
function LBScroll:SetWidth( width )
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
function LBScroll:SetHeight( height )
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
function LBScroll:SetSize( width, height )
	self:SetWidth( width );
	self:SetHeight( height );
end

-- Listbox Scrolled : Set Visible
function LBScroll:SetVisible( bVisible )
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
function LBScroll:SetParent( parent )
--Turbine.Shell.WriteLine( "LBScroll:SetParent" );
	Turbine.UI.ListBox.SetParent( self, parent );
	self.scrollBarv:SetParent( parent );
	self.separatorv:SetParent( parent );
	
	-- ZEDMOD: Horizontal Scrollbar
	if ( self.scrollBarh ) then
		self.scrollBarh:SetParent( parent );
		self.separatorh:SetParent( parent );
	end
end

function LBScroll:GetLineCount( ) return math.floor( self:GetItemCount( ) / self:GetMaxItemsPerLine( ) ); end
function LBScroll:ColRowIdx( iCol, iLine )
	if self:GetOrientation( ) == Turbine.UI.Orientation.Horizontal then
		return iCol + ( iLine - 1 ) * self:GetMaxItemsPerLine( self ); end
	return iLine + ( iCol - 1 ) * self:GetMaxItemsPerLine( self ); end
function LBScroll:ColRowItem( iCol, iLine ) local i = self:ColRowIdx( iCol, iLine ); return i <= self:GetItemCount( ) and self:GetItem( i ) or nil; end

function LBScroll:RemoveLine( iLine )
	local iRemove = self:ColRowIdx( 1, iLine ) - 1
	for i=1,self:GetMaxItemsPerLine( ) do
		self:RemoveItemAt( iRemove + i ); end
end


Marks =
{
	tag = { ["inactive"] = 2, ["reannounce"] = 4, ["vocals"] = 8, ["selected"] = 16, },
	aColors = { [2] = Turbine.UI.Color( 1, 0.50, 0.50, 0.50 ), [4] = Turbine.UI.Color( 1, 0.70, 0.70, 1.00 ), [8] = Turbine.UI.Color( 1, 0.60, 1.00, 0.30 ) },
	aBackColors = { [16] = g_cfgUI.colorLbItemSelected },
	Color = function( self, m ) return self.aColors[ m ]; end,
	SetColor = function( self, m, item ) if self.aColors[ m ] then item:SetForeColor( self.aColors[ m ] ); end; end,
	SetBackColor = function( self, m, item ) if self.aBackColors[ m ] then item:SetBackColor( self.aBackColors[ m ] ); end; end,
	SetVisual = function( self, m, item )
		self:SetColor( m, item ); self:SetBackColor( m, item ); end,
	IsSet = function( self, value, m ) return value and value % m >= m / 2 or false; end,
	IsClear = function( self, value, m ) return not self:IsSet( value, m ); end,
	Set = function( self, value, m ) if self:IsSet( value, m ) then return value else return value + m / 2; end; end,
	Clear = function( self, value, m ) if self:IsSet( value, m ) then return value - m / 2 else return value; end; end,
}

function LBScroll:SetItemColor( iLine, iCol, color )
	local item = self:ColRowItem( iCol, iLine )
	if item then item:SetForeColor( color ); end
end

function LBScroll:SetItemMarkVisual( iLine, iCol, m )
	local item = self:ColRowItem( iCol, iLine )
	if item then Marks:SetVisual( m, item ); end
end

function LBScroll:SetItemVisuals( iLine, iCol, mark )
	if not mark then return; end
	local item = self:ColRowItem( iCol, iLine ); if not item then return; end
	local usedColor, usedBackColor = nil, nil
	for _, v in pairs( Marks.tag ) do
		if Marks:IsSet( mark, v ) then
			if not usedColor then
				if Marks.aColors[ v ] then usedColor = Marks.aColors[ v ]; item:SetForeColor( usedColor ); end
			elseif usedBackColor then return -- if both have been set, stop the loop
			end
			if not usedBackColor then
				if Marks.aBackColors[ v ] then usedBackColor = Marks.aBackColors[ v ]; item:SetBackColor( usedBackColor ); end
			end
		end
	end
	if not usedColor then item:SetForeColor( g_cfgUI.colorDefault ); end
	if not usedBackColor then item:SetBackColor( g_cfgUI.colorDefaultBack ); end
end

function LBScroll:ClearItemVisuals( iItem )
	if iItem > self:GetItemCount( ) then return; end
	local item = self:GetItem( iItem )
	if item then item:SetForeColor( g_cfgUI.colorDefault ); item:SetBackColor( g_cfgUI.colorDefaultBack ); end
end

function LBScroll:MarkItem( mark, iLine, iCol )
	self.aPlayers:SetMark( iLine, mark ); self:SetItemMarkVisual( iLine, iCol, mark ); end
function LBScroll:UnmarkItem( mark, iLine, iCol )
	self.aPlayers:ClearMark( iLine, mark ); self:SetItemVisuals( iLine, iCol, self.aPlayers:Mark( iLine ) ); end
function LBScroll:ToggleMark( mark, iLine, iCol )
	if self.aPlayers:IsMarkSet( iLine, mark ) then self:UnmarkItem( mark, iLine, iCol )
	else self:MarkItem( mark, iLine, iCol ); end; end
function LBScroll:IsMarked( mark, iLine ) return self.aPlayers:IsMarkSet( iLine, mark ); end
function LBScroll:ClearMarks( mark, iCol )
	for i = 1, self.aPlayers:Count( ) do
		if self.aPlayers:IsMarkSet( i, mark ) then self:UnmarkItem( mark, i, iCol ); end
	end
end

function LBScroll:IterMark( ) self.iIter = 0; end
function LBScroll:MarkIndex( ) return self.iIter; end
function LBScroll:NextMarked( m )
	repeat
		self.iIter = self.iIter + 1;
		if self.iIter > self.aPlayers:Count( ) then return false; end
	until self.aPlayers:IsMarkSet( self.iIter, m )
	return true
end
	
function LBScroll:Selection( )
	local aSel = {}
	self:IterMark( )
	while self:NextMarked( Marks.tag.selected ) do aSel[ #aSel + 1 ] = self:IterMark( ); end
	return aSel
end

function LBScroll:CountMarked( m )
	local nMarked = 0
	self:IterMark( )
	while self:NextMarked( m ) do nMarked = nMarked + 1; end
	return nMarked
end

function LBScroll:MarkSelected( m, iCol )
	self:IterMark( )
	while self:NextMarked( Marks.tag.selected ) do self:MarkItem( m, self:MarkIndex( ), iCol ); end
end

function LBScroll:UnmarkSelected( m, iCol )
	self:IterMark( )
	while self:NextMarked( Marks.tag.selected ) do self:UnmarkItem( m, self:MarkIndex( ), iCol ); end
end

function LBScroll:ToggleMarkSelected( m, iLine, iCol )
	local nSelected = 0
	self:IterMark( )
	while self:NextMarked( Marks.tag.selected ) do
		self:ToggleMark( m, self:MarkIndex( ), iCol )
		nSelected = nSelected + 1
	end
	if nSelected == 0 then self:ToggleMark( m, iLine, iCol ); end -- if no selection, toggle the current line
end


local function SelectionKeyDown( )
	return Turbine.UI.Control.IsControlKeyDown( ) or Turbine.UI.Control.IsShiftKeyDown( )
end

function LBScroll:HandleSelection( iLine, iCol )
	if SelectionKeyDown( ) then self:ToggleMark( Marks.tag.selected, iLine, iCol )
	else self:ClearMarks( Marks.tag.selected, iCol ); self:MarkItem( Marks.tag.selected, iLine, iCol ); end
end
	

--------------------------------------------------------------------------------
-- ListBox for instrument skills

function ListBoxInstrSkills:New( scrollWidth, scrollHeight, bOrientation, config, listbox )
	listbox = listbox or ListBoxInstrSkills( scrollWidth, scrollHeight, bOrientation, config );
	setmetatable( listbox, self ); --setmetatable( listbox, LBScroll );
	self.__index = self;
	return listbox;
end

function ListBoxInstrSkills:Constructor( scrollWidth, scrollHeight, bOrientation, config )
	LBScroll.Constructor( self, scrollWidth, scrollHeight, bOrientation );
	self:SetOrientation( Turbine.UI.Orientation.Vertical );
	self.cfg = config
	self.colCopy = Skills:New( )
	self.aHeaderNames = nil
end


function ListBoxInstrSkills:GetItemByRowCol( iInstr, iPlayer )
	return LBScroll.GetItem( self, iPlayer + ( iInstr-1) * LBScroll:GetMaxItemsPerLine() );
end

-- Line count
function ListBoxInstrSkills:GetLineCount()
	return math.floor( LBScroll.GetItemCount( self ) / LBScroll.GetMaxItemsPerLine( self ) );
end

-- Listbox Char Column : Clear Items
function ListBoxInstrSkills:ClearItems()
	LBScroll.ClearItems( self );
	--self:SetMaxItemsPerLine( 2 );
end

-- Listbox Char Column : Create Char Item
function ListBoxInstrSkills:CreateCharItem()
	local charItem = Turbine.UI.Label();
	charItem:SetMultiline( false );
	charItem:SetSize( self.readyColWidth, 20 );
	charItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleCenter );
	self:ApplyHighlight( charItem, false );
	return charItem;
end

-- Listbox Char Column : Add Item
function ListBoxInstrSkills:AddItem( item )
	LBScroll.AddItem( self, item );
end

-- Listbox Char Column : Insert Item
function ListBoxInstrSkills:InsertItem( index, item )
	LBScroll.AddItem( self, index, item );
end

-- Listbox Char Column : Remove Item At
function ListBoxInstrSkills:RemoveItemAt( i )
	if ( self.bShowReadyChars ) then
		LBScroll.RemoveItemAt( self, i * 2 );
		LBScroll.RemoveItemAt( self, i * 2 - 1 );
	else
		LBScroll.AddItem( self, i );
	end
end

function ListBoxInstrSkills:CreateCB( col, line )
	local cb = Turbine.UI.Lotro.CheckBox();
	cb:SetMultiline( false );
	cb:SetSize( self.cfg.wiMaxLblHdg, self.cfg.siLblLeftHdg.y + g_cfgUI.lblHdgGap );
	cb:SetParent( self )
	cb:SetText("")
	cb.ID = col*100 + line
	cb:SetCheckAlignment( Turbine.UI.ContentAlignment.MiddleCenter );
	cb.CheckedChanged = function(s,a)
		if s:HasFocus() then skillsWindow:SetSkill( math.floor( s.ID / 100 ), s.ID % 100, s:IsChecked( ) ); end; end
	return cb
end

function ListBoxInstrSkills:CreateHorHdgLabel( parent, text )
	label = Turbine.UI.Label();
	label:SetParent( parent );
	label:SetMultiline( false );
	label:SetBackColor( g_cfgUI.colorLbHdg );
	label:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleRight );
	label:SetSize( self.cfg.siLblLeftHdg.x, self.cfg.siLblLeftHdg.y + g_cfgUI.lblHdgGap );
	label:SetText( text );
	return label;
end


function ListBoxInstrSkills:CheckedState( skills, iLine )
	return skills and skills:Contains( Instruments:Uix( iLine ) )
end

-- Add the first column with the line headers
function ListBoxInstrSkills:AddHeaderColumn( )
	Instruments:IterStart( )
	local iHdg = 1
	while Instruments:IterNext() do
		local label = self:CreateHorHdgLabel( self, Instruments:IterName( ) )
		self:AddItem( label )
	end
end

-- Add a column to the right of existing columns
function ListBoxInstrSkills:AddColumn( skills, col )
	for i=1, Instruments:Count() do 
		local cb = self:CreateCB( col, i )
		cb:SetChecked( self:CheckedState( skills, i ) )
		if i % 2 == 0 then cb:SetBackColor( g_cfgUI.wndSkills.colorLbLine  ); end
		self:AddItem( cb )
	end
end

-- Insert a column; listbox is vertical, so item index counts down/right
function ListBoxInstrSkills:InsertColumn( iCol, skills )
	local iInsert = 1 + LBScroll.GetMaxItemsPerLine( self ) * iCol -- normally (iCol-1), but we have the heading column
	for i=1, Instruments:Count() do 
		local cb = self:CreateCB()
		cb:SetChecked( self:CheckedState( skills, i ) )
		self:InsertItem( iInsert, cb )
		iInsert = iInsert + 1
	end
end

-- Called when a player leaves the group (or is manually removed just from the skills list)
function ListBoxInstrSkills:RemoveColumn( iCol )
	local iRemove = LBScroll.GetMaxItemsPerLine( self ) * iCol -- normally (iCol-1)
	for i = 1, LBScroll.GetMaxItemsPerLine( self ) do 
		LBScroll.RemoveItemAt( iRemove + i );
	end
end

function ListBoxInstrSkills:SetAllInColumn( state, iCol )
	if not iCol then return; end
	for i = Instruments:Count() * iCol + 1, Instruments:Count() * ( iCol + 1 ) do
		local cb = LBScroll.GetItem( self, i )
		if cb then cb:SetChecked( state ); end
		skillsWindow:SetSkill( iCol, nil, state )
	end
end

function ListBoxInstrSkills:SetAll( state )
	for i = 1, #self.aHeaderNames do
		self:SetAllInColumn( state, i )
	end
end


function ListBoxInstrSkills:Initialize( aHeaderNames )
	self.aHeaderNames = aHeaderNames
	self:ClearItems( )
	LBScroll.SetMaxItemsPerLine( self, Instruments:Count() );
	self:AddHeaderColumn( )
	for nCols = 1, #aHeaderNames do 
		self:AddColumn( SkillsData:Get( aHeaderNames[ nCols ] ), nCols )
	end
end

function ListBoxInstrSkills:Resize( )
	for i = LBScroll.GetMaxItemsPerLine( self ) + 1, LBScroll.GetItemCount( self ) do 
		local cb = LBScroll.GetItem( self, i )
		cb:SetWidth( self.cfg.wiLblHdg );
	end
end

-- Write line numbers of checked boxes into the aCbStates array
function ListBoxInstrSkills:GetColumnStates( iCol, skills )
	local iStart = Instruments:Count( ) * iCol
local val = skills.value
	skills:CallSet( function( i ) return self:GetItem( iStart + i ):IsChecked( ); end )
end

-- Write column data into the aCbStates[header] array
function ListBoxInstrSkills:GetStates( aHeaderNames )
	local iColStart = Instruments:Count( ) -- start behind heading column
	for iHdr = 1, #aHeaderNames do
		self:GetColumnStates( iHdr, SkillsData:Get( aHeaderNames[ iHdr ], true ) )
	end
end

-- aCbStates array contains numbers of all checkboxes to be set 
function ListBoxInstrSkills:SetColumnStates( iCol, skills )
	local iStart = Instruments:Count( ) * iCol
	if skills then skills:CallGet( function( i, s ) self:GetItem( iStart + i ):SetChecked( s ); end )
	else self:SetAllInColumn( false, iCol ); end
end

function ListBoxInstrSkills:SetColumn( iCol, skills )
	self:SetColumnStates( iCol, skills )
	local sName = PartyMembers:Name( iCol )
	SkillsData:Set( sName, skills )
end

-- Set checkboxes according to aCbStates[header] array
function ListBoxInstrSkills:SetStates( aHeaderNames )
	local iItem = LBScroll.GetMaxItemsPerLine( self )
	for iHdr = 1, #aHeaderNames do 
		self:SetColumnStates( iHdr, SkillsData:Get( aHeaderNames[ iHdr ] ) )
	end
end


function ListBoxInstrSkills:EnableItems( bEnable )
	if bEnable == nil then bEnable = true; end
	for i=1,self:GetItemCount() do
		local item = self:GetItem( i )
		item:SetEnabled( bEnable );
	end
end
	
-- Move a rect {left,top,right,bottom}
function MoveRectX( rect, dx )
	rect.left = rect.left + dx
	rect.right = rect.right + dx
end
function MoveRectY( rect, dy )
	rect.top = rect.top + dy
	rect.bottom = rect.bottom + dy
end
function MoveRect( rect, dx, dy )
	MoveRectX( rect, dx )
	MoveRectY( rect, dy )
end

-- Window placement sanity check
function SanitizeWindowPosition( wndPos, wndSize ) -- TODO: unused
	local displayWidth, displayHeight = Turbine.UI.Display.GetSize();
	
	if wndPos.left < 0 then
		MoveRectX( wndPos, -wndPos.left ); end
	if wndPos.right > displayWidth then
		MoveRectX( wndPos, displayWidth - wndPos.right ); end
	if wndPos.top < 0 then
		MoveRectY( wndPos, -wndPos.top ); end
	if wndPos.bottom > displayHeight then
		MoveRectY( wndPos, displayHeight - wndPos.bottom ); end
end

--------------------------------------------------------------------------------
-- Window for instrument skill review/assignment 

function BaseWindow:Constructor( settings, configUI )
	Turbine.UI.Lotro.Window.Constructor( self );
	self.config = settings
	self.cfg = configUI
end

function BaseWindow:Create() -- Separate from constructor so Settings are loaded 

	-- Create resize control UI in the bottom right corner
	self.resizeCtrl = Turbine.UI.Control();
	self.resizeCtrl:SetParent( self );
	self.resizeCtrl:SetSize( 20, 20 );
	self.resizeCtrl:SetSize( 20, 20 );
	self.resizeCtrl:SetZOrder( 200 );

	-- Callbacks for resize control
	self.resizeCtrl.MouseDown = function( sender, args )
		sender.dragStartX = args.X;
		sender.dragStartY = args.Y;
		sender.dragging = true;
	end
	
	self.resizeCtrl.MouseUp = function( sender, args )
		sender.dragging = false;
	end
	
	self.resizeCtrl.MouseMove = function( sender, args )
		
		local width, height = self:GetSize();
	
		if sender.dragging then -- adapt UI layout to resizing
			width = width + args.X - sender.dragStartX;
			height = height + args.Y - sender.dragStartY;

			-- Keep width and height within min/max
			if width < self.cfg.siMin.x then width = self.cfg.siMin.x
			elseif width > self.cfg.siMax.x then width = self.cfg.siMax.x; end
			self:Resize( width, height )
		end
	end
end

function BaseWindow:FinalizeResize( width, height )
	self.config.pos.Width = width; self.config.pos.Height = height
	self.resizeCtrl:SetPosition( width - 20, height - 20 );
end

function BaseWindow:PositionChanged( sender, args )
	self.config.pos.Left = self:GetLeft()
	self.config.pos.Top = self:GetTop()
--Turbine.Shell.WriteLine( "move: "..tostring(sender)..","..tostring(args) )
end


--------------------------------------------------------------------------------
-- Window for instrument skill review/assignment 

function InstrSkillsWindow:Constructor( settings, configUI )
	BaseWindow.Constructor( self, settings, configUI );
end

function InstrSkillsWindow:Create( ) -- Separate from constructor so Settings are loaded 
	BaseWindow.Create( self )

	self:SetText( Strings["asnSkillsWnd"] );

	-- Instrument skills matrix -----------------------------------------------
	self.lbSkills = ListBoxInstrSkills:New( 10, 10, false, g_cfgUI.wndSkills );
	self.lbSkills:SetParent( self );
	
	self.cbEditSkills = CreateCB( self, "edit_skills", false, 
		function( sender, args ) skillsWindow.lbSkills:EnableItems( skillsWindow.cbEditSkills:IsChecked()); end );
	self.cbRcvSkills = CreateCB( self, "receive_skills", false, 
		function( sender, args )
			if sender:IsChecked() then sender:SetBackColor( self.lbSkills.cfg.colorHdgChanged )
			else sender:SetBackColor( g_cfgUI.colorDefaultBack ); end; end );

	-- Place UI items and show
	self:SetPosition( self.config.pos.Left, self.config.pos.Top )
	self:Resize( self.config.pos.Width, self.config.pos.Height )
	self:ShowUI()
	
	self.MouseClick = function( s, a ) if self.floatSC then self.floatSC:Hide( s ); end; end
end


-- Check if the current PartyMembers.aNames matches the headings
function InstrSkillsWindow:IsListUpdateNeeded( )
	if self.aLblHdgs and #self.aLblHdgs == PartyMembers:Count( ) then -- got labels, and their count matches player count
		for i = 1, #self.aLblHdgs do if self.aLblHdgs[ i ]:GetText( ) ~= PartyMembers:Name( i ) then return true; end; end
		return false
	end
	return true
end


local function Menu_ShowPlayers( lbParent, fClicked )
	local xPos, yPos = skillsWindow:GetMousePosition( )
	local contextMenu = Turbine.UI.ContextMenu();
	local menuItems = contextMenu:GetItems( )

	for i = 1, Players:Count( ) do
		menuItems:Add( ListBox.CreateMenuItem( Players:Name( i ), i, fClicked ) )
	end

	contextMenu:ShowMenu( ); -- shows at current mouse position
end

local function SkillsColumnMenu( sender, args )
	local listbox = skillsWindow.lbSkills
	if args.Button ~= Turbine.UI.MouseButton.Right then return; end
	
	local contextMenu = Turbine.UI.ContextMenu();
	local menuItems = contextMenu:GetItems( )
	
	if sender.bChanged then
		local sPlayer = sender:GetText( )
		menuItems:Add( ListBox.CreateMenuItem( Strings["asnSk_rejectcol"], sender.ID,
			function( s, a ) skillsWindow:ModifiedSkillsResponse( listbox.SetColumnStates, sender.ID ); end ) )
		menuItems:Add( ListBox.CreateMenuItem( Strings["asnSk_acceptcol"], sender.ID,
			function( s, a ) skillsWindow:ModifiedSkillsResponse( listbox.GetColumnStates, sender.ID ); end ) )
		menuItems:Add( ListBox.CreateMenuItem( Strings["asnSk_rejectall"], sender.ID,
			function( s, a ) skillsWindow:ModifiedSkillsResponse( listbox.SetColumnStates ); end ) )
		menuItems:Add( ListBox.CreateMenuItem( Strings["asnSk_acceptall"], sender.ID,
			function( s, a ) skillsWindow:ModifiedSkillsResponse( listbox.GetColumnStates ); end ) )
	end
	
	if skillsWindow.cbEditSkills:IsChecked( ) then
		menuItems:Add( ListBox.CreateMenuItem( Strings["asnSk_setcol"], sender.ID,
			function( s, a ) listbox:SetAllInColumn( true, s.ID ); end ) )
		menuItems:Add( ListBox.CreateMenuItem( Strings["asnSk_clrcol"], sender.ID,
			function( s, a ) listbox:SetAllInColumn( false, s.ID ); end ) )
		
		menuItems:Add( ListBox.CreateMenuItem( Strings["asnSk_copycol"], sender.ID,
			function( s, a ) listbox.colCopy:Clear( ); listbox:GetColumnStates( s.ID, listbox.colCopy ); end ) )
		local item = ListBox.CreateMenuItem( Strings["asnSk_pastecol"], sender.ID,
			function( s, a ) listbox:SetColumn( s.ID, listbox.colCopy ); end )
		item:SetEnabled( not listbox.colCopy:IsEmpty( ) ); menuItems:Add( item )
		
		menuItems:Add( ListBox.CreateMenuItem( Strings["asnSk_setall"], sender.ID,
			function( s, a ) listbox:SetAll( true ); end ) )
		menuItems:Add( ListBox.CreateMenuItem( Strings["asnSk_clrall"], sender.ID,
			function( s, a ) listbox:SetAll( false ); end ) )
	end
	
	local player = Turbine.Gameplay.LocalPlayer:GetInstance( )
	if player and player:GetName( ) and sender:GetText() == player:GetName( ) then
		local f = function( s, a )
			Instruments:SlotsToSkills( songbookWindow.instrSlot, player:GetName( ) )
			skillsWindow:UpdateSkills( player:GetName( ) ); end
		menuItems:Add( ListBox.CreateMenuItem( Strings["asnSk_transfer"], sender.ID, f ) )
	end
	
	local f = function( s, a ) skillsWindow:SendDataByIdx( sender.ID, s.ID, listbox:PointToScreen( listbox:GetMousePosition( ) ) ); end
	menuItems:Add( ListBox.CreateMenuItem( Strings["asnSk_send"], sender.ID,
		function( s, a ) Menu_ShowPlayers( listbox, f ); end ) )
	
	contextMenu:ShowMenu( ); -- shows at current mouse position
end

local function FloatSC_New( self, w, h, sIcon, sIcon_a, obj )
	obj = obj or {}; setmetatable( obj, self ); self.__index = self
	obj.width = w; obj.height = h
	obj.sIcon = sIcon; obj.sIcon_a = sIcon_a
	return obj
end

local function FloatSC_SetVisible( self, bVisible )
	if self.container then self.container:SetVisible( bVisible ); end
	self.icon:SetVisible( bVisible ); self:SetVisible( bVisible ); end
local function FloatSC_Hide( self ) FloatSC_SetVisible( self, false ); end
local function FloatSC_MouseEnter( s, a ) if s.sIcon_a then s.icon:SetBackground( gDir..s.sIcon_a..".tga" ); end; end
local function FloatSC_MouseLeave( s, a ) if s.sIcon_a then s.icon:SetBackground( gDir..s.sIcon..".tga" ); end; end

local function FloatSC_Show( self, parent, x, y )
	if self.qs then 
		FloatSC_SetVisible( self.qs, true )
	else
		self.qs = CreateShortcut( parent )
		self.qs:SetSize( self.width, self.height )
		self.qs.icon = CreateIcon( parent, self.sIcon )
		self.qs.icon:SetSize( self.width, self.height )
		self.qs.sIcon = self.sIcon
		self.qs.sIcon_a = self.sIcon_a
		self.qs.Hide = FloatSC_Hide
		self.qs.MouseClick = FloatSC_Hide
		self.qs.FocusLost = FloatSC_Hide
		self.qs.MouseEnter = FloatSC_MouseEnter
		self.qs.MouseLeave = FloatSC_MouseLeave
	end
	self.qs:SetPosition( x, y )
	self.qs.icon:SetPosition( x, y ); 
end

local function FloatSC_Activate( self, parent, sCmd, x, y, container )
	if x + self.width > parent:GetWidth( ) then x = parent:GetWidth( ) - self.width; end
	if y + self.height > parent:GetHeight( ) then y = parent:GetHeight( ) - self.height; end
	self:Show( parent, x, y )
	self.qs.container = container
	self.qs:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, sCmd ) )
	self.qs:Focus( )
end

FloatSC =
{
	qs = nil,
	New = FloatSC_New,
	SetVisible = function( self, bVisible ) FloatSC_SetVisible( self.qs, bVisible ); end,
	Show = FloatSC_Show,
	Activate = FloatSC_Activate,
	Hide = function( self, parent ) if self.qs and self.qs:HasFocus( ) then parent:Focus( ); end; end,
}



function InstrSkillsWindow:SendDataByIdx( iDataSrc, iDstPlayer, x, y )
	local sSrcPlayer = Players:Name( iDataSrc )
	local sDstPlayer = Players:Name( iDstPlayer )
	if sSrcPlayer and sDstPlayer then self:SendData( self, sSrcPlayer, sDstPlayer, x, y ); end
end

function InstrSkillsWindow:PrepareData( sSrcPlayer, sDstPlayer )
	local sData = self:DataToString( sSrcPlayer )
	if not sData then return nil; end
	return "/tell "..tostring( sDstPlayer ).." SB~Sk0~"..tostring( sSrcPlayer ).."~"..sData
end

function InstrSkillsWindow:SendData( parent, sSrcPlayer, sDstPlayer, x, y )
	local sCmd = self:PrepareData( sSrcPlayer, sDstPlayer )
	if sCmd then
		if not self.floatSC then self.floatSC = FloatSC:New( 125, 29, "icn_send" ); end
		self.floatSC:Activate( parent, sCmd, self:PointToClient( x, y ) );
		return true
	end
	return false
end

function InstrSkillsWindow:ReceiveData( sData )
	if self.cbRcvSkills and not self.cbRcvSkills:IsChecked( ) then
		local f1 = function( ) skillsWindow.cbRcvSkills:SetBackColor( self.lbSkills.cfg.colorHdgChanged ); end
		local f2 = function( ) skillsWindow.cbRcvSkills:SetBackColor( g_cfgUI.colorDefaultBack ); end
		songbookWindow:AddPeriodic( 10, 0.25, f1, f2 )
		return; end
	local aItems = SplitString( sData, "~" )
	if #aItems ~= 4 then WRITE( Strings["asnSk_invalidHdr"]..". "..Strings["asnSk_wrongVersion"]..".", 5 ); return; end
	local sSbk, sVersion, sName, sValues = aItems[ 1 ], aItems[ 2 ], aItems[ 3 ], aItems[ 4 ]
	local skills = self:StringToData( sValues )
	if not skills then return false; end
	self:UpdateSkills( sName, skills )
	return true
end
	
function InstrSkillsWindow:UpdateSkills( sName, skills )
	if not self.lbSkills or self.lbSkills:GetItemCount( ) <= 0 then return; end
	local iName = Players:Index( sName )
	if not iName then return; end
	if skills then self:SetSkillsModified( iName )
	else skills = SkillsData:Get( sName ); end
	self.lbSkills:SetColumnStates( iName, skills )
end

function InstrSkillsWindow:SetSkillsModified( iName )
	if not self.lbSkills or self.lbSkills:GetItemCount( ) <= 0 then return; end
	if not self.aLblHdgs or not self.aLblHdgs[ iName ] then return; end
	self.aLblHdgs[ iName ]:SetBackColor( self.cfg.colorHdgChanged )
	self.aLblHdgs[ iName ].bChanged = true
end

function InstrSkillsWindow:AcceptModifiedSkills( iName )
	local iStart = iName or 1
	local iEnd = iName or #self.aLblHdgs
	for i = iStart, iEnd do
		local sName = Players:Name( i )
		if sName and self.aLblHdgs[ i ]:GetBackColor( ) == self.lbSkills.cfg.colorHdgChanged then
			self.lbSkills:GetColumnStates( i, SkillsData:Get( sName, true ) ); end
		self.aLblHdgs[ i ]:SetBackColor( self.cfg.colorHdgChanged )
	end
end

function InstrSkillsWindow:RejectModifiedSkills( iName )
	local iStart = iName or 1
	local iEnd = iName or #self.aLblHdgs
	for i = iStart, iEnd do
		local sName = Players:Name( i )
		if sName and self.aLblHdgs[ i ]:GetBackColor( ) == self.lbSkills.cfg.colorHdgChanged then
			self.lbSkills:SetColumnStates( i, SkillsData:Get( sName ) ); end
		self.aLblHdgs[ i ]:SetBackColor( self.cfg.colorHdgChanged )
	end
end

function InstrSkillsWindow:ModifiedSkillsResponse( func, iName )
	local iStart = iName or 1
	local iEnd = iName or #self.aLblHdgs
	for i = iStart, iEnd do
		local sName = Players:Name( i )
		if sName and self.aLblHdgs[ i ].bChanged then
			func( self.lbSkills, i, SkillsData:Get( sName, true ) ); end
		self.aLblHdgs[ i ]:SetBackColor( g_cfgUI.colorLbHdg )
		self.aLblHdgs[ i ].bChanged = false
	end
end

function InstrSkillsWindow:StringToData( sData )
	if not sData or #sData < 1 then WRITE( Strings["asnSk_wrongFormat"]..". "..Strings["asnSk_wrongVersion"]..".", 5 ); return nil; end
	local skills = Skills:New( )
	for i = 1, #sData do
		local value = sData:byte( i, i ) - 0x20
		if value < 1 or value > Instruments:Count( ) then 
			WRITE( Strings["asnSk_invalidData"]..". "..Strings["asnSk_wrongVersion"]..".", 5 ); return nil; end
		skills:Add( Instruments:Uix( value ) )
	end
	
	return skills
end

function InstrSkillsWindow:DataToString( sName )
	local sResult = ""
	local skills = SkillsData:Get( sName )
	if not skills then WRITE( Strings["asnSk_noData"]..tostring(sName)..".", 5 ); return nil; end
	skills:CallGet( function( i, s ) if s then sResult = sResult..string.char( 0x20 + i ); end; end )
--	local iData, nData = 1, #aData
--	for i = 1, Instruments:Count() do
--		while iData <= nData and Instruments:Uix( i ) > aData[ iData ] do iData = iData + 1; end
--		if iData > nData then break; end
--		if Instruments:Uix( i ) == aData[ iData ] then 
--	end
	return sResult
end


-- Create heading row for the skills listbox (names of players in the group)
function InstrSkillsWindow:CreateHeadingRow( )
	if not self.aLblHdgs then self.aLblHdgs = {}; end

	for i = 1,  PartyMembers:Count( ) do -- Change text in present labels or create new ones
		if self.aLblHdgs[ i ] then self.aLblHdgs[ i ]:SetText( PartyMembers:Name( i ) )
		else self.aLblHdgs[ i ] = CreateHdgLabel( self, PartyMembers:Name( i ), SkillsColumnMenu, i ); end
	end
	for i =  PartyMembers:Count( ) + 1, #self.aLblHdgs do --delete any remaining labels
		self.aLblHdgs[ i ]:SetParent( nil )
		self.aLblHdgs[ i ] = nil;
	end
end

-- Create heading column (instruments)
function InstrSkillsWindow:CreateHeadingColumn( )
	self.aLblLeftHdgs = {}
	Instruments:IterStart( )
	local iHdg = 1
	while Instruments:IterNext() do
		self.aLblLeftHdgs[iHdg] = CreateHdgLabel( self, Instruments:IterName( ) )
		self.aLblLeftHdgs[iHdg]:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleRight );
		iHdg = iHdg + 1
	end
end

-- Add a player to the skills listbox
function InstrSkillsWindow:AddPlayer( sPlayerName )
	self.aLblHdgs[#self.aLblHdgs+1] = CreateHdgLabel( self, sPlayerName )
	self.lbSkills:AddColumn( SkillsData:Get( sPlayerName ) )
	self:UpdateSizeLimits( )
end

-- Remove a player from the skills listbox
function InstrSkillsWindow:RemovePlayer( sPlayerName )
	for i=1,#self.aLblHdgs do 
		if self.aLblHdgs[i].GetText() == sPlayerName then
			self.lbSkills:RemoveColumn( i )
			return
		end
	end
	self:UpdateSizeLimits( )
end

function InstrSkillsWindow:UpdatePlayers( aPlayers )
	self:UpdateSkillsList( )
end


-- Note that this will be called every time the button is pressed; if any UI
-- elements are created in here, consider whether they need to be destroyed first
function InstrSkillsWindow:Launch( aPlayers )
	self:SetVisible( true )
	self:UpdatePlayers( aPlayers )
end

-- If players list changed, update the skills listbox
function InstrSkillsWindow:UpdateSkillsList( )
	if not self:IsListUpdateNeeded( ) then return; end
	self:CreateHeadingRow( )
	self.lbSkills:Initialize( PartyMembers.aNames )
	self:UpdateSizeLimits( )
	self.lbSkills:EnableItems( self.cbEditSkills:IsChecked() )
	self:Resize( )
	self:ShowHeadings( true )
end

function InstrSkillsWindow:SaveSkills( )
	self.lbSkills:GetStates( PartyMembers.aNames )
end

function InstrSkillsWindow:RevertSkills( )
	self.lbSkills:SetStates( PartyMembers.aNames )
end

function InstrSkillsWindow:SetSkill( col, row, state )
	local sName = PartyMembers:Name( col )
	local skills = SkillsData:Get( sName, true )
	if not skills then return; end
	if row then
		if state then skills:AddIx( row )
		else skills:RemoveIx( row ); end
	else
		if state then skills:SetAll( )
		else skills:Clear( ); end
	end
end

function InstrSkillsWindow:ShowHeadings( bShow )
	bShow = bShow or true
	if self.aLblHdgs then for i=1,#self.aLblHdgs do self.aLblHdgs[i]:SetVisible( bShow ); end; end
end

function InstrSkillsWindow:ShowUI( bShow )
	bShow = bShow or true
	
	self:ShowHeadings( bShow )
	self.cbEditSkills:SetVisible( bShow )
	self.cbRcvSkills:SetVisible( bShow )
	self.lbSkills:SetVisible( bShow )
end


function InstrSkillsWindow:UpdateSizeLimits( )
	self.cfg:UpdateSizeLimits( #self.aLblHdgs, layout:HorIndent(), layout:VerIndent() )
end

function InstrSkillsWindow:Resize( width, height )
	if width then self:SetWidth( width ); else width = self:GetWidth(); end
	if height then self:SetHeight( height ); else height = self:GetHeight(); end
	layout:Reset( width, height )

	-- row of buttons
--	layout:SetSizes( self.cfg.btnRow.wiSave, self.cfg.btnRow.height ):PlaceItem( self.btnSaveSkills )
--	layout:ToRight( self.cfg.btnRow.spacing ):SetWidth( self.cfg.btnRow.wiRevert ):PlaceItem( self.btnRevertSkills )
--	layout:Below( layout.spacing.y )

	-- skills listbox with row and column headers plus edit checkbox in the header corner at top left
	-- group label
	layout:ToLeftBorder( )
--	layout:SetSize( g_cfgUI.siLbl )
--	layout:PlaceItem( self.lblAssignSkills )
--	layout:Below( 4 )
	-- edit checkbox wiEditCb = 80, wiReceiveCb
	layout:SetSizes( self.cfg.wiEditCb, self.cfg.siLblLeftHdg.y )
	layout:PlaceItem( self.cbEditSkills, 0, 0 ) -- checkbox aligns differently from label
	layout:SetSizes( self.cfg.wiReceiveCb, self.cfg.siLblLeftHdg.y )
	layout:ToRight(0):PlaceItem( self.cbRcvSkills, 0, 0 ) -- checkbox aligns differently from label
	layout:ToRight(0)
	-- horizontal headings (player names)
	self:SetColumnWidth( width )
	layout:SetSizes( self.cfg.wiLblHdg - g_cfgUI.lblHdgGap, self.cfg.siLblHdg.y )
	if self.aLblHdgs then
		for i=1,#self.aLblHdgs do
			layout:PlaceItem( self.aLblHdgs[i] )
			layout:ToRight( g_cfgUI.lblHdgGap )
		end
	end

	-- listbox (includes the line headers as first column)
	layout:Below():ToLeftBorder( )
	layout:SetMaxSize()
	layout:PlaceItem( self.lbSkills )
	self.lbSkills:Resize( )

	self:FinalizeResize( width, height )
end

function InstrSkillsWindow:FinalizeResize( width, height )
	BaseWindow.FinalizeResize( self, width, height )
end

function InstrSkillsWindow:SetColumnWidth( width )
	if not self.aLblHdgs or #self.aLblHdgs <= 0 then return self.cfg.siLblHdg.x; end
	self.cfg:SetLblHdgWidth( ( width - self.cfg:StaticSizeX() - layout:HorIndent() ) / #self.aLblHdgs )
end

--------------------------------------------------------------------------------
-- ListBox parts assignment

function ListBoxInstrAssign:New( scrollWidth, scrollHeight, bOrientation, config, listbox )
	listbox = listbox or ListBoxInstrAssign( scrollWidth, scrollHeight, bOrientation, config );
	setmetatable( listbox, self ); 
	self.__index = self;
	return listbox;
end

function ListBoxInstrAssign:Constructor( scrollWidth, scrollHeight, bOrientation, config )
	LBScroll.Constructor( self, scrollWidth, scrollHeight, bOrientation );
	self:SetOrientation( Turbine.UI.Orientation.Horizontal );
	self:SetMaxItemsPerLine( 2 )
	self.cfg = config
	self.iIter = 0
	self.ToggleReannounce = function( sender, args )
		if self:IsPlayerMarked( sender.ID, Marks.tag.inactive ) then return; end
		self:TogglePlayerMark( sender.ID, Marks.tag.reannounce )
		if self:IsPlayerMarked( sender.ID, Marks.tag.reannounce ) then assignWindow:AddSingleAnnounce( sender.ID )
		else assignWindow:RemoveSingleAnnounce( sender.ID ); end; end

end

function ListBoxInstrAssign:PlayerIndex( iLine ) return LBScroll.ColRowIdx( self, 1, iLine ); end
function ListBoxInstrAssign:PartIndex( iLine ) return LBScroll.ColRowIdx( self, 2, iLine ); end

function ListBoxInstrAssign:GetPlayerItem( iLine ) return LBScroll.ColRowItem( self, 1, iLine ); end
function ListBoxInstrAssign:GetPartItem( iLine ) return LBScroll.ColRowItem( self, 2, iLine ); end

function ListBoxInstrAssign:AddPlayerItem( playerName )
	local item = self:CreatePlayerItem( playerName ); LBScroll.AddItem( self, item ); return item; end
function ListBoxInstrAssign:AddPartItem( instrName )
	local item = self:CreatePartItem( instrName ); LBScroll.AddItem( self, item ); return item; end

function ListBoxInstrAssign:SetPlayerItem( iLine, sPlayername ) -- set text if item exists, otherwise create
	local item = self:GetPlayerItem( iLine )
	if item then item:SetText( sPlayername ); return item; end
	return self:AddPlayerItem( sPlayername ); end
function ListBoxInstrAssign:SetPartItem( iLine, sPartname )
	local item = self:GetPartItem( iLine )
	if item then item:SetText( sPartname ); return item; end
	return self:AddPartItem( sPartname ); end

function ListBoxInstrAssign:AddAssignment( iLine, sPlayername, sPartname )
	self:AddPlayerItem( sPlayername ).ID = iLine; self:AddPartItem( sPartname ).ID = iLine; end
function ListBoxInstrAssign:SetAssignment( iLine, sPlayername, sPartname )
	self:SetPlayerItem( iLine, sPlayername ).ID = iLine; self:SetPartItem( iLine, sPartname ).ID = iLine; end

function ListBoxInstrAssign:ClearItems()
	if self:GetItemCount( ) <= 0 then return; end
	LBScroll.ClearItems( self );
end


function ListBoxInstrAssign:MarkPlayer( iLine, mark ) self:MarkItem( mark, iLine, 1 ); end
function ListBoxInstrAssign:UnmarkPlayer( iLine, mark ) self:UnmarkItem( mark, iLine, 1 ); end
function ListBoxInstrAssign:TogglePlayerMark( iLine, mark ) self:ToggleMark( mark, iLine, 1 ); end
function ListBoxInstrAssign:IsPlayerMarked( iLine, mark ) return self:IsMarked( mark, iLine ); end
function ListBoxInstrAssign:ClearPlayerMarks( mark ) self:ClearMarks( mark, 1 ); end

function ListBoxInstrAssign:MarkPart( iLine, mark ) self:MarkItem( mark, iLine, 2 ); end
function ListBoxInstrAssign:UnmarkPart( iLine, mark ) self:UnmarkItem( mark, iLine, 2 ); end
function ListBoxInstrAssign:TogglePartMark( iLine, mark ) self:ToggleMark( mark, iLine, 2 ); end
function ListBoxInstrAssign:IsPartMarked( iLine, mark ) return self:IsMarked( mark, iLine ); end
function ListBoxInstrAssign:ClearPartMarks( mark) self:ClearMarks( mark, 2 ); end


function ListBoxInstrAssign:CreateItem( width )
	local item = Turbine.UI.Label();
	item:SetMultiline( false );
	item:SetSize( width, self.cfg.heLbItem );
	item.MouseDoubleClick = self.ToggleReannounce
	return item;
end

-- Menu for parts assign listbox: ----------------------------------------------

local function CmpMenuParts( v1, v2 ) -- compare by part number, handle empty parts
	local iPart1 = Players.GetPartnumber( v1.pn )
	local iPart2 = Players.GetPartnumber( v2.pn )
	if not iPart1 then
		if not iPart2 then return v1.pn < v2.pn; end -- couldn't read either part number, sort alphabetically
		return false; end -- only first without, sort in at end
	if not iPart2 then return true; end
	return iPart1 < iPart2; end

local function Menu_AddCurrentParts( lbParent, menuItems, itemPlayer )
	if Assigner:GetSongParts( selectedSongIndex, songbookWindow.iCurrentSetup ) ~= true then return; end
	
	local aParts = {}
	for i = 1, Assigner:PartCount( ) do
		aParts[ i ] = Assigner:PartString( i ); end
	table.sort( aParts, CmpMenuParts )
	for i = 1, #aParts do
		local f = function( sender, args )
			Assigner:ManualAssign( sender.ID, itemPlayer:GetText( ) ); lbParent:SetPartItem( itemPlayer.ID, aParts[ i ] );  end
		menuItems:Add( ListBox.CreateMenuItem( aParts[ i ], i, f ) ); end
end

local function Menu_IsValidForManualAssign( iInstr, uix, sPlayer )
	if Assigner:HasManualAssign( iInstr ) then return false; end -- already a manual assignment for this one
	if not Assigner:PlayerHasSkill( sPlayer, uix ) then return false; end -- player does not have the instrument skill
	if Assigner:IsNameVocalist( sPlayer) and Instruments:IsWindInstr( uix ) then return false; end -- vocalist/wind instr
	return true;
end

local function Menu_ShowCurrentParts( lbParent, tmp, itemPlayer )
	if Assigner:GetSongParts( selectedSongIndex, songbookWindow.iCurrentSetup ) ~= true then return; end
	
	local contextMenu = Turbine.UI.ContextMenu();
	local menuItems = contextMenu:GetItems( )

	local sPlayer = itemPlayer:GetText( )
	local aParts = {}
	for i = 1, Assigner:PartCount( ) do
		aParts[ i ] = { ["pn"] = Assigner:PartString( i ), ["uix"] = Assigner:PartUix( i ), ["iInstr"] = i }; end
	table.sort( aParts, CmpMenuParts )
	for i = 1, #aParts do
		local f = function( sender, args )
			Assigner:ManualAssign( aParts[ i ].iInstr, sPlayer ); lbParent:SetPartItem( itemPlayer.ID, aParts[ i ].pn );  end
		local item = ListBox.CreateMenuItem( aParts[ i ].pn, i, f )
		if not Menu_IsValidForManualAssign( i, aParts[ i ].uix, sPlayer ) then item:SetEnabled( false ); end
		menuItems:Add( item )
	end
	contextMenu:ShowMenu( ); -- shows at current mouse position
end

local function Menu_AddReannounce( lbParent, menuItems, id )
	if lbParent:IsPlayerMarked( id, Marks.tag.reannounce ) then
		menuItems:Add( ListBox.CreateMenuItem( Strings["asn_removePartial"], id, lbParent.ToggleReannounce ) );
	else
		menuItems:Add( ListBox.CreateMenuItem( Strings["asn_addPartial"], id, lbParent.ToggleReannounce ) );
	end
end

function ListBoxInstrAssign:UpdateVocals( )
	self:IterMark( )
	while self:NextMarked( Marks.tag.vocals ) do
		if Assigner:ClearManualAssignForVocalist( Players:Name( self:MarkIndex( ) ) ) then
			self:SetPartItem( self:MarkIndex( ), "" ); end
	end
end
	
local function AssignPlayerSelect( sender, args, lbParent )
	if Players:IsMarkSet( sender.ID, Marks.tag.inactive ) then return; end
	if SelectionKeyDown( ) then lbParent:TogglePlayerMark( sender.ID, Marks.tag.selected )
	else lbParent:ClearPlayerMarks( Marks.tag.selected ); lbParent:MarkPlayer( sender.ID, Marks.tag.selected ); end
end
	
local function AssignPlayerMenu( sender, args )
	local lbParent = assignWindow.lbAssigns
	if args.Button == Turbine.UI.MouseButton.Left then LBScroll.HandleSelection( lbParent, sender.ID, 1 ); return; end
	if args.Button ~= Turbine.UI.MouseButton.Right then return; end
	
	local contextMenu = Turbine.UI.ContextMenu();
	local menuItems = contextMenu:GetItems( )
	
	if lbParent:IsPlayerMarked( sender.ID, Marks.tag.inactive ) then
		menuItems:Add( ListBox.CreateMenuItem( Strings["asn_include"], sender.ID,
			function( sender, args )
					if lbParent:CountMarked( Marks.tag.selected ) <= 0 then lbParent:UnmarkPlayer( sender.ID, Marks.tag.inactive )
					else lbParent:UnmarkSelected( Marks.tag.inactive, 1 ); lbParent:ClearPlayerMarks( Marks.tag.selected ); end; end ) )
	else
		if not lbParent:IsPlayerMarked( sender.ID, Marks.tag.selected ) and lbParent:CountMarked( Marks.tag.selected ) > 0 then
			lbParent:ClearPlayerMarks( Marks.tag.selected ); lbParent:MarkPlayer( sender.ID, Marks.tag.selected ); end
		
		menuItems:Add( ListBox.CreateMenuItem( Strings["asn_exclude"], sender.ID,
				function( sender, args )
					if lbParent:CountMarked( Marks.tag.selected ) <= 0 then lbParent:MarkPlayer( sender.ID, Marks.tag.inactive )
					else lbParent:MarkSelected( Marks.tag.inactive, 1 ); lbParent:ClearPlayerMarks( Marks.tag.selected ); end; end ) )
		
		menuItems:Add( ListBox.CreateMenuItem( Strings["asn_vocalist"], sender.ID,
			function( sender, args ) lbParent:ToggleMarkSelected( Marks.tag.vocals, sender.ID, 1 ); lbParent:UpdateVocals( ); end ) )
		
		if lbParent:IsPlayerMarked( sender.ID, Marks.tag.reannounce ) then
			menuItems:Add( ListBox.CreateMenuItem( Strings["asn_removePartial"], sender.ID, lbParent.ToggleReannounce ) );
		else
			menuItems:Add( ListBox.CreateMenuItem( Strings["asn_addPartial"], sender.ID, lbParent.ToggleReannounce ) );
		end
	end 
	local item = ListBox.CreateMenuItem( Strings["asn_clearExclusion"], sender.ID,
		function( sender, args ) lbParent:ClearPlayerMarks( Marks.tag.inactive ); end )
	menuItems:Add( item ); if lbParent:CountMarked( Marks.tag.inactive ) <= 0 then item:SetEnabled( false ); end
	
	item = ListBox.CreateMenuItem( Strings["asn_clearVocalists"], sender.ID,
		function( sender, args ) lbParent:ClearPlayerMarks( Marks.tag.vocals ); end )
	menuItems:Add( item ); if lbParent:CountMarked( Marks.tag.vocals ) <= 0 then item:SetEnabled( false ); end
	
	menuItems:Add( ListBox.CreateMenuItem( Strings["asn_clearPartial"], sender.ID,
		function( sender, args ) lbParent:ClearPlayerMarks( Marks.tag.reannounce ); assignWindow:CreateAnnounceShortcut( ); end ) );
	
	item = ListBox.CreateMenuItem( Strings["asn_clearSelection"], sender.ID,
		function( sender, args ) lbParent:ClearPlayerMarks( Marks.tag.selected ); end )
	menuItems:Add( item ); if lbParent:CountMarked( Marks.tag.selected ) <= 0 then item:SetEnabled( false ); end

	-- menu showing the available parts to allow manual assignment
	item = ListBox.CreateMenuItem( Strings["asn_assign"].."...", sender.ID,
		function( s, a ) Menu_ShowCurrentParts( lbParent, nil, sender ); end )
	menuItems:Add( item );
	if not songbookWindow:SongAndSetupSelected( ) then item:SetEnabled( false ); end

	contextMenu:ShowMenu( ); -- shows at current mouse position
end

function ListBoxInstrAssign:CreatePlayerItem( player )
	local item = self:CreateItem( self.cfg.wiLblPlayer + g_cfgUI.lblHdgGap )
	item:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleCenter );
	item:SetText( player );
	item.MouseClick = AssignPlayerMenu
	return item;
end

function ListBoxInstrAssign:CreatePartItem( part )
	local item = self:CreateItem( self.cfg.wiLblInstr + g_cfgUI.lblHdgGap )
	item:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
	item:SetText( part );
	return item;
end


function ListBoxInstrAssign:InitPlayerMarks( iLine )
	
	if self:IsPlayerMarked( iLine, Marks.tag.inactive ) then self:MarkPlayer( iLine, Marks.tag.inactive ); end
	if self:IsPlayerMarked( iLine, Marks.tag.vocals ) then self:MarkPlayer( iLine, Marks.tag.vocals ); end -- re-apply vocalist mark too
	if self:IsPlayerMarked( iLine, Marks.tag.reannounce ) then self:UnmarkPlayer( iLine, Marks.tag.reannounce ); end
	if self:IsPlayerMarked( iLine, Marks.tag.selected ) then self:MarkPlayer( iLine, Marks.tag.selected ); end
end

function ListBoxInstrAssign:Initialize( )
	self.aPlayers = Players
	self:ClearItems( )
	for iLine = 1, Players:Count( ) do -- set text for existing items (will be created if necessary)
		self:AddAssignment( iLine, Players:Name( iLine ), Players:Part( iLine ) )
		self:InitPlayerMarks( iLine )
	end
end

function ListBoxInstrAssign:Resize( width )
	self.cfg:ComputeSizeX( width )
	for i = 1, self:GetItemCount( ) do
		if ( i % 2 ) == 1 then self:GetItem( i ):SetWidth( self.cfg.wiLblPlayer )
		else self:GetItem( i ):SetWidth( self.cfg.wiLblInstr ); end
	end
end

--------------------------------------------------------------------------------
-- Window for instrument assignment 

function InstrAssignWindow:Constructor( settings, configUI )
	BaseWindow.Constructor( self, settings, configUI );
end
	
function InstrAssignWindow:Create()
	BaseWindow.Create( self )
	
	--self:SetZOrder( 20 );
	self:SetText( Strings["assignWnd"] );
	self.cfg:Init( )
	self.config.listOrderBy = self.config.listOrderBy or "n"
	self.config.targetChat = self.config.targetChat or "g"
	self.sAnnounce = ""
	self.aPartialAnnounce = {}
	
	-- target chat selection --------------------------------------------------
	self.lblTargetChat = CreateGroupLabel( self, "asn_chat" );
	
	if self.config.targetChat == "a" then self.config.targetChat = "g"; end -- TODO: HACK
--	self.cbChatAuto = CreateCBnoState( self, "asn_chat_auto", 
--		function( sender, args ) if sender:IsChecked() then assignWindow:ChangeTarget("a"); end; end );
	self.cbChatGroup = CreateCBnoState( self, "asn_chat_group", 
		function( sender, args ) if sender:IsChecked() then assignWindow:ChangeTarget("g"); end; end );
	self.cbChatRaid = CreateCBnoState( self, "asn_chat_raid", 
		function( sender, args ) if sender:IsChecked() then assignWindow:ChangeTarget("r"); end; end );
	self.cbChatCustom = CreateCBnoState( self, "asn_chat_custom", 
		function( sender, args ) if sender:IsChecked() then assignWindow:ChangeTarget("c"); end; end );
	-- edit control for custom chat prefix
	self.editCustomChat = Turbine.UI.Lotro.TextBox();
	self.editCustomChat:SetParent( self );
	self.editCustomChat:SetMultiline( false );
	self.editCustomChat:SetFont( Turbine.UI.Lotro.Font.Verdana14 );
	self.editCustomChat:SetText( "" );
	self.editCustomChat.FocusLost = function( sender, args ) self:SetChatPrefix( ); self:UpdateAnnounceShortcut( ); end
	-- Set initial state of checkboxes according to self.config.targetChat
	self:SetTargetCheckBoxes( )

	-- Create button
	local f = function(s,a) if a.Button == Turbine.UI.MouseButton.Left then assignWindow:CreateAssignment(); end; end
	self.btnCreate = CreateButton( self, "asn_btn_create", f )
	
	-- Skills config button
	f = function(s,a) if a.Button == Turbine.UI.MouseButton.Left then skillsWindow:Launch( ); end; end
	self.btnConfig = CreateButton( self, "asnSk_btnLaunch", f )
	
	f = function(s,a) if a.Button == Turbine.UI.MouseButton.Left then priosWindow:Launch( ); end; end
	self.btnPrios = CreateButton( self, "asnPrio_btnLaunch", f )

	self.qsAnnounce = CreateShortcut( self )
	self.qsAnnounce:SetEnabled( false )
	--self.qsAnnounce:SetZOrder( 20 );
	self.iconAnnounce = CreateIcon( self, "icn_btnAnnounce" )
	self.qsAnnounce.MouseEnter = function( sender, args )
		self.iconAnnounce:SetBackground( gDir .. "icn_btnAnnounce_hover.tga" ); end
	self.qsAnnounce.MouseLeave = function( sender, args )
		self.iconAnnounce:SetBackground( gDir .. "icn_btnAnnounce.tga" ); end

	
	-- Assignment list -----------------
	self.lblAssignParts = CreateGroupLabel( self, "asn_list", 300 );
	self.aLblHdgs = {}
	self.aLblHdgs[1] = CreateHdgLabel( self, Strings["asn_player"] )
	self.aLblHdgs[1].MouseClick = function(s,a) assignWindow:SortByName( ); end
	self.aLblHdgs[2] = CreateHdgLabel( self, Strings["asn_part"] )
	self.aLblHdgs[2].MouseClick = function(s,a) assignWindow:SortByPart( ); end

	self.lbAssigns = ListBoxInstrAssign:New( 10, 10, false, g_cfgUI.wndAssign.lbParts );
	self.lbAssigns:SetParent( self );
	
	self.lbAssigns:Initialize( )

	self:SetPosition( self.config.pos.Left, self.config.pos.Top )
	self:Resize( self.config.pos.Width, self.config.pos.Height )
	self:ShowUI()
end


function InstrAssignWindow:Launch( )
	PartyMembers:Update( songbookWindow.aPlayers )
	self:UpdatePlayers( PartyMembers.aNames )
	self:SetVisible( true )
end

function InstrAssignWindow:CopyPlayers( aPlayers )
	Players:Reset( )
	for i = 1, #aPlayers do
		Players:Add( aPlayers[ i ] )
		--self.aPartsList[ #self.aPartsList + 1 ] = { ["player"] = aPlayers[ i ], ["part"] = "", ["mark"] = 0 };
	end
	self:UpdatePartsList( )
end

function InstrAssignWindow:UpdatePlayers( aPlayers )
	self:CopyPlayers( aPlayers )
	skillsWindow:UpdatePlayers( aPlayers )
	priosWindow:UpdatePlayers( aPlayers )
end

function InstrAssignWindow:PartsString( )
	local s = ""
	for i = 1, Players:Count( ) do
		if not Players:IsMarkSet( i, Marks.tag.inactive ) and Players:HasPart( i ) then
			s = s.."\n* "..Players:Name( i )..":   "..Players:Part( i )
		end
	end
	return s
end

function InstrAssignWindow:CreateAnnounceShortcut( sParts )
	sParts = sParts or self:PartsString( )
	self.sAnnounce = "\n"..Strings["asn_nextSong"]..":\n"..songbookWindow:GetSongName()..sParts; self:UpdateAnnounceShortcut( ); end

function InstrAssignWindow:UpdateAnnounceShortcut( )
	if self.qsAnnounce then
		self.qsAnnounce:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Alias, self.sPrefix.." "..self.sAnnounce ) ); end; end

function InstrAssignWindow:ClearAnnounceShortcut( )
	if self.qsAnnounce then
		self.qsAnnounce:SetEnabled( false ); self.sAnnounce = ""; self.qsAnnounce:SetShortcut( Turbine.UI.Lotro.Shortcut( Turbine.UI.Lotro.ShortcutType.Undef, "" ) ); end; end


function InstrAssignWindow:AddSingleAnnounce( iLine )
	self.aPartialAnnounce[ #self.aPartialAnnounce + 1 ] = iLine
	table.sort( self.aPartialAnnounce )
	self:SingleAnnounce( )
end

function InstrAssignWindow:RemoveSingleAnnounce( iLine )
	for i = 1, #self.aPartialAnnounce do
		if self.aPartialAnnounce[ i ] == iLine then
			table.remove( self.aPartialAnnounce, i )
			if #self.aPartialAnnounce > 0 then self:SingleAnnounce( )
			else self:CreateAnnounceShortcut(); end
			return
		end
	end
end

function InstrAssignWindow:SingleAnnounce( iLine )
	local sParts = ""
	for i = 1, #self.aPartialAnnounce do
		sParts = sParts.."\n* "..Players:Name( self.aPartialAnnounce[ i ] )..":   "..Players:Part( self.aPartialAnnounce[ i ] )
	end
	self:CreateAnnounceShortcut( sParts )
	self:UpdateAnnounceShortcut( )
end

function InstrAssignWindow:ExecAssignerCreate( )
	self:ClearPartsData( )
	local aPlayers = self:GetActivePlayers( )
	if songbookWindow:HasSetups( ) and not songbookWindow:SelectSetupForCount( #aPlayers ) then
		WRITE( Strings["asn_noSetupAvail"] )
		return; end
	
	if Assigner:CreateAssignment( aPlayers ) then
		local sPart
		for i = 1, Players:Count( ) do
			sPart = Assigner:PartForPlayer( Players:Name( i ) ) -- inactive players were not in aPlayers list
			if sPart then Players:SetPart( i, sPart ); end
		end
		self:UpdatePartsList( )
		return true
	end
	
	self:RefreshPartsList( ) -- removes the parts 
	return false
end

-- Call Assigner to create the assignment, show in listbox, and create the shortcut for the announcement
function InstrAssignWindow:CreateAssignment( )
	if #self.aPartialAnnounce > 0 then self.aPartialAnnounce = {}; end
		
	if self:ExecAssignerCreate( ) then
		self:CreateAnnounceShortcut( self:PartsString( ) )
		self.qsAnnounce:SetEnabled( true )
	else
		self:ClearAnnounceShortcut( )
		self.qsAnnounce:SetEnabled( false )
	end
end

function InstrAssignWindow:GetActivePlayers( )
	local aPlayers = {}
	for i = 1, Players:Count( ) do 
		if not Players:IsMarkSet( i, Marks.tag.inactive ) then
			aPlayers[ #aPlayers + 1 ] = Players:Name( i ); end
	end
	return aPlayers
end


function InstrAssignWindow:NewSongSelected( iSong )
	self:ClearPartsData( )
	self:UpdatePartsList( )
end

function InstrAssignWindow:ClearPartsData( )
	Players:ClearParts( )
end

function InstrAssignWindow:UpdatePartsList( s )
	s = s or self.config.listOrderBy; if s == "n" then self:SortByName( ) else self:SortByPart( ); end; end
	
function InstrAssignWindow:RefreshPartsList( ) self.lbAssigns:Initialize( ); end

function InstrAssignWindow:SortByName( )
	self.config.listOrderBy = "n"
	Players:SortByName( )
	self.aLblHdgs[1]:SetForeColor( self.cfg.lbParts.colorHdgTextSelected )
	self.aLblHdgs[2]:SetForeColor( self.cfg.lbParts.colorHdgText )
	self:RefreshPartsList( )
	self:CreateAnnounceShortcut( self:PartsString( ) ); end

function InstrAssignWindow:SortByPart( )
	self.config.listOrderBy = "p"
	Players:SortByPart( )
	self.aLblHdgs[1]:SetForeColor( self.cfg.lbParts.colorHdgText )
	self.aLblHdgs[2]:SetForeColor( self.cfg.lbParts.colorHdgTextSelected )
	self:RefreshPartsList( )
	self:CreateAnnounceShortcut( self:PartsString( ) ); end


function InstrAssignWindow:SetChatPrefix( )
	self.sPrefix = "/f"
	if self.config.targetChat == "r" then self.sPrefix = "/ra"; return
	elseif self.config.targetChat == "c" then self.sPrefix = self.editCustomChat:GetText(); return
	elseif self.config.targetChat ~= "a" then return
	end
	
	if PartyMembers:Count( ) > 6 then self.sPrefix = "/ra" -- a simple default 
	else self.sPrefix = "/f"; end
end


function InstrAssignWindow:SetTargetCheckBox( cb, b )
	cb:SetChecked( b )
	cb:SetEnabled( not b )
end

function InstrAssignWindow:SetTargetCheckBoxes( )
	self:SetTargetCheckBox( self.cbChatGroup, self.config.targetChat == "g" )
	self:SetTargetCheckBox( self.cbChatRaid, self.config.targetChat == "r" )
	self:SetTargetCheckBox( self.cbChatCustom, self.config.targetChat == "c" )
	self.editCustomChat:SetEnabled( self.cbChatCustom:IsChecked() )
	self:SetChatPrefix( )
	self:UpdateAnnounceShortcut( )
end

function InstrAssignWindow:ChangeTarget( target )
	if self.config.targetChat ~= target then
		self.config.targetChat = target
		self:SetTargetCheckBoxes( )
	end
end

function InstrAssignWindow:UpdateSizeLimits( )
	self.cfg:UpdateSizeLimits( #self.aLblHdgs, layout:HorIndent(), layout:VerIndent() )
end

function InstrAssignWindow:ShowUI( bShow )
	bShow = bShow or true
	
	self.lblTargetChat:SetVisible( bShow )
	--self.cbChatAuto:SetVisible( bShow )
	self.cbChatGroup:SetVisible( bShow )
	self.cbChatRaid:SetVisible( bShow )
	self.cbChatCustom:SetVisible( bShow )

	self.btnCreate:SetVisible( bShow )
	self.iconAnnounce:SetVisible( bShow )
	self.qsAnnounce:SetVisible( bShow )
	self.btnConfig:SetVisible( bShow )
	self.btnPrios:SetVisible( bShow )

	self.lblAssignParts:SetVisible( bShow )
	for i=1,#self.aLblHdgs do self.aLblHdgs[i]:SetVisible( bShow ); end
	self.lbAssigns:SetVisible( bShow )
end

function InstrAssignWindow:Resize( width, height )
	if width then self:SetWidth( width ); else width = self:GetWidth(); end
	if height then self:SetHeight( height ); else height = self:GetHeight(); end
	layout:Reset( width, height ):SetPos( layout.indent.left, layout.indent.top )
	
	-- group label: target chat 
	layout:SetSize( g_cfgUI.siLbl ):PlaceItem( self.lblTargetChat )
	layout:Below(0)
	layout:SetSize( self.cfg.siCbChat ):PlaceItem( self.cbChatGroup ) 
	layout:ToRight(0):PlaceItem( self.cbChatRaid ) 
	layout:ToRight(0):PlaceItem( self.cbChatCustom ) 
	layout:ToRight(0):SetWidth( self.cfg.wiEditCustomChat ):PlaceItem( self.editCustomChat )

	layout:Below():ToLeftBorder():SetSizes( self.cfg.btnRow.wiCreate, self.cfg.btnRow.height ):PlaceItem( self.btnCreate )
	layout:ToRight( self.cfg.btnRow.spacing ):SetWidth( self.cfg.btnRow.wiAnn )
		layout:PlaceItem( self.qsAnnounce ):PlaceItem( self.iconAnnounce, 0, 1, -3, 4 )
	layout:ToRightBorder():SetWidthR( self.cfg.btnRow.wiPrios ):PlaceItem( self.btnPrios )
	layout:ToLeft( self.cfg.btnRow.spacing ):SetWidthR( self.cfg.btnRow.wiSkills ):PlaceItem( self.btnConfig )

	-- group label: parts list
	layout:Below():ToLeftBorder()
	layout:SetSize( g_cfgUI.siLbl )
	layout:PlaceItem( self.lblAssignParts )
	layout:Below(0)

	self.lbAssigns:Resize( width - layout:HorIndent( ) )
	layout:ToLeftBorder( ):SetSizes( self.cfg.lbParts.wiLblPlayer-1, self.cfg.lbParts.heLbItem ):PlaceItem( self.aLblHdgs[1] )
	layout:ToRight(2):SetWidth( self.cfg.lbParts.wiLblInstr -1 ):PlaceItem( self.aLblHdgs[2] )
	layout:Below(0):ToLeftBorder():SetMaxSize():PlaceItem( self.lbAssigns )
	
	self:FinalizeResize( width, height )
end

function InstrAssignWindow:FinalizeResize( width, height )
	BaseWindow.FinalizeResize( self, width, height )
end


--------------------------------------------------------------------------------
-- ListBox for priority selection

function ListBoxPrioEdit:New( scrollWidth, scrollHeight, bOrientation, config, listbox )
	listbox = listbox or ListBoxPrioEdit( scrollWidth, scrollHeight, bOrientation, config );
	setmetatable( listbox, self );
	self.__index = self;
	return listbox;
end

function ListBoxPrioEdit:Constructor( scrollWidth, scrollHeight, bOrientation, config )
	LBScroll.Constructor( self, scrollWidth, scrollHeight, bOrientation );
	self:SetOrientation( Turbine.UI.Orientation.Vertical );
	self.cfg = config
end


function ListBoxPrioEdit:EditItem( i )
	return LBScroll.GetItem( self, i );
end

function ListBoxPrioEdit:LabelItem( i )
	return LBScroll.GetItem( self, self.cfg:LineCount( ) + i );
end

function ListBoxPrioEdit:ClearEdits()
	for i = 1, self.cfg:LineCount( ) do self:EditItem( i ).SetText( "" ); end
end

local function LbPrio_KeyDown( sender, args )
	if args.Action == 162 then priosWindow.lbPrios:Item_EnterKey( sender.ID ); return; end
end
local function LbPrio_TextChanged( sender, args )
	local s = sender:GetText( )
	if #s > 1 then s = s:sub( 1, 1 ); end
	if not sender.validChars:find( s ) then s = ""; end
	if s ~= sender:GetText( ) then sender:SetText( s ); end
end
local function LbPrio_Wheel( sender, args )
	if Turbine.UI.Control.IsControlKeyDown() then priosWindow.lbPrios:Item_MouseWheel( sender.ID, args.Direction ); end; end
local function LbPrio_MouseEnter( sender, args ) priosWindow.lbPrios:Item_MouseEnter( sender.ID ); end
local function LbPrio_MouseLeave( sender, args ) priosWindow.lbPrios:Item_MouseLeave( sender.ID ); end

function ListBoxPrioEdit:CreateLabelItem( parent, sText )
	local label = Turbine.UI.Label( )
	label:SetParent( parent )
	label:SetMultiline( false )
	label:SetBackColor( g_cfgUI.colorLbItem )
	label:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft )
	label:SetOutlineColor( Turbine.UI.Color( 1, 0.5, 0.0, 0.0 ) )
	label:SetSize( self.cfg.wiLabel, self.cfg.heLbItems ) -- + g_cfgUI.lblHdgGap );
	label:SetText( sText );
	label.MouseWheel = LbPrio_Wheel
	label.MouseEnter = LbPrio_MouseEnter
	label.MouseLeave = LbPrio_MouseLeave
	return label;
end

function ListBoxPrioEdit:CreateEditItem( )
	local editItem = Turbine.UI.TextBox();
	editItem:SetMultiline( false );
	editItem:SetSize( self.cfg.wiEdit, self.cfg.heLbItems );
	editItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleCenter );
	editItem.validChars = self.cfg.validChars
	editItem.KeyDown = LbPrio_KeyDown
	editItem.MouseWheel = LbPrio_Wheel
	editItem.TextChanged = LbPrio_TextChanged
	return editItem;
end

function ListBoxPrioEdit:AddLabelColumn( )
	for i = 1, self.cfg:LineCount( ) do
		local item = self:CreateLabelItem( self, self.cfg:LabelText( i ) )
		LBScroll.AddItem( self, item );
		item.ID = i
	end
end

function ListBoxPrioEdit:AddEditColumn( )
	for i = 1, self.cfg:LineCount( ) do
		local item = self:CreateEditItem( )
		LBScroll.AddItem( self, item )
		item.ID = i
	end
end

function ListBoxPrioEdit:FillEditColumn( )
	for i = 1, self.cfg:LineCount( ) do
		local item = self:EditItem( i )
		local sText = self.cfg:EditContent( i )
		item:SetText( sText )
		item:SetBackColor( self.cfg:EditColor( sText ) )
	end
end

function ListBoxPrioEdit:Initialize(  )
	if LBScroll.GetItemCount( self ) > 0 then return; end -- already initialized
	LBScroll.SetMaxItemsPerLine( self, self.cfg:LineCount( ) );
	self:AddEditColumn( )
	self:AddLabelColumn( )
end

function ListBoxPrioEdit:Set( sPlayer )
	self.cfg.sPlayer = sPlayer
	self:FillEditColumn( )
end

function ListBoxPrioEdit:Item_EnterKey( id )
	local item = self:GetItem( id )
	local sText = item:GetText()
	if self.cfg:ContentOK( id, sText ) then
		self.cfg:SaveEntry( id, sText )
		item:SetBackColor( self.cfg:EditColor( sText ) )
		end
	priosWindow:Focus( ) 
end

function ListBoxPrioEdit:Item_MouseWheel( id, d )
	local item = self:GetItem( id )
	local sText = item:GetText()
	local val = tonumber( sText ); if not val then val = 0; end
	val = val + d
	if val <= 0 then
		sText = ""
	else
		if val > self.cfg.maxPrio then val = self.cfg.maxPrio; end
		sText = tostring( val )
	end
	item:SetText( sText )
	item:SetBackColor( self.cfg:EditColor( sText ) )
	if self.cfg:ContentOK( id, sText ) then self.cfg:SaveEntry( id, sText ); end
end

function ListBoxPrioEdit:Item_MouseEnter( id )
	self:LabelItem( id ):SetBackColor( g_cfgUI.colorLbItemSelected )
end
			
function ListBoxPrioEdit:Item_MouseLeave( id )
	self:LabelItem( id ):SetBackColor( g_cfgUI.colorLbItem )
end

function ListBoxPrioEdit:Resize( )
	if LBScroll.GetItemCount( self ) <= 0 then return; end
	for i = 1, self.cfg:LineCount( ) do 
		local item = self:LabelItem( i )
		item:SetWidth( self.cfg.wiLabel );
	end
end

function ListBoxPrioEdit:SetSize( w, h )
	self.cfg.wiLabel = w - self.cfg.wiEdit - self.scrollBarv:GetWidth( );
	self:Resize( )
	LBScroll.SetSize( self , w - self.scrollBarv:GetWidth( ) - 10, h )
end

function ListBoxPrioEdit:EnableItems( bEnable )
	if bEnable == nil then bEnable = true; end
	for i = 1, self.cfg:LineCount( ) do
		local item = self:EditItem( i )
		item:SetEnabled( bEnable );
	end
end
	
--------------------------------------------------------------------------------
-- ListBox showing players with known priorities as read from Settings

local function PrioListboxMenu( sender, args )
	--local lbParent = priosWindow.lbPlayers
	if not priosWindow.cbAllPlayers:IsChecked( ) then return; end -- menu currently not for current, since they are determined by Party
	if args.Button ~= Turbine.UI.MouseButton.Right then return; end
	
	local contextMenu = Turbine.UI.ContextMenu()
	local menuItems = contextMenu:GetItems( )
	
	menuItems:Add( ListBox.CreateMenuItem( Strings["asn_addPlayer"], nil,
		function( s, a ) ListBox.PlayerEntry( sender, sender.cfg.siLbItem.x, sender.cfg.siLbItem.y ); end ) )

	if sender:CountMarked( Marks.tag.selected ) > 0 then
		menuItems:Add( ListBox.CreateMenuItem( Strings["asn_removeSelPlayers"], nil, 
			function( s, a ) sender:RemoveSelectedPlayers( ); end ) )
	end

	contextMenu:ShowMenu( )
end


local function PrioPlayerMenu( sender, args )
	local lbParent = priosWindow.lbPlayers
	if not priosWindow.cbAllPlayers:IsChecked( ) then return; end -- menu currently not for current, since they are determined by Party
	if args.Button == Turbine.UI.MouseButton.Left then LBScroll.HandleSelection( lbParent, sender.ID, 1 ); return; end
	if args.Button ~= Turbine.UI.MouseButton.Right then return; end
	
	local contextMenu = Turbine.UI.ContextMenu();
	local menuItems = contextMenu:GetItems( )
	
	menuItems:Add( ListBox.CreateMenuItem( Strings["asn_addPlayer"], sender.ID,
		function( s, a ) ListBox.PlayerEntry( lbParent, lbParent.cfg.siLbItem.x, lbParent.cfg.siLbItem.y ); end ) )

	menuItems:Add( ListBox.CreateMenuItem( Strings["asn_removePlayer"], sender.ID, 
		function( s, a ) lbParent:RemovePlayer( s.ID ); lbParent:ListPlayers( ); end ) )

	if lbParent:CountMarked( Marks.tag.selected ) > 0 then
		menuItems:Add( ListBox.CreateMenuItem( Strings["asn_removeSelPlayers"], sender.ID, 
			function( s, a ) lbParent:RemoveSelectedPlayers( ); end ) )
	end

	local item = ListBox.CreateMenuItem( Strings["asnSk_clrsel"], sender.ID,
		function( sender, args ) lbParent:ClearMarks( Marks.tag.selected, 1 ); end )
	menuItems:Add( item ); if lbParent:CountMarked( Marks.tag.selected ) <= 0 then item:SetEnabled( false ); end

	contextMenu:ShowMenu( ); -- shows at current mouse position
end


function ListBoxPrioPlayers:New( scrollWidth, scrollHeight, bOrientation, config, listbox )
--Turbine.Shell.WriteLine( "ListBoxPrioPlayers:New" );
	listbox = listbox or ListBoxPrioPlayers( scrollWidth, scrollHeight, bOrientation, config );
	setmetatable( listbox, self ); --setmetatable( listbox, LBScroll );
	self.__index = self;
	self.MouseClick = PrioListboxMenu
	self.aPlayers = PlayersMark:New( )
	self.aPrioPlayers = nil
	return listbox;
end

function ListBoxPrioPlayers:Constructor( scrollWidth, scrollHeight, bOrientation, config )
	LBScroll.Constructor( self, scrollWidth, scrollHeight, bOrientation );
	self:SetOrientation( Turbine.UI.Orientation.Vertical );
	self.cfg = config
end


function ListBoxPrioPlayers:CreateItem( parent, i )
	local label = Turbine.UI.Label( )
	label:SetParent( parent )
	label:SetMultiline( false )
	label:SetBackColor( g_cfgUI.colorLbItem )
	label:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft )
	label:SetSize( self.cfg.siLbItem.x, self.cfg.siLbItem.y ) -- + g_cfgUI.lblHdgGap );
	label:SetText( self.aPlayers:Name( i ) );
	label.ID = i
	label.MouseClick = PrioPlayerMenu
	return label;
end


local function ListBox_CreateMenuItem( sText, id, fnClick )
	local newItem = Turbine.UI.MenuItem( sText )
	if id then newItem.ID = id; end
	if fnClick then newItem.Click = fnClick; end
	return newItem
end

local function ListBox_PlayerEntry( lb, width, height )
	local textBox = Turbine.UI.Lotro.TextBox( )
	textBox:SetParent( lb )
	textBox:SetMultiline( false );
	textBox:SetFont( g_cfgUI.fontNormal )
	textBox:SetBackColor( g_cfgUI.colorLbItemSelected )
	textBox:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft )
	textBox:SetSize( width, height )
	textBox:SetVisible( true )
	textBox:SetText( Strings["asn_enterPlayer"] )
	textBox:SetSelection( 1, textBox:GetTextLength( ) )
	textBox.KeyDown = function( s, a ) if a.Action == 162 then ListBox.FinalizePlayerEntry( lb, textBox ); end; end
	lb:AddItem( textBox )
	textBox:Focus( )
end

local function ListBox_FinalizePlayerEntry( lb, textBox )
	local s = textBox:GetText( )
	lb:Focus()
	lb:RemoveItem( textBox )
	textBox = nil
	ListBox.PlayerEntered( lb, s )
end

local function ListBox_PlayerEntered( lb, s )
	local aPlayers = SplitWords( s )
	if #aPlayers <= 0 then return 0; end
	local nAccepted = 0
	for i = 1, #aPlayers do
		if lb:LbCb_AddPlayer( ( aPlayers[ i ]:gsub( "^%l", string.upper ) ) ) then
			nAccepted = nAccepted + 1; end
	end
	lb:LbCb_PlayersEntered( nAccepted )
end

ListBox =
{
	CreateMenuItem = ListBox_CreateMenuItem,
	PlayerEntry = ListBox_PlayerEntry,
	FinalizePlayerEntry = ListBox_FinalizePlayerEntry,
	PlayerEntered = ListBox_PlayerEntered,
}

function ListBoxPrioPlayers:LbCb_PlayersEntered( n )
	if n > 0 then self:ListPlayers( ); end
end

function ListBoxPrioPlayers:LbCb_AddPlayer( sPlayer )
	if not self.aPrioPlayers then return false; end
	self.aPrioPlayers:Add( sPlayer )
	return true
end

function ListBoxPrioPlayers:RemovePlayer( i )
	if not self.aPlayers:RemoveAt( i ) then return false; end
	self.aPrioPlayers:RemoveAt( i )
	if self.cfg.iSelected >= i then
		self.cfg.iSelected = self.cfg.iSelected - 1
		if self.cfg.iSelected < 1 then self.cfg.iSelected = 1; end
	end
	return true
end

function ListBoxPrioPlayers:RemoveSelectedPlayers( )
	self:IterMark( )
	local aRemove = {}
	local bRemoved = false
	while self:NextMarked( Marks.tag.selected ) do
		aRemove[ #aRemove + 1 ] = self:MarkIndex( ); end
	for i = #aRemove, 1, -1 do
		bRemoved = self:RemovePlayer( aRemove[ i ] ) or bRemoved
	end
	if bRemoved then self:ListPlayers( ); end
end

function ListBoxPrioPlayers:SetPlayers( sFilter )
	self.aPrioPlayers = sFilter == "a" and PriosData or Players
end

function ListBoxPrioPlayers:CopyPlayers( )
	self.aPlayers:Reset( )
	for i = 1, self.aPrioPlayers:Count( ) do self.aPlayers:Add( self.aPrioPlayers:Name( i ) ); end
end

function ListBoxPrioPlayers:ListPlayers( )
	self:CopyPlayers( )
	if LBScroll.GetItemCount( self ) > 0 then LBScroll.ClearItems( self ); end
	for i = 1, self.aPlayers:Count( ) do
		local item = self:CreateItem( self, i )
		LBScroll.AddItem( self, item );
	end
	if self.cfg.iSelected and self.cfg.iSelected <= LBScroll.GetItemCount( self ) then
		self:SetSelectedIndex( self.cfg.iSelected ); end
end

function ListBoxPrioPlayers:Initialize( lbDetails, sFilter )
	self.cfg.lbDetails = lbDetails
	self:SetPlayers( sFilter )
	self.aPlayers:ClearAllMarks( Marks.tag.selected )
	self.cfg.iSelected = nil
	self:ListPlayers( )
	self:SetSelectedIndex( 1 )
end


function ListBoxPrioPlayers:ChangeSelectedItem( )
	if self.cfg.iSelected then
		self:ClearActiveVisuals( self.cfg.iSelected ); end
	self.cfg.iSelected = self:GetSelectedIndex( )
	self.cfg.lbDetails:Set( self:GetItem( self.cfg.iSelected ):GetText( ) )
	if self.cfg.iSelected then
		self:SetActiveVisuals( self.cfg.iSelected ); end
end

function ListBoxPrioPlayers:SetActiveVisuals( i )
	local item = self:GetItem( i )
	if not item then return; end
	item:SetFont( self.cfg.fontActive )
	item:SetForeColor( self.cfg.colorActive );
end

function ListBoxPrioPlayers:ClearActiveVisuals( i )
	local item = self:GetItem( i )
	if not item then return; end
	item:SetFont( g_cfgUI.fontNormal )--Verdana14 ) -- TrajanPro13 BookAntiqua14 Arial12
	item:SetForeColor( g_cfgUI.colorDefault );
end

function ListBoxPrioPlayers:ResizeColumn( iCol, width )
	for i = self.aPlayers:Count( ) * (iCol-1) + 1, self.aPlayers:Count( ) * iCol do 
		local item = LBScroll.GetItem( self, i )
		item:SetWidth( width );
	end
end

function ListBoxPrioPlayers:Resize( )
	if LBScroll.GetItemCount( self ) <= 0 then return; end
	self:ResizeColumn( 1, self.cfg.siLbItem.x )
end
	
function ListBoxPrioPlayers:SetSize( w, h )
	self.cfg.siLbItem.x = w
	self:Resize( )
	LBScroll.SetSize( self , w, h )
end

	
--------------------------------------------------------------------------------
-- Window for priorities assignment 

function InstrPrioWindow:Constructor( settings, configUI )
	BaseWindow.Constructor( self, settings, configUI );
end
	
function InstrPrioWindow:Create()
	BaseWindow.Create( self )
	
	self:SetText( Strings["assignPriosWnd"] );
	self.bIsInitialized = false
	self.cfg:Init()
	if self.config.bIsInitialized then self.config.bIsInitialized = nil; end -- hack to remove
	self.config.playerFilter = self.config.playerFilter or "c"

	-- Assignment list -----------------
	self.cbCurrentPlayers = CreateCBnoState( self, "asn_prios_current", 
		function( sender, args ) if sender:IsChecked() then priosWindow:ChangePlayerFilter("c"); end; end );
	self.cbAllPlayers = CreateCBnoState( self, "asn_prios_all", 
		function( sender, args ) if sender:IsChecked() then priosWindow:ChangePlayerFilter("a"); end; end );

	self.lbPrios = ListBoxPrioEdit:New( 10, 10, false, self.cfg.lbPrios );
	self.lbPrios:SetParent( self );
	self.lbPrios:SetPosition( 20, 20 )

	self.lbPlayers = ListBoxPrioPlayers:New( 10, 10, false, self.cfg.lbPlayers );
	self.lbPlayers:SetParent( self );
	self.lbPlayers:SetPosition( 20, 20 )
	self.lbPlayers.SelectedIndexChanged = function( sender, args ) sender:ChangeSelectedItem() ; end
	--self.lbPlayers:Initialize( self.lbPrios, self.config.playerFilter )

	-- Place UI items and show
	self:SetPosition( self.config.pos.Left, self.config.pos.Top )
	self:Resize( self.config.pos.Width, self.config.pos.Height )
	self:ShowUI()
end


function InstrPrioWindow:Launch( )
	self:SetPlayersCheckBoxes( )
	self:SelectPlayer( 1 )
	self:SetVisible( true )
	self.bIsInitialized = true
end

function InstrPrioWindow:ListPlayers( )
	self.lbPrios:Initialize(  )
	self.lbPlayers:Initialize( self.lbPrios, self.config.playerFilter )
	self:SelectPlayer( 1 )
end

function InstrPrioWindow:UpdatePlayers( )
	if not self.bIsInitialized or self.config.playerFilter ~= "c" then return; end
	self.lbPlayers:Initialize( self.lbPrios, self.config.playerFilter )
	self:SelectPlayer( 1 )
end

function InstrPrioWindow:SelectPlayer( iPlayer )
	self.lbPlayers:SetSelectedIndex( iPlayer )
end


function InstrPrioWindow:SetPlayersCheckBox( cb, b )
	cb:SetChecked( b )
	cb:SetEnabled( not b )
end

function InstrPrioWindow:SetPlayersCheckBoxes( )
	self:SetPlayersCheckBox( self.cbCurrentPlayers, self.config.playerFilter == "c" )
	self:SetPlayersCheckBox( self.cbAllPlayers, self.config.playerFilter == "a" )
	self:ListPlayers( )
end

function InstrPrioWindow:ChangePlayerFilter( filter )
	if self.config.playerFilter ~= filter then
		self.config.playerFilter = filter
		self:SetPlayersCheckBoxes( )
	end
end



function InstrPrioWindow:ShowUI( bShow )
	bShow = bShow or true
	
	self.cbCurrentPlayers:SetVisible( bShow )
	self.cbAllPlayers:SetVisible( bShow )
	
	self.lbPlayers:SetVisible( bShow )
	self.lbPrios:SetVisible( bShow )
end

function InstrPrioWindow:Resize( width, height )
	if width then self:SetWidth( width ); else width = self:GetWidth(); end
	if height then self:SetHeight( height ); else height = self:GetHeight(); end
	layout:Reset( width, height ):SetPos( layout.indent.left, layout.indent.top )
	
	layout:SetSize( self.cfg.siCbFilter ):PlaceItem( self.cbCurrentPlayers ) 
	layout:ToRight( 0 ):PlaceItem( self.cbAllPlayers ) 

	self.cfg:UpdateWidths( width - layout:HorIndent( ) )
	layout:Below( ):ToLeftBorder():SetWidth( self.cfg.lbPlayers:Width( ) ):SetMaxHeight( ):PlaceItem( self.lbPlayers )
	layout:ToRight( ):SetWidth( self.cfg.lbPrios:Width( ) ):SetMaxHeight( ):PlaceItem( self.lbPrios )
	
	self:FinalizeResize( width, height )
end

function InstrPrioWindow:FinalizeResize( width, height )
	BaseWindow.FinalizeResize( self, width, height )
end


-----------------------------
-- Instruments drop list
-----------------------------
LbInstruments = class( ListBoxScrolled )

function LbInstruments:New( scrollWidth, scrollHeight, listbox )
	listbox = listbox or LbInstruments( scrollWidth, scrollHeight, false );
	setmetatable( listbox, self );
	self.__index = self;
	return listbox;
end

function LbInstruments:Constructor( scrollWidth, scrollHeight )
	ListBoxScrolled.Constructor( self, scrollWidth, scrollHeight, false )
	self.sorting = "a"
	self:SetBackColor( Turbine.UI.Color( 1, 0.1, 0.1, 0.1 ) )
	self:SetZOrder( 320 )
end


function LbInstruments:Initialize( aUix )
	self.aUix = aUix
	local n = Instruments:ListRelevantSlots( self.aUix, self )
	if n <= 0 then return; end
end


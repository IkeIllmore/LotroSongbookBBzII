
--------------------------------------------------------------------------------
-- Some generic functions

function SplitString( s, sSeps )
	local aParts = {}
	local sMatch = "([^"..sSeps.."]+)"
	string.gsub( s, sMatch, function( v ) aParts[ #aParts + 1 ] = v; end )
	return aParts
end

function SplitWords( s )
	local aParts = {}
	string.gsub( s, "(%w+)", function( v ) aParts[ #aParts + 1 ] = v; end )
	return aParts
end

function Count( t )
	local n = 0; for _ in pairs(t) do n = n + 1; end; return n
end

function table.Copy( t )
  local nt = { }
  for k,v in pairs(t) do nt[k] = v end
  return nt
end

function table.GetKey( t, e )
  for k,v in pairs(t) do if v == e then return k; end; end
  return nil
end

function table.Contains( t, e ) return table.GetKey( t, e ) ~= nil; end

function PrintNum( v, at )
	if v==nil or #v<=0 then return "(nil)"; end
	local sBuffer = "("..tostring(at(v,1))
	for i=2,#v do
		sBuffer = sBuffer..", "..tostring(at(v,i))
	end
	return sBuffer..")"
end


-- Server data --------------------------------------------

local function DataSavedCB( result, message )
	if result then WRITE( SuccessRGB..Strings["SDOk"].."</rgb>" )
	else WRITE( FailRGB..Strings["SDFail"]..message.."</rgb>" ); end
end

ServerData =
{
	aData = nil,
	Load = function( self, sTag ) self.aData = SongbookLoad( Turbine.DataScope.Server, sTag ); end,
	IsValid = function( self ) return self.aData ~= nil; end,
	Verify = function( self ) if not self.aData then self.aData = { ["Version"] = "1.0" }; end; end,
	Save = function( self ) SongbookSave( Turbine.DataScope.Server, SongbookDataTag, self.aData, DataSavedCB ); end,
	Part = function( self, sKey ) return self.aData[ sKey ]; end,
	SetPart = function( self, sKey, aData ) self.aData[ sKey ] = aData; end,
	ClearPart = function( self, sKey ) self.aData[ sKey ] = nil; end,
}


-- Skills data --------------------------------------------

local function Skills_New( self, val )
	local obj = {}
	setmetatable( obj, self )
	self.__index = self
	obj.value = val or 0
	return obj
end

local function Skills_ShValue( self, i ) return math.floor( self.value / 2^(i-1) ); end
local function Skills_ContainsIx( self, i ) return i and self:ShValue( i ) % 2 == 1 or false; end
local function Skills_Contains( self, uix ) return self:ContainsIx( Instruments:IndexForUix( uix ) ); end

local function Skills_AddIx( self, i )
	if not self:ContainsIx( i ) then self.value = self.value + 2^(i-1); end; end
local function Skills_Add( self, uix )
	local i = Instruments:IndexForUix( uix )
--if not i then WRITE( "<rgb=#FF0000>Fault at uix="..tostring(uix) ); end --TODO: remove
	if not i then WRITE( "<rgb=#FF8800>Ignoring invalid iID "..tostring( uix ).." (likely a version mismatch).</rgb>" ); return; end
	self:AddIx( Instruments:IndexForUix( uix ) ); end

local function Skills_RemoveIx( self, i ) if self:ContainsIx( i ) then self.value = self.value - 2^(i-1); end; end
local function Skills_Remove( self, uix ) self:RemoveIx( Instruments:IndexForUix( uix ) ); end

local function Skills_CallSet( self, fSet )
	local shVal = 0
	for i = Instruments:Count( ), 1, -1 do
		shVal = shVal * 2
		if fSet( i ) then shVal = shVal + 1; end
	end
	self.value = shVal
end
local function Skills_CallSetByMap( self, aMap ) self:CallSet( function( i ) return aMap[ Instruments:Uix( i ) ] == true; end ); end

local function Skills_CallGet( self, fCb )
	local shVal = self.value
	for i = 1, Instruments:Count( ) do
		fCb( i, shVal % 2 == 1 )
		shVal = math.floor( shVal / 2 )
	end
end

local function Skills_Print( self )
	local a = {}
	local shVal = self.value
	for i = 1, Instruments:Count( ) do
		if shVal % 2 == 1 then a[ #a + 1 ] = Instruments:Uix( i ); end
		shVal = math.floor( shVal / 2 )
	end
	return tostring( self.value).."="..table.concat( a, "," )
end

Skills =
{
	value = 0,
	New = Skills_New,
	ShValue = Skills_ShValue,
	Set = function( self, v ) self.value = v; end,
	ContainsIx = Skills_ContainsIx,
		Contains = Skills_Contains,
	AddIx = Skills_AddIx,
		Add = Skills_Add,
	RemoveIx = Skills_RemoveIx,
		Remove = Skills_Remove,
	CallSet = Skills_CallSet,
		SetByMap = Skills_CallSetByMap,
	CallGet = Skills_CallGet,
	Clear = function( self ) self.value = 0; end,
	SetAll = function( self ) self.value = 2 ^ Instruments:Count() - 1; end,
	IsEmpty = function( self ) return not self.value or self.value < 1; end,
	Print = Skills_Print,
}


local function SkillData_Init( self )
end

local function SkillData_CheckVersion( self, settings )
	if settings.Assign and settings.Assign.aSkills then --TODO: remove Skills init in SongbookWindow.lua
		if self.aSkills and Count( self.aSkills ) > 0 then
			WRITE( "Ignoring V0 skills data since V"..self.version.." data is present." ); return; end
		self.aSkills = self:Convert( settings.Assign.aSkills, 0 )
		WRITE( "Skills converted from V0 to V"..self.version )
		settings.Assign.aSkills = nil
	end
end

local function SkillData_CopyFromSD( self )
	local aData = ServerData:Part( "Skills" )
	--self.aSkills = self:ToArr( aData )
	if not aData then return; end
	self.version = aData.version
	for k, v in pairs( aData.aSkills ) do
		self.aSkills[ k ] = Skills:New( tonumber( v ) )
	end
	ServerData:ClearPart( "Skills" )
end

local function SkillData_CopyToSD( self )
	local aData = { version = self.version, aSkills = {} }
	for k, v in pairs( self.aSkills ) do
		aData.aSkills[ k ] = tostring(v.value)
	end
	ServerData:SetPart( "Skills", aData )
end

local function SkillData_ToNum( self, aSkills )
	local aNums = {}
	local num = 0
	for player, arr in pairs( aSkills ) do
		local iArr = #arr
		for i = Instruments:Count( ), 1, -1 do
			num = num * 2
			if iArr >= 1 and arr[iArr ] == Instruments:Uix( i ) then
				num = num + 1;
				iArr = iArr - 1
			end
		end
		aNums[ player ] = num
	end
	return aNums
end

local function SkillData_ToArr( self, aNums )
	local aSkills = {}
	for player, num in pairs( aNums ) do
		local arr = {}
		for i = 1, Instruments:Count( ) do
			if num % 1 == 1 then arr[ #arr + 1 ] = Instruments:Uix( i ); end
			num = math.floor( num / 2 )
		end
		aSkills[ player ] = arr
	end
	return aSkills
end

local function SkillData_Convert( self, aData, oldVersion )
	if type(oldVersion) == "string" then oldVersion = tonumber( oldVersion ); if not oldVersion then return; end; end
	local aNewData = {}
	if oldVersion == 0 then
		for player, aSkills in pairs( aData ) do
			local newSkills = Skills:New( )
			for i = 1, #aSkills do
				local val = aSkills[ i ]
				if val < 701 then newSkills:Add( val )
				elseif val > 701 then newSkills:Add( val - 100 ); end
			end
			aNewData[ player ] = newSkills
		end
	end
	return aNewData
end

local function SkillData_Add( self, sName, uix )
	if not self.aSkills[ sName ] then self.aSkills[ sName ] = Skills:New( ); end
	if uix then self.aSkills[ sName ]:Add( uix ); end
end

local function SkillData_Remove( self, sName, uix )
	local skills = self.aSkills[ sName ]
	if not uix then skills = nil; return; end
	if skills then skills:Remove( uix ); end
end

local function SkillData_Print( self )
	local a = {}
	for name, skills in pairs( self.aSkills ) do
		a[ #a + 1 ] = name..":"..skills:Print( )
	end
	return "SkillsData:\n"..table.concat( a, "\n" )
end


SkillsData =
{
	aSkills = {},
	version = "1.0",
--	aPlayers = nil,
--	nPlayers = 0,

	Init = SkillData_Init,
	CheckVersion = SkillData_CheckVersion,
	CopyFromSD = SkillData_CopyFromSD,
	CopyToSD = SkillData_CopyToSD,
		ToNum = SkillData_ToNum,
		ToArr = SkillData_ToArr,
		Convert = SkillData_Convert,
	Count = function( self ) return Count( aSkills ); end,
	Add = SkillData_Add,
	Remove = SkillData_Remove,
	Set = function( self, sName, v )
		if not self.aSkills[ sName ] then self:Add( sName ); end; self.aSkills[ sName ]:Set( v ); end,
	Get = function( self, sName, bCreate )
		if bCreate and not self.aSkills[ sName ] then self:Add( sName ); end; return self.aSkills[ sName ]; end,
	Has = function( self, sName, uix )
		if not self.aSkills[ sName ] then return false; end; return self.aSkills[ sName ]:Contains( uix ); end,
	Print = SkillData_Print,
}


-- Priority data ------------------------------------------

local function PriosData_Init( self )
	if self.aPlayers then return; end -- already initialized
	self.aPlayers = { }
	self.aTag = {}
	self.nPlayers = 0
	for _,aInstrPrios in pairs( self.aPrios ) do
		for sPlayer in pairs( aInstrPrios ) do
			self:Add( sPlayer )
		end
	end
	--table.sort( self.aPlayers )
end

local function PriosData_CheckVersion( self, settings )
	if settings.Assign and settings.Assign.aPrios then --V0
		if self.aPrios and Count( self.aPrios ) > 0 then
			settings.Assign.aPrios = nil
			WRITE( "Ignoring V0 prio data since V"..self.version.." data is present." )
			return; end
		local fMod = function( uix, prio )
			if uix >= 701 then uix = uix - 100; end
			prio = math.floor( prio * 5/9 + 0.5 ) 
			return uix, prio; end
		if self:CopyFromData( settings.Assign, fMod ) then
			self.version = "1.0"
			WRITE( "Preferences converted from V0 to V"..self.version )
			settings.Assign.aPrios = nil
		else
			WRITE( "Failed to convert prio data from V0 to V"..self.version..", prios may not be available." )
		end
	end
end

local function PriosData_CopyFromSD( self )
	if self:CopyFromData( ServerData:Part( "Prios" ) ) then ServerData:ClearPart( "Prios" ); end
	return false
end
local function PriosData_CopyFromData( self, aData, fMod )
	if not aData or not aData.aPrios then return false; end
	self.version = aData.version
	local fCb = function( sUix, player, sPrio )
		local uix, prio = tonumber( sUix ), tonumber( sPrio )
		if fMod then uix, prio = fMod( uix, prio ); end
		if not self.aPrios[ uix ] then self.aPrios[ uix ] = {}; end
		self.aPrios[ uix ][ player ] = prio
		end
	self:IterV1( fCb, nil, aData.aPrios )
	return true
end

local function PriosData_CopyToSD( self )
	local aData = { version = self.version, aPrios = {} }
	local fCb = function( uix, player, prio )
		local sUix = tostring( uix )
		if not aData.aPrios[ sUix ] then aData.aPrios[ sUix ] = {}; end
		aData.aPrios[ sUix ][ player ] = tostring( prio )
		end
	self:IterV1( fCb )
	ServerData:SetPart( "Prios", aData )
end

local function PriosData_IterV1uix( self, fCb, aData ) aData = aData or self.aPrios; for uix, _ in pairs( aData ) do fCb( uix ); end; end
local function PriosData_IterV1( self, fCb, fCbUix, aData )
	aData = aData or self.aPrios; 
	for uix, aPrios in pairs( aData ) do
		if fCbUix then fCbUix( uix ); end
		for player, prio in pairs( aPrios ) do
			fCb( uix, player, prio )
		end
	end
end


local function PriosData_Add( self, sPlayer )
	for i = 1, self.nPlayers do
		if sPlayer <  self.aPlayers[ i ] then
			table.insert( self.aPlayers, i, sPlayer ); self.nPlayers = self.nPlayers + 1; return; end
		if sPlayer ==  self.aPlayers[ i ] then return; end -- don't insert the same player twice
	end
	self.nPlayers = self.nPlayers + 1
	self.aPlayers[ self.nPlayers ] = sPlayer -- append
end

local function PriosData_RemoveAt( self, i )
	if i <= 0 or i > self.nPlayers then return false; end
	local sName = self.aPlayers[i ]
	table.remove( self.aPlayers, i ); self.nPlayers = self.nPlayers - 1
	for _,aInstrPrios in pairs( self.aPrios ) do -- Remove every occurrence of player in self.aPrios
		for sPlayer in pairs( aInstrPrios ) do
			if sPlayer == sName then aInstrPrios[ sPlayer ] = nil; end
		end
	end
	return false
end

local function PriosData_ForUixPlayer( self, uix, sPlayer )
	local aInstr = self:ForUix( uix )
	if not aInstr then return nil; end
	return aInstr[ sPlayer ]
end

local function PriosData_SetForPlayer( self, uix, sPlayer, prio )
	if not self:ForUix( uix ) then self:AddUix( uix ); end
	if prio == 0 then prio = nil; end
	self.aPrios[ uix ][ sPlayer ] = prio
	local next = next; if next(self.aPrios[ uix ]) == nil then self.aPrios[ uix ] = nil; end -- remove table for instrument if empty
end

local function PriosData_CreateMergedTable( self )
	local tMerged = {}
	for uix, tPrios in pairs( self.aPrios ) do
		for sPlayer, prio in pairs( tPrios ) do
			tMerged[#tMerged+1] = { ["prio"] = prio, ["instr"] = uix, ["player"] = sPlayer, ["used"] = false }
		end
	end
	return tMerged
end

local function PriosData_Print( self )
	local a = {}
	local fCb = function( uix, player, prio )
		a[ uix ][ #a[ uix ] + 1 ] = tostring(player)..":"..tostring(prio); end
	self:IterV1( fCb, function( uix ) a[ uix ] = {}; end )
	local b = {}
	for uix, a in pairs( a ) do
		b[ #b + 1 ] = "\n"..tostring(uix)..": "..table.concat( a, "/" )
	end
	return "PriosData:"..table.concat( b )
end


PriosData =
{
	version = "1.0",
	aPrios = {},
	aPlayers = nil,
	nPlayers = 0,

	Init = PriosData_Init,
	CheckVersion = PriosData_CheckVersion,
	CopyFromSD = PriosData_CopyFromSD,
	CopyFromData = PriosData_CopyFromData,
	CopyToSD = PriosData_CopyToSD,
	IterV1uix = PriosData_IterV1uix,
	IterV1 = PriosData_IterV1,
	Count = function( self ) return self.nPlayers; end,
	Name = function( self, i ) return self.aPlayers[ i ]; end,
	Index = function( self, sName ) for i = 1, #self.aPlayers do if self.aPlayers[ i ] == sName then return i; end; end return nil; end,
	Add = PriosData_Add,
	RemoveAt = PriosData_RemoveAt,
	Remove = function( self, sName ) self:RemoveAt( self:Index( sName ) ); end,
	AddUix = function( self, uix ) self.aPrios[ uix ] = {}; end,
	ForUix = function( self, uix ) return self.aPrios[ uix ]; end,

	ForUixPlayer =PriosData_ForUixPlayer,
	SetForPlayer = PriosData_SetForPlayer,
	CreateMergedTable = PriosData_CreateMergedTable,
	Print = PriosData_Print,
}


--------------------------------------------------------------------------------
-- Instrument name, index, type-index, and combined id (type-index * 100 + index)

local function Instruments_CreateMap( self )
	self:IterStart( )
	self.count = 0
	while self:IterNext( ) do
		self.count = self.count + 1
		self.mapIxUix[ self.count ] = self.iBase * 100 + self.iVariant --TODO: fiddle
		self.mapUixIx[ self.mapIxUix[ self.count ] ] = self.count
	end
end

local function Instruments_IterNext( self )
	local aVariants = self:Variants( self.iBase )
	if aVariants then
		self.iVariant = self.iVariant + 1
		if self.iVariant <= #aVariants then return true; end
	end
	self.iVariant = 1
	self.iBase = self.iBase + 1
	return self:IterValid( );
end

local function Instruments_NameBaseVariant( self, iBase, iVariant ) -- get instrument name for base/variant index
--Turbine.Shell.WriteLine( "iBase="..tostring(iBase)..", iVariant="..tostring(iVariant) )
	local aVariants = self.mapIndexToVariants[ iBase ]
	if iVariant ~= 0 and aVariants then
--Turbine.Shell.WriteLine( "aVariants: "..PrintStrArray( aVariants) )
		return aVariants[ iVariant ]
	end
	return self.aInstruments[ iBase ]
end

-- Check instrument equipment slot and return instrument
--local function Instruments_GetEquipped( self )
--	local player = Turbine.Gameplay.LocalPlayer:GetInstance();
--	if player then
--		local equip = player:GetEquipment( );
--		if equip then 
--			local item = equip:GetItem( Turbine.Gameplay.Equipment.Instrument )
--			if item then return item:GetName( ); end
--		end
--	end
--	return Strings["asn_noInstrument"]

-- Setup callbacks for instrument slot
local function Instruments_SetInstrCBs( self, fEquip, fUnEquip )
	local player = Turbine.Gameplay.LocalPlayer:GetInstance();
	if player then
		local equip = player:GetEquipment( );
		if equip then
			if fEquip then
				local idInstr = Turbine.Gameplay.Equipment.Instrument
				equip.ItemEquipped = function( s, a ) if a.Index == idInstr then fEquip( s:GetItem( idInstr ) ); end; end
				equip.ItemUnequipped = function( s, a ) if a.Index == idInstr then fUnEquip( s:GetItem( idInstr ) ); end; end
			end
			local item = equip:GetItem( Turbine.Gameplay.Equipment.Instrument )
			if item then return item:GetName( ); end
		end
	end
	return Strings["asn_noInstrument"]
end

local function Instruments_ScanSlots( self, aSlots, fCb )
	for no, qs in pairs( aSlots ) do
		local sc = qs:GetShortcut( )
		if sc then
			local item = sc:GetItem( )
			if item and item:GetName( ) then
				local sName = item:GetName( )
--if sName == "Student's Fiddle" then sName = "Satakieli"; end
				local uix = self:GetUixFromString( sName ) --self:UixForName( sName )
				if not uix then
					local sRootInstr = sName:match( " (%w+)$" )
					if sRootInstr then 
						uix = self:UixForName( sRootInstr ); end
				end
				if uix then fCb( uix, qs ); end
				--if uix then self.mapNameSC[ uix ] = qs; aSkills[ #aSkills + 1 ] = uix; end
			end
		end
	end
end	

local function Instruments_SlotsToSkills( self, aSlots, sName )
	local aInstr = {}
	self:ScanSlots( aSlots, function( uix, qs ) aInstr[ uix ] = true; end )
	if Count( aInstr ) <= 0 then WRITE( "No instruments found in quickslot bar." ); return false; end
	local aStored = SkillsData:Get( sName, true )
	aStored:SetByMap( aInstr )
	return true
end


-- Setup callbacks for instrument slot
local function Instruments_ReadSlots( self, aSlots )
	self.mapNameSC = {}
	self:ScanSlots( aSlots, function( uix, qs ) self.mapNameSC[ uix ] = qs; end )
end

-- Setup callbacks for instrument slot
local function Instruments_ListRelevantSlots( self, aUix, listbox )
	if not self.mapNameSC or #self.mapNameSC <= 0 then self:ReadSlots( songbookWindow.instrSlot ); end
	listbox:ClearItems( )
	listbox:SetOrientation( Turbine.UI.Orientation.Horizontal );
	listbox:SetMaxItemsPerLine( 2 )
	--local aUix = Instruments.mapIxUix
	local aListed = {}
	for i = 1, #aUix do
		if not aListed[ aUix[ i ] ] then
			aListed[ aUix[ i ] ] = true
			local qs = self.mapNameSC[ aUix[ i ] ]
			if qs and qs:GetShortcut( ) then
					local label = Turbine.UI.Label( )
					label:SetParent( listbox )
					label:SetMultiline( false )
					label:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleRight )
					label:SetSize( 180, 35 )
					label:SetText( self:NameForUix( aUix[ i ] ) );
					label:SetBackColor( Turbine.UI.Color( 1, 0.1, 0.1, 0.1 ) )
					--label:SetVisible( true )
				listbox:AddItem( label )
				local sc = Turbine.UI.Lotro.Shortcut( qs:GetShortcut():GetType( ), qs:GetShortcut():GetData( ) )
				local qs = Turbine.UI.Lotro.Quickslot( )
				qs:SetSize( 35, 35 )
				qs:SetShortcut( sc )
				listbox:AddItem( qs )
				qs.MouseClick = function( s, a ) songbookWindow.lbSlots:SetVisible( false ); end
			end
		end
	end
	return listbox:GetItemCount( ) / 2
end

local function Instruments_GetUixFromString( self, s )
	local sClean = CleanString( s:lower() )
	local iBase, sBaseName, iVariant, sVariantName = GetTrackInstrument( sClean, 0 )
	if not iBase then return nil; end
	return self:CreateUix( iBase, iVariant )
end

local Instruments_varBase = { ["bassoon"]=2,["cowbell"]=4,["fiddle"]=6,["harp"]=8,["lute"]=10 }

local InstrVars = 
{
	aIdx = { ["bassoon"]=2,["cowbell"]=4,["fiddle"]=6,["harp"]=8,["lute"]=10 },
	aBassoon = { "basic bassoon", "lonely mountain bassoon", "brusque bassoon" },
	aFiddle = {
		"basic fiddle", "student's fiddle", "traveller's trusty fiddle", "sprightly fiddle", "lonely mountain fiddle", "bardic fiddle" },
	aHarp = { "basic harp", "misty mountain harp" },
	aLute = { "basic lute", "lute of ages" },
	aCowbell = { "basic cowbell", "moor cowbell"},
}

Instruments = 
{
	count = 0, -- will be computed in Setup()
	iBase = 0,
	iVariant = 0,
	mapIxUix = {},
	mapUixIx = {},
	variants = InstrVars,
	aWindClass = { [1]=true, [2]=true, [3]=true, [7]=true, [9]=true, [11]=true }, --bagpipe,bassoon,clarinet,flute,horn,pibgorn
	aInstruments =
	{	-- (Nim) removed double and made German Geige a syn for Fiedel
	--"bagpipe", "bassoon", "clarinet", "cowbell", "drum", "fiddle", "fiddle", "flute", "harp", "horn", "lute", "pibgorn", "theorbo"
		"bagpipe", "bassoon", "clarinet", "cowbell", "drum", "fiddle", "flute", "harp", "horn", "lute", "pibgorn", "theorbo"
	},--1		      2		     3           4          5       6         7        8       9       10      11          12
	mapIndexToVariants =
	{
		[ InstrVars.aIdx["bassoon"] ] = InstrVars.aBassoon,
		[ InstrVars.aIdx["cowbell"] ] = InstrVars.aCowbell,
		[ InstrVars.aIdx["fiddle"] ] = InstrVars.aFiddle,
		[ InstrVars.aIdx["harp"] ] = InstrVars.aHarp,
		[ InstrVars.aIdx["lute"] ] = InstrVars.aLute,
	},	
	aSynonyms =
	{
		lute = { "loa", "lute oa" }, 
		["lute of ages"] = { "loa", "lute oa" },
		["lonely mountain fiddle"] = { "lm fiddle" },
		["traveller's trusty fiddle"] = { "tt fiddle" },
		["lonely mountain bassoon"] = { "lm bassoon" },
		["misty mountain harp"] = { "mm harp" },
		drum = { "drums" },
		bagpipe = { "bagpipes" },
		clarinet = { "cla" },
		["harp"] = { "satakieli", "Gléowine’s harp" },
	},
	aSpecialInstruments =
	{
		["gléowine’s harp"] = 8,
		["satakieli"] = 8,
	},

	Count = function( self ) return self.count; end,
	Setup = function( self ) self:CreateMap( ); end,
	CreateMap = Instruments_CreateMap,
	VarBase= function( self, s ) return self.variants.aIdx[ s ]; end,
	Uix = function( self, i ) return self.mapIxUix[ i ]; end,
	IndexForUix = function( self, uix ) return self.mapUixIx[ uix ]; end,
	CreateUix = function( self, iBase, iVariant )
		local i = iBase * 100 + iVariant; if iVariant == 0 and self:BaseHasVariants( iBase ) then i = i + 1; end; return i; end,
	NameForUix = function( self, iUni ) return self:NameBaseVariant( self:Base( iUni ), self:Variant( iUni ) ); end,
	UixForName = function( self, sName )
		for i = 1, #self.mapIxUix do
			if sName:lower( ) == self:NameForUix( self.mapIxUix[ i ] ) then return self.mapIxUix[ i ]; end; end; return nil; end,
	Base = function( self, index ) return math.floor( index / 100 ); end,
	BaseCount = function( self ) return #self.aInstruments; end,
	Variant = function( self, index ) return index % 100; end,
	Variants = function( self, iBase ) return self.mapIndexToVariants[ iBase ]; end,
	BaseHasVariants = function( self, iBase ) return self.mapIndexToVariants[ iBase ]; end,
	NameBaseVariant = Instruments_NameBaseVariant,
	IterStart = function( self ) self.iBase = 0; end,
	IterNext = Instruments_IterNext,
	IterValid = function( self ) return self.iBase <= self:BaseCount( ); end,
	IterName = function( self ) return self:NameBaseVariant( self.iBase, self.iVariant ); end,
	Name = function( self, i ) return self:NameForUix( self:Uix( i ) ); end,
	IsWindInstr = function( self, uix ) return self.aWindClass[ math.floor( uix / 100 ) ]; end,
	
	--GetEquipped = Instruments_GetEquipped,
	SetInstrCBs = Instruments_SetInstrCBs,
	ScanSlots = Instruments_ScanSlots,
	SlotsToSkills = Instruments_SlotsToSkills,
	ReadSlots = Instruments_ReadSlots,
	ListRelevantSlots = Instruments_ListRelevantSlots,
	GetUixFromString = Instruments_GetUixFromString,
}

--------------------------------------------------------------------------------
-- Maintains a sorted list of party members (taken from main window)

PartyMembers = -- players list
{
	count = 0,
	aNames = {},
	Update = function( self, aMainWndPlayers )
		self.count = 0; self.aNames = {}
		for sPlayer in pairs( aMainWndPlayers ) do self.aNames[ #self.aNames + 1 ] = sPlayer; self.count = self.count + 1; end
		table.sort( self.aNames )
		if assignWindow then assignWindow:UpdatePlayers( self.aNames ); end
		end,
	Count = function( self ) return self.count; end,
	Name = function( self, i ) return self.aNames[ i ]; end
}

	
--------------------------------------------------------------------------------
-- Maintains a sorted list of players for assignment (a subset of Players)

PlayersMark = -- list of players with marking
{
	count = 0,
	aData = {},
	New = function( self, obj ) obj = obj or {}; setmetatable( obj, self ); self.__index = self; return obj; end,
	Reset = function( self ) self.aData = {}; self.count = 0; end,
	Add = function( self, sPlayer, mark )
		mark = mark or 0; self.count = self.count + 1;
		self.aData[ self.count ] = { ["player"] = sPlayer, ["mark"] = mark }; end,
	RemoveAt = function( self, i )
		if i > 0 and i <= self.count then table.remove( self.aData, i ); self.count = self.count - 1; return true; end; return false; end,
	Remove = function( self, sName ) self:RemoveAt( self:Index( sName ) ); end,
	Count = function( self ) return self.count; end,
	Index = function( self, sPlayer )
		for i = 1, #self.aData do if self.aData[ i ].player == sPlayer then return i; end; end
		return nil; end,
	At = function( self, i ) return self.aData[ i ]; end,
	Name = function( self, i ) return self.aData[ i ].player; end,
	Mark = function( self, i ) return self.aData[ i ].mark; end,
	IsMarkSet = function( self, i, m ) return Marks:IsSet( self.aData[ i ].mark, m ); end,
	SetMark = function( self, i, m )
		self.aData[ i ].mark = Marks:Set( self.aData[ i ].mark, m ); end,
	ClearMark = function( self, i, m ) self.aData[ i ].mark = Marks:Clear( self.aData[ i ].mark, m ); end,
	ClearAllMarks = function( self, m ) for i = 1, self.count do self:ClearMark( i, m ); end; end,
	SortByName = function( self )	table.sort( self.aData, function( v1, v2 ) return v1.player < v2.player; end ); end,
}



Players = PlayersMark:New( ) -- players list with parts, used in the assignment window/listbox

function Players:Add( sPlayer, sPart, mark )
	sPart = sPart or ""; mark = mark or 0; self.count = self.count + 1;
	self.aData[ self.count ] = { ["player"] = sPlayer, ["part"] = sPart, ["mark"] = mark }; end

function Players:Part( i ) return self.aData[ i ].part; end
function Players:HasPart( i ) return self.aData[ i ].part and self.aData[ i ].part ~= ""; end
function Players:SetPart( i, sPart ) self.aData[ i ].part = sPart; end
function Players:ClearPart( i ) self.aData[ i ].part = ""; end
function Players:ClearParts( ) for i = 1, self.count do self:ClearPart( i ); end; end
function Players:Partnumber( i ) return self.GetPartNumber( self.aData[ i ].part ); end
function Players:SortByPart( ) table.sort( self.aData, Players.CmpParts ); end
function Players.GetPartnumber( sPart ) return sPart.match and tonumber( sPart:match( "%[(%d-)%]" ) ) or nil; end
function Players.CmpParts( v1, v2 ) -- compare by part number, handle empty parts
	local iPart1 = Players.GetPartnumber( v1.part )
	local iPart2 = Players.GetPartnumber( v2.part )
	if not iPart1 then
		if not iPart2 then return v1.player < v2.player; end -- both are without part, sort by player
		return false; end -- only first without, sort in at end
	if not iPart2 then return true; end
	return iPart1 < iPart2; end


PrioPlayers = PlayersMark:New( ) -- players list for the priority listbox


--------------------------------------------------------------------------------
-- Table with data for instrument assignment

local function AssignerMapResetMap( self, t ) t.a, t.aSort, t.iter = { }, { }, 0; end
		
local function AssignerMapReset( self ) self:ResetMap( self.instrPlayer ); self:ResetMap( self.playerInstr ); end

local function AssignerMapArrayAdd( self, key, option )
	if not self.a[ key ] then self.a[ key ] = { ["a"] = {}, ["count"] = 0, ["nAvail"] = 0 }; end
	self.a[ key ].a[ option ] = 1
	self.a[ key ].count = self.a[ key ].count + 1
end
	
local function AssignerMapAdd( self, instr, player )
	if not self.instrPlayer.a[ instr ] then self.instrPlayer.a[ instr ] = { ["a"] = {}, ["count"] = 0, ["nAvail"] = 0 }; end
	if not self.playerInstr.a[ player ] then self.playerInstr.a[ player ] = { ["a"] = {}, ["count"] = 0, ["nAvail"] = 0 }; end
	
	self.instrPlayer.a[ instr ].count = self.instrPlayer.a[ instr ].count + 1
	self.playerInstr.a[ player ].count = self.playerInstr.a[ player ].count + 1

	self.instrPlayer.a[ instr ].a[ player ] = 1
	self.playerInstr.a[ player ].a[ instr ] = 1
end
	
	
local function AssignerMapDecAvailCountPar( self, map, kMapper, kMapped )
	local item = map.a[ kMapper ]
	if not item or not item.a[ kMapped ] then return; end
	item.a[ kMapped ] = 0;
	item.nAvail = item.nAvail - 1
	map:Sort_priv( )
end

-- Keep track of the number of possible instr/players still unclaimed
local function AssignerMapDecAvailCount( self, instr, player )
	AssignerMapDecAvailCountPar( self, self.instrPlayer, instr, player )
	AssignerMapDecAvailCountPar( self, self.playerInstr, player, instr );
end

local function AssignerMapIncAvailCountPar( self, map, kMapper, kMapped )
	local item = map.a[ kMapper ]
	if not item or not item.a[ kMapped ] then return; end
	item.a[ kMapped ] = 1;
	item.nAvail = item.nAvail + 1
	map:Sort_priv( )
end

local function AssignerMapIncAvailCount( self, iInstr, sPlayer )
	AssignerMapIncAvailCountPar( self, self.instrPlayer, sPlayer )
	AssignerMapIncAvailCountPar( self, self.playerInstr, iInstr )
end

local function AssignerMapAvailableOption( self, value, n )
	local i = 0
	for k, v in pairs( value.a ) do
		i = i + 1
		if v > 0 and i > n then return k, i; end
	end
	return nil, 0
end
	

local function AssignerMapPlayerHasInstr( self, sPlayer, iInstr )
	if not self.playerInstr.a[ sPlayer ] then return false; end
	return self.playerInstr.a[ sPlayer ].a[ iInstr ]
end
	
local function AssignerMapInstrHasPlayer( self, iInstr, sPlayer )
	if not self.instrPlayer.a[ iInstr ] then return false; end
	return self.instrPlayer.a[ iInstr ].a[ sPlayer ]
end
		


-- set nAvail same as count
local function AssignerMapResetAvail_priv( self ) for _, v in pairs( self.a ) do v.nAvail = v.count; end; end

-- create a doubly linked list in ascending order of nAvail
local function AssignerMapSort_priv( self )
	self.aSort = {}
	for k in pairs( self.a ) do self.aSort[ #self.aSort + 1 ] = k; end
	if #self.aSort <= 0 then return; end
	table.sort( self.aSort, function( v1, v2 ) return self.a[ v1 ].nAvail < self.a[ v2 ].nAvail; end )
end

local function AssignerMapFinalize( self )
	self.playerInstr:ResetAvail_priv( ); self.playerInstr:Sort_priv( )
	self.instrPlayer:ResetAvail_priv( ); self.instrPlayer:Sort_priv( )
end
		
		
local function AssignerMapString( self )
	local s = ""
	for i = 1, #self.aSort do
		local v = self.a[ self.aSort[ i ] ]
		s = s..self.aSort[ i ]..":(c="..v.count..",a="..v.nAvail..") "
	end
	return s
end

local Mapping =
{
	a = {},		-- for each instrument the players available
	aSort = {}, -- index array into a, sorted by ascending nAvail
	iIter = 0,
	New = function( self, obj ) obj = obj or {}; setmetatable( obj, self ); self.__index = self; return obj; end,
	Count = function( self ) return #self.aSort; end,
	ResetAvail_priv = AssignerMapResetAvail_priv,
	Sort_priv = AssignerMapSort_priv,
	Key = function( self, i ) return i <= #self.aSort and self.aSort[ i ] or nil; end,
	Value = function( self, i ) return i <= #self.aSort and self.a[ self.aSort[ i ] ] or nil; end,
	IterDown = function( self ) self.iIter = #self.aSort + 1; end,
	NextDown = function( self ) self.iIter = self.iIter - 1; return self.iIter > 0; end,
	IterUp = function( self ) self.iIter = 0; end,
	NextUp = function( self ) self.iIter = self.iIter + 1; return self.iIter <= #self.aSort; end,
	Iter = function( self ) return self.aSort[ self.iIter ]; end,
	IterInfo = function( self ) return self.a[ self.aSort[ self.iIter ] ]; end,
	AvailableOption = AssignerMapAvailableOption,
	AvailableOptionAt = function( self, key ) return self:AvailableOption( self.a[ key ] ); end,
	String = function( self ) return AssignerMapString( self ); end,
}

Assigner = 
{
	aPlayers = {}, -- names of players that are to be assigned (in assignWindow some players from main window can be excluded)
	aSongInstrIndex = {}, -- unified indices of instruments used in the song
	aInstrPartname = {}, -- k = instrument SB index, v = part name
	aInstrState = {}, -- (k = iInstr, v = state code)
	nSongInstr = 0, -- number of instruments in song
	aPlayerState = {}, -- (k = player name, v = state code)
	nSongPlayers = 0, -- number of players in song
	stateParts = { ["iSong"] = -1, ["iSetup"] = -1 },
	aMap = -- mapping between instruments and players
	{
		instrPlayer = Mapping,
		playerInstr = Mapping:New( ),
		Reset = AssignerMapReset,
		ResetMap = AssignerMapResetMap,
		Add = AssignerMapAdd,
		PlayerHasInstr = AssignerMapPlayerHasInstr,
		InstrHasPlayer = AssignerMapInstrHasPlayer,
		DecAvailCount = AssignerMapDecAvailCount,
		IncAvailCount = AssignerMapIncAvailCount,
		Finalize = AssignerMapFinalize,
		ResetAvail_priv = AssignerMapResetAvail_priv,
		Sort_priv = AssignerMapSort_priv,
	},
	aAssign =
	{
		aPlayerPart = { }, -- k = player name, v = part string
		aInstrPlayer = { }, -- k = instrument index, v = player name
		aUixPlayer = { }, -- k = unified instrument index, v = player name
		aAssignedType = { },
		Count = function( self ) return Count( self.aPlayerPart ); end,
		Reset = function( self ) self.aPlayerPart = { }; self.aInstrPlayer = { }; self.aAssignedType = { }; self.aVocalsOnly = {}; end,
		Register = function( self, iInstr, sPlayerName, sPartName, uix, assignType ) -- assignType: v = vocals, t = transfer, p = prio
			self.aPlayerPart[sPlayerName] = sPartName; self.aInstrPlayer[iInstr] = sPlayerName; self.aUixPlayer[uix] = sPlayerName
			self.aAssignedType[ iInstr ] = assignType; end,
		Remove = function( self, iInstr, sPlayerName, uix )
			self.aPlayerPart[sPlayerName] = nil; self.aInstrPlayer[iInstr] = nil; self.aUixPlayer[uix] = nil
			self.aAssignedType[ iInstr ] = nil; end,
		RemoveInstr = function( self, iInstr ) self.aPlayerPart[ self:PlayerForInstr(iInstr) ] = nil; self.aInstrPlayer[iInstr] = nil; end,
		HasInstr = function( self, iInstr ) return self.aInstrPlayer[iInstr] ~= nil; end,
		PlayerForInstr = function( self, iInstr ) return self.aInstrPlayer[iInstr]; end,
		HasPlayer = function( self, sPlayerName ) return self.aPlayerPart[sPlayerName] ~= nil; end,
		PartForPlayer = function( self, sPlayerName ) return self.aPlayerPart[sPlayerName]; end,
		PlayerForUix = function( self, uix ) return self.aUixPlayer[uix]; end,
	},
	vocals =
	{
		a = {},
		bActive = true,
		Reset = function( self ) self.a = {}; end,
		Count = function( self ) return #self.a; end,
		Add = function( self, sPlayerName ) self.a[ #self.a + 1 ] = sPlayerName; end,
		Remove = function( self )
			if #self.a < 1 then return nil; end
			local sName = self.a[ #self.a ]; table.remove( self.a, #self.a )
			return sName; end,
	},
	manuals =
	{
		a = {},
		Reset = function( self ) self.a = {}; end,
		Count = function( self ) return #self.a; end,
		Add = function( self, iInstr, sPlayerName ) self.a[ #self.a + 1 ] = { ["iInstr"] = iInstr, ["sPlayer"] = sPlayerName }; end,
		Instr = function( self, i ) return self.a[ i ].iInstr; end,
		Player = function( self, i ) return self.a[ i ].sPlayer; end,
	},
}


function Assigner:PrintInstrTable( t )
	return PrintNum( t, function( a, i ) return Instruments:NameForUix( self.aSongInstrIndex[ a[ i ] ] ); end ); end


function Assigner:InstrIndex( i )
	return self.aSongInstrIndex[ i ]
end

-- access helpers for player/instr state
function Assigner:RemovePlayer( sPlayer ) self.aPlayerState[ sPlayer ] = 'r'; end
function Assigner:RejoinPlayer( sPlayer ) self.aPlayerState[ sPlayer ] = 'a'; end
function Assigner:IsPlayerRemoved( sPlayer ) return self.aPlayerState[ sPlayer ] == 'r'; end
function Assigner:IsPlayerAvailable( sPlayer ) return self.aPlayerState[ sPlayer ] ~= 'r'; end
function Assigner:IsPlayerPresent( sPlayer ) return self.aPlayerState[ sPlayer ]; end
function Assigner:RemoveInstr( i ) self.aInstrState[ i ] = 'r'; end
function Assigner:RejoinInstr( i ) self.aInstrState[ i ] = 'a'; end
function Assigner:IsInstrRemoved( i ) return self.aInstrState[ i ] == 'r'; end
function Assigner:IsInstrAvailable( i ) return self.aInstrState[ i ] ~= 'r'; end


--  Assign instrument to player, so set R flag for instr and player
function Assigner:AssignInstrToPlayer( iInstr, sPlayerName, assignType )
	assignType = assignType or "-"
	local uix = self.aSongInstrIndex[ iInstr ]
	self.aAssign:Register( iInstr, sPlayerName, self.aInstrPartname[ iInstr ], uix, assignType )
	self.aMap:DecAvailCount( iInstr, sPlayerName ); 
	self:RemovePlayer( sPlayerName )
	self:RemoveInstr( iInstr )
end

--  Remove specific assignment (currently not in use)
function Assigner:RevokeAssignment( iInstr, sPlayerName )
	local uix = self.aSongInstrIndex[ iInstr ]
	self.aAssign:Remove( iInstr, sPlayerName, uix )
	self.aMap:IncAvailCount( iInstr, sPlayerName ); 
	self:RejoinPlayer( sPlayerName )
	self:RejoinInstr( iInstr )
end

--  Remove assignment for the given instrument
function Assigner:RevokeAssignmentForInstr( iInstr )
	local sPlayerName = self.aAssign:PlayerForInstr( iInstr )
	self:RevokeAssignment( iInstr, sPlayerName )
end

--  Remove assignment for first instrument in list (used to remove transferred assignments in case they turn out to be blocking)
-- Note 'first' means the one with the lowest uid; order doesn't matter for transferred assignments
function Assigner:RevokeAssignmentForLastInstr( assignedType )
	for iInstr, t in pairs( self.aAssign.aAssignedType ) do
		if t == assignedType then self:RevokeAssignmentForInstr( iInstr ); return true; end
	end
	return false
end

function Assigner:PartForPlayer( sPlayer ) return self.aAssign.aPlayerPart[ sPlayer ]; end

-- used in assign window listbox to manually assign a part (before auto-assign)
function Assigner:ManualAssign( iInstr, sPlayer )
	self.manuals:Add( iInstr, sPlayer ); end

function Assigner:HasManualAssign( iInstr )
	for i = 1, self.manuals:Count( ) do
		if self.manuals:Instr( i ) == iInstr then return true; end
	end
	return false
end

function Assigner:GetManualAssign( sPlayer )
	for i = 1, self.manuals:Count( ) do
		if self.manuals:Player( i ) == sPlayer then
			return self.manuals:Instr( i ); end
	end
	return nil
end

function Assigner:ClearManualAssignForVocalist( sPlayer )
	for i = 1, self.manuals:Count( ) do
		if self.manuals:Player( i ) == sPlayer then
			local uix = self.aSongInstrIndex[ self.manuals:Instr( i ) ]
			if Instruments:IsWindInstr( uix ) then
				table.remove( self.manuals.a, i )
				return true; end
		end
	end
	return false
end

function Assigner:ApplyManuals( )
	for i = 1, self.manuals:Count( ) do
		self:AssignInstrToPlayer( self.manuals:Instr( i ), self.manuals:Player( i ), "m" )
	end
end

function Assigner:RollbackManuals( )
	self:Rollback( "m" ); end


function Assigner:AddVocalsOnly( sPlayer )
	self.vocals:Add( sPlayer ); self:RemovePlayer( sPlayer ) end

function Assigner:RevokeVocalsOnly( )
	local sPlayer = self.vocals:Remove( )
	if not sPlayer then return nil; end
	self.vocals:Remove( sPlayer ); self:RejoinPlayer( sPlayer )
	return sPlayer
end


-- Get part name from a a Badger-formatted track name, e.g.:
-- A Nation Once Again 2 10 (2:49) - *COMBO Clarinet 10, 20
-- A Nation Once Again 2 10 (2:49) - Clarinet
-- A Nation Once Again 2 10 (2:49) - * COMBO Lute of Ages 2-4 player
function Assigner:GetBadgerStylePartname( sTrackname )
	local sPartname = sTrackname:match( "[%w%s]+%(.+%) %-[%s*]*(%a.+)" )
	return sPartname
end


function Assigner:GetPartnameAndIndex( track )
	local sCleanTrack = CleanString( track.Name:lower() )
	local aInstrumentsLang = 0 --  0 for aInstrumentsLoc, 1 for songbookWindow.aInstruments
	local iBase, sBaseName, iVariant, sVariantName = GetTrackInstrument( sCleanTrack, aInstrumentsLang )
	if not iBase then return nil, nil; end
	local sPart = self:GetBadgerStylePartname( track.Name ) -- if it's a badger-formatted part name, use it as is
	if not sPart then -- if not, use instrument name as part name
		if iVariant and iVariant == 1 then 
			sPart = Instruments:NameBaseVariant( iBase, 1 ) -- so we get 'basic lute' instead of just 'lute'
		else
			sPart = sVariantName
		end 
	end
	local sPartName = "[" .. tostring(track.Id) .. "] "..sPart
	
	return sPartName, Instruments:CreateUix( iBase, iVariant )
end

function Assigner:GetSongPartsFiltered( song, aSelTracks, bWarn )
	local aTrackData = {} -- copy uix,partname into a temporary array to be sorted afterwards
	local count = aSelTracks and #aSelTracks or #song.Tracks
	local sFailed = "No instrument detected in: "
	local aFailed = {}
	for i = 1, count do
		local iTrack = aSelTracks and aSelTracks:byte( i ) - 64 or i
		local sPartname, iUnified = self:GetPartnameAndIndex( song.Tracks[iTrack] )
		if iUnified then aTrackData[#aTrackData+1] = { ["uix"] = iUnified, ["part"] = sPartname }
		else aFailed[#aFailed + 1 ] = iTrack; end
	end
	table.sort( aTrackData, function( v1, v2 ) return v1.uix < v2.uix end )
	if #aFailed <= 0 then return aTrackData, true; end
	if bWarn then
		for i = 1, #aFailed do aFailed[ i ] = song.Tracks[ aFailed[ i ] ].Name; end
		WRITE( Strings["asn_noInstrDet"]..":\n"..table.concat( aFailed, ",\n" ) ); end
	return aTrackData, false
end

function Assigner:GetSongPartsVariants( song, iSetup, bSilent ) -- set track filter in self.aSelTracks
	if song.Setups and iSetup and iSetup > 0 and iSetup <= #song.Setups then
		--if self.aSelTracks then return self:GetSongPartsFiltered( song, self.aSelTracks, song.Setups[ iSetup ], bSilent ); else
		return self:GetSongPartsFiltered( song, song.Setups[ iSetup ], bSilent )--; end
	elseif self.aSelTracks then
		return self:GetSongPartsFiltered( song, self.aSelTracks, bSilent ); end
	return self:GetSongPartsFiltered( song, nil, bSilent )
end

function Assigner:GetSongUix( song, iSetup )
	local aTrackData = self:GetSongPartsVariants( song, iSetup, false )
	if #aTrackData <= 0 then return nil; end
	local aUix = {}
	for i = 1, #aTrackData do aUix[ #aUix + 1 ] = aTrackData[ i ].uix; end
	return aUix
end

-- Extract song instr and part names from track setup
function Assigner:GetSongParts( iSong, iSetup, bForce )
	if not iSong then WRITE( Strings["asn_selSongSetup"] ); return false; end
	
	-- can be called from assignWindow (for parts context menu) with without bForce; if it has, don't recreate the list 
	--if not bForce and self.stateParts.iSong == iSong and self.stateParts.iSetup == iSetup then return true; end
	self.stateParts.iSong = iSong; self.stateParts.iSetup = iSetup
	
	self.aSongInstrIndex = { }
	self.aInstrPartname = { }
	self.nSongInstr = 0
	self.aInstrState = {} 
	
	local song = SongDB.Songs[ iSong ]
	if not song then return false; end
	
	local aTrackData, bAllValid = self:GetSongPartsVariants( song, iSetup )
	if not bAllValid then return false; end
		
local sMsg = " "
	self.nSongInstr = #aTrackData -- now copy uix into aSongInstrIndex and sPartname into aInstrPartname, using the same index
	for i = 1, self.nSongInstr do
sMsg = sMsg..tostring(i)..":"
		self.aSongInstrIndex[ #self.aSongInstrIndex + 1 ] = aTrackData[ i ].uix
sMsg = sMsg..tostring(aTrackData[ i ].uix).." "
		self.aInstrPartname[ i ] = aTrackData[ i ].part 
		self:RejoinInstr( i )
	end
	return true
end

function Assigner:PartCount( ) return self.nSongInstr; end
function Assigner:PartString( i ) return self.aInstrPartname[ i ]; end
function Assigner:PartUix( i ) return self.aSongInstrIndex[ i ]; end


-- Check and remove priority violations from transferred assignments (e.g., when a player with a priority just joined)
function Assigner:HasHigherPriority( aInstrPrios, sPlayer, sPlayerCompare ) 
	if not aInstrPrios[ sPlayer ] then return false; end -- if first player has no priority, it can't be higher
	if not aInstrPrios[ sPlayerCompare ] then return true; end -- if first player has a priority, but second doesn't, first is definitely higher
	return aInstrPrios[ sPlayer ] > aInstrPrios[ sPlayerCompare ]
end

-- Check and remove priority violations from transferred assignments (e.g., when a player with a priority just joined)
function Assigner:RemoveForPriority( iInstr, aInstrPrios ) 
	local sAssignedPlayer = self.aAssign:PlayerForInstr( iInstr )
	for i = 1, #self.aPlayers do -- check all players in the group
		if self:HasHigherPriority( aInstrPrios, self.aPlayers[i ], sAssignedPlayer) then
			self:RevokeAssignmentForInstr( iInstr )
			return
		end
	end
end


-- Check and remove priority violations from transferred assignments (e.g., when a player with a priority just joined)
function Assigner:RemoveTransfersViolatingPrios( aPrios ) 
	for i = 1, #self.aSongInstrIndex do
		if self:IsInstrRemoved( i ) then -- this instrument seems to have a transferred assignment TODO: check if there is another of the type 
			local aInstrPrios = PriosData:ForUix( self.aSongInstrIndex[i] )
			if aInstrPrios then self:RemoveForPriority( i, aInstrPrios ); end
		end
	end
end


-- The same player could show up twice (ifinstr is doubled), so remove the second (lower prio) appearance
function Assigner:FixPrios( aPrios ) 
	table.sort( aPrios, function(v1,v2) return v1.prio < v2.prio; end )
	
	local aPlayers = {}
	local aRemove = {}
	for i = #aPrios, 1, -1 do
		if aPlayers[ aPrios[ i ].player ] then aRemove[ #aRemove + 1 ] = i; end
		aPlayers[ aPrios[ i ].player ] = true
	end
	
	for i = 1, #aRemove do -- now remove the double entries
		table.remove( aPrios, aRemove[i ] )
	end
end
	


function Assigner:BuildPrioList( )
	local aPrios = { }
	
	for i = 1, #self.aSongInstrIndex do
		local tPrios = PriosData:ForUix( self.aSongInstrIndex[ i ] )
		if tPrios then
			for sPlayer, prio in pairs( tPrios ) do
				if self:IsPlayerPresent( sPlayer ) and self.aMap:PlayerHasInstr( sPlayer, i ) then
					aPrios[#aPrios+1] = { ["prio"] = prio, ["instr"] = i, ["player"] = sPlayer, ["used"] = false }
				end
			end
		end
	end
	
	if #aPrios > 0 then self:FixPrios( aPrios ); end -- find double entries (can happen due to double instruments) and remove the lower prio one
	
	return aPrios
end
	
	
function Assigner:ApplyPrios( aPrios )
	for i = #aPrios, 1, -1 do -- assign instruments in order of descending priority
		if self:IsInstrAvailable( aPrios[i].instr ) and self:IsPlayerAvailable( aPrios[i].player ) then
			self:AssignInstrToPlayer( aPrios[i].instr, aPrios[i].player, "p" )
			aPrios[i].used = true
		end
	end
end
			
			
-- Go through applied priorities in ascending order and remove as long as MakeSelections is unsuccessful
function Assigner:RollbackPriorities( aPrios )
	if not aPrios or #aPrios <= 0 then return false; end
	
	local Iter = {
		i = 0, count = #aPrios,
		Next = function( self, a ) self.i = self.i + 1
			while self.i <= #a and a[self.i].used ~= true do self.i = self.i + 1; end
			return self.i <= #a; end }
	while Iter:Next( aPrios ) do
		if self:StartSelection( ) then return true; end
		if RecLog:AtLimit( ) then return false; end

		self:RevokeAssignment( aPrios[Iter.i].instr, aPrios[Iter.i].player )
	end
	if self:StartSelection( ) then return true; end -- try once more after removing last priority assignment
	return false
end


function Assigner:GetPlayerInstrMatrix( )
	self.aMap:Reset()
	self.aPlayerState = {}
	self.nSongPlayers = 0 -- number of players with at least one suitable instrument skill

	for i = 1,#self.aPlayers do
		local sPlayername = self.aPlayers[ i ]
		local skills = SkillsData:Get( sPlayername )
		--if not skills then skills = Skills:New( ); end --TODO: leave empty and report no usable skills?
		if skills and not skills:IsEmpty( ) then
			local bFoundApplicableSkill = false
			for iSongInstr = 1, #self.aSongInstrIndex do
				if skills:Contains( self.aSongInstrIndex[ iSongInstr ] ) then
					bFoundApplicableSkill = true
					self.aMap:Add( iSongInstr, sPlayername )
				end
			end
			if bFoundApplicableSkill then self:RejoinPlayer( sPlayername ); self.nSongPlayers = self.nSongPlayers + 1; end
		end
	end
	
	self.aMap:Finalize( )
end


function Assigner:InstrumentNames( aIndices )
	if #aIndices <= 0 then
		return "<empty list>"
	end
	local sNames = Instruments:NameForUix( aIndices[1] )
	for i=2,#aIndices do
		sNames = sNames .. "," .. Instruments:NameForUix(  aIndices[i] )
	end
	return sNames
end


function Assigner:ActiveCount( iInstr )
	if not self.aMap.instrPlayer.a[ iInstr ] then return 0; end
	local aPlayers = self.aMap.instrPlayer.a[ iInstr ].a
	
	local nActive = 0
	for sPlayer in pairs( aPlayers ) do
		if self:IsPlayerAvailable( sPlayer ) then nActive = nActive + 1; end
	end
	return nActive
end


function Assigner:InstrsForOptionCount( count )
	
	local aInstrs = {}
	
	if self.aMap.instrPlayer.a == nil then
		for i = 1, #self.aSongInstrIndex do aInstrs[#aInstrs+1] = i; end
		return aInstrs;
	end
	
	for iInstr = 1, #self.aSongInstrIndex do 
		if self:IsInstrAvailable( iInstr ) and self:ActiveCount( iInstr ) == count then
			aInstrs[#aInstrs+1] = iInstr
		end
	end

	return aInstrs
end


function Assigner:UnassignableInstrument( )
	local aFail = self:InstrsForOptionCount( 0 )
	if #aFail > 0 then -- got an instrument with no options left
		RecLog:SetError( Strings["asn_asNoPlayers"] .. self:PrintInstrTable( aFail ) );
		return true;
	end
	return false
end


function Assigner:GetUsablePrevAssigns( aOldSongUix )
	local aPlayerForInstr = {}
	local aPlayerUsed = {}
	local iOld, nOld = 1, #aOldSongUix
	for iInstr = 1, #self.aSongInstrIndex do
		while iOld <= nOld and aOldSongUix[ iOld ] < self.aSongInstrIndex[ iInstr ] do iOld = iOld + 1; end
		if iOld > nOld then break; end
		if aOldSongUix[ iOld ] == self.aSongInstrIndex[ iInstr ] then
			local sPlayerName = self.aAssign:PlayerForInstr( iOld )
			if self:IsPlayerPresent( sPlayerName ) and not aPlayerUsed[ sPlayerName ]
			and self:PlayerHasSkill( sPlayerName, aOldSongUix[ iOld ] ) then
				aPlayerUsed[ sPlayerName ] = true
				aPlayerForInstr[ iInstr ] = sPlayerName; end
		end
	end
	return aPlayerForInstr
end

function Assigner:TransferPrevAssigns( aPlayerForInstr )
	if aPlayerForInstr then
		for iInstr,sPlayer in pairs( aPlayerForInstr ) do
			if self:IsPlayerAvailable( sPlayer ) and self:IsInstrAvailable( iInstr ) 
				and not ( self:IsVocalist( Players:Index( sPlayer ) ) and Instruments:IsWindInstr( self.aSongInstrIndex[ iInstr ] ) ) then
					self:AssignInstrToPlayer( iInstr, sPlayer, "t" ); end
		end
	end
end


DbgMsg = 
{
	sMsg = "",
	Reset = function( self ) self.sMsg = ""; end,
	Log = function( self, s ) self.sMsg = self.sMsg..s; end,
	Start1 = function( self, s ) self.sMsg = self.sMsg..s; end,
	String = function( self ) return self.sMsg; end,
	Print = function( self, sPrefix ) Turbine.Shell.WriteLine( sPrefix..self:String( ) ); end
}


function Assigner:AssignedInstrString( )
	local s = ""
	for iInstr = 1, #self.aSongInstrIndex do
		if self:IsInstrRemoved( iInstr ) then
			s = s..string.char( string.byte("A") - 1 + iInstr )
		end
	end
	return s
end
		

-- Initialize msg and depth counter and start recursion of MakeSelection( )
function Assigner:StartSelection( )
	DbgMsg:Reset( )
	if self:MakeSelection( ) and not RecLog:AtLimit( ) then return true; end
	return false
end

function Assigner:IsDataValid( )
	if #self.aSongInstrIndex > #self.aPlayers then -- total number if players present is insufficient for this setup
		Turbine.Shell.WriteLine( Strings["asn_notEnoughPlayers"].." ("..tostring(#self.aPlayers).." players, "..tostring(#self.aSongInstrIndex).." parts)." )
		return false
	end
	
	if #self.aSongInstrIndex > self.nSongPlayers then -- some players don't have skills for any instruments in the song
		local aMissingSkills = {}
		for i = 1,#self.aPlayers do
			if not self.aMap.playerInstr.a[ self.aPlayers[ i ] ] then aMissingSkills[#aMissingSkills+1] = self.aPlayers[ i ]; end
		end
		local sMsg = Strings["asn_notEnoughPlayers"].."; "
		if #aMissingSkills == 1 then sMsg = sMsg..aMissingSkills[ 1 ].." "..Strings["asn_noSkillsSingular"]
		else sMsg = sMsg..table.concat( aMissingSkills, "/" ).." "..Strings["asn_noSkillsPlural"]; end
		WRITE( sMsg..Strings["asn_noSkillsEnding"] )
		return false;
	end
	
	return true
end


-- If there are players with low instr option count, assign them early
function Assigner:AssignLowOptionPlayers( )
	self.aMap.playerInstr:IterUp()
	while self.aMap.playerInstr:NextUp( ) do 
		if self:IsPlayerAvailable( self.aMap.playerInstr:Iter( ) ) then
			local value = self.aMap.playerInstr:IterInfo( )
			if value.nAvail > 1 then return; end
			if value.nAvail == 1 then
				local iInstr = self.aMap.playerInstr:AvailableOptionAt( self.aMap.playerInstr:Iter( ) )
				self:AssignInstrToPlayer( iInstr, self.aMap.playerInstr:Iter( ), "f" ) -- f for forced
			end
		end
	end 
end	
			

function Assigner:MakeSelection( )
	if self.aAssign.aPlayerPart and Count(self.aAssign.aPlayerPart) == #self.aSongInstrIndex then return true; end
	
	if RecLog:Descend( ) then Turbine.Shell.WriteLine( "ERROR: Limit exceeded: "..RecLog:String() ); return true; end
	
	if self:UnassignableInstrument( ) then return false; end -- instrument with no available players, no rollback possible
	
	for nOptions=1,self.nSongPlayers do
		local aCandidates = self:InstrsForOptionCount( nOptions )
		for iCand=1,#aCandidates do
			if self:IsInstrAvailable( aCandidates[iCand] ) then --TODO: Is this needed? We check for it when composing the candidate list
				local aPlayers = self.aMap.instrPlayer.a[aCandidates[iCand]].a
				for sPlayer in pairs( aPlayers ) do
if RecLog:Step( ) then WRITE( "ERROR: Call limit exceeded: "..RecLog:String() ); return true; end
					if self:IsPlayerAvailable( sPlayer ) and self:IsValidAssign( aCandidates[iCand], sPlayer ) then
						self:AssignInstrToPlayer( aCandidates[iCand], sPlayer )
						if self:MakeSelection( ) then
							return true
						else
							self:RevokeAssignment( aCandidates[iCand], sPlayer )
							RecLog:Ascend( )
						end
					end
				end
				return false -- found no assignment for this candidate set
			end
		end
	end
	return false
end

RecLog = 
{
	n = 0, -- number of calls
	nLimit = 10000, -- 7000
	d = 0, -- recursion depth
	dMax = 0,
	dLimit = 30,
	sError = "",
	Reset = function( self ) self.n = 0; self.d = 0; self.dMax= 0; end,
	AtLimit = function( self ) return self.d > self.dLimit or self.n > self.nLimit; end,
	Descend = function( self ) self.d = self.d + 1; self.n = self.n + 1; if self.d > self.dMax then self.dMax = self.d; end; return self:AtLimit( ); end,
	Ascend = function( self ) self.d = self.d - 1; end,
	Step = function( self ) self.n = self.n + 1; end,
	String = function( self ) return "Rec: dMax="..tostring(self.dMax)..", n="..tostring(self.n); end,
	State = function( self ) return "d="..tostring(self.d)..",n="..tostring(self.n); end,
	SetError = function( self, sError ) self.sError = sError; end,
	LastError = function( self ) return "<rgb=#FF0000>"..self.sError.."</rgb>"; end,
}

function Assigner:CurrentState( )
	return tostring(self.aAssign:Count())..":"..PrintTable( self.aAssign.aInstrPlayer )
end


function Assigner:InstrIndexForUix( uix, bAvailable )
	bAvailable = bAvailable or false
	for i = 1, #self.aSongInstrIndex do
		if self.aSongInstrIndex[ i ] == uix then
			if not bAvailable or self:IsInstrAvailable( i ) then return i; end
		end
	end
	return nil
end


function Assigner:IsAssignDone( )
	return self.aAssign.aPlayerPart and Count(self.aAssign.aPlayerPart) == #self.aSongInstrIndex
end

	
function Assigner:IsValidAssign( iInstr, sPlayer )
	return not self.vocals.bActive or not ( self:IsNameVocalist( sPlayer ) and Instruments:IsWindInstr( self.aSongInstrIndex[ iInstr ] ) )
end

function Assigner:IsVocalist( i )
	return not Players:IsMarkSet( i, Marks.tag.inactive ) and Players:IsMarkSet( i, Marks.tag.vocals )
end

function Assigner:IsNameVocalist( sPlayer )
	local i = Players:Index( sPlayer )
	return i and self:IsVocalist( i ) or false;
end


function Assigner:VocalistCount( )
	local n = 0
	for iPlayer = 1, Players:Count( ) do
		local sPlayer = Players:Name( iPlayer )
		if self:IsPlayerAvailable( sPlayer ) and self:IsVocalist( iPlayer ) then n = n + 1; end
	end
	return n
end


function Assigner:AssignVocalists( aPrios )
	self.vocals.bActive = true	-- indicates that vocalists are to be considered
	
	local aInstrPrio = {}
	for i = 1, #aPrios do aInstrPrio[ aPrios[ i ].instr ] = aPrios[ i ].prio; end

	local nAssigned = 0
	for iPlayer = 1, Players:Count( ) do -- Get instruments played by each vocalist that are not winds in aInstr
		local sPlayer = Players:Name( iPlayer )
		if self:IsPlayerAvailable( sPlayer ) and self:IsVocalist( iPlayer ) then
			local aInstr = {}
			local iLowestPrio, lowestPrio = 0, 10
			for iInstr, v in pairs( self.aMap.playerInstr.a[ sPlayer ].a ) do
				local uix = self.aSongInstrIndex[ iInstr ]
				if v > 0 and not Instruments:IsWindInstr( uix ) then
					--local i = self:InstrIndexForUix( uix, true )
					aInstr[ #aInstr + 1 ] = iInstr
				end
			end
			table.sort( aInstr, function( v1, v2 ) return self.aMap.instrPlayer.a[ v1 ].nAvail > self.aMap.instrPlayer.a[ v2 ].nAvail; end )
			for i = 1, #aInstr do -- go through the candidate instruments in order of decreasing option count
				local iInstr = aInstr[ i ]
				if aInstrPrio[ iInstr ] then
					if aInstrPrio[ iInstr ] < lowestPrio then iLowestPrio = iInstr; lowestPrio = aInstrPrio[ iInstr ]; end
				else 
					lowestPrio = -1 -- indicates that an unclaimed instrument was found and assigned
					aInstrPrio[ iInstr ] = 10 -- higher than max prio to indicate claimed by vocalist
					self:AssignInstrToPlayer( iInstr, sPlayer, "v" )
					nAssigned = nAssigned + 1
					break
				end
			end
			if lowestPrio > 0 and lowestPrio < 10 then
				self:AssignInstrToPlayer( iLowestPrio, sPlayer, "v" )
			elseif self:IsPlayerAvailable( sPlayer ) and #self.aSongInstrIndex < self.nSongPlayers - self.vocals:Count() then
				self:AddVocalsOnly( sPlayer ); end -- no part found, and room for vocals only
		end
	end
	return nAssigned
end




function Assigner:Rollback( sMark )
	while self:RevokeVocalsOnly( ) do
		if self:StartSelection( ) then return true; end
	end
	while self.aAssign:Count( ) > 0 and self:RevokeAssignmentForLastInstr( sMark ) do
		if self:StartSelection( ) then return true; end
	end
return false
end

function Assigner:RollbackVocalists( )
	self.vocals.bActive = false
	return self:StartSelection( )
end

function Assigner:RollbackTransfers( )
	return self:Rollback( "t" )
end


function Assigner:CreateAssignment( aPlayers )
	self.aPlayers = aPlayers -- list is handed over by assignWindow, because players can be excluded there
	
--DbgMsg:Reset()
RecLog:Reset()
	
	local aOldSongUix = table.Copy( self.aSongInstrIndex ) -- need a copy for GetUsablePrevAssigns() below
	
	if not self:GetSongParts( selectedSongIndex, songbookWindow.iCurrentSetup, true ) then return false; end
	
	self.vocals:Reset( )
	self:GetPlayerInstrMatrix( )
	if not self:IsDataValid( ) then return false; end
	
	local aPlayerForInstr = self:GetUsablePrevAssigns( aOldSongUix )
	self.aAssign:Reset( )
	local aPrios = self:BuildPrioList( )
	
	self:ApplyManuals( )
	self.vocals.bActive = self:VocalistCount( ) > 0
	self:ApplyPrios( aPrios )
	self:TransferPrevAssigns( aPlayerForInstr )
	
	local retVal = self:StartSelection( ) -- TODO: rollback of one level should re-apply the pre-assigns of the upper levels
		or self:RollbackTransfers( ) or self:RollbackPriorities( aPrios ) or self:RollbackVocalists( ) or self:RollbackManuals( )

	self.manuals:Reset( )
	
	if retVal then WRITE( Strings["asn_asDone"] )
	else WRITE( Strings["asn_asFail"]..", "..RecLog:LastError( ) ); end

	return retVal
end

	
function Assigner:VerifyAssignment( )
	local sMsg = ""
	for uix, sPlayer in pairs( self.aAssign.aUixPlayer ) do
		if not self:PlayerHasSkill( sPlayer, uix ) then
			sMsg = sMsg..tostring( sPlayer ).." can't play "..tostring( uix ).."; "
		end
	end
	return sMsg
end


function Assigner:PlayerHasSkill( sPlayer, uix )
	local skills = SkillsData:Get( sPlayer )
	if not skills then return false; end
	return skills:Contains( uix )
end

-----------------------
-- Check Instruments --
-----------------------
function CheckInstruments( sTrack )
	
	--*************************
	--* Get Player Instrument *
	--*************************
	
	-- Get Local Player Instance
	local player = Turbine.Gameplay.LocalPlayer:GetInstance();
	if ( not player ) then
		return;
	end
	
	-- Get Player Equipement
	local equip = player:GetEquipment();
	if ( not equip ) then
		return;
	end
	
	--  Get Player Item category Instrument equiped
	local item = equip:GetItem( Turbine.Gameplay.Equipment.Instrument );
	if ( not item ) then
		return;
	end
	
	-- Get Player Instrument Locale Name
	local PlayerInstrumentLOCName = item:GetName();
	
	-- Clean Player Instrument Local Name
	local PlayerInstrumentLOCCleanName = CleanString( PlayerInstrumentLOCName );
	
	-- Get Player Instrument Local Index and Local Generic Name from aInstrumentsLoc
	local PlayerInstrumentLOCIndex, PlayerInstrumentLOCGenericName = GetPlayerInstrumentLOC( PlayerInstrumentLOCCleanName:lower() );
	
	-- Get Player Instrument SongBook (SB) Internal Index and SB Generic Name
	local PlayerInstrumentSBIndex = PlayerInstrumentLOCIndex;
	local PlayerInstrumentSBGenericName = songbookWindow.aInstruments[PlayerInstrumentSBIndex];
	
	-- Get Player Instrument LOC/SB Type Index and LOC/SB Type Name
	local PlayerInstrumentLOCTypeIndex, PlayerInstrumentLOCTypeName, PlayerInstrumentSBTypeIndex, PlayerInstrumentSBTypeName = GetPlayerInstrumentLOCSBType( PlayerInstrumentLOCIndex, PlayerInstrumentLOCCleanName );
	if ( PlayerInstrumentLOCTypeIndex == 1 ) then
		PlayerInstrumentLOCTypeName = PlayerInstrumentLOCGenericName;
		PlayerInstrumentSBTypeName = PlayerInstrumentSBGenericName;
	end
	
	--************************
	--* Get Track Instrument *
	--************************
	-- Clean Track string
	local sCleanTrack = CleanString( sTrack:lower() );
	
	-- Set lang as Local or Songbook Internal
	local aInstrumentsLang = 0; -- set to 0 for aInstrumentsLoc
	
	-- Get Track Instrument Index, Generic Name, Type Index and Type Name
	local TrackInstrumentLOCIndex, TrackInstrumentLOCGenericName, TrackInstrumentLOCTypeIndex, TrackInstrumentLOCTypeName = nil;
	local TrackInstrumentSBIndex, TrackInstrumentSBGenericName, TrackInstrumentSBTypeIndex, TrackInstrumentSBTypeName = nil;
	
	-- First, try to get Local Instrument
	TrackInstrumentLOCIndex, TrackInstrumentLOCGenericName, TrackInstrumentLOCTypeIndex, TrackInstrumentLOCTypeName = GetTrackInstrument( sCleanTrack, aInstrumentsLang );
	TrackInstrumentSBIndex = TrackInstrumentLOCIndex;
	TrackInstrumentSBGenericName = songbookWindow.aInstruments[TrackInstrumentSBIndex];
	TrackInstrumentSBTypeIndex = TrackInstrumentLOCTypeIndex;
	if ( TrackInstrumentSBTypeIndex == 1 ) then
		TrackInstrumentSBTypeName = TrackInstrumentSBGenericName;
	end
	if ( not TrackInstrumentLOCIndex ) then
		-- Try to get Songbook Internal Instrument
		aInstrumentsLang = 1; -- set to 1 for songbookWindow.aInstruments
		TrackInstrumentSBIndex, TrackInstrumentSBGenericName, TrackInstrumentSBTypeIndex, TrackInstrumentSBTypeName = GetTrackInstrument( sCleanTrack, aInstrumentsLang );
		if ( TrackInstrumentSBIndex == 6 ) then
			if ( PlayerInstrumentLOCGenericName == "geige" ) then
				TrackInstrumentLOCIndex = TrackInstrumentSBIndex + 1;
			end
		end
		TrackInstrumentLOCIndex = TrackInstrumentSBIndex;
		TrackInstrumentLOCGenericName = aInstrumentsLoc[TrackInstrumentLOCIndex];
		TrackInstrumentLOCTypeIndex = TrackInstrumentSBTypeIndex;
		if ( TrackInstrumentLOCTypeIndex == 1 ) then
			TrackInstrumentLOCTypeName = TrackInstrumentLOCGenericName;
		end
	end
	
	--**************************************************
	--* Compare Player Instrument and Track Instrument *
	--**************************************************
	-- Set bInstrumentOk flag
	songbookWindow.bInstrumentOk = true; -- only set to false if we can successfully determine track and equipped instrument
	-- If Player Instrument Generic Name is same as Track Instrument Generic Name
	if ( PlayerInstrumentLOCGenericName == TrackInstrumentLOCGenericName ) then
		-- If Player Instrument Type Index is same as Track Instrument Type Index
		if ( PlayerInstrumentLOCTypeIndex == TrackInstrumentLOCTypeIndex ) then
			-- Instrument is good
			songbookWindow.bInstrumentOk = true;
		else
			-- Instrument is wrong
			songbookWindow.bInstrumentOk = false;
		end
	else
		-- Instrument is wrong
		songbookWindow.bInstrumentOk = false;
		
	end
	
	--**************************
	--* Set Instrument Message *
	--**************************
	-- If Track Instrument is Type 2 : Bassoon
	if ( TrackInstrumentLOCIndex == 2 ) then
		songbookWindow:SetInstrumentMessage( aInstrumentsLocBassoon[TrackInstrumentLOCTypeIndex] );
	-- If Track Instrument is Type 4 : Cowbell
	elseif ( TrackInstrumentLOCIndex == 4 ) then
		songbookWindow:SetInstrumentMessage( aInstrumentsLocCowbell[TrackInstrumentLOCTypeIndex] );
	-- If Track Instrument is Type 6 : Fiddle
	elseif ( ( TrackInstrumentLOCIndex == 6 ) or ( TrackInstrumentLOCIndex == 7 ) ) then
		songbookWindow:SetInstrumentMessage( aInstrumentsLocFiddle[TrackInstrumentLOCTypeIndex] );
	-- If Track Instrument is Type 9 : Harp
	elseif ( TrackInstrumentLOCIndex == 9 ) then
		songbookWindow:SetInstrumentMessage( aInstrumentsLocHarp[TrackInstrumentLOCTypeIndex] );
	-- If Track Instrument is Type 11 : Lute
	elseif ( TrackInstrumentLOCIndex == 11 ) then
		songbookWindow:SetInstrumentMessage( aInstrumentsLocLute[TrackInstrumentLOCTypeIndex] );
	-- If Track Instrument is other Type
	else
		songbookWindow:SetInstrumentMessage( aInstrumentsLoc[TrackInstrumentLOCIndex] );
	end
end

------------------
-- Clean String --
------------------
function CleanString( sString )
	
	-- INIT Special Char
	-- set û : \195\187
	local sU1 = "\195\187";
	
	-- set ü : \195\188
	local sU2 = "\195\188";
	
	-- change to u
	local scU = "u"
	
	-- set é : \195\169
	local sE1 = "\195\169"; --string.char(\195\169)
	
	-- set è : \195\168
	local sE2 = "\195\168"; --string.char(\195\168)
	
	-- change to e
	local scE = "e";
	
	-- set ö : \195\182
	local sO1 = "\195\182"; --string.char(\195\182)
	
	-- change to o
	local scO = "o";
	
	-- set - : 
	local sTild = "%-";
	
	-- change to " "
	local scTild = " "
	
	-- Search for Special Char
	-- û : \195\187
	local sT = string.find( sString, sU1 );
	if ( sT ~= nil ) then
		sString = string.gsub( sString, sU1, scU );
	end
	
	-- ü : \195\188
	local sT = string.find( sString, sU2 );
	if ( sT ~= nil ) then
		sString = string.gsub( sString, sU2, scU );
	end
	
	-- é : \195\169
	local sT = string.find( sString, sE1 );
	if ( sT ~= nil ) then
		sString = string.gsub( sString, sE1, scE );
	end
	
	-- è : \195\168
	local sT = string.find( sString, sE2 );
	if ( sT ~= nil ) then
		sString = string.gsub( sString, sE2, scE );
	end
	
	-- ö : \195\182
	local sT = string.find( sString, sO1 );
	if ( sT ~= nil ) then
		sString = string.gsub( sString, sO1, scO );
	end
	
		-- set - : 
	local sT = string.find( sString, sTild );
	if ( sT ~= nil ) then
		sString = string.gsub( sString, sTild, scTild );
	end
	
	return sString;
end

----------------------------------------------------------
-- Get Player Instrument LOC Index and LOC Generic Name --
----------------------------------------------------------
function GetPlayerInstrumentLOC( sName )
	for index, name in pairs( aInstrumentsLoc ) do
		if ( sName:find( name ) ) then
			return index, name;
		end
	end
	return nil, nil;
end

-----------------------------------------------------------
-- Get Player Instrument LOC/SB Type Index and Type Name --
-----------------------------------------------------------
function GetPlayerInstrumentLOCSBType( iIndex, sName )

	-- Set aInstrumentsLOCType and aInstrumentsSBType
	local aInstrumentsLOCType, aInstrumentsSBType = nil;
	-- If Instrument Name is bassoon or basson or fagott : index = 2
	if ( iIndex == 2 ) then -- Bassoon
		aInstrumentsLOCType = aInstrumentsLocBassoon;
		aInstrumentsSBType = songbookWindow.aInstrumentsBassoon;
	
	-- If Instrument Name is Cowbell or Cloche or Glocke : index = 4
	elseif ( iIndex == 4 ) then -- Cowbell
		aInstrumentsLOCType = aInstrumentsLocCowbell;
		aInstrumentsSBType = songbookWindow.aInstrumentsCowbell;
		
	-- If Instrument Name is fiddle or violon or fiedel or geige : index = 6 or 7
	elseif ( iIndex == 6 ) or ( iIndex == 7 ) then -- Fiddle
		aInstrumentsLOCType = aInstrumentsLocFiddle;
		aInstrumentsSBType = songbookWindow.aInstrumentsFiddle;
	
	-- If Instrument Name is harp or harpe or harfe : index = 9
	elseif ( iIndex == 9 ) then -- Harp
		aInstrumentsLOCType = aInstrumentsLocHarp;
		aInstrumentsSBType = songbookWindow.aInstrumentsHarp;
		
	-- If Instrument Name is Lute or luth or laute : index = 11
	elseif ( iIndex == 11 ) then -- Lute
		aInstrumentsLOCType = aInstrumentsLocLute;
		aInstrumentsSBType = songbookWindow.aInstrumentsLute;
	else
		aInstrumentsLOCType = songbookWindow.aInstruments;
		aInstrumentsSBType = songbookWindow.aInstruments;
	end
	
	-- Get Instrument LOC Type Index and LOC Type Name from LOC Name
	local instrumentLOCTypeIndex, instrumentLOCTypeName = GetInstrumentLOCType( sName, aInstrumentsLOCType );
	local instrumentSBTypeIndex = instrumentLOCTypeIndex
	if ( not instrumentLOCTypeIndex ) then
		instrumentLOCTypeIndex = 1;
		instrumentLOCTypeName = nil;
		instrumentSBTypeIndex = 1;
		instrumentSBTypeName = nil;
	else
		instrumentSBTypeName = songbookWindow.aInstruments[instrumentSBTypeIndex];
	end
	return instrumentLOCTypeIndex, instrumentLOCTypeName, instrumentSBTypeIndex, instrumentSBTypeName
end

------------------------------------------------
-- Get Instrument LOC Type Index and LOC Name --
------------------------------------------------
function GetInstrumentLOCType( sName, aInstrumentsLOCType )
	local searchType = nil;
	for index, name in pairs( aInstrumentsLOCType ) do
		searchType = string.find( name, sName:lower() );
		if ( searchType ~= nil ) then
			return index, name;
		end
	end
	return nil, nil;
end

---------------------------------
-- Get Track Instrument LOC/SB --
---------------------------------
function GetTrackInstrument( sTrack, aInstrumentsLang )
	
	-- Set aInstruments
	local aInstruments, aInstrumentsType = nil;
	if ( aInstrumentsLang == 0 ) then
		aInstruments = aInstrumentsLoc;
	else
		aInstruments = songbookWindow.aInstruments;
	end
	
	-- Get Track Instrument Index and Name
	local TrackInstrumentIndex, TrackInstrumentName = GetInstrument( sTrack, aInstruments );
	
	-- Search Instrument Name
	local searchString = nil;
	local sString = nil;
	if ( ( TrackInstrumentName == "bassoon" ) or ( TrackInstrumentName == "basson" ) or ( TrackInstrumentName == "fagott" ) )then
		if ( TrackInstrumentName == "bassoon" ) then
			if ( not searchString ) then
				sString = "lonely";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "brusque";
				searchString = string.find( sTrack, sString );
			end
		elseif ( TrackInstrumentName == "basson" ) then
			if ( not searchString ) then
				sString = "solitaire";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "brusque";
				searchString = string.find( sTrack, sString );
			end
		elseif ( TrackInstrumentName == "fagott" ) then
			if ( not searchString ) then
				sString = "einsamen";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "schroffes";
				searchString = string.find( sTrack, sString );
			end
		end
		if ( aInstrumentsLang == 0 ) then
			aInstrumentsType = aInstrumentsLocBassoon;
		else
			aInstrumentsType = songbookWindow.aInstrumentsBassoon;
		end
	elseif ( ( TrackInstrumentName == "cowbell" ) or ( TrackInstrumentName == "cloche" ) or ( TrackInstrumentName == "glocke" ) ) then
		if ( TrackInstrumentName == "cowbell" ) then
			if ( not searchString ) then
				sString = "moor";
				searchString = string.find( sTrack, sString );
			end
		elseif ( TrackInstrumentName == "cloche" ) then
			if ( not searchString ) then
				sString = "landes";
				searchString = string.find( sTrack, sString );
			end
		elseif ( TrackInstrumentName == "glocke" ) then
			if ( not searchString ) then
				sString = "moorkuh";
				searchString = string.find( sTrack, sString );
			end
		end
		if ( aInstrumentsLang == 0 ) then
			aInstrumentsType = aInstrumentsLocCowbell;
		else
			aInstrumentsType = songbookWindow.aInstrumentsCowbell;
		end
	elseif ( ( TrackInstrumentName == "fiddle" ) or ( TrackInstrumentName == "violon" ) or ( TrackInstrumentName == "fiedel" ) or ( TrackInstrumentName == "geige" ) ) then
		if ( TrackInstrumentName == "fiddle" ) then
			if ( not searchString ) then
				sString = "student";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "traveller";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "sprightly";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "lonely";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "bardic";
				searchString = string.find( sTrack, sString );
			end
		elseif ( TrackInstrumentName == "violon" ) then
			if ( not searchString ) then
				sString = "etudiant";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "voyageur";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "alerte";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "solitaire";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "barde";
				searchString = string.find( sTrack, sString );
			end
		elseif ( ( TrackInstrumentName == "fiedel" ) or ( TrackInstrumentName == "geige") )then
			if ( not searchString ) then
				sString = "schuler";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "reisenden";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "muntere";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "einsamen";
				searchString = string.find( sTrack, sString );
			end
			if ( not searchString ) then
				sString = "barden";
				searchString = string.find( sTrack, sString );
			end
		end
		if ( aInstrumentsLang == 0 ) then
			aInstrumentsType = aInstrumentsLocFiddle;
		else
			aInstrumentsType = songbookWindow.aInstrumentsFiddle;
		end
	elseif ( ( TrackInstrumentName == "harp" ) or ( TrackInstrumentName == "harpe" ) or ( TrackInstrumentName == "harfe" ) ) then
		if ( TrackInstrumentName == "harp" ) then
			if ( not searchString ) then
				sString = "misty";
				searchString = string.find( sTrack, sString );
			end
		elseif ( TrackInstrumentName == "harpe" ) then
			if ( not searchString ) then
				sString = "brumeux";
				searchString = string.find( sTrack, sString );
			end
		elseif ( TrackInstrumentName == "harfe" ) then
			if ( not searchString ) then
				sString = "nebelgebirges";
				searchString = string.find( sTrack, sString );
			end
		end
		if ( aInstrumentsLang == 0 ) then
			aInstrumentsType = aInstrumentsLocHarp;
		else
			aInstrumentsType = songbookWindow.aInstrumentsHarp;
		end
	elseif ( ( TrackInstrumentName == "lute" ) or ( TrackInstrumentName == "luth" ) or ( TrackInstrumentName == "laute" ) ) then
		if ( TrackInstrumentName == "lute" ) then
			if ( not searchString ) then
				sString = "ages";
				searchString = string.find( sTrack, sString );
			end
		elseif ( TrackInstrumentName == "luth" ) then
			if ( not searchString ) then
				sString = "siecles";
				searchString = string.find( sTrack, sString );
			end
		elseif ( TrackInstrumentName == "laute" ) then
			if ( not searchString ) then
				sString = "zeiten";
				searchString = string.find( sTrack, sString );
			end
		end
		if ( aInstrumentsLang == 0 ) then
			aInstrumentsType = aInstrumentsLocLute;
		else
			aInstrumentsType = songbookWindow.aInstrumentsLute;
		end
	end
	
	local instrumentTypeIndex = nil;
	local instrumentTypeName = nil;
	if ( searchString ~= nil ) then
		-- Get Track Instrument Type Index and Type Name
		instrumentTypeIndex, instrumentTypeName = GetType( sString , aInstrumentsType );
	end
	if ( not instrumentTypeIndex ) then
		instrumentTypeIndex = 1;
		instrumentTypeName = TrackInstrumentName;
	end
	
	local instrumentIndex = nil;
	local instrumentGenericName = nil;
	if ( aInstrumentsLang == 0 ) then
		instrumentIndex = TrackInstrumentIndex;
		instrumentGenericName = TrackInstrumentName;
	else
		instrumentIndex = TrackInstrumentIndex;
		instrumentGenericName = TrackInstrumentName;
	end
	return instrumentIndex, instrumentGenericName, instrumentTypeIndex, instrumentTypeName;
end

---------------------------------------------------
-- Get Track Instrument Type Index and Type Name --
---------------------------------------------------
function GetType( sName , aInstrumentsType )
	local searchType = nil;
	for index, name in pairs( aInstrumentsType ) do
		searchType = string.find( name, sName:lower() );
		if ( searchType ~= nil ) then
			return index, name;
		end
	end
	return nil, nil;
end

--------------------------------
-- Get Track Instrument Index --
--------------------------------
function GetTrackInstrumentIndex ( sName, aInstruments )
	for index, name in pairs( aInstruments ) do
		if ( sName:find( name ) ) then
			return index;
		end
	end
	return nil;
end

-----------------------------------------
-- Get Track Instrument Index and Name --
-----------------------------------------
function GetInstrument( sTrack, aInstruments )
	for index, name in pairs( aInstruments ) do
		if ( sTrack:find( name ) ) then
			return index, name;
		end
	end
	return nil, nil;
end
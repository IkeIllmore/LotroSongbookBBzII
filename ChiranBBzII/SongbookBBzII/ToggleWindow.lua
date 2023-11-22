ToggleWindow = class(Turbine.UI.Window);
--Turbine.Shell.WriteLine( "1. ToggleWindow.lua" );

function ToggleWindow:Constructor()
	--Turbine.Shell.WriteLine( "2. ToggleWindow.lua : ToggleWindow:Constructor()" );
	Turbine.UI.Window.Constructor(self);
	-- legacy fix
	if ( not Settings.ToggleVisible ) then
		Settings.ToggleVisible = "yes";
		Settings.ToggleLeft = tostring( Turbine.UI.Display.GetWidth() - 55 );
		Settings.ToggleTop = "310";
	end
	self:SetPosition( Settings.ToggleLeft, Settings.ToggleTop );
	self:SetSize( 35, 35 );
	self:SetZOrder( 70 );
	self:SetVisible( true );
	self:SetOpacity( Settings.ToggleOpacity );
	self.button = Turbine.UI.Control();
	self.button:SetParent( self );
	self.button:SetPosition( 0, 0 );
	self.button:SetSize( 35, 35 );
	self.button:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.button:SetBackground( "ChiranBB/SongbookBB/toggle.tga" );
	self.button.MouseEnter = function( sender, args )
		self.button:SetBackground( "ChiranBB/SongbookBB/toggle_hover.tga" );
		self:SetOpacity( 0.9 );
	end
	self.button.MouseLeave = function( sender, args )
		self.button:SetBackground( "ChiranBB/SongbookBB/toggle.tga" );
		self:SetOpacity( Settings.ToggleOpacity );
	end
	self.button.MouseDown = function( sender, args )
		if ( args.Button == Turbine.UI.MouseButton.Left ) then
			sender.dragStartX = args.X;
			sender.dragStartY = args.Y;
			sender.dragging = true;
			sender.dragged = false;
			self:SetBackColor( Turbine.UI.Color( 0, 0, 1, 0 ) );
		end
	end
	self.button.MouseUp = function( sender, args )
		if ( args.Button == Turbine.UI.MouseButton.Left ) then
			if ( sender.dragging ) then
				sender.dragging = false;
			end
			if ( not sender.dragged ) then
				songbookWindow:SetVisible( not songbookWindow:IsVisible() );
			end
			self:SetBackColor( Turbine.UI.Color( 0, 0, 0, 0 ) );
			Settings.ToggleLeft = self:GetLeft();
			Settings.ToggleTop = self:GetTop();
		end
	end
	self.button.MouseMove = function( sender, args )
		if ( sender.dragging ) then
			local left, top = self:GetPosition();
			self:SetPosition( left + ( args.X - sender.dragStartX ), top + ( args.Y - sender.dragStartY ) );
			sender:SetPosition( 0, 0 );
			sender.dragged = true;
			-- checks to restrict moving outside the screen space
			if ( self:GetLeft() > Turbine.UI.Display.GetWidth() - 35 ) then
				self:SetLeft( Turbine.UI.Display.GetWidth() - 35 );
			end
			if ( self:GetLeft() < 0 ) then
				self:SetLeft( 0 );
			end
			if ( self:GetTop() > Turbine.UI.Display.GetHeight() - 35 ) then
				self:SetTop( Turbine.UI.Display.GetHeight() - 35 );
			end
			if ( self:GetTop() < 0 ) then
				self:SetTop( 0 );
			end
		end
	end
end
class "Mute"

function Mute:__init ( )
	self.mutes = { }
	self.unmuteTimers = { }

	SQL:Execute ( "CREATE TABLE IF NOT EXISTS mutes ( steamID VARCHAR, name VARCHAR, duration BIGINT(255), date VARCHAR, reason VARCHAR, responsible VARCHAR, responsibleSteamID VARCHAR )" )

	Events:Subscribe ( "PlayerChat", self, self.onPlayerChat )
	Events:Subscribe ( "PlayerJoin", self, self.onPlayerJoin )
	Events:Subscribe ( "PlayerQuit", self, self.onPlayerQuit )
	Events:Subscribe ( "ModuleLoad", self, self.onModuleLoad )
	Events:Subscribe ( "ModuleUnload", self, self.onModuleUnload )
end

function Mute:onModuleLoad ( )
	local query = SQL:Query ( "SELECT * FROM mutes" )
	local result = query:Execute ( )
	if ( #result > 0 ) then
		for _, mute in ipairs ( result ) do
			local player = getPlayerBySteamID ( mute.steamID )
			if IsValid ( player, false ) then
				local duration = tonumber ( mute.duration ) or 0
				if ( duration == 0 ) then
					self:setPlayerMuted ( { steamID = mute.steamID }, false )
				else
					self:setPlayerMuted ( { steamID = mute.steamID, duration = duration }, true )
				end
			end
		end
	end
end

function Mute:onModuleUnload ( )
	for steamID, timer in pairs ( self.unmuteTimers ) do
		local timeLeft = isTimer ( timer )
		if ( type ( timeLeft ) == "number" ) then
			local cmd = SQL:Command ( "UPDATE mutes SET duration = ? WHERE steamID = ?" )
			cmd:Bind ( 1, math.floor ( timeLeft ) )
			cmd:Bind ( 2, steamID )
			cmd:Execute ( )
			killTimer ( timer )
		end
	end
end

function Mute:onPlayerChat ( args )
	if self:isPlayerMuted ( args.player ) then
		args.player:Message ( "You are muted!", "err" )
		return false
	end
end

function Mute:onPlayerJoin ( args )
	local steamID = tostring ( args.player:GetSteamId ( ) )
	local result = self:isSteamIDMuted ( steamID )
	if ( type ( result ) == "table" ) then
		self:setPlayerMuted ( { steamID = mute.steamID, duration = tonumber ( result [ 1 ].duration ) }, true )
	end
end

function Mute:onPlayerQuit ( args )
	local steamID = tostring ( args.player:GetSteamId ( ) )
	local timeLeft = isTimer ( self.unmuteTimers [ steamID ] )
	if ( type ( timeLeft ) == "number" ) then
		local cmd = SQL:Command ( "UPDATE mutes SET duration = ? WHERE steamID = ?" )
		cmd:Bind ( 1, math.floor ( timeLeft ) )
		cmd:Bind ( 2, steamID )
		cmd:Execute ( )
		killTimer ( self.unmuteTimers [ steamID ] )
	end
end

function Mute:setPlayerMuted ( args, state )
	if ( args.steamID ) then
		if ( type ( self.unmuteTimers [ args.steamID ] ) == "userdata" ) then
			killTimer ( self.unmuteTimers [ args.steamID ] )
		end
		if ( state ) then
			if ( not self:isSteamIDMuted ( args.steamID ) ) then
				local cmd = SQL:Command ( "INSERT INTO mutes ( steamID, name, duration, date, reason, responsible, responsibleSteamID ) VALUES ( ?, ?, ?, ?, ?, ?, ? )" )
				local theDate = os.date ( "%c" )
				local responsible = ( args.responsible or "System" )
				local reason = ( args.reason or "" )
				cmd:Bind ( 1, args.steamID )
				cmd:Bind ( 2, ( args.name or "" ) )
				cmd:Bind ( 3, args.duration )
				cmd:Bind ( 4, theDate )
				cmd:Bind ( 5, reason )
				cmd:Bind ( 6, responsible )
				cmd:Bind ( 7, ( args.responsibleSteamID or "" ) )
				cmd:Execute ( )
			end
			self.unmuteTimers [ args.steamID ] = setTimer ( unmutePlayer, args.duration, 1, args.steamID )
			self.mutes [ args.steamID ] = true
			local player = ( IsValid ( args.player, false ) and args.player or getPlayerBySteamID ( args.steamID ) )
			if ( player ) then
				Events:Fire ( "onPlayerMuted", player )
			end
		else
			local cmd = SQL:Command ( "DELETE FROM mutes WHERE steamID = ?" )
			cmd:Bind ( 1, args.steamID )
			cmd:Execute ( )
			self.mutes [ args.steamID ] = nil
			if isTimer ( self.unmuteTimers [ args.steamID ] ) then
				killTimer ( self.unmuteTimers [ args.steamID ] )
			end
			self.unmuteTimers [ args.steamID ] = nil
			local player = ( IsValid ( args.player, false ) and args.player or getPlayerBySteamID ( args.steamID ) )
			if IsValid ( player, false ) then
				player:Message ( "You are now unmuted!", "info" )
				Events:Fire ( "onPlayerUnmuted", player )
			end
		end

		return true
	else
		return false
	end
end

function unmutePlayer ( steamID )
	if ( steamID ) then
		mute:setPlayerMuted ( { steamID = steamID }, false )
	else
		return false
	end
end

function Mute:isPlayerMuted ( player )
	if IsValid ( player, false ) then
		local state = self.mutes [ tostring ( player:GetSteamId ( ) ) ]
		return ( state == nil and false or state )
	else
		return false
	end
end

function Mute:isSteamIDMuted ( steamID )
	local query = SQL:Query ( "SELECT * FROM mutes WHERE steamID = ?" )
	query:Bind ( 1, steamID )
	local result = query:Execute ( )
	if ( #result > 0 ) then
		return result
	else
		return false
	end
end

mute = Mute ( )

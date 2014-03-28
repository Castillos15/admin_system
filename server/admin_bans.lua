class "banSystem"

function banSystem:__init ( )
	SQL:Execute ( "CREATE TABLE IF NOT EXISTS bans ( steamID VARCHAR, name VARCHAR, duration BIGINT(255), date VARCHAR, reason VARCHAR, responsible VARCHAR, responsibleSteamID VARCHAR )" )

	Events:Subscribe ( "PlayerJoin", self, self.onPlayerJoin )
end

function banSystem:onPlayerJoin ( args )
	local steamID = tostring ( args.player:GetSteamId ( ) )
	local banData = self:isBanned ( steamID )
	if ( type ( banData ) == "table" ) then
		local banData = banData [ 1 ]
		local duration = tonumber ( banData.duration ) or 0
		local expired = false
		if ( duration >= os.time ( ) ) then
			local timeLeft = ( duration - os.time ( ) )
			local minutes = math.floor ( timeLeft / 60 )
			local seconds = ( timeLeft - ( minutes * 60 ) )
			local hours = math.floor ( minutes / 60 )
			local minutes = ( minutes - ( hours * 60 ) )
			local days = math.floor ( hours / 24 )
			local hours = ( hours - ( days * 24 ) )
			if ( minutes == 0 and hours == 0 and days == 0 ) then
				expired = "You are banned. \n\nExpires in: ".. ( seconds ) .." second(s)\n\nReason: ".. tostring ( banData.reason )
			elseif ( hours == 0 and days == 0 ) then
				expired = "You are banned. \n\nExpires in: ".. ( minutes ) .." minute(s), ".. tostring ( seconds ) .." second(s)\n\nReason: ".. tostring ( banData.reason )
			elseif ( days == 0 ) then
				expired = "You are banned. \n\nExpires in: ".. ( hours ) .." hour(s), ".. tostring ( minutes ) .." minute(s), ".. tostring ( seconds ) .." second(s)\n\nReason: ".. tostring ( banData.reason )
			else
				expired = "You are banned. \n\nExpires in: ".. ( days ) .." day(s), ".. ( hours ) .." hour(s), ".. tostring ( minutes ) .." minute(s), ".. tostring ( seconds ) .." second(s)\n\nReason: ".. tostring ( banData.reason )
			end
		end

		if ( duration == 0 ) then
			expired = "You are permanently banned\n\nReason: ".. tostring ( banData.reason )
		end

		if ( duration <= os.time ( ) and duration ~= 0 ) then
			self:removeBan ( steamID )
		else
			args.player:Kick ( expired )
		end
	end
end

function banSystem:addBan ( args )
	if ( type ( args ) == "table" ) then
		if self:isBanned ( args.steamID ) then
			return false
		end

		local cmd = SQL:Command ( "INSERT INTO bans ( steamID, name, duration, date, reason, responsible, responsibleSteamID ) VALUES ( ?, ?, ?, ?, ?, ?, ? )" )
		local theDate = os.date ( "%c" )
		local duration = 0
		local responsible = ( args.responsible or "System" )
		local reason = ( args.reason or "" )
		if ( args.duration == 0 ) then
			duration = 0
		else
			duration = tonumber ( os.time ( ) ) + ( tonumber ( args.duration ) * 60 )
		end
		cmd:Bind ( 1, args.steamID )
		cmd:Bind ( 2, ( args.name or "" ) )
		cmd:Bind ( 3, duration )
		cmd:Bind ( 4, theDate )
		cmd:Bind ( 5, reason )
		cmd:Bind ( 6, responsible )
		cmd:Bind ( 7, ( args.responsibleSteamID or "" ) )
		cmd:Execute ( )

		local player = getPlayerBySteamID ( args.steamID )
		if IsValid ( player, false ) then
			Chat:Broadcast ( tostring ( args.name ) .." was banned by ".. tostring ( responsible ) .." ( ".. tostring ( reason ) .." )", Color ( 255, 0, 0 ) )
			player:Kick ( "You were banned by ".. tostring ( responsible ) .."\n\nReason: ".. tostring ( reason ) )
		end

		return true
	else
		return false
	end
end

function banSystem:removeBan ( steamID )
	if ( steamID ) then
		local cmd = SQL:Command ( "DELETE FROM bans WHERE steamID = ?" )
		cmd:Bind ( 1, steamID )
		cmd:Execute ( )

		return true
	else
		return false
	end
end

function banSystem:isBanned ( steamID )
	local query = SQL:Query ( "SELECT * FROM bans WHERE steamID = ?" )
	query:Bind ( 1, steamID )
	local result = query:Execute ( )
	if ( #result > 0 ) then
		return result
	else
		return false
	end
end

function banSystem:getBans ( )
	local query = SQL:Query ( "SELECT * FROM bans" )
	local result = query:Execute ( )
	if ( type ( result ) == "table" ) then
		return result
	else
		return { }
	end
end

banSystem = banSystem ( )

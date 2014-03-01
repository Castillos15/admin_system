class "Admin"

local firstAdmin = "Your Steam ID Here" -- CHANGE IT!
local msgColors =
	{
		[ "err" ] = Color ( 255, 0, 0 ),
		[ "info" ] = Color ( 0, 255, 0 ),
		[ "warn" ] = Color ( 255, 100, 0 )
	}

function Admin:__init ( )
	self.permissions =
		{
			"player.kick",
			"player.ban",
			"player.mute",
			"player.kill",
			"player.warp",
			"player.spectate",
			"player.setmodel",
			"player.sethealth",
			"player.setmoney",
			"player.giveweapon",
			"player.warpto",
			"player.freeze",
			"player.giveadmin",
			"player.takeadmin",
			"player.givemoney",
			"player.givevehicle",
			"player.repairvehicle",
			"player.destroyvehicle",
			"player.shout",
			"general.adminpanel",
			"general.tab_players",
			"general.tab_acl",
			"general.tab_bans",
			"general.tab_modules",
			"general.tab_server",
			"general.tab_adminchat",
			"general.settime",
			"general.settimestep",
			"general.setweather",
			"ban.add",
			"ban.remove",
			"module.load",
			"module.unload",
			"acl.creategroup",
			"acl.removegroup",
			"acl.modifypermission",
			"acl.addobject",
			"acl.removeobject"
		}
	self.weaponNames =
		{
			[ 2 ] = "Pistol",
			[ 4 ] = "Revolver",
			[ 5 ] = "SMG",
			[ 6 ] = "Sawed off shotgun",
			[ 11 ] = "Assault rifle",
			[ 13 ] = "Pump action shotgun",
			[ 14 ] = "Sniper rifle",
			[ 16 ] = "Rocket launcher",
			[ 26 ] = "Minigun",
			[ 28 ] = "Machine gun",
			[ 31 ] = "SAM launcher",
			[ 32 ] = "Sentry Gun",
			[ 43 ] = "Bubble blaster",
			[ 66 ] = "Panay's rocket launcher",
			[ 100 ] = "(DLC) Bull's Eye assault rifle",
			[ 101 ] = "(DLC) Air propulsion gun",
			[ 102 ] = "(DLC) Cluster bomb launcher",
			[ 103 ] = "(DLC) Rico's signature gun",
			[ 104 ] = "(DLC) Quad rocket launcher",
			[ 105 ] = "(DLC) Multi-lock missile launcher",
			[ 116 ] = "Vehicle rocket launcher",
			[ 129 ] = "Mounted machine gun"
		}
	self.validModels =
		{
			[ 90 ] = true,
			[ 63 ] = true,
			[ 8 ] = true,
			[ 12 ] = true,
			[ 58 ] = true,
			[ 38 ] = true,
			[ 87 ] = true,
			[ 22 ] = true,
			[ 27 ] = true,
			[ 103 ] = true,
			[ 70 ] = true,
			[ 11 ] = true,
			[ 84 ] = true,
			[ 19 ] = true,
			[ 36 ] = true,
			[ 78 ] = true,
			[ 71 ] = true,
			[ 79 ] = true,
			[ 96 ] = true,
			[ 80 ] = true,
			[ 95 ] = true,
			[ 60 ] = true,
			[ 15 ] = true,
			[ 17 ] = true,
			[ 86 ] = true,
			[ 16 ] = true,
			[ 18 ] = true,
			[ 64 ] = true,
			[ 40 ] = true,
			[ 1 ] = true,
			[ 39 ] = true,
			[ 61 ] = true,
			[ 26 ] = true,
			[ 21 ] = true,
			[ 2 ] = true,
			[ 5 ] = true,
			[ 32 ] = true,
			[ 85 ] = true,
			[ 59 ] = true,
			[ 9 ] = true,
			[ 65 ] = true,
			[ 25 ] = true,
			[ 30 ] = true,
			[ 34 ] = true,
			[ 100 ] = true,
			[ 83 ] = true,
			[ 51 ] = true,
			[ 74 ] = true,
			[ 67 ] = true,
			[ 101 ] = true,
			[ 3 ] = true,
			[ 98 ] = true,
			[ 42 ] = true,
			[ 44 ] = true,
			[ 23 ] = true,
			[ 52 ] = true,
			[ 66 ] = true
		}
	self.serverInfo =
		{
			name = Config:GetValue ( "Server", "Name" ),
			maxPlayers = Config:GetValue ( "Server", "MaxPlayers" ),
			description = Config:GetValue ( "Server", "Description" ),
			streamDistance = Config:GetValue ( "Streamer", "StreamDistance" ),
			spawnPosition = Config:GetValue ( "Player", "SpawnPosition" )
		}
	self.vehicles = { }
	self.canChat = { }

	json = require "JSON"

	-- Creates the first group "Admin" and adds the content of "firstAdmin" variable as member of it.
	local permissions = { }
	for _, perm in ipairs ( self.permissions ) do
		permissions [ perm ] = true
	end
	if ACL:createGroup ( "Admin", permissions, false, "Admin", { 255, 0, 0 } ) then
		if ( firstAdmin and firstAdmin ~= "" ) then
			ACL:groupAddObject ( "Admin", firstAdmin )
		end
	end

	-- Adds the players with the permission to use the admin chat to a table.
	for player in Server:GetPlayers ( ) do
		local steamID = tostring ( player:GetSteamId ( ) )
		if ACL:hasObjectPermissionTo ( steamID, "general.tab_adminchat" ) then
			self.canChat [ steamID ] = player
		end
	end

	-- Network events
	Network:Subscribe ( "admin.requestPermissions", self, self.requestPermissions )
	Network:Subscribe ( "admin.requestInformation", self, self.requestInformation )
	Network:Subscribe ( "admin.getServerInfo", self, self.getServerInfo )
	Network:Subscribe ( "admin.isAdmin", self, self.checkIfIsAdmin )
	Network:Subscribe ( "admin.executeAction", self, self.executeAction )
	Network:Subscribe ( "admin.getBans", self, self.getBans )
	-- Normal events
	Events:Subscribe ( "ModuleUnload", self, self.onModuleUnload )
	Events:Subscribe ( "PlayerJoin", self, self.onPlayerJoin )
	Events:Subscribe ( "PlayerQuit", self, self.onPlayerQuit )
end

function Admin:onModuleUnload ( )
	for vehicle in pairs ( self.vehicles ) do
		if IsValid ( vehicle ) then
			vehicle:Remove ( )
		end
	end
end

function Admin:onPlayerJoin ( args )
	local steamID = tostring ( args.player:GetSteamId ( ) )
	if ACL:hasObjectPermissionTo ( steamID, "general.tab_adminchat" ) then
		self.canChat [ steamID ] = args.player
	end
end

function Admin:onPlayerQuit ( args )
	self.canChat [ tostring ( args.player:GetSteamId ( ) ) ] = nil
end

function Admin:requestPermissions ( _, player )
	local perms = { }
	for _, perm in ipairs ( self.permissions ) do
		perms [ perm ] = ACL:hasObjectPermissionTo ( tostring ( player:GetSteamId ( ) ), perm )
	end
	Network:Send ( player, "admin.returnPermissions", { perms, self.permissions } )
end

function Admin:checkIfIsAdmin ( _, player )
	if IsValid ( player ) then
		if ACL:hasObjectPermissionTo ( tostring ( player:GetSteamId ( ) ), "general.adminpanel" ) then
			Network:Send ( player, "admin.showPanel", { bans = banSystem:getBans ( ), acl = ACL:groupList ( ) } )
		end
	end
end

function Admin:getServerInfo ( _, player )
	if IsValid ( player ) then
		self.serverInfo.time = os.time ( )
		self.serverInfo.serverTime = os.date ( "%X" )
		self.serverInfo.weatherSeverity = DefaultWorld:GetWeatherSeverity ( )
		self.serverInfo.timeStep = DefaultWorld:GetTimeStep ( )
		Network:Send ( player, "admin.displayServerInfo", self.serverInfo )
	end
end

function Admin:requestInformation ( player, admin )
	if IsValid ( player ) then
		local x, y, z = table.unpack ( tostring ( player:GetPosition ( ) ):split ( "," ) )
		local ax, ay, az = table.unpack ( tostring ( player:GetAngle ( ) ):split ( "," ) )
		local weapon = player:GetEquippedWeapon ( )
		local vehicle = player:GetVehicle ( )
		local steamID = tostring ( player:GetSteamId ( ) )
		local groups = ACL:getObjectGroups ( steamID )
		if ( type ( groups ) ~= "table" ) then
			groups = { "None" }
		end
		local data =
			{
				name = player:GetName ( ),
				ip = player:GetIP ( ),
				steamID = steamID,
				ping = player:GetPing ( ),
				health = math.floor ( ( player:GetHealth ( ) * 100 ) ) .."%",
				money = "$".. convertNumber ( player:GetMoney ( ) ),
				position = math.round ( x, 3 ) ..", ".. math.round ( y, 3 ) ..", ".. math.round ( z, 3 ),
				angle = math.round ( ax, 3 ) ..", ".. math.round ( ay, 3 ) ..", ".. math.round ( az, 3 ),
				vehicle = ( player:InVehicle ( ) and vehicle:GetName ( ) .." ( ID: ".. vehicle:GetModelId ( ) .." ) " or "On Foot" ),
				vehicleHealth = ( player:InVehicle ( ) and math.floor ( player:GetVehicle ( ):GetHealth ( ) * 100 ) or 0 ) .."%",
				model = player:GetModelId ( ),
				weapon = ( self.weaponNames [ weapon.id ] or "Unknown" ) .. " ( ID: ".. weapon.id .." )",
				weaponAmmo = ( weapon.ammo_clip + weapon.ammo_reserve ),
				world = player:GetWorld ( ):GetId ( ),
				groups = table.concat ( groups, ", " ),
				muted = mute:isPlayerMuted ( player ),
				frozen = isPlayerFrozen ( player ),
				isAdmin = ACL:isObjectInGroup ( steamID, "Admin" )
			}
		Network:Send ( admin, "admin.displayInformation", data )
	end
end

function Admin:executeAction ( args, player )
	if IsValid ( player ) then
		if ACL:hasObjectPermissionTo ( tostring ( player:GetSteamId ( ) ), args [ 1 ] ) then
			if ( args [ 1 ] == "player.ban" ) then
				if IsValid ( args [ 2 ] ) then
					local banArgs =
					{
						steamID = tostring ( args [ 2 ]:GetSteamId ( ) ),
						name = args [ 2 ]:GetName ( ),
						reason = ( args [ 3 ] or "No reason defined" ),
						duration = tonumber ( args [ 4 ] ) or 1,
						responsible = player:GetName ( ),
						responsibleSteamID = tostring ( player:GetSteamId ( ) )
					}
					if ( not banSystem:addBan ( banArgs ) ) then
						player:Message ( "Failed to add ban.", "err" )
					end
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.kick" ) then
				if IsValid ( args [ 2 ] ) then
					local reason = tostring ( args [ 3 ] or "No reason defined" )
					Chat:Broadcast ( args [ 2 ]:GetName ( ) .." was kicked by ".. player:GetName ( ) .." ( ".. reason .." )", Color ( 255, 0, 0 ) )
					args [ 2 ]:Kick ( reason )
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.mute" ) then
				if IsValid ( args [ 2 ] ) then
					if mute:isPlayerMuted ( args [ 2 ] ) then
						if mute:setPlayerMuted ( { steamID = tostring ( args [ 2 ]:GetSteamId ( ) ), player = args [ 2 ] }, false ) then
							Chat:Broadcast ( args [ 2 ]:GetName ( ) .." was unmuted by ".. player:GetName ( ), Color ( 0, 255, 0 ) )
							self:requestInformation ( args [ 2 ], player )
						else
							player:Message ( "Unable to unmute player.", "err" )
						end
					else
						local muteArgs =
						{
							player = args [ 2 ],
							steamID = tostring ( args [ 2 ]:GetSteamId ( ) ),
							name = args [ 2 ]:GetName ( ),
							reason = ( args [ 3 ] or "No reason defined" ),
							duration = tonumber ( args [ 4 ] ) or 1,
							responsible = player:GetName ( ),
							responsibleSteamID = tostring ( player:GetSteamId ( ) )
						}
						if mute:setPlayerMuted ( muteArgs, true ) then
							Chat:Broadcast ( args [ 2 ]:GetName ( ) .." was muted by ".. player:GetName ( ) .." for ".. tostring ( muteArgs.duration / 60 ) .." seconds ( ".. tostring ( muteArgs.reason ) .." )", Color ( 255, 0, 0 ) )
							self:requestInformation ( args [ 2 ], player )
						else
							player:Message ( "Unable to mute player.", "err" )
						end
					end
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.freeze" ) then
				if IsValid ( args [ 2 ] ) then
					if isPlayerFrozen ( args [ 2 ] ) then
						setPlayerFrozen ( args [ 2 ], false )
						player:Message ( "You have unfrozen ".. args [ 2 ]:GetName ( ), "info" )
						args [ 2 ]:Message ( "You have been unfrozen by ".. player:GetName ( ), "info" )
					else
						setPlayerFrozen ( args [ 2 ], true )
						player:Message ( "You have frozen ".. args [ 2 ]:GetName ( ), "err" )
						args [ 2 ]:Message ( "You have been frozen by ".. player:GetName ( ), "err" )
					end
					self:requestInformation ( args [ 2 ], player )
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.kill" ) then
				if IsValid ( args [ 2 ] ) then
					args [ 2 ]:SetHealth ( 0 )
					player:Message ( "You have killed ".. args [ 2 ]:GetName ( ), "err" )
					args [ 2 ]:Message ( "You have been killed by ".. player:GetName ( ), "err" )		
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.sethealth" ) then
				if IsValid ( args [ 2 ] ) then
					local value = ( tonumber ( args [ 3 ] ) or 100 )
					args [ 2 ]:SetHealth ( value / 100 )
					player:Message ( "You have set ".. args [ 2 ]:GetName ( ) .."'s health to ".. tostring ( value ) .."%", "info" )
					args [ 2 ]:Message ( player:GetName ( ) .." has set your health to ".. tostring ( value ) .."%", "info" )
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.setmodel" ) then
				if IsValid ( args [ 2 ] ) then
					if ( self.validModels [ args [ 3 ] ] ) then
						args [ 2 ]:SetModelId ( args [ 3 ] )
						player:Message ( "You have set ".. args [ 2 ]:GetName ( ) .."'s model to ".. tostring ( args [ 3 ] ), "info" )
						args [ 2 ]:Message ( player:GetName ( ) .." has set your model to ".. tostring ( args [ 3 ] ), "info" )
					else
						player:Message ( "Invalid model ID.", "err" )
					end
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.setmoney" ) then
				if IsValid ( args [ 2 ] ) then
					if tonumber ( args [ 3 ] ) then
						args [ 2 ]:SetMoney ( tonumber ( args [ 3 ] ) )
						player:Message ( "You have set ".. args [ 2 ]:GetName ( ) .."'s money to ".. tostring ( convertNumber ( args [ 3 ] ) ), "info" )
						args [ 2 ]:Message ( player:GetName ( ) .." has set your money to ".. tostring ( convertNumber ( args [ 3 ] ) ), "info" )
					else
						player:Message ( "Invalid value.", "err" )
					end
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.givemoney" ) then
				if IsValid ( args [ 2 ] ) then
					if tonumber ( args [ 3 ] ) then
						args [ 2 ]:SetMoney ( tonumber ( args [ 3 ] ) + args [ 2 ]:GetMoney ( ) )
						player:Message ( "You gave ".. args [ 2 ]:GetName ( ) .." $".. tostring ( convertNumber ( args [ 3 ] ) ), "info" )
						args [ 2 ]:Message ( player:GetName ( ) .." has given you $".. tostring ( convertNumber ( args [ 3 ] ) ), "info" )
					else
						player:Message ( "Invalid value.", "err" )
					end
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.warp" ) then
				if IsValid ( args [ 2 ] ) then
					local playerPos = args [ 2 ]:GetPosition ( )
					player:SetPosition ( playerPos + Vector3 ( 2, 0, 0 ) )
					player:Message ( "You warped to ".. args [ 2 ]:GetName ( ), "info" )
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.warpto" ) then
				if IsValid ( args [ 2 ] ) then
					if IsValid ( args [ 3 ] ) then
						local playerPos = args [ 2 ]:GetPosition ( )
						args [ 3 ]:SetPosition ( playerPos + Vector3 ( 2, 0, 0 ) )
						player:Message ( "You warped ".. args [ 2 ]:GetName ( ) .." to ".. args [ 3 ]:GetName ( ), "info" )
						args [ 3 ]:Message ( "You been warped to ".. args [ 2 ]:GetName ( ) .." by ".. player:GetName ( ), "info" )
					else
						player:Message ( "Target player is offline.", "err" )
					end
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.givevehicle" ) then
				if IsValid ( args [ 2 ] ) then
					if ( args [ 3 ] and Vehicle.GetNameByModelId ( args [ 3 ] ) ) then
						if args [ 2 ]:InVehicle ( ) then
							local veh = args [ 2 ]:GetVehicle ( )
							if ( veh ) then
								veh:Remove ( )
								self.vehicles [ veh ] = nil
							end
						end
						local template = args [ 4 ]
						if ( template ~= "Default" ) then
							if ( not vehicleTemplates [ args [ 3 ] ] ) then
								template = ""
							else
								local found = false
								for _, temp in ipairs ( vehicleTemplates [ args [ 3 ] ] ) do
									if ( args [ 4 ] == temp ) then
										found = true
										break
									end
								end
								if ( not found ) then
									template = ""
								end
							end
						else
							template = ""
						end
						local vehicle = Vehicle.Create (
							{
								model_id = args [ 3 ],
								position = args [ 2 ]:GetPosition ( ),
								angle = args [ 2 ]:GetAngle ( ),
								template = template
							}
						)
						if ( vehicle ) then
							vehicle:SetUnoccupiedRespawnTime ( nil )
							vehicle:SetDeathRemove ( true )
							vehicle:SetUnoccupiedRemove ( false )
							args [ 2 ]:EnterVehicle ( vehicle, VehicleSeat.Driver )
							self.vehicles [ vehicle ] = vehicle
							player:Message ( "You gave ".. args [ 2 ]:GetName ( ) .." a ".. tostring ( Vehicle.GetNameByModelId ( args [ 3 ] ) ), "info" )
							args [ 2 ]:Message ( player:GetName ( ) .." has given you a ".. tostring ( Vehicle.GetNameByModelId ( args [ 3 ] ) ), "info" )
						else
							player:Message ( "Failed to give vehicle to ".. args [ 2 ]:GetName ( ) .."!", "err" )
						end
					else
						player:Message ( "Incorrect vehicle model ID.", "err" )
					end
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.repairvehicle" ) then
				if IsValid ( args [ 2 ] ) then
					if args [ 2 ]:InVehicle ( ) then
						args [ 2 ]:GetVehicle ( ):SetHealth ( 1 )
						player:Message ( "You repaired ".. args [ 2 ]:GetName ( ) .."'s vehicle", "info" )
						args [ 2 ]:Message ( player:GetName ( ) .." has repaired your vehicle", "info" )
					else
						player:Message ( args [ 2 ]:GetName ( ) .." is not in a vehicle.", "err" )
					end
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.destroyvehicle" ) then
				if IsValid ( args [ 2 ] ) then
					if args [ 2 ]:InVehicle ( ) then
						local veh = args [ 2 ]:GetVehicle ( )
						if ( veh ) then
							veh:Remove ( )
							self.vehicles [ veh ] = nil
						end
					else
						player:Message ( args [ 2 ]:GetName ( ) .." is not in a vehicle.", "err" )
					end
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.giveweapon" ) then
				if IsValid ( args [ 2 ] ) then
					args [ 2 ]:GiveWeapon ( WeaponSlot [ args [ 4 ] ], Weapon ( args [ 3 ], 30, 70 ) )
					player:Message ( "You gave ".. args [ 2 ]:GetName ( ) .." the weapon: ".. tostring ( getWeaponNameFromID ( args [ 3 ] ) ) ..", ammo: 30 in clip, 70 maganize.", "info" )
					args [ 2 ]:Message ( player:GetName ( ) .." has given you the weapon: ".. tostring ( getWeaponNameFromID ( args [ 3 ] ) ) ..", ammo: 30 in clip, 70 maganize.", "info" )
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.giveadmin" ) then
				if IsValid ( args [ 2 ] ) then
					if ACL:groupAddObject ( "Admin", tostring ( args [ 2 ]:GetSteamId ( ) ) ) then
						player:Message ( "You gave admin rights to ".. args [ 2 ]:GetName ( ) .."!", "info" )
						args [ 2 ]:Message ( player:GetName ( ) .." has given you admin rights!", "info" )
						self:requestInformation ( args [ 2 ], player )
					else
						player:Message ( "Failed to give admin rights to ".. args [ 2 ]:GetName ( ) .."!", "err" )
					end
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.takeadmin" ) then
				if IsValid ( args [ 2 ] ) then
					if ACL:groupRemoveObject ( "Admin", tostring ( args [ 2 ]:GetSteamId ( ) ) ) then
						player:Message ( "You revoked ".. args [ 2 ]:GetName ( ) .."'s admin rights!", "err" )
						args [ 2 ]:Message ( player:GetName ( ) .." has revoked your admin rights!", "err" )
						self:requestInformation ( args [ 2 ], player )
					else
						player:Message ( "Failed to revoke admin rights from ".. args [ 2 ]:GetName ( ) .."!", "err" )
					end
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "player.shout" ) then
				if IsValid ( args [ 2 ] ) then
					Network:Send ( args [ 2 ], "admin.shout", { name = "(".. player:GetName ( ) ..")", msg = tostring ( args [ 3 ] or "" ) } )
				else
					player:Message ( "Player is offline.", "err" )
				end
			elseif ( args [ 1 ] == "ban.add" ) then
				if ( args [ 2 ] ) then
					local banArgs =
					{
						steamID = args [ 2 ],
						name = "Unknown",
						reason = args [ 3 ],
						duration = args [ 4 ],
						responsible = player:GetName ( ),
						responsibleSteamID = tostring ( player:GetSteamId ( ) )
					}
					if ( not banSystem:addBan ( banArgs ) ) then
						player:Message ( "Failed to add ban.", "err" )
					else
						player:Message ( "You have successfully banned ".. tostring ( args [ 2 ] ) .."!", "info" )
						self:getBans ( _, player )
					end
				else
					player:Message ( "No steam ID given.", "err" )
				end
			elseif ( args [ 1 ] == "ban.remove" ) then
				if ( args [ 2 ] ) then
					if banSystem:removeBan ( args [ 2 ] ) then
						player:Message ( "You have successfully unbanned ".. tostring ( args [ 2 ] ) .."!", "info" )
						self:getBans ( _, player )
					else
						player:Message ( "Failed to remove ban!", "err" )
					end
				else
					player:Message ( "No steam ID given.", "err" )
				end
			elseif ( args [ 1 ] == "general.settime" ) then
				if tonumber ( args [ 2 ] ) then
					DefaultWorld:SetTime ( tonumber ( args [ 2 ] ) )
					player:Message ( "Game time successfully changed.", "info" )
				else
					player:Message ( "Invalid value.", "err" )
				end
			elseif ( args [ 1 ] == "general.settimestep" ) then
				if tonumber ( args [ 2 ] ) then
					player:Message ( "Game time step successfully changed.", "info" )
					DefaultWorld:SetTimeStep ( tonumber ( args [ 2 ] ) )
				else
					player:Message ( "Invalid value.", "err" )
				end
			elseif ( args [ 1 ] == "general.setweather" ) then
				if tonumber ( args [ 2 ] ) then
					DefaultWorld:SetWeatherSeverity ( tonumber ( args [ 2 ] ) )
					player:Message ( "Game weather successfully changed.", "info" )
				else
					player:Message ( "Invalid value.", "err" )
				end
			elseif ( args [ 1 ] == "general.tab_adminchat" ) then
				for _, thePlayer in pairs ( self.canChat ) do
					Network:Send ( thePlayer, "admin.addChatMessage", { msg = player:GetName ( ) ..": ".. args [ 2 ] } )
				end
			elseif ( args [ 1 ] == "acl.modifypermission" ) then
				if ( args [ 2 ] ) then
					if ( args [ 3 ] and args [ 4 ] ) then
						if ACL:updateGroupPermission ( args [ 2 ], args [ 3 ], toboolean ( args [ 4 ] ) ) then
							player:Message ( "Successfully changed permission.", "info" )
							self:getACL ( nil, player )
						else
							player:Message ( "Failed to update permission!", "err" )
						end
					end
				else
					player:Message ( "No group given.", "err" )
				end
			elseif ( args [ 1 ] == "acl.creategroup" ) then
				if ( args [ 2 ] ) then
					if ( type ( args [ 3 ] ) == "table" ) then
						if ACL:createGroup ( args [ 2 ], args [ 3 ], player:GetName ( ) .."(".. tostring ( player:GetSteamId ( ) ) ..")" ) then
							player:Message ( "Successfully created ACL group ".. tostring ( args [ 2 ] ) .."!", "info" )
							self:getACL ( nil, player )
						else
							player:Message ( "Failed to create ACL group!", "err" )
						end
					else
						player:Message ( "Invalid permissions table.", "err" )
					end
				else
					player:Message ( "No group name was given.", "err" )
				end
			elseif ( args [ 1 ] == "acl.removegroup" ) then
				if ( args [ 2 ] ) then
					if ACL:destroyGroup ( args [ 2 ] ) then
						player:Message ( "You have successfully destroyed ACL group ".. tostring ( args [ 2 ] ) .."!", "err" )
						self:getACL ( nil, player )
					else
						player:Message ( "Failed to destroy ACL group!", "err" )
					end
				else
					player:Message ( "No group name was given.", "err" )
				end
			elseif ( args [ 1 ] == "acl.addobject" ) then
				if ( args [ 2 ] ) then
					if ( args [ 3 ] ) then
						if ACL:groupAddObject ( args [ 2 ], args [ 3 ] ) then
							player:Message ( "You have successfully added object ".. tostring ( args [ 3 ] ) .." to ACL group ".. tostring ( args [ 2 ] ) .."!", "info" )
							self:getACL ( nil, player )
						else
							player:Message ( "Failed to add object!", "err" )
						end
					else
						player:Message ( "No steam ID was given.", "err" )
					end
				else
					player:Message ( "No group name was given.", "err" )
				end
			elseif ( args [ 1 ] == "acl.removeobject" ) then
				if ( args [ 2 ] ) then
					if ( args [ 3 ] ) then
						if ACL:groupRemoveObject ( args [ 2 ], args [ 3 ] ) then
							player:Message ( "You have successfully remove object ".. tostring ( args [ 3 ] ) .." from ACL group ".. tostring ( args [ 2 ] ) .."!", "err" )
							self:getACL ( nil, player )
						else
							player:Message ( "Failed to remove object!", "err" )
						end
					else
						player:Message ( "No steam ID was given.", "err" )
					end
				else
					player:Message ( "No group name was given.", "err" )
				end
			end
		else
			player:Message ( "You don't have access to this function.", "err" )
		end
	end
end

function Admin:getBans ( _, player )
	if IsValid ( player ) then
		Network:Send ( player, "admin.displayBans", banSystem:getBans ( ) )
	end
end

function Admin:getACL ( _, player )
	if IsValid ( player ) then
		Network:Send ( player, "admin.displayACL", ACL:groupList ( ) )
	end
end

function Player:Message ( msg, color )
	self:SendChatMessage ( msg, msgColors [ color ] )
end

Events:Subscribe ( "ModuleLoad",
	function ( )
		Admin = Admin ( )
	end
)

class "Admin"

msgColors =
	{
		[ "err" ] = Color ( 255, 0, 0 ),
		[ "info" ] = Color ( 0, 255, 0 ),
		[ "warn" ] = Color ( 255, 100, 0 )
	}

function Admin:__init ( )
	self.permissions = { }
	self.panel = {
		main = { },
		ban = { },
		kick = { },
		mute = { },
		warp = { },
		manualBan = { },
		shout = { },
		permChange = { },
		aclCreate = { },
		aclObject = { },
		vehColor = { }
	}
	self.players = { }
	self.warpPlayers = { }
	self.serverInfo = { }
	self.vehicleList = { }
	self.vehicleModelFromName = { }
	self.reasons =
		{
			"Impersonating",
			"Spamming/Flooding",
			"Insulting/Flaming",
			"Cheating/Hacking",
			"Abusing bugs",
			"Advertising",
			"Not listening to staff",
			"Trolling/Griefing",
			"Using an unacceptable name"
		}
	self.bans = { }
	self.banData = { }
	self.permissionNames = { }
	self.permissionSelected = { }
	self.permissionItems = { }
	self.templateItems = { }
	self.modules = { }
	self.active = false
	self.playerUpdateTimer = Timer ( )
	self.serverUpdateTimer = Timer ( )
	self.playerPermissionsTimer = Timer ( )
	self.victim = false
	self.shoutName = ""
	self.shoutMessage = ""
	self.sx, self.sy = Game:GetSetting ( 30 ), Game:GetSetting ( 31 )

	for _, model in ipairs ( { 1, 2, 4, 7, 8, 9, 10, 11, 12, 13, 15, 18, 21, 22, 23, 26, 29, 31, 32, 33, 35, 36, 40, 41, 42, 43, 44, 46, 47, 48, 49, 52, 54, 55, 56, 60, 61, 63, 66, 70, 71, 72, 73, 74, 76, 77, 78, 79, 83, 84, 86, 87, 89, 90, 91, 5, 6, 16, 19, 25, 27, 28, 38, 45, 50, 69, 80, 88, 3, 14, 30, 34, 37, 39, 51, 57, 59, 62, 64, 65, 67, 81, 85 } ) do
		local name = Vehicle.GetNameByModelId ( model )
		table.insert (
			self.vehicleList,
			name
		)
		self.vehicleModelFromName [ name ] = model
	end
	table.sort ( self.vehicleList, function ( a, b ) return ( a < b ) end )

	self.panel.main.window = GUI:Window ( "Admin Panel by Castillo v0.2", Vector2 ( 0.2, 0.5 ), Vector2 ( 0.5, 0.8 ) )
	self.panel.main.window:Subscribe ( "WindowClosed", self, self.onPanelClose )
	self.panel.main.window:SetVisible ( false )
	GUI:Center ( self.panel.main.window )
	self.panel.main.tabPanel, self.tabs = GUI:TabControl ( { "Players", "ACL", "Bans", "Modules", "Server", "AdminChat" }, Vector2 ( 0.0, 0.0 ), Vector2 ( 0.0, 0.0 ), self.panel.main.window )
	self.panel.main.tabPanel:SetDock ( GwenPosition.Fill )
	self.panel.main.playersTab = self.tabs.players.base
	self.panel.main.aclTab = self.tabs.acl.base
	self.panel.main.bansTab = self.tabs.bans.base
	self.panel.main.modulesTab = self.tabs.modules.base
	self.panel.main.serverTab = self.tabs.server.base
	self.panel.main.adminchatTab = self.tabs.adminchat.base

	self.panel.main.playersList = GUI:SortedList ( Vector2 ( 0.0, 0.0 ), Vector2 ( 0.16, 0.66 ), self.panel.main.playersTab, { { name = "Players" } } )
	self.panel.main.playersList:Subscribe ( "RowSelected", self, self.getInformation )
	self.panel.main.playersSearch = GUI:TextBox ( "", Vector2 ( 0.0, 0.67 ), Vector2 ( 0.16, 0.035 ), "text", self.panel.main.playersTab )
	self.panel.main.playersSearch:Subscribe ( "TextChanged", self, self.searchPlayer )
	GUI:Label ( "Player:", Vector2 ( 0.165, 0.01 ), Vector2 ( 0.2, 0.1 ), self.panel.main.playersTab ):SetTextColor ( Color ( 255, 0, 0 ) )
	self.panel.main.playerName = GUI:Label ( "Name: N/A", Vector2 ( 0.17, 0.04 ), Vector2 ( 0.2, 0.03 ), self.panel.main.playersTab )
	self.panel.main.playerSteamID = GUI:Label ( "Steam ID: N/A", Vector2 ( 0.17, 0.07 ), Vector2 ( 0.2, 0.03 ), self.panel.main.playersTab )
	self.panel.main.playerIP = GUI:Label ( "IP: N/A", Vector2 ( 0.17, 0.1 ), Vector2 ( 0.2, 0.03 ), self.panel.main.playersTab )
	self.panel.main.playerPing = GUI:Label ( "Ping: N/A", Vector2 ( 0.17, 0.13 ), Vector2 ( 0.2, 0.03 ), self.panel.main.playersTab )
	self.panel.main.playerGroups = GUI:Label ( "Groups: N/A", Vector2 ( 0.17, 0.16 ), Vector2 ( 0.185, 0.03 ), self.panel.main.playersTab )
	self.panel.main.playerGroups:SetWrap ( true )
	GUI:Label ( "Game:", Vector2 ( 0.165, 0.2 ), Vector2 ( 0.2, 0.1 ), self.panel.main.playersTab ):SetTextColor ( Color ( 255, 0, 0 ) )
	self.panel.main.playerHealth = GUI:Label ( "Health: N/A", Vector2 ( 0.17, 0.23 ), Vector2 ( 0.2, 0.03 ), self.panel.main.playersTab )
	self.panel.main.playerMoney = GUI:Label ( "Money: N/A", Vector2 ( 0.17, 0.26 ), Vector2 ( 0.2, 0.5 ), self.panel.main.playersTab )
	self.panel.main.playerPosition = GUI:Label ( "Position: N/A", Vector2 ( 0.17, 0.29 ), Vector2 ( 0.2, 0.03 ), self.panel.main.playersTab )
	self.panel.main.playerAngle = GUI:Label ( "Angle: N/A", Vector2 ( 0.17, 0.32 ), Vector2 ( 0.2, 0.03 ), self.panel.main.playersTab )
	self.panel.main.playerModel = GUI:Label ( "Model: N/A", Vector2 ( 0.17, 0.35 ), Vector2 ( 0.2, 0.03 ), self.panel.main.playersTab )
	self.panel.main.playerWorld = GUI:Label ( "World: N/A", Vector2 ( 0.17, 0.38 ), Vector2 ( 0.2, 0.03 ), self.panel.main.playersTab )
	self.panel.main.playerWeapon = GUI:Label ( "Weapon: N/A", Vector2 ( 0.17, 0.41 ), Vector2 ( 0.2, 0.03 ), self.panel.main.playersTab )
	self.panel.main.playerWeaponAmmo = GUI:Label ( "Weapon ammo: N/A", Vector2 ( 0.17, 0.44 ), Vector2 ( 0.2, 0.03 ), self.panel.main.playersTab )
	GUI:Label ( "Vehicle:", Vector2 ( 0.165, 0.48 ), Vector2 ( 0.2, 0.1 ), self.panel.main.playersTab ):SetTextColor ( Color ( 255, 0, 0 ) )
	self.panel.main.playerVehicle = GUI:Label ( "Name: N/A", Vector2 ( 0.17, 0.51 ), Vector2 ( 0.2, 0.03 ), self.panel.main.playersTab )
	self.panel.main.playerVehicleHealth = GUI:Label ( "Health: N/A", Vector2 ( 0.17, 0.54 ), Vector2 ( 0.2, 0.03 ), self.panel.main.playersTab )

	self.panel.main.ban = GUI:Button ( "Ban", Vector2 ( 0.36, 0.01 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.ban" )
	self.panel.main.ban:Subscribe ( "Press", self, self.showBanWindow )
	self.panel.main.kick = GUI:Button ( "Kick", Vector2 ( 0.423, 0.01 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.kick" )
	self.panel.main.kick:Subscribe ( "Press", self, self.showKickWindow )
	self.panel.main.mute = GUI:Button ( "Mute", Vector2 ( 0.36, 0.05 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.mute" )
	self.panel.main.mute:Subscribe ( "Press", self, self.showMuteWindow )
	self.panel.main.freeze = GUI:Button ( "Freeze", Vector2 ( 0.423, 0.05 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.freeze" )
	self.panel.main.freeze:Subscribe ( "Press", self, self.freezePlayer )
	self.panel.main.kill = GUI:Button ( "kill", Vector2 ( 0.36, 0.09 ), Vector2 ( 0.123, 0.03 ), self.panel.main.playersTab, "player.kill" )
	self.panel.main.kill:Subscribe ( "Press", self, self.killPlayer )
	self.panel.main.valueField = GUI:TextBox ( "", Vector2 ( 0.36, 0.15 ), Vector2 ( 0.123, 0.03 ), "numeric", self.panel.main.playersTab )
	self.panel.main.setHealth = GUI:Button ( "Set Health", Vector2 ( 0.36, 0.19 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.sethealth" )
	self.panel.main.setHealth:Subscribe ( "Press", self, self.setHealth )
	self.panel.main.setModel = GUI:Button ( "Set Model", Vector2 ( 0.423, 0.19 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.setmodel" )
	self.panel.main.setModel:Subscribe ( "Press", self, self.setModel )
	self.panel.main.setMoney = GUI:Button ( "Set Money", Vector2 ( 0.36, 0.23 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.setmoney" )
	self.panel.main.setMoney:Subscribe ( "Press", self, self.setMoney )
	self.panel.main.giveMoney = GUI:Button ( "Give money", Vector2 ( 0.423, 0.23 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.givemoney" )
	self.panel.main.giveMoney:Subscribe ( "Press", self, self.giveMoney )
	self.panel.main.warpTo = GUI:Button ( "Warp to...", Vector2 ( 0.36, 0.28 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.warp" )
	self.panel.main.warpTo:Subscribe ( "Press", self, self.warpTo )
	self.panel.main.spectate = GUI:Button ( "Spectate", Vector2 ( 0.423, 0.28 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.spectate" )
	self.panel.main.spectate:Subscribe ( "Press", self, self.spectate )
	self.panel.main.warpPlayerTo = GUI:Button ( "Warp player to...", Vector2 ( 0.36, 0.32 ), Vector2 ( 0.123, 0.03 ), self.panel.main.playersTab, "player.warpto" )
	self.panel.main.warpPlayerTo:Subscribe ( "Press", self, self.showWarpWindow )
	self.panel.main.vehicleMenu, items = GUI:ComboBox ( Vector2 ( 0.36, 0.36 ), Vector2 ( 0.123, 0.03 ), self.panel.main.playersTab, self.vehicleList )
	for _, item in pairs ( items ) do
		item:Subscribe ( "Press", self, self.displayVehicleTemplates )
	end

	self.panel.main.vehicleTemplateMenu = GUI:ComboBox ( Vector2 ( 0.36, 0.4 ), Vector2 ( 0.123, 0.03 ), self.panel.main.playersTab )
	table.insert ( self.templateItems, self.panel.main.vehicleTemplateMenu:AddItem ( "Default" ) )
	self.panel.main.giveVehicle = GUI:Button ( "Give", Vector2 ( 0.36, 0.44 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.givevehicle" )
	self.panel.main.giveVehicle:Subscribe ( "Press", self, self.giveVehicle )
	self.panel.main.destroyVehicle = GUI:Button ( "Destroy", Vector2 ( 0.423, 0.44 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.destroyvehicle" )
	self.panel.main.destroyVehicle:Subscribe ( "Press", self, self.destroyVehicle )
	self.panel.main.repairVehicle = GUI:Button ( "Repair", Vector2 ( 0.36, 0.48 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.repairvehicle" )
	self.panel.main.repairVehicle:Subscribe ( "Press", self, self.repairVehicle )
	self.panel.main.setVehicleColour = GUI:Button ( "Set colour", Vector2 ( 0.423, 0.48 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.setvehiclecolour" )
	self.panel.main.setVehicleColour:Subscribe ( "Press", self, self.showVehicleColourSelector )
	self.panel.main.weaponMenu = GUI:ComboBox ( Vector2 ( 0.36, 0.53 ), Vector2 ( 0.123, 0.03 ), self.panel.main.playersTab, getWeaponNames ( ) )
	self.panel.main.weaponSlotMenu = GUI:ComboBox ( Vector2 ( 0.36, 0.57 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, { "Primary", "Left", "Right" } )
	self.panel.main.giveWeapon = GUI:Button ( "Give", Vector2 ( 0.423, 0.57 ), Vector2 ( 0.06, 0.03 ), self.panel.main.playersTab, "player.giveweapon" )
	self.panel.main.giveWeapon:Subscribe ( "Press", self, self.giveWeapon )
	self.panel.main.giveAdmin = GUI:Button ( "Give admin rights", Vector2 ( 0.36, 0.67 ), Vector2 ( 0.123, 0.03 ), self.panel.main.playersTab, "player.giveadmin" )
	self.panel.main.giveAdmin:Subscribe ( "Press", self, self.giveAdmin )
	self.panel.main.shout = GUI:Button ( "Shout", Vector2 ( 0.36, 0.63 ), Vector2 ( 0.123, 0.03 ), self.panel.main.playersTab, "player.shout" )
	self.panel.main.shout:Subscribe ( "Press", self, self.showShoutWindow )

	GUI:Label ( "Server:", Vector2 ( 0.0, 0.01 ), Vector2 ( 0.2, 0.1 ), self.panel.main.serverTab ):SetTextColor ( Color ( 255, 0, 0 ) )
	self.panel.main.serverName = GUI:Label ( "Server name: N/A", Vector2 ( 0.005, 0.04 ), Vector2 ( 0.0, 0.0 ), self.panel.main.serverTab )
	self.panel.main.serverPlayers = GUI:Label ( "Players online: N/A", Vector2 ( 0.005, 0.07 ), Vector2 ( 0.0, 0.0 ), self.panel.main.serverTab )
	self.panel.main.serverDescription = GUI:Label ( "Description: N/A", Vector2 ( 0.005, 0.1 ), Vector2 ( 0.1, 0.03 ), self.panel.main.serverTab )
	self.panel.main.serverSpawnPosition = GUI:Label ( "Spawn Position: N/A", Vector2 ( 0.005, 0.13 ), Vector2 ( 0.1, 0.03 ), self.panel.main.serverTab )
	self.panel.main.serverTime = GUI:Label ( "Spawn Position: N/A", Vector2 ( 0.005, 0.16 ), Vector2 ( 0.1, 0.03 ), self.panel.main.serverTab )
	GUI:Label ( "Game:", Vector2 ( 0.0, 0.19 ), Vector2 ( 0.2, 0.13 ), self.panel.main.serverTab ):SetTextColor ( Color ( 255, 0, 0 ) )
	self.panel.main.serverGameTime = GUI:Label ( "Game Time: N/A", Vector2 ( 0.005, 0.22 ), Vector2 ( 0.0, 0.0 ), self.panel.main.serverTab )
	self.panel.main.serverGameTimeField = GUI:TextBox ( "", Vector2 ( 0.14, 0.219 ), Vector2 ( 0.03, 0.023 ), "numeric", self.panel.main.serverTab )
	self.panel.main.setGameTime = GUI:Button ( "Set", Vector2 ( 0.175, 0.218 ), Vector2 ( 0.031, 0.029 ), self.panel.main.serverTab, "general.settime" )
	self.panel.main.setGameTime:Subscribe ( "Press", self, self.setTime )
	GUI:Label ( "(0-23)", Vector2 ( 0.21, 0.225 ), Vector2 ( 0.03, 0.03 ), self.panel.main.serverTab )
	self.panel.main.serverWeather = GUI:Label ( "Weather Severity: N/A", Vector2 ( 0.005, 0.25 ), Vector2 ( 0.0, 0.0 ), self.panel.main.serverTab )
	self.panel.main.serverWeatherField = GUI:TextBox ( "", Vector2 ( 0.14, 0.25 ), Vector2 ( 0.03, 0.023 ), "numeric", self.panel.main.serverTab )
	self.panel.main.setWeatherSeverity = GUI:Button ( "Set", Vector2 ( 0.175, 0.25 ), Vector2 ( 0.031, 0.029 ), self.panel.main.serverTab, "general.setweather" )
	self.panel.main.setWeatherSeverity:Subscribe ( "Press", self, self.setWeather )
	GUI:Label ( "(0-2)", Vector2 ( 0.213, 0.26 ), Vector2 ( 0.03, 0.03 ), self.panel.main.serverTab )
	self.panel.main.serverTimeStep = GUI:Label ( "Time Step: N/A", Vector2 ( 0.005, 0.28 ), Vector2 ( 0.0, 0.0 ), self.panel.main.serverTab )
	self.panel.main.serverTimeStepField = GUI:TextBox ( "", Vector2 ( 0.14, 0.28 ), Vector2 ( 0.03, 0.023 ), "numeric", self.panel.main.serverTab )
	self.panel.main.setTimeStep = GUI:Button ( "Set", Vector2 ( 0.175, 0.28 ), Vector2 ( 0.031, 0.029 ), self.panel.main.serverTab, "general.settimestep" )
	self.panel.main.setTimeStep:Subscribe ( "Press", self, self.setTimeStep )
	GUI:Label ( "(0-inf)", Vector2 ( 0.21, 0.29 ), Vector2 ( 0.03, 0.03 ), self.panel.main.serverTab )

	self.panel.ban.window = GUI:Window ( "Ban Player", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.22, 0.24 ) )
	self.panel.ban.window:SetVisible ( false )
	GUI:Center ( self.panel.ban.window )
	self.panel.ban.reasonLabel = GUI:Label ( "Select a reason or write one", Vector2 ( 0.05, 0.01 ), Vector2 ( 0.19, 0.03 ), self.panel.ban.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.panel.ban.reasonCheck = GUI:CheckBox ( "", Vector2 ( 0.0, 0.04 ), Vector2 ( 0.018, 0.03 ), self.panel.ban.window )
	self.panel.ban.reasonEdit = GUI:TextBox ( "Custom reason", Vector2 ( 0.02, 0.04 ), Vector2 ( 0.19, 0.03 ), "text", self.panel.ban.window )
	self.panel.ban.reasonsBox = GUI:ComboBox ( Vector2 ( -0.001, 0.08 ), Vector2 ( 0.21, 0.03 ), self.panel.ban.window, self.reasons )
	self.panel.ban.durationLabel = GUI:Label ( "Select punishment duration", Vector2 ( 0.05, 0.13 ), Vector2 ( 0.19, 0.03 ), self.panel.ban.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.panel.ban.duration = GUI:TextBox ( "", Vector2 ( 0.0, 0.16 ), Vector2 ( 0.05, 0.03 ), "numeric", self.panel.ban.window )
	self.panel.ban.durationBox = GUI:ComboBox ( Vector2 ( 0.06, 0.16 ), Vector2 ( 0.08, 0.03 ), self.panel.ban.window, { "Days", "Hours", "Minutes", "Permanent" } )
	self.panel.ban.ban = GUI:Button ( "Ban", Vector2 ( 0.15, 0.16 ), Vector2 ( 0.06, 0.03 ), self.panel.ban.window )
	self.panel.ban.ban:Subscribe ( "Press", self, self.banPlayer )

	self.panel.kick.window = GUI:Window ( "Kick Player", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.22, 0.2 ) )
	self.panel.kick.window:SetVisible ( false )
	GUI:Center ( self.panel.kick.window )
	self.panel.kick.reasonLabel = GUI:Label ( "Select a reason or write one", Vector2 ( 0.05, 0.01 ), Vector2 ( 0.19, 0.03 ), self.panel.kick.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.panel.kick.reasonCheck = GUI:CheckBox ( "", Vector2 ( 0.0, 0.04 ), Vector2 ( 0.018, 0.03 ), self.panel.kick.window )
	self.panel.kick.reasonEdit = GUI:TextBox ( "Custom reason", Vector2 ( 0.02, 0.04 ), Vector2 ( 0.19, 0.03 ), "text", self.panel.kick.window )
	self.panel.kick.reasonsBox = GUI:ComboBox ( Vector2 ( -0.001, 0.08 ), Vector2 ( 0.21, 0.03 ), self.panel.kick.window, self.reasons )
	self.panel.kick.kick = GUI:Button ( "Kick", Vector2 ( 0.0, 0.12 ), Vector2 ( 0.21, 0.03 ), self.panel.kick.window )
	self.panel.kick.kick:Subscribe ( "Press", self, self.kickPlayer )

	self.panel.mute.window = GUI:Window ( "Mute Player", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.22, 0.24 ) )
	self.panel.mute.window:SetVisible ( false )
	GUI:Center ( self.panel.mute.window )
	self.panel.mute.reasonLabel = GUI:Label ( "Select a reason or write one", Vector2 ( 0.05, 0.01 ), Vector2 ( 0.19, 0.03 ), self.panel.mute.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.panel.mute.reasonCheck = GUI:CheckBox ( "", Vector2 ( 0.0, 0.04 ), Vector2 ( 0.018, 0.03 ), self.panel.mute.window )
	self.panel.mute.reasonEdit = GUI:TextBox ( "Custom reason", Vector2 ( 0.02, 0.04 ), Vector2 ( 0.19, 0.03 ), "text", self.panel.mute.window )
	self.panel.mute.reasonsBox = GUI:ComboBox ( Vector2 ( -0.001, 0.08 ), Vector2 ( 0.21, 0.03 ), self.panel.mute.window, self.reasons )
	self.panel.mute.durationLabel = GUI:Label ( "Select punishment duration", Vector2 ( 0.05, 0.13 ), Vector2 ( 0.19, 0.03 ), self.panel.mute.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.panel.mute.duration = GUI:TextBox ( "", Vector2 ( 0.0, 0.16 ), Vector2 ( 0.05, 0.03 ), "numeric", self.panel.mute.window )
	self.panel.mute.durationBox = GUI:ComboBox ( Vector2 ( 0.06, 0.16 ), Vector2 ( 0.08, 0.03 ), self.panel.mute.window, { "Minutes", "Hours", "Days" } )
	self.panel.mute.mute = GUI:Button ( "Mute", Vector2 ( 0.15, 0.16 ), Vector2 ( 0.06, 0.03 ), self.panel.mute.window )
	self.panel.mute.mute:Subscribe ( "Press", self, self.mutePlayer )

	self.panel.warp.window = GUI:Window ( "Warp Player To", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.2, 0.45 ) )
	self.panel.warp.window:SetVisible ( false )
	GUI:Center ( self.panel.warp.window )
	self.panel.warp.search = GUI:TextBox ( "", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.19, 0.03 ), "text", self.panel.warp.window )
	self.panel.warp.search:Subscribe ( "TextChanged", self, self.searchWarpPlayer )
	self.panel.warp.list = GUI:SortedList ( Vector2 ( 0.0, 0.04 ), Vector2 ( 0.19, 0.32 ), self.panel.warp.window, { { name = "Player" } } )
	self.panel.warp.warp = GUI:Button ( "Warp", Vector2 ( 0.0, 0.37 ), Vector2 ( 0.19, 0.035 ), self.panel.warp.window )
	self.panel.warp.warp:Subscribe ( "Press", self, self.warpPlayerTo )

	self.panel.main.bansList = GUI:SortedList ( Vector2 ( 0.0, 0.0 ), Vector2 ( 0.16, 0.66 ), self.panel.main.bansTab, { { name = "Ban" } } )
	self.panel.main.bansList:Subscribe ( "RowSelected", self, self.getBanInformation )
	self.panel.main.bansSearch = GUI:TextBox ( "", Vector2 ( 0.0, 0.67 ), Vector2 ( 0.16, 0.035 ), "text", self.panel.main.bansTab )
	self.panel.main.bansSearch:Subscribe ( "TextChanged", self, self.searchBan )
	GUI:Label ( "Ban details:", Vector2 ( 0.165, 0.01 ), Vector2 ( 0.2, 0.1 ), self.panel.main.bansTab ):SetTextColor ( Color ( 255, 0, 0 ) )
	self.panel.main.banSteamID = GUI:Label ( "Steam ID: N/A", Vector2 ( 0.17, 0.04 ), Vector2 ( 0.2, 0.03 ), self.panel.main.bansTab )
	self.panel.main.banName = GUI:Label ( "Name: N/A", Vector2 ( 0.17, 0.07 ), Vector2 ( 0.2, 0.03 ), self.panel.main.bansTab )
	self.panel.main.banDuration = GUI:Label ( "Duration: N/A", Vector2 ( 0.17, 0.1 ), Vector2 ( 0.2, 0.03 ), self.panel.main.bansTab )
	self.panel.main.banDate = GUI:Label ( "Date: N/A", Vector2 ( 0.17, 0.13 ), Vector2 ( 0.2, 0.03 ), self.panel.main.bansTab )
	self.panel.main.banResponsible = GUI:Label ( "Responsible: N/A", Vector2 ( 0.17, 0.16 ), Vector2 ( 0.2, 0.03 ), self.panel.main.bansTab )
	self.panel.main.banResponsibleSteam = GUI:Label ( "Responsible Steam ID: N/A", Vector2 ( 0.17, 0.19 ), Vector2 ( 0.2, 0.03 ), self.panel.main.bansTab )
	self.panel.main.banReasonScroll = GUI:ScrollControl ( Vector2 ( 0.17, 0.22 ), Vector2 ( 0.2, 0.25 ), self.panel.main.bansTab )
	self.panel.main.banReason = GUI:Label ( "Reason: N/A", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.2, 0.3 ), self.panel.main.banReasonScroll )
	self.panel.main.banReason:SetWrap ( true )
	self.panel.main.banReason:SizeToContents ( )
	self.panel.main.banRemove = GUI:Button ( "Unban", Vector2 ( 0.17, 0.67 ), Vector2 ( 0.07, 0.035 ), self.panel.main.bansTab, "ban.remove" )
	self.panel.main.banRemove:Subscribe ( "Press", self, self.removeBan )
	self.panel.main.banAdd = GUI:Button ( "Add ban", Vector2 ( 0.25, 0.67 ), Vector2 ( 0.07, 0.035 ), self.panel.main.bansTab, "ban.add" )
	self.panel.main.banAdd:Subscribe ( "Press", self, self.showManualBanWindow )
	self.panel.main.banRefresh = GUI:Button ( "Refresh", Vector2 ( 0.33, 0.67 ), Vector2 ( 0.07, 0.035 ), self.panel.main.bansTab )
	self.panel.main.banRefresh:Subscribe ( "Press", self, self.refreshBans )

	self.panel.manualBan.window = GUI:Window ( "Manual Ban", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.22, 0.3 ) )
	self.panel.manualBan.window:SetVisible ( false )
	GUI:Center ( self.panel.manualBan.window )
	GUI:Label ( "Write the Steam ID to ban", Vector2 ( 0.05, 0.001 ), Vector2 ( 0.19, 0.03 ), self.panel.manualBan.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.panel.manualBan.steamID = GUI:TextBox ( "", Vector2 ( 0.0, 0.025 ), Vector2 ( 0.21, 0.03 ), "text", self.panel.manualBan.window )
	GUI:Label ( "Select a reason or write one", Vector2 ( 0.05, 0.07 ), Vector2 ( 0.19, 0.03 ), self.panel.manualBan.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.panel.manualBan.reasonCheck = GUI:CheckBox ( "", Vector2 ( 0.0, 0.1 ), Vector2 ( 0.018, 0.03 ), self.panel.manualBan.window )
	self.panel.manualBan.reasonEdit = GUI:TextBox ( "Custom reason", Vector2 ( 0.02, 0.1 ), Vector2 ( 0.19, 0.03 ), "text", self.panel.manualBan.window )
	self.panel.manualBan.reasonsBox = GUI:ComboBox ( Vector2 ( -0.001, 0.14 ), Vector2 ( 0.21, 0.03 ), self.panel.manualBan.window, self.reasons )
	GUI:Label ( "Select punishment duration", Vector2 ( 0.05, 0.19 ), Vector2 ( 0.19, 0.03 ), self.panel.manualBan.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.panel.manualBan.duration = GUI:TextBox ( "", Vector2 ( 0.0, 0.22 ), Vector2 ( 0.05, 0.03 ), "numeric", self.panel.manualBan.window )
	self.panel.manualBan.durationBox = GUI:ComboBox ( Vector2 ( 0.06, 0.22 ), Vector2 ( 0.08, 0.03 ), self.panel.manualBan.window, { "Days", "Hours", "Minutes", "Permanent" } )
	self.panel.manualBan.ban = GUI:Button ( "Ban", Vector2 ( 0.15, 0.22 ), Vector2 ( 0.06, 0.03 ), self.panel.manualBan.window )
	self.panel.manualBan.ban:Subscribe ( "Press", self, self.manualBan )

	self.panel.shout.window = GUI:Window ( "Shout Player", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.25, 0.16 ) )
	self.panel.shout.window:SetVisible ( false )
	GUI:Center ( self.panel.shout.window )
	self.panel.shout.message = GUI:TextBox ( "", Vector2 ( 0.0, 0.01 ), Vector2 ( 0.24, 0.05 ), "text", self.panel.shout.window )
	self.panel.shout.shout = GUI:Button ( "Shout!", Vector2 ( 0.0, 0.07 ), Vector2 ( 0.24, 0.04 ), self.panel.shout.window )
	self.panel.shout.shout:Subscribe ( "Press", self, self.shoutPlayer )

	self.panel.main.chatScroll = GUI:ScrollControl ( Vector2 ( 0.0, 0.01 ), Vector2 ( 0.48, 0.6 ), self.panel.main.adminchatTab )
	self.panel.main.chatMessages = GUI:Label ( "", Vector2 ( 0.0, 0.011 ), Vector2 ( 0.48, 0.0 ), self.panel.main.chatScroll )
	self.panel.main.chatMessages:SetWrap ( true )
	self.panel.main.chatMessage = GUI:TextBox ( "", Vector2 ( 0.0, 0.66 ), Vector2 ( 0.38, 0.04 ), "text", self.panel.main.adminchatTab )
	self.panel.main.chatMessage:Subscribe ( "ReturnPressed", self, self.sendChatMessage )
	self.panel.main.sendMessage = GUI:Button ( "Send", Vector2 ( 0.385, 0.66 ), Vector2 ( 0.05, 0.04 ), self.panel.main.adminchatTab )
	self.panel.main.sendMessage:Subscribe ( "Press", self, self.sendChatMessage )
	self.panel.main.clearMessage = GUI:Button ( "Clear", Vector2 ( 0.44, 0.66 ), Vector2 ( 0.04, 0.04 ), self.panel.main.adminchatTab )
	self.panel.main.clearMessage:Subscribe ( "Press", self, self.clearChatMessage )

	self.panel.main.aclTree = GUI:Tree ( Vector2 ( 0.0, 0.0 ), Vector2 ( 0.2, 0.71 ), self.panel.main.aclTab )
	self.panel.main.aclDataLabel = GUI:Label ( "Group name: N/A\n\nCreator: N/A\n\nCreation date: N/A\n\nGroup objects: N/A", Vector2 ( 0.205, 0.01 ), Vector2 ( 0.0, 0.0 ), self.panel.main.aclTab )
	self.panel.main.aclDataLabel:SizeToContents ( )
	self.panel.main.aclCreateGroup = GUI:Button ( "Create group", Vector2 ( 0.21, 0.64 ), Vector2 ( 0.1, 0.03 ), self.panel.main.aclTab )
	self.panel.main.aclCreateGroup:Subscribe ( "Press", self, self.showACLCreateWindow )
	self.panel.main.aclDestroyGroup = GUI:Button ( "Destroy group", Vector2 ( 0.21, 0.68 ), Vector2 ( 0.1, 0.03 ), self.panel.main.aclTab )
	self.panel.main.aclDestroyGroup:Subscribe ( "Press", self, self.destroyACLGroup )
	self.panel.main.aclAddObject = GUI:Button ( "Add object", Vector2 ( 0.32, 0.64 ), Vector2 ( 0.1, 0.03 ), self.panel.main.aclTab )
	self.panel.main.aclAddObject:Subscribe ( "Press", self, self.showACLAddObjectWindow )
	self.panel.main.aclRemoveObject = GUI:Button ( "Remove object", Vector2 ( 0.32, 0.68 ), Vector2 ( 0.1, 0.03 ), self.panel.main.aclTab )
	self.panel.main.aclRemoveObject:Subscribe ( "Press", self, self.removeACLObject )

	self.panel.permChange.window = GUI:Window ( "ACL Permission", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.15, 0.2 ) )
	self.panel.permChange.window:SetVisible ( false )
	GUI:Center ( self.panel.permChange.window )
	self.panel.permChange.label = GUI:Label ( "Permission:", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.14, 0.1 ), self.panel.permChange.window )
	GUI:Label ( "Accepted values: true/false", Vector2 ( 0.0, 0.03 ), Vector2 ( 0.2, 0.1 ), self.panel.permChange.window )
	self.panel.permChange.value = GUI:TextBox ( "", Vector2 ( 0.01, 0.07 ), Vector2 ( 0.12, 0.03 ), "text", self.panel.permChange.window )
	self.panel.permChange.set = GUI:Button ( "Set permission", Vector2 ( 0.01, 0.12 ), Vector2 ( 0.12, 0.03 ), self.panel.permChange.window )
	self.panel.permChange.set:Subscribe ( "Press", self, self.modifyACLPermission )

	self.panel.aclCreate.window = GUI:Window ( "Create ACL Group", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.25, 0.45 ) )
	self.panel.aclCreate.window:SetVisible ( false )
	GUI:Center ( self.panel.aclCreate.window )
	GUI:Label ( "Group name:", Vector2 ( 0.001, 0.001 ), Vector2 ( 0.1, 0.03 ), self.panel.aclCreate.window )
	self.panel.aclCreate.name = GUI:TextBox ( "", Vector2 ( 0.001, 0.03 ), Vector2 ( 0.24, 0.03 ), "text", self.panel.aclCreate.window )
	self.panel.aclCreate.permissions = GUI:SortedList ( Vector2 ( 0.0, 0.07 ), Vector2 ( 0.24, 0.27 ), self.panel.aclCreate.window, { { name = "Permission" } } )
	self.panel.aclCreate.select = GUI:Button ( "Select", Vector2 ( 0.0, 0.34 ), Vector2 ( 0.12, 0.03 ), self.panel.aclCreate.window )
	self.panel.aclCreate.select:Subscribe ( "Press", self, self.onPermissionSelect )
	self.panel.aclCreate.selectAll = GUI:Button ( "Select all", Vector2 ( 0.12, 0.34 ), Vector2 ( 0.12, 0.03 ), self.panel.aclCreate.window )
	self.panel.aclCreate.selectAll:Subscribe ( "Press", self, self.onPermissionSelectAll )
	self.panel.aclCreate.create = GUI:Button ( "Create Group", Vector2 ( 0.0, 0.37 ), Vector2 ( 0.24, 0.03 ), self.panel.aclCreate.window )
	self.panel.aclCreate.create:Subscribe ( "Press", self, self.createACLGroup )

	self.panel.aclObject.window = GUI:Window ( "Add Object to: ", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.15, 0.15 ) )
	self.panel.aclObject.window:SetVisible ( false )
	GUI:Center ( self.panel.aclObject.window )
	GUI:Label ( "Steam ID to add:", Vector2 ( 0.001, 0.001 ), Vector2 ( 0.1, 0.03 ), self.panel.aclObject.window )
	self.panel.aclObject.value = GUI:TextBox ( "", Vector2 ( 0.0, 0.03 ), Vector2 ( 0.14, 0.03 ), "text", self.panel.aclObject.window )
	self.panel.aclObject.add = GUI:Button ( "Add", Vector2 ( 0.0, 0.07 ), Vector2 ( 0.14, 0.03 ), self.panel.aclObject.window )
	self.panel.aclObject.add:Subscribe ( "Press", self, self.addACLObject )

	self.panel.main.modulesList = GUI:SortedList ( Vector2 ( 0.0, 0.0 ), Vector2 ( 0.16, 0.66 ), self.panel.main.modulesTab, { { name = "Module" } } )
	self.panel.main.modulesSearch = GUI:TextBox ( "", Vector2 ( 0.0, 0.67 ), Vector2 ( 0.16, 0.035 ), "text", self.panel.main.modulesTab )
	self.panel.main.modulesSearch:Subscribe ( "TextChanged", self, self.searchModule )
	GUI:Label ( "Module log:", Vector2 ( 0.165, 0.01 ), Vector2 ( 0.2, 0.1 ), self.panel.main.modulesTab ):SetTextColor ( Color ( 255, 0, 0 ) )
	self.panel.main.modulesLogScroll = GUI:ScrollControl ( Vector2 ( 0.17, 0.04 ), Vector2 ( 0.34, 0.5 ), self.panel.main.modulesTab )
	self.panel.main.modulesLog = GUI:Label ( "", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.34, 0.5 ), self.panel.main.modulesLogScroll )
	self.panel.main.modulesLog:SetWrap ( true )
	self.panel.main.moduleLoad = GUI:Button ( "Load", Vector2 ( 0.17, 0.67 ), Vector2 ( 0.07, 0.035 ), self.panel.main.modulesTab, "module.load" )
	self.panel.main.moduleLoad:Subscribe ( "Press", self, self.loadModule )
	self.panel.main.moduleReload = GUI:Button ( "Reload", Vector2 ( 0.25, 0.67 ), Vector2 ( 0.07, 0.035 ), self.panel.main.modulesTab, "module.load" )
	self.panel.main.moduleReload:Subscribe ( "Press", self, self.reloadModule )
	self.panel.main.moduleUnload = GUI:Button ( "Unload", Vector2 ( 0.33, 0.67 ), Vector2 ( 0.07, 0.035 ), self.panel.main.modulesTab, "module.unload" )
	self.panel.main.moduleUnload:Subscribe ( "Press", self, self.unloadModule )
	self.panel.main.modulesRefresh = GUI:Button ( "Refresh", Vector2 ( 0.41, 0.67 ), Vector2 ( 0.07, 0.035 ), self.panel.main.modulesTab )
	self.panel.main.modulesRefresh:Subscribe ( "Press", self, self.refreshModules )

	self.panel.vehColor.window = GUI:Window ( "Vehicle Colour", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.3, 0.36 ) )
	GUI:Center ( self.panel.vehColor.window )
	self.panel.vehColor.window:SetVisible ( false )
	self.panel.vehColor.tabPanel, self.vehColorTabs = GUI:TabControl ( { "Tone 1", "Tone 2" }, Vector2 ( 0.0, 0.0 ), Vector2 ( 0.0, 0.0 ), self.panel.vehColor.window )
	self.panel.vehColor.tabPanel:SetDock ( GwenPosition.Fill )
	self.panel.vehColor.tone1 = GUI:ColorPicker ( true, Vector2 ( 0.0, 0.0 ), Vector2 ( 0.3, 0.23 ), self.vehColorTabs [ "tone 1" ].base )
	self.panel.vehColor.tone1Set = GUI:Button ( "Set colour", Vector2 ( 0.0, 0.24 ), Vector2 ( 0.282, 0.03 ), self.vehColorTabs [ "tone 1" ].base )
	self.panel.vehColor.tone1Set:Subscribe ( "Press", self, self.setVehicleTone1Colour )
	self.panel.vehColor.tone2 = GUI:ColorPicker ( true, Vector2 ( 0.0, 0.0 ), Vector2 ( 0.3, 0.23 ), self.vehColorTabs [ "tone 2" ].base )
	self.panel.vehColor.tone2Set = GUI:Button ( "Set colour", Vector2 ( 0.0, 0.24 ), Vector2 ( 0.282, 0.03 ), self.vehColorTabs [ "tone 2" ].base )
	self.panel.vehColor.tone2Set:Subscribe ( "Press", self, self.setVehicleTone2Colour )

	-- Normal events
	Events:Subscribe ( "KeyUp", self, self.onKeyPress )
	Events:Subscribe ( "PlayerJoin", self, self.onPlayerJoin )
	Events:Subscribe ( "PlayerQuit", self, self.onPlayerQuit )
	Events:Subscribe ( "LocalPlayerInput", self, self.disableControls )
	-- Events:Subscribe ( "ModuleUnload", self, self.onModuleUnload )
	-- Network events
	Network:Send ( "admin.requestPermissions" )
	Network:Subscribe ( "admin.returnPermissions", self, self.returnPermissions )
	Network:Subscribe ( "admin.displayInformation", self, self.displayInformation )
	Network:Subscribe ( "admin.displayServerInfo", self, self.displayServerInfo )
	Network:Subscribe ( "admin.showPanel", self, self.showPanel )
	Network:Subscribe ( "admin.displayBans", self, self.displayBans )
	Network:Subscribe ( "admin.shout", self, self.shout )
	Network:Subscribe ( "admin.addChatMessage", self, self.addChatMessage )
	Network:Subscribe ( "admin.displayACL", self, self.displayACL )
	Network:Subscribe ( "admin.displayModules", self, self.displayModules )
end

function Admin:isActive ( )
	return self.active
end

function Admin:setActive ( state )
	if ( state == true ) then
		Network:Send ( "admin.isAdmin" )
	else
		self.panel.main.window:SetVisible ( false )
		Mouse:SetVisible ( false )
		self.active = false
		if ( updateDataEvent ) then
			Events:Unsubscribe ( updateDataEvent )
		end
	end
end

function Admin:onKeyPress ( args )
	if ( args.key == string.byte ( "P" ) ) then
		self:setActive ( not self:isActive ( ) )
	end
end

function Admin:disableControls ( args )
	if ( self:isActive ( ) and Game:GetState ( ) == GUIState.Game ) then
		return false
	end
end

function Admin:onPanelClose ( )
	self:setActive ( false )
end

function Admin:showPanel ( data )
	self.panel.main.window:SetVisible ( true )
	Mouse:SetVisible ( true )
	self.active = true
	self:loadPlayersToList ( )
	updateDataEvent = Events:Subscribe ( "PostTick", self, self.updateData )
	Network:Send ( "admin.getServerInfo" )
	self:displayBans ( data.bans )
	self:displayACL ( data.acl )
	self:displayModules ( data.modules )
	for _, guiElement in ipairs ( GUI:GetAllProtected ( ) ) do
		local id = guiElement:GetDataString ( "id" )
		if ( id ) then
			if ( self.permissions [ id ] ~= nil ) then
				guiElement:SetEnabled ( self.permissions [ id ] )
			end
		end
	end
end

function Admin:returnPermissions ( perms )
	self.permissions = perms [ 1 ]
	self.permissionNames = perms [ 2 ]
end

function Admin:addPlayerToList ( player )
	local item = self.panel.main.playersList:AddItem ( player:GetName ( ) )
	item:SetDataObject ( "id", player )
	self.players [ tostring ( player:GetSteamId ( ) ) ] = item
end

function Admin:loadPlayersToList ( )
	self.panel.main.playersList:Clear ( )
	self:addPlayerToList ( LocalPlayer )
	for player in Client:GetPlayers ( ) do
		self:addPlayerToList ( player )
	end
end

function Admin:getInformation ( )
	local row = self.panel.main.playersList:GetSelectedRow ( )
	if ( row ) then
		local player = row:GetDataObject ( "id" )
		if IsValid ( player, false ) then
			Network:Send ( "admin.requestInformation", player )
		end
	end
end

function Admin:displayInformation ( data )
	if ( type ( data ) == "table" ) then
		self.panel.main.playerName:SetText ( "Name: ".. tostring ( data.name ) )
		self.panel.main.playerSteamID:SetText ( "Steam ID: ".. tostring ( data.steamID ) )
		self.panel.main.playerIP:SetText ( "IP: ".. tostring ( data.ip ) )
		self.panel.main.playerGroups:SetText ( "Groups: ".. tostring ( data.groups ) )
		self.panel.main.playerPing:SetText ( "Ping: ".. tostring ( data.ping ) )
		self.panel.main.playerHealth:SetText ( "Health: ".. tostring ( data.health ) )
		self.panel.main.playerMoney:SetText ( "Money: ".. tostring ( data.money ) )
		self.panel.main.playerPosition:SetText ( "Position: ".. tostring ( data.position ) )
		self.panel.main.playerAngle:SetText ( "Angle: ".. tostring ( data.angle ) )
		self.panel.main.playerWorld:SetText ( "World: ".. tostring ( data.world ) )
		self.panel.main.playerModel:SetText ( "Model: ".. tostring ( data.model ) )
		self.panel.main.playerVehicle:SetText ( "Name: ".. tostring ( data.vehicle ) )
		self.panel.main.playerVehicleHealth:SetText ( "Health: ".. tostring ( data.vehicleHealth ) )
		self.panel.main.playerWeapon:SetText ( "Weapon: ".. tostring ( data.weapon ) )
		self.panel.main.playerWeaponAmmo:SetText ( "Weapon ammo: ".. tostring ( data.weaponAmmo ) )
		self.panel.main.mute:SetText ( ( data.muted == true and "Unmute" or "Mute" ) )
		self.panel.main.freeze:SetText ( ( data.frozen == true and "Unfreeze" or "Freeze" ) )
		self.panel.main.giveAdmin:SetText ( ( data.isAdmin == true and "Revoke admin rights" or "Give admin rights" ) )
	end
end

function Admin:onPlayerJoin ( args )
	self:addPlayerToList ( args.player )
end

function Admin:onPlayerQuit ( args )
	local steamID = tostring ( args.player:GetSteamId ( ) )
	if ( self.players [ steamID ] ) then
		self.panel.main.playersList:RemoveItem ( self.players [ steamID ] )
		self.players [ steamID ] = nil
	end
end

function Admin:displayServerInfo ( info )
	self.serverInfo = info
	local timeTable = tostring ( math.round ( Game:GetTime ( ), 1 ) ):split ( "." )
	self.panel.main.serverName:SetText ( "Server Name: ".. tostring ( info.name ) )
	self.panel.main.serverName:SizeToContents ( )
	self.panel.main.serverPlayers:SetText ( "Players: ".. tostring ( self:countPlayers ( ) ) .."/".. tostring ( info.maxPlayers ) )
	self.panel.main.serverPlayers:SizeToContents ( )
	self.panel.main.serverDescription:SetText ( "Description: ".. tostring ( info.description ) )
	self.panel.main.serverDescription:SizeToContents ( )
	self.panel.main.serverSpawnPosition:SetText ( "Spawn Position: ".. tostring ( info.spawnPosition ) )
	self.panel.main.serverSpawnPosition:SizeToContents ( )
	self.panel.main.serverTime:SetText ( "Server Time: ".. tostring ( info.serverTime ) )
	self.panel.main.serverTime:SizeToContents ( )
	self.panel.main.serverGameTime:SetText ( "Game Time: ".. string.format ( "%02d:%02d", ( timeTable [ 1 ] or 0 ), ( timeTable [ 2 ] or 0 ) ) )
	self.panel.main.serverGameTime:SizeToContents ( )
	self.panel.main.serverWeather:SetText ( "Weather Severity: ".. tostring ( info.weatherSeverity ) )
	self.panel.main.serverWeather:SizeToContents ( )
	self.panel.main.serverTimeStep:SetText ( "Time Step: ".. tostring ( info.timeStep ) )
	self.panel.main.serverTimeStep:SizeToContents ( )
end

function Admin:updateData ( )
	if self:isActive ( ) then
		if ( self.serverUpdateTimer:GetSeconds ( ) >= 10 ) then
			Network:Send ( "admin.getServerInfo" )
			self.serverUpdateTimer:Restart ( )
		end
		if ( self.playerUpdateTimer:GetSeconds ( ) >= 5 ) then
			self:getInformation ( )
			self.playerUpdateTimer:Restart ( )
		end
		if ( self.playerPermissionsTimer:GetSeconds ( ) >= 15 ) then
			Network:Send ( "admin.requestPermissions" )
			self.playerPermissionsTimer:Restart ( )
		end
	end
end

function Admin:searchPlayer ( )
	local text = self.panel.main.playersSearch:GetText ( ):lower ( )
	if ( text:len ( ) > 0 ) then
		for _, item in pairs ( self.players ) do
			item:SetVisible ( false )
			if item:GetCellText ( 0 ):lower ( ):find ( text, 1, true ) then
				item:SetVisible ( true )
			end
		end
	else
		for _, item in pairs ( self.players ) do
			item:SetVisible ( true )
		end
	end
end

function Admin:showBanWindow ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		self.panel.ban.window:SetVisible ( true )
		self.victim = player
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:banPlayer ( )
	if IsValid ( self.victim, false ) then
		local reason = ( self.panel.ban.reasonCheck:GetChecked ( ) == true and self.panel.ban.reasonEdit:GetText ( ) or self.panel.ban.reasonsBox:GetSelectedItem ( ):GetText ( ) )
		local durationMethod = self.panel.ban.durationBox:GetSelectedItem ( ):GetText ( )
		local duration = tonumber ( self.panel.ban.duration:GetText ( ) )
		if ( not duration or duration < 0 or durationMethod == "Permanent" ) then
			duration = 0
		end
		if ( duration > 0 ) then
			if ( durationMethod == "Days" ) then
				duration = ( duration * 1440 )
			elseif ( durationMethod == "Hours" ) then
				duration = ( duration * 60 )
			end
		end

		Network:Send ( "admin.executeAction", { "player.ban", self.victim, reason, duration } )
		self.victim = false
		self.panel.ban.window:SetVisible ( false )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:showKickWindow ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		self.panel.kick.window:SetVisible ( true )
		self.victim = player
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:kickPlayer ( )
	if IsValid ( self.victim, false ) then
		local reason = ( self.panel.kick.reasonCheck:GetChecked ( ) == true and self.panel.kick.reasonEdit:GetText ( ) or self.panel.kick.reasonsBox:GetSelectedItem ( ):GetText ( ) )
		Network:Send ( "admin.executeAction", { "player.kick", self.victim, reason } )
		self.victim = false
		self.panel.kick.window:SetVisible ( false )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:showMuteWindow ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		if ( self.panel.main.mute:GetText ( ) == "Mute" ) then
			self.panel.mute.window:SetVisible ( true )
			self.victim = player
		else
			Network:Send ( "admin.executeAction", { "player.mute", player } )
		end
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:mutePlayer ( )
	if IsValid ( self.victim, false ) then
		local reason = ( self.panel.mute.reasonCheck:GetChecked ( ) == true and self.panel.mute.reasonEdit:GetText ( ) or self.panel.mute.reasonsBox:GetSelectedItem ( ):GetText ( ) )
		local durationMethod = self.panel.mute.durationBox:GetSelectedItem ( ):GetText ( )
		local duration = tonumber ( self.panel.mute.duration:GetText ( ) )
		if ( not duration or duration < 1 ) then
			duration = 0.1
		end
		if ( durationMethod == "Days" ) then
			duration = ( duration * 1440 )
		elseif ( durationMethod == "Hours" ) then
			duration = ( duration * 60 )
		end

		Network:Send ( "admin.executeAction", { "player.mute", self.victim, reason, ( duration * 60 ) } )
		self.victim = false
		self.panel.mute.window:SetVisible ( false )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:freezePlayer ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		Network:Send ( "admin.executeAction", { "player.freeze", player } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:killPlayer ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		Network:Send ( "admin.executeAction", { "player.kill", player } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:setHealth ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		local value = tonumber ( self.panel.main.valueField:GetText ( ) ) or 0
		if ( value > 100 ) then
			value = 100
		end
		Network:Send ( "admin.executeAction", { "player.sethealth", player, value } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:setModel ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		local value = tonumber ( self.panel.main.valueField:GetText ( ) ) or 0
		Network:Send ( "admin.executeAction", { "player.setmodel", player, value } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:setMoney ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		local value = tonumber ( self.panel.main.valueField:GetText ( ) ) or 0
		Network:Send ( "admin.executeAction", { "player.setmoney", player, value } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:giveMoney ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		local value = tonumber ( self.panel.main.valueField:GetText ( ) ) or 0
		Network:Send ( "admin.executeAction", { "player.givemoney", player, value } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:warpTo ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		Network:Send ( "admin.executeAction", { "player.warp", player } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:showWarpWindow ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		self.victim = player
		self.panel.warp.window:SetVisible ( true )
		self.panel.warp.list:Clear ( )
		local item = self.panel.warp.list:AddItem ( LocalPlayer:GetName ( ) )
		item:SetDataObject ( "id", LocalPlayer )
		self.warpPlayers [ LocalPlayer:GetSteamId ( ) ] = item
		for player in Client:GetPlayers ( ) do
			local item = self.panel.warp.list:AddItem ( player:GetName ( ) )
			item:SetDataObject ( "id", player )
			self.warpPlayers [ player:GetSteamId ( ) ] = item
		end
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:warpPlayerTo ( )
	if IsValid ( self.victim, false ) then
		local player = self:getListSelectedPlayer ( self.panel.warp.list )
		if ( player ) then
			Network:Send ( "admin.executeAction", { "player.warpto", self.victim, player } )
			self.panel.warp.window:SetVisible ( false )
		else
			self:Message ( "Player selected is offline.", "err" )
		end
	else
		self:Message ( "Player is offline.", "err" )
	end
end

function Admin:searchWarpPlayer ( )
	local text = self.panel.warp.search:GetText ( ):lower ( )
	if ( text:len ( ) > 0 ) then
		for _, item in pairs ( self.warpPlayers ) do
			item:SetVisible ( false )
			if item:GetCellText ( 0 ):lower ( ):find ( text, 1, true ) then
				item:SetVisible ( true )
			end
		end
	else
		for _, item in pairs ( self.warpPlayers ) do
			item:SetVisible ( true )
		end
	end
end

function Admin:spectate ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		self.victim = player
		if ( not spectateEvent ) then
			spectateEvent = Events:Subscribe ( "CalcView", self, self.spectateCamera )
		else
			if ( self.victim == player ) then
				Events:Unsubscribe ( spectateEvent )
			end
		end
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:spectateCamera ( )
	if IsValid ( self.victim, false ) then
		local position = self.victim:GetPosition ( )
		local angle = self.victim:GetAngle ( )
		Camera:SetPosition ( position + angle * Vector3 ( 0, 2.5, 10 ) )
		--return false
	else
		Events:Unsubscribe ( spectateEvent )
	end
end

function Admin:displayVehicleTemplates ( )
	for index, item in ipairs ( self.templateItems ) do
		if ( item ) then
			if ( item:GetText ( ) ~= "Default" ) then
				item:Remove ( )
			end
		end
		table.remove ( self.templateItems, index )
	end
	local name = self.panel.main.vehicleMenu:GetSelectedItem ( ):GetText ( )
	if ( name ) then
		local model = self.vehicleModelFromName [ name ]
		if ( model ) then
			local templates = vehicleTemplates [ model ]
			if ( templates ) then
				for _, template in ipairs ( templates ) do
					table.insert ( self.templateItems, self.panel.main.vehicleTemplateMenu:AddItem ( tostring ( template ) ) )
				end
			end
		end
	end
end

function Admin:giveVehicle ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		local name = self.panel.main.vehicleMenu:GetSelectedItem ( ):GetText ( )
		if ( name ) then
			local model = self.vehicleModelFromName [ name ]
			if ( model ) then
				local template = self.panel.main.vehicleTemplateMenu:GetSelectedItem ( ):GetText ( )
				Network:Send ( "admin.executeAction", { "player.givevehicle", player, model, template } )
			end
		end
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:destroyVehicle ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		Network:Send ( "admin.executeAction", { "player.destroyvehicle", player } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:repairVehicle ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		Network:Send ( "admin.executeAction", { "player.repairvehicle", player } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:showVehicleColourSelector ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		if player:InVehicle ( ) then
			self.panel.vehColor.window:SetVisible ( true )
			self.victim = player
		else
			self:Message ( "This player is not in a vehicle.", "err" )
		end
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:setVehicleTone1Colour ( )
	if IsValid ( self.victim, false ) then
		if self.victim:InVehicle ( ) then
			local color = self.panel.vehColor.tone1:GetColor ( )
			Network:Send ( "admin.executeAction", { "player.setvehiclecolour", self.victim, "tone1", color } )
			self.panel.vehColor.window:SetVisible ( false )
			self.victim = nil
		else
			self:Message ( "This player is not in a vehicle.", "err" )
		end
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:setVehicleTone2Colour ( )
	if IsValid ( self.victim, false ) then
		if self.victim:InVehicle ( ) then
			local color = self.panel.vehColor.tone2:GetColor ( )
			Network:Send ( "admin.executeAction", { "player.setvehiclecolour", self.victim, "tone2", color } )
			self.panel.vehColor.window:SetVisible ( false )
			self.victim = nil
		else
			self:Message ( "This player is not in a vehicle.", "err" )
		end
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:giveWeapon ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		local name = self.panel.main.weaponMenu:GetSelectedItem ( ):GetText ( )
		local slot = self.panel.main.weaponSlotMenu:GetSelectedItem ( ):GetText ( )
		if ( name and slot ) then
			Network:Send ( "admin.executeAction", { "player.giveweapon", player, getWeaponIDFromName ( name ), slot } )
		end
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:giveAdmin ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		if ( self.panel.main.giveAdmin:GetText ( ) == "Give admin rights" ) then
			Network:Send ( "admin.executeAction", { "player.giveadmin", player } )
		else
			Network:Send ( "admin.executeAction", { "player.takeadmin", player } )
		end
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:showShoutWindow ( )
	local player = self:getListSelectedPlayer ( self.panel.main.playersList )
	if ( player ) then
		self.victim = player
		self.panel.shout.window:SetVisible ( true )
	else
		self:Message ( "No player selected.", "err" )	
	end
end

function Admin:shoutPlayer ( )
	if IsValid ( self.victim, false ) then
		local message = self.panel.shout.message:GetText ( )
		if ( message ~= "" ) then
			Network:Send ( "admin.executeAction", { "player.shout", self.victim, message } )
			self.victim = false
			self.panel.shout.window:SetVisible ( false )
		end
	else
		self:Message ( "Player is offline.", "err" )	
	end
end

function Admin:shout ( args )
	if ( self.shoutEvent ) then
		Events:Unsubscribe ( self.shoutEvent )
	end

	if isTimer ( self.shoutTimer ) then
		killTimer ( self.shoutTimer )
	end

	self.shoutName = args.name
	self.shoutMessage = args.msg
	self.shoutEvent = Events:Subscribe ( "Render", self, self.renderShout )
	self.shoutTimer = setTimer ( self.removeShout, 5, 1 )
end

function Admin:renderShout ( )
	Render:DrawText ( Vector2 ( Render.Width / 2 - ( Render:GetTextWidth ( self.shoutName ) / 2 ), self.sy / 2 ), self.shoutName, Color ( 255, 200, 0 ), 30 )
	Render:DrawText ( Vector2 ( Render.Width / 2 - ( Render:GetTextWidth ( self.shoutMessage ) / 2 ), self.sy / 2 + 50 ), self.shoutMessage, Color ( 255, 200, 0 ), 30 )
end

function Admin:removeShout ( )
	local self = admin
	if ( self.shoutEvent ) then
		Events:Unsubscribe ( self.shoutEvent )
	end
	self.shoutName = ""
	self.shoutMessage = ""
	self.shoutTimer = nil
	self.shoutEvent = nil
end

function Admin:displayBans ( bans )
	self.panel.main.bansList:Clear ( )
	self.bans = { }
	self.banData = { }
	if ( bans ) then
		for _, ban in ipairs ( bans ) do
			local item = self.panel.main.bansList:AddItem ( ( ban.name == "" and ban.steamID or ban.name .."(".. tostring ( ban.steamID ) ..")" ) )
			item:SetDataString ( "id", ban.steamID )
			self.banData [ ban.steamID ] = ban
			self.bans [ ban.steamID ] = item
		end
	end
end

function Admin:getBanInformation ( )
	local row = self.panel.main.bansList:GetSelectedRow ( )
	if ( row ) then
		local id = row:GetDataString ( "id" )
		if ( id ) then
			local data = self.banData [ id ]
			if ( data ) then
				self.panel.main.banSteamID:SetText ( "Steam ID: ".. tostring ( id ) )
				self.panel.main.banName:SetText ( "Name: ".. tostring ( data.name ) )
				local duration = tonumber ( data.duration ) or 0
				local expired = false
				if ( duration <= self.serverInfo.time and duration ~= 0 ) then
					self.panel.main.banDuration:SetText ( "Duration: Already expired." )
				elseif ( duration == 0 ) then
					self.panel.main.banDuration:SetText ( "Duration: Permanent." )
				else
					local timeLeft = ( duration - self.serverInfo.time )
					local minutes = math.floor ( timeLeft / 60 )
					local seconds = ( timeLeft - ( minutes * 60 ) )
					local hours = math.floor ( minutes / 60 )
					local minutes = ( minutes - ( hours * 60 ) )
					local days = math.floor ( hours / 24 )
					local hours = ( hours - ( days * 24 ) )
					self.panel.main.banDuration:SetText ( "Duration: ".. tostring ( days ) .." day(s), ".. tostring ( hours ) .." hour(s), ".. tostring ( minutes ) .." min(s), ".. tostring ( seconds ) .." sec(s)" )
				end
				self.panel.main.banDuration:SizeToContents ( )
				self.panel.main.banDate:SetText ( "Date: ".. tostring ( data.date ):gsub ( " ", " - " ) )
				self.panel.main.banReason:SetText ( "Reason: ".. tostring ( data.reason ) )
				self.panel.main.banResponsible:SetText ( "Responsible: ".. tostring ( data.responsible ) )
				self.panel.main.banResponsibleSteam:SetText ( "Responsible Steam ID: ".. tostring ( data.responsibleSteamID ) )
			end
		end
	end
end

function Admin:searchBan ( )
	local text = self.panel.main.bansSearch:GetText ( ):lower ( )
	if ( text:len ( ) > 0 ) then
		for _, item in pairs ( self.bans ) do
			item:SetVisible ( false )
			if item:GetCellText ( 0 ):lower ( ):find ( text, 1, true ) then
				item:SetVisible ( true )
			end
		end
	else
		for _, item in pairs ( self.bans ) do
			item:SetVisible ( true )
		end
	end
end

function Admin:refreshBans ( )
	Network:Send ( "admin.getBans" )
end

function Admin:removeBan ( )
	local row = self.panel.main.bansList:GetSelectedRow ( )
	if ( row ) then
		local id = row:GetDataString ( "id" )
		if ( id ) then
			Network:Send ( "admin.executeAction", { "ban.remove", id } )
		end
	else
		self:Message ( "No ban selected.", "err" )
	end
end

function Admin:showManualBanWindow ( )
	self.panel.manualBan.window:SetVisible ( true )
end

function Admin:manualBan ( )
	local steamID = self.panel.manualBan.steamID:GetText ( )
	if ( steamID ~= "" ) then
		local reason = ( self.panel.manualBan.reasonCheck:GetChecked ( ) == true and self.panel.manualBan.reasonEdit:GetText ( ) or self.panel.manualBan.reasonsBox:GetSelectedItem ( ):GetText ( ) )
		local durationMethod = self.panel.manualBan.durationBox:GetSelectedItem ( ):GetText ( )
		local duration = tonumber ( self.panel.manualBan.duration:GetText ( ) )
		if ( not duration or duration < 0 or durationMethod == "Permanent" ) then
			duration = 0
		end
		if ( duration > 0 ) then
			if ( durationMethod == "Days" ) then
				duration = ( duration * 1440 )
			elseif ( durationMethod == "Hours" ) then
				duration = ( duration * 60 )
			end
		end

		Network:Send ( "admin.executeAction", { "ban.add", steamID, reason, duration } )
		self.panel.manualBan.window:SetVisible ( false )
	else
		self:Message ( "No steam ID given.", "err" )
	end
end

function Admin:setTime ( )
	local value = self.panel.main.serverGameTimeField:GetText ( )
	Network:Send ( "admin.executeAction", { "general.settime", value } )
end

function Admin:setWeather ( )
	local value = self.panel.main.serverWeatherField:GetText ( )
	Network:Send ( "admin.executeAction", { "general.setweather", value } )
end

function Admin:setTimeStep ( )
	local value = self.panel.main.serverTimeStepField:GetText ( )
	Network:Send ( "admin.executeAction", { "general.settimestep", value } )
end

function Admin:sendChatMessage ( )
	local text = self.panel.main.chatMessage:GetText ( )
	if ( text ~= "" ) then
		Network:Send ( "admin.executeAction", { "general.tab_adminchat", text } )
		self:clearChatMessage ( )
	end
end

function Admin:clearChatMessage ( )
	self.panel.main.chatMessage:SetText ( "" )
end

function Admin:addChatMessage ( args )
	local text = self.panel.main.chatMessages:GetText ( )
	if ( text == "" ) then
		self.panel.main.chatMessages:SetText ( args.msg )
	else
		self.panel.main.chatMessages:SetText ( text .."\n".. args.msg )
	end
	self.panel.main.chatMessages:SizeToContents ( )
end

function Admin:displayACL ( acl )
	if ( type ( acl ) == "table" ) then
		self.aclGroupData = { }
		self.panel.main.aclTree:Clear ( )
		self.panel.aclObject.window:SetDataString ( "group", "" )
		self.panel.main.aclTree:SetDataString ( "group", "" )
		self.panel.main.aclTree:SetDataString ( "object", "" )
		for _, group in ipairs ( acl ) do
			self.aclGroupData [ group.name ] = group
			local node = self.panel.main.aclTree:AddNode ( tostring ( group.name ) )
			node:Subscribe ( "Select", self, self.onACLGroupClick )
			local permNode = node:AddNode ( "Permissions" )
			for _, perm in ipairs ( self.permissionNames ) do
				local node = permNode:AddNode ( tostring ( perm ) )
				node:SetDataString ( "value", tostring ( group.permissions [ perm ] ) )
				node:Subscribe ( "Select", self, self.onACLRightClick )
				node:GetLabel ( ):SetTextNormalColor ( ( group.permissions [ perm ] and Color ( 0, 255, 0 ) or Color ( 255, 0, 0 ) ) )
				--node:SetToolTip ( "Value: ".. tostring ( group.permissions [ perm ] ) )
			end
			local objNode = node:AddNode ( "Objects" )
			for _, steamID in ipairs ( group.objects ) do
				local node = objNode:AddNode ( tostring ( steamID ) )
				node:Subscribe ( "Select", self, self.onACLObjectClick )
			end
		end
	end
end

function Admin:onACLGroupClick ( node )
	local name = node:GetText ( )
	local data = self.aclGroupData [ name ]
	if ( type ( data ) == "table" ) then
		self.panel.main.aclDataLabel:SetText ( "Group name: ".. tostring ( name ) .."\n\nCreator: ".. tostring ( data.creator ) .."\n\nCreation date: ".. tostring ( data.creationDate ):gsub ( " ", " - " ) .."\n\nGroup objects: ".. tostring ( #data.objects ) )
		self.panel.main.aclDataLabel:SizeToContents ( )
		self.panel.main.aclTree:SetDataString ( "group", name )
	end
end

function Admin:onACLRightClick ( node )
	local perm = node:GetText ( )
	local value = node:GetDataString ( "value" )
	self.panel.permChange.window:SetVisible ( true )
	self.panel.permChange.label:SetText ( "Permission: ".. tostring ( perm ) )
	self.panel.permChange.label:SizeToContents ( )
	self.panel.permChange.value:SetText ( tostring ( value ) )
end

function Admin:modifyACLPermission ( )
	local value = self.panel.permChange.value:GetText ( )
	local perm = self.panel.permChange.label:GetText ( ):gsub ( "Permission: ", "" )
	local group = self.panel.main.aclTree:GetDataString ( "group" )
	if ( value == "true" or value == "false" ) then
		Network:Send ( "admin.executeAction", { "acl.modifypermission", group, perm, value } )
	else
		self:Message ( "Invalid value, accepted values: true/false.", "err" )
	end
	self.panel.permChange.window:SetVisible ( false )
end

function Admin:showACLCreateWindow ( )
	self.panel.aclCreate.permissions:Clear ( )
	self.permissionItems = { }
	for _, perm in ipairs ( self.permissionNames ) do
		self.permissionItems [ perm ] = self.panel.aclCreate.permissions:AddItem ( tostring ( perm ) )
		self.permissionSelected [ perm ] = false
	end
	self.panel.aclCreate.window:SetVisible ( true )
end

function Admin:onPermissionSelect ( )
	local item = self.panel.aclCreate.permissions:GetSelectedRow ( )
	if ( item ) then
		local name = item:GetCellText ( 0 )
		if ( not self.permissionSelected [ name ] ) then
			item:SetTextColor ( Color ( 0, 255, 0 ) )
			self.permissionSelected [ name ] = true
		else
			item:SetTextColor ( Color ( 255, 255, 255 ) )
			self.permissionSelected [ name ] = false
		end
	end
end

function Admin:onPermissionSelectAll ( )
	for perm, item in pairs ( self.permissionItems ) do
		item:SetTextColor ( Color ( 0, 255, 0 ) )
		self.permissionSelected [ perm ] = true
	end
end

function Admin:createACLGroup ( )
	local name = self.panel.aclCreate.name:GetText ( )
	if ( name ~= "" ) then
		local perms = { }
		for _, perm in ipairs ( self.permissionNames ) do
			perms [ perm ] = self.permissionSelected [ perm ]
		end
		Network:Send ( "admin.executeAction", { "acl.creategroup", name, perms } )
		self.panel.aclCreate.window:SetVisible ( false )
	else
		self:Message ( "Write a group name.", "err" )
	end
end

function Admin:destroyACLGroup ( )
	local group = self.panel.main.aclTree:GetDataString ( "group" )
	if ( group and group ~= "" ) then
		Network:Send ( "admin.executeAction", { "acl.removegroup", group } )
	end
end

function Admin:showACLAddObjectWindow ( )
	local group = self.panel.main.aclTree:GetDataString ( "group" )
	if ( group and group ~= "" ) then
		self.panel.aclObject.window:SetTitle ( "Add Object to: ".. tostring ( group ) )
		self.panel.aclObject.window:SetDataString ( "group", group )
		self.panel.aclObject.window:SetVisible ( true )
	end
end

function Admin:addACLObject ( )
	local group = self.panel.aclObject.window:GetDataString ( "group" )
	if ( group and group ~= "" ) then
		local steamID = self.panel.aclObject.value:GetText ( )
		if ( steamID ~= "" ) then
			Network:Send ( "admin.executeAction", { "acl.addobject", group, steamID } )
			self.panel.aclObject.window:SetVisible ( false )
		else
			self:Message ( "Write a steam ID to add.", "err" )
		end
	end
end

function Admin:onACLObjectClick ( node )
	local steamID = node:GetText ( )
	if ( steamID ) then
		self.panel.main.aclTree:SetDataString ( "object", steamID )
	end
end

function Admin:removeACLObject ( )
	local group = self.panel.main.aclTree:GetDataString ( "group" )
	if ( group and group ~= "" ) then
		local object = self.panel.main.aclTree:GetDataString ( "object" )
		if ( object and object ~= "" ) then
			Network:Send ( "admin.executeAction", { "acl.removeobject", group, object } )
		end
	end
end

function Admin:displayModules ( modules )
	self.panel.main.modulesList:Clear ( )
	self.modules = { }
	if ( modules ) then
		for name, state in pairs ( modules [ 1 ] ) do
			local item = self.panel.main.modulesList:AddItem ( tostring ( name ) )
			item:SetTextColor ( ( state and Color ( 0, 255, 0 ) or Color ( 255, 0, 0 ) ) )
			self.modules [ name ] = item
		end

		self.panel.main.modulesLog:SetText ( "" )
		for index, log_ in ipairs ( modules [ 2 ] ) do
			if ( index == 1 ) then
				self.panel.main.modulesLog:SetText ( modules [ 2 ] [ 1 ] )
			else
				self.panel.main.modulesLog:SetText ( self.panel.main.modulesLog:GetText ( ) .."\n".. tostring ( log_ ) )
			end
		end
		self.panel.main.modulesLog:SizeToContents ( )
		self.panel.main.modulesLog:SetWrap ( true )
	end
end

function Admin:searchModule ( )
	local text = self.panel.main.modulesSearch:GetText ( ):lower ( )
	if ( text:len ( ) > 0 ) then
		for _, item in pairs ( self.modules ) do
			item:SetVisible ( false )
			if item:GetCellText ( 0 ):lower ( ):find ( text, 1, true ) then
				item:SetVisible ( true )
			end
		end
	else
		for _, item in pairs ( self.modules ) do
			item:SetVisible ( true )
		end
	end
end

function Admin:loadModule ( )
	local row = self.panel.main.modulesList:GetSelectedRow ( )
	if ( row ) then
		local name = row:GetCellText ( 0 )
		if ( name ) then
			Network:Send ( "admin.executeAction", { "module.load", name } )
		end
	else
		self:Message ( "Please select a module.", "err" )
	end
end

function Admin:reloadModule ( )
	local row = self.panel.main.modulesList:GetSelectedRow ( )
	if ( row ) then
		local name = row:GetCellText ( 0 )
		if ( name ) then
			Network:Send ( "admin.executeAction", { "module.load", "module.reload", name } )
		end
	else
		self:Message ( "Please select a module.", "err" )
	end
end

function Admin:unloadModule ( )
	local row = self.panel.main.modulesList:GetSelectedRow ( )
	if ( row ) then
		local name = row:GetCellText ( 0 )
		if ( name ) then
			Network:Send ( "admin.executeAction", { "module.unload", name } )
		end
	else
		self:Message ( "Please select a module.", "err" )
	end
end

function Admin:refreshModules ( )
	Network:Send ( "admin.getModules" )
end

function Admin:Message ( msg, color )
	Chat:Print ( msg, msgColors [ color ] )
end

function Admin:countPlayers ( )
	local players = 1
	for player in Client:GetPlayers ( ) do
		players = ( players + 1 )
	end

	return players
end

function Admin:getListSelectedPlayer ( list )
	if ( list ) then
		local row = list:GetSelectedRow ( )
		if ( row ) then
			return row:GetDataObject ( "id" )
		end
	else
		return false
	end
end

function Admin:onModuleUnload ( )
	for _, panel in pairs ( self.panel ) do
		for _, gwen in pairs ( panel ) do
			gwen:Remove ( )
			gwen = nil
		end
	end
end

Events:Subscribe ( "ModuleLoad",
	function ( )
		admin = Admin ( )

		Events:Fire ( "HelpAddItem",
			{
				name = "Admin System",
				text = [[
					Admin System by Castillo

					Features:

					ACL ( Access Control List ): Controls the groups, group permissions, group members, able to disable entire panel tabs.
					Ban system: A SQL based ban system ( duration bans, date of the ban, the admin who banned, etc )
					Mute system: A SQL based mute system ( duration, date, admin responsible, etc )
					Freeze system: Freezing/unfreezing player ( disables all controls but camera movement )
					Spectating players: Not tested yet, but should work.
					Setting health/model/money
					Warp to players/warp player to another player
					Give/destroy/repair vehicles/set colour
					Give weapons to specified slot
					Shout to players: Displays a message on the center of the screen of the player selected.
					Killing players
					Setting game time/weather severity/time step
					Displaying some of the server config settings ( name, players/max players, etc )
					Admin chat
					Module management ( load/reload/unload modules )

					Commands:

					/ban <player> <duration in minutes> <reason> -> Bans a player for the given duration and reason.
					/kick<player> <reason> -> Kicks a player with the given reason.
					/mute <player> <duration in seconds> <reason> -> Mutes a player with given duration and reason.
					/freeze <player> -> Freezes/unfreezes a player.
					/kill <player> -> Kills a player.
					/sethealth <player> <value: 0-100> -> Sets the health of a player to the given value.
					/setmodel <player> <model ID> -> Sets the model of a player to the given value.
					/setmoney <player> <amount> -> Sets the money of a player to the given value.
					/givemoney <player> <amount> -> Gives the player the given amount of money.
					/warp <player> -> Warps to a player.
					/warpplayerto <player> <player to> -> Warps a player to another.
					/giveveh <player> <model ID> <template> -> Gives a vehicle to a player.
					/repairveh <player> -> Repairs the vehicle of a player.
					/destroyveh <player> -> Destroys the vehicle of a player.
					/giveweap <player> <weapon ID> -> Gives 100 ammo ( 30 magazine, 70 extra ammo ) of the specified weapon.
					/giveadmin <player> -> Adds the player to the "Admin" ACL group.
					/takeadmin <player> -> Removes the player from the "Admin" ACL group.
					/shout <player> <message> -> Displays a message on the player screen.
					/settime <value: 0-23> -> Sets the default world time to the specified value.
					/settimestep <value> -> Sets the default world time step to the specified value.
					/setweather <value: 0-2> -> Sets the default world weather severity to the specified value.
					/loadmodule <name> -> Loads a module.
					/reloadmodule <name> -> Reloads a module.
					/unloadmodule <name> -> Unloads a module.

					Toggle key: P
				]]
			}
		)
	end
)

Events:Subscribe ( "ModuleUnload",
	function ( )
		Events:Fire ( "HelpRemoveItem",
			{
				name = "Admin System"
			}
		)
	end
)

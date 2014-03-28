class "Admin"

msgColors =
	{
		[ "err" ] = Color ( 255, 0, 0 ),
		[ "info" ] = Color ( 0, 255, 0 ),
		[ "warn" ] = Color ( 255, 100, 0 )
	}

function Admin:__init ( )
	self.permissions = { }
	self.panel = { }
	self.banPanel = { }
	self.kickPanel = { }
	self.mutePanel = { }
	self.warpPanel = { }
	self.manualBanPanel = { }
	self.shoutPanel = { }
	self.permPanelChange = { }
	self.aclCreatePanel = { }
	self.aclObjectPanel = { }
	self.vehColorPanel = { }
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

	self.panel.window = GUI:Window ( "Admin Panel by Castillo v0.2", Vector2 ( 0.2, 0.5 ), Vector2 ( 0.5, 0.8 ) )
	self.panel.window:Subscribe ( "WindowClosed", self, self.onPanelClose )
	self.panel.window:SetVisible ( false )
	GUI:Center ( self.panel.window )
	self.panel.tabPanel, self.tabs = GUI:TabControl ( { "Players", "ACL", "Bans", "Modules", "Server", "AdminChat" }, Vector2 ( 0.0, 0.0 ), Vector2 ( 0.0, 0.0 ), self.panel.window )
	self.panel.tabPanel:SetDock ( GwenPosition.Fill )
	self.panel.playersTab = self.tabs.players.base
	self.panel.aclTab = self.tabs.acl.base
	self.panel.bansTab = self.tabs.bans.base
	self.panel.modulesTab = self.tabs.modules.base
	self.panel.serverTab = self.tabs.server.base
	self.panel.adminchatTab = self.tabs.adminchat.base

	self.panel.playersList = GUI:SortedList ( Vector2 ( 0.0, 0.0 ), Vector2 ( 0.16, 0.66 ), self.panel.playersTab, { { name = "Players" } } )
	self.panel.playersList:Subscribe ( "RowSelected", self, self.getInformation )
	self.panel.playersSearch = GUI:TextBox ( "", Vector2 ( 0.0, 0.67 ), Vector2 ( 0.16, 0.035 ), "text", self.panel.playersTab )
	self.panel.playersSearch:Subscribe ( "TextChanged", self, self.searchPlayer )
	GUI:Label ( "Player:", Vector2 ( 0.165, 0.01 ), Vector2 ( 0.2, 0.1 ), self.panel.playersTab ):SetTextColor ( Color ( 255, 0, 0 ) )
	self.panel.playerName = GUI:Label ( "Name: N/A", Vector2 ( 0.17, 0.04 ), Vector2 ( 0.2, 0.03 ), self.panel.playersTab )
	self.panel.playerSteamID = GUI:Label ( "Steam ID: N/A", Vector2 ( 0.17, 0.07 ), Vector2 ( 0.2, 0.03 ), self.panel.playersTab )
	self.panel.playerIP = GUI:Label ( "IP: N/A", Vector2 ( 0.17, 0.1 ), Vector2 ( 0.2, 0.03 ), self.panel.playersTab )
	self.panel.playerPing = GUI:Label ( "Ping: N/A", Vector2 ( 0.17, 0.13 ), Vector2 ( 0.2, 0.03 ), self.panel.playersTab )
	self.panel.playerGroups = GUI:Label ( "Groups: N/A", Vector2 ( 0.17, 0.16 ), Vector2 ( 0.185, 0.03 ), self.panel.playersTab )
	self.panel.playerGroups:SetWrap ( true )
	GUI:Label ( "Game:", Vector2 ( 0.165, 0.2 ), Vector2 ( 0.2, 0.1 ), self.panel.playersTab ):SetTextColor ( Color ( 255, 0, 0 ) )
	self.panel.playerHealth = GUI:Label ( "Health: N/A", Vector2 ( 0.17, 0.23 ), Vector2 ( 0.2, 0.03 ), self.panel.playersTab )
	self.panel.playerMoney = GUI:Label ( "Money: N/A", Vector2 ( 0.17, 0.26 ), Vector2 ( 0.2, 0.5 ), self.panel.playersTab )
	self.panel.playerPosition = GUI:Label ( "Position: N/A", Vector2 ( 0.17, 0.29 ), Vector2 ( 0.2, 0.03 ), self.panel.playersTab )
	self.panel.playerAngle = GUI:Label ( "Angle: N/A", Vector2 ( 0.17, 0.32 ), Vector2 ( 0.2, 0.03 ), self.panel.playersTab )
	self.panel.playerModel = GUI:Label ( "Model: N/A", Vector2 ( 0.17, 0.35 ), Vector2 ( 0.2, 0.03 ), self.panel.playersTab )
	self.panel.playerWorld = GUI:Label ( "World: N/A", Vector2 ( 0.17, 0.38 ), Vector2 ( 0.2, 0.03 ), self.panel.playersTab )
	self.panel.playerWeapon = GUI:Label ( "Weapon: N/A", Vector2 ( 0.17, 0.41 ), Vector2 ( 0.2, 0.03 ), self.panel.playersTab )
	self.panel.playerWeaponAmmo = GUI:Label ( "Weapon ammo: N/A", Vector2 ( 0.17, 0.44 ), Vector2 ( 0.2, 0.03 ), self.panel.playersTab )
	GUI:Label ( "Vehicle:", Vector2 ( 0.165, 0.48 ), Vector2 ( 0.2, 0.1 ), self.panel.playersTab ):SetTextColor ( Color ( 255, 0, 0 ) )
	self.panel.playerVehicle = GUI:Label ( "Name: N/A", Vector2 ( 0.17, 0.51 ), Vector2 ( 0.2, 0.03 ), self.panel.playersTab )
	self.panel.playerVehicleHealth = GUI:Label ( "Health: N/A", Vector2 ( 0.17, 0.54 ), Vector2 ( 0.2, 0.03 ), self.panel.playersTab )

	self.panel.ban = GUI:Button ( "Ban", Vector2 ( 0.36, 0.01 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.ban" )
	self.panel.ban:Subscribe ( "Press", self, self.showBanWindow )
	self.panel.kick = GUI:Button ( "Kick", Vector2 ( 0.423, 0.01 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.kick" )
	self.panel.kick:Subscribe ( "Press", self, self.showKickWindow )
	self.panel.mute = GUI:Button ( "Mute", Vector2 ( 0.36, 0.05 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.mute" )
	self.panel.mute:Subscribe ( "Press", self, self.showMuteWindow )
	self.panel.freeze = GUI:Button ( "Freeze", Vector2 ( 0.423, 0.05 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.freeze" )
	self.panel.freeze:Subscribe ( "Press", self, self.freezePlayer )
	self.panel.kill = GUI:Button ( "kill", Vector2 ( 0.36, 0.09 ), Vector2 ( 0.123, 0.03 ), self.panel.playersTab, "player.kill" )
	self.panel.kill:Subscribe ( "Press", self, self.killPlayer )
	self.panel.valueField = GUI:TextBox ( "", Vector2 ( 0.36, 0.15 ), Vector2 ( 0.123, 0.03 ), "numeric", self.panel.playersTab )
	self.panel.setHealth = GUI:Button ( "Set Health", Vector2 ( 0.36, 0.19 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.sethealth" )
	self.panel.setHealth:Subscribe ( "Press", self, self.setHealth )
	self.panel.setModel = GUI:Button ( "Set Model", Vector2 ( 0.423, 0.19 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.setmodel" )
	self.panel.setModel:Subscribe ( "Press", self, self.setModel )
	self.panel.setMoney = GUI:Button ( "Set Money", Vector2 ( 0.36, 0.23 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.setmoney" )
	self.panel.setMoney:Subscribe ( "Press", self, self.setMoney )
	self.panel.giveMoney = GUI:Button ( "Give money", Vector2 ( 0.423, 0.23 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.givemoney" )
	self.panel.giveMoney:Subscribe ( "Press", self, self.giveMoney )
	self.panel.warpTo = GUI:Button ( "Warp to...", Vector2 ( 0.36, 0.28 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.warp" )
	self.panel.warpTo:Subscribe ( "Press", self, self.warpTo )
	self.panel.spectate = GUI:Button ( "Spectate", Vector2 ( 0.423, 0.28 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.spectate" )
	self.panel.spectate:Subscribe ( "Press", self, self.spectate )
	self.panel.warpPlayerTo = GUI:Button ( "Warp player to...", Vector2 ( 0.36, 0.32 ), Vector2 ( 0.123, 0.03 ), self.panel.playersTab, "player.warpto" )
	self.panel.warpPlayerTo:Subscribe ( "Press", self, self.showWarpWindow )
	self.panel.vehicleMenu, items = GUI:ComboBox ( Vector2 ( 0.36, 0.36 ), Vector2 ( 0.123, 0.03 ), self.panel.playersTab, self.vehicleList )
	for _, item in pairs ( items ) do
		item:Subscribe ( "Press", self, self.displayVehicleTemplates )
	end

	self.panel.vehicleTemplateMenu = GUI:ComboBox ( Vector2 ( 0.36, 0.4 ), Vector2 ( 0.123, 0.03 ), self.panel.playersTab )
	table.insert ( self.templateItems, self.panel.vehicleTemplateMenu:AddItem ( "Default" ) )
	self.panel.giveVehicle = GUI:Button ( "Give", Vector2 ( 0.36, 0.44 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.givevehicle" )
	self.panel.giveVehicle:Subscribe ( "Press", self, self.giveVehicle )
	self.panel.destroyVehicle = GUI:Button ( "Destroy", Vector2 ( 0.423, 0.44 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.destroyvehicle" )
	self.panel.destroyVehicle:Subscribe ( "Press", self, self.destroyVehicle )
	self.panel.repairVehicle = GUI:Button ( "Repair", Vector2 ( 0.36, 0.48 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.repairvehicle" )
	self.panel.repairVehicle:Subscribe ( "Press", self, self.repairVehicle )
	self.panel.setVehicleColour = GUI:Button ( "Set colour", Vector2 ( 0.423, 0.48 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.setvehiclecolour" )
	self.panel.setVehicleColour:Subscribe ( "Press", self, self.showVehicleColourSelector )
	self.panel.weaponMenu = GUI:ComboBox ( Vector2 ( 0.36, 0.53 ), Vector2 ( 0.123, 0.03 ), self.panel.playersTab, getWeaponNames ( ) )
	self.panel.weaponSlotMenu = GUI:ComboBox ( Vector2 ( 0.36, 0.57 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, { "Primary", "Left", "Right" } )
	self.panel.giveWeapon = GUI:Button ( "Give", Vector2 ( 0.423, 0.57 ), Vector2 ( 0.06, 0.03 ), self.panel.playersTab, "player.giveweapon" )
	self.panel.giveWeapon:Subscribe ( "Press", self, self.giveWeapon )
	self.panel.giveAdmin = GUI:Button ( "Give admin rights", Vector2 ( 0.36, 0.67 ), Vector2 ( 0.123, 0.03 ), self.panel.playersTab, "player.giveadmin" )
	self.panel.giveAdmin:Subscribe ( "Press", self, self.giveAdmin )
	self.panel.shout = GUI:Button ( "Shout", Vector2 ( 0.36, 0.63 ), Vector2 ( 0.123, 0.03 ), self.panel.playersTab, "player.shout" )
	self.panel.shout:Subscribe ( "Press", self, self.showShoutWindow )

	GUI:Label ( "Server:", Vector2 ( 0.0, 0.01 ), Vector2 ( 0.2, 0.1 ), self.panel.serverTab ):SetTextColor ( Color ( 255, 0, 0 ) )
	self.panel.serverName = GUI:Label ( "Server name: N/A", Vector2 ( 0.005, 0.04 ), Vector2 ( 0.0, 0.0 ), self.panel.serverTab )
	self.panel.serverPlayers = GUI:Label ( "Players online: N/A", Vector2 ( 0.005, 0.07 ), Vector2 ( 0.0, 0.0 ), self.panel.serverTab )
	self.panel.serverDescription = GUI:Label ( "Description: N/A", Vector2 ( 0.005, 0.1 ), Vector2 ( 0.1, 0.03 ), self.panel.serverTab )
	self.panel.serverSpawnPosition = GUI:Label ( "Spawn Position: N/A", Vector2 ( 0.005, 0.13 ), Vector2 ( 0.1, 0.03 ), self.panel.serverTab )
	self.panel.serverTime = GUI:Label ( "Spawn Position: N/A", Vector2 ( 0.005, 0.16 ), Vector2 ( 0.1, 0.03 ), self.panel.serverTab )
	GUI:Label ( "Game:", Vector2 ( 0.0, 0.19 ), Vector2 ( 0.2, 0.13 ), self.panel.serverTab ):SetTextColor ( Color ( 255, 0, 0 ) )
	self.panel.serverGameTime = GUI:Label ( "Game Time: N/A", Vector2 ( 0.005, 0.22 ), Vector2 ( 0.0, 0.0 ), self.panel.serverTab )
	self.panel.serverGameTimeField = GUI:TextBox ( "", Vector2 ( 0.14, 0.219 ), Vector2 ( 0.03, 0.023 ), "numeric", self.panel.serverTab )
	self.panel.setGameTime = GUI:Button ( "Set", Vector2 ( 0.175, 0.218 ), Vector2 ( 0.031, 0.029 ), self.panel.serverTab, "general.settime" )
	self.panel.setGameTime:Subscribe ( "Press", self, self.setTime )
	GUI:Label ( "(0-23)", Vector2 ( 0.21, 0.225 ), Vector2 ( 0.03, 0.03 ), self.panel.serverTab )
	self.panel.serverWeather = GUI:Label ( "Weather Severity: N/A", Vector2 ( 0.005, 0.25 ), Vector2 ( 0.0, 0.0 ), self.panel.serverTab )
	self.panel.serverWeatherField = GUI:TextBox ( "", Vector2 ( 0.14, 0.25 ), Vector2 ( 0.03, 0.023 ), "numeric", self.panel.serverTab )
	self.panel.setWeatherSeverity = GUI:Button ( "Set", Vector2 ( 0.175, 0.25 ), Vector2 ( 0.031, 0.029 ), self.panel.serverTab, "general.setweather" )
	self.panel.setWeatherSeverity:Subscribe ( "Press", self, self.setWeather )
	GUI:Label ( "(0-2)", Vector2 ( 0.213, 0.26 ), Vector2 ( 0.03, 0.03 ), self.panel.serverTab )
	self.panel.serverTimeStep = GUI:Label ( "Time Step: N/A", Vector2 ( 0.005, 0.28 ), Vector2 ( 0.0, 0.0 ), self.panel.serverTab )
	self.panel.serverTimeStepField = GUI:TextBox ( "", Vector2 ( 0.14, 0.28 ), Vector2 ( 0.03, 0.023 ), "numeric", self.panel.serverTab )
	self.panel.setTimeStep = GUI:Button ( "Set", Vector2 ( 0.175, 0.28 ), Vector2 ( 0.031, 0.029 ), self.panel.serverTab, "general.settimestep" )
	self.panel.setTimeStep:Subscribe ( "Press", self, self.setTimeStep )
	GUI:Label ( "(0-inf)", Vector2 ( 0.21, 0.29 ), Vector2 ( 0.03, 0.03 ), self.panel.serverTab )

	self.banPanel.window = GUI:Window ( "Ban Player", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.22, 0.24 ) )
	self.banPanel.window:SetVisible ( false )
	GUI:Center ( self.banPanel.window )
	self.banPanel.reasonLabel = GUI:Label ( "Select a reason or write one", Vector2 ( 0.05, 0.01 ), Vector2 ( 0.19, 0.03 ), self.banPanel.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.banPanel.reasonCheck = GUI:CheckBox ( "", Vector2 ( 0.0, 0.04 ), Vector2 ( 0.018, 0.03 ), self.banPanel.window )
	self.banPanel.reasonEdit = GUI:TextBox ( "Custom reason", Vector2 ( 0.02, 0.04 ), Vector2 ( 0.19, 0.03 ), "text", self.banPanel.window )
	self.banPanel.reasonsBox = GUI:ComboBox ( Vector2 ( -0.001, 0.08 ), Vector2 ( 0.21, 0.03 ), self.banPanel.window, self.reasons )
	self.banPanel.durationLabel = GUI:Label ( "Select punishment duration", Vector2 ( 0.05, 0.13 ), Vector2 ( 0.19, 0.03 ), self.banPanel.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.banPanel.duration = GUI:TextBox ( "", Vector2 ( 0.0, 0.16 ), Vector2 ( 0.05, 0.03 ), "numeric", self.banPanel.window )
	self.banPanel.durationBox = GUI:ComboBox ( Vector2 ( 0.06, 0.16 ), Vector2 ( 0.08, 0.03 ), self.banPanel.window, { "Days", "Hours", "Minutes", "Permanent" } )
	self.banPanel.ban = GUI:Button ( "Ban", Vector2 ( 0.15, 0.16 ), Vector2 ( 0.06, 0.03 ), self.banPanel.window )
	self.banPanel.ban:Subscribe ( "Press", self, self.banPlayer )

	self.kickPanel.window = GUI:Window ( "Kick Player", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.22, 0.2 ) )
	self.kickPanel.window:SetVisible ( false )
	GUI:Center ( self.kickPanel.window )
	self.kickPanel.reasonLabel = GUI:Label ( "Select a reason or write one", Vector2 ( 0.05, 0.01 ), Vector2 ( 0.19, 0.03 ), self.kickPanel.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.kickPanel.reasonCheck = GUI:CheckBox ( "", Vector2 ( 0.0, 0.04 ), Vector2 ( 0.018, 0.03 ), self.kickPanel.window )
	self.kickPanel.reasonEdit = GUI:TextBox ( "Custom reason", Vector2 ( 0.02, 0.04 ), Vector2 ( 0.19, 0.03 ), "text", self.kickPanel.window )
	self.kickPanel.reasonsBox = GUI:ComboBox ( Vector2 ( -0.001, 0.08 ), Vector2 ( 0.21, 0.03 ), self.kickPanel.window, self.reasons )
	self.kickPanel.kick = GUI:Button ( "Kick", Vector2 ( 0.0, 0.12 ), Vector2 ( 0.21, 0.03 ), self.kickPanel.window )
	self.kickPanel.kick:Subscribe ( "Press", self, self.kickPlayer )

	self.mutePanel.window = GUI:Window ( "Mute Player", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.22, 0.24 ) )
	self.mutePanel.window:SetVisible ( false )
	GUI:Center ( self.mutePanel.window )
	self.mutePanel.reasonLabel = GUI:Label ( "Select a reason or write one", Vector2 ( 0.05, 0.01 ), Vector2 ( 0.19, 0.03 ), self.mutePanel.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.mutePanel.reasonCheck = GUI:CheckBox ( "", Vector2 ( 0.0, 0.04 ), Vector2 ( 0.018, 0.03 ), self.mutePanel.window )
	self.mutePanel.reasonEdit = GUI:TextBox ( "Custom reason", Vector2 ( 0.02, 0.04 ), Vector2 ( 0.19, 0.03 ), "text", self.mutePanel.window )
	self.mutePanel.reasonsBox = GUI:ComboBox ( Vector2 ( -0.001, 0.08 ), Vector2 ( 0.21, 0.03 ), self.mutePanel.window, self.reasons )
	self.mutePanel.durationLabel = GUI:Label ( "Select punishment duration", Vector2 ( 0.05, 0.13 ), Vector2 ( 0.19, 0.03 ), self.mutePanel.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.mutePanel.duration = GUI:TextBox ( "", Vector2 ( 0.0, 0.16 ), Vector2 ( 0.05, 0.03 ), "numeric", self.mutePanel.window )
	self.mutePanel.durationBox = GUI:ComboBox ( Vector2 ( 0.06, 0.16 ), Vector2 ( 0.08, 0.03 ), self.mutePanel.window, { "Minutes", "Hours", "Days" } )
	self.mutePanel.mute = GUI:Button ( "Mute", Vector2 ( 0.15, 0.16 ), Vector2 ( 0.06, 0.03 ), self.mutePanel.window )
	self.mutePanel.mute:Subscribe ( "Press", self, self.mutePlayer )

	self.warpPanel.window = GUI:Window ( "Warp Player To", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.2, 0.45 ) )
	self.warpPanel.window:SetVisible ( false )
	GUI:Center ( self.warpPanel.window )
	self.warpPanel.search = GUI:TextBox ( "", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.19, 0.03 ), "text", self.warpPanel.window )
	self.warpPanel.search:Subscribe ( "TextChanged", self, self.searchWarpPlayer )
	self.warpPanel.list = GUI:SortedList ( Vector2 ( 0.0, 0.04 ), Vector2 ( 0.19, 0.32 ), self.warpPanel.window, { { name = "Player" } } )
	self.warpPanel.warp = GUI:Button ( "Warp", Vector2 ( 0.0, 0.37 ), Vector2 ( 0.19, 0.035 ), self.warpPanel.window )
	self.warpPanel.warp:Subscribe ( "Press", self, self.warpPlayerTo )

	self.panel.bansList = GUI:SortedList ( Vector2 ( 0.0, 0.0 ), Vector2 ( 0.16, 0.66 ), self.panel.bansTab, { { name = "Ban" } } )
	self.panel.bansList:Subscribe ( "RowSelected", self, self.getBanInformation )
	self.panel.bansSearch = GUI:TextBox ( "", Vector2 ( 0.0, 0.67 ), Vector2 ( 0.16, 0.035 ), "text", self.panel.bansTab )
	self.panel.bansSearch:Subscribe ( "TextChanged", self, self.searchBan )
	GUI:Label ( "Ban details:", Vector2 ( 0.165, 0.01 ), Vector2 ( 0.2, 0.1 ), self.panel.bansTab ):SetTextColor ( Color ( 255, 0, 0 ) )
	self.panel.banSteamID = GUI:Label ( "Steam ID: N/A", Vector2 ( 0.17, 0.04 ), Vector2 ( 0.2, 0.03 ), self.panel.bansTab )
	self.panel.banName = GUI:Label ( "Name: N/A", Vector2 ( 0.17, 0.07 ), Vector2 ( 0.2, 0.03 ), self.panel.bansTab )
	self.panel.banDuration = GUI:Label ( "Duration: N/A", Vector2 ( 0.17, 0.1 ), Vector2 ( 0.2, 0.03 ), self.panel.bansTab )
	self.panel.banDate = GUI:Label ( "Date: N/A", Vector2 ( 0.17, 0.13 ), Vector2 ( 0.2, 0.03 ), self.panel.bansTab )
	self.panel.banResponsible = GUI:Label ( "Responsible: N/A", Vector2 ( 0.17, 0.16 ), Vector2 ( 0.2, 0.03 ), self.panel.bansTab )
	self.panel.banResponsibleSteam = GUI:Label ( "Responsible Steam ID: N/A", Vector2 ( 0.17, 0.19 ), Vector2 ( 0.2, 0.03 ), self.panel.bansTab )
	self.panel.banReasonScroll = GUI:ScrollControl ( Vector2 ( 0.17, 0.22 ), Vector2 ( 0.2, 0.25 ), self.panel.bansTab )
	self.panel.banReason = GUI:Label ( "Reason: N/A", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.2, 0.3 ), self.panel.banReasonScroll )
	self.panel.banReason:SetWrap ( true )
	self.panel.banReason:SizeToContents ( )
	self.panel.banRemove = GUI:Button ( "Unban", Vector2 ( 0.17, 0.67 ), Vector2 ( 0.07, 0.035 ), self.panel.bansTab, "ban.remove" )
	self.panel.banRemove:Subscribe ( "Press", self, self.removeBan )
	self.panel.banAdd = GUI:Button ( "Add ban", Vector2 ( 0.25, 0.67 ), Vector2 ( 0.07, 0.035 ), self.panel.bansTab, "ban.add" )
	self.panel.banAdd:Subscribe ( "Press", self, self.showManualBanWindow )
	self.panel.banRefresh = GUI:Button ( "Refresh", Vector2 ( 0.33, 0.67 ), Vector2 ( 0.07, 0.035 ), self.panel.bansTab )
	self.panel.banRefresh:Subscribe ( "Press", self, self.refreshBans )

	self.manualBanPanel.window = GUI:Window ( "Manual Ban", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.22, 0.3 ) )
	self.manualBanPanel.window:SetVisible ( false )
	GUI:Center ( self.manualBanPanel.window )
	GUI:Label ( "Write the Steam ID to ban", Vector2 ( 0.05, 0.001 ), Vector2 ( 0.19, 0.03 ), self.manualBanPanel.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.manualBanPanel.steamID = GUI:TextBox ( "", Vector2 ( 0.0, 0.025 ), Vector2 ( 0.21, 0.03 ), "text", self.manualBanPanel.window )
	GUI:Label ( "Select a reason or write one", Vector2 ( 0.05, 0.07 ), Vector2 ( 0.19, 0.03 ), self.manualBanPanel.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.manualBanPanel.reasonCheck = GUI:CheckBox ( "", Vector2 ( 0.0, 0.1 ), Vector2 ( 0.018, 0.03 ), self.manualBanPanel.window )
	self.manualBanPanel.reasonEdit = GUI:TextBox ( "Custom reason", Vector2 ( 0.02, 0.1 ), Vector2 ( 0.19, 0.03 ), "text", self.manualBanPanel.window )
	self.manualBanPanel.reasonsBox = GUI:ComboBox ( Vector2 ( -0.001, 0.14 ), Vector2 ( 0.21, 0.03 ), self.manualBanPanel.window, self.reasons )
	GUI:Label ( "Select punishment duration", Vector2 ( 0.05, 0.19 ), Vector2 ( 0.19, 0.03 ), self.manualBanPanel.window ):SetTextColor ( Color ( 0, 200, 0 ) )
	self.manualBanPanel.duration = GUI:TextBox ( "", Vector2 ( 0.0, 0.22 ), Vector2 ( 0.05, 0.03 ), "numeric", self.manualBanPanel.window )
	self.manualBanPanel.durationBox = GUI:ComboBox ( Vector2 ( 0.06, 0.22 ), Vector2 ( 0.08, 0.03 ), self.manualBanPanel.window, { "Days", "Hours", "Minutes", "Permanent" } )
	self.manualBanPanel.ban = GUI:Button ( "Ban", Vector2 ( 0.15, 0.22 ), Vector2 ( 0.06, 0.03 ), self.manualBanPanel.window )
	self.manualBanPanel.ban:Subscribe ( "Press", self, self.manualBan )

	self.shoutPanel.window = GUI:Window ( "Shout Player", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.25, 0.16 ) )
	self.shoutPanel.window:SetVisible ( false )
	GUI:Center ( self.shoutPanel.window )
	self.shoutPanel.message = GUI:TextBox ( "", Vector2 ( 0.0, 0.01 ), Vector2 ( 0.24, 0.05 ), "text", self.shoutPanel.window )
	self.shoutPanel.shout = GUI:Button ( "Shout!", Vector2 ( 0.0, 0.07 ), Vector2 ( 0.24, 0.04 ), self.shoutPanel.window )
	self.shoutPanel.shout:Subscribe ( "Press", self, self.shoutPlayer )

	self.panel.chatScroll = GUI:ScrollControl ( Vector2 ( 0.0, 0.01 ), Vector2 ( 0.48, 0.6 ), self.panel.adminchatTab )
	self.panel.chatMessages = GUI:Label ( "", Vector2 ( 0.0, 0.011 ), Vector2 ( 0.48, 0.0 ), self.panel.chatScroll )
	self.panel.chatMessages:SetWrap ( true )
	self.panel.chatMessage = GUI:TextBox ( "", Vector2 ( 0.0, 0.66 ), Vector2 ( 0.38, 0.04 ), "text", self.panel.adminchatTab )
	self.panel.chatMessage:Subscribe ( "ReturnPressed", self, self.sendChatMessage )
	self.panel.sendMessage = GUI:Button ( "Send", Vector2 ( 0.385, 0.66 ), Vector2 ( 0.05, 0.04 ), self.panel.adminchatTab )
	self.panel.sendMessage:Subscribe ( "Press", self, self.sendChatMessage )
	self.panel.clearMessage = GUI:Button ( "Clear", Vector2 ( 0.44, 0.66 ), Vector2 ( 0.04, 0.04 ), self.panel.adminchatTab )
	self.panel.clearMessage:Subscribe ( "Press", self, self.clearChatMessage )

	self.panel.aclTree = GUI:Tree ( Vector2 ( 0.0, 0.0 ), Vector2 ( 0.2, 0.71 ), self.panel.aclTab )
	self.panel.aclDataLabel = GUI:Label ( "Group name: N/A\n\nCreator: N/A\n\nCreation date: N/A\n\nGroup objects: N/A", Vector2 ( 0.205, 0.01 ), Vector2 ( 0.0, 0.0 ), self.panel.aclTab )
	self.panel.aclDataLabel:SizeToContents ( )
	self.panel.aclCreateGroup = GUI:Button ( "Create group", Vector2 ( 0.21, 0.64 ), Vector2 ( 0.1, 0.03 ), self.panel.aclTab )
	self.panel.aclCreateGroup:Subscribe ( "Press", self, self.showACLCreateWindow )
	self.panel.aclDestroyGroup = GUI:Button ( "Destroy group", Vector2 ( 0.21, 0.68 ), Vector2 ( 0.1, 0.03 ), self.panel.aclTab )
	self.panel.aclDestroyGroup:Subscribe ( "Press", self, self.destroyACLGroup )
	self.panel.aclAddObject = GUI:Button ( "Add object", Vector2 ( 0.32, 0.64 ), Vector2 ( 0.1, 0.03 ), self.panel.aclTab )
	self.panel.aclAddObject:Subscribe ( "Press", self, self.showACLAddObjectWindow )
	self.panel.aclRemoveObject = GUI:Button ( "Remove object", Vector2 ( 0.32, 0.68 ), Vector2 ( 0.1, 0.03 ), self.panel.aclTab )
	self.panel.aclRemoveObject:Subscribe ( "Press", self, self.removeACLObject )

	self.permPanelChange.window = GUI:Window ( "ACL Permission", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.15, 0.2 ) )
	self.permPanelChange.window:SetVisible ( false )
	GUI:Center ( self.permPanelChange.window )
	self.permPanelChange.label = GUI:Label ( "Permission:", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.14, 0.1 ), self.permPanelChange.window )
	GUI:Label ( "Accepted values: true/false", Vector2 ( 0.0, 0.03 ), Vector2 ( 0.2, 0.1 ), self.permPanelChange.window )
	self.permPanelChange.value = GUI:TextBox ( "", Vector2 ( 0.01, 0.07 ), Vector2 ( 0.12, 0.03 ), "text", self.permPanelChange.window )
	self.permPanelChange.set = GUI:Button ( "Set permission", Vector2 ( 0.01, 0.12 ), Vector2 ( 0.12, 0.03 ), self.permPanelChange.window )
	self.permPanelChange.set:Subscribe ( "Press", self, self.modifyACLPermission )

	self.aclCreatePanel.window = GUI:Window ( "Create ACL Group", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.25, 0.45 ) )
	self.aclCreatePanel.window:SetVisible ( false )
	GUI:Center ( self.aclCreatePanel.window )
	GUI:Label ( "Group name:", Vector2 ( 0.001, 0.001 ), Vector2 ( 0.1, 0.03 ), self.aclCreatePanel.window )
	self.aclCreatePanel.name = GUI:TextBox ( "", Vector2 ( 0.001, 0.03 ), Vector2 ( 0.24, 0.03 ), "text", self.aclCreatePanel.window )
	self.aclCreatePanel.permissions = GUI:SortedList ( Vector2 ( 0.0, 0.07 ), Vector2 ( 0.24, 0.27 ), self.aclCreatePanel.window, { { name = "Permission" } } )
	self.aclCreatePanel.select = GUI:Button ( "Select", Vector2 ( 0.0, 0.34 ), Vector2 ( 0.12, 0.03 ), self.aclCreatePanel.window )
	self.aclCreatePanel.select:Subscribe ( "Press", self, self.onPermissionSelect )
	self.aclCreatePanel.selectAll = GUI:Button ( "Select all", Vector2 ( 0.12, 0.34 ), Vector2 ( 0.12, 0.03 ), self.aclCreatePanel.window )
	self.aclCreatePanel.selectAll:Subscribe ( "Press", self, self.onPermissionSelectAll )
	self.aclCreatePanel.create = GUI:Button ( "Create Group", Vector2 ( 0.0, 0.37 ), Vector2 ( 0.24, 0.03 ), self.aclCreatePanel.window )
	self.aclCreatePanel.create:Subscribe ( "Press", self, self.createACLGroup )

	self.aclObjectPanel.window = GUI:Window ( "Add Object to: ", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.15, 0.15 ) )
	self.aclObjectPanel.window:SetVisible ( false )
	GUI:Center ( self.aclObjectPanel.window )
	GUI:Label ( "Steam ID to add:", Vector2 ( 0.001, 0.001 ), Vector2 ( 0.1, 0.03 ), self.aclObjectPanel.window )
	self.aclObjectPanel.value = GUI:TextBox ( "", Vector2 ( 0.0, 0.03 ), Vector2 ( 0.14, 0.03 ), "text", self.aclObjectPanel.window )
	self.aclObjectPanel.add = GUI:Button ( "Add", Vector2 ( 0.0, 0.07 ), Vector2 ( 0.14, 0.03 ), self.aclObjectPanel.window )
	self.aclObjectPanel.add:Subscribe ( "Press", self, self.addACLObject )

	self.panel.modulesList = GUI:SortedList ( Vector2 ( 0.0, 0.0 ), Vector2 ( 0.16, 0.66 ), self.panel.modulesTab, { { name = "Module" } } )
	self.panel.modulesSearch = GUI:TextBox ( "", Vector2 ( 0.0, 0.67 ), Vector2 ( 0.16, 0.035 ), "text", self.panel.modulesTab )
	self.panel.modulesSearch:Subscribe ( "TextChanged", self, self.searchModule )
	GUI:Label ( "Module log:", Vector2 ( 0.165, 0.01 ), Vector2 ( 0.2, 0.1 ), self.panel.modulesTab ):SetTextColor ( Color ( 255, 0, 0 ) )
	self.panel.modulesLogScroll = GUI:ScrollControl ( Vector2 ( 0.17, 0.04 ), Vector2 ( 0.34, 0.5 ), self.panel.modulesTab )
	self.panel.modulesLog = GUI:Label ( "", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.34, 0.5 ), self.panel.modulesLogScroll )
	self.panel.modulesLog:SetWrap ( true )
	self.panel.moduleLoad = GUI:Button ( "Load", Vector2 ( 0.17, 0.67 ), Vector2 ( 0.07, 0.035 ), self.panel.modulesTab, "module.load" )
	self.panel.moduleLoad:Subscribe ( "Press", self, self.loadModule )
	self.panel.moduleReload = GUI:Button ( "Reload", Vector2 ( 0.25, 0.67 ), Vector2 ( 0.07, 0.035 ), self.panel.modulesTab, "module.load" )
	self.panel.moduleReload:Subscribe ( "Press", self, self.reloadModule )
	self.panel.moduleUnload = GUI:Button ( "Unload", Vector2 ( 0.33, 0.67 ), Vector2 ( 0.07, 0.035 ), self.panel.modulesTab, "module.unload" )
	self.panel.moduleUnload:Subscribe ( "Press", self, self.unloadModule )
	self.panel.modulesRefresh = GUI:Button ( "Refresh", Vector2 ( 0.41, 0.67 ), Vector2 ( 0.07, 0.035 ), self.panel.modulesTab )
	self.panel.modulesRefresh:Subscribe ( "Press", self, self.refreshModules )

	self.vehColorPanel.window = GUI:Window ( "Vehicle Colour", Vector2 ( 0.0, 0.0 ), Vector2 ( 0.3, 0.36 ) )
	GUI:Center ( self.vehColorPanel.window )
	self.vehColorPanel.window:SetVisible ( false )
	self.vehColorPanel.tabPanel, self.vehColorPanel.tabs = GUI:TabControl ( { "Tone 1", "Tone 2" }, Vector2 ( 0.0, 0.0 ), Vector2 ( 0.0, 0.0 ), self.vehColorPanel.window )
	self.vehColorPanel.tabPanel:SetDock ( GwenPosition.Fill )
	self.vehColorPanel.tone1 = GUI:ColorPicker ( true, Vector2 ( 0.0, 0.0 ), Vector2 ( 0.3, 0.23 ), self.vehColorPanel.tabs [ "tone 1" ].base )
	self.vehColorPanel.tone1Set = GUI:Button ( "Set colour", Vector2 ( 0.0, 0.24 ), Vector2 ( 0.282, 0.03 ), self.vehColorPanel.tabs [ "tone 1" ].base )
	self.vehColorPanel.tone1Set:Subscribe ( "Press", self, self.setVehicleTone1Colour )
	self.vehColorPanel.tone2 = GUI:ColorPicker ( true, Vector2 ( 0.0, 0.0 ), Vector2 ( 0.3, 0.23 ), self.vehColorPanel.tabs [ "tone 2" ].base )
	self.vehColorPanel.tone2Set = GUI:Button ( "Set colour", Vector2 ( 0.0, 0.24 ), Vector2 ( 0.282, 0.03 ), self.vehColorPanel.tabs [ "tone 2" ].base )
	self.vehColorPanel.tone2Set:Subscribe ( "Press", self, self.setVehicleTone2Colour )

	-- Normal events
	Events:Subscribe ( "KeyUp", self, self.onKeyPress )
	Events:Subscribe ( "PlayerJoin", self, self.onPlayerJoin )
	Events:Subscribe ( "PlayerQuit", self, self.onPlayerQuit )
	Events:Subscribe ( "LocalPlayerInput", self, self.disableControls )
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
		self.panel.window:SetVisible ( false )
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
	self.panel.window:SetVisible ( true )
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
	local item = self.panel.playersList:AddItem ( player:GetName ( ) )
	item:SetDataObject ( "id", player )
	self.players [ tostring ( player:GetSteamId ( ) ) ] = item
end

function Admin:loadPlayersToList ( )
	self.panel.playersList:Clear ( )
	self:addPlayerToList ( LocalPlayer )
	for player in Client:GetPlayers ( ) do
		self:addPlayerToList ( player )
	end
end

function Admin:getInformation ( )
	local row = self.panel.playersList:GetSelectedRow ( )
	if ( row ) then
		local player = row:GetDataObject ( "id" )
		if IsValid ( player, false ) then
			Network:Send ( "admin.requestInformation", player )
		end
	end
end

function Admin:displayInformation ( data )
	if ( type ( data ) == "table" ) then
		self.panel.playerName:SetText ( "Name: ".. tostring ( data.name ) )
		self.panel.playerSteamID:SetText ( "Steam ID: ".. tostring ( data.steamID ) )
		self.panel.playerIP:SetText ( "IP: ".. tostring ( data.ip ) )
		self.panel.playerGroups:SetText ( "Groups: ".. tostring ( data.groups ) )
		self.panel.playerPing:SetText ( "Ping: ".. tostring ( data.ping ) )
		self.panel.playerHealth:SetText ( "Health: ".. tostring ( data.health ) )
		self.panel.playerMoney:SetText ( "Money: ".. tostring ( data.money ) )
		self.panel.playerPosition:SetText ( "Position: ".. tostring ( data.position ) )
		self.panel.playerAngle:SetText ( "Angle: ".. tostring ( data.angle ) )
		self.panel.playerWorld:SetText ( "World: ".. tostring ( data.world ) )
		self.panel.playerModel:SetText ( "Model: ".. tostring ( data.model ) )
		self.panel.playerVehicle:SetText ( "Name: ".. tostring ( data.vehicle ) )
		self.panel.playerVehicleHealth:SetText ( "Health: ".. tostring ( data.vehicleHealth ) )
		self.panel.playerWeapon:SetText ( "Weapon: ".. tostring ( data.weapon ) )
		self.panel.playerWeaponAmmo:SetText ( "Weapon ammo: ".. tostring ( data.weaponAmmo ) )
		self.panel.mute:SetText ( ( data.muted == true and "Unmute" or "Mute" ) )
		self.panel.freeze:SetText ( ( data.frozen == true and "Unfreeze" or "Freeze" ) )
		self.panel.giveAdmin:SetText ( ( data.isAdmin == true and "Revoke admin rights" or "Give admin rights" ) )
	end
end

function Admin:onPlayerJoin ( args )
	self:addPlayerToList ( args.player )
end

function Admin:onPlayerQuit ( args )
	local steamID = tostring ( args.player:GetSteamId ( ) )
	if ( self.players [ steamID ] ) then
		self.panel.playersList:RemoveItem ( self.players [ steamID ] )
		self.players [ steamID ] = nil
	end
end

function Admin:displayServerInfo ( info )
	self.serverInfo = info
	local timeTable = tostring ( math.round ( Game:GetTime ( ), 1 ) ):split ( "." )
	self.panel.serverName:SetText ( "Server Name: ".. tostring ( info.name ) )
	self.panel.serverName:SizeToContents ( )
	self.panel.serverPlayers:SetText ( "Players: ".. tostring ( self:countPlayers ( ) ) .."/".. tostring ( info.maxPlayers ) )
	self.panel.serverPlayers:SizeToContents ( )
	self.panel.serverDescription:SetText ( "Description: ".. tostring ( info.description ) )
	self.panel.serverDescription:SizeToContents ( )
	self.panel.serverSpawnPosition:SetText ( "Spawn Position: ".. tostring ( info.spawnPosition ) )
	self.panel.serverSpawnPosition:SizeToContents ( )
	self.panel.serverTime:SetText ( "Server Time: ".. tostring ( info.serverTime ) )
	self.panel.serverTime:SizeToContents ( )
	self.panel.serverGameTime:SetText ( "Game Time: ".. string.format ( "%02d:%02d", ( timeTable [ 1 ] or 0 ), ( timeTable [ 2 ] or 0 ) ) )
	self.panel.serverGameTime:SizeToContents ( )
	self.panel.serverWeather:SetText ( "Weather Severity: ".. tostring ( info.weatherSeverity ) )
	self.panel.serverWeather:SizeToContents ( )
	self.panel.serverTimeStep:SetText ( "Time Step: ".. tostring ( info.timeStep ) )
	self.panel.serverTimeStep:SizeToContents ( )
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
	local text = self.panel.playersSearch:GetText ( ):lower ( )
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
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		self.banPanel.window:SetVisible ( true )
		self.victim = player
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:banPlayer ( )
	if IsValid ( self.victim, false ) then
		local reason = ( self.banPanel.reasonCheck:GetChecked ( ) == true and self.banPanel.reasonEdit:GetText ( ) or self.banPanel.reasonsBox:GetSelectedItem ( ):GetText ( ) )
		local durationMethod = self.banPanel.durationBox:GetSelectedItem ( ):GetText ( )
		local duration = tonumber ( self.banPanel.duration:GetText ( ) )
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
		self.banPanel.window:SetVisible ( false )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:showKickWindow ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		self.kickPanel.window:SetVisible ( true )
		self.victim = player
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:kickPlayer ( )
	if IsValid ( self.victim, false ) then
		local reason = ( self.kickPanel.reasonCheck:GetChecked ( ) == true and self.kickPanel.reasonEdit:GetText ( ) or self.kickPanel.reasonsBox:GetSelectedItem ( ):GetText ( ) )
		Network:Send ( "admin.executeAction", { "player.kick", self.victim, reason } )
		self.victim = false
		self.kickPanel.window:SetVisible ( false )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:showMuteWindow ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		if ( self.panel.mute:GetText ( ) == "Mute" ) then
			self.mutePanel.window:SetVisible ( true )
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
		local reason = ( self.mutePanel.reasonCheck:GetChecked ( ) == true and self.mutePanel.reasonEdit:GetText ( ) or self.mutePanel.reasonsBox:GetSelectedItem ( ):GetText ( ) )
		local durationMethod = self.mutePanel.durationBox:GetSelectedItem ( ):GetText ( )
		local duration = tonumber ( self.mutePanel.duration:GetText ( ) )
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
		self.mutePanel.window:SetVisible ( false )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:freezePlayer ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		Network:Send ( "admin.executeAction", { "player.freeze", player } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:killPlayer ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		Network:Send ( "admin.executeAction", { "player.kill", player } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:setHealth ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		local value = tonumber ( self.panel.valueField:GetText ( ) ) or 0
		if ( value > 100 ) then
			value = 100
		end
		Network:Send ( "admin.executeAction", { "player.sethealth", player, value } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:setModel ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		local value = tonumber ( self.panel.valueField:GetText ( ) ) or 0
		Network:Send ( "admin.executeAction", { "player.setmodel", player, value } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:setMoney ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		local value = tonumber ( self.panel.valueField:GetText ( ) ) or 0
		Network:Send ( "admin.executeAction", { "player.setmoney", player, value } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:giveMoney ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		local value = tonumber ( self.panel.valueField:GetText ( ) ) or 0
		Network:Send ( "admin.executeAction", { "player.givemoney", player, value } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:warpTo ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		Network:Send ( "admin.executeAction", { "player.warp", player } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:showWarpWindow ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		self.victim = player
		self.warpPanel.window:SetVisible ( true )
		self.warpPanel.list:Clear ( )
		local item = self.warpPanel.list:AddItem ( LocalPlayer:GetName ( ) )
		item:SetDataObject ( "id", LocalPlayer )
		self.warpPlayers [ LocalPlayer:GetSteamId ( ) ] = item
		for player in Client:GetPlayers ( ) do
			local item = self.warpPanel.list:AddItem ( player:GetName ( ) )
			item:SetDataObject ( "id", player )
			self.warpPlayers [ player:GetSteamId ( ) ] = item
		end
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:warpPlayerTo ( )
	if IsValid ( self.victim, false ) then
		local player = self:getListSelectedPlayer ( self.warpPanel.list )
		if ( player ) then
			Network:Send ( "admin.executeAction", { "player.warpto", self.victim, player } )
			self.warpPanel.window:SetVisible ( false )
		else
			self:Message ( "Player selected is offline.", "err" )
		end
	else
		self:Message ( "Player is offline.", "err" )
	end
end

function Admin:searchWarpPlayer ( )
	local text = self.warpPanel.search:GetText ( ):lower ( )
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
	local player = self:getListSelectedPlayer ( self.panel.playersList )
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
	local name = self.panel.vehicleMenu:GetSelectedItem ( ):GetText ( )
	if ( name ) then
		local model = self.vehicleModelFromName [ name ]
		if ( model ) then
			local templates = vehicleTemplates [ model ]
			if ( templates ) then
				for _, template in ipairs ( templates ) do
					table.insert ( self.templateItems, self.panel.vehicleTemplateMenu:AddItem ( tostring ( template ) ) )
				end
			end
		end
	end
end

function Admin:giveVehicle ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		local name = self.panel.vehicleMenu:GetSelectedItem ( ):GetText ( )
		if ( name ) then
			local model = self.vehicleModelFromName [ name ]
			if ( model ) then
				local template = self.panel.vehicleTemplateMenu:GetSelectedItem ( ):GetText ( )
				Network:Send ( "admin.executeAction", { "player.givevehicle", player, model, template } )
			end
		end
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:destroyVehicle ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		Network:Send ( "admin.executeAction", { "player.destroyvehicle", player } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:repairVehicle ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		Network:Send ( "admin.executeAction", { "player.repairvehicle", player } )
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:showVehicleColourSelector ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		if player:InVehicle ( ) then
			self.vehColorPanel.window:SetVisible ( true )
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
			local color = self.vehColorPanel.tone1:GetColor ( )
			Network:Send ( "admin.executeAction", { "player.setvehiclecolour", self.victim, "tone1", color } )
			self.vehColorPanel.window:SetVisible ( false )
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
			local color = self.vehColorPanel.tone2:GetColor ( )
			Network:Send ( "admin.executeAction", { "player.setvehiclecolour", self.victim, "tone2", color } )
			self.vehColorPanel.window:SetVisible ( false )
			self.victim = nil
		else
			self:Message ( "This player is not in a vehicle.", "err" )
		end
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:giveWeapon ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		local name = self.panel.weaponMenu:GetSelectedItem ( ):GetText ( )
		local slot = self.panel.weaponSlotMenu:GetSelectedItem ( ):GetText ( )
		if ( name and slot ) then
			Network:Send ( "admin.executeAction", { "player.giveweapon", player, getWeaponIDFromName ( name ), slot } )
		end
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:giveAdmin ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		if ( self.panel.giveAdmin:GetText ( ) == "Give admin rights" ) then
			Network:Send ( "admin.executeAction", { "player.giveadmin", player } )
		else
			Network:Send ( "admin.executeAction", { "player.takeadmin", player } )
		end
	else
		self:Message ( "No player selected.", "err" )
	end
end

function Admin:showShoutWindow ( )
	local player = self:getListSelectedPlayer ( self.panel.playersList )
	if ( player ) then
		self.victim = player
		self.shoutPanel.window:SetVisible ( true )
	else
		self:Message ( "No player selected.", "err" )	
	end
end

function Admin:shoutPlayer ( )
	if IsValid ( self.victim, false ) then
		local message = self.shoutPanel.message:GetText ( )
		if ( message ~= "" ) then
			Network:Send ( "admin.executeAction", { "player.shout", self.victim, message } )
			self.victim = false
			self.shoutPanel.window:SetVisible ( false )
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
	self.panel.bansList:Clear ( )
	self.bans = { }
	self.banData = { }
	if ( bans ) then
		for _, ban in ipairs ( bans ) do
			local item = self.panel.bansList:AddItem ( ( ban.name == "" and ban.steamID or ban.name .."(".. tostring ( ban.steamID ) ..")" ) )
			item:SetDataString ( "id", ban.steamID )
			self.banData [ ban.steamID ] = ban
			self.bans [ ban.steamID ] = item
		end
	end
end

function Admin:getBanInformation ( )
	local row = self.panel.bansList:GetSelectedRow ( )
	if ( row ) then
		local id = row:GetDataString ( "id" )
		if ( id ) then
			local data = self.banData [ id ]
			if ( data ) then
				self.panel.banSteamID:SetText ( "Steam ID: ".. tostring ( id ) )
				self.panel.banName:SetText ( "Name: ".. tostring ( data.name ) )
				local duration = tonumber ( data.duration ) or 0
				local expired = false
				if ( duration <= self.serverInfo.time and duration ~= 0 ) then
					self.panel.banDuration:SetText ( "Duration: Already expired." )
				elseif ( duration == 0 ) then
					self.panel.banDuration:SetText ( "Duration: Permanent." )
				else
					local timeLeft = ( duration - self.serverInfo.time )
					local minutes = math.floor ( timeLeft / 60 )
					local seconds = ( timeLeft - ( minutes * 60 ) )
					local hours = math.floor ( minutes / 60 )
					local minutes = ( minutes - ( hours * 60 ) )
					local days = math.floor ( hours / 24 )
					local hours = ( hours - ( days * 24 ) )
					self.panel.banDuration:SetText ( "Duration: ".. tostring ( days ) .." day(s), ".. tostring ( hours ) .." hour(s), ".. tostring ( minutes ) .." min(s), ".. tostring ( seconds ) .." sec(s)" )
				end
				self.panel.banDuration:SizeToContents ( )
				self.panel.banDate:SetText ( "Date: ".. tostring ( data.date ):gsub ( " ", " - " ) )
				self.panel.banReason:SetText ( "Reason: ".. tostring ( data.reason ) )
				self.panel.banResponsible:SetText ( "Responsible: ".. tostring ( data.responsible ) )
				self.panel.banResponsibleSteam:SetText ( "Responsible Steam ID: ".. tostring ( data.responsibleSteamID ) )
			end
		end
	end
end

function Admin:searchBan ( )
	local text = self.panel.bansSearch:GetText ( ):lower ( )
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
	local row = self.panel.bansList:GetSelectedRow ( )
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
	self.manualBanPanel.window:SetVisible ( true )
end

function Admin:manualBan ( )
	local steamID = self.manualBanPanel.steamID:GetText ( )
	if ( steamID ~= "" ) then
		local reason = ( self.manualBanPanel.reasonCheck:GetChecked ( ) == true and self.manualBanPanel.reasonEdit:GetText ( ) or self.manualBanPanel.reasonsBox:GetSelectedItem ( ):GetText ( ) )
		local durationMethod = self.manualBanPanel.durationBox:GetSelectedItem ( ):GetText ( )
		local duration = tonumber ( self.manualBanPanel.duration:GetText ( ) )
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
		self.manualBanPanel.window:SetVisible ( false )
	else
		self:Message ( "No steam ID given.", "err" )
	end
end

function Admin:setTime ( )
	local value = self.panel.serverGameTimeField:GetText ( )
	Network:Send ( "admin.executeAction", { "general.settime", value } )
end

function Admin:setWeather ( )
	local value = self.panel.serverWeatherField:GetText ( )
	Network:Send ( "admin.executeAction", { "general.setweather", value } )
end

function Admin:setTimeStep ( )
	local value = self.panel.serverTimeStepField:GetText ( )
	Network:Send ( "admin.executeAction", { "general.settimestep", value } )
end

function Admin:sendChatMessage ( )
	local text = self.panel.chatMessage:GetText ( )
	if ( text ~= "" ) then
		Network:Send ( "admin.executeAction", { "general.tab_adminchat", text } )
		self:clearChatMessage ( )
	end
end

function Admin:clearChatMessage ( )
	self.panel.chatMessage:SetText ( "" )
end

function Admin:addChatMessage ( args )
	local text = self.panel.chatMessages:GetText ( )
	if ( text == "" ) then
		self.panel.chatMessages:SetText ( args.msg )
	else
		self.panel.chatMessages:SetText ( text .."\n".. args.msg )
	end
	self.panel.chatMessages:SizeToContents ( )
end

function Admin:displayACL ( acl )
	if ( type ( acl ) == "table" ) then
		self.aclGroupData = { }
		self.panel.aclTree:Clear ( )
		self.aclObjectPanel.window:SetDataString ( "group", "" )
		self.panel.aclTree:SetDataString ( "group", "" )
		self.panel.aclTree:SetDataString ( "object", "" )
		for _, group in ipairs ( acl ) do
			self.aclGroupData [ group.name ] = group
			local node = self.panel.aclTree:AddNode ( tostring ( group.name ) )
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
		self.panel.aclDataLabel:SetText ( "Group name: ".. tostring ( name ) .."\n\nCreator: ".. tostring ( data.creator ) .."\n\nCreation date: ".. tostring ( data.creationDate ):gsub ( " ", " - " ) .."\n\nGroup objects: ".. tostring ( #data.objects ) )
		self.panel.aclDataLabel:SizeToContents ( )
		self.panel.aclTree:SetDataString ( "group", name )
	end
end

function Admin:onACLRightClick ( node )
	local perm = node:GetText ( )
	local value = node:GetDataString ( "value" )
	self.permPanelChange.window:SetVisible ( true )
	self.permPanelChange.label:SetText ( "Permission: ".. tostring ( perm ) )
	self.permPanelChange.label:SizeToContents ( )
	self.permPanelChange.value:SetText ( tostring ( value ) )
end

function Admin:modifyACLPermission ( )
	local value = self.permPanelChange.value:GetText ( )
	local perm = self.permPanelChange.label:GetText ( ):gsub ( "Permission: ", "" )
	local group = self.panel.aclTree:GetDataString ( "group" )
	if ( value == "true" or value == "false" ) then
		Network:Send ( "admin.executeAction", { "acl.modifypermission", group, perm, value } )
	else
		self:Message ( "Invalid value, accepted values: true/false.", "err" )
	end
	self.permPanelChange.window:SetVisible ( false )
end

function Admin:showACLCreateWindow ( )
	self.aclCreatePanel.permissions:Clear ( )
	self.permissionItems = { }
	for _, perm in ipairs ( self.permissionNames ) do
		self.permissionItems [ perm ] = self.aclCreatePanel.permissions:AddItem ( tostring ( perm ) )
		self.permissionSelected [ perm ] = false
	end
	self.aclCreatePanel.window:SetVisible ( true )
end

function Admin:onPermissionSelect ( )
	local item = self.aclCreatePanel.permissions:GetSelectedRow ( )
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
	local name = self.aclCreatePanel.name:GetText ( )
	if ( name ~= "" ) then
		local perms = { }
		for _, perm in ipairs ( self.permissionNames ) do
			perms [ perm ] = self.permissionSelected [ perm ]
		end
		Network:Send ( "admin.executeAction", { "acl.creategroup", name, perms } )
		self.aclCreatePanel.window:SetVisible ( false )
	else
		self:Message ( "Write a group name.", "err" )
	end
end

function Admin:destroyACLGroup ( )
	local group = self.panel.aclTree:GetDataString ( "group" )
	if ( group and group ~= "" ) then
		Network:Send ( "admin.executeAction", { "acl.removegroup", group } )
	end
end

function Admin:showACLAddObjectWindow ( )
	local group = self.panel.aclTree:GetDataString ( "group" )
	if ( group and group ~= "" ) then
		self.aclObjectPanel.window:SetTitle ( "Add Object to: ".. tostring ( group ) )
		self.aclObjectPanel.window:SetDataString ( "group", group )
		self.aclObjectPanel.window:SetVisible ( true )
	end
end

function Admin:addACLObject ( )
	local group = self.aclObjectPanel.window:GetDataString ( "group" )
	if ( group and group ~= "" ) then
		local steamID = self.aclObjectPanel.value:GetText ( )
		if ( steamID ~= "" ) then
			Network:Send ( "admin.executeAction", { "acl.addobject", group, steamID } )
			self.aclObjectPanel.window:SetVisible ( false )
		else
			self:Message ( "Write a steam ID to add.", "err" )
		end
	end
end

function Admin:onACLObjectClick ( node )
	local steamID = node:GetText ( )
	if ( steamID ) then
		self.panel.aclTree:SetDataString ( "object", steamID )
	end
end

function Admin:removeACLObject ( )
	local group = self.panel.aclTree:GetDataString ( "group" )
	if ( group and group ~= "" ) then
		local object = self.panel.aclTree:GetDataString ( "object" )
		if ( object and object ~= "" ) then
			Network:Send ( "admin.executeAction", { "acl.removeobject", group, object } )
		end
	end
end

function Admin:displayModules ( modules )
	self.panel.modulesList:Clear ( )
	self.modules = { }
	if ( modules ) then
		for name, state in pairs ( modules [ 1 ] ) do
			local item = self.panel.modulesList:AddItem ( tostring ( name ) )
			item:SetTextColor ( ( state and Color ( 0, 255, 0 ) or Color ( 255, 0, 0 ) ) )
			self.modules [ name ] = item
		end

		self.panel.modulesLog:SetText ( "" )
		for index, log_ in ipairs ( modules [ 2 ] ) do
			if ( index == 1 ) then
				self.panel.modulesLog:SetText ( modules [ 2 ] [ 1 ] )
			else
				self.panel.modulesLog:SetText ( self.panel.modulesLog:GetText ( ) .."\n".. tostring ( log_ ) )
			end
		end
		self.panel.modulesLog:SizeToContents ( )
		self.panel.modulesLog:SetWrap ( true )
	end
end

function Admin:searchModule ( )
	local text = self.panel.modulesSearch:GetText ( ):lower ( )
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
	local row = self.panel.modulesList:GetSelectedRow ( )
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
	local row = self.panel.modulesList:GetSelectedRow ( )
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
	local row = self.panel.modulesList:GetSelectedRow ( )
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

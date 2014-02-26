local timers = { }
local objectToTimer = { }
local weaponList =
	{
		{ 2, "Pistol" },
		{ 4, "Revolver" },
		{ 5, "SMG" },
		{ 6, "Sawed off shotgun" },
		{ 11, "Assault rifle" },
		{ 13, "Pump action shotgun" },
		{ 14, "Sniper rifle" },
		{ 16, "Rocket launcher" },
		{ 28, "Machine gun" },
		{ 43, "Bubble blaster" },
		{ 66, "Panay's rocket launcher" },
		{ 100, "(DLC) Bull's Eye assault rifle" },
		{ 101, "(DLC) Air propulsion gun" },
		{ 102, "(DLC) Cluster bomb launcher" },
		{ 103, "(DLC) Rico's signature gun" },
		{ 104, "(DLC) Quad rocket launcher" },
		{ 105, "(DLC) Multi-lock missile launcher" }
	}
local weaponNames = { }
local weaponIDFromName = { }
local weaponNameFromID = { }
vehicleTemplates =
	{
		[ 1 ] = { "Modern_Cab", "Modern_Hardtop", "Classic_Cab" },
		[ 7 ] = { "FullyUpgraded", "WeaponUpgrade0", "WeaponUpgrade1" },
	    [ 8 ] = { "Hijack_Rear" },
   		[ 10 ] = { "Ingame", "Cutscene" },
   		[ 11 ] = { "FullyUpgraded", "Police" },
   		[ 18 ] = { "Cannon", "Russian" },
  		[ 31 ] = { "MG", "Cab" },
   		[ 35 ] = { "FullyUpgraded" },
   		[ 36 ] = { "Sport", "Civil", "Gimp" },
   		[ 40 ] = { "Regular", "Crane" },
   		[ 44 ] = { "Softtop", "Cab" },
   		[ 46 ] = { "Combi", "CombiMG", "Cab" },
   		[ 48 ] = { "BuggyMG" },
   		[ 56 ] = { "FullyUpgraded", "Hardtop", "MGCannon1", "WeaponUpgrade1", "Cab" },
   		[ 61 ] = { "FullyUpgraded", "WeaponUpgrade1", "TestTopSpeed", "TestAcceleration", "TestHandling" },
   		[ 66 ] = { "Double" },
   		[ 77 ] = { "FullyUpgraded", "WeaponUpgrade1" },
   		[ 78 ] = { "Cab" },
   		[ 84 ] = { "Cab" },
   		[ 87 ] = { "Softtop", "Cab" },
   		[ 91 ] = { "Softtop", "Hardtop" },
   		[ 5 ] = { "Fishing", "Cab" },
   		[ 38 ] = { "Djonk01", "Djonk02", "Djonk03", "Djonk04" },
   		[ 88 ] = { "FullyUpgraded", "TestAcceleration", "TestTopSpeed", "WeaponUpgrade1" },
   		[ 3 ] = { "FullyUpgraded", "WeaponUpgrade1", "Mission" },
		[ 37 ] = { "FullyUpgraded", "Mission", "WeaponUpgrade0", "WeaponUpgrade1" },
		[ 57 ] = { "FullyUpgraded", "WeaponUpgrade1" },
		[ 62 ] = { "Armed", "UnArmed", "Dome" },
		[ 81 ] = { "FullyUpgraded", "WeaponUpgrade1" }
	}

for _, weapon in ipairs ( weaponList ) do
	table.insert ( weaponNames, weapon [ 2 ] )
	weaponIDFromName [ weapon [ 2 ] ] = weapon [ 1 ]
	weaponNameFromID [ weapon [ 1 ] ] = weapon [ 2 ]
end

function getWeaponNames ( )
	return weaponNames
end

function getWeaponNameFromID ( id )
	return weaponNameFromID [ id ]
end

function getWeaponIDFromName ( name )
	return weaponIDFromName [ name ]
end

function convertNumber ( number )
	local formatted = number
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if ( k==0 ) then
			break
		end
	end

	return formatted
end

function getPlayerBySteamID ( steamID )
	local found = false
	for player in Server:GetPlayers ( ) do
		if ( tostring ( player:GetSteamId ( ) ) == steamID ) then
			found = player
			break
		end
	end

	return found
end

function timersTick ( )
	for index, timer in ipairs ( timers ) do
		local restart = false
		if ( timer.object:GetSeconds ( ) >= timer.delay ) then
			if ( type ( timer.func ) == "function" ) then
				timer.func ( table.unpack ( timer.args ) )
			end
			if ( type ( timer.repeats ) == "number" ) then
				timer.repeats = ( timer.repeats - 1 )
				if ( timer.repeats > 0 ) then
					restart = true
				end
			elseif ( timer.repeats == "always" ) then
				restart = true
			end
			if ( restart ) then
				timer.object:Restart ( )
			else
				objectToTimer [ timer.object ] = nil
				timer.object = nil
				table.remove ( timers, index )
			end
		end
	end
end
Events:Subscribe ( "PostTick", timersTick )

function setTimer ( func, delay, repeats, ... )
	if ( type ( func ) == "function" ) then
		local object = Timer ( )
		local timer =
			{
				object = object,
				delay = ( delay or 1 ),
				repeats = ( repeats == 0 and "always" or repeats ),
				func = func,
				args = { ... }
			}
		table.insert ( timers, timer )
		objectToTimer [ object ] = #timers

		return object
	else
		return false
	end
end

function killTimer ( timer )
	if ( type ( timer ) == "userdata" ) then
		if ( objectToTimer [ timer ] ) then
			if ( timers [ objectToTimer [ timer ] ] ) then
				if ( timers [ objectToTimer [ timer ] ].object == timer ) then
					table.remove ( timers, objectToTimer [ timer ] )
					timers [ objectToTimer [ timer ] ] = nil
				end
				objectToTimer [ timer ] = nil

				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

function isTimer ( timer )
	if ( type ( timer ) == "userdata" ) then
		if ( objectToTimer [ timer ] ) then
			if ( timers [ objectToTimer [ timer ] ] ) then
				if ( timers [ objectToTimer [ timer ] ].object == timer ) then
					return ( timers [ objectToTimer [ timer ] ].delay - timers [ objectToTimer [ timer ] ].object:GetSeconds ( ) )
				else
					return false
				end
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function toboolean ( str )
	return ( str == "true" and true or str == "false" and false )
end
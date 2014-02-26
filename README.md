Advanced GUI/Command based Admin System with a lot of functions and commands.

Features:

ACL ( Access Control List ): Controls the groups, group permissions, group members, able to disable entire panel tabs.

Ban system: A SQL based ban system ( duration bans, date of the ban, the admin who banned, etc )

Mute system: A SQL based mute system ( duration, date, admin responsible, etc )

A freeze system: Freezing/unfreezing player ( disables all controls but camera movement )

Spectating players: Not tested yet, but should work.

Setting health/model/money

Warp to players/warp player to another player

Give/destroy/repair vehicles

Give weapons to specified slot

Shout to players: Displays a message on the center of the screen of the player selected.
Killing players

Setting game time/weather severity/time step

Displaying some of the server config settings ( name, players/max players, etc )

Admin chat

Commands:

/ban <player> <duration in minutes> <reason> -> Bans a player for the given duration and reason.

/kick <player> <reason> -> Kicks a player with the given reason.

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

/giveadmin <player> -> Sets the ACL group of the player to "Admin".

/takeadmin <player> -> Removes the player from the "Admin" ACL group.

/shout <player> <message> -> Displays a message on the player screen.

/settime <value: 0-23> -> Sets the default world time to the specified value.

/settimestep <value> -> Sets the default world time step to the specified value.

/setweather <value: 0-2> -> Sets the default world weather severity to the specified value.


Players tab: http://cubeupload.com/im/fr6I9D.jpg, http://cubeupload.com/im/7XpAtN.jpg

Bans tab: http://cubeupload.com/im/TgGnbv.jpg

Server tab: http://cubeupload.com/im/ULaIR7.jpg

Admin chat tab: http://cubeupload.com/im/bvRXoM.jpg

ACL tab: http://cubeupload.com/im/0OoEvo.jpg, http://cubeupload.com/im/mVcT11.jpg

Toggle key: P

IMPORTANT:

You must make at least ONE person an Admin, for this you must put the Steam ID in server/admin_server.lua -> "firstAdmin" variable, from then, you can make others Admin by using the panel ( P key ).

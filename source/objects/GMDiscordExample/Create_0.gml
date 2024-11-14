// # Load my Discord Channel Card
// You can find your server's Guild ID > Open Discord > Go to Settings > Advanced > Enable Developer Mode. Then, right click on your server title and select "Copy ID".
GMDiscordCard("PUT_YOUR_GUILD_ID_HERE", function(status, data) {
	
	switch(status) {
		
		case DiscordCardStatus.Loading:
		// It's loading
		
		break;
		
		case DiscordCardStatus.Ready:
		// It's ready
		
		// Here, you can parse the data..
		// BEWARE! Some of the data here may not be available. In this case, you'll receive "" or -1 (for strings or ints)
		// BEWARE 2 - Make sure that you put the correct GuildID, otherwise you'll g
		
		
		var serverId = data.ServerID;
		var serverName = data.ServerName;
		
		var serverInstantInvite = data.ServerInstantInvite;
		var serverPresenceMemberCount = data.ServerPresenceMemberCount;
		
		// Now you can draw a cool Discord Invitation Card with that!
		show_debug_message(serverId);
		show_debug_message(serverName);
		show_debug_message(serverInstantInvite);
		show_debug_message(serverPresenceMemberCount);
		
		break;
		
		case DiscordCardStatus.Failed:
		show_debug_message("HTTP Call error. Check your internet connection?");
		break;
		
		case DiscordCardStatus.Error:
		show_debug_message("ERROR!");
		show_debug_message(data.Error);
		// Doesn't work, sorry.
		break;
		
		
	}
	
	
});
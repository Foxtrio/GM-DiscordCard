// # Extension written by Foxtrio @foxtriogames
// https://github.com/Foxtrio

/*
	Attribution is not required, but greatly appreciated.
	If you do, please let me know ^^

*/


global.__GMDiscordCards = [];

enum DiscordCardStatus {
	Loading,
	Ready,
	Failed,
	Error,
}

/// @function               GMDiscordCard(guildId, callback)
/// @description            Requests a Guild Information from Discord. This information includes: Server ID and Name, Invitation Link and Online Presence.
/// @param {String}			guildId		Guild ID of your Discord channel. You can get this ID > Open Discord > Go to Settings > Advanced > Enable Developer Mode. Then, right click on your server title and select "Copy ID".
/// @param {Function}		callback	The function that'll be called when the operation is completed/failed, or in progress.
function GMDiscordCard(guildId, callback) {
	if (!is_string(guildId)) {
		show_error("Guild ID must be a string, such as : \"1234567\"", true);
	}
	
	array_push(global.__GMDiscordCards, {
		GuildId : guildId,
		CallbackFunc : callback,
		HttpRequest : http_get(string("https://discordapp.com/api/guilds/{0}/widget.json", string(guildId))),
		Status : DiscordCardStatus.Loading,
	});
	

}


/// @function               GMDiscordCardHTTPAsyncEvent()
/// @description            Must be placed in a HTTP Async Event!
function GMDiscordCardHTTPAsyncEvent() {
	
	// Just to be safe, shut it down if these don't exist.
	if (ds_map_exists(async_load, "id") == false || ds_map_exists(async_load, "status") == false) {
		exit;
	}

	var __httpId, __cardsList
	__httpId = async_load[? "id"];
	__cardsList = global.__GMDiscordCards;
	
	var __caller = -1;
	for (var i = 0; i < array_length(__cardsList); ++i) {
	    // code here
		if (__cardsList[i].HttpRequest == __httpId) {
			
			__caller = i;
			break;
		}
	}

	// We have a caller...
	if (__caller != -1) {
		
		// We must do try / catch here, because things may break - on a very very rare occasion.
		var status, __callbackFunc;
		status = async_load[? "status"];
		__callbackFunc = __cardsList[__caller].CallbackFunc;

		if (status < 0) {
			// Failed
			if (__callbackFunc != -1) {
				__callbackFunc(DiscordCardStatus.Failed, "");
			}
			
			// This call is no longer needed. Remove from the memory
			array_delete(__cardsList, __caller, 1);
			
			
		} else if (status == 1) {
			// Still Downloading the data....
			if (__callbackFunc != -1) {
				__callbackFunc(DiscordCardStatus.Loading, "");
			}
			
			

		} else if (status == 0) {
			// Completed!
			
			// Try to parse JSON
			var __dataJson
			try {
				__dataJson = json_parse(async_load[? "result"]);
			} catch(_e) {
				
				if (__callbackFunc != -1) {
					__callbackFunc(DiscordCardStatus.Error, {
						Error : "Couldn't parse the inbound JSON string",
					});
					
					// This call is no longer needed. Remove from the memory
					array_delete(__cardsList, __caller, 1);
					
					exit;
				}
			}
			
			// If you put an unknown Guild ID
			if (variable_struct_exists(__dataJson, "code")) {
					
				if (__callbackFunc != -1) {
					__callbackFunc(DiscordCardStatus.Error, {
						Error : "Guild ID doesn't exist.",
					});
					
					// This call is no longer needed. Remove from the memory
					array_delete(__cardsList, __caller, 1);
					
					exit;
				}
			};
			
			// If you put an unknown Guild ID Format.
			if (variable_struct_exists(__dataJson, "guild_id") || variable_struct_exists(__dataJson, "message")) {
					
				if (__callbackFunc != -1) {
					__callbackFunc(DiscordCardStatus.Error, {
						Error : "Guild ID format error!",
					});
					
					// This call is no longer needed. Remove from the memory
					array_delete(__cardsList, __caller, 1);
					
					exit;
				}
			};
			
			
			var __serverId, __serverName, __serverInstantInvite, __presenceMemberCount;
			
			__serverId = variable_struct_exists(__dataJson, "id") ? __dataJson.id : "";
			__serverName = variable_struct_exists(__dataJson, "name") ? __dataJson.name : "";
			__serverInstantInvite = variable_struct_exists(__dataJson, "instant_invite") ? __dataJson.instant_invite : "";
			
			__presenceMemberCount = variable_struct_exists(__dataJson, "presence_count") ? real(__dataJson.presence_count) : -1;

			
			if (__callbackFunc != -1) {
				__callbackFunc(DiscordCardStatus.Ready, {
					
					ServerID : __serverId,
					ServerName : __serverName,
					ServerInstantInvite : __serverInstantInvite,
					ServerPresenceMemberCount : __presenceMemberCount,
				});
			}
			
			// This call is no longer needed. Remove from the memory
			array_delete(__cardsList, __caller, 1);
	
		}
		
		
	}

	
}
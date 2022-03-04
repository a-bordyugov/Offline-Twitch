return {
	run = function()
		fassert(rawget(_G, "new_mod"), "Offline Twitch must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("offline_twitch", {
			mod_script       = "scripts/mods/offline_twitch/offline_twitch",
			mod_data         = "scripts/mods/offline_twitch/offline_twitch_data",
			mod_localization = "scripts/mods/offline_twitch/offline_twitch_localization"
		})
	end,
	packages = {
		"resource_packages/offline_twitch/offline_twitch"
	}
}
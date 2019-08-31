Config = {}

-- Turn this to false if you want everyone to use this.
Config.OnlyPolicemen = true

-- This is how much ammo you should get per weapon you take out.
Config.ReceiveAmmo = 250
Config.RequiredRefillGrade = 5
Config.ArmoryMarkerColor = { r = 50, g = 50, b = 204, a = 100 }
Config.ArmoryMarker = 27
-- You don't need to edit these if you don't want to.
Config.Kevlar = {
	{ ["x"] = 455.95, ["y"] = -979.46, ["z"] = 29.709582824707, ["h"] = 0 },
}
Config.Armory = {
	{ ["x"] = 460.06, ["y"] = -979.46, ["z"] = 29.709582824707, ["h"] = 0 },
}
Config.Attachment = {
	{ ["x"] = 461.6067, ["y"] = -981.0711, ["z"] = 29.709582824707, ["h"] = 0 },
}


-- This is the available weapons you can pick out.
Config.ArmoryWeapons = {	
	{ ["weaponHash"] = "WEAPON_FLASHLIGHT", ["name"] = "Lommelygte" },
	{ ["weaponHash"] = "WEAPON_NIGHTSTICK", ["name"] = "Knippel" },
	{ ["weaponHash"] = "WEAPON_STUNGUN", ["name"] = "Tazer" },
	{ ["weaponHash"] = "WEAPON_PISTOL_MK2", ["name"] = "Pistol Mk II" },
	{ ["weaponHash"] = "WEAPON_SMG", ["name"] = "SMG" },	
	{ ["weaponHash"] = "WEAPON_CARBINERIFLE_MK2", ["name"] = "Carbine Rifle Mk II" },
	{ ["weaponHash"] = "WEAPON_PUMPSHOTGUN", ["name"] = "Shotgun" },
}


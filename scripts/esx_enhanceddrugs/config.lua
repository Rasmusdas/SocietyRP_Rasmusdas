Config = {}

Config.Reward = {
	["meth"] = 0,
	["coke"] = 0,
	["weed"] = 0,
}

Config.DrugVans = {
	{
		Location = vector3(0,0,0),
		InUse = false,
		Heading = 0,
		GoonSpawns = {
			one = vector3(0,0,0),
			two = vector3(0,0,0),
		},
	},
}

Config.DeliveryPoints = {
	vector3(0,0,0),
	-- Add more by putting more vector3()'s in here
}


Config.DrugNPC = {
	{
		spot = {x=0,y=0,z=0},
		Heading = 0,
		Hint = ""
	}
}

Config.Prices = {
	["Coke"] = 0,
}

Config.StickLoc = 
{
	{
		Location = vector3(0,0,0),
		GoonSpawns = {
			vector3(0,0,0),vector3(0,0,0),vector3(0,0,0)
		}
	}
}

Config.ScaleName = "hqscale"

Config.Convertion = 
{
	{
		ItemPre = "cokeBig",
		ItemPost = "cokeSmall",
		Amount = 0,
		ReqItem = "drugbags",
		ReqItemName = "Bags",
		ReqItemAmount = 0,
		ReqScale = true,
		ConvertionTime = 0,
		ConvertText = "OMDANNER KOKAIN"
	},{
		ItemPre = "cokeSmall",
		ItemPost = "coke",
		Amount = 0,
		ReqItem = "drugbags",
		ReqItemName = "Bags",
		ReqItemAmount = 0,
		ReqScale = true,
		ConvertionTime = 0,
		ConvertText = "OMDANNER KOKAIN"
	}
}
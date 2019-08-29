resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX DrugSale'

version '2.0.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
	'server/main.lua',
	'config.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'client/drugvan.lua',
	'client/drugnpc.lua',
	'client/drugeffects.lua',
	'config.lua'

}

dependencies {
	'es_extended',
}

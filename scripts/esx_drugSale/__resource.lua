resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

description 'ESX DrugSale'

version '2.0.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/bedremain.lua'
}

client_scripts {
	'client/main.lua',
}

dependencies {
	'es_extended',
	'esx_outlawalert'
}

local urbandictionary = {}
local HTTP = require('socket.http')
local URL = require('socket.url')
local JSON = require('dkjson')
local mattata = require('mattata')

function urbandictionary:init(configuration)
	urbandictionary.arguments = 'urbandictionary <query>'
	urbandictionary.commands = mattata.commands(self.info.username, configuration.commandPrefix):c('urbandictionary', true):c('ud', true):c('urban', true).table
	urbandictionary.help = configuration.commandPrefix .. 'urbandictionary <query> - Defines the given word. Urban style. Aliases: ' .. configuration.commandPrefix .. 'ud, ' .. configuration.commandPrefix .. 'urban.'
end

function urbandictionary:onMessageReceive(msg, configuration)
	local input = mattata.input(msg.text)
	if not input then
		mattata.sendMessage(msg.chat.id, urbandictionary.help, nil, true, false, msg.message_id, nil)
		return
	end
	local url = configuration.apis.urbandictionary .. URL.escape(input)
	local jstr, res = HTTP.request(url)
	if res ~= 200 then
		mattata.sendMessage(msg.chat.id, configuration.errors.connection, nil, true, false, msg.message_id, nil)
		return
	end
	local jdat = JSON.decode(jstr)
	if jdat.result_type == "no_results" then
		mattata.sendMessage(msg.chat.id, configuration.errors.results, nil, true, false, msg.message_id, nil)
		return
	end
	local output = '*' .. jdat.list[1].word .. '*\n\n' .. mattata.trim(jdat.list[1].definition)
	if string.len(jdat.list[1].example) > 0 then
		output = output .. '_\n\n' .. mattata.trim(jdat.list[1].example) .. '_'
	end
	output = output:gsub('%[', ''):gsub('%]', '')
	mattata.sendMessage(msg.chat.id, output, 'Markdown', true, false, msg.message_id, nil)
end

return urbandictionary
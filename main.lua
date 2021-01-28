-- dependencies
local json = require('json')
local discordia = require('discordia')
local client = discordia.Client()

storyServerID = "784167695372779561"
storyChannelID = "784644349879255080"
chapterSubtitle = "𝒞𝒽𝒶𝓅𝓉𝑒𝓇"
charLimit = 1000
wipe = false
post = true
-- storyChannel:send{embed = chapter}

client:on('ready', function()
	-- client.user is the path for your bot

	print('Logged in as '.. client.user.username)

	local storyChannel = client:getChannel(storyChannelID)
	
	local storyServer = client:getGuild(storyServerID)
	print("Current server: ".. storyServer.name)
	local storyText = getStoryText(storyChannel)

	local newChapters = compileChapters(storyText, storyServer)

	
	local myMessages = getMyMesssages(storyChannel)
	
	if wipe == true then
		wipeMyMessages(storyChannel, 1)
	end

	for nindex, newChapter in pairs(newChapters) do
		local sendChapter = true
		for mindex, message in pairs(myMessages) do
			local newChapterTitle = trim(newChapter["fields"][1]["name"])
			local newChapterContent = trim(newChapter["fields"][1]["value"])
			local oldChapterTitle = trim(message.embed["fields"][1]["name"])
			local oldChapterContent = trim(message.embed["fields"][1]["value"])
			
			if newChapterTitle == oldChapterTitle then
				print("Found a match for Chapter " .. nindex)
				print(newChapterTitle .. ": " .. newChapterContent)
				print(oldChapterTitle .. ": " .. oldChapterContent)
				if newChapterContent ~= oldChapterContent then
					message:delete()
				else
					sendChapter = false
				end
			end

		end

		if sendChapter == true and post == true then
			storyChannel:send{embed = newChapter}
		end
	end

	os.exit()
end)


function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end


function getMyMesssages(channel) --working on date sorting
	local firstMessage = channel:getFirstMessage()
	local lastMessage = channel:getLastMessage()
	local messageHistory = {}
	local myMessages = {}
	while firstMessage ~= lastMessage do
		local rawMessageHistory = channel:getMessagesBefore(lastMessage.id)

		local tempIter = 1
		for index, message in pairs(rawMessageHistory) do
			messageHistory[tempIter] = message
			tempIter = tempIter + 1

		end

		table.sort(messageHistory, function(m1, m2) return m1.createdAt < m2.createdAt end)



		tempIter = 1
		for index, message in pairs(messageHistory) do
			if message.author == client.user then
				myMessages[tempIter] = message
				tempIter = tempIter + 1
			end
		end
		lastMessage = messageHistory[1]
	end

	if channel:getLastMessage().author == client.user then
		table.insert(myMessages, channel:getLastMessage())
	end

	table.sort(myMessages, function(m1, m2) return m1.createdAt < m2.createdAt end)

	return myMessages

end


function wipeMyMessages(channel, cycles)
	local repeats = cycles

	while repeats > 0 do
		local myMessages = getMyMesssages(channel)
		channel:bulkDelete(myMessages)
		sleep(5)
		repeats = repeats - 1
	end
end


-- sort messages by date
-- assemble into string, insert handlers
-- spit back out 

function sleep(n)
	os.execute("sleep " .. tonumber(n))
end


-- function getStoryChannel(server, channelID) -- select channel
-- 	for channel in server.TextChannels do
-- 		if channelID == channel.id then 
-- 			break
-- 		end
-- 	end

function getStoryText(channel) -- index all messages in story channel

	local firstMessage = channel:getFirstMessage()
	local endOfChannel = false
	local storyText = {}
	while endOfChannel == false do
		messageHistory = channel:getMessagesAfter(firstMessage.id) -- gets the first 100 messages in the channel
		storyMessages = {firstMessage}
		for id, message in pairs(messageHistory) do
			table.insert(storyMessages, message)
		end

		table.sort(storyMessages, function(a,b) return a.createdAt < b.createdAt end) -- sort message by date / time

		for index, message in pairs(storyMessages) do
			local text = message.cleanContent
			if text ~= nil and message.author.bot == false then
				table.insert(storyText, trim(text))
			end
		end

		if #storyMessages < 50 then
			endOfChannel = true
			break
		else
			firstMessage = storyMessages[#storyMessages]
		end
		sleep(1)
	end
	-- sort words by date


	return storyText

end







function compileRawChapters(words)
	-- check if the story is over 2000 characters yet
	local rawChapters = {""}
	local words = words
	local currentChapter = 1

	for index, word in pairs(words) do
		if string.len(rawChapters[currentChapter]) + string.len(word) > charLimit == true then
			currentChapter = currentChapter + 1
			rawChapters[currentChapter] = ""
		end

		rawChapters[currentChapter] = rawChapters[currentChapter] .. " " .. word

	end

	return rawChapters

end

function compileChapters(words, server)
	rawChapters = compileRawChapters(words)
	chapters = {}
	toBeContinuedText = "...𝓪𝓷𝓭 𝓽𝓱𝓮 𝓼𝓽𝓸𝓻𝔂 𝓬𝓸𝓷𝓽𝓲𝓷𝓾𝓮𝓼 𝓸𝓷!"

	for index, chapter in pairs(rawChapters) do
		local chapterEmbed = {
			title = "𝔒𝔫𝔠𝔢 𝔲𝔭𝔬𝔫 𝔞 𝔱𝔦𝔪𝔢 𝔦𝔫 " .. server.name .. "..." ,
			fields = {
				{name = "𝒞𝒽𝒶𝓅𝓉𝑒𝓇 " .. index, value = chapter},
				{name = toBeContinuedText, value = "** **"}
			},
			color = discordia.Color.fromRGB(114, 137, 218).value,
			timestamp = discordia.Date():toISO('T', 'Z')
		}

		table.insert(chapters, chapterEmbed)
	end	

	return chapters
end 



client:run('Bot Nzk0ODUwNjU0ODAzODUzMzQz.X_A0Ww.xUd5J6OFhDw93WMpiWaDaylxj-A')	
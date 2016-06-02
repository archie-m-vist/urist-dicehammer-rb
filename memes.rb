def initMemes (bot, serverFlags)
   bot.message(contains: 'plump helm') do |event|
   if serverFlags[event.server.id]["memes"]
      event.respond 'OM NOM NOM BRING MORE WINE'
      end
   end

   bot.message(contains: 'miasma') do |event|
      if serverFlags[event.server.id]["memes"]
         event.respond "_Urist Dicehammer was disgusted by miasma recently._"
      end
   end

   bot.message(contains: 'carp') do |event|
      if serverFlags[event.server.id]["memes"]
         event.respond "_Urist Dicehammer has witnessed death._"
      end
   end

   bot.message(contains: 'race condition') do |event|
      if serverFlags[event.server.id]["memes"]
         event.respond "Zero point. See you next semester!"
      end
   end
end

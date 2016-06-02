def initFlags (bot, serverFlags)
   bot.servers.keys.each do |server|
      serverFlags[server] = { "memes" => false }
   end
   
   bot.command :toggle do |event, setting, svalue|
      if svalue.casecmp("yes") == 0 || svalue.casecmp("on") == 0 || svalue.casecmp("true") == 0
         value = true
      elsif svalue.casecmp("no") == 0 || svalue.casecmp("off") == 0 || svalue.casecmp("false") == 0
         value = false
      else
         return "Error: expected 'on' or 'off' for !toggle"
      end
   
      if setting.casecmp("memes") == 0
         serverFlags[event.server.id]["memes"] = value
         if ( value )
            "JUST MEME MY URIST UP"
         else
            "This is a sober, serious bot."
         end
      end
   end
end

require 'discordrb'
load 'parser.rb'

bot = Discordrb::Commands::CommandBot.new token: [token here], application_id: [appid here], prefix: '!'

name = "Urist Dicehammer"

# defines urist's ebin maymays
#load "memes.rb"
#engage_memes(bot)

serverFlags = {}

# run on bot startup
bot.ready do |event|
   puts "Ready!"
   bot.servers.keys.each do |server|
      serverFlags[server] = { "memes" => false }
   end
end

bot.message(with_text: 'Check Urist') do |event|
   event.respond "Ready!"
end

bot.command :coinflip do |event, *args|
   number = 1
   if ( args.length > 0 )
      number = args[0].to_i
      if ( number < 1 )
         number = 1
      end
   end
   headcount = 0
   tailcount = 0
   output = ""
   # repeat flips
   while ( number > 0 )
      if ( rand(2) == 1 )
         output += "Heads."
         headcount += 1
      else
         output += "Tails."
         tailcount += 1
      end
      number -= 1
      if ( number > 0 )
         output += " "
      end
   end
   totals = ""
   if ( headcount + tailcount > 1 )
      totals = "**"
      if ( headcount > 0 )
         totals += headcount.to_s + " heads"
      end
      if ( headcount > 0 && tailcount > 0 )
         totals += ", "
      end
      if ( tailcount > 0 )
         totals += tailcount.to_s + " tails"
      end
      totals += ":** "
   end
   totals + output
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

bot.message(contains: 'plump helm') do |event|
   if serverFlags[event.server.id]["memes"]
      event.respond 'OM NOM NOM BRING MORE WINE'
   end
end

bot.message(contains: 'miasma') do |event|
   if serverFlags[event.server.id]["memes"]
      event.respond "_"+name+" was disgusted by miasma recently._"
   end
end

bot.message(contains: 'carp') do |event|
   if serverFlags[event.server.id]["memes"]
      event.respond "_"+name+" has witnessed death._"
   end
end

bot.message(contains: 'race condition') do |event|
   if serverFlags[event.server.id]["memes"]
      event.respond "Zero point. See you next semester!"
   end
end

bot.command :roll do |event, dstring, *args|
   if dstring.casecmp("help") == 0
      event.respond "Suppoted features:"
      event.respond "!roll 3d6 would roll three six-sided dice, giving results and total."
      event.respond "!roll 3#3d6 would roll three six-sided dice three times, giving separate results and totals."
      event.respond "!roll 3d6+4 would roll three six-sided dice and add 4 to the total."
      return
   end
   
   parsedArgs = parseRollArgs(args, event)
   
   # regular expressions to parse dstring
   dice = /(?<number>[0-9]+)d(?<faces>[0-9]+)/
   dcount = /(?<count>[0-9]+)#/
   dbonus = /d[0-9]+(?<sign>[\+\-])(?<bonus>[0-9]+)/
   
   # get dice data
   mdata = dice.match(dstring)
   if not mdata
      return "Invalid die specifier."
   end
   number = mdata['number'].to_i
   faces = mdata['faces'].to_i
   output = event.user.name + " rolled " + number.to_s + "d" + faces.to_s;
   
   # check count
   count = 1
   if dcount.match(dstring)
      count = $~['count'].to_i
      output += " " + $~['count'] + " times"
   end
   
   # check count/number for message length limiter
   if ( count > 10 or number > 25 )
      return "Error: "+name+" only supports up to 10 different rolls or 25 dice at present due to Discord message limitations."
   end
   # determine bonus
   sign = ""
   bonus = 0
   if dbonus.match(dstring)
      bonus = $~['bonus'].to_i
      sign = $~['sign']
      if sign == "-"
         bonus = bonus * -1
      end
      output += " with modifier "+sign+$~['bonus']
   end
   output += ": "
   
   # roll dice
   while ( count > 0 )
      total = 0
      temp = number
      resultArray = []
      while ( temp > 0 )
         roll = 1+rand(faces)
         resultArray << roll
         total += roll
         temp -= 1
      end
      # drop dice if requested
      if parsedArgs.key?('drop')
         dropped = ['drop']
         dropCount = parsedArgs['drop'][0]
         dropSide = parsedArgs['drop'][1]
         while ( dropped.length < dropCount+1 )
            remove = []
            if dropSide == 'lowest' # drop lowest
               remove = resultArray.enum_for(:each_with_index).min
            else # drop highest
               remove = resultArray.enum_for(:each_with_index).max
            end
            dropped << remove[0]
            total -= remove[0]
            resultArray.delete_at(remove[1])
         end
         resultArray << dropped
      end
      resultString = parseResultString(resultArray)
      total += bonus
      output += "**" + total.to_s + "** {" + resultString + "}"
      if ( count > 1 )
         output += ", "
      end
      count -= 1
   end
   output
end

bot.run

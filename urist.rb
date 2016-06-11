require 'discordrb'
load 'parser.rb'
load 'token.rb'

bot = Discordrb::Commands::CommandBot.new token: loginToken(), application_id: appID(), prefix: '!'

# defines urist's ebin maymays
#load "memes.rb"
#engage_memes(bot)

serverFlags = {}

load 'flags.rb'
load 'memes.rb'

# run on bot startup
bot.ready do |event|
   initFlags(bot, serverFlags)
   initMemes(bot, serverFlags)
   puts "Ready!"
end

bot.message(with_text: 'Check Urist') do |event|
   event.respond "Ready!"
end

bot.command :emote do |event, name, *args|
   if /\./.match(name) or /\//.match(name)
      if serverFlags[event.server.id]["memes"]
         event.respond "Nice try."
      end
      return
   end
   if ( name == "help" )
      event.respond "Suppoted emotes:"
      folders = Dir.entries("./pictures")
      folders.delete(".")
      folders.delete("..")
      folders.each do |folder|
         event.respond "!emote " + folder
      end
      return
   end
   # get file
   dir = "./pictures/"+name.to_s+"/"
   count = Dir[dir+"*"].length
   if ( count == 0 )
      return "Error: Unsupported emote."
   end
   id = rand(count)+1
   if args.length > 0 && args[0].to_i > 0 && args[0].to_i <= count
      id = args[0].to_i
   end
   fname = dir + id.to_s + ".gif"
   # send file
   ifile = File.new(fname,"r")
   event.channel.send_file(ifile)
   nil
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

bot.command :request do|event, *args|
   if args.length == 0 and args[0].casecmp("help") == 0
      event.respond "Sends a suggestion for a Urist feature for Archie to ignore, the lazy fuck."
      return
   end
   open('requests.out', 'a') { |f|
      f.puts event.user.name ": " args.join(" ")
   }
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
   dbonus = /d[0-9]+(?<sign>[\+\-\*\/])(?<bonus>[0-9]+)/
   
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
      elsif sign == "/"
         bonus = 1.0/bonus
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
      # set up the result string
      resultString = parseResultString(resultArray)
      # apply bonus
      if sign == "+" or sign == "-"
         total += bonus
      elsif sign == "*" or sign == "/"
         total *= bonus
      end
      output += "**" + total.to_s
      # check 'em
      if parsedArgs.key?('dubs') || serverFlags[event.server.id]["memes"]
         if total % 100 == 77
            output += " Checked; Nana wills it. "
         elsif (total % 100) % 11 == 0
            output += " Checked. "
         end
      end
      output += "** {" + resultString + "}"
      if ( count > 1 )
         output += ", "
      end
      count -= 1
   end
   output
end

bot.run

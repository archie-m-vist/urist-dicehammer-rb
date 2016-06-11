# parses arguments to roll
def parseRollArgs (args, event)
   parsedArgs = {}
   index = 0
   while ( index < args.count )
      arg = args[index]
      if ( arg.casecmp("drop") == 0 )
         dropCount = 1
         dropEnd = 'lowest'
         if index+1 < args.length && (args[index+1].casecmp("lowest") == 0 || args[index+1].casecmp("highest") == 0 )
            parsedArgs['drop'] = [1,args[index+1].downcase]
            index += 1
         elsif index+1 < args.length && args[index+1].to_i != 0
            dropCount = args[index+1].to_i
            if index+2 < args.length && "highest".casecmp(args[index+2]) == 0
               dropEnd = 'highest'
               index += 1
            elsif index+2 < args.length && "lowest".casecmp(args[index+2]) == 0
               index += 1
            end
            parsedArgs['drop'] = [dropCount, dropEnd]
            index += 1
         else
            event.respond "Error: unexpected argument after 'drop'. Expected integer and lowest/highest."
         end
      elsif ( arg.casecmp("dubs") == 0 )
         parsedArgs['dubs'] = true
      elsif ( arg.casecmp("explode") == 0 )
         parsedArgs['explode'] = { 'expMax' => 1 }
         if index+1 < args.length && (args[index+1].to_i.to_s == args[index+1])
            parsedArgs['explode']['expMax'] = args[index+1].to_i
            index += 1
         end
      end
      index += 1
   end
   return parsedArgs
end

# creates result string from array of rolls
def parseResultString (resultArray)
   index = 0
   resultString = ""
   while ( index < resultArray.count )
      if resultArray[index].is_a? Integer
         resultString += resultArray[index].to_s
         if ( index < resultArray.count-1 )
            resultString += ","
         end
      else
         if resultArray[index][0] == "drop"
            resultString += " (dropped "
            len = resultArray[index].length
            (1..len-2).each do |i|
               resultString += resultArray[index][i].to_s + ","
            end
            resultString += resultArray[index][len-1].to_s + ")"
         end
      end
      index += 1
   end
   resultString
end

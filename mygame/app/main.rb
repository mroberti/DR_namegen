

$gtk.reset()
def r 
  $gtk.reset()
end
# //  =======================================================
# //   WHAT STUFF MEANS
# //  =======================================================
# //   symbol ($)  group name          parser field
# //   ----------  ------------------  -------------------------
# //   s           syllablesStart      parser_data["start"]
# //   m           syllablesMiddle     parser_data["middle"]
# //   e           syllablesEnd        parser_data["end"]
# //   P           syllablesPre        parser_data["pre"]
# //   p           syllablesPost       parser_data["post"]
# //   v           phonemesVocals      parser_data["vocals"]
# //   c           phonemesConsonants  parser_data["consonants"]
# //   A           customGroupA        parser_data["cga"]
# //   B           customGroupB        parser_data["cgb"]
# //   ...
# //   N           customGroupN        parser_data["cgn"]
# //   O           customGroupO        parser_data["cgo"]
# //   ?           phonemesVocals/     parser_data["vocals"]/
# //               phonemesConsonants  parser_data["consonants"]
# //  =======================================================
### SETUP :

def format_as_ordinal(number)
  def ordinal_suffix(number)
    ones = number.to_s[-1]
    tens = number.to_s[-2]
    
    return 'nd' if ones == '2'
    return 'rd' if ones == '3'
    return 'st' if ones == '1' && tens != '1'
    return 'st' if ones == '1' && (number < 10 || tens != '1')
    'th'
  end
  number.to_s + ordinal_suffix(number)
end

def isNumber(value)
  numbers = '0'..'9'
  if((value.chars.all? { |c| numbers.include? c }))then
    return true
  else   
    return false
  end
end

def roll100(value)
  result = false
  if(rand(100)<value.to_i)then
    result = true
  end
  return result
end

def makeName(args,filename)
  $ruleFile = $gtk.parse_json($gtk.read_file("assets/data/"+filename))
  rules = $ruleFile['rules'].split(",")
  puts 'Rules '+rules.to_s
  rules.each do | tempRule |
    # puts "Before tempRule: " + tempRule.to_s
    tempRule = tempRule.gsub!(" ", "")
    # puts "After  tempRule: " + tempRule.to_s
  end
  # puts 'Begin----------------------------'
  # puts 'Parsing '+ filename
  # puts "Number of rules: "+rules.length().to_s

  def doThePhonemes(args,theRules)
    parsedRules=theRules.gsub!("$", "").split("_")
    # puts "parsedRules: " + parsedRules.to_s
    theName = ""
    parsedRules.each do | tempRule |
      theRule = tempRule[-1]
      # puts "theRule: " + theRule.to_s
      thePercentile = tempRule.to_s.split(theRule)[0]
      if(thePercentile==nil)then
        # puts 'Its nil'
        thePercentile=99
        theRule = tempRule[0]
        # puts 'Adjusted rule '+theRule
      end
      # puts "thePercentile: " + thePercentile.to_s

      if(roll100(thePercentile)==true or thePercentile==nil)then 
        theWord = $ruleFile[theRule].split(",").sample()
        # puts "theWord: " + theWord.to_s
        theName+=theWord
      end
    end
    return theName
  end

  def parseMeRule(args,rule)
    # puts 'I\'m processing my rule!'
    if rule.include? "%"
      # puts "String includes '%'"
      beginning = rule.index('$')
      theLength = rule.length()
      trimmedRule = rule[beginning..theLength]
      thePercentile = rule[0..beginning-1].gsub!("%", "")
      # puts 'TrimmedRule :' + trimmedRule
      result = doThePhonemes(args,trimmedRule)
      if result.include? "`"
        puts 'Found a `'
        result.gsub!("`", format_as_ordinal(rand(1000)+1)+" ")
      end
      # Add the result to the array for later display
      args.state.names << result
      # puts "thePercentile:" + thePercentile + ',' + roll100(thePercentile).to_s

    else
      # puts "String does NOT includes '%'"
      # puts 'Rule :' + rule
      result = doThePhonemes(args,rule)
      if result.include? "`"
        puts 'Found a `'
        result.gsub!("`", format_as_ordinal(rand(1000)+1)+" ")
      end
      # Add the result to the array for later display
      args.state.names << result
    end 
  end

  parseMeRule(args,rules[rand(rules.length())])

end

def setup args
    # for i in 1..50 do
    #   puts format_as_ordinal(i)         
    # end

  names = ['empires.json','corporations.json','books.json','dwarf male.json','military_units.json']
  args.state.names=[]
  # names = ['dwarf male.json']
  names.each do | tempName |
    # Add filename to our output labels
    args.state.names << ("|" + tempName)
    for i in 1..20 do
      # Generate the names
      makeName(args,tempName) # <- This does the magic
    end
  end
  puts args.state.names.to_s
  args.state.setup_done = true
end

def render args
  args.outputs.labels << [100,90, args.state.rules, 3, 1, 0,0,0, 200, 1]
  args.outputs.labels << [100,60, args.gtk.current_framerate.to_i, 3, 1, 0,0,0, 200, 1]
  xLocation = 10
  yLocation = 700
  for i in 1..args.state.names.length()-1 do
    if args.state.names[i].include? "|"
        xLocation = xLocation + 250
        yLocation = 700
    end
    yLocation = yLocation - 20
    args.outputs.labels << [xLocation,yLocation, args.state.names[i], -3, 0, 0,0,0, 200, 1]
  end
end

### MAIN LOOP :
def tick(args)
  ## Setup :
  setup(args) unless args.state.setup_done
  render args
end

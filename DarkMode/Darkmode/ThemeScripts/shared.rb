require 'nokogiri'
require 'fileutils'
$new_color_assets = ['labelDefault','containerBg'].map(&:chomp) # add assets here

# Returns HexCode for Red green blue Alpha values
def name_for_rgba_components(red, green, blue, alpha)
    colorcode = format('#%02X%02X%02X%02X', red.round, green.round, blue.round, alpha).to_s
    return if colorcode == '#00000000' #clear color
    return if colorcode[7,9] == '00' # no alpha
    colorcode
end

# returns  hexCode foe white with Alpha
def name_for_white_and_alpha_components(white, alpha)
    newWhite = (white.round(8) * 255).round
    newAlpha = (alpha.round(8) * 255).round
    colorcode = format('#%02X%02X%02X%02X', newWhite, newWhite, newWhite, newAlpha).to_s
    return if colorcode == '#00000000' #clear color
    return if colorcode[7,2] == '00' # no alpha
    colorcode
end
# returns colorCode for Color XMl 
def get_hexcode(colorTag)
    return unless colorTag
    return systemColor_hex(colorTag['systemColor']) if colorTag['systemColor'] #New system colors
    return systemColor_hex(colorTag['cocoaTouchSystemColor']) if colorTag['cocoaTouchSystemColor'] #system colors
    if colorTag['name'] # Color Asset
        return color_code_from_asset(colorTag['name'])
    end
    color_space = colorTag['colorSpace']
    color_space = colorTag['customColorSpace'] if color_space == 'custom'
    hexCode = nil
    case color_space
        when 'sRGB', 'calibratedRGB', 'displayP3', 'deviceRGB' # color Schems(R, G, B)
            components = colorTag.attributes
            .values_at('red', 'green', 'blue', 'alpha')
            .map(&:value)
            .map(&:to_f)
            .map { |c| c.round(8) * 255 }
            hexCode = name_for_rgba_components(*components)
        when 'genericGamma22GrayColorSpace', 'calibratedWhite' # color Schems(White, Alpha)
            components = colorTag.attributes
            .values_at('white', 'alpha')
            .map(&:value)
            .map(&:to_f)
            hexCode = name_for_white_and_alpha_components(*components)
    end
    hexCode
end

# will set the tokenValue with keyPath for control userDefinedRuntimeAttributes
def add_token(doc, control, keyPath, tokenValue) 
    return unless tokenValue
    return unless keyPath
    userDefinedRuntimeAttributes = control.at_xpath('userDefinedRuntimeAttributes') || control.add_child(doc.create_element('userDefinedRuntimeAttributes'))
    unless userDefinedRuntimeAttributes.at("userDefinedRuntimeAttribute[@keyPath=#{keyPath}]") # Property not exits create
        userDefinedRuntimeAttributes << doc.create_element('userDefinedRuntimeAttribute', type: 'string', keyPath: keyPath, value: tokenValue)
    else  
        userDefinedRuntimeAttributes.at("userDefinedRuntimeAttribute[@keyPath=#{keyPath}]")['value'] = tokenValue # Property exits  and update tokenvalue
    end
end

# color code for system colors
def systemColor_hex(colorName)
    #  puts color
    case colorName
    when 'systemBackgroundColor', 'whiteColor'
        '#FFFFFFFF'
    when 'labelColor', 'darkTextColor'
        '#000000FF'
    when 'systemYellowColor'
         '#FFCC00FF'
    when 'systemRedColor'
         '#FF3830FF'
    when 'systemGray5Color'
         '#E5E5EAFF'
    when 'lightTextColor'
         '#CBCCCDFF'
    when 'systemGreenColor'
         '#4CD964FF'
    when 'systemPurpleColor'
         '#AF52DEFF'
    else
    puts "Unknown systemColor -- #{colorName}"
    end
end

# creates directory
def create_file(path, extension)
    dir = File.dirname(path)
  
    unless File.directory?(dir)
      FileUtils.mkdir_p(dir)
    end
  
    path << ".#{extension}"
    File.new(path, 'a')
end

# writes the line to  my_file
def write_to_file(line)
    file = "ThemeScripts/WrongColors.txt"
    create_file("ThemeScripts/WrongColors", "txt")
    colors_file = File.open(file)
    file_data = colors_file.readlines.map(&:chomp)
    if file_data.include? line 
        return
    end
    File.open(colors_file, 'a') do |file|
       file.puts "#{line}"
    end
end

def color_code_from_asset(asset_name)
    case asset_name
     when 'primaryColor'
         '#FF0000'
     when 'labelDefault'
         '#000000FF'
     when 'labelPrimary'
         '#FF0000'
     when 'labelWhite'
         '#FFFFFFFF'
     when 'switchColor'
         '#53575AFF'
     else
         if $new_color_assets.include? asset_name
             puts"New Asset found #{asset_name}"
            asset_name
         elsif
            puts "Unknown ColorAssest -- #{asset_name}"
         end
     end
 end



require 'nokogiri'
require_relative 'shared'
$view_colors = []
BEGIN {

}

# returns colortoken for colorcode: Hex 8 digit
def get_view_token(colorCode)
    return unless colorCode
    return colorCode if $new_color_assets.include? colorCode
    
    if ['#3C3C431D', '#3C3C4349', '#3C3C4348', '#3C3C4319', '#FFFFFF33', '#CCCCCC68', '#F4F4F4FF', '#F6F6F7FF', '#F5F5F5FF', '#FFFFFF17', '#F2F2F2FF'].include? colorCode
        return 'separtor'
    end
    case colorCode[0,7]
    when '#FFFFFF'
        "separatorDefault" # white
    when '#F0F0F0'
        "separatorTertiary"
    when '#D8D8D8', '#D9D9D9','#DDDEDE', '#D9D9D9'
        "separator"
    when '#000000'
      return
    else
    puts "Wrong #{colorCode}"
          $view_colors << colorCode
        return
    end
 end

# returns matching token Keypath for keyPath  
def get_token_keyPath(keyPath) 
    return unless keyPath
    case keyPath
    when 'backgroundColor'
        "tkBgColor"
    else 
        puts "Unmatched keyPath: #{keyPath}"
        return
    end
end
def update_uiComponent(doc, uiComponent, xib)
    # puts File.basename(xib) # storyboard or xib
    return unless rect = uiComponent.at_xpath('rect')
    return if rect['height'] == "0.0"
    return if rect['height'].to_i > 5
    return if rect['height'] == rect['width'] # ignore if view is square
    case rect['height']
    when "0.5", "1", "2", "3" "3.5", "0.33333333333334281", "5"
       uiComponent.xpath('color').each do |color|
           next unless color['key'] == 'backgroundColor'
           hexCode = get_hexcode(color)
           next unless hexCode
           tokenPath = get_token_keyPath(color['key'] )
           tokenValue = get_view_token(hexCode)
           add_token(doc, uiComponent, tokenPath, tokenValue)
       end
    end
    case rect['width']
    when "1", "2"
        uiComponent.xpath('color').each do |color|
            next unless color['key'] == 'backgroundColor'
            hexCode = get_hexcode(color)
            next unless hexCode
            tokenPath = get_token_keyPath(color['key'] )
            tokenValue = get_view_token(hexCode)
            add_token(doc, uiComponent, tokenPath, tokenValue)
        end
    end
end
Dir['**/*.{storyboard,xib}'].each do |xib|
    next if xib.match(/LaunchScreen.storyboard/) # skip launch
    next if xib.match(/watch/) || xib.match(/Pods/) # skip watch and pods
    doc = Nokogiri::XML(File.read(xib))
    #  puts xib
    # view
    doc.xpath('//view').each do |view|
        next if view.parent.name == 'viewController'
        update_uiComponent(doc, view, xib)
    end
   
    # label
    doc.xpath('//label').each do |view| 
        update_uiComponent(doc, view, xib)
    end
    File.write(xib, doc.to_xml(indent: 4, encoding: 'UTF-8'))
end
END {
    $view_colors.uniq.sort.each do |color| 
        write_to_file("Separator Bg- WrongColor - #{color}")
      #puts "View Bg- WrongColor - #{color}"
  end
}

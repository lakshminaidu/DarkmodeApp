require 'nokogiri'
require_relative 'shared'
$view_colors = []
BEGIN {

}

# returns colortoken for colorcode: Hex 8 digit
def get_view_token(colorCode)
    return unless colorCode
    return colorCode if $new_color_assets.include? colorCode
    if colorCode == '#3C3C431D' || colorCode == '#3C3C4349' || colorCode == '#3C3C4348' || colorCode == '#3C3C4319'
        return 'separator'
    end
    case colorCode[0,7] # removed alpha last two
    when '#FFFFFF', '#F0F0F0', '#F1F0F0', '#F1F1F1', '#F1F1F2', '#F2F2F2', '#F4F4F4', '#F5F5F5', '#F6F6F7', '#F9F9F9', '#FAFAFA', '#F8F8F8'  # white
      "containerBg"
#    when '#A59C94', '#A9ABAC', '#AAAAAA', '#AAACAD', '#979797' # white
#      "fillTertiary"
    when '#00F900'
        'successBg'
    when '#E9EAEA', '#F1F7F1', '#096EB7', '#FFCC00', '#AF52DE' #ignore special color
        # special colors
        return
    when '#000000'
       # clear colors
      return
    else
          $view_colors << colorCode
          puts "New BG Color Found: #{colorCode}"
        return
    end
 end
def get_text_color_token(colorCode)
    return unless colorCode
    return colorCode if $new_color_assets.include? colorCode
    # ignoring alpha
    case colorCode[0,7]
    when '#000000'
        'labelDefault'
    when '#FFFFFF'
        "labelWhite"
    when "#FF3830", "#FF5454", "#FF4454", "#FF5454", '#FF2600', '#FF3B30', '#FF0000'
        "labelPrimary"
    when '#C4A02E'
        # special color ignore
    else
        "Not matched labelColor -#{colorCode}"
        $label_colors << colorCode
        return
    end
end

# returns matching token Keypath for keyPath
def get_token_keyPath(keyPath) 
    return unless keyPath
    case keyPath
    when 'backgroundColor'
        "tkBgColor"
    when 'borderColor'
        "tkBorderColor"
    when 'textColor', 'titleColor'
         "tkTextColor"
    when 'tintColor'
        "tkTintColor"
    when 'onTintColor' # switch on color
        "tkOnTintColor"
    when 'placeHolderColor', 'placeholderColor' # textField placehoder
        "tkPlaceHolderColor"
    else
        puts "Unmatched keyPath: #{keyPath}"
        return
    end
end



def get_view_border_token(colorCode)
    return unless colorCode
    return colorCode if $new_color_assets.include? colorCode
    case colorCode[0,7]
    when '#979797', '#9B9B9B'
        "borderSecondary"
    else
        puts "New border color found: #{colorCode}"
        return
    end
end


def update_uiComponent(doc, uiComponent, xib)
    # puts File.basename(xib) # storyboard or xib
    userDefinedRuntimeAttributes = uiComponent.at_xpath('userDefinedRuntimeAttributes')
    if userDefinedRuntimeAttributes
        userDefinedRuntimeAttributes.search("userDefinedRuntimeAttribute").each do |userDefinedRuntimeAttribute|
            case userDefinedRuntimeAttribute['keyPath']
            when 'borderColor' # custom colors
                color = userDefinedRuntimeAttribute.search('color').first
                next unless color
                hexCode = get_hexcode(color)
                next unless hexCode
                tokenPath = get_token_keyPath(userDefinedRuntimeAttribute['keyPath'])
                tokenValue = get_view_border_token(hexCode)
                puts "#{uiComponent.name} - borderColor - : #{tokenValue}: #{hexCode}"
                add_token(doc, uiComponent, tokenPath, tokenValue)
            end
        end
    end
    uiComponent.xpath('color').each do |color|
     next unless color['key'] == 'backgroundColor'
     hexCode = get_hexcode(color)
     next unless hexCode
     tokenPath = get_token_keyPath(color['key'] )
     tokenValue = get_view_token(hexCode)
     puts "#{uiComponent.name} - background - : #{tokenValue}: #{hexCode}"
     add_token(doc, uiComponent, tokenPath, tokenValue)
    end
end
Dir['**/*.{storyboard,xib}'].each do |xib|
    
    next if xib.match(/LaunchScreen.storyboard/) # skip launch
#    next if xib.match(/Main.storyboard/) # skip Main
    next if xib.match(/watch/) || xib.match(/Pods/) # skip watch and pods
    doc = Nokogiri::XML(File.read(xib))
    #  puts xib
    # view
    doc.xpath('//view').each do |view|
        next if view.parent.name == 'viewController'
        update_uiComponent(doc, view, xib)
    end
    # CollectionViewCell
    doc.xpath('//collectionViewCell').each do |view|
        update_uiComponent(doc, view, xib)
    end
    # label
    doc.xpath('//label').each do |label|
        update_uiComponent(doc, label, xib)
        if label.search("nil[@key='textColor']").first
            add_token(doc, label, "tkTextColor", 'labelDefault')
        end
        unless label['customClass']
            # puts 'no custom class'
            color = label.search("color[@key='textColor']").first
            unless color
                # no color added
                add_token(doc, label, 'tkTextColor', 'labelDefault')
            else
               hexCode = get_hexcode(color)
               tokenValue = get_text_color_token(hexCode)
               puts "Label-textColor-#{tokenValue}:  #{hexCode}"
               add_token(doc, label, 'tkTextColor', tokenValue)
            end
        else
        puts label['customClass']
        end
    end
    # textField
    doc.xpath('//textField').each do |view| 
        update_uiComponent(doc, view, xib)
    end
     # textView
    doc.xpath('//textView').each do |view|
        update_uiComponent(doc, view, xib)
    end
     # tableViewCell
    doc.xpath('//tableViewCell').each do |view| 
        update_uiComponent(doc, view, xib)
    end
    #tableView
    doc.xpath('//tableView').each do |view| 
        update_uiComponent(doc, view, xib)
    end
     # tableViewCellContentView
    doc.xpath('//tableViewCellContentView').each do |view| 
         update_uiComponent(doc, view, xib)
    end
     # scrollView
    doc.xpath('//scrollView').each do |view| 
        update_uiComponent(doc, view, xib)
    end
     # collectionView
    doc.xpath('//collectionView').each do |view| 
        update_uiComponent(doc, view, xib)
    end
    doc.xpath('//button').each do |button|
        button.xpath("state").each do |state|
            buttonImage = state['image'] || state['backgroundImage']
            puts "Button State images #{buttonImage}"
            state.xpath('color').each do |color|
                hexCode = get_hexcode(color)
                next unless hexCode
                tokenPath = get_token_keyPath(color['key'])
                tokenValue = get_text_token(hexCode)
                puts "Button key #{color['key']} tokenPath #{tokenPath} value #{tokenValue} hexCode: #{hexCode}"
                add_token(doc, button, tokenPath, tokenValue)
            end
        end
    end
    doc.xpath('//imageView').each do |imageView|
        image = imageView['image']
        next unless image
        puts "imageView image #{image}"
    end
    # switchs
    doc.xpath('//switch').each do |switch|
#        add_token(doc, switch, 'tkTintColor', 'switchUnselected')
#        add_token(doc, switch, 'tkBgColor', 'switchUnselected')
        switch.xpath('color').each do |color|
            hexCode = get_hexcode(color)
            next unless hexCode
            tokenPath = get_token_keyPath(color['key'])
            tokenValue = nil
            case color['key']
            when 'onTintColor'
                tokenValue = 'switchSelected'
            when 'tintColor', 'backgroundColor'
                tokenValue = 'switchUnselected'
            end
            puts "#{switch.name}-#{color['key']}: #{hexCode}, #{tokenValue}"
            add_token(doc, switch, tokenPath, tokenValue)
        end
    end
    # TextField Search
    doc.xpath('//textField').each do |textField|
        check_input_component(doc, textField)
    end
    # TextView search
    doc.xpath('//textView').each do |textView|
        check_input_component(doc, textView)
    end
    # ViewController view
    doc.xpath('//viewController/view').each do |view|
        # puts "ViewController View"
        next unless view.parent.name == 'viewController'
        view.xpath("color").each do |color|
            next if color['name']
            next unless color['key'] == 'backgroundColor'
            hexCode = get_hexcode(color)
            next unless hexCode
            tokenValue = get_token_keyPath(color['key'])
            puts "AppBG: backgroundColor: #{tokenValue} #{hexCode}"
            add_token(doc, view, 'tkBgColor', tokenValue)
        end
    end
    File.write(xib, doc.to_xml(indent: 4, encoding: 'UTF-8'))
end
def check_input_component(doc, uiComponent)
    return unless uiComponent.search('color') #return if no colors
    uiComponent.xpath('color').each do |color|
        next unless color['key']
        next if color['key'] == 'backgroundColor'
        hexCode = get_hexcode(color)
        next unless hexCode
        tokenPath = get_token_keyPath(color['key'] )
        tokenValue = get_token_keyPath(hexCode)
        #  puts "#{uiComponent.name} key #{color['key']} tokenPath #{tokenPath} value #{tokenValue} hexCode: #{hexCode}"
        add_token(doc, uiComponent, tokenPath, tokenValue)
    end
end

END {
    $view_colors.uniq.sort.each do |color| 
        write_to_file("View Bg- WrongColor - #{color}")
      #puts "View Bg- WrongColor - #{color}"
  end
}

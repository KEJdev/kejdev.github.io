require 'nokogiri'

module Jekyll
  module ExtractFirstImageFilter
    def extract_first_image(input)
      if input.include? "img"
        doc = Nokogiri::HTML(input)
        img = doc.at_css('img')
        img ? img['src'] : nil
      else
        nil
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::ExtractFirstImageFilter)
require 'nokogiri'

module Jekyll
  module ExtractFirstImageFilter
    def extract_first_image(input)
      doc = Nokogiri::HTML(input)
      img = doc.css('img').first
      img.nil? ? "" : img['src']
    end
  end
end

Liquid::Template.register_filter(Jekyll::ExtractFirstImageFilter)
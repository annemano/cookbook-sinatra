require 'nokogiri'
require 'open-uri'

class ScrapeAllRecipesService
  def initialize(keyword)
    @keyword = keyword
    @html_file = URI.open("https://www.allrecipes.com/search/results/?search=#{@keyword}").read
    @doc = Nokogiri::HTML(@html_file)
  end

  def call
    @doc.search('.card__title').first(5).map { |element| element.text.strip }
  end

  def descriptions
    @doc.search('.card__summary').first(5).map { |element| element.text.strip }
  end

  def ratings
    @doc.search('.recipe-ratings').first(5).map do |element|
      match_data = element.text.strip.match(/\d{1}.\d?/)
      match_data[0].to_f
    end
  end

  def prep_time(index)
    recipe_urls = @doc.search('.card__detailsContainer .card__titleLink').first(5).map do |element|
      element.attribute("href").value
    end
    html_doc = Nokogiri::HTML(URI.open(recipe_urls[index]).read)
    match_data = html_doc.search('.recipe-meta-item-body').text.strip.match(/^\d+/)
    match_data[0]
  end
end

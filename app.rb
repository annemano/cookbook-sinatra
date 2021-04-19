require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "better_errors"
require_relative 'cookbook'
require_relative 'recipe'
require_relative 'scrape_all_recipes_service'
configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

cookbook = Cookbook.new(File.join(__dir__, 'recipes.csv'))

get '/' do
  @recipes = cookbook.all
  erb :index
end

get '/new' do
  erb :new
end

post '/recipes' do
  recipe = Recipe.new(params[:name], params[:description], params[:rating], params[:preptime])
  cookbook.add_recipe(recipe)
  redirect to('/')
end

get '/destroy/:id' do
  index = params["id"].to_i
  cookbook.remove_recipe(index)
  redirect to('/')
end

get '/done/:id' do
  index = params["id"].to_i
  cookbook.done(index)
  redirect to('/')
end

get '/import' do
  erb :import
end

post '/choose_recipe' do
  @ingredient = params[:ingredient]
  scrape = ScrapeAllRecipesService.new(@ingredient)
  @names = scrape.call
  erb :choose_recipe
end

get '/import_recipe/:id&:ingredient' do
  index = params["id"].to_i
  scrape = ScrapeAllRecipesService.new(params["ingredient"])
  prep_time = scrape.prep_time(index)
  recipe = Recipe.new(scrape.call[index], scrape.descriptions[index], scrape.ratings[index], prep_time)
  cookbook.add_recipe(recipe)
  redirect to('/')
end

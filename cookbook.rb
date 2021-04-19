require 'csv'
require_relative 'recipe'

class Cookbook
  def initialize(csv_file_path)
    @csv_file_path = csv_file_path
    @recipes = []
    # get recipes from csv
    load_csv
  end

  def all
    @recipes
  end

  def add_recipe(recipe)
    # adds a new recipe to the cookbook
    @recipes << recipe
    save_to_csv
  end

  def remove_recipe(recipe_index)
    # removes a recipe from the cookbook
    @recipes.delete_at(recipe_index)
    save_to_csv
  end

  def done(index)
    @recipes[index].done!
    save_to_csv
  end

  private

  def load_csv
    CSV.foreach(@csv_file_path) do |row|
      @recipes << Recipe.new(row[0], row[1], row[2], row[3], row[4] == "true")
    end
  end

  def save_to_csv
    csv_options = { col_sep: ',', force_quotes: true, quote_char: '"' }
    CSV.open(@csv_file_path, 'wb', csv_options) do |csv|
      @recipes.each do |recipe|
        csv << [recipe.name, recipe.description, recipe.rating, recipe.prep_time, recipe.done?]
      end
    end
  end
end

require "./lib/user_input.rb"

class BrowseController < ApplicationController
  def random
    id = "b3130393" # TODO: make this a random value
    from_item(id)
  end

  def from_item(id = nil)
    if id == nil
      id = UserInput::Cleaner.clean_id(params[:id])
    end
    if id.empty?
      return render status: 400, :text => "No item ID was provided"
    end
    render "index", locals: {id: id}, :layout => false
  end
end

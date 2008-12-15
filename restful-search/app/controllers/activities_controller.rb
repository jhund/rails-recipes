class ActivitiesController < ApplicationController

  def index
    @list_options = load_list_options
    @activities = Activity.filter(@list_options).paginate(:page => params[:page])
  end

private

  def load_list_options
    # define default list options here. They will be used if non are given via params
    options = {:sorted_by => 'most_recent'}
    # find relevant query parameters and override list options
    Activity.list_option_names.each do |name|
      options[name] = params[name] unless params[name].blank?
    end
    options
  end

end

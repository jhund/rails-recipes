class Activity < ActiveRecord::Base

  belongs_to :project

  named_scope :search, lambda{ |query|
      q = "%#{query.downcase}%"
      { :conditions => ['lower(activities.description) LIKE ?', q] } }
  named_scope :for_project, lambda { |project_ids|
      { :conditions => ['activities.project_id IN (?)', *project_ids.to_a] } }
  named_scope :with_activity_type, lambda { |activity_type_ids|
      { :conditions => ['activities.activity_type_id IN (?)', *activity_type_ids.to_a] } }
  # don't call the below 'sort_by'. There seems to be some naming conflict
  named_scope :sorted_by, lambda { |sort_option|
      case sort_option.to_s
      when 'most_recent'
        { :order => 'activities.created_at DESC' }
      when 'client_project_name_a_to_z'
        { :order => 'lower(clients.name) ASC, lower(projects.name) ASC', :joins => {:project => :client}}
      when 'duration_shortest_first'
        { :order => 'activities.duration ASC' }
      when 'duration_longest_first'
        { :order => 'activities.duration DESC' }
      else
        raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
      end }
  
  # applies list options to retrieve matching records from database
  def self.filter(list_options)
    raise(ArgumentError, "Expected Hash, got #{list_options.inspect}") unless list_options.is_a?(Hash)
    # compose all filters on AR Proxy
    ar_proxy = Activity
    list_options.each do |key, value|
      next unless self.list_option_names.include?(key) # only consider the list options
      next if value.blank? # ignore blank list options
      ar_proxy = ar_proxy.send(key, value) # compose this option
    end
    ar_proxy # return the ActiveRecord proxy object
  end
  
  # returns array of valid list option names
  def self.list_option_names
    self.scopes.map{|s| s.first} - [:named_scope_that_is_not_a_list_option]
  end
  
end

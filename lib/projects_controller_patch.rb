require_dependency 'projects_controller'

module ProjectsControllerPatch

  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      before_filter :calculate_custom_fields, :only => :index
    end

  end
  
  module InstanceMethods

    def calculate_custom_fields
      @custom_fields = CustomField.used_for_project_filtering
    end

  end


end

ProjectsController.send(:include, ProjectsControllerPatch)

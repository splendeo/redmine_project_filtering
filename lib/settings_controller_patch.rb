require_dependency 'settings_controller'

module SettingsControllerPatch

  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      before_filter :calculate_custom_fields_usable_for_project_filtering, :only => :plugin
    end

  end

  module InstanceMethods
  
    def calculate_custom_fields_usable_for_project_filtering
      if params[:id] == 'redmine_project_filtering'
        @project_custom_fields = CustomField.usable_for_project_filtering
      end
    end

  end

end

SettingsController.send(:include, SettingsControllerPatch)

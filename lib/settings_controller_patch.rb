require_dependency 'settings_controller'

module SettingsControllerPatch

  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      before_filter :calculate_project_custom_fields, :only => :plugin
    end

  end

  module InstanceMethods
  
    def calculate_project_custom_fields
      if params[:id] == 'redmine_project_filtering'
        @project_custom_fields = CustomField.all(
          :conditions => [ 
            "custom_fields.type = 'ProjectCustomField' AND " +
            "( custom_fields.field_format IN (?) OR " +
            "  ( custom_fields.field_format IN (?) AND custom_fields.searchable = ? ) " +
            ")",
            ['bool', 'date'],
            ['string', 'text', 'list'],
            true
          ],
          :order => 'custom_fields.position ASC'
        )
      end
    end

  end

end

SettingsController.send(:include, SettingsControllerPatch)

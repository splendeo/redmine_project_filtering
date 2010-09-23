require_dependency 'custom_field'

module CustomFieldPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
    
    base.class_eval do      
      named_scope( :used_for_project_filtering, lambda do |*args|
        used_fields = Setting[:plugin_redmine_project_filtering][:project_filtering_used_fields].keys.collect(&:to_i)
        { :conditions  => [ "custom_fields.type = 'ProjectCustomField' 
                             AND custom_fields.field_format = 'list' 
                             AND custom_fields.id IN (?)", used_fields]}
      end)
      
      after_create :configure_use_in_project_filtering
      
    end
  end
  
  module InstanceMethods
  
    def configure_use_in_project_filtering
      if(self.type == 'ProjectCustomField' and field_format=='list')
        value = Setting[:plugin_redmine_project_filtering][:project_filtering_used_fields]
        value[self.id.to_s] = "1"
        Setting[:plugin_redmine_project_filtering] = { :project_filtering_used_fields => value }
      end
    end
  
  end
end

CustomField.send(:include, CustomFieldPatch)

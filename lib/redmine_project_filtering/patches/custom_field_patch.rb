module RedmineProjectFiltering

  module Patches

    module CustomFieldPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        
        base.class_eval do
          unloadable
          named_scope( :used_for_project_filtering, lambda do |*args|
            plugin_settings = Setting['plugin_redmine_project_filtering']
            used_field_setting = Setting['plugin_redmine_project_filtering'].present? ? plugin_settings['used_fields'] : {}
            used_field_hash = used_field_setting.class == Hash ? used_field_setting : {}
            used_fields = used_field_hash.keys.collect(&:to_i)
            { :conditions  => [ "custom_fields.type = 'ProjectCustomField' 
                                 AND custom_fields.field_format = 'list' 
                                 AND custom_fields.id IN (?)", used_fields ] }
          end)
          
          named_scope( :usable_for_project_filtering, {
            :conditions => { 
              :type => 'ProjectCustomField',
              :field_format => 'list'
            },
            :order => 'custom_fields.position ASC'
          })
          
          after_create :configure_use_in_project_filtering
          
        end
      end
      
      module InstanceMethods
      
        def configure_use_in_project_filtering
          if(self.type == 'ProjectCustomField' and field_format=='list')
            plugin_settings = Setting[:plugin_redmine_project_filtering]
            plugin_settings[:used_fields] ||= {}
            plugin_settings[:used_fields][self.id.to_s] = "1"
            Setting[:plugin_redmine_project_filtering] = plugin_settings
          end
        end
      
      end
    end
  end
end

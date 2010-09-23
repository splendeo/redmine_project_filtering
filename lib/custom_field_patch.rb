require_dependency 'custom_field'

module CustomFieldPatch
  def self.included(base) # :nodoc:
    base.class_eval do
    
      named_scope(:used_for_project_filtering, lambda do |*args|
        used_fields = Setting[:plugin_redmine_project_filtering]['project_filtering_used_fields']
        {:conditions => ['custom_fields.id IN (?)', used_fields.keys.collect(&:to_i)]}
      end)
    
    end
  end
end

CustomField.send(:include, CustomFieldPatch)

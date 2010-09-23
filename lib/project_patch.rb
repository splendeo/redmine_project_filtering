require_dependency 'project'

module ProjectPatch

  def self.included(base) # :nodoc:
    base.send(:include, WithCustomValues)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def custom_fields_used_for_project_filtering
      Setting['project_filtering_used_fields'].keys
    end
  end
  

end

Project.send(:include, ProjectPatch)

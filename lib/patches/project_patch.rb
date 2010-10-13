require_dependency 'project'

module ProjectPatch

  def self.included(base) # :nodoc:
    base.send(:include, WithCustomValues)
    
    base.class_eval do
      named_scope :roots, { :conditions => "projects.parent_id IS NULL" }
    end
  end

end

Project.send(:include, ProjectPatch)

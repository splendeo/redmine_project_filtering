require_dependency 'project'

module ProjectPatch

  def self.included(base) # :nodoc:
    base.send(:include, WithCustomValues)
  end

end

Project.send(:include, ProjectPatch)

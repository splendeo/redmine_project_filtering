require_dependency 'projects_helper'

module ProjectsHelperPatch

  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods

    # Renders a tree of projects as a nested set of unordered lists
    # The given collection may be a subset of the whole project tree
    # (eg. some intermediate nodes are private and can not be seen)
    def render_project_hierarchy_with_filtering(projects)
      s = []
      if projects.any?
        ancestors = []
        original_project = @project
        projects.each do |project|
          # set the project environment to please macros.
          @project = project
          if (ancestors.empty? || project.is_descendant_of?(ancestors.last))
            s << "<ul class='projects #{ ancestors.empty? ? 'root' : nil}'>"
          else
            ancestors.pop
            s << "</li>"
            while (ancestors.any? && !project.is_descendant_of?(ancestors.last)) 
              ancestors.pop
              s << "</ul></li>"
            end
          end
          classes = (ancestors.empty? ? 'root' : 'child')
          s << "<li class='#{classes}'><div class='#{classes}'>" +
                 link_to_project(project, {}, :class => "project #{User.current.member_of?(project) ? 'my-project' : nil}")
          s << "<ul class='filter_fields'>"
          CustomField.used_for_project_filtering.each do |field|
            value_model = project.custom_value_for(field.id)
            value = value_model.present? ? value_model.value : nil
            s << "<li><b>#{field.name.humanize}:</b> #{value}</li>" if value.present?
          end
          s << "</ul>"
          s << "<div class='clear'></div>"
          unless project.description.blank?
            s << "<div class='wiki description'>"
            s << "<b>#{ t(:field_description) }:</b>"
            s << textilizable(project.short_description, :project => project)
            s << "\n</div>"
          end
          s << "</div>"
          ancestors << project
        end
        ancestors.size.times{ s << "</li></ul>" }
        @project = original_project
      end
      s.join "\n"
    end
  
  end
end

ProjectsHelper.send(:include, ProjectsHelperPatch)


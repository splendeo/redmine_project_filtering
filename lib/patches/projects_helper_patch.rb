require_dependency 'projects_helper'

module ProjectsHelperPatch

  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    # Renders a tree of projects as a nested set of unordered lists
    # The given collection may be a subset of the whole project tree
    # (eg. some intermediate nodes are private and can not be seen)
    def render_project_hierarchy_with_filtering(projects,custom_fields,question)
      s = []
      if projects.any?
        tokens = calculate_tokens(custom_fields, question)
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
            link_to( highlight_tokens(project.name, tokens), 
              {:controller => 'projects', :action => 'show', :id => project},
              :class => "project #{User.current.member_of?(project) ? 'my-project' : nil}"
            )
          s << "<ul class='filter_fields'>"
          CustomField.usable_for_project_filtering.each do |field|
            value_model = project.custom_value_for(field.id)
            value = value_model.present? ? value_model.value : nil
            s << "<li><b>#{field.name.humanize}:</b> #{highlight_tokens(value, tokens)}</li>" if value.present?
          end
          s << "</ul>"
          s << "<div class='clear'></div>"
          unless project.description.blank?
            s << "<div class='wiki description'>"
            s << "<b>#{ t(:field_description) }:</b>"
            s << highlight_tokens(textilizable(project.short_description, :project => project), tokens)
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
    
    private
    
    def calculate_tokens(custom_fields, question)
      list = custom_fields.values
      list << question if question.present?

      tokens = list.join(' ').scan(%r{((\s|^)"[\s\w]+"(\s|$)|\S+)}).collect {|m| m.first.gsub(%r{(^\s*"\s*|\s*"\s*$)}, '')}
      # tokens must be at least 2 characters long
      tokens.select {|w| w.length > 1 }
    end
    
    # copied from search_helper. But it doesn't escape 
    def highlight_tokens(text, tokens)
      return text unless text && tokens && !tokens.empty?
      re_tokens = tokens.collect {|t| Regexp.escape(t)}
      regexp = Regexp.new "(#{re_tokens.join('|')})", Regexp::IGNORECASE    
      result = ''
      text.split(regexp).each_with_index do |words, i|
        if result.length > 1200
          # maximum length of the preview reached
          result << '...'
          break
        end
        words = words.mb_chars
        if i.even?
          result << (words.length > 100 ? "#{words.slice(0..44)} ... #{words.slice(-45..-1)}" : words)
        else
          t = (tokens.index(words.downcase) || 0) % 4
          result << content_tag('span', words, :class => "highlight token-#{t}")
        end
      end
      result
    end
  
  end
end

ProjectsHelper.send(:include, ProjectsHelperPatch)


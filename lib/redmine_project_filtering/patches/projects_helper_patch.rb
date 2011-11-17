module RedmineProjectFiltering
  module Patches
    module ProjectsHelperPatch

      def self.included(base) # :nodoc:
        base.class_eval do
          unloadable
          # Renders a tree of projects as a nested set of unordered lists
          # The given collection may be a subset of the whole project tree
          # (eg. some intermediate nodes are private and can not be seen)
          def render_project_hierarchy_with_filtering(projects,custom_fields,question)
            s = []
            if projects.any?
              tokens = RedmineProjectFiltering.calculate_tokens(question, custom_fields)
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
                if @project.respond_to? :license and @project.license.present? then
                  s << "<li><b>#{t(:label_license)}:</b> #{link_to_license_version(@project.license) }</li>"
                end
                CustomField.usable_for_project_filtering.each do |field|
                  value_model = project.custom_value_for(field.id)
                  value = value_model.present? ? value_model.value : nil
                  s << "<li><b>#{field.name.humanize}:</b> #{highlight_tokens(value, tokens)}</li>" if value.present?
                end
                s << "</ul>"
                s << "<div class='clear'></div>"
                unless project.description.blank?
                  s << "<div class='wiki description'>"
                  s << highlight_tokens(textilizable(project.short_description(30), :project => project), tokens)
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

          # copied from search_helper. This one doesn't escape html or limit the text length
          def highlight_tokens(text, tokens)
            return text unless text && tokens && !tokens.empty?
            re_tokens = tokens.collect {|t| Regexp.escape(t)}
            regexp = Regexp.new "(#{re_tokens.join('|')})", Regexp::IGNORECASE
            result = ''
            text.split(regexp).each_with_index do |words, i|
              words = words.mb_chars
              if i.even?
                result << words
              else
                t = (tokens.index(words.downcase) || 0) % 4
                result << content_tag('span', words, :class => "highlight token-#{t}")
              end
            end
            result
          end

          def license_plugin_detected?
            Module.const_get('License') && true rescue false
          end


        end
      end

    end
  end
end


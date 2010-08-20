require 'redmine'

=begin
require 'redmine_sympa/hooks/project_hooks'

require 'dispatcher'
Dispatcher.to_prepare :redmine_sympa do
  require_dependency 'project'
  require_dependency 'enabled_module'

  Project.send(:include, RedmineSympa::Patches::ProjectPatch)
  EnabledModule.send(:include, RedmineSympa::Patches::EnabledModulePatch)

end
=end

Redmine::Plugin.register :redmine_project_filtering do
  name 'Redmine Project filtering plugin'
  author 'Enrique García Cota'
  description 'Adds filtering capabilities to the the project/index page'
  version '0.0.1'

  settings({
    :partial => 'settings/redmine_project_filtering',
    :default => {
      # 'redmine_project_filtering_blah' => 'blah'
    }
  })

end

require 'redmine'

Dispatcher.to_prepare :featured_projects do

  require_dependency 'redmine_project_filtering/with_custom_values'

  require_dependency 'projects_helper'
  ProjectsHelper.send(:include, RedmineProjectFiltering::Patches::ProjectsHelperPatch)
  
  require_dependency 'custom_field'
  CustomField.send(:include, RedmineProjectFiltering::Patches::CustomFieldPatch)
  
  require_dependency 'project'
  Project.send(:include, RedmineProjectFiltering::Patches::ProjectPatch)
  
  require_dependency 'projects_controller'
  ProjectsController.send(:include, RedmineProjectFiltering::Patches::ProjectsControllerPatch)
  
  require_dependency 'settings_controller'
  SettingsController.send(:include, RedmineProjectFiltering::Patches::SettingsControllerPatch)

end

# will not work on development mode

Redmine::Plugin.register :redmine_project_filtering do
  name 'Redmine Project filtering plugin'
  author 'Enrique García Cota'
  url 'http://development.splendeo.es/projects/redm-project-filter'
  author_url 'http://www.splendeo.es'
  description 'Adds filtering capabilities to the the project/index page'
  version '0.9'

  settings({
    :partial => 'settings/redmine_project_filtering',
    :default => { 'used_fields' => {} }
  })

end

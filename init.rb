# encoding: utf-8

Rails.logger.info 'Starting Project Filter Plugin for Redmine'

require 'redmine'
if Rails::VERSION::MAJOR < 3
  require 'dispatcher'
  object_to_prepare = Dispatcher
else
  object_to_prepare = Rails.configuration
  # if redmine plugins were railties:
  # object_to_prepare = config
end

object_to_prepare.to_prepare do

  require_dependency 'redmine_project_filtering'
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
  author 'Enrique García Cota, Francisco de Juan'
  url 'https://github.com/splendeo/redmine_project_filtering'
  author_url 'http://www.splendeo.es'
  description 'Adds filtering capabilities to the the project/index page'
  version '0.9.6'

  settings :default => {'used_fields' => {}}, :partial => 'settings/redmine_project_filtering'

end

require 'redmine'


# will not work on development mode
require 'settings_controller_patch'
require 'with_custom_values'
require 'project_patch'


Redmine::Plugin.register :redmine_project_filtering do
  name 'Redmine Project filtering plugin'
  author 'Enrique García Cota'
  description 'Adds filtering capabilities to the the project/index page'
  version '0.0.1'

  settings({
    :partial => 'settings/redmine_project_filtering',
    :default => {
      'project_filtering_used_fields' => {}
    }
  })

end

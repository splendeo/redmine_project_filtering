require 'redmine'


# will not work on development mode
require 'settings_controller_patch'
require 'with_custom_values'
require 'project_patch'
require 'custom_field_patch'
require 'projects_controller_patch'


Redmine::Plugin.register :redmine_project_filtering do
  name 'Redmine Project filtering plugin'
  author 'Enrique García Cota'
  description 'Adds filtering capabilities to the the project/index page'
  version '0.0.1'

  settings({
    :partial => 'settings/redmine_project_filtering',
    :default => {
      'used_fields' => {},
      'css' => "
#project_filtering label { display: block; }
#project_filtering p { float: left; }
#project_filtering p.q { width: 30em; }
#project_filtering p.custom_field { width: 10em; }
#project_filtering p.buttons { clear: both; with: 100%; float: none; }
"
    }
  })

end

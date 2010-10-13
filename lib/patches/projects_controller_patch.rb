require_dependency 'projects_controller'

module ProjectsControllerPatch

  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      before_filter :calculate_custom_fields, :only => :index
      before_filter :calculate_project_filtering_settings, :only => :index
      alias_method_chain :index, :project_filtering
    end

  end
  
  module InstanceMethods

    def calculate_custom_fields
      @custom_fields_used_for_project_filtering = CustomField.used_for_project_filtering
    end
    
    def calculate_project_filtering_settings
      @project_filtering_settings = Setting[:plugin_redmine_project_filtering]
    end
    
    def index_with_project_filtering
      respond_to do |format|
        format.any(:html, :xml) { 
          calculate_filtered_projects
        }
        format.js {
          calculate_filtered_projects
          render :update do |page|
            page.replace_html 'projects', render_project_hierarchy_with_filtering(@projects, @custom_fields, @question)
          end
        }
        format.atom {
          projects = Project.visible.find(:all, :order => 'created_on DESC',
                                                :limit => Setting.feeds_limit.to_i)
          render_feed(projects, :title => "#{Setting.app_title}: #{l(:label_project_latest)}")
        }
      end
    end
    
    private
    
    def calculate_filtered_projects
      @projects = Project.visible
      
      @custom_fields = params[:custom_fields] || {}

      unless @custom_fields.empty?
        @projects = @projects.with_custom_values(params[:custom_fields])
      end

      @question = params[:q]
      if @question.present? and @question.length > 1
        @projects = @projects.search(params[:q]).first.sort_by(&:lft)
      else
        @projects = @projects.all(:order => 'lft')
      end
    end

  end


end

ProjectsController.send(:include, ProjectsControllerPatch)

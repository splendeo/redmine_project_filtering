require 'ostruct'

module RedmineProjectFiltering
  module Patches
    module ProjectsControllerPatch

      def self.included(base) # :nodoc:
        base.class_eval do
          unloadable
          before_filter :calculate_custom_fields, :only => :index
          before_filter :calculate_project_filtering_settings, :only => :index
          alias_method_chain :index, :project_filtering

          if (Module.const_get('License') && true rescue false)
            helper :LicenseVersions
            extend LicenseVersionsHelper
          end
        end
      end


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
              page.replace_html 'projects', :partial => 'filtered_projects'
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

        @question = (params[:q] || "").strip
        @custom_fields = params[:custom_fields] || {}
        @license_version_id = params[:license_version_id]

        @projects = Project.visible

        if license_plugin_detected?
          nil_license_version = OpenStruct.new(:id => "", :title => "")
          nil_license_version.instance_eval('undef id')
          @license_versions = [nil_license_version] + LicenseVersion.for_select.all
          @projects = @projects.with_license_id(@license_version_id) if @license_version_id.present?
        end

        unless @custom_fields.empty?
          @projects = @projects.with_custom_values(params[:custom_fields])
        end

        @featured_projects = @projects.featured if Project.respond_to? :featured

        @projects = @projects.search_by_question(@question)
        @featured_projects = @featured_projects.search_by_question(@question) if @featured_projects

      end

      def license_plugin_detected?
        Module.const_get('License') && true rescue false
      end


    end
  end
end

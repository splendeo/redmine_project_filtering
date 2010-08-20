class SettingsController < ApplicationController
  before_filter :calculate_project_custom_fields, :only => :plugin
  
  private
  
  def calculate_project_custom_fields
    if params[:id] == 'redmine_project_filtering'
      @project_custom_fields = CustomField.all(
        :conditions => [ 
          "custom_fields.type = 'ProjectCustomField' AND " +
          "( custom_fields.field_format IN (?) OR " +
          "  ( custom_fields.field_format IN (?) AND custom_fields.searchable = ? ) " +
          ")",
          ['bool', 'date'],
          ['string', 'text', 'list'],
          true
        ],
        :order => 'custom_fields.position ASC'
      )
    end
  end


end

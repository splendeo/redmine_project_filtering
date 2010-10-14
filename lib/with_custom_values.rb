# adds a with_custom_values named scope to the model it is included in

module WithCustomValues

  def self.included(base) # :nodoc:

    base.class_eval do
      named_scope( :with_custom_values,
        lambda do |*args|
          fields = args.first
          
          strings = []
          values = []
          joins = []
          
          fields.each do|key, value|
            if(value.present?)
              table_name = "custom_values_filtering_on_#{key}"
              strings << "(#{table_name}.custom_field_id = ? AND #{table_name}.value = ?)"
              values << key.to_i
              values << value
              joins << "left join custom_values #{table_name} on #{table_name}.customized_id = #{base.table_name}.id"
            end
          end
        
          if strings.length == 0
            { :conditions => true }
          else
            { :joins => joins.join(' '), 
              :conditions => [strings.join(' AND '), *values]
            }
        end
      )

    end

  end

end

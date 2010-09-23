# adds a with_custom_values named scope to the model it is included in

module WithCustomValues

  def self.included(base) # :nodoc:

    base.class_eval do
      named_scope( :with_custom_values,
        lambda do |*args|
          fields = args.first
          
          strings = []
          values = []
          
          fields.each do|key, value|
            strings << "(custom_values.custom_field_id = ? AND custom_values.value = ?)"
            values << key
            values << value
          end
        
          { :include => :custom_values, 
            :conditions => [strings.join(' AND '), *values]
          }
        end
      )

    end

  end

end

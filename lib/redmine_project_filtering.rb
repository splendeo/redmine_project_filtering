module RedmineProjectFiltering

  # transforms a question and a list of custom fields into something that Project.search can process
  def self.calculate_tokens(question, custom_fields=nil)
    list = []
    list << custom_fields.values if custom_fields.present?
    list << question if question.present?

    tokens = list.join(' ').scan(%r{((\s|^)"[\s\w]+"(\s|$)|\S+)})
    tokens = tokens.collect{ |m| m.first.gsub(%r{(^\s*"\s*|\s*"\s*$)}, '') }
    
    # tokens must be at least 2 characters long
    tokens.select {|w| w.length > 1 }
  end

end

module MarcDisplay

	def marc_display_field(name)
		return nil unless self.respond_to?(:to_marc)
    marc = self.to_marc
    return marc.subjects
	  #Return an empty array if method doesn't exist.
	  begin
	    marc.send(name)
	  rescue NoMethodError
	    nil
	  end
	end

	def marc_subjects
	  self.to_marc.subjects
	end

	#Can be a tag or array of tag numbers.
	def marc_tag(number)
	  self.to_marc.by_tag(number)
	end

end
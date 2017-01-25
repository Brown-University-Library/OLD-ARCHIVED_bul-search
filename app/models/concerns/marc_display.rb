#Handle local display logic for show pages based
#on MARC records
module MarcDisplay

	def marc_display_field(name)
		return nil unless self.respond_to?(:to_marc)
		marc = self.to_marc
		#Return an empty array if method doesn't exist.
		begin
			marc.send(name)
		rescue NoMethodError
			nil
		end
	end

	def marc_subjects
		if self.respond_to?(:to_marc)
			return self.to_marc.subjects
		elsif self["subject_t"] != nil
			# TODO: implement a better way to handle BDR subjects
			return self["subject_t"]
		end
		return []
	end

	#Can be a tag or array of tag numbers.
	def marc_tag(number, exclude=[])
		return nil unless self.respond_to?(:to_marc)
	  self.to_marc.by_tag(number, options={exclude: exclude})
	end

	#Notes
	def marc_note(number, options={})
		return nil unless self.respond_to?(:to_marc)
		if options.empty?
			self.to_marc.get_note(number)
	  else
	  	self.to_marc.get_note(number, options=options)
	  end
	end

end

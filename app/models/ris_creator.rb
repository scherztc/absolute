# 
# Export one of the Digital Case items in RIS format, as a file
# to import into EndNote etc, or in a callback for Refworks export etc.
#
# RISCreator.new( item ).export
#
# Note: We assume input and output in UTF8. The RIS spec kind of says
# it has to be ascii only, but most actual software seems to be able to do
# UTF8.
#
# Best spec/docs for RIS format seems to be at
# http://www.refman.com/support/risformat_intro.asp
# Download zip file there, pay attention to excel spreadsheet
# as well as PDF overview. 
#
# This RISCreator is based on the one found here: 
# https://github.com/jrochkind/bento_search/blob/master/app/models/bento_search/ris_creator.rb
# But it has been adapted to handle the Digital Case collection items rather than
# the BentoSearch::ResultItem.
class RISCreator 
	def initialize(i)
		# 'i' is the Text object that is returned by ActiveFedora::Base.find('pid').
		@item = i
<<<<<<< HEAD

		#TODO The type method for @item is returning this error:
		# 'Tried to fetch `type' from solr, but it isn't indexed.'
		# @ris_format = translate_ris_format
=======
		@ris_format = translate_ris_format
>>>>>>> c5cbd31... Started on the spec file to test the RISCreator and also cleaned out some of the sections of the RISCreator that were commented out from the bentosearch.  In the spec, Im attempting to create a test GenericWork to then run the export on and test the output with line by line comparison.
	end

	def export
		out = "".force_encoding("UTF-8")
		#out << tag_format("TY", @ris_format)

<<<<<<< HEAD
		id = @item.to_param
		out << tag_format("ID", id)
=======
		# @item.to_param returns an id that always starts with "ksl:"
		# For the RIS citation we want to remove that, though, and only return the pid.		
		id = @item.id.to_s.split ":"
		out << tag_format("ID", id[1])
>>>>>>> 0457a3b... ris_creator_spec works and runs three different tests, though the conditions are very similar in most possible calls to the ris_creator. I also cleaned out ris_creator, removing some methods and comments that werent being used or giving important information.

<<<<<<< HEAD
		out << tag_format("TI", @item.title)		
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> c375d0c... Started on the spec file to test the RISCreator and also cleaned out some of the sections of the RISCreator that were commented out from the bentosearch.  In the spec, Im attempting to create a test GenericWork to then run the export on and test the output with line by line comparison.
=======
		# @item.title returns something like  ["Title of this item"]
		# So to remove the surrounding pairs of quotes and brackets using split
		title = @item.title.to_s.split "\""
<<<<<<< HEAD
<<<<<<< HEAD
		out << tag_format("TI", title[1])		
>>>>>>> c5cbd31... Started on the spec file to test the RISCreator and also cleaned out some of the sections of the RISCreator that were commented out from the bentosearch.  In the spec, Im attempting to create a test GenericWork to then run the export on and test the output with line by line comparison.
=======
		out << tag_format("TI", title[1])
		
>>>>>>> 0457a3b... ris_creator_spec works and runs three different tests, though the conditions are very similar in most possible calls to the ris_creator. I also cleaned out ris_creator, removing some methods and comments that werent being used or giving important information.
>>>>>>> a0e8b9a... ris_creator_spec works and runs three different tests, though the conditions are very similar in most possible calls to the ris_creator. I also cleaned out ris_creator, removing some methods and comments that werent being used or giving important information.
=======
		out << tag_format("TI", title[1])		
>>>>>>> c5cbd31... Started on the spec file to test the RISCreator and also cleaned out some of the sections of the RISCreator that were commented out from the bentosearch.  In the spec, Im attempting to create a test GenericWork to then run the export on and test the output with line by line comparison.
>>>>>>> c375d0c... Started on the spec file to test the RISCreator and also cleaned out some of the sections of the RISCreator that were commented out from the bentosearch.  In the spec, Im attempting to create a test GenericWork to then run the export on and test the output with line by line comparison.
		@item.creator.each do |author|		
			out << tag_format("AU", author)
		end
		@item.contributor.each do |author|
			out << tag_format("AU", author)
		end
<<<<<<< HEAD
			#out << tag_format("PY", @item.year)
			# We have the date rather than just the year
		out << tag_format("DA", @item.date)
		#out << tag_format("LA", @item.language)

			# We do not have methods to find any of the following
			#out << tag_format("VL", @item.volume)
			#out << tag_format("IS", @item.issue)
			#out << tag_format("SP", @item.start_page)
			#out << tag_format("EP", @item.end_page)
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
		date = @item.date.to_s.split "\""
		out << tag_format("DA", date[1])
<<<<<<< HEAD
>>>>>>> c5cbd31... Started on the spec file to test the RISCreator and also cleaned out some of the sections of the RISCreator that were commented out from the bentosearch.  In the spec, Im attempting to create a test GenericWork to then run the export on and test the output with line by line comparison.
>>>>>>> a0e8b9a... ris_creator_spec works and runs three different tests, though the conditions are very similar in most possible calls to the ris_creator. I also cleaned out ris_creator, removing some methods and comments that werent being used or giving important information.
=======
=======
		date = @item.date.to_s.split "\""
		out << tag_format("DA", date[1])
>>>>>>> c5cbd31... Started on the spec file to test the RISCreator and also cleaned out some of the sections of the RISCreator that were commented out from the bentosearch.  In the spec, Im attempting to create a test GenericWork to then run the export on and test the output with line by line comparison.
>>>>>>> c375d0c... Started on the spec file to test the RISCreator and also cleaned out some of the sections of the RISCreator that were commented out from the bentosearch.  In the spec, Im attempting to create a test GenericWork to then run the export on and test the output with line by line comparison.
		
		#TODO The source method is also returning the index error:
		# 'Tried to fetch `source' from solr, but it isn't indexed.'	
		# @item.source.each do |source_title|		
			# out << tag_format("T2", source_title)
		# end
	
		out << tag_format("PB", @item.publisher)
		out << tag_format("AB", @item.description)
=======
	
		pub = @item.publisher.to_s.split "\""
		out << tag_format("PB", pub[1])

		desc = @item.description.to_s.split "\""
		out << tag_format("AB", desc[1])

>>>>>>> 0457a3b... ris_creator_spec works and runs three different tests, though the conditions are very similar in most possible calls to the ris_creator. I also cleaned out ris_creator, removing some methods and comments that werent being used or giving important information.
		@item.subject.each do |kw|
			out << tag_format("KW", kw)
		end

		relation = @item.relation.to_s.split"\""		
		out << tag_format("LB", relation[1])	
		# include main link and any other links?
<<<<<<< HEAD
		out << tag_format("UR", @item.identifier)
		# @item.linked_resource_urls.each do |link|
			# out << tag_format("UR", link.url)
		# end
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
		url = @item.identifier.to_s.split "\""
		out << tag_format("UR", url[1])
<<<<<<< HEAD
>>>>>>> c5cbd31... Started on the spec file to test the RISCreator and also cleaned out some of the sections of the RISCreator that were commented out from the bentosearch.  In the spec, Im attempting to create a test GenericWork to then run the export on and test the output with line by line comparison.
>>>>>>> a0e8b9a... ris_creator_spec works and runs three different tests, though the conditions are very similar in most possible calls to the ris_creator. I also cleaned out ris_creator, removing some methods and comments that werent being used or giving important information.
=======
=======
		url = @item.identifier.to_s.split "\""
		out << tag_format("UR", url[1])
>>>>>>> c5cbd31... Started on the spec file to test the RISCreator and also cleaned out some of the sections of the RISCreator that were commented out from the bentosearch.  In the spec, Im attempting to create a test GenericWork to then run the export on and test the output with line by line comparison.
>>>>>>> c375d0c... Started on the spec file to test the RISCreator and also cleaned out some of the sections of the RISCreator that were commented out from the bentosearch.  In the spec, Im attempting to create a test GenericWork to then run the export on and test the output with line by line comparison.
		# end with blank lines, so multiple ones can be concatenated for
		# a file.
=======
		# end with blank lines, so multiple ones can be concatenated for a file.
>>>>>>> 0457a3b... ris_creator_spec works and runs three different tests, though the conditions are very similar in most possible calls to the ris_creator. I also cleaned out ris_creator, removing some methods and comments that werent being used or giving important information.
		out << "\r\nER - \r\n\r\n"
	end

	@@format_map = {
		# bento_search doesn't distinguish between journal, magazine, and newspaper,
		# RIS does, sorry, we map all to journal article.
		"Article" => "JOUR",
		"Book" => "BOOK",
		"Movie" => "MPCT",
		"MusicRecording" => "MUSIC",
		#"Photograph" => "GEN",
		"SoftwareApplication" => "COMP",
		"WebPage" => "ELEC",
		"VideoObject" => "VIDEO",
		"AudioObject" => "SOUND",
		
		# Worth noting that right now everything in the old Digital Case was returning
		# 'text' as 'BOOK's.  We might want to fix this for the future.
		"poster" => "SLIDE",
		"text" => "BOOK", 
		
		:serial => "SER",
		:dissertation => "THES",
		:conference_paper => "CPAPER",
		:conference_proceedings => "CONF",
		:report => "RPRT",
		:book_item => "CHAP"
	}

	# based on current @item.format, output
	# appropriate RIS format string
	 def translate_ris_format
		 # default "GEN"=generic if unknown
		 @@format_map[@item.type] || "GEN"
	 end

	# Formats refworks tag/value line and returns it.
	#
	# Returns empty string if you pass in an empty value though.
	#
	# "Each six-character tag must be in the following format:
	# "<upper-case letter><upper-case letter or number><space><space><dash><space>"
	#
	# "Each tag and its contents must be on a separate line,
	# preceded by a "carriage return/line feed" (ANSI 13 10)."
	#
	# "Note, however, that the asterisk (character 42)
	# is not allowed in the author, keywords or periodical name fields."
	def tag_format(tag, value)
		return "" if value.blank?
		raise ArgumentError.new("Illegal RIS tag") unless tag =~ /[A-Z][A-Z0-9]/
		# "T2" seems to be the only "journal name field", which is
		# mentioned along with these others as not being allowed to contain
		# asterisk.
		if ["AU", "A2", "A3", "A4", "KW", "T2"].include? tag
			value = value.gsub("*", " ")
		end
		return "\r\n#{tag} - #{value}"
	end

<<<<<<< HEAD
	# Take a ruby Date and translate to RIS date format
	# "YYYY/MM/DD/other info"
	#
	# returns nil if input is nil.
	def format_date(d)
		return nil if d.nil?
		return d.strftime("%Y/%m/%d")
	end

<<<<<<< HEAD
	# RIS wants `Last, First M.`
	# All of the authors being stored in Digital Case are already in this format though.
	def format_author_name(author)
		if author.last.present? && author.first.present?
			str = "#{author.last}, #{author.first}"
			if author.middle.present?
				middle = author.middle
				middle += "." if middle.length == 1
				str += " #{middle}"
			end
			return str
		elsif author.display.present?
			return author.display
		elsif author.last.present?
			return author.last?
		else
			return nil
		end
	end

=======
>>>>>>> a0e8b9a... ris_creator_spec works and runs three different tests, though the conditions are very similar in most possible calls to the ris_creator. I also cleaned out ris_creator, removing some methods and comments that werent being used or giving important information.
=======
>>>>>>> c375d0c... Started on the spec file to test the RISCreator and also cleaned out some of the sections of the RISCreator that were commented out from the bentosearch.  In the spec, Im attempting to create a test GenericWork to then run the export on and test the output with line by line comparison.
end

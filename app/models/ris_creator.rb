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
		@ris_format = translate_ris_format
	end

	def export
		out = "".force_encoding("UTF-8")
		out << tag_format("TY", @ris_format)


		# @item.to_param returns an id that always starts with "ksl:"
		# For the RIS citation we want to remove that, though, and only return the pid.		
		id = @item.id.to_s.split ":"
		out << tag_format("ID", id[1])
	

		# @item.title returns something like  ["Title of this item"]
		# So to remove the surrounding pairs of quotes and brackets using split
		title = @item.title.to_s.split "\""
		out << tag_format("TI", title[1])		

		@item.creator.each do |author|		
			out << tag_format("AU", author)
		end
		#Not a duplicate- contributors are authors too
		@item.contributor.each do |author|		
			out << tag_format("AU", author)
		end

		date = @item.date.to_s.split "\""
		out << tag_format("DA", date[1])
	
		pub = @item.publisher.to_s.split "\""
		out << tag_format("PB", pub[1])

		desc = @item.description.to_s.split "\""
		out << tag_format("AB", desc[1])

		@item.subject.each do |kw|
			out << tag_format("KW", kw)
		end

		relation = @item.relation.to_s.split"\""		
		out << tag_format("LB", relation[1])	
		# include main link and any other links?

		url = @item.identifier.to_s.split "\""
		out << tag_format("UR", url[1])

		# end with blank lines, so multiple ones can be concatenated for a file.
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
		"Text" => "BOOK", 
		
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
		 type = @item.type.to_s.split "\""
		 @@format_map[type[1]] || "GEN"
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
		if tag=="TY" #First line is always Type and should not be preceded by a newline.
			return "#{tag} - #{value}"
		end
		return "\r\n#{tag} - #{value}"
	end
end

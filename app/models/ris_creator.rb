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
		# 'i' is the Text object that is returned by the rails console command ActiveFedora::Base.find('pid').
		# The Text object has information relevant to creating the ris citation.
		@item = i

		#TODO The type method for @item is returning this error:
		# 'Tried to fetch `type' from solr, but it isn't indexed.'
		# @ris_format = translate_ris_format
	end

	def export
		out = "".force_encoding("UTF-8")
		#out << tag_format("TY", @ris_format)

		id = @item.to_param
		out << tag_format("ID", id)

		out << tag_format("TI", @item.title)		
		@item.creator.each do |author|		
			out << tag_format("AU", author)
		end
		@item.contributor.each do |author|
			out << tag_format("AU", author)
		end
			#out << tag_format("PY", @item.year)
			# We have the date rather than just the year
		out << tag_format("DA", @item.date)
		#out << tag_format("LA", @item.language)

			# We do not have methods to find any of the following
			#out << tag_format("VL", @item.volume)
			#out << tag_format("IS", @item.issue)
			#out << tag_format("SP", @item.start_page)
			#out << tag_format("EP", @item.end_page)
		
		#TODO The source method is also returning the index error:
		# 'Tried to fetch `source' from solr, but it isn't indexed.'	
		# @item.source.each do |source_title|		
			# out << tag_format("T2", source_title)
		# end
			# ISSN and ISBN both share SN
			# And we don't have methods to find either
			#out << tag_format("SN", @item.issn)
			#out << tag_format("SN", @item.isbn)
			#out << tag_format("DO", @item.doi)	
		out << tag_format("PB", @item.publisher)
		out << tag_format("AB", @item.description)
		@item.subject.each do |kw|
			out << tag_format("KW", kw)
		end

		relation = @item.relation.to_s.split"\""		
		out << tag_format("LB", relation[1])	
		# include main link and any other links?
		out << tag_format("UR", @item.identifier)
		# @item.linked_resource_urls.each do |link|
			# out << tag_format("UR", link.url)
		# end
		# end with blank lines, so multiple ones can be concatenated for
		# a file.
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
	#
	# The spec also seems to say ascii-only, but I don't think that's true
	# for actually existing software, we do utf-8.
	#
	# Refworks MAY require unicode composed normalization if it accepts utf8
	# at all. but not doing that yet. http://bibwild.wordpress.com/2010/04/28/refworks-problems-importing-diacritics/
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

	# Take a ruby Date and translate to RIS date format
	# "YYYY/MM/DD/other info"
	#
	# returns nil if input is nil.
	def format_date(d)
		return nil if d.nil?
		return d.strftime("%Y/%m/%d")
	end

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

end

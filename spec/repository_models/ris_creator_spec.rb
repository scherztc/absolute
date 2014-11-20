require 'spec_helper'
require 'ris_creator'

describe RISCreator do
		
	describe '#export' do
		context 'when the Generic work is ordinary' do		
			sample_dc = GenericWork.create!(pid: "ksl:test", title: ["Just a Test"], source: ["National Geographic"], 
				creator: ["Thomas, Mark", "Anne, Caty", "Petrusinski, Adam"], type: ["Text"], date: ["May 15, 2007"],
				description: ["On a long and arduous journey through the Andes mountains these test researchers discovered that they had missed their real life's calling"], subject: ["Hiking", "Test", "Disappointment"], 
				relation: ["National Geographic Test"], identifier: ["http://test.case.edu/ksl:test"] ) 

			creator = RISCreator.new(sample_dc) 

			export = creator.export 
			export = export.split"\r\n"
			export[0].should == 'TY - BOOK'
			export[1].should == 'ID - test'
			export[2].should == 'TI - Just a Test'
			export[3].should == 'AU - Thomas, Mark'
			export[4].should == 'AU - Anne, Caty'
			export[5].should == 'AU - Petrusinski, Adam'
			export[6].should == 'DA - May 15, 2007'		#If we change dates so that they are normalized, this will probably fail
			export[7].should == "AB - On a long and arduous journey through the Andes mountains these test researchers discovered that they had missed their real life's calling"
			export[8].should == 'KW - Hiking'
			export[9].should == 'KW - Test'
			export[10].should == 'KW - Disappointment'
			export[11].should == 'LB - National Geographic Test'
			export[12].should == 'UR - http://test.case.edu/ksl:test'
			export[13].should == 'ER - '		
		end

		context 'when the Generic work is minimal' do		
			sample_dc = GenericWork.create!(pid: "ksl:min", title: ["Small Test"], 
				creator: ["Hall, Todd"], contributor: ["Lee, Kris"], type: ["Text"], publisher: "Test pub",
				description: ["Not much info"] ) 

			creator = RISCreator.new(sample_dc) 

			export = creator.export 
			export = export.split"\r\n"
			export[0].should == 'TY - BOOK'
			export[1].should == 'ID - min'
			export[2].should == 'TI - Small Test'
			export[3].should == 'AU - Hall, Todd'
			export[4].should == 'AU - Lee, Kris'	#Also tests the inclusion of contributors as opposed to a list of creators
			export[5].should == 'PB - Test pub'
			export[6].should == "AB - Not much info"
			export[7].should == 'ER - '		
		end

		context 'when the Generic work is not text' do		
			sample_dc = GenericWork.create!(pid: "ksl:grav", title: ["Gravity"], 
				creator: ["Test, test"], type: ["Movie"],
				description: ["Lack of Oxygen"] ) 

			creator = RISCreator.new(sample_dc) 

			export = creator.export 
			export = export.split"\r\n"
			export[0].should == 'TY - MPCT'
			export[1].should == 'ID - grav'
			export[2].should == 'TI - Gravity'
			export[3].should == 'AU - Test, test'
			export[4].should == "AB - Lack of Oxygen"
			export[5].should == 'ER - '		
		end
	end
end
		
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
      it {
        expect(export[0]).to eq('TY - BOOK')
        expect(export[1]).to eq('ID - test')
        expect(export[2]).to eq('TI - Just a Test')
        expect(export[3]).to eq('AU - Thomas, Mark')
        expect(export[4]).to eq('AU - Anne, Caty')
        expect(export[5]).to eq('AU - Petrusinski, Adam')
        expect(export[6]).to eq('DA - May 15, 2007')		#If we change dates so that they are normalized, this will probably fail
        expect(export[7]).to eq("AB - On a long and arduous journey through the Andes mountains these test researchers discovered that they had missed their real life's calling")
        expect(export[8]).to eq('KW - Hiking')
        expect(export[9]).to eq('KW - Test')
        expect(export[10]).to eq('KW - Disappointment')
        expect(export[11]).to eq('LB - National Geographic Test')
        expect(export[12]).to eq('UR - http://test.case.edu/ksl:test')
        expect(export[13]).to eq('ER - ')
      }
    end

    context 'when the Generic work is minimal' do		
      sample_dc = GenericWork.create!(pid: "ksl:min", title: ["Small Test"], 
        creator: ["Hall, Todd"], contributor: ["Lee, Kris"], type: ["Text"], publisher: ["Test pub"],
        description: ["Not much info"] ) 

      creator = RISCreator.new(sample_dc) 

      export = creator.export 
      export = export.split"\r\n"
      it {
        expect(export[0]).to eq('TY - BOOK')
        expect(export[1]).to eq('ID - min')
        expect(export[2]).to eq('TI - Small Test')
        expect(export[3]).to eq('AU - Hall, Todd')
        expect(export[4]).to eq('AU - Lee, Kris')	#Also tests the inclusion of contributors as opposed to a list of creators
        expect(export[5]).to eq('PB - Test pub')
        expect(export[6]).to eq("AB - Not much info")
        expect(export[7]).to eq('ER - ')
      }
    end

    context 'when the Generic work is not text' do		
      sample_dc = GenericWork.create!(pid: "ksl:grav", title: ["Gravity"], 
        creator: ["Test, test"], type: ["Movie"],
        description: ["Lack of Oxygen"] ) 

      creator = RISCreator.new(sample_dc) 

      export = creator.export 
      export = export.split"\r\n"
      it {
        expect(export[0]).to eq('TY - MPCT')
        expect(export[1]).to eq('ID - grav')
        expect(export[2]).to eq('TI - Gravity')
        expect(export[3]).to eq('AU - Test, test')
        expect(export[4]).to eq("AB - Lack of Oxygen")
        expect(export[5]).to eq('ER - ')
      }
    end
  end
end
		

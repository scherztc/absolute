require 'spec_helper'
require "cancan/matchers"

describe "User" do
  describe "Abilities" do
    # This would test all of the registered Work types.
    # To keep the tests running faster, we just test one of them (see below) because they are all the same.
    #Worthwhile.configuration.curation_concerns.each do |curation_concern_type|
    #  it_behaves_like 'has_abilities_of_a_case_work', curation_concern_type
    #end
    it_behaves_like 'has_abilities_of_a_case_work', CaseGenericWork
  end
end

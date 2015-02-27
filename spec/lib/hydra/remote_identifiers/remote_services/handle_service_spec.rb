require 'spec_helper'
require 'hydra/remote_identifier/remote_services/handle_service'

module Hydra::RemoteIdentifier
  module RemoteServices

    describe HandleService do
      subject { RemoteServices::HandleService.new }
      let(:password) { "TestPass" }
      let(:existing_handle) { 'http://hdl.handle.net/2186/ksl:ech' }
      let(:nonexistant_handle) { 'http://hdl.handle.net/2186/ksl:invalid' }
      let(:new_handle) { 'ksl:newhandle' }
      let(:updated_handle) { 'ksl:updatedhandle' }
      let(:delete_handle) { 'ksl:deletehandle' }
      let(:location) { 'http://digital.case.edu/concern/texts/updatehandle' }

      context '.handle_exists?' do
        it 'should return true for an existing handle' do
          expect(subject.handle_exists?(existing_handle)).to eq true
        end

        it 'should return false for a handle that doesn\'t exist' do
          expect(subject.handle_exists?(nonexistant_handle)).to eq false
        end
      end

      context '.data_for_create' do
        it 'should return formatted data to create a new handle' do
          expect(subject.data_for_create(new_handle, location)).to eq "CREATE 12345/ksl:newhandle\n" +
            "100 HS_ADMIN 86400 1110 ADMIN\n" +
            "200::111111111111:0.NA/12345\n" +
            "2 URL 86400 1110 UTF8 http://digital.case.edu/concern/texts/newhandle\n\n"
        end
      end

      context '.data_for_update' do
        it 'should return formatted data to update a handle' do
          expect(subject.data_for_update(updated_handle, location)).to eq "MODIFY 12345/ksl:updatehandle\n" +
            "2 URL 86400 1110 UTF8 http://digital.case.edu/concern/texts/updatehandle\n\n"
        end
      end

      context '.data_for_delete' do
        it 'should return the data to remove a handle' do
          expect(subject.data_for_delete(delete_handle)).to eq "DELETE 12345/ksl:deletehandle\n\n"
        end
      end

      context '.namespace' do
        it 'returns the correct namespace for the environment' do
          expect(subject.namespace).to eq '12345'
        end
      end
    end

  end
end

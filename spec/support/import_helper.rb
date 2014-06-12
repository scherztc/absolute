module ImportHelper

  # The import script sets the PID of the new object the same
  # as the PID of the source object, but since the new object
  # and source object are in the same fedora when running the
  # specs, they can't have the same PID.
  def stub_out_set_pid(new_pid=nil)
    allow_any_instance_of(ObjectFactory).to receive(:set_pid) { new_pid }
  end

end

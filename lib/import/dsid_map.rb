class DsidMap

  # Normalize the dsid names.
  # In Case Western's fedora, some of the datastreams have
  # inconsistent dsids.  For example, the datastream in the
  # source fedora might be called 'MODS.xml', but when we
  # import it into the target fedora, it will be called 'MODS'.


  # ["MODS", "TEI", "TEIP5", "VRA", "PBCore", "METS", "QDC"]
  DSID_MAP = { 'MODS' => ['mods.xml'],
               'PBCore' => ['pbcore.xml'],
               'METS' => ['mets.xml'],
  }

  def self.target_dsid(source_dsid)
    dsid = DSID_MAP.select{|k,v| v.map(&:downcase).include?(source_dsid.downcase) }.keys.first
    dsid ||= source_dsid
  end

end

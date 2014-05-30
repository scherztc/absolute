class DsidMap

  # Normalize the dsid names.
  # In Case Western's fedora, some of the datastreams have
  # inconsistent dsids.  For example, the datastream in the
  # source fedora might be called 'MODS.xml', but when we
  # import it into the target fedora, it will be called 'MODS'.

  DSID_MAP = { 'MODS' => ['mods.xml', 'modss.xml'],
               'PBCore' => ['pbcore.xml'],
               'METS' => ['mets.xml'],
               'TEI' => ['tei.xml'],
               'TEIP5' => ['teip5.xml'],
               'VRA' => ['vra.xml']
  }

  def self.target_dsid(source_dsid)
    dsid = DSID_MAP.select{|k,v| v.map(&:downcase).include?(source_dsid.downcase) }.keys.first
    dsid ||= source_dsid
  end

end

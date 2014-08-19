# Returns an array containing the vhost 'CoSign service' value and URL
Sufia.config do |config|

  config.application_name = "Digital Case"

  config.fits_to_desc_mapping= {
    :file_title => :title,
    :file_author => :creator
  }

  # Specify a different template for your repositories unique identifiers
  # config.noid_template = ".reeddeeddk"

  config.max_days_between_audits = 7

  config.cc_licenses = [
    'Kelvin Smith Library, Case Western Reserve University, Cleveland, Ohio, provides the information contained in digital case for non-commercial, personal, or research use only. All other use, including but not limited to commercial or scholarly reproductions, redistribution, publication or transmission, whether by electronic means or otherwise, without prior written permission of the copyright holder is strictly prohibited. For more information contact digital case at digitalcase@case.edu.',
    'This work may be protected by copyright law under U.S. Code Title 17. Digital Case makes this reproduction available for personal research purposes only. For more information, please contact Digital Case at digitalcase@case.edu.',
    'This work is in the public domain. For more information contact University Archives at archives@case.edu or by calling 216-368-3320.'
  ]

  #config.cc_licenses_reverse = Hash[*config.cc_licenses.to_a.flatten.reverse]

  config.resource_types = {
    "Article" => "Article",
    "Audio" => "Audio",
    "Book" => "Book",
    "Capstone Project" => "Capstone Project",
    "Conference Proceeding" => "Conference Proceeding",
    "Dataset" => "Dataset",
    "Dissertation" => "Dissertation",
    "Image" => "Image",
    "Journal" => "Journal",
    "Map or Cartographic Material" => "Map or Cartographic Material",
    "Masters Thesis" => "Masters Thesis",
    "Part of Book" => "Part of Book",
    "Poster" => "Poster",
    "Presentation" => "Presentation",
    "Project" => "Project",
    "Report" => "Report",
    "Research Paper" => "Research Paper",
    "Software or Program Code" => "Software or Program Code",
    "Video" => "Video",
    "Other" => "Other",
  }

  config.permission_levels = {
    "Choose Access"=>"none",
    "View/Download" => "read",
    "Edit" => "edit"
  }

  config.owner_permission_levels = {
    "Edit" => "edit"
  }

  config.queue = Sufia::Resque::Queue

  # Map hostnames onto Google Analytics tracking IDs
  # config.google_analytics_id = 'UA-99999999-1'


  # Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)
  # config.temp_file_base = '/home/developer1'

  # If you have ffmpeg installed and want to transcode audio and video uncomment this line
  config.enable_ffmpeg = true

  # Specify the Fedora pid prefix:
  config.id_namespace = "ksl"

  # Specify the path to the file characterization tool:
  # config.fits_path = "fits.sh"

end

Date::DATE_FORMATS[:standard] = "%m/%d/%Y"

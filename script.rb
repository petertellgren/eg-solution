require 'pp'
require_relative 'lib/eagle.rb'

module UploadDirectory
  # return a hash where the keys are study identifierers, each value is an array of files to add
  def self.fetch(directory)
    mapping = []
    files = Dir.glob(directory)
    files.each do |file|
      mapping << UploadFile.new(file)
    end
    return mapping
  end

end

class UploadFile
  attr_accessor :study_id, :study_uuid, :path, :name

  def initialize(path)
    @path = path
    @name = File.basename(path)
    @study_id = @name.split(' ').first
  end
end

# List of files to upload to studies
files_to_upload = UploadDirectory.fetch("./files-to-upload/*")

# create a Ealge API client
eagle_client = Eagle::Client.new do |config|
  config.client_id  = "james.cox@eaglegenomics.com"
  config.client_key = "d9dcfacea7f1d162b18c17b0638a71b8"
end

# get all the invetsigations
investigations = eagle_client.investigations.list

# create a placeholder structure where the keys are the study identifiers
study_ids = Hash[files_to_upload.collect { |f|  [f.study_id, 0] }]

# A cahced version to speed up testing
# study_ids = {"TPS-003"=>"4781fed1-3364-4e68-8037-184cfe781c5d", "SDH432"=>"018d102a-4887-4ed7-a617-1cec991fdabd", "SDH034"=>"1164e512-42e5-4ea1-85e8-690a52fd061a"}

# for each investigation we fecth all studies and map the uuid to the identifier
investigations.each do |investtigation|
  investigation_details = eagle_client.investigations.details( investtigation["uuid"] )
  investigation_details["studies"].each do |study|
    study_id = study["identifier"]
    study_ids[study_id] = study["uuid"] if study_ids.keys.include?( study_id )
  end
end

# upload each file
files_to_upload.each do |file|
  eagle_client.studies.upload( study_ids[file.study_id], file.name, file.path )
end

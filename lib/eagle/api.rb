require 'base64'

module Eagle

  class Investigations
    attr_accessor :master

    def initialize(master)
      @master = master
    end

    # Return a list of all investigations available to this account
    # @return [Array] an array of structs with information about each investigation
    def list
      return @master.call :get, 'investigations.json'
    end

    # Return details of a specific investigation
    # @param [uuid] uuid, the uniqe identifier for the investigation
    # @return [Hash] a structure with information about a specific investigation
    def details(uuid)
      return @master.call :get, "investigations/#{uuid}.json"
    end
  end

  class Studies
    attr_accessor :master

    def initialize(master)
      @master = master
    end

    # Upload a data file to a specific study
    # @param [uuid] study_id, the uniqe identifier for the study
    # @param [String] filen_name name to assign the file
    # @param [String] file_path releative path to the file we want to upload
    # @return [Hash] a response hash with status
    def upload(study_id, file_name, file_path)
      params = {
        isa_model_type: "Study",
        isa_model_id: study_id,
        name: file_name,
        file: Base64.encode64(File.read(file_path))
      }
      return @master.call :post, 'data_files', params
    end

  end


end
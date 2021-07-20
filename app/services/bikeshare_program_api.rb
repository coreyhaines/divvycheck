require 'http'
require 'json'

class BikeshareProgramApi
  def self.all_station_information(program:, tracker: nil)
    Rails.cache.fetch("all_station_information/#{program.name}", expires_in: 1.day) do
      Rails.logger.info "Retrieving and Caching All Station Information #{program.name}"
      get_from_api(program.all_station_information_url)
    end
  end

  def self.all_station_status(program:, tracker: nil)
    Rails.cache.fetch("all_station_status/#{program.name}", expires_in: 1.minute) do
      Rails.logger.info "Retrieving and Caching All Station status #{program.name}"
      get_from_api(program.all_station_status_url)
    end
  end

  def self.specific_station_statuses(program:, tracker:, ids:)
    informations = BikeshareProgramApi.
      all_station_information(program: program, tracker: tracker).
      select {|st| ids.include? st["station_id"]}

    statuses = BikeshareProgramApi.
      all_station_status(program: program, tracker: tracker).
      select {|st| ids.include? st["station_id"]}

    informations.zip(statuses).map{|info, status| info.merge(status)}
  end

  def self.get_from_api(url)
    response = HTTP.headers("Client-Identifier" => "coreyhaines/freedock.app").get(url).to_s
    JSON.parse(response).dig("data", "stations")
  end
end

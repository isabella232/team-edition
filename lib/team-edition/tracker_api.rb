module TeamEdition
  class TrackerApi
    def initialize(api_key)
      @api_key = api_key
    end

    def members(project_id)
      uri = URI.parse("https://www.pivotaltracker.com/services/v5/projects/#{project_id}/memberships")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.path)
      request["Content-Type"] = "application/json"
      request["X-TrackerToken"] = @api_key
      # puts "hi"
      # puts request
      # puts project_id
      # req = http.request(request)
      # puts req.header
      # puts req.body
      response = JSON.parse(http.request(request).body).map { |membership| membership["person"]["email"] }
      response
    end

    def add_to_project(project_id, name, initials, email, role)
      abort "role must be owner, member or viewer" unless %w{owner member viewer}.include?(role)

      uri = URI.parse("https://www.pivotaltracker.com/services/v5/projects/#{project_id}/memberships")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"] = "application/json"
      request["X-TrackerToken"] = @api_key
      request.body = <<-JSON
      {
        "role": "#{role}",
        "email": "#{email}",
        "name": "#{name}",
        "initials": "#{initials}"
      }
      JSON
      response = http.request(request)
      raise "Failed: #{response.inspect} #{response.body}" unless response.code == "200"
    end
  end
end

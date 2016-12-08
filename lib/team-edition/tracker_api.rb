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
      response = JSON.parse(http.request(request).body).map { |membership| membership["person"]["email"] }
      response
    end

    def post_add_to_project_request(project_id, name, initials, email, role)
      uri = URI.parse("https://www.pivotaltracker.com/services/v3/projects/#{project_id}/memberships")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"] = "application/xml"
      request["X-TrackerToken"] = @api_key
      request.body = <<-XML
      <membership>
        <role>#{role}</role>
        <person>
          <name>#{name}</name>
          <initials>#{initials}</initials>
          <email>#{email}</email>
        </person>
      </membership>
      XML
      response = http.request(request)
    end

    def add_to_project(project_id, name, initials, email, role)
      abort "role must be owner, member or viewer" unless %w{owner member viewer}.include?(role)
      3.times do
        response = post_add_to_project_request(project_id, name, initials, email, role)
        break if response.code == "200"
        puts "\e[31m Failed with response code #{response.code}! Waiting one minute and trying again. \e[0m "
        sleep 60
      end
      raise "Failed: #{response.inspect} #{response.body}" unless response.code == "200"
    end
  end
end

class AutocertMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    data = []
    if ENV['AUTOCERT_CHALLENGE_KEY'] && ENV['AUTOCERT_CHALLENGE_TOKEN']
      data << { key: ENV['AUTOCERT_CHALLENGE_KEY'], token: ENV['AUTOCERT_CHALLENGE_TOKEN'] }
    else
      ENV.each do |k, v|
        if d = k.match(/^AUTOCERT_CHALLENGE_KEY_([0-9]+)/)
          index = d[1]
          data << { key: v, token: ENV["AUTOCERT_CHALLENGE_TOKEN_#{index}"] }
        end
      end
    end

    data.each do |e|
      if env["PATH_INFO"] == "/.well-known/acme-challenge/#{e[:token]}"
        return [200, { "Content-Type" => "text/plain" }, [e[:key]]]
      end
    end

    @app.call(env)
  end
end

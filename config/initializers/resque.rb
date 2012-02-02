ENV["REDISTOGO_URL"] ||= "redis://stpn:b8be70ed6ebfb7d0c5b248d2e4fd4ae2@perch.redistogo.com:9511/"

uri = URI.parse(ENV["REDISTOGO_URL"])
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
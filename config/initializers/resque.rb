
ENV["REDISTOGO_URL"] ||= "redis://stpn:6517cfc074b96099471820759b9228b8@chubb.redistogo.com:9164/"


Dir["#{Rails.root}/app/workers/*.rb"].each { |file| require file }

uri = URI.parse(ENV["REDISTOGO_URL"])
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
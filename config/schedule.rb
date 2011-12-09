every 2.minutes do
  command "curl -i -X POST -d 'number=100' http://localhost:3000/videos"
end
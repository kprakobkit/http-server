require 'socket'

server = TCPServer.new 2000

loop do
  puts "Server running"
  socket = server.accept
  request = socket.gets
  resource = request.split[1].gsub(/\//,"")

  case resource
  when "welcome"
    status = 200
    body = [
      "<html>",
      "<head>",
      "<title>Welcome</title>",
      "</head>",
      "<body>",
      "<h1>Hello World</h1>",
      "<p>Welcome to the world's simplest web server.</p>",
      "<p><img src='http://i.imgur.com/A3crbYQ.gif'></p>",
      "</body>",
      "</html>\r\n\r\n"
    ].join("\r\n")
  when "profile"
    status = 200
    body = [
      "<html>",
      "<head>",
      "<title>My Profile Page</title>",
      "</head>",
      "<body>",
      "<p>This is my profile page.</p>",
      "</body>",
      "</html>\r\n\r\n"
    ].join("\r\n")
  else
    status = 404
    body = "not found\r\n\r\n"
  end

  header = [
    "HTTP/1.1 #{status} #{status == 404 ? "NOT FOUND" : "OK" }",
    "Date: #{Time.now}",
    "Server: Neo Server",
      "Content-Type: text/html; charset=UTF-8",
      "Content-Length: #{body.length}",
    "Connection: Close\r\n\r\n"
  ].join("\r\n")

  socket.puts header
  socket.puts body

  socket.close
end

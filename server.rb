require 'socket'

server = TCPServer.new 2000

loop do
  puts "Server running."
  client = server.accept

  puts "Response"
  client.puts "Hello World!"
  client.close
end

require 'socket'

server = TCPServer.new 2000

loop do
  puts "Server running"
  socket = server.accept
  message = socket.gets.chomp

  case message
  when 'home'
    response = 'Welcome to my Server!'
  when 'profile'
    response = [
      'User: Peter Prakobkit',
      'Favorite Quote: Chang Ku Yu Nai?'
    ].join("\n")
  end

  socket.puts response

  socket.close
end

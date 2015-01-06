require 'socket'

class Request
  attr_reader :resource

  def initialize request_line
    @request_line = request_line
    @resource = @request_line.split[1].gsub(/\//,"")
  end
end

class Response
  @@resources = Dir["views/*.html"].map { |file_name| File.basename(file_name, ".html") }

  def initialize request
    @request = request
    @status = get_status
  end

  def get_status
    @@resources.include?(@request.resource) ? 200 : 404
  end

  def status_message
    case @status
    when 200
      "OK"
    when 404
      "NOT FOUND"
    end
  end

  def header
    [
      "HTTP/1.1 #{@status} #{status_message}",
      "Date: #{Time.now}",
      "Server: Neo Server",
        "Content-Type: text/html; charset=UTF-8",
        "Content-Length: #{body.length}",
      "Connection: Close\r\n\r\n"
    ].join("\r\n")
  end

  def body
    if @status == 404
      render 404
    else
      render @request.resource
    end
  end

  def render file_name
    File.read("views/#{file_name}.html")
  end
end

class Server
  def initialize port
    @port = port
  end

  def start
    server = TCPServer.new @port
    loop do
      socket = server.accept
      request = Request.new(socket.gets)
      response = Response.new(request)

      socket.puts response.header
      socket.puts response.body

      socket.close
    end
  end
end

require 'socket'
require 'cgi'

class Request
  attr_accessor :request_lines
  attr_reader :resource

  def initialize
    @request_lines = []
  end

  def build_request
    request_line = @request_lines.first.split(" ")
    @resource = request_line[1].split("?")[0].gsub(/\//,"")
    @params = request_line[1].split("?")[1]
  end

  def params_hash
    CGI::parse(@params) if @params
  end

  def cookie
    @request_lines[-1].split(": ").last # assuming the cookie in the request is the last attribute
  end
end

class Response
  @@visits = {}

  def initialize request
    @request = request
    @status = get_status
  end

  def resources
    Dir["views/*.html"].map { |file_name| File.basename(file_name, ".html") }
  end

  def get_status
    resources.include?(@request.resource) ? 200 : 404
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
      "Connection: Close",
      "Set-Cookie: name=computer2\r\n\r\n"
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
    body = File.read("views/#{file_name}.html")
    if @request.params_hash
      @request.params_hash.each do |param, value|
        body.gsub!(/{{#{param}}}/, value.first)
      end
    end
    body
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
      request = Request.new

      while request_line = socket.gets and request_line !~ /^\s*$/
        request.request_lines << request_line.chomp
      end

      request.build_request
      response = Response.new(request)

      socket.puts response.header
      socket.puts response.body

      socket.close
    end
  end
end

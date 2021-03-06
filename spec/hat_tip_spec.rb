require 'CGI'
require_relative '../hat_tip'

describe Server do
  let (:port) { 2121 }
  let (:server) { Server.new port }

  describe "#new" do
    it "should instantiate a server instance with the specified port" do
      expect(server).to be_a Server
      expect(server.instance_variable_get(:@port)).to eq port
    end
  end
end

describe Request do
  let (:request_line) { "GET /foobar HTTP/1.1" }
  let (:params) { "param1=value1&param2=value2" }
  let (:params_hash) { CGI::parse(params) }
  let (:request_with_params) { "GET /foobar?#{params} HTTP/1.1" }
  let (:request) { Request.new request_line }

  describe "#new" do
    it "should instantiate a new request object" do
      expect(request).to be_a Request
    end

    it "should assign @resource by parsing the request line" do
      expect(request.resource).to eq "foobar"
    end

    it "should assign @params" do
      request = Request.new request_with_params
      expect(request.params_hash).to eq params_hash
    end
  end
end

describe Response do
  let (:valid_request_line) { "GET /foo HTTP/1.1" }
  let (:valid_request) { Request.new valid_request_line }
  let (:invalid_request_line) { "GET /bar HTTP/1.1" }
  let (:invalid_request) { Request.new invalid_request_line }
  let (:valid_response) { Response.new valid_request }
  let (:invalid_response) { Response.new invalid_request }
  let (:resources) { ["foo", "foobar"] }

  describe "#new" do
    it "should instantiate a new response object" do
      expect(valid_response).to be_a Response
    end
  end

  describe "#get_status" do
    before :each do
      allow_any_instance_of(Response).to receive(:resources).and_return(resources)
    end

    it "should return 200 if the resource exists" do
      expect(valid_response.instance_variable_get(:@status)).to eq 200
    end

    it "should return 404 if the resource exists" do
      expect(invalid_response.instance_variable_get(:@status)).to eq 404
    end
  end

  describe "body" do
    let (:params) { "first=Peter&last=Prakobkit" }
    let (:request_with_params) { "GET /welcome?#{params} HTTP/1.1" }
    let (:request) { Request.new request_with_params }
    let (:response) { Response.new request }
    let (:resources) { ["welcome", "foobar"] }

    describe "#new" do
      it "should instantiate a new response object" do
        expect(valid_response).to be_a Response
      end
    end

    context "welcome page" do
      it "should have the right content" do
        expect(response.body).to include "Peter"
        expect(response.body).to include "Prakobkit"
      end
    end
  end
end

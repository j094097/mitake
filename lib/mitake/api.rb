module Mitake
  class API

    SmSendGet   = "/SmSendGet.asp"
    SmSendPost  = "/SmSendPost.asp"
    SmQueryGet  = "/SmQueryGet.asp"
    SpLmGet     = "/SpLmGet"

    def initialize(options = {})
      @username = options.fetch(:username) { ENV['mitake_username'] }
      @password = options.fetch(:password) { ENV['mitake_password'] }
      @host = options.fetch(:host) { "http://smexpress.mitake.com.tw:9600" }
    end

    def send_sms(numbers, options = {})

      message = hack_message_encode(options.fetch(:message))

      case numbers
      when Array
        if numbers.length == 1
          response = http_get(api_uri(SmSendGet), {dstaddr: numbers.first, smbody: message})
        else
          response = multi_message_post(api_uri(SmSendPost), numbers, message)
        end
      when String
        response = http_get(api_uri(SmSendGet), {dstaddr: numbers, smbody: message})
      else
        return raise "Numbers Must Be Array or String"
      end

      #results = response.body.split("\r\n").drop(1).map{|e| e.split("=")}.to_h
      #ec = Encoding::Converter.new("Big5", "UTF-8")
      #results["Error"] = ec.convert(results["Error"])
    end

    def get_balance
      response = http_get(api_uri(SmQueryGet), {})

      result = response.body.split('=')

      unless result.first == 'AccountPoint'
        raise "API Fetch Faild!"
      end

      result.last.to_i
    end

    def get_message(options = {})
      response = http_get(api_uri(SmQueryGet), options)
    end


    def api_uri(path)
      uri = URI("#{@host}#{path}")
      uri.query = URI.encode_www_form(user_params)
      uri
    end

    def multi_message_data(numbers, message)
      data = %w()
      numbers.each_with_index do |number, index|
        data.push "[#{index}]\r\n"
        data.push "dstaddr=#{number}\r\n"
        data.push "smbody=#{message}\r\n"
      end
      return data.join('')
    end

    def multi_message_post(uri, numbers, message)
      post_data = multi_message_data(numbers, message)

      http = Net::HTTP.new(uri.host, uri.port)
      
      request = Net::HTTP::Post.new(uri.request_uri)

      request.body = post_data
      request.content_length = post_data.length
      request.content_type = 'text/xml'

      return http.request(request)
    end

    def http_get(uri, params)
      if params.any?
        params.each do |key, value|
          uri.query = URI.encode_www_form(URI.decode_www_form(uri.query) << [key, value])
        end
      end

      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Get.new(uri.request_uri)
      
      return http.request(request)
    end

    #三竹指定encode
    def hack_message_encode(message)
      CGI.escape(message).gsub('+', '%20')
    end

    def user_params
      { username: @username, password: @password, encoding: 'UTF8' }
    end

    
  end
end
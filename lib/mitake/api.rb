module Mitake
  class API

    SmSendGet   = "/SmSendGet.asp"
    SmSendPost  = "/SmSendPost.asp"
    SmQueryGet  = "/SmQueryGet.asp"
    SpLmGet     = "/SpLmGet"

    Statuscode = {
      '*' => '系統發生錯誤，請聯絡三竹資訊窗口人員',
      'a' => '簡訊發送功能暫時停止服務，請稍候再試',
      'b' => '簡訊發送功能暫時停止服務，請稍候再試',
      'c' => '請輸入帳號',
      'd' => '請輸入密碼',
      'e' => '帳號、密碼錯誤',
      'f' => '帳號已過期',
      'h' => '帳號已被停用',
      'k' => '無效的連線位址',
      'm' => '必須變更密碼，在變更密碼前，無法使用簡訊發送服務',
      'n' => '密碼已逾期，在變更密碼前，將無法使用簡訊發送服務',
      'p' => '沒有權限使用外部Http程式',
      'r' => '系統暫停服務，請稍後再試',
      's' => '帳務處理失敗，無法發送簡訊',
      't' => '簡訊已過期',
      'u' => '簡訊內容不得為空白',
      'v' => '無效的手機號碼',
      '0' => '預約傳送中',
      '1' => '已送達業者',
      '2' => '已送達業者',
      '3' => '已送達業者',
      '4' => '已送達手機',
      '5' => '內容有錯誤',
      '6' => '門號有錯誤',
      '7' => '簡訊已停用',
      '8' => '逾時無送達',
      '9' => '預約已取消'
    }

    

    def initialize(options = {})
      @username = options.fetch(:username) { ENV['mitake_username'] }
      @password = options.fetch(:password) { ENV['mitake_password'] }
      @host = options.fetch(:host) { "http://smexpress.mitake.com.tw:9600" }
      @SpLm_host = options.fetch(:SpLm_host) { "http://smexpress.mitake.com.tw:7002" }
    end

    def send_sms(options = {})
      numbers = options.fetch(:numbers) { "" }
      message = hack_message_encode(options.fetch(:message)) { "" }
      response_callback_url = options.fetch(:response_callback_url) { "" }

      case numbers
      when Array
        if numbers.length == 1
          response = http_get(api_uri(@host, SmSendGet), {dstaddr: numbers.first, smbody: message, response: response_callback_url})
        else
          response = multi_message_post(api_uri(@host, SmSendPost), numbers, message, response_callback_url)
        end
      when String
        response = http_get(api_uri(@host, SmSendGet), {dstaddr: numbers, smbody: message, response: response_callback_url})
      else
        return raise "Numbers Must Be Array or String"
      end

      response_message = response.body
      # response_message = "[1]\r\nmsgid=0939137671\r\nstatuscode=1\r\n[2]\r\nmsgid=0939138467\r\nstatuscode=1\r\nAccountPoint=96\r\n"
      # response_message = "[0]\r\nstatuscode=e\r\nError=?b???B?K?X???~\r\n[1]\r\n[0]\r\nstatuscode=e\r\nError=?b???B?K?X???~\r\n"

      if /AccountPoint=\w+/.match(response_message)
        results = response_message.sub(/^AccountPoint=\w+\r\n/, '').
                                   split(/\[\d\]\r?\n/).
                                   reject(&:empty?).
                                   map{ |e| e.split("\r\n").map{|e| e.split("=")}.to_h }

        results << { "AccountPoint" => /AccountPoint=\w+/.match(response_message)[0].split("=")[1] }

        results.map { |e| e.default_proc = proc{|h, k| h.key?(k.to_s) ? h[k.to_s] : nil} }

        #[{"msgid"=>"0939137671", "statuscode"=>"1"}, {"msgid"=>"0939138467", "statuscode"=>"1"}, {"AccountPoint"=>"96"}]
      else
        results = response_message.split(/\[\d\]\r?\n/).
                                   reject(&:empty?).
                                   map{ |e| e.split("\r\n").map{|e| e.split("=")}.to_h }

        ec = Encoding::Converter.new("Big5", "UTF-8")
        results.map { |e| e["Error"] = ec.convert(e["Error"]); e.default_proc = proc{|h, k| h.key?(k.to_s) ? h[k.to_s] : nil} }

        #{"statuscode"=>"e", "Error"=>"帳號、密碼錯誤"}
      end

      results
    end

    def get_message_status(options = {})
      msgid = options.fetch(:msgid) { nil }
      
      case msgid
      when String
        response = http_get(api_uri(@host, SmQueryGet), options)
      else
        return raise "Msgid Must Be String"
      end

      response_message = response.body

      if response_message.length == 0
        raise "API Fetch Faild!"
      else
        results = response_message.split("\r\n").
                                   reject(&:empty?).
                                   map do |e|
                                    message = e.split("\t")
                                    { "msgid" => message[0], "statuscode" => message[1], "statustime" => message[2] }
                                  end
        results.map { |e| e.default_proc = proc{|h, k| h.key?(k.to_s) ? h[k.to_s] : nil} }
      end

      results
      #{"msgid"=>"0939137671", "statuscode"=>"4", "statustime"=>"20160808153248"}
    end

    def get_balance
      response = http_get(api_uri(@host, SmQueryGet), {})

      result = response.body.split('=')

      if result.first == 'AccountPoint'
        result.last.to_i
      else
        raise "API Fetch Faild!"
      end      
    end

    def send_long_sms(options = {})
      numbers = options.fetch(:numbers) { "" }
      message = hack_message_encode(options.fetch(:message)) { "" }
      response_callback_url = options.fetch(:response_callback_url) { "" }

      response = http_get(api_uri(@SpLm_host, SpLmGet), {dstaddr: number, smbody: message, response: response_callback_url})
      response_message = response.body
      # response_message = "[1]\r\nmsgid=#021BCAE83\r\nstatuscode=1\r\nAccountPoint=93"

      if /AccountPoint=\w+/.match(response_message)
        results = response_message.sub(/^AccountPoint=\w+/, '').
                                   split(/\[\d\]\r?\n/).
                                   reject(&:empty?).
                                   map{ |e| e.split("\r\n").map{|e| e.split("=")}.to_h }

        results << { "AccountPoint" => /AccountPoint=\w+/.match(response_message)[0].split("=")[1] }

        results.map { |e| e.default_proc = proc{|h, k| h.key?(k.to_s) ? h[k.to_s] : nil} }
      else
        results = response_message.split(/\[\d\]\r?\n/).
                                   reject(&:empty?).
                                   map{ |e| e.split("\r\n").map{|e| e.split("=")}.to_h }

        ec = Encoding::Converter.new("Big5", "UTF-8")
        results.map { |e| e["Error"] = ec.convert(e["Error"]); e.default_proc = proc{|h, k| h.key?(k.to_s) ? h[k.to_s] : nil} }

        #{"statuscode"=>"e", "Error"=>"帳號、密碼錯誤"}
      end

      results
      #[{"msgid"=>"#021BCAF21", "statuscode"=>"1"}, {"AccountPoint"=>"92"}] 
    end

    def api_uri(host, path)
      uri = URI("#{host}#{path}")
      uri.query = URI.encode_www_form(user_params)
      uri
    end

    def multi_message_data(numbers, message, response_callback_url)
      data = %w()
      numbers.each_with_index do |number, index|
        data.push "[#{index}]\r\n"
        data.push "dstaddr=#{number}\r\n"
        data.push "smbody=#{message}\r\n"
        data.push "response=#{response_callback_url}\r\n" if response_callback_url.length > 0
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
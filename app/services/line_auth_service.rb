class LineAuthService
  def initialize(api_uri)
    @api_uri = api_uri
  end

  def execute(body)
    nonce = SecureRandom.uuid + Time.now.to_i.to_s
    resp = Faraday.post("#{ENV['line_pay_server']}#{@api_uri}") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-LINE-ChannelId'] = ENV['line_pay_id']
      req.headers['X-LINE-Authorization-Nonce'] = nonce
      req.body = body.to_json
      req.headers['X-LINE-Authorization'] = Base64.encode64(OpenSSL::HMAC.digest("SHA256", ENV['line_pay_secret'], ENV['line_pay_secret'] + @api_uri + req.body + nonce)).gsub(/\n/,"")
    end
    @result = JSON.parse(resp.body)
  end

  def success?
    @result["returnCode"] == "0000"
  end

  def payment_url
    @result["info"]["paymentUrl"]["web"]
  end
end

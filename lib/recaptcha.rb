require 'net/http'

module Sinatra
  module ReCaptcha
    VERSION = "0.0.1"
    
    @server = 'http://api.recaptcha.net'
    @verify = 'http://api-verify.recaptcha.net'
    
    class << self
      attr_accessor :public_key, :private_key, :server
      attr_reader   :verify
    end
    
    def recaptcha(type = :iframe)
      raise "Recaptcha type: #{type} is not known, please use (:iframe or :ajax)" unless [:iframe, :ajax].include?(type.to_sym)
      self.send("recaptcha_#{type}")
    end

    def recaptcha_correct?
      recaptcha = Net::HTTP.post_form URI.parse("#{Sinatra::ReCaptcha.verify}/verify"), {
        :privatekey => Sinatra::ReCaptcha.private_key,
        :remoteip   => request.ip,
        :challenge  => params[:recaptcha_challenge_field],
        :response   => params[:recaptcha_response_field]
      }
      answer, error = recaptcha.body.split.map { |s| s.chomp }
      unless answer == 'true'
        return false
      else
        return true
      end
    end
    
    protected
    
    def recaptcha_iframe
      "<script type='text/javascript'
         src='#{Sinatra::ReCaptcha.server}/challenge?k=#{Sinatra::ReCaptcha.public_key}'>
      </script>
      <noscript>
         <iframe src='#{Sinatra::ReCaptcha.server}/noscript?k=#{Sinatra::ReCaptcha.public_key}'
             height='300' width='500' frameborder='0'></iframe><br>
         <textarea name='recaptcha_challenge_field' rows='3' cols='40'>
         </textarea>
         <input type='hidden' name='recaptcha_response_field' 
             value='manual_challenge'>
      </noscript>"
    end
    
    def recaptcha_ajax
      "<div id='recaptcha_div'> </div>
        <script type='text/javascript' src='#{Sinatra::ReCaptcha.server}/js/recaptcha_ajax.js'></script>
        <script type='text/javascript' >
          Recaptcha.create('#{Sinatra::ReCaptcha.public_key}', 'recaptcha_div' );
        </script>"
    end
    
  end

  helpers ReCaptcha
end

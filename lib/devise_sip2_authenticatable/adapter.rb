module Devise
  module Sip2Utilities
    require 'date'
    
    UID_ALGORITHM = 0
    PWD_ALGORITHM = 0  
    FIELD_TERMINATOR = '|'
    MESSAGE_TERMINATOR = "\r\n"
    LANGUAGE = '001'
    
    def crc(msg)    
      _sum = msg.chars.inject(0) {|iter, x| iter + x.ord }
      sum = (_sum & 0xFFFF) * -1
      sprintf("%4X", sum)[-4,4]
    end
    
    def timestamp
      DateTime.now.strftime("%Y%m%d    %H%M%S")
    end
      
    def justifier(item, length)
      item.to_s.rjust(length, ' ')
    end

    def msg_finalize(msg)
      msg + crc(msg) + MESSAGE_TERMINATOR
    end

    def field_build(key, value)
      key + value + FIELD_TERMINATOR
    end
    
    def msg_patron_information(seq, patron, patron_pwd, ao, type, ac = '')
      _msg = [ '63', 
        justifier(LANGUAGE, 3),
        justifier(timestamp, 18),
        justifier(sprintf("%-10s",type), 10),
        field_build('AO', ao),
        field_build('AA', patron),
        field_build('AD', patron_pwd),
        field_build('BP', '1'),
        field_build('BQ', '5'),
        'AY', seq, 'AZ' ].join
      msg_finalize(_msg)
    end
    
    def parse_patron_information_response(response)
      valid = !!(response =~ /\|CQY\|/)
      name = response.match(/\|AE([^\|]*)/)[1] rescue nil
      email = response.match(/\|BE([^\|]*)/)[1].split(/,/).first rescue nil
      { :valid => valid, :name => name, :email => email }
    end    
  end
  
  class Sip2

    require 'socket'
    include Sip2Utilities
    attr_accessor :ao

    SIP2_CONFIG = YAML.load_file("#{Rails.root}/config/sip2.yml")[Rails.env]
    
    def initialize()  
      host = SIP2_CONFIG.fetch('host', 'localhost')
      port = SIP2_CONFIG.fetch('port', 6001)
      @ao = SIP2_CONFIG.fetch('ao', nil)
      @socket = connect(host, port)
      @seq = -1    
    end
    
    def next_seq
      @seq = @seq.next
    end
    
    def get_patron_information(params = {})
      patron = params.fetch(:patron, '')
      patron_pwd = params.fetch(:patron_pwd, '')
      type = params.fetch(:type, '      ')
      msg = msg_patron_information(next_seq, patron, patron_pwd, @ao, type)
      response = process_request(msg)
      parse_patron_information_response(response)
    end
      
    def process_request(request)
      response = ''
      @socket.print(request)    
      while ( t = @socket.read(1) ) and ( t != "\r" )
        response << t
      end
      response
    end
    
    def close
      @socket.close
    end
    
    def connect(host, port)
      begin
        TCPSocket.new(host, port)  
      rescue SocketError => e
        puts e.message
      end
    end

  end
end

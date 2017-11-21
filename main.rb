#!mruby
#Ver.2.35

# Dual DC Motor Driver TB6612FNG Class
class  TB6612Driver
  MOTOR_SPEED = 50

  def initialize(pwma = 4, pwmb = 10, ain1 = 18, ain2 = 3, bin1 = 15, bin2 = 14)
    @pwma = pwma
    @pwmb = pwmb
    @ain1 = ain1
    @ain2 = ain2
    @bin1 = bin1
    @bin2 = bin2

    [pwma, pwmb, ain1, ain2, bin1, bin2].each { |pin| pinMode(pin, OUTPUT) }
  end
  
  def forward(speed = MOTOR_SPEED)
      digitalWrite(@ain1, HIGH)  #A1
      digitalWrite(@ain2, LOW)   #A2
      digitalWrite(@bin1, HIGH)  #B1
      digitalWrite(@bin2, LOW)   #B2
      
      pwm(@pwma, speed)
      pwm(@pwmb, speed)
  end
  
  def backward(speed = MOTOR_SPEED)
      digitalWrite(@ain1, LOW)   #A1
      digitalWrite(@ain2, HIGH)  #A2
      digitalWrite(@bin1, LOW)   #B1
      digitalWrite(@bin2, HIGH)  #B2
      
      pwm(@pwma, speed)
      pwm(@pwmb, speed)
  end
  
  def turn_right(speed = MOTOR_SPEED)
      digitalWrite(@ain1, HIGH) #A1
      digitalWrite(@ain2, LOW)  #A2
      digitalWrite(@bin1, LOW)  #B1
      digitalWrite(@bin2, HIGH) #B2
      
      pwm(@pwma, speed)
      pwm(@pwmb, speed)
  end
  
  def turn_left(speed = MOTOR_SPEED)
      digitalWrite(@ain1, LOW)  #A1
      digitalWrite(@ain2, HIGH) #A2
      digitalWrite(@bin1, HIGH) #B1
      digitalWrite(@bin2, LOW)  #B2
      
      pwm(@pwma, speed)
      pwm(@pwmb, speed)
  end
  
  def stop
      digitalWrite(@ain1, LOW)  #A1
      digitalWrite(@ain2, LOW)  #A2
      digitalWrite(@bin1, LOW)  #B1
      digitalWrite(@bin2, LOW)  #B2

      pwm(@pwma, 0)
      pwm(@pwmb, 0)
    end
  
end


# CITRUS Sweeper Control Class
class CitrusSweepwer

INDEX_BODY = <<EOS
<html><head>
<title>CITRUS Sweeper</title>
<style>button {width:30%;height:256px;padding:20px;font-size:50px;} </style>
</head>
<body><form method="get">
<h1 align="center">CITRUS Sweeper<br><br><br>
<button type='submit' name='motor' value='1'>Forward</button><br><br>
<button type='submit' name='motor' value='3'>Left</button>
<button type='submit' name='motor' value='0'>Stop</button>
<button type='submit' name='motor' value='4'>Right</button><br><br>
<button type='submit' name='motor' value='2'>Backward</button><br><br>
<button type='submit' name='exit' value='1' style='width: 70%;'>EXIT</button><br>
</h1></form></body></html>
EOS

INDEX_HEADER = <<EOS
HTTP/1.1 200 OK
Server: GR-CITRUS
Content-Type: text/html
Connection: close
Content-Length: #{INDEX_BODY.length.to_s}

EOS

  def puts(s)
    @stdout.println s
  end

  def initialize(ssid, password)
    @stdout = Serial.new(0, 115200)
    @motor = TB6612Driver.new
    
    unless System.use?('WiFi')
      puts "WiFi Card can't use."
      System.exit
    end
    
    unless System.use?('SD')
      puts "Please insert a microSD card."
      System.exit
    end
    
    puts "WiFi disconnect #{ WiFi.disconnect }"
    puts "WiFi Mode Setting #{ WiFi.setMode(3) }" #Station-Mode & SoftAPI-Mode
    puts "WiFi access point #{ WiFi.softAP(ssid, password, 2, 3) }"
    puts "WiFi dhcp enable #{ WiFi.dhcp(0, 1) }"
    puts "WiFi multiConnect Set #{ WiFi.multiConnect(1) }"
    puts "WiFi ipconfig #{ WiFi.ipconfig }"
    puts "WiFi HttpServer Stop #{ WiFi.httpServer(-1) }"
    delay 100
    puts "WiFi HttpServer Start #{ WiFi.httpServer(80) }"
  end
  
  def render_index(session_number)
    WiFi.send(session_number, INDEX_HEADER)
    WiFi.send(session_number, INDEX_BODY)
  end
  
  def run
    loop do
      response, session_number = WiFi.httpServer
    
      case
      when response == "/"
        puts "#{response} #{session_number}"
        render_index(session_number)
      when response == "/?motor=0"
        @motor.stop
        led 0
        puts "#{response} #{session_number}"
        render_index(session_number)
      when response == "/?motor=1"
        @motor.forward
        led 1
        puts "#{response} #{session_number}"
        render_index(session_number)
      when response == "/?motor=2"
        @motor.backward
        led 1
        puts "#{response} #{session_number}"
        render_index(session_number)
      when response == "/?motor=3"
        @motor.turn_left
        led 1
        delay 400
        @motor.stop
        led 0
        puts "#{response} #{session_number}"
        render_index(session_number)
      when response == "/?motor=4"
        @motor.turn_right
        led 1
        delay 400
        @motor.stop
        led 0
        puts "#{response} #{session_number}"
        render_index(session_number)
      when response == "/?exit=1"
        puts "#{response} #{session_number}"
        render_index(session_number)
        break
      when response == "0,CLOSED\r\n"
        puts "#{response} #{session_number}"
      when response.to_s.length > 2 && ((response.bytes[0].to_s + response.bytes[1].to_s  == "0,") || (response.bytes[0].to_s + response.bytes[1].to_s  == "1,"))
        puts "Else(*,:#{response} #{session_number}"
      when response != 0
        puts "Else:#{response}"
        render_index(session_number)
      end
    
      delay 0
    end

    puts "WiFi HttpServer Stop #{ WiFi.httpServer(-1) }"
    puts "WiFi disconnect #{ WiFi.disconnect }"
  end

end

CitrusSweepwer.new("Sweeper 192.168.4.1", "37003700").run

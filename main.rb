#!mruby
#Ver.2.35

# Dual DC Motor Driver TB6612FNG Class
class  Tb6612
  MOTOR_SPEED = 50

  def initialize(pwma = 4, pwmb = 10, ain1 = 18, ain2 = 3, bin1 = 15, bin2 = 14)
    @pwma = pwma
    @pwmb = pwmb
    @ain1 = ain1
    @ain2 = ain2
    @bin1 = bin1
    @bin2 = bin2

    pinMode(ain1, OUTPUT)
    pinMode(ain2, OUTPUT)
    pinMode(bin1, OUTPUT)
    pinMode(bin2, OUTPUT)  
  end
  
  def  forward(speed = MOTOR_SPEED)
      digitalWrite(@ain1, HIGH)  #A1
      digitalWrite(@ain2, LOW)   #A2
      digitalWrite(@bin1, HIGH)  #B1digitalWrite(bin
      digitalWrite(@bin2, LOW)   #B2
      
      pwm(@pwma,  speed)
      pwm(@pwmb, speed)
  end
  
  def backward(speed = MOTOR_SPEED)
      digitalWrite(@ain1, LOW)   #A1
      digitalWrite(@ain2, HIGH)  #A2
      digitalWrite(@bin1, LOW)   #B1
      digitalWrite(@bin2, HIGH)  #B2
      
      pwm(@pwma,  speed)
      pwm(@pwmb, speed)
  end
  
  def turn_right(speed = MOTOR_SPEED)
      digitalWrite(@ain1, HIGH)  #A1
      digitalWrite(@ain2,  LOW)  #A2
      digitalWrite(@bin1,  LOW)  #B1
      digitalWrite(@bin2, HIGH)  #B2
      
      pwm(@pwma,  speed)
      pwm(@pwmb, speed)
  end
  
  def turn_left(speed = MOTOR_SPEED)
      digitalWrite(@ain1, LOW)   #A1
      digitalWrite(@ain2,  HIGH) #A2
      digitalWrite(@bin1,  HIGH) #B1
      digitalWrite(@bin2, LOW)   #B2
      
      pwm(@pwma,  speed)
      pwm(@pwmb, speed)
  end
  
  def stop
      pwm(@pwma, 0)
      pwm(@pwmb, 0)
  
      digitalWrite(@ain1,  LOW)  #A1
      digitalWrite(@ain2,  LOW)  #A2
      digitalWrite(@bin1,  LOW)  #B1
      digitalWrite(@bin2,  LOW)  #B2
  end
  
end

Usb = Serial.new(0,115200)

motor = Tb6612.new
Usb.println("Moter System Start.")

if(!System.use?('WiFi'))then
  Usb.println "WiFi Card can't use."
  System.exit() 
end
Usb.println "WiFi Ready"

Usb.println "WiFi disconnect #{WiFi.disconnect}"
Usb.println "WiFi Mode Setting #{WiFi.setMode 3}" #Station-Mode & SoftAPI-Mode
Usb.println "WiFi access point #{WiFi.softAP "Sweeper 192.168.4.1","37003700",2,3}"
Usb.println "WiFi dhcp enable #{WiFi.dhcp 0,1}"
Usb.println "WiFi multiConnect Set #{WiFi.multiConnect 1}"
Usb.println "WiFi ipconfig #{WiFi.ipconfig}"

Usb.println WiFi.httpServer(-1).to_s
delay 100

INDEX_BODY = <<EOS
<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>CITRUS Sweeper</title></head>
<body><form method="get" >
<h1 align="center">CITRUS Sweeper<br><br><br>
<button type='submit' name='motor' value='1' style='width: 30%; height: 256px; padding: 20px;font-size:50px;'>Forward</button><br><br>
<button type='submit' name='motor' value='3' style='width: 30%; height: 256px; padding: 20px;font-size:50px;'>Turn Left</button>
<button type='submit' name='motor' value='0' style='width: 30%; height: 256px; padding: 20px;font-size:50px;'>Stop</button>
<button type='submit' name='motor' value='4' style='width: 30%; height: 256px; padding: 20px;font-size:50px;'>Turn Right</button><br><br>
<button type='submit' name='motor' value='2' style='width: 30%; height: 256px; padding: 20px;font-size:50px;'>Backward</button><br><br>
<button type='submit' name='exit' value='1' style='width: 70%; height: 256px; padding: 20px;font-size:50px;'>EXIT</button><br>
</h1></form></body></html>
EOS

INDEX_HEADER = <<EOS
HTTP/1.1 200 OK
Server: GR-CITRUS
Content-Type: text/html
Connection: close
Content-Length: #{INDEX_BODY.length.to_s}

EOS

Usb.println WiFi.httpServer(80).to_s

def send_index_html(sesnum)
  WiFi.send(sesnum, INDEX_HEADER)
  WiFi.send(sesnum, INDEX_BODY)
end

loop do
  res, sesnum = WiFi.httpServer
  #Usb.println res.to_s
  if(res == "/")then
    Usb.println res + " " + sesnum.to_s
      
    send_index_html(sesnum)
  elsif(res == "/?motor=0")
    Usb.println res + " " + sesnum.to_s
    motor.stop
    led 0
    send_index_html(sesnum)
  elsif(res == "/?motor=1")
    Usb.println res + " " + sesnum.to_s
    motor.forward
    led 1
    send_index_html(sesnum)
  elsif(res == "/?motor=2")
    Usb.println res + " " + sesnum.to_s
    motor.backward
    led 1
    send_index_html(sesnum)
  elsif(res == "/?motor=3")
    Usb.println res + " " + sesnum.to_s
    motor.turn_left
    led 1
    send_index_html(sesnum)
  elsif(res == "/?motor=4")
    Usb.println res + " " + sesnum.to_s
    motor.turn_right
    led 1
    send_index_html(sesnum)
  elsif(res == "/?exit=1")
    Usb.println res + " " + sesnum.to_s
    
    send_index_html(sesnum)
    break
  elsif(res == "0,CLOSED\r\n")
    Usb.println res + " " + sesnum.to_s
  elsif(res.to_s.length > 2 && ((res.bytes[0].to_s + res.bytes[1].to_s  == "0,") || (res.bytes[0].to_s + res.bytes[1].to_s  == "1,")))
    Usb.println "Else(*,:" + res + " " + sesnum.to_s
  elsif(res != 0)
    Usb.println "Else:" + res.to_s
      
    send_index_html(sesnum)
  end

  delay 0
end

WiFi.httpServer(-1)
Usb.println WiFi.disconnect

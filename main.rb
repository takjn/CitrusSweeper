#!mruby
#Ver.2.24
#TB6612FNG L-L->STOP. L-H->CCW, H-L->CW, H-H->ShortBrake
MOTOR_SPEED = 30
TURN_DELAY = 100

pos = 0
vero = [4,10]
num = [18,3,15,14]
Usb = Serial.new(0)
pinMode(18, OUTPUT)
pinMode(3, OUTPUT)
pinMode(15, OUTPUT)
pinMode(14, OUTPUT)
Usb.println("Moter System Start.")

def forward
    digitalWrite(18, HIGH) #A1
    digitalWrite(3,  LOW)  #A2
    digitalWrite(15, HIGH) #B1
    digitalWrite(14, LOW)  #B2
    
    pwm(4,  100)
    pwm(10, 100)
end

def backward
    digitalWrite(18, LOW)   #A1
    digitalWrite(3,  HIGH)  #A2
    digitalWrite(15, LOW)   #B1
    digitalWrite(14, HIGH)  #B2
    
    pwm(4,  MOTOR_SPEED)
    pwm(10, MOTOR_SPEED)
end

def turn_right
    digitalWrite(18, HIGH)  #A1
    digitalWrite(3,  LOW)   #A2
    digitalWrite(15, LOW)   #B1
    digitalWrite(14, HIGH)  #B2
    
    pwm(4,  MOTOR_SPEED)
    pwm(10, MOTOR_SPEED)
end

def turn_left
    digitalWrite(18, LOW)   #A1
    digitalWrite(3,  HIGH)  #A2
    digitalWrite(15, HIGH)  #B1
    digitalWrite(14, LOW)   #B2
    
    pwm(4,  MOTOR_SPEED)
    pwm(10, MOTOR_SPEED)
end

def stop
    pwm(4,  0)
    pwm(10, 0)

    digitalWrite(18, HIGH)  #A1
    digitalWrite(3,  HIGH)  #A2
    digitalWrite(15, HIGH)  #B1
    digitalWrite(14, HIGH)  #B2
end



#ESP8266を一度停止させる(リセットと同じ)
pinMode(5,1)
digitalWrite(5,0)   # LOW:Disable
delay 500
digitalWrite(5,1)   # LOW:Disable
delay 500

Usb = Serial.new(0,115200)

if(!System.use?('WiFi'))then
  Usb.println "WiFi Card can't use."
  System.exit() 
end
Usb.println "WiFi Ready"

Usb.println "WiFi disconnect"
Usb.println WiFi.disconnect

Usb.println "WiFi Mode Setting"
Usb.println WiFi.setMode 3  #Station-Mode & SoftAPI-Mode

# Usb.println "WiFi access point"
# #Usb.println WiFi.softAP "GR-CITRUS","37003700",2,3
Usb.println WiFi.softAP "Sweeper 192.168.4.1","37003700",2,3

Usb.println "WiFi dhcp enable"
Usb.println WiFi.dhcp 0,1

Usb.println "WiFi multiConnect Set"
Usb.println WiFi.multiConnect 1

# Usb.println "WiFi connecting"
# Usb.println WiFi.connect("Weeyble01","akiba2525")

Usb.println "WiFi ipconfig"
Usb.println WiFi.ipconfig

Usb.println WiFi.httpServer(-1).to_s
delay 100

bodybtn = '<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8">'
bodybtn += '<title>CITRUS Sweeper</title></head>'
bodybtn += '<body><form method="get" >'
bodybtn += '<h1 align="center">CITRUS Sweeper<br><br><br>'
bodybtn += "<button type='submit' name='motor' value='1' style='width: 30%; height: 256px; padding: 20px;font-size:50px;'>Forward</button><br><br>"
bodybtn += "<button type='submit' name='motor' value='3' style='width: 30%; height: 256px; padding: 20px;font-size:50px;'>Turn Left</button>"
bodybtn += "<button type='submit' name='motor' value='0' style='width: 30%; height: 256px; padding: 20px;font-size:50px;'>Stop</button>"
bodybtn += "<button type='submit' name='motor' value='4' style='width: 30%; height: 256px; padding: 20px;font-size:50px;'>Turn Right</button><br><br>"
bodybtn += "<button type='submit' name='motor' value='2' style='width: 30%; height: 256px; padding: 20px;font-size:50px;'>Backward</button><br><br>"
bodybtn += "<button type='submit' name='exit' value='1' style='width: 70%; height: 256px; padding: 20px;font-size:50px;'>EXIT</button><br>"
bodybtn += "</h1></form></body></html>"
bodybtn += "\r\n\r\n"

headerbtn = "HTTP/1.1 200 OK\r\n"
headerbtn += "Server: GR-CITRUS\r\n"
headerbtn += "Content-Type: text/html\r\n"
#headerbtn += "Date: Sun, 22 Oct 2017 12:00:00 GMT\r\n"
headerbtn += "Connection: close\r\n"
headerbtn += "Content-Length: " + bodybtn.length.to_s + "\r\n\r\n"

Usb.println WiFi.httpServer(80).to_s

#header.txtを読み込む
def headview
    return
    
  fn = SD.open(0, 'header.txt', 0)
  if(fn < 0)then
    Usb.println "SD open error"
  else
    size = SD.size(fn)
    for i in 0..size
      Usb.print SD.read(fn).chr
    end
    SD.close(fn)
  end

  Usb.println WiFi.connectedIP
end

while(true)do
  res, sesnum = WiFi.httpServer
  #Usb.println res.to_s
  if(res == "/")then
    Usb.println res + " " + sesnum.to_s
      
    WiFi.send(sesnum, headerbtn)
    WiFi.send(sesnum, bodybtn)

    headview()
  elsif(res == "/?motor=0")
    Usb.println res + " " + sesnum.to_s
    stop
    led 0
    WiFi.send(sesnum, headerbtn)
    WiFi.send(sesnum, bodybtn)
    headview()
  elsif(res == "/?motor=1")
    Usb.println res + " " + sesnum.to_s
    forward
    led 1
    WiFi.send(sesnum, headerbtn)
    WiFi.send(sesnum, bodybtn)
    headview()
  elsif(res == "/?motor=2")
    Usb.println res + " " + sesnum.to_s
    backward
    led 1
    WiFi.send(sesnum, headerbtn)
    WiFi.send(sesnum, bodybtn)
    headview()
  elsif(res == "/?motor=3")
    Usb.println res + " " + sesnum.to_s
    turn_left
    led 1
    WiFi.send(sesnum, headerbtn)
    WiFi.send(sesnum, bodybtn)
    headview()
  elsif(res == "/?motor=4")
    Usb.println res + " " + sesnum.to_s
    turn_right
    led 1
    WiFi.send(sesnum, headerbtn)
    WiFi.send(sesnum, bodybtn)
    headview()
  elsif(res == "/?exit=1")
    Usb.println res + " " + sesnum.to_s
    
    WiFi.send(sesnum, headerbtn)
    WiFi.send(sesnum, bodybtn)
    headview()
    break
  elsif(res == "0,CLOSED\r\n")
    Usb.println res + " " + sesnum.to_s
    
    headview()
  elsif(res.to_s.length > 2 && ((res.bytes[0].to_s + res.bytes[1].to_s  == "0,") || (res.bytes[0].to_s + res.bytes[1].to_s  == "1,")))
    Usb.println "Else(*,:" + res + " " + sesnum.to_s
  
    headview()
  elsif(res != 0)
    Usb.println "Else:" + res.to_s
      
    WiFi.send(sesnum, headerbtn)
    WiFi.send(sesnum, bodybtn)
    headview()
  end
  delay 0
end

#WiFi.send 0, "OK"
WiFi.httpServer(-1)
Usb.println WiFi.disconnect

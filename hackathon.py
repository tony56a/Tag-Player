import serial
import pygame
import datetime
import os

def change_to_lowercase():
	for filename in os.listdir("."):
		os.rename(filename,filename.lower())

#change all filenames to lowercase
change_to_lowercase()
#Serial port for bluetooth connection
ser = serial.Serial(2,115200,5)
#Opens up the list of keys
f = open('list.txt','r')
#reads, throws away the instruction lines
f.readline()
f.readline()
f.readline()
f.readline()
f.readline()
#reads the list of IDs, names, and song start times
IDlist = f.readlines()
nameList = IDlist[:]
times = IDlist[:]
# put them into seperate lists
for i in range(len(IDlist)):
	print IDlist[i].split(",")
	times[i] = float(IDlist[i].split(",")[2])
	nameList[i] = IDlist[i].split(",")[1]
	IDlist[i] = IDlist[i].split(",")[0]

f.close()

# start the pygame audio mixer
pygame.mixer.init()


while 1:
	#write a byte to the bluetooth adapter,
	#since it will disconnect after a while of inactivity
	ser.write(" ")
	#get the time
	time = datetime.datetime.now()
	weekday = time.weekday()
	hour = time.hour
	minute = time.minute
	
	#clear the buffer for the bluetooth serial port,and get the id
	ser.flushInput()
	ser.flushOutput()	
	string = ser.read(15)
	print "ID:"+string[1:13]
	# # if after 10am, and before 3pm, you're late!
	# if hour > 9 and hour < 14:
		# pygame.mixer.music.stop()
		# pygame.mixer.music.load("late.ogg")
		# pygame.mixer.music.play(0,29.1)
		# ser.write("<Hi! You're Late!>")
	# # if before 9am, you're early!
	# elif hour < 8 :
		# pygame.mixer.music.stop()
		# pygame.mixer.music.load("early.ogg")
		# pygame.mixer.music.play(0,29.7)
		# ser.write("<Morning! You're Early!>")
	# # if it's friday, TGIF!
	# elif weekday == 4:
		# pygame.mixer.music.stop()
		# pygame.mixer.music.load("friday.ogg")
		# pygame.mixer.music.play(0,44.4)
		# ser.write("<Happy Friday!>")
	#otherwise, look for IDs, and play the song that matches up with the correct ID
	
	foundName = False
	for j in range(len(IDlist)):
		if (IDlist[j].find(string[2:13]) >=0  or IDlist[j].find(string[1:13]) >=0 ):
			foundName = True
			pygame.mixer.music.stop()
			if (nameList[j].lower().find("kristel") >=0):
				pygame.mixer.music.set_volume(0.5)
			pygame.mixer.music.load(nameList[j].lower().split("\n")[0]+".ogg")
			pygame.mixer.music.play(0,times[j])
			if hour<12:
				ser.write("<Morning, "+nameList[j]+"!>")
			elif hour > 12 and hour < 17 :
				ser.write("<Afternoon, "+nameList[j]+"!>")
			else :
				ser.write("<Evening, "+nameList[j]+"!>")
			break
	if not foundName:
		ser.write("<Whoops! "+"No/song/here...>")		
	#fadeout after 12 seconds,reset the ID string
	pygame.mixer.music.fadeout(12000)
	string = ""
	

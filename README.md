Tag-Player
==========

An Arduino-based RFID keytag scanner, with a Python script on a remote computer playing audio clips linked to tag IDs. Includes a character LCD to display ambient content on card reader.

Developed during the March Wattpad internal hackathon, requires PySerial and PyGame libraries.

Arduino Sketch
==============

The sketch interfaces with the RFID reader,and a Bluetooth module via UART connections, and formats data to send to the computer, as well as display messages sent from the computer via Bluetooth. 
![diagram](https://github.com/tony56a/Tag-Player/blob/master/image.png?raw=true)

Python Script
=============

The script reads a text file with the list of RFID tags and asscoiated audio files,and maintains a constant connection to the reader via Bluetooth. Upon reciving files, it will compare with the list of IDs, and play the matching clip using PyGame.
# 6.111 Dance Dance Revolution
Final project for MIT 6.111: Introductory Digital Systems Laboratory.
The gameplay is exactly like normal Dance Dance Revolution, but the player's steps are detected by the interruption of a laser beam. The player is in a square whenever an intersection of lasers is interrupted. We used six lasers in order to create nine intersections. 

The software for our project can be broken down into five main areas: 
* Visual 
  * Handles all of the images that appear on the screen during the game. 
* Selector 
  * Handles menu display and user input to determine the settings for each game.
* Sensor 
  * Processes input from six phototransistors to determine where a player is stepping at a given time. 
* Game 
  * Compares the input from the sensors with the correct choreography in order to decide how to score the player on a given step.
* Audio 
  * Communicates with an SD card in order to play audio during the game.
  
All COE files needed to recreate the ROM's are all located in the coe_files folder.

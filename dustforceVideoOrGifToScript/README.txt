imagemagick and ffmpeg need to be installed and added to your PATH system environment variable for this
batch file to work. the "code" file also needs to be in the same directory as convert.bat.

Instructions:
1. Drag .gif / video file onto .bat file
2. Take the frames folder that is output and place it into your .../Dustforce/user/embed_src folder
3. Place the .as file which was put into the .../Dustforce/user/script_src folder
4. Add the script to your map and the script should compile and embed the sprite

Notes:
Bat file converts video file to 10fps. If you want to change this, open the .bat file and adjust the fps
argument to your desired fps. The .as file will also need this line:

if(frame_count%8 == 0)

adjusted to be:

if(frame_count%round(60/YOUR_CHOSEN_FPS) == 0)

where YOUR_CHOSEN_FPS is the fps you changed in the bat file.
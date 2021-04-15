@ECHO OFF
if not exist "frames" mkdir frames
ffmpeg -i %1 -vf fps=10 frames/out%%d.png
cd frames
magick mogrify -define png:format=png32 -format png *.png
for /f %%A in ('dir ^| find "File(s)"') do set cnt=%%A
cd ..
ECHO const int NUM_FRAMES = %cnt%; > animated.as
FOR /L %%v IN (0,1,%cnt%) do (ECHO const string EMBED_out%%v = "frames/out%%v.png";) >> animated.as
type code >> animated.as
PAUSE
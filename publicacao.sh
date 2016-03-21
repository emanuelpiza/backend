#!/bin/bash

equipe="$1"
dia=$(date "--date=${dataset_date} -2 day" +%Y%m%d)
dia_pasta=$(date "--date=${dataset_date} -2 day" +%Y-%m-%d)
horario="$2"
duracao="$3"
trechos=$((duracao/30))

for(( cont=0; cont<trechos; cont++ ))
do
   minutos=$((36*$cont))
   horamin=$(date -d "$horario today + $minutos minutes" +'%H%M')
   ffmpeg -i ./${dia_pasta}/001/HDCVI_ch1_main_${dia}${horamin}* -vf "crop=1400:1080:0:0" -filter:v "setpts=1.666666666666*PTS" ./${dia_pasta}/ch1_$cont.mp4
   ffmpeg -i ./${dia_pasta}/002/HDCVI_ch2_main_${dia}${horamin}* -vf "crop=1400:1080:460:0" -filter:v "setpts=1.666666666666*PTS" ./${dia_pasta}/ch2_$cont.mp4
   ffmpeg -i ./${dia_pasta}/ch1_$cont.mp4 -i ./${dia_pasta}/ch2_$cont.mp4 -filter_complex "[0:v:0]pad=iw*2:ih[bg]; [bg][1:v:0]overlay=w" ./${dia_pasta}/merge_$dia_$cont.mp4
done


printf "file '%s'\n" ./${dia_pasta}/merge* > ./merge.txt & wait

rm -f ./${dia_pasta}/ch* 


ffmpeg -f concat -i ./merge.txt -c copy ./${dia_pasta}/$dia.mp4 & wait

python ./upload/upload_video.py --file=./${dia_pasta}/$dia.mp4 --title="$equipe" --description="Jogo no Paradiso Futebol Society" --keywords="futebol, futebol society" --category=17 --privacyStatus="unlisted" 

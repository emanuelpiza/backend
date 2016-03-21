#!/bin/bash

equipe="$1"
dia=$(date "--date=$2" +%Y%m%d)
dia_pasta=$(date "--date=$2" +%Y-%m-%d)
horario="$3"
duracao="$4"
trechos=$((duracao/30))
inicio="$5"

for(( cont=0; cont<trechos; cont++ ))
do
   minutos=$((36*$cont))
   horamin=$(date -d "$horario today + $minutos minutes" +'%H%M')
   ffmpeg -i ./${dia_pasta}/001/HDCVI_ch1_main_${dia}${horamin}* $inicio -vf "crop=1400:1080:0:0" ./${dia_pasta}/ch${horario}1_$cont.mp4
   ffmpeg -i ./${dia_pasta}/002/HDCVI_ch2_main_${dia}${horamin}* $inicio -vf "crop=1400:1080:460:0" ./${dia_pasta}/ch${horario}2_$cont.mp4
   inicio="" 
done

printf "file '.%s'\n" ./${dia_pasta}/ch${horario}1_* > ./${dia_pasta}/ch${horario}1.txt & wait

ffmpeg -f concat -i ./${dia_pasta}/ch${horario}1.txt -c copy ./${dia_pasta}/ch${horario}final1.mp4 & wait

printf "file '.%s'\n" ./${dia_pasta}/ch${horario}2_* > ./${dia_pasta}/ch${horario}2.txt & wait

ffmpeg -f concat -i ./${dia_pasta}/ch${horario}2.txt -c copy ./${dia_pasta}/ch${horario}final2.mp4 & wait

ffmpeg -i  ./${dia_pasta}/ch${horario}final1.mp4 -i  ./${dia_pasta}/ch${horario}final2.mp4 -filter_complex "[0:v:0]pad=iw*2:ih[bg]; [bg][1:v:0]overlay=w" ./${dia_pasta}/${dia}${horario}.mp4 & wait

python ./upload/upload_video.py --file=./${dia_pasta}/${dia}${horario}.mp4 --title="$equipe $dia" --description="Jogo no Paradiso Futebol Society" --keywords="futebol, futebol society" --category=17 --privacyStatus="unlisted" 

#rm -rf ./${dia_pasta}/ch${horario}*

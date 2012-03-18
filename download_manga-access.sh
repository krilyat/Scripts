#!/bin/bash
#set -x
ConcurentDownloadChapter="10"
Parallel="0"

Manga=$1
Dir=${2}
ThisChapter=$3
BaseDir=$(cd $Dir && pwd)
BaseUrl="http://www.manga-access.com"
MATURE="?mature_confirm=1" # for manga like doubt
Uri="/manga/${1:0:1}/$1/"

CurlPage="/usr/bin/curl --silent "
CurlDl="/usr/bin/curl -O "
Wget="/usr/bin/wget"

function CatchChapter () {

Url="${BaseUrl}${Uri}${MATURE}"
echo "Retriving Chapters"
for Chapter in $(${CurlPage[@]} $Url | grep '<em>chapter</em>' | awk -F'"' '{print $4}' | sort -t'/' -k6n) ;do
    if [ $Parallel -ge $ConcurentDownloadChapter ] ;then
        wait
        Parallel="0"
    fi
    
    Parallel=$(($Parallel+1))
    #TestFunction $Chapter $Parallel &
    CatchPage $Chapter &

done
}

function TestFunction () {
echo "$1 $2"
sleep 10


}
function CatchThisChapter () {
Url="${BaseUrl}${Uri}"
StartChapter=$ThisChapter
EndChapter=$ThisChapter
if [[ $ThisChapter =~ "[0-9]*-[0-9]*" ]] ;then
    StartChapter=$(echo $ThisChapter | cut -d'-' -f1)    
    EndChapter=$(echo $ThisChapter | cut -d'-' -f2)    
    
    echo "Retriving from Chapter $StartChapter to $EndChapter"
else

    echo "Retriving Chapter $ThisChapter"
fi

for ChapterS in $(seq $StartChapter $EndChapter) ;do
    if [ $Parallel -ge $ConcurentDownloadChapter ] ;then
        wait
        Parallel="0"
    fi
    for Chapter in $(${CurlPage[@]} $Url | grep '<em>chapter</em>' | awk -F'"' '{print $4}' | sort -t'/' -k6n | grep "/$ChapterS\$") ;do
        Parallel=$(($Parallel+1))
        
        CatchPage $Chapter &

    done
done
}

function CatchPage () {
Chapter=$1
Dir=$(echo $Chapter | awk -F'/' '{print $NF}')
if [ ${#Dir} -eq 1 ] ;then
    Dir="00$Dir"
elif [ ${#Dir} -eq 2 ] ;then
    Dir="0$Dir"
fi
Url="${BaseUrl}${Chapter}"

if [ -d "$BaseDir/$Dir" ] ;then
    echo "Chapter $Chapter Already Retrive"
else
    echo "Retriving pages from Chapter : $Chapter"
    mkdir "$BaseDir/$Dir" 
    cd "$BaseDir/$Dir"
    for Page in $(${CurlPage[@]} $Url | grep -i "href=\"$Chapter/" | awk -F'"' '{for(i=2;i<NF;i=i+2){print $i}}') ;do
        DownloadImage $Page
    done
fi
}

function DownloadImage () {

Page=$1
RealPage=$(echo $Page | awk -F'/' '{print $NF}')
Url="${BaseUrl}${Page}"
UrlImage=$(${CurlPage[@]} $Url | grep '<img style="cursor: pointer;" src="' | cut -d'"' -f4)


${CurlDl[@]} $UrlImage &>/dev/null
if [ $? -eq 0 ] ;then
echo -ne "Downloading Page $RealPage into $PWD ..." > /dev/null
    echo " ...SUCCESS" > /dev/null
else
echo -ne "Downloading Page $RealPage into $PWD ..."
    echo "FAIL"
fi

}

RenameChapter() {
cd $BaseDir
for Page in $(find . -type f -name '[0-9].???') ;do 
    mv $Page $(echo $Page | sed 's/\([0-9]\.[a-z][a-z][a-z]\)/00\1/') 
done
for Page in $(find . -type f -name '[0-9]-[0-9].???') ;do 
    mv $Page $(echo $Page | sed 's/\([0-9]\)-\([0-9]\.[a-z][a-z][a-z]\)/00\1-00\2/') 
done
for Page in $(find . -type f -name '[0-9][0-9].???') ;do 
    mv $Page $(echo $Page | sed 's/\([0-9][0-9]\.[a-z][a-z][a-z]\)/0\1/') 
done
for Page in $(find . -type f -name '[0-9][0-9]-[0-9][0-9].???') ;do 
    mv $Page $(echo $Page | sed 's/\([0-9][0-9]\)-\([0-9][0-9]\.[a-z][a-z][a-z]\)/0\1-0\2/') 
done

}
case $# in
2) CatchChapter
    RenameChapter;;
3) CatchThisChapter
    RenameChapter;;
*) exit 1
esac



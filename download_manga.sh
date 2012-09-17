#!/bin/bash
#set -x

FORCE="0"
_usage() {
cat << ENDUSAGE
usage: $0 -s SITE -m MANGA -d DIR
    -s : Download site
    -m : manga to download
    -d : destination directory (The chapter and manga directory will be created)
    -f : force retriving
    -h : affiche cet aide
ENDUSAGE
}

_MakeDirectoryStructure(){
if [ -d $DIR ] ;then
    if [ -d ${DIR}/${MANGA} ] ;then
        _DetectSite
    else
        mkdir ${DIR}/${MANGA}
        _DetectSite
    fi
else
    echo "$DIR doesn't exist"
    _usage
    exit 1
fi
}

_DetectSite() {
case $SITE in
"japanshin") _DownloadJapanShin;;
*)echo "$SITE" not suported;;
esac
}

_DownloadJapanShin() {
readonly BASEURL="http://www.japan-shin.com/lectureenligne/reader/series/${MANGA}/"
readonly CURLOPTS='--silent --user-agent "Mozilla/4.0" --max-time 60'
readonly ListUrlChapter=$(curl ${CURLOPTS[@]} $BASEURL | grep '<div class="title"><a href=' | awk -F'"' '{print $4}')

for CHAPTER in $(echo "$ListUrlChapter");do
    _CreateChapterDir $CHAPTER
done
}

_CreateChapterDir(){
CHAPTERURL=$1
ChapterNumber=$(echo "$CHAPTERURL" | awk -F'/' '{print $(NF-1)}')

case ${#ChapterNumber} in
    1)  ChapterNumber="00${ChapterNumber}";;
    2)  ChapterNumber="0${ChapterNumber}";;
esac

if [ -d ${DIR}/${MANGA}/$ChapterNumber ] ;then
    if [ $FORCE -ne "0" ] ;then
        mv ${DIR}/${MANGA}/$ChapterNumber ${DIR}/${MANGA}/${ChapterNumber}_old
        mkdir ${DIR}/${MANGA}/$ChapterNumber
        _GetJapanShinPages "$CHAPTERURL" ${DIR}/${MANGA}/$ChapterNumber
    fi
else
    mkdir ${DIR}/${MANGA}/$ChapterNumber
    _GetJapanShinPages "$CHAPTERURL" ${DIR}/${MANGA}/$ChapterNumber
fi
}

_GetJapanShinPages() {
CHAPTERURL=$1
DEST=$2
ListUrlPages=$(curl ${CURLOPTS[@]} "$CHAPTERURL" | grep '<ul class="dropdown" style="width:90px;"><li><a href=' | tr '=' '\n' | grep "$MANGA" | cut -d'"' -f2)
for PAGES in $(echo "$ListUrlPages");do
     _DownloadJapanShinImg $PAGES $DEST
done
}

_DownloadJapanShinImg(){
PAGEURL=$1
DESTDIR=$2
JPEGURL=$(curl ${CURLOPTS[@]} $PAGEURL | grep '<img class="open" src="' | awk -F'"' '{print $(NF-1)}')
RealPage=$(echo $PAGEURL | awk -F'/' '{print $NF}')
Ext=$(echo "$JPEGURL" | awk -F'.' '{print tolower($NF)}')

case ${#RealPage} in
1)RealPage="00${RealPage}.$Ext";;
2)RealPage="0${RealPage}.$Ext";;
esac
echo "downloading $PAGEURL ..."
curl ${CURLOPTS[@]} "$JPEGURL" -o $DESTDIR/$RealPage 
}

#Gestion des arguments
while getopts hfd:s:m: OPT; do
case "${OPT}" in
    h)  _usage
        exit 0;;
    s)  readonly SITE="${OPTARG}";;
    m)  readonly MANGA="${OPTARG}";;
    d)  readonly DIR="${OPTARG}";;
    f)  readonly FORCE="1";;
    *)  echo "Option non reconnue ${OPT}"
        _usage
        exit 1;;
esac
done
#Gestion des Variables nécessaire
if [ -z $SITE ] ;then 
    echo "-s SITE is required"
    _usage
    exit 1
elif [ -z $MANGA ] ;then
    echo "-m MANGA is required"
    _usage
    exit 1
elif [ -z $DIR ] ;then
    echo "-d DIR is required"
    _usage
    exit 1
fi

_MakeDirectoryStructure

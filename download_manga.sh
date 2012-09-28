#!/bin/bash
#set -x

FORCE="0"
_log(){
    if ! [ -z $VERBOSE ] ;then
        echo $@ | tee /tmp/logmanga
    fi
}

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
        _log "${DIR}/${MANGA} already exist ..."
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
"japanshin") _log "SITE is japanshin ..."
    _DownloadJapanShin;;
*)echo "$SITE" not suported;;
esac
}

_DownloadJapanShin() {
readonly BASEURL="http://www.japan-shin.com/lectureenligne/reader/series/${MANGA}/"
readonly CURLOPTS='--silent --user-agent "Mozilla/4.0" --max-time 60'
readonly ListUrlChapter=$(curl ${CURLOPTS[@]} $BASEURL | grep '<div class="title"><a href=' | awk -F'"' '{print $4}')

for CHAPTER in $(echo "$ListUrlChapter");do
    _log "processing $CHAPTER"
    _CreateChapterDir $CHAPTER
done
}

_CreateChapterDir(){
CHAPTERURL=$1
#ChapterNumber=$(echo "$CHAPTERURL" | awk -F'/' '{print $(NF-1)}')
ChapterNumber=$(echo "$CHAPTERURL" | awk -F'/' '{i=1;while($i!=0){i++}{for(j=i+1;j<NF;j++){if(chap==""){chap=$j}else{chap=chap"."$j}}}{print chap}}')
_log "-e $CHAPTERURL\n $ChapterNumber"
if [[ $ChapterNumber =~ [0-9]+\\\.[0-9]  ]] ;then
    _log "chapter like xx.xx"
    case ${#ChapterNumber} in
        3)  ChapterNumber="00${ChapterNumber}";;
        4)  ChapterNumber="0${ChapterNumber}";;
    esac

else
    _log "chapter like xx"
    case ${#ChapterNumber} in
        1)  ChapterNumber="00${ChapterNumber}";;
        2)  ChapterNumber="0${ChapterNumber}";;
    esac
fi

if [ -d ${DIR}/${MANGA}/$ChapterNumber ] ;then
    if [ $FORCE -ne "0" ] ;then
    _log "FORCE option ON"
        _log "renaming old directory"
        _log "-e \t mv ${DIR}/${MANGA}/$ChapterNumber ${DIR}/${MANGA}/${ChapterNumber}_old"
        mv ${DIR}/${MANGA}/$ChapterNumber ${DIR}/${MANGA}/${ChapterNumber}_old
        _log "creating new one"
        mkdir ${DIR}/${MANGA}/$ChapterNumber
        _log "getting pages"
        _log "-e \t _GetJapanShinPages "$CHAPTERURL" ${DIR}/${MANGA}/$ChapterNumber"
        _GetJapanShinPages "$CHAPTERURL" ${DIR}/${MANGA}/$ChapterNumber
    fi
else
    _log "create directory ${DIR}/${MANGA}/$ChapterNumber"
    mkdir ${DIR}/${MANGA}/$ChapterNumber
    _GetJapanShinPages "$CHAPTERURL" ${DIR}/${MANGA}/$ChapterNumber
fi
}

_GetJapanShinPages() {
CHAPTERURL=$1
DEST=$2
ListUrlPages=$(curl ${CURLOPTS[@]} "$CHAPTERURL" | grep '<ul class="dropdown" style="width:90px;"><li><a href=' | tr '=' '\n' | grep "$MANGA" | cut -d'"' -f2)
for PAGES in $(echo "$ListUrlPages");do
    _log "download pages $PAGES"
    _DownloadJapanShinImg $PAGES $DEST
done
}

_DownloadJapanShinImg(){
PAGEURL=$1
DESTDIR=$2
JPEGURL=$(curl ${CURLOPTS[@]} $PAGEURL | grep '<img class="open" src="' | awk -F'"' '{print $(NF-1)}' | sed 's! !%20!g')
RealPage=$(echo $PAGEURL | awk -F'/' '{print $NF}')
Ext=$(echo "$JPEGURL" | awk -F'.' '{print tolower($NF)}')

case ${#RealPage} in
1)RealPage="00${RealPage}.$Ext";;
2)RealPage="0${RealPage}.$Ext";;
esac
echo "downloading $PAGEURL ..."
_log "-e \t curl ${CURLOPTS[@]} "$JPEGURL" -o $DESTDIR/$RealPage"
curl ${CURLOPTS[@]} "$JPEGURL" -o $DESTDIR/$RealPage 
}

#Gestion des arguments
while getopts vhfd:s:m: OPT; do
case "${OPT}" in
    h)  _usage
        exit 0;;
    s)  readonly SITE="${OPTARG}";;
    m)  readonly MANGA="${OPTARG}";;
    d)  readonly DIR="${OPTARG}";;
    f)  readonly FORCE="1";;
    v)  readonly VERBOSE="1";;
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

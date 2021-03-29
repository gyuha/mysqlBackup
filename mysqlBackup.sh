#!/bin/bash

# 사용법에 대한 함수.

function print_usage()
{
	echo "`basename $0` [Setting File] [Restore Host]"
	echo " -h : help"
	echo " -f : Setting file name"

	exit 1
}

# 만약 파라메터가 없으면 종료.
if [ $# -eq 0 ]
then
	print_usage
fi

#########################################
# MySQL 백업 Script #
#########################################
DB_INFO_FILE=""
while getopts hp:v o
do
	case "$o" in
		h)
		print_usage 0;;
		*)
		DB_INFO_FILE=$2
		;;
	esac
done
shift $(($OPTIND - 1))

# 해당 파일이 존재하지 않으면 에러를 출력하고 종료한다.
[ ! -f "$1" ] && echo "[ERROR] "$1" is not exist" && exit 1
DB_INFO_FILE=`echo "$1" | tr '\\\\' '/'`

source $DB_INFO_FILE

# 백업 폴더가 없으면 종료.
if [ ! -d $BACKUP_DIR ]
then
	echo "BACKUP_DIR Can not be found."
	echo "Check $1 file"
	exit 1
fi

# 날짜 지정-파일명-저장 디렉토리 설정
DATE=`/bin/date +%Y%m%d-%H%M%S`
PREFIX="$DB_NAME-Backup"
FILEPREFIX="$PREFIX-$DATE"
BACKUP_LOG="$BACKUP_DIR/backup.log"
RESTORE=$2

# 예외 폴더 지정
IGNORED_TABLES_STRING=''
for TABLE in "${EXCLUDED_TABLES[@]}"
do :
	IGNORED_TABLES_STRING+=" --ignore-table=${DATABASE}.${TABLE}"
done


#########################################
# backup
#########################################
# /usr/local/mysql/bin/mysqldump 절대 경로를 모두 써주는 것이 좋다.
start_time=`date +%s`
mysqldump -h$HOST -u$USERNAME -p$PASSWORD --column-statistics=0 -R --databases $DATABASE $IGNORED_TABLES_STRING > $BACKUP_DIR/$FILEPREFIX.sql
cd $BACKUP_DIR
if [  ${#RESTORE} -ne 0 ]
then
	echo "Restore Database"
	mysql -h$RESTORE -uroot -p < $FILEPREFIX.sql
fi
echo "Compress Database backup file"
tar -zcf $FILEPREFIX.tar.gz $FILEPREFIX.sql
rm -f $FILEPREFIX.sql
end_time=`date +%s`

elapsed_time=$[ $end_time - $start_time ]
echo "날짜 	 : "`date` 							>> "$BACKUP_LOG"
echo "파일명   : $FILEPREFIX"".tar.gz"			>> "$BACKUP_LOG"

# 일정 갯수 이상은 제거
t=30
i=`ls $PREFIX*.tar.gz|wc -l`
if [ $i -gt $t ]
then
	i=`expr $i - $t`
else
	i=0
fi

rm -rf `ls $PREFIX*.tar.gz|head -$i`;

#if [ $i -gt 0 ]; then
#	echo "삭제 파일" 				>> "$BACKUP_LOG"
#	echo `ls -l -h $PREFIX*.tar.gz|head -$i` 	>> "$BACKUP_LOG"
#fi

echo "삭제백업 : $i 개" 			>> "$BACKUP_LOG"
echo "수행시간 : $elapsed_time""sec" 	>> "$BACKUP_LOG"
echo "################################################################" >> "$BACKUP_LOG"

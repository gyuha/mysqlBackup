mysqlBackup
===========

mysql backup shell script

== 설정

설정값 입력
	DB_NAME="sample"

	HOST=localhost
	USERNAME="root"
	PASSWORD="password"

	# 특정 데이터베이스 백업
	DATABASE="mysql test"
	# --all-databases일 경우 전체 DB 백업
	#DATABASE="--all-databases"

	BACKUP_DIR=`pwd`"/sample"

예) sample.db

== 사용방법
./mysqlBackup.sh [설정 파일]




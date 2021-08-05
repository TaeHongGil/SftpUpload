
############ 타겟폴더, sftp폴더버전
forderName=
version=
############ sftp 정보
sftpServer=
sftpPath=
############

#~/.ssh/key파일이름
# keyFileName=id_rsa

#server config파일 없으면 생성
# if [ ! -e ~/.ssh/config ]; then
#     echo "
# Host Take5
#     HostName take5-dev.doubleugames.com
#     User ec2-user
#     IdentityFile ~/.ssh/$keyFileName
#         " > ~/.ssh/config
# fi

#p7zip 설치
7z -h
if [ $? -eq 0 ]; then
    echo ""
else
    brew install p7zip
fi

# #sftp 첫 접속시 에러메세지 처리가 되는지 모르겠어서 넣음
# sftp $sftpServer <<EOF
# bye
# EOF

#sftp 경로 없으면 exit (첫접속시 에러메세지 확인되는지 모름)
echo "ls $sftpPath" | sftp -b - $sftpServer
if [ $? -eq 0 ]; then
    echo ""
else
    echo "
sftp error : check version or sftpPath"
    exit
fi

#resource폴더 생성
if [ ! -e ~/Desktop/resource ]; then
    mkdir ~/Desktop/resource
fi

#resource_backup폴더 생성
if [ ! -e ~/Desktop/resource_backup ]; then
    mkdir ~/Desktop/resource_backup
fi

#타겟폴더 없으면 exit
if [ ! -e ~/Desktop/resource/$forderName ]; then
    echo "~/Desktop/resource/$forderName not exist"
    exit
fi

cd ~/Desktop/resource
7z a $forderName.zip ./$forderName
#zip파일 없으면 exit
if [ ! -e ~/Desktop/resource/$forderName.zip ]; then
    echo "~/Desktop/resource/$forderName.zip not exist"
    exit
fi

mv -n ./$forderName ../resource_backup/
day=$(date | awk '{print $3$5$6$7}')
mv ../resource_backup/$forderName ../resource_backup/$forderName\_$day
size=$(7z x -y $forderName.zip | grep -A 2 "Size\:")

sftp $sftpServer <<EOF
cd $sftpPath
put $forderName.zip
bye
EOF

echo "

File Size"
echo "version : $version"
echo $size | awk '{print "zip     : " $4 "\nforder  : " $2}'
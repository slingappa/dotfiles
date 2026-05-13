sudo kill -9 `ps -ef | grep -i qemu | grep -v grep | grep $USER | awk '{print $2}'`
#sudo kill -9 `ps -ef | grep -i qemu | grep -v grep | grep $USER | tail -1 | awk '{print $2}'`
sudo kill -9 `ps -ef | grep -i http.server | grep -v grep | grep $USER | awk '{print $2}'`
#sudo kill -9 `ps -ef | grep zoom | grep -v grep | awk '{print $2}'`
#sudo kill -9 `ps -ef | grep global | grep -v grep | awk '{print $2}'`


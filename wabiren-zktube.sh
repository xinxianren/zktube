#color
red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'

#prefix
info="${green}[信息]${none}"
error="${red}[错误]${none}"

#show
show_error(){
  echo -e "${Error}" "$1"
}

script_url="https://raw.githubusercontent.com/pumpkin4gb/MinerTools/main/Zktube/wabiren-zktube.sh"
_version="beta"


install() {
	[[ -f ~/wabiren-zkt/docker-compose.yml && -f ~/.revenue_address ]] && echo -e "当前用户已安装[挖币人zkTube工具]，请卸载后重新安装。" && return
	echo "开始安装……"
    sudo apt-get remove docker docker-engine docker.io containerd runc > /dev/null 2>&1
    curl -fsSL https://get.docker.com | bash -s docker
    sudo apt-get update
    sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common
    curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
       "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/ \
      $(lsb_release -cs) \
      stable"
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    docker-compose --version
    read -p "输入ETH钱包地址:" ETH_address
    echo $ETH_address > ${HOME}/.revenue_address
    mkdir ${HOME}/wabiren-zkt
    wget -O ${HOME}/.zktool/docker-compose.yml https://file.zktube.io/docker/prover/docker-compose.yml 
	cd ${HOME}/wabiren-zkt
    docker-compose -f ${HOME}/wabiren-zkt/docker-compose.yml up -d 
    docker-compose ps
}

uninstall(){
	[[ ! -d ${HOME}/wabiren-zkt ]] && echo -e "当前用户未安装[挖币人zkTube工具]。" && return
  echo "正在停止zktube……"
  docker-compose stop > /dev/null 2>&1
  sleep 2
  docker-compose rm > /dev/null 2>&1
  rm -f ~/.revenue_address
  rm -rf ~/wabiren-zkt
  read -p "$(echo -e "(是否卸载docker？[${magenta}Y/n$none]):")" bool_remove_docker
  case $bool_remove_docker in
  	[Yy])	
	  	sudo apt-get remove docker docker-engine docker.io containerd runc
  		;;
  	*)
  		echo "保留docker。"
  		;;
  	esac
  read -p "$(echo -e "(是否删除此脚本文件？ [${magenta}Y/n$none]):") " bool_remove_self
  case $bool_remove_self in
	  [Yy])	
	  	sleep 2
  		rm $0
  		;;
  	*)
      echo "保留脚本文件。"
		;;
	esac
}

diff_file(){
  cmp -s $1 $2
  if [ $? -eq 1 ]
  then
    return 0
  else
    return 1
  fi
}

update_script(){
  echo "正在检查脚本是否有更新……"
  wget ${script_url} -O /tmp/wabiren-zktube.sh -o /tmp/zktupdate.log
  if grep "‘/tmp/wabiren-zktube.sh’ saved" /tmp/zktupdate.log > /dev/null 2>&1
  then
    if diff_file /tmp/wabiren-zktube.sh ${HOME}/wabiren-zktube.sh
    then
      mv /tmp/wabiren-zktube.sh ${HOME}/wabiren-zktube.sh
      chmod a+x ${HOME}/wabiren-zktube.sh
      echo "脚本已更新并退出，重新运行以使更新生效，如更新后异常请到https://github.com/runbzz/zktube查看说明或反馈。"
      exit
    else
      echo "脚本尚无更新可用。"
    fi
  else
    show_error "无法连接更新服务，请检查网络状况并重试。多次连接失败请到https://github.com/runbzz/zktube查看说明或反馈。"
  fi
}

clear
while :; do
	echo
	echo "..................... Zktube Helper...................."
	echo
	echo "版本号：$_version"
	echo
	echo "官方网址：https://www.xinxianren.com"
	echo
	echo "详细教程：https://www.xinxianren.com"
	echo
	echo "注意：此脚本仅适用于Ubuntu环境！"
	echo
	echo " 1. 安装"
	echo
	echo " 2. 卸载"
	echo
	echo " 3. 更新"
	echo
	echo " 4. 退出"
	echo
	read -p "$(echo -e "请选择 [${magenta}1-4$none]:")" choose
	case $choose in
	1)
		install
		break
		;;
	2)
		uninstall
		break
		;; 
	3)
		update_script
		break
		;; 
	*)
		break
		;;
	esac
done

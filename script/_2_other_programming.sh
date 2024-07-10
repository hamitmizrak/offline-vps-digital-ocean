#!/bin/bash
echo "Genel Kurulumlar"

# User Variable
UPDATED="Güncelleme"
CLEANER="Temizleme"
INSTALL="Yükleme"
DELETED="Silme"
CHMOD="Erişim İzni"
INFORMATION="Genel Bilgiler Ports | NETWORKING"
UFW="Uncomplicated Firewall Ggüvenlik duvarı Yöentim Araçı"
LOGOUT="Sistemi Tekrar Başlatmak"
CHECK="Yüklencek Paket bağımlılıkları"
PACKAGE="Paket Sistemde Yüklü mü"
DOCKER_PULL="Docker Pulling"
LOGIN="Docker Login"
LOGOUT="Docker Logout"
PORTAINER="Docker Portainer"
DOCKERCOMPOSE="Docker Compose"



###################################################################
###################################################################
# Updated
updated() {
    sleep 2
    echo -e "\n###### ${UPDATED} ######  "
    
    # Güncelleme Tercihi
    echo -e "Güncelleme İçin Seçim Yapınız\n1-)update\n2-)upgrade\n3-)dist-upgrade\n4-)Çıkış"
    read chooise

    # Girilen sayıya göre tercih
    case $chooise in
        1)
            read -p "Sistemin Listesini Güncellemek İstiyor musunuz ? e/h " listUpdatedResult
            if [[ $listUpdatedResult == "e" || $listUpdatedResult == "E" ]]; then
                echo -e "List Güncelleme Başladı ..."
                sudo ./countdown.sh
                sudo apt-get update
            else
                echo -e "Sistemin Listesini Güncellenemesi yapılmadı"
            fi
            ;; 
        2)
            read -p "Sistemin Paketini Yükseltmek İstiyor musunuz ? e/h " systemListUpdatedResult
            if [[ $systemListUpdatedResult == "e" || $systemListUpdatedResult == "E" ]]; then
                echo -e "Sistem Paket Güncellenmesi Başladı ..."
                sudo ./countdown.sh
                sudo apt-get update && sudo apt-get upgrade -y
            else
                echo -e "Sistem Paket Güncellenmesi  yapılmadı..."
            fi
            ;; 
        3)
            read -p "Sistemin Çekirdeğini Güncellemek İstiyor musunuz ? e/h " kernelUpdatedResult
            if [[ $kernelUpdatedResult == "e" || $kernelUpdatedResult == "E" ]]; then
                echo -e "Kernel Güncelleme Başladı ..."
                sudo ./countdown.sh
                sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y
                # Çekirdek(Kernel) güncellemelerinde yeniden başlamak gerekebilir
                sudo apt list --upgradable | grep linux-image
            else
                echo -e "Kernel Güncellemesi Yapılmadı..."
            fi
            ;;
        *)
            echo -e "Lütfen sadece size belirtilen seçeneği seçiniz"
            ;;
    esac
}
updated

###################################################################
###################################################################
# logout
logout() {
    sleep 2
    echo -e "\n###### ${LOGOUT} ######  "
    read -p "Sistemi Kapatıp Tekrar Açmak ister misiniz ? e/h " logoutResult
    if [[ $logoutResult == "e" || $logoutResult == "E" ]]; then
        echo -e "Sitem Kapatılıyor ..."

        # Geri Sayım
        sudo ./countdown.sh

        # Update
        sudo apt update
        clean # Temizleme Fonkisyonunu çağırsın
        ./reboot.sh
    else
        echo -e "Sistem Kapatılmadı"
    fi
}
# logout

###################################################################
###################################################################
# Paket Yüklendi mi
is_loading_package() {
    sleep 2
    echo -e "\n###### ${PACKAGE} ######  "
    read -p "Paketin Yüklendiğini Öğrenmek İster misiniz ? e/h " packageResult
    if [[ $packageResult == "e" || $packageResult == "E" ]]; then
        echo -e "Yüklenmiş paket bilgisini öğrenme ..."

        # Geri Sayım
        sudo ./countdown.sh

        echo -e "Bulunduğum dizin => $(pwd)\n"
        sleep 1

        echo -e "######### Paket Bağımlılığı #########\n"
        read -p "Lütfen yüklenmiş paket adını giriniz examples: git: " user_input

        # dependency
        package_information "$user_input"
    else
        echo -e "Paket Yüklenme Bilgisi İstenmedi..."
    fi
}

package_information() {
    # parametre - arguman
    local packagename=$1

    # Belirli bir Komutun Yolu (Sistemde nerede olduğunu bulmak)
    which $packagename

    # İlgili Paketi bulma
    whereis $packagename

    # Paket Bilgilerini Görüntüleme
    apt-cache show $packagename

    # Paketin Yüklü olup olmadığını Kontrol Etmek
    dpkg-query -W -f='${Status} ${Package}\n' $packagename

    # Geri Sayım
    sudo ./countdown.sh

    # Yüklü Tüm paketleri Listele
    dpkg -l 

    # Geri Sayım
    sudo ./countdown.sh

    # Eğer paket isimleri uzunsa grep ile arama yap 
    dpkg -l | grep $packagename

    # Dosyalarını Listelemek İstersem
    dpkg -L $packagename

    ############
    # Yüklü Tüm Paketleri Listelemek
    apt list --installed

    # Belirli bir paketin yüklü olup olmadığını kontrol etmek
    apt list --installed | grep $packagename 
}

###################################################################
###################################################################
# Paket Bağımlıklarını Görme
check_package() {
    sleep 2
    echo -e "\n###### ${CHECK} ######  "
    read -p "Sistem İçin Genel Bağımlılık Paketini Yüklemek İstiyor musunuz ? e/h " checkResult
    if [[ $checkResult == "e" || $checkResult == "E" ]]; then
        echo -e "Yüklenecek Paket Bağımlılığı ..."

        # Geri Sayım
        sudo ./countdown.sh

        echo -e "Bulunduğum dizin => $(pwd)\n"
        sleep 1

        echo -e "######### Paket Bağımlılığı #########\n"
        read -p "Lütfen yüklemek istediğiniz paket adını yazınız examples: nginx: " user_input

        # dependency
        dependency "$user_input"
    else
        echo -e "Bağımlılıklar kontrol edilmedi ..."
    fi
}

dependency() {
    # parametre - arguman
    local packagename=$1
    #
    sudo apt-get check
    sudo apt-cache depends $packagename
    sudo apt-get install $packagename
}

###################################################################
###################################################################
# Clean
# Install
clean() {
    sleep 2
    echo -e "\n###### ${CLEANER} ######  "
    read -p "Sistemde Gereksiz Paketleri Temizlemek İster misiniz ? e/h " cleanResult
    if [[ $cleanResult == "e" || $cleanResult == "E" ]]; then
        echo -e "Gereksiz Paket Temizliği Başladı ..."

        # Geri Sayım
        sudo ./countdown.sh

        echo -e "######### nginx #########\n"
        sudo apt-get autoremove -y
        sudo apt autoclean
        echo -e "Kırık Bağımlılıkları Yükle ..."
        sudo apt install -f
    else
        echo -e "Güncelleme yapılmadı"
    fi
}
clean

###################################################################
###################################################################
# Git Packet Install
# Install
gitInstall() {
    # Güncelleme Fonksiyonu
    updated

    # Geri Sayım
    sudo ./countdown.sh

    echo -e "\n###### ${INSTALL} ######  "
    read -p "Git Paketini Yüklemek İstiyor musunuz ? e/h " gitInstallResult
    if [[ $gitInstallResult == "e" || $gitInstallResult == "E" ]]; then
        echo -e "Git Paket Yükleme Başladı ..."

        # Geri Sayım
        sudo ./countdown.sh

        echo -e "Bulunduğum dizin => $(pwd)\n"
        sleep 1
        echo -e "######### Git #########\n"

        # Yükleme
        sudo apt-get install git -y 
        git version
        git config --global user.name "Hamit Mızrak"
        git config --global user.email "hamitmizrak@gmail.com"
        git config --global -l

        # Geri Sayım
        sudo ./countdown.sh

        echo -e "######### Git Version #########\n"
        git --version

        # Clean Function
        clean

        # Yüklenen Paket Hakkında Bilgi Almak
        is_loading_package

         # Git Check Package dependency Fonksiyonunu çağır
        check_package
    else
        echo -e "Git Yüklenmesi yapılmadı...."
    fi
}
gitInstall

###################################################################
###################################################################
# VS CODE Packet Install
# Install
vsCodeInstall() {
     # Güncelleme Fonksiyonu
    updated

    # Geri Sayım
    sudo ./countdown.sh

    echo -e "\n###### ${INSTALL} ######  "
    read -p "VS Code Paketini Yüklemek İstiyor musunuz ? e/h " vscodeInstallResult
    if [[ $vscodeInstallResult == "e" || $vscodeInstallResult == "E" ]]; then
        echo -e "VS Code Paket Yükleme Başladı ..."

        # Geri Sayım
        sudo ./countdown.sh

        echo -e "Bulunduğum dizin => $(pwd)\n"
        sleep 1
        echo -e "######### VS CODE #########\n"

        # Yükleme
        sudo snap install code --classic
        sleep 1

        sudo mkdir frontend
        cd frontend
        code .

        # Clean Function
        clean

        # Yüklenen Paket Hakkında Bilgi Almak
        is_loading_package

        # VSCODE Check Package dependency Fonksiyonunu çağır
        check_package
    else
        echo -e "VSCode Yüklenmesi Yapılmadı...."
    fi
}
vsCodeInstall

###################################################################
###################################################################
# JAVA JDK Packet Install
# Install
jdkInstall() {
     # Güncelleme Fonksiyonu
    updated

    # Geri Sayım
    sudo ./countdown.sh

    echo -e "\n###### ${INSTALL} ######  "
    read -p "JDK Paketini Yüklemek İstiyor musunuz ? e/h " jdkInstallResult
    if [[ $jdkInstallResult == "e" || $jdkInstallResult == "E" ]]; then
        echo -e "JDK Paket Yükleme Başladı ..."

        # Geri Sayım
        sudo ./countdown.sh

        echo -e "Bulunduğum dizin => $(pwd)\n"
        sleep 1
        echo -e "######### JDK #########\n"

        # Yükleme
        sudo apt-get install openjdk-11-jdk -y
        sudo add-apt-repository ppa:openjdk-r/ppa -y 
        echo -e "#Java Home\nJAVA_HOME=\"/usr/lib/jvm/java-11-openjdk-amd64/bin/\" " >> ~/.bashrc

        #sudo update-alternative --config java

        # Geri Sayım
        sudo ./countdown.sh

        echo -e "######### Git Version #########\n"
        which git
        which java 
        java --version
        javac --version

        # Clean Function
        clean

        # Yüklenen Paket Hakkında Bilgi Almak
        is_loading_package

        # VSCODE Check Package dependency Fonksiyonunu çağır
        check_package
    else
        echo -e "JDK Yüklenmesi Yapılmadı...."
    fi
}
jdkInstall

###################################################################
###################################################################
# MAVEN Packet Install
# Install
mavenInstall() {
     # Güncelleme Fonksiyonu
    updated

    # Geri Sayım
    sudo ./countdown.sh

    echo -e "\n###### ${INSTALL} ######  "
    read -p "MAVEN Paketini Yüklemek İstiyor musunuz ? e/h " mavenInstallResult
    if [[ $mavenInstallResult == "e" || $mavenInstallResult == "E" ]]; then
        echo -e "MAVEN Paket Yükleme Başladı ..."

        # Geri Sayım
        sudo ./countdown.sh

        echo -e "Bulunduğum dizin => $(pwd)\n"
        sleep 1
        echo -e "######### MAVEN #########\n"

        # Yükleme
        java --version 
        javac --version
        #sudo update-alternative --config java

        # Geri Sayım
        sudo ./countdown.sh

        # Maven Yükle
        sudo apt install maven 
        
         # Geri Sayım
        sudo ./countdown.sh

        echo -e "######### Version #########\n"
        which git
        which java
        which maven
        git --version
        java --version
        javac --version
        mvn --version

        # Clean Function
        clean

        # Yüklenen Paket Hakkında Bilgi Almak
        is_loading_package

        # VSCODE Check Package dependency Fonksiyonunu çağır
        check_package
    else
        echo -e "Maven Yüklenmesi Yapılmadı...."
    fi
}
mavenInstall

###################################################################
###################################################################
# Apache Tomcat Packet Install
# Install
apacheTomcatInstall() {
     # Güncelleme Fonksiyonu
    updated

    # Geri Sayım
    sudo ./countdown.sh

    echo -e "\n###### ${INSTALL} ######  "
    read -p "APACHE TOMCAT Paketini Yüklemek İstiyor musunuz ? e/h " apacheTomcatInstallResult
    if [[ $apacheTomcatInstallResult == "e" || $apacheTomcatInstallResult == "E" ]]; then
        echo -e "APACHE TOMCAT Paket Yükleme Başladı ..."

        # Geri Sayım
        sudo ./countdown.sh

        echo -e "Bulunduğum dizin => $(pwd)\n"
        sleep 1
        echo -e "######### APACHE TOMCAT #########\n"

        # Yükleme
        java --version 
        javac --version
        mvn --version

        #sudo update-alternative --config java

        # Geri Sayım
        sudo ./countdown.sh

        # Apache Tomcat Yükle
        # Tomcat 10 için En az JDK 11 kurmalısınız
        wget  https://archive.apache.org/dist/tomcat/tomcat-10/v10.0.8/bin/apache-tomcat-10.0.8.tar.gz
        sudo tar xzvf apache-tomcat-10.0.8.tar.gz
        sudo mkdir /opt/tomcat/
        sudo mv apache-tomcat-10.0.8/* /opt/tomcat/
        sudo chown -R www-data:www-data /opt/tomcat/
        # İzinleri Sembolik Mod olarak değiştirmek
        #sudo chmod -R u+rwx,g+rx,o+rx /opt/tomcat/
        sudo chmod -R 755 /opt/tomcat/
        
         # Geri Sayım
        sudo ./countdown.sh

        # Tomcat Servisi Başlatma Ve Etkinleştirme
        sudo systemctl daemon-reload
        sudo systemctl start tomcat

        # Test 
        curl http://localhost:8080

        # Restart
        sudo systemctl restart tomcat

        # Tomcat Servisinin Otomatik Olarak Başlamasını Sağlıyordu.
        sudo sytemctl enable tomcat

        # Tomcat Version
        /opt/tomcat/bin/catalina.sh version 
        
        echo -e "######### Version #########\n"
        which git
        which java
        which maven
        git --version
        java --version
        javac --version
        mvn --version

        # Clean Function
        clean

        # Yüklenen Paket Hakkında Bilgi Almak
        is_loading_package

        # VSCODE Check Package dependency Fonksiyonunu çağır
        check_package
    else
        echo -e "Apache Tomcat Yüklemesi Yapılmadı...."
    fi
}
apacheTomcatInstall

###################################################################
###################################################################
# Docker Packet Install
# Install
dockerInstall() {

     # Güncelleme Fonksiyonu
    updated

    # Geri Sayım
    sudo ./countdown.sh

    echo -e "\n###### ${INSTALL} ######  "
    read -p "DOCKER Paketini Yüklemek İstiyor musunuz ? e/h " dockerInstallResult
    if [[ $dockerInstallResult == "e" || $dockerInstallResult == "E" ]]; then
        echo -e "Docker Paket Yükleme Başladı ..."

        # Geri Sayım
        sudo ./countdown.sh

        echo -e "Bulunduğum dizin => $(pwd)\n"
        sleep 1
        echo -e "######### DOCKER #########\n"

        # Yükleme
        git --version 
        java --version 
        javac --version
        mvn --version
        #sudo update-alternative --config java

        # Geri Sayım
        sudo ./countdown.sh

        # Docker Kurulumu
         # Eğer önceden Docker varsa sil
        sudo apt-get purge docker-ce docker-ce-cli containerd.io -y
        sudo rm -rf /var/lib/docker
        sudo rm -rf /var/lib/containerd
        sudo apt-get clean
        sudo apt-get autoremove -y
        sudo apt-get update
        sudo apt-get remove docker docker-engine docker.io containerd runc
        sudo apt-get update
        sudo apt-get upgrade

         ### HTTPS üzerinden bir depo kullanmasına izin vermek için##################################
        sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

        ### Docker’ın resmi GPG anahtarını ekleyiniz. curl aracı ile GPG anahtarını komut içerisine aktarınız
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo apt-key fingerprint 0EBFCD88

        ### curl aracı ile Docker apt deposunu eklemek
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

        ###############DOCKER KURULUMU##########################################
        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io -y

        # sudo systemctl status docker
        # sleep 2
        # q
        sudo systemctl enable --now docker 
        sudo systemctl start docker
        # sudo systemctl status docker

        ### kullanıcı adınızı docker grubuna ekle
        sudo usermod -aG docker ${USER}
        su - ${USER}
        sudo  id -NG
        sudo apt-get install bash-completion 
        docker version

        # Docker Image Oluştursun
        docker run hello-world
        
         # Geri Sayım
        sudo ./countdown.sh

        # Docker Pulling
        dockerPulling

        # DockerHub Login 
        dockerHubLogin

        # DockerHub Logout 
        dockerHubLogout

        # Docker Compose 
        dockerCompose

        # Docker Linux Ubuntu Portainer
        dockerPortainer

        # Version
        echo -e "######### Version #########\n"
        which git
        which java
        which maven
        git --version
        java --version
        javac --version
        mvn --version

        # Clean Function
        clean

        # Yüklenen Paket Hakkında Bilgi Almak
        is_loading_package

        # VSCODE Check Package dependency Fonksiyonunu çağır
        check_package
    else
        echo -e "Docker Kurulumu Yapılmadı...."
    fi
}
dockerInstall

# Docker Pulling
dockerPulling() {
     # Geri Sayım
    sudo ./countdown.sh

    echo -e "\n### ${DOCKER_PULL} ###"
    read -p "\nDockerHub'a Pull  yapmak istiyor musunuz ? E/H? " updatedResult
    if [[ $updatedResult == "E" || $updatedResult == "e"  ]]
    then
        echo -e "Docker Pulling ... "  
        sudo docker pull nginx
        sudo docker pull httpd # apache
        docker pull tomcat:9.0.8-jre8-alpine
        sudo docker pull mysql
        sudo docker pull postgres
        sudo docker pull ubuntu
        sudo docker pull alpine
        sudo docker pull centos
        sudo docker pull node # nodejs
        sudo docker pull mongo # nosql
        sudo docker pull redis
        sudo docker pull python:3.8
        docker images
    else
        echo -e "apt-get Update List Güncelleme Yapılmadı!!!\n "   
    fi
}

# dockerHubLogin
dockerHubLogin() {
    # Geri Sayım
    sudo ./countdown.sh

    echo -e "\n### ${LOGIN} ###"
    read -p "\nDockerHub'a Giriş yapmak istiyor musunuz ? E/H? " updatedResult
    if [[ $updatedResult == "E" || $updatedResult == "e"  ]]
    then
        echo -e "Docker Login ... "  
        sudo docker login
    else
        echo -e "apt-get Update List Güncelleme Yapılmadı!!!\n "   
    fi
}

# dockerHubLogout
dockerHubLogout() {
    # Geri Sayım
    sudo ./countdown.sh

    echo -e "\n### ${LOGOUT} ###"
    read -p "\nDockerHub'a Çıkış yapmak istiyor musunuz ? E/H? " updatedResult
    if [[ $updatedResult == "E" || $updatedResult == "e"  ]]
    then
        echo -e "Docker Login ... "  
        sudo docker logout
    else
        echo -e "apt-get Update List Güncelleme Yapılmadı!!!\n "   
    fi
}

# Docker Portainer
dockerPortainer(){
    # Geri Sayım
    sudo ./countdown.sh

    echo -e "\n### ${PORTAINER} ###"
    read -p "\nDockerHub'a Çıkış yapmak istiyor musunuz ? E/H? " portainerResult
    if [[ $portainerResult == "E" || $portainerResult == "e"  ]]
    then
        echo -e "Docker Portainer ... "  
        ##### Aşağıdaki kodları yaz ##########################################
        sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

        ##### CHMOD ##########################################
        sudo chmod +x /usr/local/bin/docker-compose
        sudo docker volume create portainer_data

        ##### PORT##########################################
        sudo docker run -d -p 2222:9000 -p 8000:8000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /srv/portainer:/data portainer/portainer
        sudo docker start portainer
        sudo docker stop portainer

        ##### CHMOD ##########################################
        ifconfig
        sudo curl localhost:2222 

        # username:root
        # password:rootroot

    else
        echo -e "Docker Portainer Ekleme Yapılmadı!!!\n "   
    fi
}

# Docker Compose
dockerCompose(){
    # Geri Sayım
    sudo ./countdown.sh

    echo -e "\n### ${DOCKERCOMPOSE} ###"
    read -p "\nDocker Compose Eklemek İstiyor musunuz ? E/H? " dockerComposeResult
    if [[ $dockerComposeResult == "E" || $dockerComposeResult == "e"  ]]
    then
        echo -e "Docker Compose Ekleniyor ... "  
      
    else
        echo -e "Docker Compose Ekleme Yapılmadı!!!\n "   
    fi
}


###################################################################
###################################################################
# Information
information() {
    sleep 2
    echo -e "\n###### ${INFORMATION} ######  "
    read -p "Genel Bilgileri Görmek ister misiniz ? e/h " informationResult
    if [[ $informationResult == "e" || $informationResult == "E" ]]; then
        echo -e "Genel Bilgiler Verilmeye Başlandı ..."

        # Geri Sayım
        sudo ./countdown.sh

        #sudo su
        echo -e "Ben Kimim => $(whoami)\n"
        sleep 1
        echo -e "Ağ Bilgisi => $(ifconfig)\n"
        sleep 1
        echo -e "Port Bilgileri => $(netstat -nlptu)\n"
        sleep 1
        echo -e "Linux Bilgileri => $(uname -a)\n"
        sleep 1
        echo -e "Dağıtım Bilgileri => $(lsb_release -a)\n"
        sleep 1
        echo -e "HDD Disk Bilgileri => $(df -m)\n"
        sleep 1
        echo -e "CPU Bilgileri => $(cat /proc/cpuinfo)\n"
        sleep 1
        echo -e "RAM Bilgileri => $(free -m)\n"
        sleep 1
    else
        echo -e "Dosya izinleri yapılmadı"
    fi
}
information



###################################################################
###################################################################
# Port And Version
portVersion() {
    node -v
    zip -v
    unzip -v+
    # build-essential:
    gcc --version # gcc: GNU C compiler derlemek
    g++ --version # g++: GNU C++ compiler derlemek
    make --version # make: Makefile kullanarak derlemek içindir
    git --version
    java --version
    javac --version
    mvn --version

    # Tomcat Version
    /opt/tomcat/bin/catalina.sh version 

    # docker Version
    #docker-compose -v
}
portVersion

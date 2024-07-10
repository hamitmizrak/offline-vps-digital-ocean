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
TECH="Diğer Teknolojiler"

###################################################################
###################################################################
# Access Permission
accessPermission() {
    sleep 2
    echo -e "\n###### ${CHMOD} ######  "
    read -p "Dosya İzinleri Vermek İstiyor musunuz ? e/h " permissionResult
    if [[ $permissionResult == "e" || $permissionResult == "E" ]]; then
        echo -e "Dosya izinleri Başladı ..."
        
        # chmod: Dosya ve dizinlerin erişimi için izinler
        # r: Okuma(read) 2^2=4
        # w: Yazma(Write) 2^1=2
        # x: Çalıştırma(Execute) 2^0=1

        # Kullanıcı Kategorileri
        # u: Dosya sahibi(user)
        # g: Grup Üyeleri(group)
        # o: Diğer Kullanıcılar (others)
        # a: Tüm kullancıılar (all)
        ls -al
        ls -l countdown.sh
        ls -l reboot.sh
        # İzinleri Sembolik Mod olarak değiştirmek
        chmod u+rwx,g+rx,o+rx ./script

        # İzinleri Sayısal Mod olarak değiştirmek
        chmod 755 ./script

        # Bash scriptlere izin vermek
        sudo chmod +x countdown.sh
        sudo chmod +x reboot.sh
        sudo chmod +x _2_other_programming.sh
        sudo chmod +x docker_tomcat.sh

        sudo ./countdown.sh
    else
        echo -e "Dosya İzinleri Yapılmadı..."
    fi
}
# Function Calling
accessPermission

###################################################################
###################################################################
# Updated
updated() {
    sleep 2
    echo -e "\n###### ${UPDATED} ######  "
    
    # Güncelleme Tercihi
    echo -e "Güncelleme İçin Seçim Yapınız\n1-)update\n2-)upgrade\n3-)dist-upgrade"
    read chooise

    # Girilen sayıya göre tercih
    case $chooise in
        1)
            read -p "Sistemin Listesini Güncellemek İstiyor musunuz ? e/h " listUpdatedResult
            if [[ $listUpdatedResult == "e" || $listUpdatedResult == "E" ]]; then
                echo -e "List Güncelleme Başladı ..."
                ./countdown.sh
                sudo apt-get update
            else
                echo -e "Sistemin Listesini Güncellenemesi yapılmadı"
            fi
            ;; 
        2)
            read -p "Sistemin Paketini Yükseltmek İstiyor musunuz ? e/h " systemListUpdatedResult
            if [[ $systemListUpdatedResult == "e" || $systemListUpdatedResult == "E" ]]; then
                echo -e "Sistem Paket Güncellenmesi Başladı ..."
                ./countdown.sh
                sudo apt-get update && sudo apt-get upgrade -y
            else
                echo -e "Sistem Paket Güncellenmesi  yapılmadı..."
            fi
            ;; 
        3)
            read -p "Sistemin Çekirdeğini Güncellemek İstiyor musunuz ? e/h " kernelUpdatedResult
            if [[ $kernelUpdatedResult == "e" || $kernelUpdatedResult == "E" ]]; then
                echo -e "Kernel Güncelleme Başladı ..."
                ./countdown.sh
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
        ./countdown.sh
        sudo apt update
        clean # Temizleme Fonkisyonunu çağırsın
        ./reboot.sh
    else
        echo -e "Sistem Kapatılmadı..."
    fi
}
# logout


###################################################################
###################################################################
# Güvenlik duvarı INSTALL  (UFW => Uncomplicated Firewall)
theFirewallInstall() {
    sleep 2
    echo -e "\n###### ${UFW} ######  "
    read -p "Güvenlik Duvarı Kurulumlarını İster misiniz ? e/h " ufwResult
    if [[ $ufwResult == "e" || $ufwResult == "E" ]]; then
        echo -e "Güvenlik Duvarı Kuurlumları ,port izinler ve IP adres izinleri başladı ..."
        ./countdown.sh
        netstat -nlptu
        sleep 3
        echo -e "######### UFW (Uncomplicated Firewall) #########\n"
        # UFW kurulumu
        sudo apt install ufw -y

        # UFW Status
        sudo ufw status

        # Varsayılan Giden Trafik Kurallarını Belirlemek(Dış dünyayay yapılan bağlantıların varsayılan olarak izin verildiği anlamına gelir)
        # Tüm Giden Trafiğe İzin Ver
        sudo ufw default allow outgoing

        # Ssh(Secure Shell) trafiğine izin verir. Bağlantılara izin vermek
        sudo ufw allow ssh
        sudo ufw allow 22
        sudo ufw allow 80
        sudo ufw allow 443
        sudo ufw allow 1111 # Apache Tomcat - Docker 
        sudo ufw allow 2222 # docker portainer
        sudo ufw allow 8000 # docker portainer
        sudo ufw allow 3333 # Jenkins
        sudo ufw allow 3306 # mysql
        sudo ufw allow 5432 # Postgresql
        sudo ufw allow 8080
        sudo ufw allow 9000
        sudo ufw allow 9090
        # IP: 127.0.0.1 DNS: localhost
        sudo ufw allow from 127.0.0.1 to any port 8080

        # UFW Etkinleştirme
        sudo ufw enable

        # UFW Status
        sudo ufw status
    else
        echo -e "Güvenlik Duvarı Açılmadı..."
    fi
}
#theFirewallInstall

# Güvenlik duvarı DELETE   (UFW => Uncomplicated Firewall)
theFirewallDelete() {
    sleep 2
    echo -e "\n###### ${UFW} ######  "
    read -p "Güvenlik Duvarı Kapatmak İster misiniz ? e/h " ufwCloseResult
    if [[ $ufwResufwCloseResultult == "e" || $ufwCloseResult == "E" ]]; then
        echo -e "Güvenlik Duvarı port,ip,gelen giden ağlar kapatılmaya  başladı ..."
        ./countdown.sh
        netstat -nlptu
        sleep 3
        echo -e "######### UFW (Uncomplicated Firewall) #########\n"
        # UFW Status
        sudo ufw status

        # Varsayılarn Gelen Trafik Kurallarını belirleme(Güvenliği artırmak için gelen bağlantıları varsayılan olarak reddeder yalnızca belirlenen bağlantılara izin verir)
        # Tüm Gelen Trafiği Engelle
        sudo ufw default deny incoming

        # Ssh(Secure Shell) trafiğine izin verir. Bağlantılara izin vermek
        sudo ufw delete allow ssh
        sudo ufw delete allow 22
        sudo ufw delete allow 80
        sudo ufw delete allow 443
        sudo ufw delete allow 1111
        sudo ufw delete allow 2222
        sudo ufw delete allow 3333
        sudo ufw delete allow 3306
        sudo ufw delete allow 5432
        sudo ufw delete allow 8080
        sudo ufw delete allow 9000
        sudo ufw delete allow 9090
        # IP: 127.0.0.1 DNS: localhost
        sudo ufw delete allow from 127.0.0.1 to any port 8080

        # UFW Devre Dışı Bırak
        sudo ufw disable

        # UFW Status
        sudo ufw status
    else
        echo -e "Güvenlik Duvarı Ayarları Kapatılmadı .... "
    fi
}
#theFirewallDelete

###################################################################
###################################################################
# Install
install() {
    sleep 2
    echo -e "\n###### ${INSTALL} ######  "
    read -p "Sistem İçin Genel Yükleme İstiyor musunuz ? e/h " commonInstallResult
    if [[ $commonInstallResult == "e" || $commonInstallResult == "E" ]]; then
        echo -e "Genel Yükleme Başladı ..."
        ./countdown.sh
        echo -e "Bulunduğum dizin => $(pwd)\n"
        sleep 1
        sudo apt-get install vim -y
        sleep 1
        sudo apt-get install rar -y
        sleep 1
        sudo apt-get install unrar -y
        sleep
        sudo apt-get install curl -y
        sleep 1
        sudo apt-get install openssh-server -y
        sleep 1
        # build-essential: Temel Geliştirme araçları içeren meta-pakettir
        sudo apt install build-essential wget zip unzip -y
        # Firewall Function
        theFirewallInstall
        theFirewallDelete
    else
        echo -e "Sistem İçin Genel Yükleme Yapılmadı..."
    fi
}
install

# Packet Install
# Install
packageInstall() {
    sleep 2
    echo -e "\n###### ${INSTALL} ######  "
    read -p "Sistem İçin Genel Paket Yüklemek İstiyor musunuz ? e/h " packageInstallResult
    if [[ $packageInstallResult == "e" || $packageInstallResult == "E" ]]; then
        echo -e "Genel Paket Yükleme Başladı ..."
        ./countdown.sh
        echo -e "Bulunduğum dizin => $(pwd)\n"
        sleep 1
        echo -e "######### Nginx #########\n"
        # Nginx Check Package dependency Fonksiyonunu çağır
        check_package

        # Yükleme
        sudo apt-get install nginx -y
        sudo systemctl start nginx
        sudo systemctl enable nginx
        ./countdown.sh

        #echo -e "######### nodejs #########\n"
        #sudo apt install nodejs -y
        #./countdown.sh

        #echo -e "######### Brute Force  #########\n"
        #sudo apt install fail2ban -y
        #sudo systemctl start fail2ban
        #sudo systemctl enable fail2ban
        #./countdown.sh

        echo -e "######### Monitoring  #########\n"
        sudo apt install htop iftop net-tools -y

        #echo -e "######### Python  #########\n"
        #sudo apt install python3 python3-pip -y
    else
        echo -e "Sistem İçin Genel Paket Yüklemesi Yapılmadı..."
    fi
}
packageInstall

###################################################################
###################################################################
# Paket Bağımlıklarını Görme
check_package() {
    sleep 2
    echo -e "\n###### ${CHECK} ######  "
    read -p "Sistem İçin Genel Paket Yüklemek İstiyor musunuz ? e/h " checkResult
    if [[ $checkResult == "e" || $checkResult == "E" ]]; then
        echo -e "Yüklenecek Paket Bağımlılığı ..."
        ./countdown.sh
        echo -e "Bulunduğum dizin => $(pwd)\n"
        sleep 1

        echo -e "######### Paket Bağımlılığı #########\n"
        read -p "Lütfen yüklemek istediğiniz paket adını yazınız examples: nginx" user_input

        # dependency
        dependency "$user_input"
    else
        echo -e "Paket Bağımlıklarını Yapılmadı..."
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
# Information
information() {
    sleep 2
    echo -e "\n###### ${INFORMATION} ######  "
    read -p "Genel Bilgileri Görmek ister misiniz ? e/h " informationResult
    if [[ $informationResult == "e" || $informationResult == "E" ]]; then
        echo -e "Genel Bilgiler Verilmeye Başlandı ..."
        ./countdown.sh
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
        echo -e "Dosya İzinleri Yapılmadı"
    fi
}
information

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
        ./countdown.sh
        echo -e "######### Clean #########\n"
        sudo apt-get autoremove -y
        sudo apt autoclean
        echo -e "Kırık Bağımlılıkları Yükle ..."
        sudo apt install -f
    else
        echo -e "Temizleme Yapılmadı..."
    fi
}
clean

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
}
portVersion


###################################################################
###################################################################
# Clean
# Install
other_technology() {
    ./countdown.sh
    echo -e "\n###### ${TECH} ######  "
    read -p "Sistem için Yüklemek İsteyeceğiniz Paketleri Yüklemek İster misiniz ? e/h " otherResult
    if [[ $otherResult == "e" || $otherResult == "E" ]]; then
        echo -e "Teknolojiler Yüklenmeye başlandı ..."
        ./countdown.sh
        echo -e "######### Teknolojiler #########\n"
        ./_2_other_programming.sh
       
    else
        echo -e "Teknolojiler Yüklenmeye Başlanmadı ...."
    fi
}
other_technology
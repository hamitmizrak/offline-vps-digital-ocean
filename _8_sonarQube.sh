#!/bin/bash

# Değişkenler
SONARQUBE_VERSION=9.9.0.65466
SONARQUBE_USER=sonarqube
INSTALL_DIR=/opt/sonarqube
POSTGRES_USER=sonar
POSTGRES_PASSWORD=your_postgres_password
SONARQUBE_DB=sonarqube

# PostgreSQL kurulumu
sudo apt update
sudo apt install -y postgresql postgresql-contrib

# PostgreSQL servisini başlatma ve otomatik başlama ayarları
sudo systemctl start postgresql
sudo systemctl enable postgresql

# PostgreSQL kullanıcı ve veritabanı oluşturma
sudo -i -u postgres psql -c "CREATE USER $POSTGRES_USER WITH ENCRYPTED PASSWORD '$POSTGRES_PASSWORD';"
sudo -i -u postgres psql -c "CREATE DATABASE $SONARQUBE_DB OWNER $POSTGRES_USER;"

# PostgreSQL yapılandırma ayarlarını değiştirme
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/12/main/postgresql.conf
echo "host    all             all             0.0.0.0/0               md5" | sudo tee -a /etc/postgresql/12/main/pg_hba.conf

# PostgreSQL servisini yeniden başlatma
sudo systemctl restart postgresql

# Java ve diğer gerekli paketlerin kurulumu
sudo apt install -y openjdk-11-jdk wget unzip

# SonarQube kullanıcı ve grubunu oluşturma
sudo groupadd $SONARQUBE_USER
sudo useradd -r -g $SONARQUBE_USER -d $INSTALL_DIR -s /bin/bash $SONARQUBE_USER

# SonarQube'u indirme ve kurma
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONARQUBE_VERSION.zip -P /tmp
sudo mkdir -p $INSTALL_DIR
sudo unzip /tmp/sonarqube-$SONARQUBE_VERSION.zip -d $INSTALL_DIR
sudo mv $INSTALL_DIR/sonarqube-$SONARQUBE_VERSION/* $INSTALL_DIR
sudo chown -R $SONARQUBE_USER:$SONARQUBE_USER $INSTALL_DIR

# SonarQube yapılandırma dosyasını PostgreSQL kullanacak şekilde düzenleme
sudo cp $INSTALL_DIR/conf/sonar.properties $INSTALL_DIR/conf/sonar.properties.bak
sudo sed -i "s|#sonar.jdbc.username=|sonar.jdbc.username=$POSTGRES_USER|g" $INSTALL_DIR/conf/sonar.properties
sudo sed -i "s|#sonar.jdbc.password=|sonar.jdbc.password=$POSTGRES_PASSWORD|g" $INSTALL_DIR/conf/sonar.properties
sudo sed -i "s|#sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube|sonar.jdbc.url=jdbc:postgresql://localhost/$SONARQUBE_DB|g" $INSTALL_DIR/conf/sonar.properties

# SonarQube servisi oluşturma
cat <<EOL | sudo tee /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
ExecStart=$INSTALL_DIR/bin/linux-x86-64/sonar.sh start
ExecStop=$INSTALL_DIR/bin/linux-x86-64/sonar.sh stop
User=$SONARQUBE_USER
Group=$SONARQUBE_USER
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOL

# SonarQube servisini başlatma ve durumunu kontrol etme
sudo systemctl daemon-reload
sudo systemctl start sonarqube
sudo systemctl status sonarqube

# SonarQube'in otomatik olarak başlamasını etkinleştirme
sudo systemctl enable sonarqube

# Firewall ayarları (güvenlik duvarı) yapılandırması (opsiyonel)
# sudo ufw allow 9000
# sudo ufw status

echo "PostgreSQL ve SonarQube kurulumu tamamlandı. SonarQube'u web tarayıcınızdan erişmek için http://<sunucu-ip>:9000 adresine gidin."

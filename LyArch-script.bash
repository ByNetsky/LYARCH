#!/bin/bash
clear

echo '
# ************************************************ #
#               LyArch Install Script              #
#                  edit ByNetsky		   #
#                                                  #
#   arch linux auf einem raspberry pi + sd-karte   #
#      getestet auf einer 8Gb micro sd Karte       #
# ************************************************ #
! Drücke STRG + C, um das Skript abzubrechen !
'

# Alle Befehle anzeigen (DEBUG)
# set -x

# Reinigung, falls erforderlich
echo '
Reinige..
-------------'
sudo umount boot
sudo umount root
echo 'DONE
'

echo '
Löschen von Junk-Dateien
-------------------'
sudo rm -r boot
sudo rm -r root
sudo rm ARCH-LINUX-DATEI-ISO.tar.gz
echo 'Fertig
'

# Anzeigen der Mounted Volumes
echo '
Alle Mounted Volumes
-------------------'
lsblk
echo "Gebeden Standort deiner SD-Karte ein (z.B.: /dev/sdb):"
read uservolume
echo '
'

# Erstelle Partition
echo '
Neupartitionierung der SD-Karte
----------------------'
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo fdisk $uservolume
  o # Die Partitionstabelle im Speicher löschen
  n # Neue Partition
  p # Primäre Partition
  1 # Partition Nummer 1
    # Standard - Start am Anfang der Festplatte
  +300M # 300 MB Boot Partition
  t # Ändere Partition System-ID
  c # ... zu W95 FAT32 (LBA)
  n # Neue Partition
  p # Primäre Partition
  2 # Partition Nummer 2
    # Standard, Start direkt nach der vorhergehenden Partition
    # Standard, Partition bis zum Ende der Festplatte erweitern
  p # Partitionstabelle anzeigen
  w # Schreiben der Partitionstabelle
  q # Und schon sind wir fertig
EOF
partprobe
echo 'FERTIG
'

echo '
Dateisystem erstellen
-------------------'
echo "[boot] ${uservolume}1 => vfat"
sudo mkfs.vfat ${uservolume}1 # Dateisystem erstellen
mkdir boot # Bootverzeichnis erstellen
sudo mount ${uservolume}1 boot # Boot Partition mounten

echo "[root] ${uservolume}2 => ext4"
sudo mkfs.ext4 # Dateisystem erstellen
mkdir root # Rootverzeichnis erstellen
sudo mount ${uservolume}2 root # Root Partition mounten
echo 'FERTIG
'

echo '
Lade Arch Linux Image herunter
-------------------------------'
wget https://alaa.ad24.cz/repos/2022/02/06/os/rpi/ArchLinuxARM-2021.11-rpi-armv7-rootfs.tar.gz # Aktuelles archlinux herunterladen
echo 'FERTIG
'

echo '
Heruntergeladenes Archiv entpacken
-----------------------------'
echo 'Entpacke in den Root ...'
sudo bsdtar -xpf ArchLinuxARM-2021.11-rpi-armv7-rootfs.tar.gz -C root # Alle Inhalte in das Hauptverzeichnis entpacken
echo 'FERTIG
'

echo '
Verschieben der Boot Dateien
-----------------'
# Der Befehl "mv" schien Probleme beim Verschieben von Dateien zwischen verschiedenen Partitionen zu haben
# sudo mv root/boot/* boot # Verschiebe alle Inhalte vom Boot Ordner in das Boot Verzeichnis
echo 'Kopiere root/boot/* -> boot'
sudo cp --no-preserve=mode,ownership root/boot/* boot
echo 'Lösche root/boot/* Dateien'
sudo rm -r root/boot/*
echo 'FERTIG
'

echo '
Löschen von Junk-Dateien
-------------------'
sudo rm ArchLinuxARM-2021.11-rpi-armv7-rootfs.tar.gz
echo 'FERTIG
'

# Anzeige aller Befehle deaktivieren
set +x

echo '
+++ Stecke die SD-Karte in deine Raspberry Pi und schau, ob alles funktioniert.'
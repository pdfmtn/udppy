#!/bin/python2.7
# import pyshark
# udp_payload=[]
# capture = pyshark.FileCapture('capture.log',display_filter='udp port 22222')
# udp_payload.append(bytearray.fromhex(capture.data.data).decode())
import sys
import os
import urllib

import png
import scapy
# import pyshark
import pcapng
import hashlib
import pypng
from PIL import Image
from hachoir.parser import createParser
from hachoir.metadata import extractMetadata
#Exec sys pour tshark et foremost
# os.system("tshark -r capture.pcapng -Y 'udp' -w capture_udp.pcap")
# os.system("foremost -i capture.pcapng")
def frompython():
    #liste les images
    listeimage = os.listdir("/root/cours/foremost/png/")
    print listeimage
    listeimage.remove("tdudp.py")
    listehash2 = []
    nombreimage = len(listeimage)

    stockagehash = open("../../hashpython.txt", "a")
    compteurdoubon = 0
    comptehashunique = 0
    #calcule les hash et ajoute a listehash2
    for i in range(0, nombreimage):
        listehash2.append(hashlib.md5(Image.open(listeimage[i]).tobytes()))
        print listehash2[i]
    #controle des doublon
    for debut in range(0, nombreimage):
        for fin in range(debut+1, nombreimage):
            if listehash2[debut] == listehash2[fin]:
                listehash2.remove(fin)
                os.remove(listeimage[debut])
                compteurdoubon = compteurdoubon + 1
            else:
                stockagehash.write(listehash2[debut])
                comptehashunique = comptehashunique + 1

        print "Hash unique", comptehashunique
        print "Doublon", compteurdoubon
    # verif fichier png (entete etc)
    for debut in range(0,nombreimage):
        r = png.Reader(file='/root/TDUDP/foremost/png/'+ listeimage[debut])
        print "image", listeimage[debut] , "\n"
        r.read()
        parser = createParser(listeimage[debut])
        metadata = extractMetadata(parser)
        for line in metadata.exportPlaintext():
            print(line)
        # sessions = a.sessions()
        # for session in sessions:
        #     udp_payload = ""
        # for packet in sessions[session]:
        #     print packet


def fromfile():
    hashnontrier = open("hashnontrier.txt", "r")
    hashtrier = open("hashtrier.txt", "a")

    listehash = []
    listehash = hashnontrier.readlines()

    nombreligne = len(listehash)
    compteurdoubon = 0
    comptehashunique = 0
    for debut in range(0, nombreligne):
        for fin in range(debut + 1, nombreligne):
            if listehash[debut] == listehash[fin]:
                listehash.remove(fin)
                compteurdoubon = compteurdoubon + 1
            else:
                comptehashunique = comptehashunique + 1

        hashnontrier.write(listehash[debut])

    print "Hash unique", comptehashunique
    print "Doublon", compteurdoubon

    hashnontrier.close()
    hashtrier.close()


if sys.argv[1] == "0":
    fromfile()
elif sys.argv[1] == "1":
    frompython()
else:
    print "0 -> depuis fichier", "\n", "1 -> depuis python"

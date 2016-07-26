import requests
import urllib
import json
from urllib. import urlopen
from bs4 import BeautifulSoup as bs
from bs4 import SoupStrainer
import random
import string
import re
import numpy as np
import re
import types
import csv
import os
import sys

def websitedata(url):
        openurl=requests.get(url)
        info=openurl.text
        return info
    
def main():
    f = open('DailyStrength1.txt', 'w')
    info=websitedata('https://www.dailystrength.org/search?query=drug%20interactions')
    soup=bs(info, "html5lib")
    with requests.Session() as session:
            response = session.post("https://www.dailystrength.org/search?query=drug%20interactions", data={'start':0})
            print(response.content)
    
    for link in soup.find_all(href=re.compile("group")): #links with 'forum' in the url
              #print link
              m = re.search('href="(.+?)">', str(link)) #Print Everything inside of href=" and ">
              if m:
                  found = m.group(1)
                  #print found
                  
              a = urllib.urlopen('http://www.dailystrength.org' + found).read()
              soup = bs(a, "lxml")

              for discussion1 in soup.find_all("div", class_="discussion_text longtextfix485"):
                      print >> f, 'Next Text Item:', discussion1.get_text()
                       # print discussion1.get_text()
    f.close()                
         
    return 0

if __name__ == '__main__':
        main()

# grab-status-page.py

from requests import get
from requests.exceptions import RequestException
from contextlib import closing
from bs4 import BeautifulSoup
from datetime import datetime


logfile_name = "ee_data_usage.log"

url = "http://add-on.ee.co.uk/status"

now = datetime.utcnow()
with closing(get(url, stream=True)) as resp:
            print(resp)
            # print(resp.content)
            html = BeautifulSoup(resp.content, 'html.parser')
            for p in html.select('span'):
                classes = p.get('class')
                if classes and 'allowance__left' in classes:
                    allowance=p.text.split()
                    #print(now, allowance)
                    logfile = open(logfile_name, 'a')
                    logfile.write("%s,%s,%s\n" % (now, allowance[0], allowance[3]))
                    logfile.close()

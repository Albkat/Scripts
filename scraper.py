import requests
from bs4 import BeautifulSoup
from time import sleep
import json
import sys

def get_citing_urls(doi):
    dois = []
    headers = {"user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36" ,'referer':'https://www.google.com/'}
    cite_url=""
    base_url = "https://scholar.google.com/scholar"
    params = {
        "q": f'doi:{doi}', # Search for the DOI
        "as_vis": "0",  # Show citation links
        "hl": "en"
    }
    response = requests.get(base_url, params=params, headers=headers)
    sleep(3) # Sleep for 3 seconds to avoid getting blocked
    if response.status_code == 200:

        soup = BeautifulSoup(response.content, 'html.parser') # Parse the HTML
        for a in soup.find_all('a', href=True):
            if "Cited by" in a.text: # Find the "Cited by" link
                cite_url = a['href']
                num_citations = a.text.split()[-1]
                break
    try: # Try to get the number of citations
        num_sites = int(num_citations)//20+1
    except: # If there is no number of citations, this could mean, that the user has been blocked by Google Scholar. (or there are no citations - but then you wouldn't need this script anyway)
        print("You may have been blocked by Google Scholar. Try again later.")
        exit()
    short_abstracts = []
    hrefs = []
    titles = []
    base_url = "https://scholar.google.com" + cite_url
    for i in range(0,num_sites):
        if i==0:
            cite_params = {
                "hl": "en",
                "num": "20"
            }
        else:
            cite_params = {
                "start": str(i*20),
                "num": "20",
                "hl": "en"
            }
        cite_response = requests.get(base_url, params=cite_params, headers=headers)
        sleep(3) # Sleep for 3 seconds to avoid getting blocked
        if cite_response.status_code == 200:
            cite_soup = BeautifulSoup(cite_response.content, 'html.parser')
            #print(cite_soup.prettify())
            headings = cite_soup.find_all('h3')
            for heading in headings:
                for a in heading.find_all('a', href=True):
                    hrefs.append(a['href'])
                    titles.append(a.text)
                for div in cite_soup.find_all('div', class_='gs_rs'):
                    short_abstracts.append(div.text)

    return hrefs, titles, short_abstracts

doi = sys.argv[1]

citing_urls, titles, abstracts = get_citing_urls(doi)
# Make Json from lists
citing = []
print("Total number of citations: ",len(citing_urls))
for i in range(len(citing_urls)):
    citing.append({'url':citing_urls[i],'title':titles[i],'short_abstract':abstracts[i]})
citing_json = json.dumps(citing, indent=4)

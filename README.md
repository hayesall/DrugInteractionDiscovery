### Drug Interaction Discovery with NLP and Machine Learning:

---

__Alexander L. Hayes | Savannah Smith | Devendra Dhami | Sriraam Natarajan__

Using data pulled from rxlist.com, openFDA, PubMed.  This repository contains the scripts for pulling data from each source, and an overview of each are explained below.

---

##### Table of Contents
1. [openFDA](#openfda)
2. [PubMed](#pubmed)
3. [Confidence](#confidence)
4. [Learning](#learning)

---

#####openFDA:
Here you will find several shell scripts for pulling drug names from rxlist.com, pulling labeling information from openFDA, and `fixlist.sh` to fix the list of drugs if `rxdownloader.sh` crashes halfway through.

Running the scripts will take some time (`rxdownloader.sh` took about 6 hours in total to crawl through the database), find out more about the labeling database at [their website.](https://open.fda.gov/api/reference/)

The full set of [extracted data](https://github.iu.edu/hayesall/PMDataDump/tree/master/bashscripts/drugInteractionsFolder) can be found on Alexander's IU GitHub.  Because of its size forking the repository or downloading a .zip is recommended.

1. `builddruglist.sh`

   Downloads drug names from rxlist.com  
   Outputs a text file (`drugslist.txt`)  
   Arguments can be passed to tweak the output.

  * `bash builddruglist.sh         `(by default formats for openFDA)
  * `bash builddruglist.sh openFDA `(replace spaces with +AND+)
  * `bash builddruglist.sh PubMed  `(replace spaces with +)
  * `bash builddruglist.sh Web     `(replace spaces with _)

2. `rxdownloader.sh`

   Takes a list of drugs(drugslist.txt)  
   Queries openFDA for each drug (`fdainteractions.sh`)  
   Outputs a text file in drugInteractionsFolder/ (i.e. Warfarin+AND+Sodium will be output as drugInteractionsFolder/Warfarin+AND+Sodium-data.txt).

   Running it is simple (though time consuming):  
   `bash rxdownloader.sh`

   Additionally, RXDownloader does some sorting for us: it queries all __generic__ drugs, outputs __brand name__ drugs to a separate file (drugInteractionsFolder/BRANDNAMEDRUGS.txt), and separates __unknown drugs__ as well (drugInteractionsFolder/UNKNOWNDRUGS.txt).  Looking up generic drugs also pulls their brand-name equivalents, so redundancy is minimized.  Finally, each step is detailed in a Log file (drugInteractionsFolder/LOG.txt) which outlines what was queried and when it was completed.

   If RXDownloader crashes, it can be started up again to continue where it left off.

3. `fixlist.sh`

   For error checking: run `bash fixlist.sh` to download a fresh copy of drugslist.txt, check each entry against the LOG file generated by RXDownloader, and remove any entries that are present in both.

[Return to Top](#table-of-contents)

[View in Folder](https://github.iu.edu/ProHealth/Drug_Interaction_Discovery/tree/master/openFDA)

---

#####PubMed:


[Return to Top](#table-of-contents)
---

#####Confidence:

[Return to Top](#table-of-contents)
---

#####Learning:

[Return to Top](#table-of-contents)
---

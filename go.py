import csv
import re

def isInitialVowel(s):
  return (len(s)>0 and s[0].lower() in 'aeiouáéíóúàèìòù')

def isLenitableS(s):
  return len(s)>1 and s[0] in 'sS' and (s[1].lower() in 'lnr' or isInitialVowel(s[1]))

def isLenitable(s):
  return isLenitableS(s) or (len(s)>0 and s[0].lower() in 'bcdfgmpt')

def addWord(d,w,flags=None):
  if w not in d:
    d[w] = set()
  if flags:
    for f in flags:
      d[w].add(f)

def addWords(checker, gocOnly, tostrip):
  with open('vspellcheckerexport.csv', newline='', encoding="utf8") as csvfile:
    freader = csv.reader(csvfile, delimiter=',', quotechar='"')
    next(freader, None)  # skip header row
    for row in freader:
      bristeacha = row[2]
      aicme = row[4]
      roinn = row[5]
      wordlist = row[1] if gocOnly else row[3]
      wordInRow = 0
      for w in wordlist.split(', '):
        if ' ' in w or roinn=='NULL' or aicme=='':
          for x in w.split():
            addWord(checker,x.rstrip('!.,;)'))
        elif w=='':
          pass
        elif w in tostrip:
          pass
        else:
          w = w.rstrip('.') # add abbreviations without .
          addWord(checker,w)
          if roinn=='noun' and aicme!='rio.':
            if aicme=='boir.' or aicme=='fir.':
              addWord(checker,w,'K')
            if re.match('^ainm',aicme) and (isInitialVowel(w) or w[0].lower()=='f'):
              addWord(checker,w,'E')
            elif isInitialVowel(w):
              addWord(checker,w,'DEHKN')
              if aicme=='fir.':
                addWord(checker,w,'T')
            elif isLenitableS(w):  # masc and fem?
              addWord(checker,w,'T')
            elif w[0].lower()=='f':
              addWord(checker,w,'DE')
          elif roinn=='verb':
            if w[-3:]=='inn':
              addWord(checker,w+'-sa')
            elif w[-5:]=='amaid':
              addWord(checker,w+'-ne')
          elif roinn=='adjective':
              if wordInRow==0 and isInitialVowel(w):
                addWord(checker,w,'GK')
              else:
                addWord(checker,w,'K')
        wordInRow += 1
  csvfile.close()

def writeDict(checker, filename):
  output = open(filename, 'w', encoding="utf8")
  output.write(str(len(goc.keys()))+'\n')
  for w in sorted(goc):
    flaglist = list(goc[w])
    flaglist.sort()
    flags = ''.join(flaglist)
    if flags:
      output.write(w+'/'+flags+'\n')
    else:
      output.write(w+'\n')
  output.close()
  
  
striplist=set()
with open('striplist.txt', newline='', encoding="utf8") as stripfile:
  for line in stripfile:
    striplist.add(line.rstrip('\n'))

goc = dict()
with open('propernouns.txt', newline='', encoding="utf8") as prop:
  for line in prop:
    if '.' not in line and '/' not in line:
      addWord(goc,line.rstrip('\n'))
with open('semigaelic.txt', newline='', encoding="utf8") as prop:
  for line in prop:
    if '.' not in line and '/' not in line:
      addWord(goc,line.rstrip('\n'))
    
addWords(goc, True, striplist)
writeDict(goc, 'gd_GB.dic')
addWords(goc, False, striplist)
writeDict(goc, 'gd_GB_2.dic')

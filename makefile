# spell checker version
VERSION=2.1
#MAKESCRIPT=${HOME}/seal/make-extensions/make-extensions
MAKESCRIPT=${HOME}/Dearbhair/make-extensions
SOURCE=Entries.csv

all: gd_GB.zip glan.txt scrabble.zip

# distro of this build package, not of the spell checker
dist: FORCE
	rm -f gd.zip
	zip gd.zip gd_GB.aff makefile README_gd_GB.txt striplist.txt unlenitables.txt lumpaffixes.pl

glan.txt: gd_GB.dic gd_GB.aff unmunch.sh
	bash unmunch.sh gd_GB.dic gd_GB.aff | LC_ALL=C sort -u > $@

gd_GB.zip gd-GB-dictionary.xpi: gd_GB.dic
	sed -i "/^This is version.*of hunspell-gd/s/.*/This is version $(VERSION) of hunspell-gd./" README_gd_GB.txt
	$(MAKESCRIPT) gd_GB 'Scottish Gaelic' 'Scotland' $(VERSION) 'An dearbhair-litreachaidh beag airson Mozilla'

gd_GB-scrabble.aff: gd_GB.aff
	cat gd_GB.aff | sed '/^SFX K.*igin/s/^/#/' | sed '/^SFX K Y/s/6/4/' > $@

scrabble-afb.txt: gd_GB.dic gd_GB-scrabble.aff unmunch.sh
	bash unmunch.sh gd_GB.dic gd_GB-scrabble.aff | LC_ALL=C sort -u | egrep -v '[A-ZÀÈÌÒÙÁÉÓ]' | egrep -v "[^a-il-prstuáéíóúàèìòù]" | egrep '..' | egrep -v 'ê' | tr "áéíóú" "àèìòù" | keepif -n striplist.txt | LC_ALL=C sort -u > $@

scrabble.txt: scrabble-afb.txt
	LC_ALL=C sort -u scrabble-afb.txt > $@

scrabble.zip: scrabble.txt
	zip $@ scrabble.txt
	cp $@ ${HOME}/public_html/obair

# sed -i '/\//s/$$/K/; /\//!s/$$/\/K/' $@
gd_GB.dic : all.txt withflags.txt grave-all.txt grave-withflags.txt
	cat all.txt withflags.txt grave-all.txt grave-withflags.txt | perl lumpaffixes.pl | LC_ALL=C sort -u > $@
	cat unlenitables.txt | while read x; do sed -i "s/^\($$x\/.*\)S/\1/" $@; done
	cat striplist.txt | while read x; do sed -i "/^$$x\//d" $@; done
	sed -i "1s/.*/`cat gd_GB.dic | wc -l`\n&/" $@
    
# AFB entries from 2nd field - all inflected forms
all.txt : $(SOURCE)
	cat $(SOURCE) | egrep -v '^#' | tr -d '\015' | sed 's/ﬁ/fi/g' | sed 's/,dòighean-/, dòighean-/' | tr -d "\t" | tr -d '*:' | sed "s/’/'/g" | sed 's/…//g' | sed 's/""/\\"/g' | sed 's/^[^,]*,//' | sed 's/\\"//g' | sed 's/,[^,]*$$//' | sed 's/^"//' | sed 's/"$$//' | sed 's/([^)]*)//g' | sed 's/\[[^ ]*\]//g' | sed 's/^ *//' | sed 's/ *$$//' | sed 's/, /\n/g' | tr '/' "\n" | tr " " "\n" | sed 's/[!,.;?]*$$//' | egrep -v '^\[.*\]$$' | sed 's/^(\(.*\))$$/\1/' | sed 's/^{\(.*\)}$$/\1/' | sed 's/^(//' | sed 's/[!,.;?)]*$$//' | egrep -v '[~#&.;){}!0-9]' | sed '/\]/d' | sed '/\[/d' | tr -d '(' | egrep '[A-Za-z]' | egrep -v '^\(-' | egrep -v "'.*'" | egrep -v -- '^-' | egrep -v '^(B|neg)$$' | LC_ALL=C sort -u > $@

adjectives.txt : $(SOURCE)
	cat $(SOURCE) | egrep -v '^#' | tr -d '\015' | egrep '^[0-9]+,"' | egrep ',Adjective' | sed 's/^[^,]*,"//' | sed 's/",Adjective.*//' | egrep '^[^ ][^ ]+,' > $@

masc.txt : $(SOURCE)
	cat $(SOURCE) | egrep -v '^#' | tr -d '\015' | egrep '^[0-9]+,"' | egrep ',Common Masculine' | sed 's/^[^,]*,"//' | sed 's/",Common Masculine.*//' | egrep '^[^ ][^ ]+,' > $@

fem.txt : $(SOURCE)
	cat $(SOURCE) | egrep -v '^#' | tr -d '\015' | egrep '^[0-9]+,"' | egrep ',Common Feminine' | sed 's/^[^,]*,"//' | sed 's/",Common Feminine.*//' | egrep '^[^ ][^ ]+,' > $@

verb.txt : $(SOURCE)
	cat $(SOURCE) | egrep -v '^#' | tr -d '\015' | egrep '^[0-9]+,"' | egrep ',Verb' | sed 's/^[^,]*,"//' | sed 's/",Verb.*//' | egrep '^[^ ][^ ]+,' > $@

# headwords from AFB with POS-appropriate affix flags added
# special cases at end are adjectives that can take t-; MB email 11 Aug 2010
# then we might add /T more selectively, like this:
#	cat masc.txt | egrep '^[Ss][aeiouàèìòùáéíóúlnr]' | sed 's/^[^,]*,[^,]*, *//' | sed 's/,.*/\/KST/' >> $@
#  No need to add /S flags explicitly since AFB includes lenited forms among inflections; we'll get those in all.txt
# email 27 Nov 2011; don't add any flags to verbs...
# cat verb.txt | sed '/^[aeiouAEIOUàèìòùÀÈÌÒÙáéíóúÁÉÍÓÚ]/s/,.*/\/EHK/' | sed '/^[Ff]/s/,.*/\/EK/' | sed '/,/s/,.*/\/K/' >> $@
withflags.txt : adjectives.txt masc.txt fem.txt verb.txt
	cat masc.txt | sed '/^[aeiouAEIOUàèìòùÀÈÌÒÙáéíóúÁÉÍÓÚ]/s/,.*/\/EHKNT/' | sed '/^[Ff]/s/,.*/\/EK/' | sed '/^[Ss]/s/,.*/\/KT/' | sed '/,/s/,.*/\/K/' > $@
	cat masc.txt | tr " ," "\n\n" | egrep '.' | LC_ALL=C sort -u | sed '/^[aeiouAEIOUàèìòùÀÈÌÒÙáéíóúÁÉÍÓÚ]/s/$$/\/EHKN/' | sed '/^[Ff]/s/$$/\/EK/' | sed '/^[Ss]/s/$$/\/KT/' | sed '/^[^aeiouAEIOUàèìòùÀÈÌÒÙáéíóúÁÉÍÓÚFfSs]/s/$$/\/K/' >> $@ 
	cat fem.txt | sed '/^[aeiouAEIOUàèìòùÀÈÌÒÙáéíóúÁÉÍÓÚ]/s/,.*/\/EHKN/' | sed '/^[Ff]/s/,.*/\/EK/' | sed '/^[Ss]/s/,.*/\/KT/' | sed '/,/s/,.*/\/K/' >> $@
	cat fem.txt | tr " ," "\n\n" | egrep '.' | LC_ALL=C sort -u | sed '/^[aeiouAEIOUàèìòùÀÈÌÒÙáéíóúÁÉÍÓÚ]/s/$$/\/EHKN/' | sed '/^[Ff]/s/$$/\/EK/' | sed '/^[Ss]/s/$$/\/KT/' | sed '/^[^aeiouAEIOUàèìòùÀÈÌÒÙáéíóúÁÉÍÓÚFfSs]/s/$$/\/K/' >> $@ 
	cat adjectives.txt | sed '/^[aeiouAEIOUàèìòùÀÈÌÒÙáéíóúÁÉÍÓÚ]/s/,.*/\/H/' | sed '/,/s/,.*//' >> $@
	sed -i '/^àrd\//s/$$/T/; /^ùr\//s/$$/T/; /^ath\//s/$$/T/' $@
	echo "aonamh/EHT" >> $@
	echo "ochdamh/EHT" >> $@
	echo "olc/EHT" >> $@
	echo "uile/EHT" >> $@
	echo "siathamh/ST" >> $@
	echo "seachdamh/ST" >> $@
	echo "sàr/ST" >> $@

grave-all.txt : all.txt
	cat all.txt | egrep '[áéíóúÁÉÍÓÚ]' | tr 'áéíóúÁÉÍÓÚ' 'àèìòùÀÈÌÒÙ' > $@

grave-withflags.txt : withflags.txt
	cat withflags.txt | egrep '[áéíóúÁÉÍÓÚ]' | tr 'áéíóúÁÉÍÓÚ' 'àèìòùÀÈÌÒÙ' > $@

# temp helper to avoid over-generating on Dwelly words we already have in AFB
withflags-justheads.txt : withflags.txt grave-withflags.txt
	cat withflags.txt grave-withflags.txt | egrep '/' | sed 's/\/.*//' > $@

# dimwitted affixes added - bad overgeneration
#  dwelly.txt comes from idirlamha/gd/dwelly, "all.txt" target
#  NO LONGER USED!
dwelly-aff.txt : dwelly.txt withflags-justheads.txt
	cat dwelly.txt | keepif -n withflags-justheads.txt | sed '/^[aeiouAEIOUàèìòùÀÈÌÒÙáéíóúÁÉÍÓÚ][a-zàèìòùáéíóú]/s/$$/\/EHNT/' | sed '/^[Ff][a-zàèìòùáéíóú]/s/$$/\/ES/' | sed '/^[Ss][aeiouàèìòùáéíóúlnr]/s/$$/\/ST/' | sed '/^[BbCcDdGgMmPpTt][a-gi-zàèìòùáéíóú]/s/$$/\/S/' > $@

# NO LONGER USED!
gd_GB-dwelly.dic : dwelly-aff.txt
	cp dwelly-aff.txt $@
	cat unlenitables.txt | while read x; do sed -i "s/^\($$x\/.*\)S/\1/" $@; done
	cat striplist.txt | while read x; do sed -i "/^$$x\//d" $@; done
	sed -i "1s/.*/`cat gd_GB.dic | wc -l`\n&/" $@

# NO LONGER USED
gd_GB-afb-and-dwelly.dic : all.txt withflags.txt dwelly-aff.txt grave-all.txt grave-withflags.txt
	cat all.txt withflags.txt dwelly-aff.txt grave-all.txt grave-withflags.txt | perl lumpaffixes.pl | LC_ALL=C sort -u > $@
	sed -i '/\//s/$$/K/; /\//!s/$$/\/K/' $@
	cat unlenitables.txt | while read x; do sed -i "s/^\($$x\/.*\)S/\1/" $@; done
	cat striplist.txt | while read x; do sed -i "/^$$x\//d" $@; done
	sed -i "1s/.*/`cat gd_GB.dic | wc -l`\n&/" $@


clean:
	rm -f all.txt withflags.txt grave-all.txt grave-withflags.txt dwelly.txt dwelly-aff.txt withflags-justheads.txt missing*.txt gd_GB.dic *.xpi *.oxt *.zip all-old.txt glan.txt gd_GB-scrabble.aff scrabble*.txt gd_GB-dwelly.dic gd_GB-afb.dic scrab-afb-stats.txt adjectives.txt masc.txt fem.txt verb.txt

FORCE:

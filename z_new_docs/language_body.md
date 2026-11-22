
# ---- Changes:
Done. Hindi + Arabic are in the backend; company enabled set is the client’s 19.

Catalog (20) — HU kept but not enabled:

Code	Locale	Flag	Name
HI
hi
IN
Hindi
AR
ar
SA
Arabic
HU
hu
HU
Hungarian (catalog only)
Enabled for this company (19):


DE, EN, TR, PL, RO, FR, ES, IT, NL, PT, RU, UK, BG, HR, SR, SQ, EL, HI, AR
GET /mobile/config → enabledLanguages should now return that list (no HU).
Share with app: use API codes HI / AR, locales hi / ar.

# ------->>>>>>>>>>>>


All 18 API language codes (Language enum / POST /settings/language body):

API language	Locale (x-locale)	Flag / display	Name
DE
de
DE
German
EN
en
GB
English
PL
pl
PL
Polish
RO
ro
RO
Romanian
TR
tr
TR
Turkish
BG
bg
BG
Bulgarian
HR
hr
HR
Croatian
SR
sr
RS
Serbian
UK
uk
UA
Ukrainian
RU
ru
RU
Russian
SQ
sq
AL
Albanian
IT
it
IT
Italian
FR
fr
FR
French
ES
es
ES
Spanish
PT
pt
PT
Portuguese
NL
nl
NL
Dutch
EL
el
GR
Greek
HU
hu
HU
Hungarian
Copy-paste enum list:


DE, EN, PL, RO, TR, BG, HR, SR, UK, RU, SQ, IT, FR, ES, PT, NL, EL, HU
Change language:


POST /api/v1/settings/language
{ "language": "RO" }
Enabled subset for the company comes from GET /mobile/config → enabledLanguages (not always all 18).


Agent

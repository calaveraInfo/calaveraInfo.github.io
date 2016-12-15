---
title: Method level caching
translationEn: /v3/blog/2016/07/01/method-level-caching-en.html
---

Mám rád slovo "kurvítko". Je takové hezky české a přes zdánlivou lidovost má pro mě exaktní význam, který bych jinak musel vyjadřovat poměrně nudným opisem. Je to součástka, která má v nějakém větším celku objektivně malý nebo diskutabilní význam, ale která ho zároveň dokáže solidně rozjebat. Svět samozřejmě není černobílý, takže je u součástek lepší mluvit o "kurvítko indexu", který vyjadřuje poměr mezi zmíněnými vlastnostmi.  Ze zkušenosti mám u různých vývojářských praktik ‎přiřazený svůj interní kurvítko index, který hodně ovlivňuje moje architektonická rozhodnutí. Pro zajímavost, víte co má u mě nejvyšší kurvítko index? Suverénně Caching a High availability.

Mazáci vědí, že cache představuje z hlediska abstrakce [dva nejtěžší problémy počítačové vědy vůbec][fowler:two]. Tímto konstatováním by článek mohl skončit, protože říká vše potřebné, ale nikdo nemá tak velkou fantazii, aby si jenom na základě toho dokázal představit, jak děsivé jsou důsledky. Proto bych tu problematiku rád odvyprávěl optikou normálního kodéra skrz banální praxi, kde se ty vznešené myšlenky i pouhé obskurní neduhy lidské psychologie střetávají na jedné úrovni.

Cachování je technika stará jako programování samo, co se tedy stalo, že je potřeba o tom mluvit zrovna teď? Dokud byl caching v softwaru aplikován na jasně vymezenou doménu, jako například cachovaní celých HTML stránek, bylo to ok. Cachovací nástroje se ale postupně zobecňovaly, až se nakonec i v mainstreamu objevily [nástroje aplikující caching formou metainformací rovnou na úrovni jednotlivých funkcí/metod][Spring:cache]. Větší obecností a granularitou cachování se sice principiálně nic nezměnilo, ale negativa se projevují daleko více a jsou mnohem hůře řešitelná než u doménově specifického cachování. Budu tedy mluvit konkrétně o cachování na úrovni metod, protože se to na něm vysvětluje nejjednodušeji, ale v menší míře se to týká cachování obecně.

## Zadarmo to nebude

Na první pohled je to jednoduché: máte problém s performance? Hoďte na pár vytipovaných metod @Cacheable a je to. Přesně takhle vidí caching projektový management a přesně takhle většinou vypadají školení od architektů pro zbytek týmu. Tohle počáteční zdání všech zúčastněných, že caching je výkonnostní "free lunch" je celkem zásadní faktor ve velikosti kurvítko indexu. Lidi totiž zjistí, že něco není v pořádku až když průšvih nepozorovaně proklouzne až do produkce.

Co se týče přínosů, tak zásadní věc je, že aby cache vůbec k něčemu byla, musí se dobře nastavit, což je dlouhodobá a týmová práce mezi vývojáři a provozáky. Ti první rozhodují jaká data do jakých cachí se budou dávat a jak se s nimi bude pracovat, ti druzí pak nastavují parametry dodaných cachí podle hardwaru, profilů zátěže, systémové konfigurace a hlavně monitoringu reálného chování. Dohromady to je trochu [černá magie][Pinos:cache] kde jedna činnost závisí na druhé v kruhu, ale většinou se to nijak neřeší ani v technickém designu, ani manažersky (protože stačí tam dát @Cacheable, že jo).

Navíc ve většině velkých firem mají vztahy vývoje a provozu k DevOps idylce velmi daleko a oddělení spolu vedou spíše zákopovou válku. Reálně tak aplikace často skončí v produkci s defaultními parametry nastřelenými naslepo přímo od vývojáře, a operations se toho nedotknou ani dvoumetrovou holí, protože to berou jako aplikační nastavení, což není jejich věc. Když říkám, že výsledky takového cachování jsou katastrofické, nemyslím tím plus mínus pár procent předpokládané úspory, ale to, že výsledný výkonnostní efekt může být záporný! O tom, proč runtime náklady cache nemusí být zrovna malé, za chvíli.

## Klíče, klíče, klíče

Ohledně přínosů tedy stačí trochu podcenit složitost celého procesu a mohou být směšně malé. Teď se podívejme na druhou stranu - jaké problémy může cachování přinést? Ty hlavní se všechny točí okolo jednoho tématu: generování klíčů pro cachované položky.

Selský rozum se spokojí s vysvětlením, že klíče se počítají z parametrů cachované metody zhruba podobně, jako hash do hash mapy. Zkušenější si možná ještě ověří, že se do hashe započítává i jméno metody, jinak by se vracel stejný výsledek z jakékoli cachované metody se stejnou signaturou. Ano, toto absurdní chování je stále ještě [výchozí chování][ehcache-annotations] některých frameworků.

Samozřejmě ani jméno metody není zdaleka neprůstřelný způsob zajištění unikátnosti klíče, viz typická jména metod DAO pro různé entity jako například getById(long id) apod. Nestačí tedy defaultně přidávat k hashi i jméno třídy? To už není výchozí chování v žádném frameworku, ale ani to nemusí stačit - co když je metoda na abstraktním generickém předkovi (což je typické třeba pro DAO implementované pomocí JPA)?

Takových scénářů, banálních, ale reálných, se dá vymyslet docela dost. Rozvádět to ale nebudu, protože tyhle naivní chyby jsou ve skutečnosti ten menší problém. I pokud už nastanou, jsou většinou explicitní (class cast exception), nastávají většinou konzistentně a proto jsou zachyceny už během vývoje a oprava je pro konkrétní případy přímočará.

Ten hlavní problém má kořen v tom, že cache nemusí být hash mapa. Hash mapa používá hash jen k určení pozice, kde záznam hledat, finální výběr probíhá pomocí equals. To cache dělat nemusí, resp. mohou si to paradoxně dovolit jen primitivní in memory implementace. Pro ty profesionálnější je naopak klíč absolutní identifikace. Proč by vás to mělo zajímat? Protože většina implementací hash algoritmů kolize moc neřeší (přestože by měly, o tom ale později) a obětuje odolnost proti kolizím za rychlost. Jestli jste o tom doteď nevěděli a pochybujete, ukázkový příklad je [algoritmus hashe pro obyčejný String ve starší Javě][Java String]. Omezení na 16 znaků nevypadá úplně bezpečně, že? Takhle křiklavé případy už jsou naštěstí opraveny, ale subtilnější zůstávají.

Nejen z těchto důvodů je dobré nespoléhat se automaticky na [defaultní generátor klíčů][Spring:default], ale vybrat vhodnou kombinaci generátoru a cache implementace, jejíž prioritou nemusí být rychlost (sic!), ale odolnost proti kolizím. Kolize jsou totiž v tomto kontextu naprostá katastrofa. Z cachované metody se zcela potichu může vrátit objekt pro úplně jiné parametry!

Pokud tedy cachujete například servisní metodu, kde se autorizace pro daná data kontroluje až uvnitř, kolize klíče cachované položky toto zabezpečení obchází. Na první pohled je to jen plané sýčkování, protože klíče jsou dlouhé a generovací algoritmy taky určitě nebudou úplně hloupé, takže možnost náhodné kolize je absurdní, ale vraťme se ještě k mojí poznámce, že ani standardní hash algoritmy by neměly být příliš naivní.

Ačkoli je hash mapa vůči kolizím klíčů na první pohled odolná, přesto je to v praxi [základ vektoru pro denial of service útok][funkcionalne.cz:hash]. S tímto vědomím si zkuste představit, jaké úsilí vloží útočník do odhalování kolizí když jeho odměna nebude prosté zastavení služby, ale krádež dat. Možná můžete věřit, že hash algoritmus je kvalitní ve smyslu náhodných kolizí, ale je kryptograficky kvalitní? Nejen že to sám neumím ověřit, ale ani neznám nikoho, kdo by to ověřit uměl.

Bez matematického génia v týmu je tak asi lepší strategie ověřovat v code review, že do klíče se započítává jen nezbytně nutné množství dat z parametrů a žádné z nich nejsou ovlivnitelné uživatelem. Dobrá pojistka proti úniku uživatelských dat je také vytvoření vlastního rozšíření generátoru klíčů, který je bude prefixovat identifikátorem přihlášeného uživatele tak, aby z principu nebylo možné dosáhnout kolize pro cache dat dvou různých uživatelů.

Takže si to shrňme: použitím method level cache může libovolný programátor v libovolném místě programu obejít všechny programátorské pojistky od kompilátoru až po bezpečnostní audit. Může to být v důsledku nesprávného použití, špatného nastavení, náhodné konstelace dat nebo cíleného útoku. V lepším případě pak dojde *jen* k fatální chybě, v horším případě bude aplikace potichu rozdávat data. Když se to takhle podá, snad už je jasné, proč by se mělo cachování prezentovat jako odjištěný granát mezi dětskými hračkami. A to jsem popsal jen špičku ledovce.

## Stav
Teď na chvíli odložím svou paranoiu a napíšu ještě něco málo o softwarově inženýrském hledisku cache. Stejně jako na balíčkách cigeret by mělo na unpure jazycích stát varování podbarvené explicitními obrázky sebevražd vyhořelých programátorů: ["Stav způsobuje závislosti, závislosti způsobují komplexitu, komplexita zabíjí."][state] Z tohoto moudra plyne skoro podmíněný reflex zkušených programátorů eliminovat jakýkoli zbytný stav (který často přešvihne až do podoby [obsese funkcionálním programováním][calavera.info:funkcionalni]). Cache jde ale naopak přímo opačným směrem - zavádí implicitní stav tam, kde nebyl.

Závislost pak spočívá v tom, že při jakékoli manipulaci s daty je potřeba kromě primárního úložiště přemýšlet nad tím, kde kterou cache je potřeba ještě vyčistit od zastaralých záznamů. Čím víc dat je v cache, tím víc míst bude nějakou takovou závislost mít. Čím složitější data se v cache uchovávají, tím složitější bude poznat, že taková závislost vůbec existuje a nezapomenout na ní.

Tohle je problém známý a zřejmý, takže stejně jako v případě klíčů se radši podívejme na zákeřnější důsledky cache jako stavu aplikace. Já osobně jsem jsem si je v praxi uvědomil až při práci pro finanční instituci, která ze zákona musí informovat všechny zúčastněné stejným způsobem. Pokud tedy její web běží na clusteru, nesmí se stát, aby člověk přistupující na jeden node získal nějakou informaci kvůli cachování byť i jen o minutu déle, než člověk přistupující na druhý node.

Logickým krokem je v takovém případě použití implementace cache se synchronizací. Návod vypadá jako volební program ANO - [prostě povolte UDP multicast mezi nody a stav jejich cache se prostě bude  synchronizovat][ehcache:synchro]. Ve všech cache bude to samé, takže všichni budou mít stejná data. Jednoduché.

Realita je ale taková, že jsme právě nepopsali nic menšího než jeden z nejobtížnějších problémů distribuovaných systémů vůbec - jejich konzistence. Ten [podle většinového názoru nejde vyřešit bez kompromisů][cap], proto je ostatně většinou i v srdci větších systémů jedna monolitická databáze. Pokud opravdu existují na systém striktní regulatorní požadavky, je potřeba vědět, jaké kompromisy vybraná implementace cache dělá, jinak se s jakýmikoli garancemi můžete šeredně spálit. I toto je odvrácená tvář nově zavedeného stavu.

## Drobnosti
Proti výše popsaným šílenostem jsou moje další poznámky vlastně drobnosti, takže jen telegraficky:

- při použití standardního hashCode pro generování klíčů často mezi parametry proklouzne třída, která jej neoverriduje, čímž efektivně cachování vypne (hashCode je pro každou instanci jiná).
- podobně se dá neúmyslně vypnout cachování když se mezi parametry vloudí objekt typu java.util.Date, u kterého se do hashCode započítává potenciálně bezvýznamná položka, jako je počet milisekund. To se často nevědomky inicializuje na náhodnou aktuální hodnotu a málokdo to po nastavení těch významových položek resetuje.
- vzhledem k množství problémů s použitím hashCode mají některé frameworky svůj defaultní generátor klíčů založený na reflexi. To s sebou ale nese vlastní specifickou sadu problémů.
- umístit anotaci Cacheable na třídu je velmi nebezpečné, protože může vést ke cachování metod, u kterých to autor nezamýšlel
- pokud je na metodě více anotací, je důležité vědět, v jakém pořadí vůči cache se vytvoří příslušné proxy. Už jsem zmiňoval například security důsledky pokud je autorizace kontrolována až za cache, ale zajímavá je třeba taky Transactional, která může zahájit transakci, přestože se nakonec vrátí cachovaná hodnota a tím prakticky zruší jakýkoli přínos cache.

## Uf...
Nechápejte mě špatně, rozumně použitá cache je velmi užitečný nástroj, proto se také [standardizuje][jsr-107]. Pro jednorázově nastavené/neměnné hodnoty, jako např. konfigurace aplikace nebo číselníky je její použití skutečně jednoduché a bezpečné. Chtěl jsem ale ukázat, jak obrovská chyba by bylo považovat jí za bezpracnou silver bullet pro performance, jak se to často děje.

[state]: https://blog.acolyer.org/2015/03/20/out-of-the-tar-pit/
[fowler:two]: http://martinfowler.com/bliki/TwoHardThings.html
[jsr-107]: https://jcp.org/en/jsr/detail?id=107
[cap]: https://en.wikipedia.org/wiki/CAP_theorem
[ehcache:synchro]: http://www.ehcache.org/documentation/2.8/replication/jgroups-replicated-caching.html#example-configuration-using-udp-multicast
[Pinos:cache]: http://tom2ee.blogspot.cz/2015/11/jak-se-vyplati-kesovani.html
[Java String]: https://en.wikipedia.org/wiki/Java_hashCode%28%29
[funkcionalne.cz:hash]: http://funkcionalne.cz/2016/02/kolize-hashu-pro-mirne-pokrocile/
[Spring:default]: https://github.com/spring-projects/spring-framework/blob/master/spring-context/src/main/java/org/springframework/cache/interceptor/DefaultKeyGenerator.java
[Spring:cache]: http://docs.spring.io/spring/docs/current/spring-framework-reference/html/cache.html
[ehcache-annotations]: https://code.google.com/archive/p/ehcache-spring-annotations/
[calavera.info:funkcionalni]: http://calavera.info/v3/blog/2016/04/24/objektove-vs-funkcionalni.html
[jsr-107]: https://jcp.org/en/jsr/detail?id=107

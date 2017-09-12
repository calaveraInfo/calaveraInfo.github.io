---
title: Modularita
---

Tenhle článek v průběhu mnoha měsíců předělávání a doplňování
narostl do nestvůrných rozměrů. Na začátku jsem si jen
chtěl utřídit myšlenky k tématu modularity a skončil jsem
s monstrem, kterou nejsem schopný zkrotit. Chtělo
by to masivně proškrtat a vydestilovat, ale už na to prostě nemám.
Jestli to někdo přečte celé, má u mě pivo.

## Kapitola 1: Ekonomie modularity

Alfa a omega modularity jsou kontrakty mezi moduly. Obecně se kontrakty považují za hochnóblové slovo pro API, ale to je obrovské zjednodušení. Jednak proto, že API občas nestačí ani na základní funkční specifikaci a musí být doplněno [protokolem][datalog] a jednak proto, že API (spíše podvědomě než z definice) implikuje pouze jednu variantu kontraktu - jednostranný kontrakt definovaný poskytovatelem služby. To má ekonomický smysl v podobě přepoužitelnosti takové služby, tzn. sdílení nákladů.

Ekonomicky může mít ale jednostranný kontrakt i úplně jiný účel: flexibilitu. To když je kontrakt definován (vlastněn) odběratelem služby. Pak si může odběratel vybírat a měnit dodavatele (implementaci) jak se mu zachce. Podle ceny, přidané hodnoty, čehokoli. V programování se tomu říká [dependency inversion][inversion] a je to základní architektonický nástroj. Hned vysvětlím proč.

Kromě strategického výběru mezi přepoužitelností a flexibilitou je totiž možné se na tuto závislost dívat ještě z jiného pohledu - v praxi definuje, čí zájmy bude kontrakt přednostně řešit. Jestli zájem dodavatele na rozvoji jím dodávaného produktu nebo zájem odběratele na stabilitě nebo rozvoji produktu odvozeného. Tu první situaci je možné si představit třeba na příkladu, kdy telefonní operátor jednostranně zavede v obchodních podmínkách FUP. Klient může nesouhlasit, ale břímě spojené se změnou operátora leží na něm. Ta druhá situace je vidět třeba na příkladu veřejných zakázek. Vypíše se jasně definovaná zakázka a kdo dá za daných podmínek lepší cenu, vyhrál.

Právě tenhle netechnický význam kontraktu je jedno z klíčových nedorozumění mezi počítačovou vědou a praktikujícími architekty. Matematiku nezajímá, jaké podpůrné lešení je potřeba postavit k výrobě algoritmu samotného, ani kdo z něj bude mít prospěch či újmu. V praxi ale kraluje [Conwayův zákon][conway] a struktura software a struktura organizace, která jej vytváří, je neoddělitelně spojena a na ekonomickém významu kontraktů mezi jednotlivými částmi proto sakra záleží. Pro toho, kdo má zajistit, že se projekt nezhroutí vlastní organizační vahou, má teorie her a kontraktů stejný význam jako lambda kalkulus nebo turingův stroj.

OOP a tooling okolo něj pak začne dávat trochu smysl. Napodobování komunikačních schémat objektů reálného světa může být z matematického pohledu extrémně nevhodný nástroj algoritmizace, ale na druhou stranu je v něm modelování ekonomických vztahů first class citizen a to v celé jejich šíři.

Že to má velký význam nevědomky ilustruje třeba [přednáška Riche Hickeyho o tomto tématu v souvislosti se Spec][spec]. Všimněte si na ní, že definice slov Accretion a Breakage, na kterých všechny jeho úvahy stojí, vychází z implicitní představy kontraktu na straně dodavatele. V opačném scénáři, kontrakt definovaný odběratelem, by však tyto slova měli přesně opačný význam a veškerá jednoduchost by byla rázem v tahu. Tohle ale nemůže být výčitka, protože takový scénář nemá žádnou oporu v základním výpočetním modelu, díky kterému je jinak Clojure tak skvělý jazyk.

Zcela chápu právoplatné rozhořčení nad myšlenkou, že by se kvůli zatažení "ekonomické politiky" do vývoje měly obětovat plody matematiky za poslední půlstoletí, ale právě tady vstupuje do hry modularita, protože:

1. [Composability is destroyed at the IO boundaries in any language][composability]. Čím více oddělených modulů, tím více IO boundaries kde se bude projevovat Conwayův zákon a vůbec nezáleží na tom, jestli jsou ty hranice modulů externí nebo interní. Čistě matematický přístup se pak umonáduje a ztrácí dost ze svého smyslu.
2. Teorie kontraktů je matematická disciplína jako každá jiná - modely, důkazy a tak, dokonce nobelova cena za ekonomii byla udělena minulý rok právě za ní. Jenom si na rozdíl od lambda kalkulu nemůže zjednodušit práci immutabilitou a podobně, protože lidské vztahy prostě immutabilní nejsou.

Jakkoli to tedy zní strašidelně, možná by stálo za to zkusit cíleně najít hlubší paralely mezi programováním a ekonomií a zjistit, jestli si z toho oboru nemůžeme vzít víc, než těch pár mlhavých představ rozepsaných výše. A tak začalo moje hledání svatého grálu modularity. Nebudu napínat až do konce: žádný není. Ale cesta za ním je, jako v pohádce, důležitější než existence samotná.

## Kapitola 2: Modularita pro profesionály

V předchozí kapitole se mi snad povedlo přesvědčit alespoň někoho, že modelování modularity a architektura informačních systémů vůbec řeší trochu víc než samotná algoritmizace a obecná abstrakce. Snažil jsem se tím trochu rehabilitovat myšlenku OOP jako užitečného nástroje pro vybudování příslušné intuice. V téhle kapitole se budu věnovat tomu, že jsem tím rozhodně nemyslel Javu.

### Co vlastně řeší OSGi

Musím se ostudně přiznat, že až do nedávna jsem sám nechápal smysl OSGi. Moduly a závislosti mezi nimi je přeci možné deklarovat v Mavenu a dynamické načítání částí programu je také možné realizovat pomocí pokročilé práce s classloadery, to dělají třeba servlet kontejnery odjakživa. Tak proč zcela nová technologie?

Až nedávno jsem pochopil, že jsem ve skutečnosti nikdy nepracoval s doopravdy modulární architekturou. Že přes veškerou složitost a hloubku tranzitivních závislostí v nich nemáme žádné cykly a konflikty jen takové, že se dají vyřešit jednorázově a trvale. Že vývoj modulů měl společný harmonogram a že měli jen pár téměř stejných odběratelů. ‎Jinak řečeno, že technicky sice aplikace do modulů rozdělené byly, ale prakticky žádný z problémů modularity řešit nemusely. A to bude asi častý omyl - modularita je problém esenciální, nikoli akcidentální. Dokud jej fakticky nemáte, je jakékoli technické řešení dostatečné.

Tahle idylka většinou skončí, když se někdo rozhodne využít deklarované "modularity" a ze stávajících modulů se má vytvořit jiný, podstatně odlišný produkt, při zachování toho původního. Místo očekávaného přeskládání lego kostiček nastane spíše něco jako transplantace orgánů. Několika najednou. Opakovaně.

Týmy v odpovědi na požadavky více produktů začnou navíc nové verze svých modulů chrlit ve vražedném tempu. Přes veškerou snahu plánované i neplánované breaking change prostě nastávají, už jen proto, že jak ukázaly [kontroverze okolo semver][semver], breaking change může být klidně i pouhá oprava bugu. Matematika pravděpodobnosti je pak nemilosrdná - jakkoli může být pravděpodobnost chyby u jednoho modulu malá, kombinovaná pravděpodobnost nekonzistence u desítek modulů dohromady je každodenní jistotou.

Co dělá tento problém v Javě (a nejen tam) obzvláště hořký je zdánlivě banální fakt, že tam **není systémová možnost ověřit kompatibilitu kontraktů kódu, který se v classpath (runtime) ocitl již zkompilovaný**. Jinak řečeno ‎kontrola, že jeden kus aplikace má vůbec šanci fungovat dohromady s jiným kusem aplikace, se provádí jen a pouze při kompilaci. A to je pro modularitu, která stojí na představě předkompilovaných stavebních bloků, vražedné.

Taková vlastnost eliminuje v modulární architektuře velkou část výhody explicitní definice kontraktů _per se_. Tím, že se většina byznys logiky v modulárních systémech přesune z vlastního kódu do předkompilovaných modulů, přesune se taky zjištění většiny zásadních chyb z kompilační fáze do runtime. A to je jádro příčiny nevyhnutelného řádového prodražení modulárních aplikací v Javě, o frustraci vývojářů nemluvě.

Jedna možnost je po vzoru Spec (a mnoha jiných) uvalit na rozhraní modulů omezení, která umožní tuto komplexitu mechanicky zvládat. [Celý minulý díl][modularita 1] jsem věnoval tomu, proč si tohle zjednodušení (zatím) odpustím. Jiná možnost je začít budovat od základu novou infrastrukturu typu OSGi, která problematiku metodicky podchytí bez umělých omezení, ale složitě. Nestačilo by však jen do Javy přidat tu vlastnost, která tam evidentně chybí?

### VerifaLabs to the rescue!

Naprostá bomba pro mě bylo zjištění, že právě tomuhle problému se zrovna v Čechách věnuje spinoff [VerifaLabs][verifalabs] z výzkumného programu [ReliSA][relisa] na Západočeské univerzitě, mojí Alma mater. A že to jsou lidé od Přemka Brady, mého dávného oponenta diplomky, se kterým jsem zůstal v občasném kontaktu, takže jsem si mohl domluvit neformální zkoušku výsledků jejich práce.

Dostali jsme k vyzkoušení alfa verzi produktu zabalenou do podoby Maven pluginu, který ve fázi "test" velmi zjednodušeně řečeno ověří každý bytekódový invoke proti skutečné bytekódové signatuře reálně přítomné na classpath. Není sice fér shrnout to nadlidské úsilí, které takový úkol vyžaduje, do tak banálního popisu, ale zájemci nechť si od kluků z VerifaLabs nechají udělat přednášku sami, je ohromující.

Byl jsem opravdu zvědavý, jak v takové analýze obstojí náš projekt. Chyb v produkci jsme zas tolik hlášených neměli, ale během vývoje jsme jich s vydáváním nových verzí modulů museli řešit vždy požehnaně, takže byla otázka, kolik nám jich uniklo. Plugin jako výstup generoval běžný textový soubor kde zhruba jeden řádek odpovídal jedné nalezené chybě. Spustil jsem analýzu a ... a výstupní soubor měl po jejím skončení 13 MB. Uf. Po rychlé validaci jsem bohužel musel uznat, že zjištěné výsledky odpovídají realitě.

Jak je to možné? Opravdu v naší aplikaci seděly desítky tisíc chyb‎ a bylo jen otázkou času, kdy se projeví? Samozřejmě, že ne. V naprosté většině se jednalo o falešně pozitivní nálezy plynoucí z toho, že moduly měly volitelné závislosti (nebo volitelně volali nekompatibilní kód v nich), které se v naší konfiguraci nikdy nemohly dostat do reálné code path. Pomalu mi začala docházet zoufalost modularity v celé svojí hrůze.

Nejde o to, že by se s tím onen validátor nedokázal vypořádat, naopak nabízel k tomu luxusní nástroje. Ale konfigurovat je z podstaty mohl jen člověk s expertní znalostí systému, který zná konfiguraci a architekturu projektu natolik dobře, aby ty nereálné code path, kde nás kompatibilita rozhraní nezajímá, dokázal spolehlivě určit (a to jsme se [undecidibility problému][undecidibility] dotkli jen velmi zlehka). Navíc při tak obřím množství hlášení existují prakticky jen dvě možnosti:

1. Obětovat vyhodnocení analýzy velké množství času a zkoumat každé hlášení zvlášť. To je dobré řešení když se jedná o kritický systém u kterého musíme mít maximální jistotu absence runtime chyb, ale dělat to třeba u webovek asi není úplně ekonomické.
2. Použít nějakou heuristiku pro hromadné zpracování (dát na blacklist celé namespacy nebo regulární výrazy). Ale to jsme zpátky tam, kde jsme byli. Zavádíme opět prvek nejistoty, šedou zónu, jejíž velikost bude úměrná kvalitě a lenosti výše zmíněných expertů.

U obou strategií navíc platí, že to nejsou jednorázové činnosti, protože konfigurace projektu se mění a s ní i dosažitelná code path. Pochopil jsem, že v opravdové modularitě závislosti faktické (runtime) budou vždy vyžadovat zcela samostatně udržovanou konfiguraci oddělenou od závislostí organizačních (compile time). Pokud mají mít moduly vůbec nějakou flexibilitu, nelze to první beze zbytku odvodit z druhého, jak se to očekává od Mavenu. Někdo musí (ať už v jakékoli podobě - OSGi manifesty nebo konfigurace výše popsaného validačního nástroje apod.), vytyčit kontext, ve kterém chce modul provozovat, protože korektnost programu nás nesmí zajímat jinde než v reálně dosažitelné code path, kterou spoluurčují _data_ a ty v buildu prostě nemáme.

### Plot twist
A nebo máme? Teď je přesně ten čas na mé obvyklé vystřízlivění ve kterém zjistím, že problém, který se sofistikovaně snažím vyřešit celé měsíce je adresován nějakou starou, běžnou a banální praktikou, kterou nemá ani cenu zmiňovat.

Je to tak. Ve skutečnosti k modularitě nepotřebujeme frameworky, experty ani šedé zóny. Ve skutečnosti existuje možnost, jak (v rozumné míře) exaktně a mechanicky určit živé code path každého projektu a kompatibilitu kontraktů na nich a to i u již zkompilovaného kódu. Tou možností jsou: BA DUM TSSS ... testy. Asi nemusím vysvětlovat proč.

‎Aby to bylo ještě ironičtějsí, přesně tuhle strategii jsem dokonce sám rozebíral v [prvním článku na tomto blogu o tom, jak udělat flexibilnější XML služby][api vs protokol] už před více než rokem. Jen to tenkrát bylo ‎z trochu jiného pohledu a nedocházela mi obecnost toho řešení ve vztahu k modularitě.

## Kapitola 3: Modularita pro amatéry

Složitější to je, když - v analogové terminologii - trváme na použití součástek bez toho, abychom s dodavatelem sepsali smlouvu o jejich dodávkách a parametrech. V téhle kapitole si zatím vystačíme s jednodušší variantou, kdy smluvně nepodchycené dodávky používáme pouze při výrobě produktu (sestavování classpath), ne až při jeho provozu. Stejně ale tady už s mým ekonomickým vzděláním nedokážu načrtnout žádnou paralelu aby nekulhala na obě nohy, snad to někdo dokáže v komentářích.

Základem, jak jsem "objevil" výše, mohou být pro tento případ testy. Interakci mezi jednotlivými moduly mají ale v popisu práce testovat až integrační testy, které jsou většinou pojaty jako funkční testy. To je pro zjištění, že jsou moduly binárně nekompatibilní, trochu pozdě, nemluvě o tom, že se takové testy nedají přepoužít. Tady ještě analogová paralela existuje - nechceme postavit celé auto abychom zjistili, že ložisko má jiný rozměr než jeho objímka. Potřebujeme tedy něco jako "unit testy integrace".

Takové testy se dají udělat poměrně jednoduše, když máte specifikaci toho, co očekáváte, zapsanou v takové podobě, že se dá samostatně použít k validaci vybraných vzorků. To je třeba [příklad XSD][test], ale Java interfacy tímto způsobem použít nejdou, tam se nekompatibilita dá zjistit až při skutečném volání. Udělat pro ně unit testy integrace v Mavenu je o dost pracnější a přepoužitelnost vyžaduje spouštění testů z jiných modulů a tím pádem i netriviální výrobu více artefaktů v jednom modulu. Možná na to někdy zkusím udělat vzorovou ukázku, ale teď to nebude.

Testy v předchozím odstavci jsou potřeba k tomu, aby stromy kompilačních a runtime závislostí mohli být zcela oddělené a my si je mohli v projektu libovolně přeskládat nebo změnit. To je právě to, co od modularity požadujeme, jen by to bez testů kompatibility kontraktů bylo dost rizikové. Jak si ale s Java buildovacími nástroji vlastně můžeme naházet na classpath jiné složení modulů než to, které bylo použito pro kompilaci? V Mavenu to totiž nejde. Přestože má koncept scopů, ty mají trochu jinou sémantiku poplatnou jeho modelu buildování, který kompilační a runtime závislosti naopak spojuje, takže modularitě vlastně brání. To jsou nám paradoxy.

Tady nám nezbývá než nazout holiny, vyhrnout rukávy, všechny modulární závislosti označit jako provided a v projektu udržovat stínový strom compile závislostí, který budeme moci znásilnit dle libosti. Určitě to nechceme dělat pro všechno (stínový strom Spring závislostí ne e), ale pro vyzkoušení ukázkové detekce a řešení třeba [diamond problému][diamond] jich stačí pár vlastních.

Pozn. 1: Mít paralelně vedle sebe strom závislostí jednotlivých modulů a koncové binárky se může v Mavenu zdát jako hodně absurdní přístup, ale zrovna tohle je překvapivě praktický koncept. Dá se s ním řešit obvyklý problém microservice, že sice chcete [provozovat služby odděleně][microservice], ale jako vývojář chcete testovat celý systém jako [monolit][monolith].

Pozn. 2: Za povšimnutí ještě stojí, jak moc je v tomto ohledu rozdílná situace třeba Céčka, které má v buildu o jednu fázi navíc - linking objektových souborů. Vsadím se, že spousta Javistů a jiných virtuálních strojařů už dávno zapomněla, že linking nemusí být pouze dynamický. Tam se dá vymyslet věcí!

### Runtime modularita

Další level už je jen opravdová runtime modularita. Na její simulaci pomocí classloaderů už nemám, protože sám stěží chápu magii OSGi nebo [Haskelovského backpacku][backpack]. Děkuji za pozornost a přeju příjemných pár let v dalším samostudiu modularity. Otázek a myšlenkových směrů jsem k tomu v tomto článku nastínil asi dost.‎ Není divu, že [opravdová modularita je první bod ‎v seznamu námětů k dalšímu vývoji v programovacích jazycích][languages]

[verifalabs]: http://www.verifalabs.com/
[semver]: https://github.com/staltz/comver
[relisa]: http://relisa.kiv.zcu.cz/
[undecidibility]: https://en.wikipedia.org/wiki/Undecidable_problem
[api vs protokol]: http://calavera.info/v3/blog/2016/02/01/generovani-modelu-z-xsd.html
[feynman]: http://archives.caltech.edu/pictures/1.10-29.jpg
[inversion]: https://en.wikipedia.org/wiki/Dependency_inversion_principle
[datalog]: https://www.youtube.com/watch?v=R2Aa4PivG0g
[spec]: https://www.youtube.com/watch?v=oyLBGkS5ICk
[conway]: https://en.wikipedia.org/wiki/Conway's_law
[composability]: https://pchiusano.github.io/2017-01-20/why-not-haskell.html
[test]: https://github.com/calaveraInfo/hospis/blob/master/rest/lib/src/test/java/cz/cestadomu/hospis/rest/lib/model/AbstractModelTest.java
[languages]: http://graydon2.dreamwidth.org/253769.html
[diamond]: http://www.well-typed.com/blog/9/
[microservice]: https://github.com/calaveraInfo/hospis/blob/master/rest/web/pom.xml#L22
[monolith]: https://github.com/calaveraInfo/hospis/blob/master/bundle/pom.xml#L107
[backpack]: https://ghc.haskell.org/trac/ghc/wiki/Backpack
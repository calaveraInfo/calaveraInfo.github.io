---
title: Modularita 2
---

[Minule][modularita 1] se mi snad povedlo přesvědčit alespoň někoho, že modelování modularity a architektura informačních systémů vůbec řeší trochu víc než samotná algoritmizace a obecná abstrakce. Snažil jsem se tím trochu rehabilitovat myšlenku OOP jako užitečného nástroje pro vybudování příslušné intuice. Dnes se budu věnovat tomu, že jsem tím rozhodně nemyslel Javu.

## Co vlastně řeší OSGi

Musím se ostudně přiznat, že až do nedávna jsem sám nechápal smysl OSGi. Moduly a závislosti mezi nimi je přeci možné deklarovat v Mavenu a dynamické načítání částí programu je také možné realizovat pomocí pokročilé práce s classloadery, to dělají třeba servlet kontejnery odjakživa. Tak proč zcela nová technologie?

Až nedávno jsem pochopil, že jsem ve skutečnosti nikdy nepracoval s doopravdy modulární architekturou. Že přes veškerou složitost a hloubku tranzitivních závislostí v nich nemáme žádné cykly a konflikty jen takové, že se dají vyřešit jednorázově a trvale. Že vývoj modulů měl společný harmonogram a že měli jen pár téměř stejných odběratelů. ‎Jinak řečeno, že technicky sice aplikace do modulů rozdělené byly, ale prakticky žádný z problémů modularity řešit nemusely. A to bude asi častý omyl - modularita je problém esenciální, nikoli akcidentální. Dokud jej fakticky nemáte, je jakékoli technické řešení dostatečné.

Tahle idylka většinou skončí, když se někdo rozhodne využít deklarované "modularity" a ze stávajících modulů se má vytvořit jiný, podstatně odlišný produkt, při zachování toho původního. Místo očekávaného přeskládání lego kostiček nastane spíše něco jako transplantace orgánů. Několika najednou. Opakovaně.

Týmy v odpovědi na požadavky více produktů začnou navíc nové verze svých modulů chrlit ve vražedném tempu. Přes veškerou snahu plánované i neplánované breaking change prostě nastávají, už jen proto, že jak ukázaly [kontroverze okolo semver][semver], breaking change může být klidně i pouhá oprava bugu. Matematika pravděpodobnosti je pak nemilosrdná - jakkoli může být pravděpodobnost chyby u jednoho modulu malá, kombinovaná pravděpodobnost nekonzistence u desítek modulů dohromady je každodenní jistotou.

Co dělá tento problém v Javě (a nejen tam) obzvláště hořký je zdánlivě banální fakt, že tam **není systémová možnost ověřit kompatibilitu kontraktů kódu, který se v classpath (runtime) ocitl již zkompilovaný**. Jinak řečeno ‎kontrola, že jeden kus aplikace má vůbec šanci fungovat dohromady s jiným kusem aplikace, se provádí jen a pouze při kompilaci. A to je pro modularitu, která stojí na představě předkompilovaných stavebních bloků, vražedné.

Taková vlastnost eliminuje v modulární architektuře velkou část výhody explicitní definice kontraktů _per se_. Tím, že se většina byznys logiky v modulárních systémech přesune z vlastního kódu do předkompilovaných modulů, přesune se taky zjištění většiny zásadních chyb z kompilační fáze do runtime. A to je jádro příčiny nevyhnutelného řádového prodražení modulárních aplikací v Javě, o frustraci vývojářů nemluvě.

Jedna možnost je po vzoru Spec (a mnoha jiných) uvalit na rozhraní modulů omezení, která umožní tuto komplexitu mechanicky zvládat. [Celý minulý díl][modularita 1] jsem věnoval tomu, proč si tohle zjednodušení (zatím) odpustím. Jiná možnost je začít budovat od základu novou infrastrukturu typu OSGi, která problematiku metodicky podchytí bez umělých omezení, ale složitě. Nestačilo by však jen do Javy přidat tu vlastnost, která tam evidentně chybí?

## ReliSA to the rescue!

Naprostá bomba pro mě bylo zjištění, že právě tomuhle problému se zrovna v Čechách věnuje spinoff [VerifaLabs][verifalabs] z výzkumného programu [ReliSA][relisa] na Západočeské univerzitě, mojí Alma mater. A že to jsou lidé od Přemka Brady, mého dávného oponenta diplomky, se kterým jsem zůstal v občasném kontaktu, takže jsem si mohl domluvit neformální zkoušku výsledků jejich práce.

Dostali jsme k vyzkoušení alfa verzi produktu zabalenou do podoby Maven pluginu, který ve fázi "test" velmi zjednodušeně řečeno ověří každý bytekódový invoke proti skutečné bytekódové signatuře reálně přítomné na classpath. Není sice fér shrnout to nadlidské úsilí, které takový úkol vyžaduje, do tak banálního popisu, ale zájemci

Byl jsem opravdu zvědavý, jak v takové analýze obstojí náš projekt. Chyb v produkci jsme zas tolik hlášených neměli, ale během vývoje jsme jich s vydáváním nových verzí modulů museli řešit vždy požehnaně, takže byla otázka, kolik nám jich uniklo. Plugin jako výstup generoval běžný textový soubor kde zhruba jeden řádek odpovídal jedné nalezené chybě. Spustil jsem analýzu a ... a výstupní soubor měl po jejím skončení 13 MB. Uf. Po rychlé validaci jsem bohužel musel uznat, že zjištěné výsledky odpovídají realitě.

Jak je to možné? Opravdu v naší aplikaci seděly desítky tisíc chyb‎ a bylo jen otázkou času, kdy se projeví? Samozřejmě, že ne. V naprosté většině se jednalo o falešně pozitivní nálezy plynoucí z toho, že moduly měly volitelné závislosti (nebo volitelně volali nekompatibilní kód v nich), které se v naší konfiguraci nikdy nemohly dostat do reálné code path. Pomalu mi začala docházet zoufalost modularity v celé svojí hrůze.

Nejde o to, že by se s tím onen validátor nedokázal vypořádat, naopak nabízel k tomu luxusní nástroje. Ale konfigurovat je z podstaty mohl jen člověk s expertní znalostí systému, který zná konfiguraci a architekturu projektu natolik dobře, aby ty nereálné code path, kde nás kompatibilita rozhraní nezajímá, dokázal spolehlivě určit (a to jsme se [undecidibility problému][undecidibility] dotkli jen velmi zlehka). Navíc při tak obřím množství hlášení existují prakticky jen dvě možnosti:

1. Obětovat vyhodnocení analýzy velké množství času a zkoumat každé hlášení zvlášť. To je dobré řešení když se jedná o kritický systém u kterého musíme mít maximální jistotu absence runtime chyb, ale dělat to třeba u webovek asi není úplně ekonomické.
2. Použít nějakou heuristiku pro hromadné zpracování (dát na blacklist celé namespacy nebo regulární výrazy). Ale to jsme zpátky tam, kde jsme byli. Zavádíme opět prvek nejistoty, šedou zónu, jejíž velikost bude úměrná kvalitě a lenosti výše zmíněných expertů.

U obou strategií navíc platí, že to nejsou jednorázové činnosti, protože konfigurace projektu se mění a s ní i dosažitelná code path. Pochopil jsem, že v opravdové modularitě závislosti faktické (runtime) budou vždy vyžadovat zcela samostatně udržovanou konfiguraci oddělenou od závislostí organizačních (compile time). Pokud mají mít moduly vůbec nějakou flexibilitu, nelze to první beze zbytku odvodit z druhého, jak se to očekává od Mavenu. Někdo musí (ať už v jakékoli podobě - OSGi manifesty nebo konfigurace výše popsaného validačního nástroje apod.), vytyčit kontext, ve kterém chce modul provozovat, protože korektnost programu nás nesmí zajímat jinde než v reálně dosažitelné code path, kterou spoluurčují _data_ a ty v buildu prostě nemáme.

## Plot twist
A nebo máme? Teď je přesně ten čas na mé obvyklé vystřízlivění ve kterém zjistím, že problém, který se sofistikovaně snažím vyřešit celé měsíce je adresován nějakou starou, běžnou a banální praktikou, kterou nemá ani cenu zmiňovat.

Je to tak. Ve skutečnosti k modularitě nepotřebujeme frameworky, experty ani šedé zóny. Ve skutečnosti existuje možnost, jak (v rozumné míře) exaktně a mechanicky určit živé code path každého projektu a kompatibilitu kontraktů na nich a to i u již zkompilovaného kódu. Tou možností jsou: BA DUM TSSS ... testy. Asi nemusím vysvětlovat proč.

‎Aby to bylo ještě ironičtějsí, přesně tuhle strategii jsem dokonce sám rozebíral v [prvním článku na tomto blogu o tom, jak udělat flexibilnější XML služby][api vs protokol] už před více než rokem. Jen to tenkrát bylo ‎z trochu jiného pohledu a nedocházela mi obecnost toho řešení ve vztahu k modularitě.

## Závěr?

Možná teď tohle celé  vypadá jako zbytečné akademické cvičení, ale jak nám odkázal Feynman: ["What I cannot create, I do not understand"][feynman]. Tenhle závěrečný test nabitých vědomostí má v tomto případě podobu hypotetického cvičení: Jak přizpůsobit projekty v běžné Javě a Mavenu tak, aby byly doopravdy modulární? Neboli jak si po domácku napodobit vlastnosti modulární platformy? A právě tady má rozpitvání tématu až na prvočástice svůj smysl, protože ukazuje, které klíčové vlastnosti to vlastně jsou.

Já si z tohohle zamyšlení odnáším hlavně tyhle dvě:

1. Oddělit strom závislostí kompilačních a běhových. To sice Maven sémantika přímo nepodporuje, ale nic nebrání tomu, abychom si dva (do jisté míry) oddělené stromy udržovali s její pomocí sami a jejich význam určili pouze metodicky. Tenhle trik jsem poprvé použil na mém exploratorním "pet" projektu HospIS  abych zachoval možnost buildu jako [produkčních microservice][microservice] i jako‎ [vývojářského monolitu][monolith] zároveň, ale význam tohoto triku je daleko širší.
2. Když už jsou běhové a kompilační závislosti odděleny, je pak potřeba speciální třída "unit integračních" testů na ověření, jestli mezi nimi není v používané části kontraktů nekompatibilní rozdíl. To jsem si vyzkoušel v tomtéž projektu na [příkladu XSD kontraktů][test]. Pro Java kontrakty to vypadá sice trochu jinak, ale princip je stejný.

Těžko říct, jestli je tenhle závěr nějak hodnotný, objevný nebo jestli má vůbec nějakou obecnou platnost. Já jsem si ale při myšlenkovém experimentování, které k němu vedlo, [odstranil velkou spoustu magie][magie] z mých představ o modularitě.

## P.S.
Možná si někdo vzpomene, že jsem sliboval rozbor kontraktů z ekonomického pohledu. Tak jsem tuhle část původně i napsal, ale nedalo se to číst, tak jsem k výsledkům těch dedukcí vymyslel trochu jednodušší omáčku :-).

[modularita 1]: http://calavera.info/v3/blog/2017/02/26/modularita-1.html
[verifalabs]: http://www.verifalabs.com/
[semver]: https://github.com/staltz/comver
[relisa]: http://relisa.kiv.zcu.cz/
[undecidibility]: https://en.wikipedia.org/wiki/Undecidable_problem
[api vs protokol]: http://calavera.info/v3/blog/2016/02/01/generovani-modelu-z-xsd.html
[feynman]: http://archives.caltech.edu/pictures/1.10-29.jpg
---
title: Modularita 1
---

Znáte takové ty období, kdy shodou okolností všude narážíte na jedno téma?  Tak jsem okolo Vánoc všude narážel na téma modularity. Jednou jsem si dopřál luxus se nad ním pár hodin zamyslet jen s tužkou a papírem a byl to doslova a do písmene brainstorming. Zápisky z toho budou dvojdílné, protože aby to dávalo vůbec nějaký smysl, je nutné se nejdřív rozepsat o kontextu. První díl bude o paradoxu, že čím modulárnější architektura, tím menší potenciál v ní má klasický matematický přístup k algoritmizaci. Jinak řečeno to, že se trendy FP a microservice dostali do mainstreamu téměř zároveň, považuji za vrchol podivnosti.

Alfa a omega modularity jsou kontrakty mezi moduly. Obecně se kontrakty považují za hochnóblové slovo pro API, ale to je obrovské zjednodušení. Jednak proto, že API občas nestačí ani na základní funkční specifikaci a musí být doplněno [protokolem][datalog] a jednak proto, že API (spíše podvědomě než z definice) implikuje pouze jednu variantu kontraktu - jednostranný kontrakt definovaný poskytovatelem služby. To má ekonomický smysl v podobě přepoužitelnosti takové služby, tzn. sdílení nákladů.

Ekonomicky může mít ale jednostranný kontrakt i úplně jiný účel: flexibilitu. To když je kontrakt definován (vlastněn) odběratelem služby. Pak si může odběratel vybírat a měnit dodavatele (implementaci) jak se mu zachce. Podle ceny, přidané hodnoty, čehokoli. V programování se tomu říká [dependency inversion][inversion] a je to základní architektonický nástroj. Hned vysvětlím proč.

Kromě strategického výběru mezi přepoužitelností a flexibilitou je totiž možné se na tuto závislost dívat ještě z jiného pohledu - v praxi definuje, čí zájmy bude kontrakt přednostně řešit. Jestli zájem dodavatele na rozvoji jeho produktu nebo zájem odběratele na stabilitě nebo rozvoji produktu odvozeného. Tu první situaci je možné si představit třeba na příkladu, kdy telefonní operátor jednostranně zavede v obchodních podmínkách FUP. Klient může nesouhlasit, ale břímě spojené se změnou operátora leží na něm. Ta druhá situace je vidět třeba na příkladu veřejných zakázek. Vypíše se jasně definovaná zakázka a kdo dá za daných podmínek lepší cenu, vyhrál.

Právě tenhle netechnický význam kontraktu je jedno z klíčových nedorozumění mezi počítačovou vědou a praktikujícími architekty. Matematiku nezajímá, jaké podpůrné lešení je potřeba postavit k výrobě algoritmu samotného, ani kdo z něj bude mít prospěch či újmu. V praxi ale kraluje [Conwayův zákon][conway] a struktura software a struktura organizace, která jej vytváří, je neoddělitelně spojena a na ekonomickém významu kontraktů mezi jednotlivými částmi proto sakra záleží. Pro toho, kdo má zajistit, že se projekt nezhroutí vlastní organizační vahou, má teorie her a kontraktů stejný význam jako lambda kalkulus nebo turingův stroj.

OOP a tooling okolo něj pak začne dávat trochu smysl. Napodobování komunikačních schémat objektů reálného světa může být z matematického pohledu extrémně nevhodný nástroj algoritmizace, ale na druhou stranu je v něm modelování ekonomických vztahů first class citizen a to v celé jejich šíři.

Že to má velký význam nevědomky ilustruje třeba [přednáška Riche Hickeyho o tomto tématu v souvislosti se Spec][spec]. Všimněte si na ní, že definice slov Accretion a Breakage, na kterých všechny jeho úvahy stojí, vychází z implicitní představy kontraktu na straně dodavatele. V opačném scénáři, kontrakt definovaný odběratelem, by však tyto slova měli přesně opačný význam a veškerá jednoduchost by byla rázem v tahu. Tohle ale nemůže být výčitka, protože takový scénář nemá žádnou oporu v základním výpočetním modelu, díky kterému je jinak Clojure tak skvělý jazyk.

Zcela chápu právoplatné rozhořčení nad myšlenkou, že by se kvůli zatažení "ekonomické politiky" do vývoje měly obětovat plody matematiky za poslední půlstoletí, ale právě tady vstupuje do hry modularita, protože:

1. [Composability is destroyed at the IO boundaries in any language][composability]. Čím více oddělených modulů, tím více IO boundaries kde se bude projevovat Conwayův zákon a vůbec nezáleží na tom, jestli jsou ty hranice modulů externí nebo interní. Čistě matematický přístup se pak umonáduje a ztrácí dost ze svého smyslu.
2. Teorie kontraktů není žádné šarlatánství. Minulý rok byla právě za ní udělena Nobelova cena za ekonomii, je to rigidní věda jako každá jiná, včetně matematických modelů a podobných atributů. Jenom si na rozdíl od lambda kalkulu nemůže zjednodušit práci immutabilitou a podobně, protože lidské vztahy prostě immutabilní nejsou.

Jakkoli to tedy zní strašidelně, možná by stálo za to zkusit cíleně najít hlubší paralely mezi programováním a ekonomií a zjistit, jestli si z toho oboru nemůžeme vzít víc, než těch pár mlhavých představ rozepsaných výše. A tak začalo moje hledání svatého grálu modularity. Do příštího dílu nebudu napínat: žádný není. Ale cesta za ním je, jako v pohádce, důležitější než existence samotná.

[inversion]: https://en.wikipedia.org/wiki/Dependency_inversion_principle
[datalog]: https://www.youtube.com/watch?v=R2Aa4PivG0g
[spec]: https://www.youtube.com/watch?v=oyLBGkS5ICk
[conway]: https://en.wikipedia.org/wiki/Conway's_law
[composability]: https://pchiusano.github.io/2017-01-20/why-not-haskell.html

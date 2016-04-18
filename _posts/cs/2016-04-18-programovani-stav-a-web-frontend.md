---
title:  "Programování, stav a web frontend"
lang: cs
layout: post
---

Už mě nebaví diskuze o [frontendových architekturách][Fowler: Frontend architectures]. I od základního MVC existuje nekonečné množství variant a specializací, které se liší nuancemi v tom, odkud kam vedou jakým stylem malované šipky. Diskuze o tom končí na argumentech typu kam co "patří", kde je co "přehlednější", v čem je "nejmíň duplicity" a dalších subjektivních pocitech jejichž reálný dopad je přinejmenším diskutabilní.

V některých architekturách se ale vyskytuje jeden aspekt o kterém bych tady chtěl psát, protože z mé zkušenosti praktický význam má a to zásadní. Je to možnost definovat [model stavu view][Fowler: Presentation model] nezávisle na view frameworku a který je [normalizovaný][Database normalization] podle analytické abstrakce dané stránky. Celé view pak může být jen pure funkcí takového stavu, což ve světě JavaScriptu skvěle zpopularizoval [React][React], ale do server side frameworků [tento trend][Fowler: Passive view] moc nepronikl.

Server side frameworky, zvlášť ty z objektově orientovaných jazyků, jdou cestou s úplně opačným výsledkem.  Jsou většinou založeny na konceptu stavových komponent. To svádí k tomu, že celkový stav stránky je rozdrobený mezi jednotlivé komponenty a strukturou kopíruje vzhled UI místo analytické abstrakce stránky nebo use case. Navíc je takhle strukturovaný stav většinou hodně denormalizovaný.

Zatím to vypadá jako stejné plané teoretizování, o kterém jsem říkal, že ho nemám rád, takže už radši přejdu k praktické ukázce důsledků. Začnu s typickým lakmusovým papírkem dobré architektury - testy.

## Musí být testování webového frontendu složité?

Většina webových frontendových aplikací se musí testovat molochy typu Selenium. Proč?  Jednoduše proto, že view komponenty většinou nedokážou existovat mimo svůj standardní kontext serveru, prohlížeče atd. a zároveň jsou jako držitelé stavu nedílnou součástí byznys logiky.

I když se povede pomocí nějaké černé magie typu [Arquillian][Arquillian] provozovat komponenty v rámci unit testovacího frameworku, je potřeba se ke stavu komponent většinou dostat hledáním v komponentovém stromu, což je každou chvíli rozbité, protože to většinou závisí na vizuální podobě a/nebo textových identifikátorech.

A jestli jste to ještě nevzdali, je tu ten největší problém: co vlastně v testech assertovat? I základní komponenta má několik stavových atributů (visible, enabled, value...) a typická stránka má mnoho základních komponent. Stavový prostor takového view je prakticky nekonečný a integritu v něm neuhlídá ani pánbůh.

Často si architekti tento problém nepřipouští, protože si představují, že stránka se "jen" skládá z komplexních komponent, které představují hermeticky uzavřený celek testovatelný samostatně. To je v praxi utopie přímo z definice - komponenta jakékoli velikosti musí být otevřená mnoha různým scénářům použití, jinak by reálně nebyla přepoužitelná, což vynucuje kontrolu vnitřního stavu komponenty v každém konkrétním scénáři zvlášť. Stránka složená z komponent je vždy mnohem víc, než pouhý součet svých částí!

Abych to uzavřel: hodně lidí tomu asi nebude věřit, ale i frontend se dá automaticky testovat i bez Selenia, pokud má dobrou architekturu (opravdu jsem zažil celou web aplikaci naostro spuštěnou jen v JUnit). Jeden z klíčových prvků, který to umožňuje, je klasický příklad [základního architekturního úkonu inverze závislostí][Uncle Bob: Little architecture]: stav view nesmí být závislý na použité view technologii, ale naopak ‎view musí být závislé na byznysovém modelu svého stavu.

## Jak pomůže model stavu?

Na příkladu testů se ukazuje důsledek denormalizovaného stavu v tom, že vlastně není jasné, jak ověřit testovanou skutečnost. Příklad: splnění byznys požadavku "formulář bude za nějakých podmínek read only" musí být kontrolováno tak, že se projdou všechny prvky daného formuláře a ověří se, že jsou ve stavu disabled. Jedna jednoduchá informace se bude složitě ověřovat na mnoha místech. Z těchto míst  ale zároveň žádné nemá autoritativní postavení vůči ostatním. Pokud po nějaké sekvenci událostí jedna z komponent nebude disabled, co to znamená? Že je v programu chyba, nebo že naopak program správně pamatuje na jiný byznys požadavek, který také manipuluje s tímto atributem?

To je otázka, která není zásadní jen v testech, ale obecně pro celý quality assurance proces a údržbovou fázi života software. To, co model stavu dovoluje, je explicitně a deklarativně vyjmenovat skutečnosti ze zadání a vybrat tím z nekonečného stavového prostoru vizuální reprezentace většinou překvapivě malou množinu atomických faktů. To je klíčové pro analytiky, architekty i programátory a komunikaci mezi nimi podobně jako například rozhraní služeb.

## Další důsledky

Dál už to takhle podrobně rozebírat nebudu, ale podobně zásadní dopad má existence modelu stavu view na několik dalších oblastí:

* Debugging/Logging‎: když je stav na jednom místě, je jednoduché jej vypisovat při každé události, výjimce atd. Když je v logu kompletní a normalizovaný (takže čitelný) stav aplikace v každém důležitém okamžiku, je jednoduché hledat chyby i‎ bez přímého přístupu k danému prostředí a/nebo post mortem.
* Jak jsem nedávno psal: <blockquote class="twitter-tweet" data-lang="cs"><p lang="en" dir="ltr">Every sufficiently large web application contains a poorly-specified, bug-ridden implementation of half of Web Flow <a href="https://t.co/1v6bBKbI4U">https://t.co/1v6bBKbI4U</a></p>&mdash; František Řezáč (@calaverainfo) <a href="https://twitter.com/calaverainfo/status/712981101397016576">24. března 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>. Problém je, že hranice odpovědnosti mezi abstrakcí stavového automatu pro přechod mezi stránkami a komponentového modelu jedné stránky je velmi neurčitá a zároveň je zasahování jedné abstrakce do druhé technicky většinou náročné. Použití modelu stavu view jako neutrálního prostředku spolupráce je elegantní řešení tohoto problému.

## Závěr

Model stavu view není sám o sobě kompletní předpis architektury, ale spíše obecný aspekt, který je možné realizovat napříč různými kombinacemi architektur a technologií. Problém ale je, že všechny ty abstraktní myšlenky nakonec znamenají v kódu pro každého něco úplně jiného. Tak jsem třeba zažil to, že stavem aplikace se myslela jen data, která zadal uživatel. ‎Nebo se udělá pár výjimek z technických důvodů, např. data v dynamických grafech se načítají přímo ze služby místo z modelu. ‎Někdy jde o pár drobností, jindy to vypadá jako dort od Čapkova pejska a kočičky.

Reálné projekty z mnoha důvodů nějaké kompromisy dělat musí. Jak ale hodnotit kompromisy v tak abstraktní věci, jako je architektura a nezapadnout do svatých válek? Právě kvůli tomu je potřeba mít jasně definované praktické důsledky, které od volby architektury a technologie očekáváme. Ty nejdůležitější jsem zde vypsal.

Pro ty, kdo hledají jednoduché poučky: používejte architekturu MVVM, protože okolo modelu stavu view staví kompletní architekturu a její doslovnost nedovoluje příliš mnoho "kreativních" odchylek.

Pro ty, kdo hledají hlubší pochopení: Nic v článku není nijak objevné. Staří mazáci dobře vědí, že stav je asi jediná opravdu těžká věc na programování a většina inženýrských konstrukcí se nějak týká jeho zkrocení (immutabilita, monády atd.). Centralizovat aplikační stav a všechno ostatní postavit okolo něj je z tohoto pohledu vlastně nejzákladnější opatření pro jakýkoli druh aplikace a je obecně platné napříč architekturami i programovacími paradigmaty (odkaz Elm architektura).

[Fowler: Frontend architectures]: http://martinfowler.com/eaaDev/uiArchs.html
[Fowler: Presentation model]: http://martinfowler.com/eaaDev/PresentationModel.html
[Fowler: Passive view]: http://martinfowler.com/eaaDev/PassiveScreen.html
[Database normalization]: https://en.wikipedia.org/wiki/Database_normalization
[React]: https://facebook.github.io/react/
[Arquillian]: http://arquillian.org/
[Uncle Bob: Little architecture]: http://blog.cleancoder.com/uncle-bob/2016/01/04/ALittleArchitecture.html

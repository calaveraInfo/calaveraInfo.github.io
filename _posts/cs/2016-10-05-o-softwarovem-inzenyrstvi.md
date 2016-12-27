---
title: O softwarovém inženýrství
---

Mám ho! Mám tagline pro svůj blog! Od chvíle kdy jsem na GeoCities umístil v rámci prvních pokusů s HTML svojí sebeprezentaci jsem jej zoufale hledal. Zatímco ostatní používali vtipné slovní hříčky, citáty slavných nebo oduševnělá moudra. Já cítil, že to musí být něco hlubšího. To místo v nadpisu stránky si přece zaslouží něco zásadního, nejlépe obecný destilát smyslu života a osobní  životní misi v jednom. Bohužel najít dnes myšlenku s takovými parametry a ještě k tomu originální je jako kupovat značkové tepláky ve vietnamské tržnici. Přestože mi formuláře profilů na sociálních sítích trýznivě připomínaly neukojenou potřebu sebeurčení, zůstávaly prázdné. Až doteď.

To je on: Abstrakce, kontrakty, závislosti.

Proč? Protože chci vykřičet do světa, že vyrábět software je triviálně jednoduché. A jak je možné, že se to přesto [všechno pořád tak sere][fails]? Protože je zoufale málo těch, kteří v každodenním zahlcení blbostmi dokážou ty jednoduché principy vidět.

Už jsem se to naučil skrývat, ale všechno ve mně přímo řve, kdykoli jsem u ohnivé debaty který jazyk je expresivnější, které IDE je víc integrovanější, který build nástroj rychlejší, která architektura škálovatelnější, která metodika produktivnější. Kdykoli někdo argumentuje KISS [nebo][dry] [DRY][abstraction tweet] [principem][repeat tweet] nebo jiným klenotem lidové vývojářské moudrosti. Kdykoli někdo prezentuje novou technologii jako silver bullet aniž by vůbec dokázal vyjmenovat [esenciální problémy][silver] softwaru popsané ve stejnojmenné eseji, platné dnes do puntíku stejně, jako když byly formulovány před skoro čtyřiceti lety.

Stále dokola vidím to naivní očekávání, že nějaký problém inherentně přítomný v zadání (ať už přímo nebo nepřímo) bude nějak podstatně menší po aplikaci nějaké technologie. Je to cargo kult, který kupí technologie v naději, že přiláká magické zjednodušení řešených problémů. Ale jakýkoli software je ve své podstatě jen nehmotná myšlenka a jako takovou dokáže zkrotit její složitost jediný nástroj - abstrakce. Technologie jsou pouze jejich prostředníkem a sami o sobě nic negarantují. Zvlášť když se je snaží používat lidi, kteří o potřebě zjednodušovat problémy skrz abstrakce ani nevědí (to je pro mě definice pejorativního slova kodér).

Stále dokola se též objevuje myšlenka, že pro větší flexibilitu produktu i vývoje je potřeba méně fixních plánů. Zvlášť v záplavě nepochopení agilních metodik nabývá tenhle trend obludných rozměrů. Jako kdybychom pro větší odolnost budov vůči zemětřesení použili na jejich nosné zdi želé. Ale umění ‎absorbovat změnu nespočívá ve zrušení pevných bodů konstrukce, ale v jejich designu tak, aby dovolily veškerou možnou dynamiku, ale právě a jen v takových mezích, ve kterých dokážou garantovat svojí strategickou úlohu. To je umění designu kontraktů. Co určuje ony meze a úlohy, které musí kontrakty v celkové konstrukci plnit? Abstrakce.

A třetí slovo. Definicí softwarové architektury je pro mě [Fowlerovo "Architektura je to, co je důležité. Důležité je to, co nejde jednoduše změnit."][fowler] Z hlediska praxe se dá odvodit ještě jeden fakt: "jednoduše nejde změnit to, na čem něco jiného závisí." Proto je pro mě softwarová architektura v praxi synonymem pro management závislostí - některé typy závislostí mají větší flexibilitu než jiné, některé se dají eliminovat, některé se dají invertovat atd. Ne technologické vizionářství, ale tohle má tvořit hlavní náplň práce architekta. A co je jeho prostředek ke sledování a manipulaci se závislostmi? Kontrakty.

Je to práce ve své podstatě tak banální, že vlastně nikdo necítí potřebu jí vůbec dělat. Bez důsledného řízení závislostí se ale jejich [složitost v průběhu vývoje přirozeně zvyšuje a následky jsou stejné, jako u složitosti algoritmické][dependency hell] - existuje mez, od které ani všechny zdroje světa nestačí ani k malému navýšení zpracovávaného rozsahu. V algoritmech jsou rozsahem myšleny data, v architektuře byznys požadavky. Když se taková složitost závislostí objeví v kódu, říká se tomu špagety a je to zralé na kompletní přepis. To možná bolí, ale dá se to přežít. Když se to stane na úrovni velkých multikomponentových systémů, je to asi jediný technický důvod, který dokáže zabít celé projekty a dokonce i firmy.

Jestli si má výroba softwaru udržet [inženýrský status][atlantic], nesmí se to stávat. Aby se to nestávalo, je podle mě potřeba znát význam a spojitost právě těchto termínů a umět je převádět v technickou realitu. Je to můj osobní výběr esence softwarového inženýrství, nedokážu z toho výběru nic odebrat ani k němu nic přidat aniž by přestal být esenciální. Mrzí mě, že to tolik lidí považuje za akademické bláboly. Ještě víc mě překvapilo, že když jsem to zkusil vygooglovat (i v různých variantách), nenašel jsem nic kloudného. Jako kdyby to v téhle spojitosti nikdo jiný neviděl.

A pak mi to došlo, že to je on, to je můj tagline.

[dependency hell]: https://research.swtch.com/version-sat
[fails]: http://spectrum.ieee.org/static/the-staggering-impact-of-it-systems-gone-wrong
[dry]: http://thereignn.ghost.io/on-dry-and-the-cost-of-wrongful-abstractions/
[abstraction tweet]: https://twitter.com/jessitron/status/619941474902351872
[repeat tweet]: https://twitter.com/jezenthomas/status/776096875648847872
[silver]: http://worrydream.com/refs/Brooks-NoSilverBullet.pdf
[fowler]: http://martinfowler.com/ieeeSoftware/whoNeedsArchitect.pdf
[atlantic]: http://www.theatlantic.com/technology/archive/2015/11/programmers-should-not-call-themselves-engineers/414271/

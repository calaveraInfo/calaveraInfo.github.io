---
title:  "Generování modelu z XSD"
---

Nedávné řešení problémů s m2e (adaptace Mavenu pro Eclipse) mě přivedlo k tématu, které je v profesionální Javě prakticky dogmatické a už se o něm ani moc nepřemýšlí - generování Java tříd z XSD. Termín "contract first" už prakticky splynul s tímto úkonem a nikoho už nenapadne, že by to mohlo být i úplně jinak.

Při volání externích služeb máme v principu pouze dvě možnosti - [platfomně závislé API a nebo neutrální protokol][1]. Oba principy mají své výhody i nevýhody a proto může být v některých případech dobré přidat do aplikace vrstvu převádějící jeden princip na druhý. To je právě případ XSD, které definuje protokol, ale vygenerováním‎ Java modelu se jej snažíme převést na API.

Má to ale háček. V normálním případě, kdy je API dodáváno poskytovatelem služby, je jeho hlavní výhoda v tom, že může syntakticky i sémanticky vést ke správnému pochopení a používání služby. Generované API ale k informacím obsaženým v protokolu už žádné další přidat nemůže. To začíná být důvod k zamyšlení.

Ve skutečnosti je jediný efekt vygenerování Java tříd v tom, že pravidla z XSD převedeme do Java kódu, takže je místo XML validátoru kontroluje kompilátor. Kdyby to bylo zadarmo, tak proč ne, ale ono není.

První problém, kterým platíme, je rozdíl ve vyjadřovacích schopnostech rozdílných zápisů, které vedou k diskrepanci tak dobře známé třeba z JPA vs SQL. Naše datové modely si pro zachování zdravého rozumu budou muset vystačit s minimalistickým‎ průnikem množin vlastností dokumentového (XSD) a objektového (Java) přístupu.

Druhý, a podle mě závažnější problém, není na první pohled vidět. Jelikož soulad s protokolem kontroluje kompilátor, jakákoli změna u poskytovatele služby vyžaduje rekompilaci klienta služby i když se ho změna vůbec nemusela dotknout. Místo toho, aby protokol definoval minimální sadu pravidel, která zajistí oboustranou otevřenou kompatibilitu, máme uzavřené API, které musí vždy odpovídat 1:1 s rozhraním služby, protože jinak nejsme schopni garantovat kompatibilitu vůbec.

Ve většině mých štací to vedlo, ať už cíleně nebo jen tak samovolně, k vytvoření samostatné "mapovací vrstvy", která drobnější změny v protokolu odstíní od modelu servisní vrstvy nebo naopak. Ultimátní paradox je, že kromě toho, že to je buď zabugovaný samodomo bastl nebo nějaké [Dozer][dozer] monstrum, tak je to právě jen duplikace funkčnosti JAXB mapování! Na konci tedy skončíme s jednou vrstvou, frameworkem a konfigurací navíc a nedostaneme za to vůbec nic.

Netolerantnost ke změně v rozhraní je právě to, co typovému přístupu (právoplatně) vyčítají zastánci hippie přístupu s REST a JSON. Přitom je to vlastnost, kterou jsme si k webovým službám přidali sami, původní přístup je jednoduchý: místo generování kódu používat vlastní doménový model, mapování dodat ručně pomocí anotací (nebo složitějším nástrojem), a soulad s protokolem kontrolovat na reálných příkladech v rámci testů. Nejen že se závislost na rozhraní služby přesune z kompilační fáze do testovací (čímž se mimo jiné zbavíme mého původního problému [MDEP-187][2]), ale hlavně nám nepodstatné změny nebudou zasahovat do kódu.

Ve skutečnosti tedy web služby založené na XML nejen že mohou být stejně flexibilní jako REST+JSON alternativa, ale zároveň mohou vytěžit i vlastnosti silně typových dat, což vynalézači kola jako Apiary nebo Blueprint teprve horko těžko dohání, navíc na komerční úrovni. Vzdáváme se toho výměnou za iluzi, že není třeba opouštět Javu a ono se to nějak zařídí. Stojí to za to?

[1]: http://c2.com/cgi/wiki?ApiVsProtocol
[2]: https://issues.apache.org/jira/browse/MDEP-187
[3]: http://dozer.sourceforge.net/

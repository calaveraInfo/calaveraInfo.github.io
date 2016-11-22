---
title:  "Objektové vs. funkcionální programování"
---

V poslední době se čím dál tím víc mluví o nástupu funkcionálního programování a jeho nadřazenosti nad objektovým. Že to slyším od testosteronem nadopovaných mladíků hledajících způsob vyjádření dominance je naprosto v pořádku, byl jsem jedním z nich, ale že to začínám slýchat i od [seniorních][Mature engineer] inženýrů mě trošku děsí. ‎Proto bych chtěl k téhle debatě přidat pár střízlivých faktů.

1. Funkcionální (FP) a objektové (OOP) programování nejsou vzájemně soupeřící koncepty, ale naopak z větší části úplně mimoběžné. Centrální myšlenka objektového programování není ani tak dědičnost a další pilíře z kurzů "Naučte se OOP za 21 dní", ale [messaging][Kay: Messaging]. Většina lidí si na to dělá bohužel názor skrze Javu a spol., kde messaging zdegeneroval do podoby volání metod, o tom ale později.

2. Messaging a spol. neměl ulehčit práci programátorům v psaní algoritmů, ale [architektům v designu systémů][Uncle Bob: Little architecture]. Mimo jiné tím, že v kódu katalyzuje principy high cohesion a loose coupling, což vyústí v [komoditizaci jednotlivých částí software, to bude srážet cenu vývoje o celé řády a způsobí tím revoluci v softwaru][Brooks: Silver bullet]. Jestli vám to nepřipomíná Javu, ale problematiku dnešních web API a různých PaaS, chápete správně. Dnes to vypadá, jak kdyby FP přišlo vyřešit nedostatky zastaralého OOP, ale před 40 lety to bylo jaksi naopak.

    [Boolean as a service][booleans.io] je možná myšlený jako vtip o módě microservice (který se šeredně vymknul kontrole a místo vtipu se stal módou), ale ve své podstatě je esencí OOP. Já osobně si tipuju, že až tohle někomu dojde, "vynalezne" celé OOP v kontextu web platforem znovu.

3. Kritika OOP nemíří často přímo na jeho vlastnosti, ale skrz něj na vlastnosti imperativního programování jako takového. A to je jádro pudla - tyto kategorie nejde hodnotit jako lepší a horší, mají jen rozdílné vlastnosti. Imperativní programování je poplatné tomu, že pomocí něj ovládáme fyzický stroj, zatímco funkcionální je poplatné tomu, že pomocí něj chceme vyjadřovat myšlenku.

    Vývojáři většiny softwaru samozřejmě potřebují hlavně formulovat myšlenky a jak je bude stroj vykonávat je jim jedno, takže logicky preferují FP. Má to však i stinnou stránku. Například nejenže je [nemožné v lambda kalkulu určit teoretickou výpočetní náročnost][SO: lambda calculus], ale i prakticky má FP inherentní výkonostní problém.

    Často se argumentuje, že to je [jen otázka správných algoritmů a datových struktur][HAMT], ale pravda je taková, že [FP z principu porušuje snad všechny předpoklady, které usnadňují hardwaru běh programu][FP is bullshit] a výsledkem jsou řádové (jakože 3 a víc řádů) rozdíly ve výkonnosti.‎ Tyto rozdíly jsou dokonce tak velké, že v mnoha případech nejsou ani teoreticky kompenzovatelné paralelizovatelností, kterou FP umožňuje, protože její přínosy jsou omezené Ahmdalovým zákonem! Tohle hezky ilustruje, že každá vlastnost má pozitivní i negativní význam, záleží jen a pouze na konkrétních podmínkách a cílech, proto: 

4. Dobrý inženýr musí umět oboje dobře. Přístup chytré horákyně - vzít si z obojího jen to nejlepší - [je stejná blbost, jako vždycky][Strange Loop].

5. I samotná Java, jakkoli mnoha lidem zprzní pohled na OOP, se nestala fackovacím panákem úplně zaslouženě. Technická excelence a masové rozšíření se vzájemně vylučují. Sice jsem četl už mnoho obhajob toho, že lambda kalkulus je vlastně přirozenější způsob zápisu algoritmů, ale ruku na srdce - zkuste si představit, jak vysvětlujete [Yoneda lemmu][Yoneda lemma] průměrnému kodérovi. I Haskel komunita razí slogan "avoid success at all cost", protože moc dobře ví, že z těchto dvou kvalit si může vybrat jen jednu.

    Java (stejně jako dnes JavaScript) cílí na masové rozšíření, chce se stát stabilním základem významné části celého průmyslu. Taková technologie se vyrobit nedá, [musí se nechat vyrůst společně s lidmi, kteří jí používají][Growing a language] a proto bude stejně nedokonalá jako oni, od začátku až do konce. Porovnávat to s ideálním stavem je stejně nesmyslné jako třeba v politice.

Nejsem starý morous a myšlenkovou elegancí FP jsem naprosto uchvácen už dlouho, ale mám taky čím dál tím vzácnější schopnost přízemní sebereflexe. Technologický evangelismus může být stejně destruktivní a iracionální, jako ten náboženský:

<iframe width="560" height="315" src="https://www.youtube.com/embed/3wyd6J3yjcs" frameborder="0" allowfullscreen></iframe>

[Mature engineer]: http://www.kitchensoap.com/2012/10/25/on-being-a-senior-engineer/
[Kay: Messaging]: http://c2.com/cgi/wiki?AlanKayOnMessaging
[Uncle Bob: Little architecture]: http://blog.cleancoder.com/uncle-bob/2016/01/04/ALittleArchitecture.html
[Brooks: Silver bullet]: http://worrydream.com/refs/Brooks-NoSilverBullet.pdf
[booleans.io]: https://booleans.io/
[SO: lambda calculus]: http://cstheory.stackexchange.com/questions/23798/p-and-np-classes-explanation-through-lambda-calculus
[HAMT]: http://www.cambridge.org/cz/academic/subjects/computer-science/programming-languages-and-applied-logic/purely-functional-data-structures
[FP is bullshit]: http://funkcionalne.cz/2015/09/grim-hardware-realities-of-functional-programming/
[Strange Loop]: https://www.youtube.com/watch?v=449j7oKQVkc
[Growing a language]: https://www.youtube.com/watch?v=_ahvzDzKdB0
[Yoneda lemma]: https://en.wikipedia.org/wiki/Yoneda_lemma

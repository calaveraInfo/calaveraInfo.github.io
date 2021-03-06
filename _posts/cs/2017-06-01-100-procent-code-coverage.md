---
title: 100% code coverage
---

V poslední době jsem četl hodně článků lametujících na vynucování vysoké code coverage. I když s tím v zásadě souhlasím, nebyl bych to já, aby mě to nevyprovokovalo k protiargumentaci. Jeden aspekt vysoké code coverage se mi totiž strašně líbí.

Nejdřív bych měl ale upozornit na způsob, jakým vysoké code coverage v praxi dosahuji, protože to nejsou unit testy. Unit testovat gettery a settery je opravdu blbost. Můj oblíbený trik je ale [měřit code coverage i v integračních testech][sonar], přičemž tím myslím Maven fázi "integration-tests", kde se snažím (pokud to je smysluplné) spustit celou aplikaci dohromady v sandbox prostředí a testovat ji‎ end to end. Zadáním uživatelského nebo jiného vstupu na začátku a kontrolou volání externích služeb nebo databáze na konci.

Code coverage v takovýchto integračních testech má tu sympatickou vlastnost, že na základě jednoduchého test scénáře většinou pokryje všechny ty nudné části typu getterů a setterů a jiného přelévání dat na různých mezivrstvách architektury. ‎A to je onen důležitý detail, kterého jsem si při vysokém pokrytí všimnul. Kód, který po takovém testování zůstane nepokrytý je v naprosté většině případů indikací nedostatku v testovacích scénářích. Dokonce i‎ takový nepokrytý setter na databázové entitě pak neinterpretujete jako otravné hnidopižství, ale jako indikaci, že testovací data vašich integračních scénářů nejsou dostatečně reprezentativní.

Jinak řečeno code coverage v integračních testech na rozdíl od unit testů daleko efektivněji splňuje svojí základní úlohu - testování testů. Při zavádění testů se každý ohání tím, že jen projekt s testy je možné efektivně udržovat a rozvíjet, protože lidé pak nemají strach něco významně měnit. Málokdo už ale přizná to, že v praxi tenhle strach trvá i když má projekt testy a to z jednoduchého důvodu, že nikdo přesně neví, co ty testy vlastně pokrývají.

Tenhle problém samozřejmě teoreticky nemáte, pokud rigidně dodržujete TDD, ale ruku na srdce - opravdu jste někdy neudělali hotfix bez předem připraveného testu? Ani vaši kolegové? A co refaktoring, který nezměnil funkčnost, ale vytvořil jiné code path - ‎pokrývají je původní testy? Opravdu si lajznete ten refaktoring kódu který se volá z dalších deseti míst, která jste nikdy neviděli? Už cítíte ten ochromující efekt nejistoty?

Na Sonar, kde půlka tříd (DTO a spol) nemá ani řádku pokrytou testy, se nikomu dívat nechce. Jak by tam mezi těmi horami kódu mohl někdo najít nějaký relevantní kousek. Proti tomu na Sonar, kde všechny mezery v testech hned vyskočí navrch seznamu na dashboardu se každý podívá rád, zvlášť když je u každého bloku většinou jasné, jakou slabinu indikuje. Stejně jako na dobře nakonfigurovanou statickou analýzu. Nedělejte z pokrytí kódu testy buzeraci udělejte z ní služebníka a lidi se přestanou hádat, jestli to má smysl. Je to trochu složitější [nakonfigurovat][konfigurace], zvlášť v [multimodulovém projektu][merge], ale stojí to za to.

[sonar]: https://blog.sonarsource.com/measure-coverage-by-integration-tests-with-sonar-updated/
[konfigurace]: https://docs.sonarqube.org/display/PLUG/Code+Coverage+by+Integration+Tests+for+Java+Project
[merge]: http://www.eclemma.org/jacoco/trunk/doc/merge-mojo.html
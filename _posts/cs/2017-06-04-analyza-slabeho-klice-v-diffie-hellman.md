---
title: Analýza slabého klíče v Diffie Hellman začátku SSL
---

Pár poznámek z řešení nedávného problému. Používejte jen na vlastní nebezpečí.

## Symptom
Hláška prohlížeče: Při spojení s host:port nastala chyba. Při komunikaci protokolem SSL byl v inicializační zprávě typu Server Key Exchange obdržen slabý klíč typu Diffie-Hellman. Kód chyby: SSL_ERROR_WEAK_SERVER_EPHEMERAL_DH_KEY

## [Důvod](https://weakdh.org/)
Krátké DH se dají napadnout pomocí Logjam útoku, proto jsou ve většině nástrojů zakázány nebo deprecated.

## Diagnóza
openssl detekuje slabou DH touto hláškou:

    openssl s_client -connect host:port -cipher "EDH"

>     140284808136336:error:14082174:SSL routines:SSL3_CHECK_CERT_AND_ALGORITHM:dh key too small:s3_clnt.c:3435:

Explicitně [vypíše openssl sílu DH jen někdy](https://unix.stackexchange.com/questions/333877/how-to-find-which-key-exactly-dh-key-too-small-openssl-error-is-about):

> s_client displays Server Temp Key info only on successful handshake (and only in version 1.0.2 up

Pak by to [mělo jít vypsat takhle](https://stackoverflow.com/questions/36353025/java-jvm-hotspot-ephemeraldhkeysize):

    openssl s_client -connect host:port -cipher "EDH" 2>/dev/null | grep -ie "Server .* key"

>     Server Temp Key: DH, 1024 bits

Konkrétní hodnotu je možné zjistit jen [ruční analýzou zpráv](https://superuser.com/questions/905557/openssl-display-dh-parameters):

    openssl s_client -msg -connect host:port

>     <<< TLS 1.0 Handshake [length 022c], ServerKeyExchange
>         0c 00 02 28 00 60 e9 e6 42 59 9d 35 5f 37 c9 7f
>         fd 35 67 12 0b 8e 25 c9 cd 43 e9 27 b3 a9 67 0f
>         be c5 d8 90 14 19 22 d2 c3 b3 ad 24 80 09 37 99
>         86 9d 1e 84 6a ab 49 fa b0 ad 26 d2 ce 6a 22 21

- Kde `0c 00 02 28` je kód zprávy ServerKeyExchange 0c s délkou 00 02 28.
- Následující dva bajty `00 60` jsou délka modulu DH. Měla by to být hodnota alespoň `01 00`, tedy 256 bytů, tzn. modulus má 2041 - 2048 bitů.

Ještě delší rozbor je [zde](https://stackoverflow.com/questions/31820170/trouble-viewing-diffie-hellman-parameters-p-g-y-in-tls-exchange)

## Java

Defaultní velikost DH byla zvýšena na 2048 až v [Java SE 6u105](http://docs.oracle.com/javase/6/docs/technotes/guides/security/SunProviders.html#dhkeysizenote) i když s [délkou DH se hýbalo už asi i dřív](http://www.oracle.com/us/technologies/java/overview-156328.html) a proto je pro dřívější verze potřeba to udělat [ručně](https://www.java.com/en/configure_crypto.html#DHAKeySize).

    vim jdk1.6.0_75/jre/lib/security/java.security

>     -jdk.tls.disabledAlgorithms=...
>     +jdk.tls.disabledAlgorithms=..., DH keySize < 2048

V Java 8 je možné zadat délku DH jako [systémový parametr](https://stackoverflow.com/questions/24502672/how-to-expand-dh-key-size-to-2048-in-java-8) `-Djdk.tls.ephemeralDHKeySize=2048`, více popsáno [zde](http://docs.oracle.com/javase/8/docs/technotes/guides/security/jsse/JSSERefGuide.html#customizing_dh_keys).

## Aplikační server

Servlet kontejner (konkrétně Tomcat a odvozeniny) může opravu v konfiguraci Java ignorovat z různých důvodů:

- Je použitý nativní APR konektor, pak se použije systémové OpenSSL nastavení + konfigurace konektoru
- Verze Javy nebo JCE nepodporuje příslušné konfigurační direktivy nebo šifry

Je pak nutné opravovat SSL přímo v [nastavení konektoru aplikačního serveru](https://wiki.jasig.org/display/CASUM/HOWTO+Configure+JBoss+for+HTTPS):

    vim /.../jboss/server/default/deploy/jbossweb.sar/server.xml

Nejspolehlivější je [úplně vypustit z povolených šifer DH bez eliptických křivek](https://serverfault.com/questions/721489/how-to-make-jboss-5-1-0-ga-meet-diffie-hellman-standards) (s EC je dostatečně bezpečný menší klíč).
Toto může sice pro starší prohlížeče vypnout forward secrecy, ale aplikace bude alespoň fungovat.

>     <Connector protocol="HTTP/1.1" SSLEnabled="true"
>     port="443" address="${jboss.bind.address}" scheme="https" secure="true" clientAuth="false"
>     keystoreFile=".../keystore.jks"
>     keystorePass="..." sslEnabledProtocols="TLSv1,TLSv1.1,TLSv1.2"
>     ciphers="TLS_ECDHE..." />
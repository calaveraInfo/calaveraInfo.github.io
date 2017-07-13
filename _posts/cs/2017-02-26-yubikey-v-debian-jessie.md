---
title: YubiKey 4 v Debian Jessie
---

YubiKey a U2F jsou jedny z nejlepších věcí, které se staly v počítačové bezpečnosti posledních let. Je to čipová karta a zároveň usb čtečka v balení, které se zcela schová do usb portu (verze nano). Nijak tedy nevyčnívá a je možné ho třeba v notebooku prostě nechat jako takovou simku na které máte hardwarově chráněné všechny svoje kryptografické klíče, protože tahle titěrnost zvládá prakticky všechny standardizované bezpečnostní technologie. Jeho využití je ve skutečnosti tak široké, že nastavit ho v plném rozsahu je vlastně dost práce. Proto tady nechám svoje poznámky z takového nastavování v Debian Jessie, může to někomu pomoct.

POZOR!!! Toto jsou opravdu pouze poznámky a rozcestník odkazů. Nejedná se o doslovný návod a v žádném případě jej tak nepoužívejte, pokud zcela nerozumíte popsané problematice. Počítačová bezpečnost na této úrovni je velmi ostrý nástroj se kterým se můžete šeredně pořezat. Tím nemyslím jen potenciální bezpečnostní díry, ale třeba také lock-out z vlastního systému!

## Prerekvizity

    sudo apt-get install pcscd pcsc-tools opensc

### [Yubico personalization tool](https://developers.yubico.com/yubikey-personalization/)

Je potřeba inicializovat token do [správného usb módu](https://developers.yubico.com/yubikey-personalization/Manuals/ykpersonalize.1.html). Není potřeba celý GUI nástroj, stačí jen verze s command line interface.

    sudo apt-get install libusb-dev
    wget https://developers.yubico.com/yubico-c/Releases/libyubikey-1.13.tar.gz # lib je potreba pro build personalisation tool
    tar tar -xf libyubikey-1.13.tar.gz
    cd libyubikey-1.13
    ./configure
    make check
    sudo make install
    cd ..
    wget https://developers.yubico.com/yubikey-personalization/Releases/ykpers-1.17.3.tar.gz
    tar -xf ykpers-1.17.3.tar.gz
    cd ykpers-1.17.3/
    ./configure
    make
    sudo make install
    sudo ./ykpersonalize -m 6 # Nastav token do modu OTP+U2F+CCID

V Debian Jessie je pro YubiKey 4 potřeba [updatovat seznam známých zařízení libccid](https://github.com/Yubico/yubioath-desktop/blob/master/resources/linux-patch-ccid):

    sudo vim /etc/libccid_Info.plist

>     <key>ifdVendorID</key>
>     <array>
>     +    <string>0x1050</string>
>     +    <string>0x1050</string>
>     +    <string>0x1050</string>
>     +    <string>0x1050</string>
>     ...
>     <key>ifdProductID</key>
>     <array>
>     +    <string>0x0407</string>
>     +    <string>0x0406</string>
>     +    <string>0x0405</string>
>     +    <string>0x0404</string>
>     ...
>     <key>ifdFriendlyName</key>
>     <array>
>     +    <string>Yubico Yubikey 4 OTP+U2F+CCID</string>
>     +    <string>Yubico Yubikey 4 U2F+CCID</string>
>     +    <string>Yubico Yubikey 4 OTP+CCID</string>
>     +    <string>Yubico Yubikey 4 CCID</string>

    sudo service pcscd restart

## Výchozí bod

    opensc-tool --list-readers

>     # Detected readers (pcsc)
>     Nr.  Card  Features  Name
>     0    Yes             Yubico Yubikey NEO OTP+U2F+CCID 00 00

    piv-tool -n

>     Using reader with a card: Yubico Yubikey NEO OTP+U2F+CCID 00 00
>     PIV-II card

    pcsc_scan

>     Reader 0: Yubico Yubikey NEO OTP+U2F+CCID 00 00
>       Card state: Card inserted,
>       ATR:
>       ...
>     Possibly identified card (using /usr/share/pcsc/smartcard_list.txt):
>             YubiKey NEO (PKI)
>             http://www.yubico.com/

    pkcs15-tool -D

>     Using reader with a card: Yubico Yubikey NEO OTP+U2F+CCID 00 00
>     PKCS#15 Card [PIV_II]:
>             Version        : 0
>             Serial number  : 00000000
>             Manufacturer ID: piv_II
>             Flags          :
>
>     PIN [PIV Card Holder pin]
>             Object Flags   : [0x1], private
>     ...

    yubico-piv-tool -a status

>     CHUID:  No data available
>     CCC:    No data available
>     PIN tries left: 3

## [U2F](https://www.yubico.com/support/knowledge-base/categories/articles/can-set-linux-system-use-u2f/)

    sudo vim /etc/udev/rules.d/70-u2f.rules

>     # this udev file should be used with udev 188 and newer
>     ACTION!="add|change", GOTO="u2f_end"
>
>     # Yubico YubiKey
>     KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0402|0403|0406|0407|0410", TAG+="uaccess"
>
>     LABEL="u2f_end"

## [PIV](https://ubuntuforums.org/showthread.php?t=1557180)

### [Info](https://developers.yubico.com/yubico-piv-tool/YubiKey_PIV_introduction.html)

PIV applet AID: a000000308

The default PIN code is 123456. The default PUK code is 12345678.

The default 3DES management key (9B) is 010203040506070801020304050607080102030405060708.

The following key slots exists:

* 9A, 9C, 9D, 9E: RSA 1024, RSA 2048, or ECC secp256r1 keys (algorithms 6, 7, 11 respectively).

* 9B: Triple-DES key (algorithm 3) for PIV management.

The maximum size of stored objects is 2025/3049 bytes for current versions of YubiKey NEO and YubiKey 4, respectively.

Currently all functionality are available over both contact and contactless interfaces (contrary to what the specifications mandate).

### [Sloty v YubiKey NEO](https://developers.yubico.com/PIV/Introduction/Certificate_slots.html)

* Slot 9a: PIV Authentication
* Slot 9c: Digital Signature
* Slot 9d: Key Management
* Slot 9e: Card Authentication

### [Yubico PIV tool](https://developers.yubico.com/yubico-piv-tool/)

    sudo apt-get install libssl-dev libpcsclite-dev
    wget https://developers.yubico.com/yubico-piv-tool/Releases/yubico-piv-tool-1.4.2.tar.gz
    tar -xvf yubico-piv-tool-1.4.2.tar.gz
    cd yubico-piv-tool-1.4.2
    ./configure
    make # vysledek v tool/
    sudo make install
    sudo ldconfig -v

### Inicializace klíče

    yubico-piv-tool -a change-pin # pin i puk nejsou ty same, jako treba pro gpg, je nutne je nastavit samostatne.
    yubico-piv-tool -a change-puk
    yubico-piv-tool -s 9a -o public_key.pem --touch-policy=always -a generate
    yubico-piv-tool -s 9a -i public_key.pem -o certificate.pem -S '/CN=Frantisek Rezac/OU=individual/O=calavera.info/' -a verify -a selfsign
    yubico-piv-tool -s 9a -i certificate.pem --touch-policy=always -a import-certificate
    pkcs15-tool --list-keys # Pro zjisteni ID klice
    pkcs15-tool --read-ssh-key <ID klice>
    echo <ssh-rsa ...> >> ~/.ssh/authorized_keys # pro pouziti PIV pro SSH login

#### [Ověření informací v certifikátu](https://www.sslshopper.com/article-most-common-openssl-commands.html)

    pkcs15-tool --list-certificates # pro zjisteni ID certifikatu
    pkcs15-tool --read-certificate <ID certifikatu> # Ulozit vystup do certificate.pem
    openssl x509 -in certificate.pem -text -noout

#### [Alternativní generování klíče pomocí OpenSSL na počítači](https://en.wikibooks.org/wiki/Cryptography/Generate_a_keypair_using_OpenSSL)

    openssl genpkey -algorithm RSA -out private_key.pem -pkeyopt rsa_keygen_bits:2048
    openssl rsa -pubout -in private_key.pem -out public_key.pem
    yubico-piv-tool -s 9a --touch-policy=always -i private_key.pem -a import-key
    # zbytek stejny jako pri generovani na karte

#### Alternativní generování klíče pomocí piv-tool/OpenSSL na YubiKey (experimentální)

    echo -n  01:02:03:04:05:06:07:08:01:02:03:04:05:06:07:08:01:02:03:04:05:06:07:08 > admin.key
    export PIV_EXT_AUTH_KEY=/home/calavera/admin.key
    piv-tool --genkey 9A:07 --admin A:9B:03 --out ./9a-public

    export PIV_9A_KEY=/home/calavera/prace/passwords/yubikey-info/9a-public
    openssl
    engine dynamic -pre SO_PATH:/usr/lib/engines/engine_pkcs11.so -pre ID:pkcs11 -pre NO_VCHECK:1 -pre LIST_ADD:1 -pre LOAD -pre MODULE_PATH:/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
    req -engine pkcs11 -x509 -new -key slot_1-id_1 -keyform engine -out 9a-x509.pem -text
    req -engine pkcs11 -pubkey -new -key slot_1-id_1 -keyform engine -out 9a-public.pem -text

### SSH

Buď v `~/.ssh/config`

    PKCS11Provider /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so

nebo jako parametr příkazové řádky

    -I /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so

### PAM

    man pam_pkcs11
    sudo apt-get install libpam-pkcs11
    sudo mkdir /etc/pam_pkcs11
    zcat /usr/share/doc/libpam-pkcs11/examples/pam_pkcs11.conf.example.gz | sudo tee /etc/pam_pkcs11/pam_pkcs11.conf
    sudo mkdir /etc/pam_pkcs11/cacerts /etc/pam_pkcs11/crls

    sudo vim /etc/pam_pkcs11/pam_pkcs11.conf

>     pkcs11_module opensc {
>         module = /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so;
>         cert_policy = signature;
>         ...
>     }
>     ...
>     use_mappers = openssh;

#### Test

    sudo vim /etc/pam.d/sudo

>     %PAM-1.0
>     +auth sufficient pam_pkcs11.so debug
>     @include common-auth

#### Globálně

    sudo vim /etc/pam.d/common-auth

>     # pam-auth-update(8) for details.
>     +auth    [success=3 default=ignore]  pam_pkcs11.so
>     # here are the per-package modules (the "Primary" block)

#### Keyring

Side efekt zavedení PKCS11 PAM je, že se nemůže automaticky odemkdnout defaultní Gnome keyring pomocí login hesla. Ještě horší je, že se nějakou automagií po ručním otevření keyringu změní heslo keyringu na PIN (který se zadává na přihlašovací obrazovce místo hesla). Tohle funguje i opačně, tedy když se někdy v budoucnu člověk opět přihlásí heslem, změní se heslo keyringu z PINu na heslo.

## [GPG](https://www.yubico.com/support/knowledge-base/categories/articles/use-yubikey-openpgp/)

Defaultně je v Debianu Jessie instalované GPG 1.x.x, které má omezení na RSA max 3072 bitů. Pro využití RSA 4096, kterého je schopný YubiKey 4, je potřeba instalovat GPG řady 2.

    sudo apt-get install gnupg2 scdaemon rng-tools
    gpg2 --change-pin # GPG PIN i admin PIN neni ten samy jako u PIV, je potreba jej nastavit zvlast

### Generování klíče

#### Přímo na kartě

Tuto variantu nepoužívat! Při generování se sice nabídne vytvoření off card zálohy, ale to se bude zálohovat jen podklíč pro encryption, ne hlavní certifikační klíč!

    gpg2 --card-edit

>     admin
>     generate # souhlasit s off-card zálohou, která vytvoří soubor sk_XXXXXXXXXXXXXXXXX.gpg

    gpg2 --card-status # zjistit key id
    gpg2 --armor --export <key id> --output pgp-public-key.asc
    gpg2 --armor --export-secret-keys <key id> --output pgp-secret-key.asc # toto nezalohuje doopravdy privatni klic, jen stub ukazujici na kartu
    gpg2 --gen-revoke <key id> --output pgp-revocation.asc
    # publikovat klic na http://keys.gnupg.net/ nebo jinem serveru z sks keyserver pool nebo
    gpg2 --send-key <key id> # v pgp.conf musi byt nastaveny keyserver (to je defaultne) nebo pridat parametr --keyserver keys.gnupg.net

#### Na air-gapovaném počítači

    gpg2 --gen-key # vytvori hlavni (certifikacni a podepisovaci) klic a podklic pro ecnryption
    # expiration nedavat, na hlavni klic se sbiraji overovaci podpisy ostatnich o ktere by se po expiration prislo
    # lepsi je dat expiration na podklice vytvorene pozdeji
    # bez zadane expiration pri generovani bude sice bez expiration i podklic pro encryption, ale to se da opravit pozdeji
    gpg2 --expert --edit-key <key id> # expert je potreba aby bylo mozne vytvorit podklic pro authentication
>     key 1 # vybere encryption podklic pro nasledujici pokyny
>     expire # nastavit expiration, ktere je z predchoziho kroku nenastavene
>     key 0 # zrusi vybrani
>     addkey # pridat podklic pro signing (mozne zvolit primo z nabidky) a authentication (je potreba togglovat rucne)
>     save

    cp -R ~/.gnupg /mnt/usb/gpg-backup/

    gpg2 --edit-key <key id>
>     key 1
>     keytocard # vybrat prislusny slot, udelat pro subklice pro signing, encryption, authentication
>     save

### Záloha GPG klíče na druhou kartu

#### [Pokud byl klíč generován přímo na kartě][https://readlist.com/lists/gnupg.org/gnupg-users/6/30732.html]

V tomto případě nelze klíč duplikovat celý, jen encryption podklíč, který se při vytváření uložil na disk.

    gpg2 --edit-key <key id>
>     toggle
>     bkuptocard sk_XXXXXXXXXXXXXXX.gpg # soubor vytvoreny pri vygenerovani klice

#### Pokud byl klíč generován na airgapovaném počítači

    cp /mnt/usb/gpg-backup/.gnupg ~/alt-gpg-home
    gpg2 --homedir ~/alt-gpg-home --edit-key <key id>
    # zopakovat prikaz keytocard jako pri vytvareni primarni karty, je mozne vynechat save

### Inicializace pracovního počítače

    sudo apt-get install pinentry-curses
    sudo update-alternatives --display pinentry
    sudo update-alternatives --config pinentry

    # import public klice je mozne provest nekolika zpusoby
    # bud stazenim z keyserveru s odvozenim key id ze secret klice na karte
    gpg2 --card-edit

>     fetch

    # nebo importem souboru
    gpg2 --import gpg-public-key.asc

    # nebo stazenim z keyserveru
    gpg2 --recv-keys <key id>

    # v gpg se neda odvodit public klic ze secret klice! (neobsahoval by asi uid)

    gpg2 --card-status # jako vedlejsi efekt propoji privatni klic na karte s klicem stazenym pomoci fetch
    gpg2 --edit-key <key id>

>     trust # zvolit ultimate trust

    vim ~/.gnupg/gpg.conf

>     +default-key <key id>
>     +default-recipient-self

### Přechod na záložní kartu na pracovním počítači

    gpg2 --delete-secret-keys <key id>
    gpg2 --card-status # svaze aktualni (nahradni) kartu s puvodnim public klicem (stejne jako pri inicializaci karty primarni)

### Troubleshooting

    gpg2 --list-packets secret-exported-key.gpg # zobrazi jednotlive pakety v klici
    cat secret-exported-key.gpg > gpgsplit # rozdeli klic do souboru obsahujicich jednotlive pakety
    cat paket1.sig paket2.uid paket3.sig | gpg2 --import # importuje jen vybranou podmnozinu klicu

### Použití

    gpg2 --clearsign sometext.txt

### [Nedostatek entropie](http://fios.sector16.net/hardware-rng-on-raspberry-pi/)

GPG může zůstat "viset", což znamená, že má nedostatek entropie. Dá se to zpravit démonem pro doplňování entropie v kernelu, kterému se dá zadat zdroj entropie. Tím se dá doplňovat entropie z pseudonáhodných čísel, ale u Raspberry jde využít i hardwarový generátor.

    # pokud se rngd nespousti automaticky, je mozne spustit rucne
    sudo rngd -r /dev/hwrng # raspberry nebo
    sudo rngd -r /dev/urandom # pseudonahodna cisla

Jiná možnost je ještě použít hardwarový generátor přímo z karty pomocí příkazu `scdrand`, ale to jsem netestoval.

### Přechod na nový GPG klíč v pass

Pass init je možné dělat opakovaně i s několika různými key id. Pass zajistí šifrování pro všechny klíče, které si
uchovává v ~/.password-store/.gpg-id

    pass init <old key id> <new key id>

### GIT ###
V gitu je možné explicitně podepisovat commity pomocí GPG.

    vim ~/.gitconfig

>     [user]
>         ...
>     +    signingkey = <signing key id>
>     +[gpg]
>     +    program = gpg2

    git commit -S -am 'signed commit'
    git log --show-signature -1

### GIT ###
V gitu je možné explicitně podepisovat commity pomocí GPG.

    vim ~/.gitconfig

>     [user]
>         ...
>     +    signingkey = <signing key id>
>     +[gpg]
>     +    program = gpg2

    git commit -S -am 'signed commit'
    git log --show-signature -1



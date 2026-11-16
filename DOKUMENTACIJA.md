# PROJEKTNA DOKUMENTACIJA MOBILNE APLIKACIJE „FLORAMARKET“

**Univerzitet u Novom Sadu**  
**Fakultet tehničkih nauka**  
**Departman za računarsku tehniku i računarske komunikacije**  
**Predmet:** Mobilne informacione tehnologije  
**Smer:** Inženjerstvo informacionih sistema  

**Student:** Atina Vučković IT67/2024  
**Profesori:** dr Marko Arsenović, dr Srđan Sladojević  
**Predmetni asistenti:** Maša Šaranović, Tamara Žuvela, Sofija Đorđević  

---

## 1. Uvod

### 1.1 Svrha projekta
Svrha projekta je realizacija visoko responzivne, modularne mobilne aplikacije **„FloraMarket”** koja objedinjuje ponudu lokalnih cvećara i korisnicima omogućava jednostavan, brz i vizuelno dopadljiv proces pretrage, naručivanja i kupovine svežeg cveća, sobnih biljaka i cvetnih aranžmana. Posebna pažnja posvećena je modernoj edukaciji korisnika o pravilnoj nezi biljaka u zavisnosti od spoljnih mikroklimatskih uslova, što se ostvaruje povezivanjem sa javnim meteorološkim servisom.

### 1.2 Opseg projekta
Opseg sistema obuhvata:
- Prezentaciju profila lokalnih cvećara u Novom Sadu sa osnovnim informacijama (lokacija, radno vreme, kontakt, ocene).
- Dinamički prikaz kataloga proizvoda (buketi, saksijske i sobne biljke, sukulenti, aranžmani) uz savete za negu.
- Integraciju sa spoljnim servisom **OpenWeather API** radi automatskog prikazivanja saveta za zalivanje i vlaženje listova u skladu sa trenutnom temperaturom i vlažnošću vazduha.
- Korpu i upravljanje narudžbinama uz automatizovan proračun cene dostave.
- Online naplatu putem **Stripe API-ja** korišćenjem sigurnog *PaymentIntent* mehanizma.
- Zaštićeni administratorski panel sa potpunim CRUD mogućnostima nad artiklima i cvećarama, kao i praćenjem statusa generisanih porudžbina.

### 1.3 Definicije i skraćenice
- **UI (User Interface)** – Korisnički interfejs mobilne aplikacije.
- **Flutter** – Google-ov open-source radni okvir za izradu nativnih aplikacija za više platformi (iOS, Android, Web) iz jedne baze koda.
- **Dart** – Objektno-orijentisani programski jezik optimizovan za razvoj korisničkog interfejsa.
- **Widget** – Osnovna strukturna i vizuelna jedinica Flutter aplikacije.
- **State Management** – Upravljanje stanjem aplikacije i sinhronizacija podataka između sloja poslovne logike i prikaza.
- **Provider** – Preporučeni Flutter paket za upravljanje stanjem zasnovan na `ChangeNotifier` obrascu.
- **Firestore** – Fleksibilna, skalabilna NoSQL cloud baza podataka (deo Firebase platforme).
- **API (Application Programming Interface)** – Softverski posrednik koji omogućava komunikaciju sa eksternim servisima (Stripe, OpenWeather).
- **CRUD** – Akronim za osnovne operacije nad podacima: *Create* (Kreiranje), *Read* (Čitanje/Prikaz), *Update* (Ažuriranje), *Delete* (Brisanje).

---

## 2. Opis problema i motivacija

### 2.1 Problem
Tradicionalni način kupovine cveća vezan je za fizički odlazak u pojedinačne cvećare, gde je kupac ograničen trenutnim asortimanom jedne lokacije. Pritom, kupci nakon kupovine (posebno zahtevnijih sobnih biljaka kao što su *Monstera Deliciosa* ili *Orhideja Phalaenopsis*) često nemaju odgovarajuće smernice o održavanju, te biljke u kućnim uslovima propadaju usled nepravilnog zalivanja, promaje ili promene godišnjih doba.

### 2.2 Motivacija i ciljne grupe
Ideja iza **FloraMarket** platforme jeste da objedini ponudu cvećara u jednom gradu, pruži transparentnost cena i asortimana, i obezbedi kupcima kontinuirani kontekstualni savet za održavanje.
Ciljne grupe obuhvataju:
- Građane koji žele brzu dostavu buketa na kućnu adresu ili kao poklon za posebne prilike.
- Ljubitelje sobne vegetacije (tzv. *urban jungle* pokret) koji žele precizna uputstva o nezi.
- Lokalne vlasnike cvećara kojima digitalna platforma donosi veći obim porudžbina i vidljivost bez potrebe za sopstvenim IT sistemom.

---

## 3. Opis korišćenog tehnološkog steka

### 3.1 Frontend i programski jezik
- **Flutter 3.x / Dart 3.x:** Omogućava renderovanje sa 60/120 fps, konzistentan prikaz i podršku za Material 3 dizajn sistem.
- **Google Fonts (Poppins):** Za modernu, čitljivu tipografiju.
- **Cupertino Icons & Material Icons:** Za prepoznatljive vizuelne oznake radnji.

### 3.2 Upravljanje stanjem (State Management)
- **Provider paket:** Logika aplikacije je odvojena od korisničkog interfejsa. Svaki provajder nasleđuje `ChangeNotifier` i poziva `notifyListeners()` prilikom promene stanja, čime se selektivno ponovo iscrtavaju samo komponente koje zavise od tih podataka:
  - `AuthProvider` – stanje ulogovanog korisnika i prava pristupa.
  - `CartProvider` – stanje korpe, količina i obračun ukupnog iznosa.
  - `ProductProvider` – stanje artikala, filteri, pretraga i CRUD operacije.
  - `ShopProvider` – lista cvećara i radnji.
  - `OrderProvider` – kreiranje i praćenje narudžbina.
  - `WishlistProvider` – perzistentno čuvanje omiljenih artikala.
  - `ThemeProvider` – promena između svetle i tamne teme.

### 3.3 Baza podataka i skladištenje
- **Firebase Firestore (NoSQL):** Podaci se čuvaju u vidu dokumenata unutar 4 ključne kolekcije:
  - `users` (podaci o profilu, ulozi i kontaktima)
  - `florists` (cvećare sa nazivom, lokacijom, radnim vremenom i ocenama)
  - `products` (artikli sa cenom, uputstvom za održavanje, kategorijom i slikom)
  - `orders` (porudžbine sa podacima o kupcu, adresom, stavkama i statusom)
- **SharedPreferences:** Za lokalno perzistiranje korisničkih podešavanja (režim teme, lokalni keš, omiljeni artikli).

### 3.4 Spoljne API integracije
1. **OpenWeather API:**
   - Preuzima trenutne vremenske podatke za Novi Sad (temperatura, vlažnost vazduha, vremenske prilike).
   - Aplikacija mapira ove podatke u personalizovan savet za negu biljaka (npr. pri temperaturama preko 28°C savetuje orošavanje listova i češću promenu vode u vazi; pri temperaturama ispod 10°C savetuje unošenje sobnih biljaka dalje od hladnih prozora).
2. **Stripe API:**
   - Korišćenje *PaymentIntent* koncepta gde aplikacija generiše iznos u RSD i autorizuje kartično plaćanje preko bezbednog toka.

---

## 4. Arhitektura sistema (Opis implementacije)

### 4.1 Organizacija modula
Projekat prati slojevitu arhitekturu preporučenu u Flutter zajednici:
- `models/` – čiste domen klase sa `fromMap` i `toMap` serijalizacijom.
- `services/` – enkapsulacija mrežnih poziva, Stripe plaćanja i komunikacije sa Firestore bazom.
- `providers/` – stanje aplikacije, logika filtriranja i reaktivni tokovi.
- `screens/` – ekrani aplikacije grupisani logički po modulima (`home/`, `shop/`, `product/`, `cart/`, `checkout/`, `orders/`, `wishlist/`, `profile/`, `admin/`, `auth/`).
- `widgets/` – višekratne komponente prilagođene dizajnerskom sistemu.
- `config/` – konstante, stilovi i definicije tema.

### 4.2 Korisničke uloge (Specifikacija 3.2)
Sistem strogo odvaja prava pristupa za 3 definisane uloge:
1. **Gost:**
   - Čitanje javnih podataka: početni ekran, preporučene cvećare, OpenWeather kartica, katalog proizvoda i detalji sa savetima.
   - Pristup korpi i checkout formi je blokiran – prikazuje se obaveštenje sa pozivom na prijavu.
2. **Kupac:**
   - Puna mogućnost naručivanja cveća, dodavanje u korpu, odabir količine, brisanje iz korpe.
   - Lista želja (*Wishlist*).
   - Checkout tok sa unosom adrese i Stripe kartičnom naplatom.
   - Praćenje sopstvene istorije porudžbina.
   - Ažuriranje sopstvenog profila (*Update* kontakt podataka).
3. **Administrator:**
   - Pristup kontrolnoj tabli sa metrikom prihoda i broja artikala.
   - **Create:** Dodavanje novih artikala cveća i novih cvećara.
   - **Read:** Pregled svih artikala i svih narudžbina u sistemu.
   - **Update:** Izmena postojećih artikala i promenu statusa porudžbina u realnom vremenu (*U pripremi*, *Poslato*, *Isporučeno*).
   - **Delete:** Brisanje artikala i uklanjanje cvećara.

---

## 5. Funkcionalnosti aplikacije (Prikaz i opis)

- **Dinamički vremenski widget (OpenWeather):** Prikazuje temperaturu, procenat vlage i automatski generisan savet za cvećare i kućne biljke.
- **Pretraga i filtriranje:** Filtriranje po kategorijama (*Buketi*, *Sobno cveće*, *Aranžmani*, *Sukulenti*) i tekstualna pretraga po nazivu ili uputstvu za negu.
- **Katalog cvećara:** Prikaz radnji na mapi / listi uz uvid u detalje pojedinačne radnje i asortiman koji isključivo ta radnja nudi.
- **Detalji artikla:** Prikaz fotografije, cene, opisa, istaknutog uputstva za održavanje, odabir količine i dugme za dodavanje u korpu.
- **Korpa sa kalkulatorom dostave:** Automatski proračun troškova dostave (standardna dostava 350 RSD, a besplatna za porudžbine veće od 4.000 RSD).
- **Checkout i Stripe plaćanje:** Unos adrese primaoca, napomene za posvetu i sigurna obrada putem Stripe servisa.
- **Istorija porudžbina:** Transparentan prikaz statusa porudžbina kroz vizuelne značke u boji.
- **Svetla i Tamna tema:** Dinamička promena izgleda na nivou čitave aplikacije jednim klikom.

---

## 6. Potencijalna unapređenja, rizici i ograničenja

- **Potencijalna unapređenja:**
  - Dodavanje Stripe Webhook mehanizma na serverskoj strani za asinhronu potvrdu uspeha uplate.
  - Implementacija Push notifikacija (npr. Firebase Cloud Messaging) koje bi korisnike podsećale na zalivanje sobne biljke jednom nedeljno.
  - Kalendar za zakazivanje dostave cveća na tačan datum (rođendani, 8. mart, Dan zaljubljenih).
- **Rizici:**
  - Zavisnost od stabilne internet konekcije prilikom Stripe transakcije (rešeno kroz transakcioni model stanja u `OrderProvider`-u).
  - Firebase bezbednosna pravila (*Security Rules*) koja moraju onemogućiti neautorizovano menjanje cena i statusa od strane običnih kupaca.
- **Ograničenja:**
  - Cveće je kvarljiva roba, stoga je logistika dostave ograničena na lokalno tržište (grad Novi Sad).

---

## 7. Zaključak

Aplikacija **FloraMarket** u potpunosti ispunjava sve zahteve definisane specifikacijom predmeta *Mobilne informacione tehnologije*:
- Implementirane su sve 3 obavezne uloge (Gost, Kupac, Administrator).
- Svi podaci se dinamički preuzimaju iz baze podataka (Firestore NoSQL) bez hardkodovanog sadržaja.
- Podržane su sve osnovne **CRUD operacije** (Create, Read, Update, Delete) nad podacima.
- Integrisana su dva spoljna API servisa (**OpenWeather API** i **Stripe API**).
- Korisnički interfejs je moderan, responzivan, izrađen u Flutter framework-u u skladu sa vodećim standardima mobilnog dizajna.

---

## 8. Reference

1. Flutter zvanična dokumentacija: https://docs.flutter.dev/
2. Firebase Authentication & Firestore vodič: https://firebase.google.com/docs
3. Provider paket za upravljanje stanjem u Flutteru: https://pub.dev/packages/provider
4. Stripe PaymentIntents API referenca: https://docs.stripe.com/api
5. OpenWeather Current Weather Data API: https://openweathermap.org/api


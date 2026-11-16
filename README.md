# FloraMarket – Mobilne Informacione Tehnologije

**Univerzitet u Novom Sadu • Fakultet tehničkih nauka**  
**Smer:** Inženjerstvo informacionih sistema  
**Predmet:** Mobilne informacione tehnologije  
**Student:** Atina Vučković (IT67/2024)  
**Profesori:** dr Marko Arsenović, dr Srđan Sladojević  
**Predmetni asistenti:** Maša Šaranović, Tamara Žuvela, Sofija Đorđević  

---

## 🌸 O Projektu

**FloraMarket** je moderna mobilna aplikacija razvijena u **Flutter framework-u** korišćenjem **Dart** programskog jezika. Aplikacija funkcioniše kao digitalna platforma za lokalne cvećare na teritoriji Novog Sada, omogućavajući korisnicima pregled cveća, sobnih biljaka, aranžmana i online kupovinu.

Ključna inovacija projekta je **edukacija o nezi biljaka** kroz integraciju **OpenWeather API-ja**, koji na osnovu trenutnih meteoroloških parametara (temperatura, vlažnost vazduha) dinamički generiše savete za zalivanje i održavanje cveća. Za bezbedno online plaćanje integrisan je **Stripe API** putem *PaymentIntent* toka.

---

## 👥 Korisničke Uloge i Prava Pristupa (Specifikacija 3.2)

1. **Gost (neulogovan korisnik):**
   - Pregled javno dostupnih stranica: početni ekran sa OpenWeather widgetom i savetima.
   - Izlistavanje preporučenih cvećara i pretraga artikala.
   - Prikaz detalja o biljkama (slike visoke rezolucije, cene, uputstva za negu).
   - *Zaštita:* Nema pristup korpi niti mogućnost kreiranja porudžbina (pri pokušaju se prikazuje obaveštenje za prijavu).

2. **Registrovani korisnik (kupac):**
   - Registracija i prijava sa validacijom unosa (email, lozinka, kontakt podaci).
   - Dodavanje artikala u korpu, promena količina i brisanje stavki.
   - Lista želja (*Wishlist*) za čuvanje omiljenih biljaka.
   - Checkout proces sa unosom adrese dostave i Stripe kartičnim plaćanjem.
   - Automatsko pražnjenje korpe i kreiranje porudžbine u Firestore bazi.
   - Pregled istorije porudžbina i statusa pripreme/isporuke.
   - Ažuriranje svojih kontakt podataka (*Update* profil).
   - Promena teme aplikacije (**Svetli / Tamni režim**).

3. **Administrator:**
   - Pristup zaštićenoj kontrolnoj tabli (*Admin Dashboard*).
   - **CRUD nad proizvodima:**
     - *Create:* Dodavanje novog cveća i biljaka.
     - *Read:* Pregled kompletnog inventara sa filterima.
     - *Update:* Izmena cene, opisa, fotografije ili saveta za održavanje.
     - *Delete:* Trajno uklanjanje artikla iz baze.
   - Upravljanje cvećarama (dodavanje i brisanje partnerskih radnji).
   - Praćenje svih porudžbina u sistemu uz promenu statusa u realnom vremenu (*Na čekanju*, *U pripremi*, *Poslato*, *Isporučeno*, *Otkazano*).

---

## 🛠️ Tehnološki Stek

- **Frontend:** Flutter SDK (Dart)
- **Upravljanje stanjem (State Management):** `Provider` (`ChangeNotifierProvider`, `Consumer`)
- **Baza podataka i Auth:** Firebase Firestore (kolekcije `users`, `florists`, `products`, `orders`) & Firebase Auth
- **Spoljni API 1:** **OpenWeather API** – preuzimanje temperature i vlažnosti u realnom vremenu i generisanje dinamičkih saveta o nezi biljaka
- **Spoljni API 2:** **Stripe API** – procesiranje online kartičnih uplata putem *PaymentIntent* mehanizma
- **Lokalno skladištenje:** `shared_preferences`

---

## 📁 Arhitektura Projekta

```
flowermarket/
├── pubspec.yaml                 # Konfiguracija zavisnosti paketa
├── README.md                    # Uputstvo i opis projekta
├── DOKUMENTACIJA.md             # Kompletna projektna dokumentacija
├── test/
│   └── unit_test.dart           # Jedinični testovi za korpu i vremenske savete
├── preview/
│   └── index.html               # Interaktivni live simulator aplikacije za prezentaciju
├── lib/
│   ├── main.dart                # Inicijalizacija i MultiProvider konfiguracija
│   ├── config/
│   │   ├── constants.dart       # Konstante aplikacije, rute, cene, API ključevi
│   │   └── theme.dart           # Light i Dark teme (Material 3)
│   ├── models/
│   │   ├── florist.dart         # Model cvećare
│   │   ├── product.dart         # Model cveta / biljke
│   │   ├── cart_item.dart       # Model stavke u korpi
│   │   ├── order.dart           # Model porudžbine
│   │   ├── user_profile.dart    # Model korisničkog profila i uloga
│   │   └── weather_data.dart    # Model vremenskih prilika i saveta
│   ├── services/
│   │   ├── firestore_service.dart # Rad sa NoSQL kolekcijama i postojanost podataka
│   │   ├── weather_service.dart   # OpenWeather API pozivi i fallback kalkulacije
│   │   └── stripe_service.dart    # Stripe PaymentIntent obrada uplata
│   ├── providers/
│   │   ├── auth_provider.dart     # Autentifikacija i uloge (Gost, Kupac, Admin)
│   │   ├── cart_provider.dart     # Upravljanje korpom i obračun dostave
│   │   ├── product_provider.dart  # Upravljanje proizvodima i CRUD operacije
│   │   ├── shop_provider.dart     # Upravljanje cvećarama
│   │   ├── order_provider.dart    # Generisanje i praćenje statusa porudžbina
│   │   ├── wishlist_provider.dart # Upravljanje listom želja
│   │   └── theme_provider.dart    # Promena teme (Svetla / Tamna)
│   ├── widgets/
│   │   ├── weather_tip_card.dart  # Dinamički OpenWeather widget sa savetom
│   │   ├── florist_card.dart      # Kartica cvećare sa ocenom i lokacijom
│   │   ├── product_card.dart      # Kartica proizvoda sa cenom i brzim dodavanjem
│   │   ├── cart_item_tile.dart    # Stavka u korpi sa +/- i brisanjem
│   │   ├── custom_button.dart     # Stilizovano dugme sa stanjem učitavanja
│   │   ├── custom_text_field.dart # Polje za unos sa validacijom
│   │   ├── role_badge.dart        # Značka trenutne uloge
│   │   └── empty_state.dart       # Prikaz praznog stanja
│   └── screens/
│       ├── splash_screen.dart           # Splash ekran sa logotipom
│       ├── main_navigation_screen.dart  # BottomNavigationBar navigacija
│       ├── home/home_screen.dart        # Početni ekran sa widgetima
│       ├── shop/
│       │   ├── shops_list_screen.dart   # Pregled svih cvećara
│       │   └── shop_details_screen.dart # Detalji cvećare i njen asortiman
│       ├── product/
│       │   └── product_details_screen.dart # Velika slika, opis, nega, količina
│       ├── cart/cart_screen.dart        # Pregled korpe i iznosa
│       ├── checkout/checkout_screen.dart# Forma za dostavu i Stripe naplata
│       ├── order_success/order_success_screen.dart # Potvrda porudžbine
│       ├── orders/order_history_screen.dart        # Istorija kupovina
│       ├── wishlist/wishlist_screen.dart           # Sačuvani artikli
│       ├── profile/
│       │   ├── profile_screen.dart      # Korisnički profil i demo switcher
│       │   └── edit_profile_screen.dart # Ažuriranje podataka kupca
│       └── admin/
│           ├── admin_dashboard_screen.dart # Kontrolna tabla za administratora
│           ├── manage_products_screen.dart # Lista i CRUD operacije nad cvećem
│           ├── add_edit_product_screen.dart# Forma za unos i izmenu artikla
│           ├── manage_orders_screen.dart   # Praćenje i promena statusa porudžbina
│           └── manage_shops_screen.dart    # Upravljanje cvećarama
```

---

## 🚀 Pokretanje Projekta

### 1. Pokretanje preko Flutter CLI-ja
Ukoliko imate instaliran Flutter SDK:
```bash
cd flowermarket
flutter pub get
flutter run
```
Za pokretanje na vebu ili Chrome pregledaču:
```bash
flutter run -d chrome
```

### 2. Pokretanje testova
```bash
flutter test
```

### 3. Interaktivni Live Simulator (Brzi pregled bez čekanja)
U folderu `preview/index.html` nalazi se kompletan interaktivni mobilni simulator sa simuliranim iPhone okvirom koji možete odmah otvoriti u bilo kom veb pregledaču:
- Mogućnost instant prebacivanja između sve 3 uloge (**Gost**, **Kupac**, **Administrator**).
- Testiranje OpenWeather dinamičkog widgeta.
- Testiranje korpe i proračuna besplatne dostave (preko 4.000 RSD).
- Testiranje simulacije Stripe naplate.
- Testiranje kompletnih administratorskih CRUD funkcija (dodavanje, izmena i brisanje cveća iz baze).


# EVMaroc

> L'app iOS de référence pour localiser les bornes de recharge au Maroc

---

## Problem Statement

Les conducteurs de VE au Maroc n'ont pas de source unique fiable pour localiser les bornes de recharge. Les données sont fragmentées entre plusieurs apps d'opérateurs (Kilowatt, TotalEnergies, FastVolt), aucune ne couvre tout le marché, et les infos sont souvent obsolètes.

**User frustration** : "Je ne sais jamais si la borne sera là, compatible, et fonctionnelle."

---

## Target Users

| Persona | Description | Besoin primaire |
|---------|-------------|-----------------|
| **Navetteur urbain** | Casablanca/Rabat, recharge au bureau ou mall | Trouver une borne proche, savoir si dispo |
| **Road-tripper** | Trajets inter-villes (Casa → Marrakech) | Planifier les arrêts, éviter l'angoisse de la panne |
| **Early adopter** | Passionné EV, veut contribuer | Signaler nouvelles bornes, corriger erreurs |

**MVP Focus** : Navetteur urbain + Road-tripper

---

## Core User Jobs (Jobs-to-be-Done)

```
QUAND je suis en déplacement avec ma voiture électrique
JE VEUX trouver rapidement une borne compatible proche
POUR pouvoir recharger sans stress
```

```
QUAND je planifie un trajet longue distance
JE VEUX voir les bornes sur mon itinéraire
POUR savoir où m'arrêter et éviter la panne
```

```
QUAND j'arrive à une borne et qu'elle est HS ou différente
JE VEUX pouvoir signaler le problème
POUR aider les autres conducteurs
```

---

## MVP Feature Set (MoSCoW)

### Must Have (V1.0)

| Feature | Rationale |
|---------|-----------|
| Carte interactive | Core value — voir les bornes autour de soi |
| Fiche station | Détails essentiels : connecteurs, puissance, opérateur |
| Filtres | Type de prise, puissance minimum |
| Recherche | Par ville ou adresse |
| Navigation | Ouvrir dans Apple Maps / Google Maps |
| Signalement | "Info incorrecte" / "Borne HS" |

### Should Have (V1.1)

| Feature | Rationale |
|---------|-----------|
| Favoris | Sauvegarder ses bornes habituelles |
| Photos | Voir à quoi ressemble la borne |
| Ajouter une borne | Crowdsourcing |

### Could Have (V1.2+)

| Feature | Rationale |
|---------|-----------|
| Filtres avancés | Gratuit/payant, accès 24h, avec café |
| Historique | Mes dernières recharges |
| Planificateur d'itinéraire | Suggérer les arrêts sur un trajet |

### Won't Have (MVP)

- Paiement in-app
- Disponibilité temps réel
- Réservation
- Comptes utilisateurs complexes

---

## Information Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      TAB BAR                            │
├─────────────────┬─────────────────┬─────────────────────┤
│                 │                 │                     │
│    🗺️ Carte     │    📍 Liste     │    ⚙️ Réglages     │
│   (default)     │                 │                     │
│                 │                 │                     │
└─────────────────┴─────────────────┴─────────────────────┘
```

### Navigation Flow

```
Carte
 ├── Tap pin → Station Sheet (bottom sheet, 40% height)
 │              ├── Swipe up → Full Station Detail
 │              └── Tap "Itinéraire" → Apple Maps
 │
 ├── Search bar → Search Results
 │
 └── Filter button → Filter Sheet

Liste
 ├── Tap row → Station Detail (push)
 └── Pull to refresh

Réglages
 ├── Filtres par défaut
 ├── Langue (FR/AR)
 ├── À propos
 └── Contribuer une borne
```

---

## Key Screens — UX Specification

### Map View (Home)

```
┌─────────────────────────────────────────┐
│ ┌─────────────────────────────────────┐ │
│ │ 🔍 Rechercher une ville, adresse... │ │
│ └─────────────────────────────────────┘ │
│                                         │
│         MAP (full bleed)                │
│                                         │
│              📍                         │
│                    📍    📍             │
│                                         │
│        📍                               │
│                         📍              │
│                                    [◎]  │  ← Re-center button
│                                    [⊞]  │  ← Filter button
│─────────────────────────────────────────│
│  🗺️        📍        ⚙️               │  ← Tab bar
└─────────────────────────────────────────┘
```

**Behavior**

- Map centers on user location on launch (with permission)
- Pins clustered when zoomed out
- Tap pin → bottom sheet slides up
- Search bar is collapsed by default, expands on tap

**Pin Design**

| État | Couleur | Signification |
|------|---------|---------------|
| Disponibilité inconnue | Gris | Donnée non vérifiée récemment |
| Vérifié récemment | Vert | Confirmé par un utilisateur |

---

### Station Sheet (Bottom Sheet)

**Triggered by** : Tap on map pin
**Height** : 40% screen (détent), swipe up for full detail

```
┌─────────────────────────────────────────┐
│ ──────  (drag indicator)                │
│                                         │
│  Station Anfaplace Mall                 │
│  📍 Casablanca · 1.2 km                 │
│                                         │
│  ┌────────┐ ┌────────┐ ┌────────┐       │
│  │ Type 2 │ │  CCS   │ │  22kW  │       │
│  │  AC    │ │  DC    │ │  50kW  │       │
│  └────────┘ └────────┘ └────────┘       │
│                                         │
│  Opérateur : Kilowatt                   │
│  Mis à jour : il y a 3 jours            │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │       🧭  Itinéraire            │    │  ← Primary CTA
│  └─────────────────────────────────┘    │
│                                         │
│  Voir détails ↑                         │
└─────────────────────────────────────────┘
```

**UX Details**

- Connector types as **visual chips** with icons
- Power displayed prominently (users care about kW)
- "Mis à jour" = trust signal
- Primary action = Navigation (most common intent)

---

### Station Detail (Full Screen)

**Triggered by** : Swipe up on sheet OR tap "Voir détails"

```
┌─────────────────────────────────────────┐
│ ← Retour           Station              │
│─────────────────────────────────────────│
│                                         │
│  ┌─────────────────────────────────┐    │
│  │                                 │    │
│  │         📷 Photo                │    │
│  │        (placeholder)            │    │
│  │                                 │    │
│  └─────────────────────────────────┘    │
│                                         │
│  Station Anfaplace Mall                 │
│  Casablanca, Boulevard de la Corniche   │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  CONNECTEURS                            │
│  ┌─────────────────────────────────┐    │
│  │ ⚡ Type 2         22 kW    AC   │    │
│  │    x2 prises                    │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │ ⚡ CCS Combo      50 kW    DC   │    │
│  │    x1 prise                     │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  INFORMATIONS                           │
│  Opérateur         Kilowatt             │
│  Accès             24h/24               │
│  Tarif             0.5 DH/min (AC)      │
│                    2.5 DH/min (DC)      │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │       🧭  Itinéraire            │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ⚠️ Signaler un problème                │
│                                         │
└─────────────────────────────────────────┘
```

---

### Filter Sheet

**Triggered by** : Filter button on map

```
┌─────────────────────────────────────────┐
│ ──────                                  │
│                                         │
│  Filtres                   Réinitialiser│
│                                         │
│  TYPE DE PRISE                          │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌────────┐  │
│  │Type 2│ │ CCS  │ │CHAdeMO│ │Domestic│  │
│  │  ✓   │ │  ✓   │ │      │ │        │  │
│  └──────┘ └──────┘ └──────┘ └────────┘  │
│                                         │
│  PUISSANCE MINIMUM                      │
│  ○ Tous   ○ 22kW+   ● 50kW+   ○ 100kW+ │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │      Appliquer (12 stations)    │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

---

## Visual Design Direction

### Design Principles

| Principe | Application |
|----------|-------------|
| **Clarity over decoration** | UI minimale, focus sur les données |
| **Trust through transparency** | Montrer la fraîcheur des données |
| **Speed to value** | Info clé visible en < 2 sec |
| **Native iOS feel** | SF Symbols, system fonts, standard patterns |

### Color Palette

| Token | Value | Usage |
|-------|-------|-------|
| Primary | `#10B981` | Green — énergie, EV |
| Background | System Background | Adapts to dark mode |
| Text Primary | System Label | — |
| Text Secondary | System Secondary Label | — |
| Accent | `#3B82F6` | Blue — CTAs |
| Warning | `#F59E0B` | Orange — signalements |

### Typography

| Style | Spec |
|-------|------|
| Large Title | SF Pro Display Bold 34pt |
| Title 1 | SF Pro Display Bold 28pt |
| Headline | SF Pro Text Semibold 17pt |
| Body | SF Pro Text Regular 17pt |
| Caption | SF Pro Text Regular 12pt |

### Icons

SF Symbols exclusively:

- `bolt.fill` — bornes
- `fuelpump.fill` — type de courant
- `location.fill` — navigation
- `exclamationmark.triangle` — signalement

---

## Data Model

### Station

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | String | Nom de la station |
| `address` | String | Adresse complète |
| `city` | String | Ville |
| `latitude` | Decimal | Coordonnée GPS |
| `longitude` | Decimal | Coordonnée GPS |
| `operator` | String | Kilowatt, TotalEnergies, etc. |
| `is_verified` | Boolean | Vérifié par un utilisateur |
| `created_at` | Timestamp | — |
| `updated_at` | Timestamp | — |

### Connector

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `station_id` | UUID | Foreign key |
| `type` | Enum | Type2, CCS, CHAdeMO, Domestic |
| `power_kw` | Integer | Puissance en kW |
| `current_type` | Enum | AC, DC |
| `quantity` | Integer | Nombre de prises |

### Contribution

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `station_id` | UUID | Foreign key (nullable si nouvelle) |
| `type` | Enum | new_station, correction, photo |
| `data` | JSON | Données de la contribution |
| `status` | Enum | pending, approved, rejected |
| `created_at` | Timestamp | — |

---

## Tech Stack

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **UI** | SwiftUI | Modern, declarative, less code |
| **Map** | MapKit | Native, free, performant |
| **Location** | Core Location | iOS standard |
| **Backend** | Supabase | Postgres + REST API + Auth + Free tier |
| **Storage** | Supabase Storage | Photos des bornes |

### Dependencies

```swift
dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
]
```

---

## Project Structure

```
EVMaroc/
├── App/
│   └── EVMarocApp.swift
├── Models/
│   ├── Station.swift
│   ├── Connector.swift
│   └── ConnectorType.swift
├── Services/
│   ├── StationService.swift
│   ├── LocationService.swift
│   └── SupabaseClient.swift
├── Views/
│   ├── Map/
│   │   ├── MapView.swift
│   │   └── StationAnnotation.swift
│   ├── StationList/
│   │   ├── StationListView.swift
│   │   └── StationRow.swift
│   ├── StationDetail/
│   │   ├── StationDetailView.swift
│   │   └── ConnectorCard.swift
│   └── Common/
│       ├── FilterSheet.swift
│       └── SearchBar.swift
└── Resources/
    └── Assets.xcassets
```

---

## MVP Success Metrics

| Metric | Target (3 mois post-launch) |
|--------|----------------------------|
| Downloads | 1,000 |
| DAU | 100 |
| Stations dans la DB | 150+ |
| Contributions utilisateurs | 50+ signalements |
| App Store rating | 4.0+ |

---

## MVP Scope Summary

### In Scope (V1.0)

- [x] Carte interactive avec pins
- [x] Bottom sheet station
- [x] Détail station complet
- [x] Filtres (type de prise, puissance)
- [x] Recherche ville/adresse
- [x] Navigation vers Apple Maps
- [x] Signalement de problème

### Out of Scope (Future)

- [ ] Comptes utilisateurs
- [ ] Favoris (V1.1)
- [ ] Ajout de borne (V1.1)
- [ ] Photos (V1.1)
- [ ] Disponibilité temps réel
- [ ] Paiement in-app
- [ ] Planificateur d'itinéraire

---

## Market Context (Morocco)

### Current Infrastructure

| Metric | Value |
|--------|-------|
| Bornes AC (lentes) | ~1,500 |
| Bornes DC (rapides) | < 100 |
| Stations actives | ~80 |
| Points de recharge publics | ~400 |

### Major Operators

- **TotalEnergies** — 15 stations sur l'axe Tanger-Agadir
- **IRESEN + ADM** — 37 stations autoroutières
- **Kilowatt** — Service national à la demande
- **FastVolt** — Focus Tanger
- **EV I-smart** — Startup bornes 100% marocaines

### Pricing

- AC : 0.5 DH/min
- DC : 2.5 DH/min

---

## License

MIT

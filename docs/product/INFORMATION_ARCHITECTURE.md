# Arcus — Product Spec & Information Architecture

## Brand

- **App name:** Arcus  
- **Tagline:** Precision archery calculators, offline.  
- **Positioning:** Professional offline-first calculators for compound, recurve, traditional, and crossbow setups. Original visual identity (deep spruce + brass), unrelated to any reference website’s look or copy.  
- **Disclaimer (global):** Results are planning estimates. Inspect, chronograph, and tune equipment with a qualified professional before hunting or competition.

## Assumptions (non-blocking)

1. Website sync API will be implemented later by the website team; Arcus ships OpenAPI + mock sync.  
2. Store listings target Android + iOS; Linux/web used for CI smoke.  
3. English-first localization via ARB; no hard-coded UI strings.  
4. Ads off by default (`AdConfig.enabled = false`); AdMob test IDs only.

## Primary user flows

1. **Quick calc** → Home → category → calculator → live result → save/favorite.  
2. **Setup Assistant** → bow → arrow → components → performance → recommendations → save profile.  
3. **Profile reuse** → select “My Hunting Rig” → open any calculator pre-filled.  
4. **Learn** → guides / glossary / safety offline.  
5. **Sync (optional online)** → pull content updates → show “last updated”.

## App navigation

```
Bottom nav:
  Home | Calculators | Assistant | Library | More

More: Profiles, History, Converters, Settings, Privacy, Terms, About
```

## Calculator catalog (v1 shipped in engine + UI shells)

### Arrow build
Arrow Weight, FOC (measured), FOC (component estimate), Component Weight, GPI helpers, Arrow Length, Point Weight, GPP, Balance, Spine Selection.

### Bow performance
Bow Speed (IBO), Arrow Speed (mass change), Draw Weight helpers, Draw Length, Let-Off, Efficiency (approx), Stored Energy (approx).

### Performance / hunting
KE, Momentum, Drop, Trajectory, Sight Pin Gap, Shot Angle, Velocity Loss, Downrange Energy/Momentum.

### Spine / tuning
Static spine lookup (heuristic), Dynamic load index, Point/length/cam adjustments, Paper tuning guide, Spine charts (planning).

### Crossbow
Bolt weight, Speed, KE, Momentum, Drop/trajectory, Bolt selection notes.

### Converters
Weight, length, speed, energy, momentum, angle, distance.

## Screen template (every calculator)

Matches STEP 4 of the master prompt: breadcrumb, title, intro, inputs+units+tooltips, Calculate/Reset/Copy, results, formula, steps, interpretation, charts, examples, limitations/safety, FAQ, related tools/guides.

## Design system (summary)

See `docs/design/DESIGN_SYSTEM.md`. Light + dark navy themes; 8pt spacing; large touch targets (≥48dp); live preview; sticky calculate on small phones.

# Nexo de Runas — Visual pilot: 3 canonical Forest cards

## Scope
Branch: `feature/visual-pilot-three-cards`. Do not merge into `main` until the APK is visually verified on Android.

Pilot cards:
- `BS-001` → `bs_001_brote_del_claro` (1 cost / 1 ATQ / 2 SAL)
- `BS-006` → `bs_006_lobo_de_manada` (3 cost / 3 ATQ / 3 SAL)
- `BS-013` → `bs_013_avatar_del_bosque` (6 cost / 6 ATQ / 8 SAL)

## Supplied art bundle
From this conversation: `Nexo_de_Runas_Arte_Piloto_3_Cartas_para_Godot.zip`.
Copy the three `.webp` images as binary files to `assets/domains/forest/cards/art/`, retaining exact names. The bundle contains a README.

- `bs_001_brote_del_claro.webp`
- `bs_006_lobo_de_manada.webp`
- `bs_013_avatar_del_bosque.webp`

Source artwork in the conversation remains the archive/master; these are cropped, Android-friendly 384×512 WebP versions. Do not substitute AI-generated full card images containing baked text or stats.

## Already implemented in this branch
- `card_art_registry.gd`: official card-id-to-art path; per-card focal points; proportional crops
- `vertical_battle_card.gd`: dynamic hand / lane illustration rendering without touching combat
- `canonical_forest_card.gd`: canonical Forest card detail rendering and fallback
- `tests/visual_pilot_three_cards_test.gd`: mappings, crops, dynamic ATQ/SAL
- Android GitHub Actions workflow runs pilot contract test

## Acceptance gate
1. Verify all three images exist in GitHub at the exact paths.
2. Godot 4.3 import and all existing tests pass.
3. Android debug workflow succeeds on the feature branch; APK artifact appears.
4. On-device verify hand, lane, enlarged detail and crop legibility for 3 cards.
5. Names, cost, ATQ, SAL, abilities and gameplay continue to come from canonical card data.
6. No change to `scripts/domain/`, `scripts/application/`, combat rules, Android signing or saves.
7. Share the APK directly and a short before/after summary. Never claim APK ready before workflow completion.

## Known limitation
The current GitHub connector can commit text, but the 3 artwork binary files have **not yet been uploaded to the branch**. A coding session that can upload binary assets must import the supplied ZIP. Until then, the renderer will correctly continue showing its temporary rune fallback.

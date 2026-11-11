# CHANGES

## 2026-11-11 - v0.26 (correction objets finis + joaillerie/enchantement/alchimie/cuisine)

**Correction** : la récupération des objets finis ne fonctionnait pas pour les
writs journaliers — Lazy Writ Crafter met les crafts de writ en file
LibLazyCrafting avec un style libre (`LLC_FREE_STYLE_CHOICE`, une chaîne de
caractères), et l'ancien code exigeait un style numérique pour construire le
lien de l'objet final. Les matériaux étaient donc toujours retirés.

### Correction et précision de l'appariement (writs journaliers)

- Les objets finis des commandes journalières sont appariés **quel que soit le
  style, sans trait et de qualité blanche uniquement** : n'importe quel style
  est utilisé pour construire le lien (`GetSmithingPatternResultLink` — le
  style ne change pas l'ItemId), et les piles du sac / de la banque de guilde
  sont filtrées par `GetItemLinkQuality == ITEM_QUALITY_NORMAL` et
  `GetItemLinkTraitInfo == ITEM_TRAIT_TYPE_NONE`.
- Une requête **avec trait** ou **d'ensemble** (`setIndex`) ne peut pas être
  satisfaite par un objet blanc sans trait : matériaux uniquement.
- **Joaillerie** : station 7 (`CRAFTING_TYPE_JEWELRYCRAFTING`) ajoutée au
  traitement smithing (matériaux + objets finis).

### Enchantement / Alchimie / Cuisine (pris en charge par LibLazyCrafting)

- **Enchantement** : matériaux = les trois runes (`potencyItemID` /
  `essenceItemID` / `aspectItemID` × `quantity`) ; objet fini = le glyphe,
  calculé via `GetEnchantingResultingItemLink` (les slots des runes sont
  cherchés dans le sac puis la banque de guilde).
- **Alchimie** : matériaux = solvant + réactifs (`solventId`, `reagentId1-3` ×
  `timesToMake`) ; objet fini = la potion, via `GetAlchemyResultingItemLink`.
- **Cuisine** : matériaux = les ingrédients de la recette
  (`GetRecipeIngredientItemLink` + `GetRecipeIngredientRequiredQuantity` ×
  `timesToMake`) ; objet fini = le plat, via `resultLink` de la requête LLC ou
  `GetRecipeResultItemLink` (couverture partielle : la quantité par craft de
  `GetRecipeResultQuantity` est prise en compte).
- Ces matériaux sont fusionnés avec les besoins des writs (maximum par objet),
  et la mécanique « l'objet fini remplace les matériaux » s'applique aussi
  bien au file LLC qu'aux besoins matériaux des writs.

### Limites

- Les objets finis doivent se trouver dans la **même banque de guilde** que
  l'étape « Retirer pour commandes journalières » (l'API du jeu n'expose que
  la banque de guilde actuellement sélectionnée).
- Glyphes / potions / plats : appariement par ItemId exact (le lien résultat
  encode l'objet précis) ; le filtre blanc/sans trait ne s'applique qu'aux
  objets d'équipement smithing dont l'ItemId n'encode ni trait ni qualité.
- Non testé dans ESO : validation hors jeu uniquement (compilation Lua 5.1
  et harnais de tests avec file LLC simulée — 61 assertions).

## 2026-11-11 - v0.25 (récupération des objets finis + traduction française)

**Objectif** : récupérer automatiquement en banque de guilde l'objet final (épée,
casque, bâton, bouclier...) et non simplement les matériaux, et ajouter la
traduction française (`lang/fr.lua`).

### Ajouts

- **Objets finis depuis la banque de guilde** : pour chaque requête
  « smithing » de la file LibLazyCrafting, le lien de l'objet final est
  construit via `GetSmithingPatternResultLink(patternIndex, materialIndex,
  materialQuantity, itemStyleId, traitIndex, linkStyle)` (API ESOUI, inchangée
  entre U51 et U52 ; appelée par LibLazyCrafting lui-même pour ses crafts).
  L'objet est recherché dans le sac et dans la banque de guilde
  (`WG.FindItem`) ; les exemplaires disponibles sont retirés directement au
  lieu des matériaux, et la quantité de matériaux est réduite en conséquence
  (couverture partielle : produit x n + matériaux pour le reste).
- **Réduction des besoins des writs** : quand l'objet final est disponible, la
  quantité de matériaux qu'il remplace est aussi déduite du besoin calculé
  depuis les conditions des writs journaliers (plancher 0) — la fabrication
  n'est plus demandée en double.
- **Style / trait requis** : avec un choix de style libre
  (`LLC_FREE_STYLE_CHOICE`, une chaîne de caractères dans LibLazyCrafting),
  l'objet final ne peut pas être déterminé : seul le matériau est compté
  (comportement précédent). La qualité (blanc/vert...) n'est pas comparée :
  l'appariement se fait par ItemId, comme pour les matériaux.
- Nouveau réglage « Take Finished Products Instead of Materials » (activé
  par défaut, `WG.SV.LazyCraftingProduct`) ; chaînes en / zh / fr.
- **Traduction française** : `WareGuild/lang/fr.lua` — traduction complète de
  `lang/en.lua` (interface, réglages, messages de discussion). Chargée
  automatiquement par le manifeste (`lang/$(language).lua`) pour les clients
  français.
- `Version: 0.25`, `WG.version = "0.25"` (`AddOnVersion` inchangé).

### Tests hors jeu

- Harnais étendu à 36 assertions : produit entièrement en banque de guilde
  (produit retiré, aucun matériau), couverture partielle (1 produit +
  matériaux pour l'exemplaire manquant), produit absent (matériaux seuls),
  style libre (matériaux seuls), réglage désactivé (matériaux seuls), writ
  couvert par le produit (besoin matériaux du writ réduit à 0). Tous les
  fichiers livrés compilent en Lua 5.1.

### Limites

- Les objets finis ne sont recherchés que pour les requêtes de type
  « smithing » (forge, couture, travail du bois) avec style et trait fixés ;
  les requêtes d'enchantement, d'alchimie, de cuisine ou de joaillerie de la
  file LibLazyCrafting ne sont pas couvertes.
- Non testé dans ESO : validation hors jeu uniquement (compilation Lua 5.1
  et harnais de tests avec file d'attente LLC simulée).

## 2026-11-11 - v0.24 (Update U51/U52, API 101051 / 101052)

**Objectif** : mise à jour pour la version ESOUI actuelle (Update 52, API 101052 —
compatible live U51 et PTS U52) et interaction avec LazyCrafting pour les tâches
journalières récurrentes.

### Ajouts

- **Intégration LazyCrafting (LibLazyCrafting)** : nouvelle fonction
  `WG.FindLazyCraftingItem()` lit la file d'attente de LibLazyCrafting
  (`LibLazyCrafting.craftingQueue`, utilisée par Dolgubon's Lazy Writ Crafter et
  Lazy Set Crafter) et en extrait les matériaux de base (acier / textile / bois,
  stations forge, couture, travail du bois) des objets à fabriquer.
  `WG.FindDailyItem()` fusionne ces quantités avec celles calculées depuis les
  conditions des writs journaliers : pour un même matériau, le maximum des deux
  sources est retenu afin d'éviter un double comptage (retrait en trop).
- Nouveau réglage « Use LazyCrafting Queue » (activé par défaut) dans le menu ;
  chaînes en / zh ajoutées.
- `LibLazyCrafting` et `FCOItemSaver` déclarés en `OptionalDependsOn` dans le
  manifeste.

### Mises à jour U51/U52

- `## APIVersion: 101051 101052` (avant : 101044), `Version: 0.24`,
  `AddOnVersion: 20261111`.
- Vérifications effectuées contre le dépôt esoui (branches `live` = API 101051
  et `pts` = API 101052, documentation ESOUIDocumentation) : toutes les
  fonctions et constantes utilisées (`GetJournalQuestInfo`,
  `GetQuestConditionItemInfo`, `GetJournalQuestConditionValues`,
  `DoesItemLinkFulfillJournalQuestCondition`, `GetItemLinkStacks`,
  `GetSmithingPatternMaterialItemLink`, `GetNextGuildBankSlotId`,
  `INTERACTION:PopulateChatterOption` / `FinalizeChatterOptions`,
  `GetChatterOptionData`, scènes `guildBank` / `gamepad_guild_bank` /
  `interact` / `gamepadInteract`, fragments `GUILD_BANK_FRAGMENT` /
  `GAMEPAD_GUILD_BANK_FRAGMENT`, `ZO_SavedVars`, `QUEST_TYPE_CRAFTING`,
  `ITEMFILTERTYPE_*`, `SETTING_TYPE_LOOT`) existent et sont inchangées entre
  U51 et U52. L'option `optionIndex` de fonction (utilisé par WareGuild pour
  l'entrée de dialogue « WareGuild ») reste supportée par le client
  (`label.optionIndex()` dans `interactwindow_shared.lua`).

### Corrections et optimisations

- `WG.FindItem` (banque de guilde) : `GetNextGuildBankSlotId()` peut retourner
  `nil` quand la banque est vide — garde ajoutée (avant : erreur « for initial
  value must be a number »).
- `WG.FindDailyItem` (scan alchimie/cuisine dans la banque de guilde) : le test
  `if GetNextGuildBankSlotId then` était toujours vrai et ne protégeait rien —
  remplacé par une garde réelle sur le résultat.
- Suppression de l'appel `StackBag(BAG_BACKPACK)` à la fermeture de la banque
  de guilde : fonction jamais définie dans l'addon (depuis le commit initial),
  provoquait une erreur Lua « attempt to call a nil value » à chaque fermeture.
- Boucles d'inventaire `for i = 0, GetBagSize(1) do` : `GetBagSize` retourne un
  nombre de slots (indices valides 0 à n-1) — corrigées en
  `GetBagSize(1) - 1` (`WG.FindItem`, `WG.FindItemType`, `ShouldStack`,
  `WG.Stack`, `ItemList`).

### Tests hors jeu

- `test/test_WareGuild.lua` : harnais autonome (Lua 5.1 via lupa) qui charge
  les fichiers livrés (pas des copies) avec des stubs du jeu et une file
  LibLazyCrafting simulée — 18 assertions (accumulation LLC, multiplicateur
  `smithingQuantity`, fusion max avec les writs, réglage désactivé, absence de
  LibLazyCrafting, banque de guilde vide sans crash, bornes des boucles
  d'inventaire). Hors du dossier chargé en jeu.

### Limites

- Le calcul des matériaux LazyCrafting ne couvre que les matériaux de base
  (lingots/étoffe/cuir/bois) des requêtes de type « smithing » (forge, couture,
  travail du bois) ; les pierres de style, pierres de trait et matériaux
  d'amélioration ne sont pas comptés (comme pour l'analyse existante des writs).
- Non testé dans ESO : validation hors jeu uniquement (compilation Lua 5.1 et
  harnais de tests avec file d'attente LLC simulée).

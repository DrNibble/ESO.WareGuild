# CHANGES

## 2026-11-13 - v0.29 (regroupement des piles avant tous les dépôts)

### Fonctionnement

- **Tous les dépôts WareGuild** : dépôt de matériaux par catégorie, dépôt
  intégral et dépôt jusqu'à une quantité cible, y compris le redépôt du
  surplus d'un retrait. Les objets non empilables conservent leur transfert
  habituel.
- **Planification dans Data.lua** : les dépôts et séparations prévus par
  slot deviennent des transactions par lien d'objet. La quantité nette à
  déposer reste celle de la règle d'origine. Le calcul de place tient compte
  du retrait de piles entières, des empilements intermédiaires et des
  emplacements libérés par le dépôt des piles pleines avant la séparation
  finale.
- **Exécution dans Main.lua** : retirer les piles correspondantes de la
  banque sélectionnée, les empiler dans le sac après chaque retrait, séparer
  le reliquat à conserver, puis redéposer les piles regroupées. Les slots
  sont relus à chaque mouvement ; aucune file de slots périmés n'est
  réutilisée après un empilement.
- **Exemple validé** : banque `2 + 3` ancolies, sac `25`, quantité à garder
  dans le sac `5` : retrait des deux piles, empilement à `30`, puis dépôt
  d'une seule pile de `25` et conservation de `5` dans le sac.

### Protections et repli

- **Place insuffisante** : message dans le chat, aucun retrait pour le
  regroupement, puis dépôt habituel. Un sac entièrement plein ne bloque plus
  un dépôt de pile entière. Si le dépôt habituel exige lui-même une
  séparation et qu'aucun emplacement n'est disponible, il reste impossible :
  arrêt avec le message de sac plein plutôt qu'un dépôt du reliquat réservé.
- **Objets compatibles uniquement** : pas d'appariement approximatif par
  ItemId pour le regroupement. Les contrôles de qualité, trait, niveau et
  points Champion complètent la comparaison du lien et le contournement
  historique du niveau interne en banque.
- **Droits et protections** : respects des exclusions FCOItemSaver existantes.
  Sans droit de retrait, dépôt habituel avec avertissement. Les slots de
  banque sont revérifiés avant chaque retrait ; si leur contenu change ou
  si le droit disparaît, le regroupement restant est ignoré et les piles déjà
  récupérées sont incluses dans le redépôt.
- **Événements asynchrones** : attendre à la fois la confirmation locale du
  transfert en banque et la mise à jour du sac, quel que soit leur ordre.
  Les mouvements de séparation/empilement attendent les quantités source
  et destination. Les événements d'autres joueurs ne valident pas le
  transfert.
- **Annulation et erreurs** : nettoyage des événements à la fermeture,
  invalidation des anciens callbacks et garde contre un double démarrage.
  Une erreur de transfert ou un délai de 10 secondes sans réponse provoque
  un arrêt avec message invitant à vérifier le sac et la banque. Les objets
  déjà transférés ne sont pas automatiquement restaurés après cet arrêt.
- **Langues et version** : messages ajoutés en français, anglais et chinois ;
  version `0.29`, AddOnVersion `20261113`.

### Vérification

API et signatures vérifiées dans
[ESOUI live, révision f819c808](https://github.com/esoui/esoui/blob/f819c808d57e237707c76e7b52518e2589c9e191/ESOUIDocumentation.txt) :
`TransferFromGuildBank`, `TransferToGuildBank`, `GetSlotStackSize`,
`FindFirstEmptySlotInBag`, `DoesPlayerHaveGuildPermission`,
`RequestMoveItem` et événements de banque/inventaire.

Compilation de tous les fichiers Lua livrés en Lua 5.1 et **216 assertions
hors jeu réussies** : 92 tests existants, plus 124 assertions de
`test/test_GuildBankDeposit.lua`. Le nouveau harnais charge les vrais fichiers
Data.lua et Main.lua et simule les transferts et leurs événements différés :
exemple des ancolies, tous les types de dépôt, limites de pile, 20 jeux de
quantités, manque de place, banque pleine, événements dans les deux ordres,
objets protégés, niveaux différents, changement de droits/contenu,
fermeture, changement de guilde, erreur serveur et timeout.

**Non testé dans ESO** : validation hors jeu uniquement. Les transferts
concernent exclusivement la banque de guilde sélectionnée et utilisent le
sac à dos réel, sans sac virtuel.

## 2026-11-12 - v0.28 (craft level des objets finis dans FindDailyItem)

- **Niveau exact du writ** : pour la forge, la couture, le bois et la
  joaillerie, `WG.FindDailyItem()` construit un lien de référence depuis
  `GetSmithingPatternInfoForItemId(ItemId, MaterialId, CraftType)`, puis
  `GetSmithingPatternResultLink` avec l'index de matériau retourné et la
  quantité du tier dans `WG.MaterialExcel`. Le candidat doit avoir le même
  `GetItemLinkRequiredLevel` et les mêmes
  `GetItemLinkRequiredChampionPoints`, en plus des critères blanc, sans
  trait et condition du journal satisfaite. Le style reste libre.
- **Retrait cohérent** : `CraftLevel` et `CraftChampionPoints` accompagnent
  l'objet jusqu'à l'étape de banque et au filtre optionnel de `WG.FindItem`.
  Un autre exemplaire du même ItemId, mais du mauvais niveau, ne peut donc
  ni gonfler le total du sac ni être sélectionné pour ce retrait. Les
  règles ordinaires sans filtre gardent leur comportement.
- **Repli prudent** : si le patron ou le lien de référence est indisponible,
  les matériaux restent demandés ; aucun niveau n'est deviné.
- **Périmètre** : ce correctif vise les équipements des conditions du journal.
  Le parcours propre à la file LibLazyCrafting reste inchangé.

### Vérification

Signatures contrôlées dans `esoui/esoui`, branche `live`, révision
`f819c808d57e237707c76e7b52518e2589c9e191` (API 101051, mise à jour
12.1.7 du 9 novembre 2026) :
[documentation des API](https://github.com/esoui/esoui/blob/f819c808d57e237707c76e7b52518e2589c9e191/ESOUIDocumentation.txt)
et [résolution du patron depuis le journal](https://github.com/esoui/esoui/blob/f819c808d57e237707c76e7b52518e2589c9e191/esoui/ingame/crafting/craftadvisor_manager.lua#L261).

Compilation des fichiers livrés en Lua 5.1 et harnais hors jeu :
92 assertions, dont niveau incorrect, niveaux mélangés, CP150 contre CP160,
style différent, sac au mauvais niveau, filtres blanc/sans trait au retrait,
référence indisponible et parcours réel de l'étape journalière jusqu'au
choix du slot transféré. Non testé dans ESO.

## 2026-11-11 - v0.27 (objets finis des writs journaliers sans file LazyCrafting)

**Correction** : la récupération des objets finis en banque de guilde ne
fonctionnait que via la file d'attente LibLazyCrafting — elle dépendait donc
de Lazy Writ Crafter et de sa file (souvent vide au moment d'ouvrir la
banque de guilde). Un bouclier en érable (itemId 43556) présent en banque
de guilde n'était jamais retiré pour un writ du journal.

### Cause racine

`WG.FindDailyItem()` lisait bien les conditions du writ
(`GetQuestConditionItemInfo`) mais ne cherchait que les **matériaux bruts**
(forge / couture / bois / joaillerie / enchantement). La recherche d'objets
finis existait uniquement dans le parcours de la file LazyCrafting
(`WG.FindLazyCraftingItem`). Pour un writ du journal sans entrée dans la
file LLC, aucun objet fini n'était jamais trouvé dans la banque de guilde.

### Correction

- **Parcours du journal de quêtes** : pour chaque condition de writ
  (forge, couture, bois, joaillerie), la banque de guilde est maintenant
  balayée avec `DoesItemLinkFulfillJournalQuestCondition` (comme le
  faisait déjà le code pour l'alchimie et la cuisine). Un objet fini est
  retenu s'il est **blanc** (`GetItemLinkQuality == ITEM_QUALITY_NORMAL`),
  **sans trait** (`GetItemLinkTraitInfo == ITEM_TRAIT_TYPE_NONE`) et qu'il
  remplit la condition du writ, quel que soit son style.
- **Enchantement** : même balayage pour les glyphes — un glyphe déjà en
  banque remplace les trois runes.
- **Matériaux réduits en conséquence** : la quantité de matériaux bruts
  n'est calculée que pour les objets restant à fabriquer (besoin du writ
  moins les objets finis trouvés en banque).
- **Fusion des deux parcours** : les objets finis des writs et ceux de la
  file LazyCrafting sont fusionnés en une seule étape de retrait
  (`Count` = contenu actuel du sac + quantité réclamée), plafonnée par la
  disponibilité de la banque de guilde. L'option « Retirer les objets finis
  au lieu des matériaux » s'applique donc aussi aux writs journaliers,
  même sans Lazy Writ Crafter.

### Tests (hors-ligne)

Harnais Lua étendu (74 assertions au total) : retrait de 2 boucliers sans
aucune file LazyCrafting, couverture partielle (1 objet fini + matériaux du
manquant), objet déjà dans le sac, option désactivée, bouclier vert ou avec
trait ignoré, glyphe d'enchantement retenu sans runes.

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

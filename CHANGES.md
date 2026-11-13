# CHANGES

## 2026-11-13 - v0.37 (diagnostic du regroupement au dépôt)

- **Regroupement au dépôt (pierres d'âme, etc.)** : le mécanisme existe depuis
  la v0.29 (retrait des piles de la banque, regroupement dans le sac,
  dépôt du montant nécessaire, conservation du montant à garder). Il est
  ignoré quand les piles de la banque ne sont pas strictement identiques
  (niveau, PC, qualité, trait ou lien) à celles du sac.
- **Nouveau message** : lorsque la banque contient le même objet mais que la
  pile est rejetée, le chat affiche les liens, niveaux, PC et qualités du sac
  et de la banque, afin de déterminer la cause réelle sans deviner. Aucun
  assouplissement du contrôle pour l'instant : fusionner des niveaux
  différents risquerait de déposer le mauvais objet. Non testé dans ESO.

## 2026-11-13 - v0.36 (retrait des lignes de suivi)

- **Lignes de suivi retirées** : la ligne « dans le sac / à retirer /
  disponible dans cette banque » ajoutée en v0.35 n'est plus affichée. Les
  règles de retrait ne changent pas.
- **Contrôle du niveau exact par la passive d'artisanat : non ajouté.** Le
  matériau du writ (`MaterialId` de la condition) correspond un pour un au
  rang de la passive (10 paliers en forge, couture et bois) ; lire la passive
  n'apporte donc aucune information de plus, et demande de retrouver la bonne
  passive par métier avec des API vérifiables seulement en jeu. Le palier est
  déjà validé par la condition du journal. Un niveau exact par palier
  supposerait une table codée en dur non vérifiée dans ESO.

## 2026-11-13 - v0.35 (diagnostic des objets finis manquants)

- **Ligne de suivi par objet fini de commande journalière** : avant chaque
  retrait, le chat indique pour l'objet le nombre déjà dans le sac, le nombre à
  retirer et le nombre disponible dans la banque de guilde de l'étape
  (par exemple « dans le sac : 0 ; à retirer : 1 ; disponible dans cette
  banque : 1 »). Elle permet de savoir si un objet manquant n'est pas trouvé,
  est déjà compté dans le sac, ou est retiré sans être accepté par la quête.
  Dédupliquée comme les autres messages. Aucun changement de règle de retrait.

## 2026-11-13 - v0.34 (palier du matériau respecté au retrait, sans établi)

**Problème** : en v0.33, la recherche trouvait bien le bouclier et le bâton en
frêne roux (la condition du journal refusait ceux en érable), mais l'étape de
retrait ne gardait que l'`ItemId`, qui est identique à tous les paliers. Elle
pouvait donc retirer l'exemplaire en érable (plus petite pile) et compter un
érable du sac comme stock.

- **Condition du journal portée jusqu'au retrait** : chaque objet fini de writ
  garde les conditions (`quête`, `condition`) qui l'ont demandé. `WG.FindItem`
  (banque et sac) n'accepte plus qu'un exemplaire que
  `DoesItemLinkFulfillJournalQuestCondition` valide pour l'une de ces
  conditions, en plus de la qualité blanche et de l'absence de trait. Cela
  s'applique aux étapes « garder » et « remettre en banque ».
- **Niveau exact** : toujours comparé quand le lien de référence existe
  (établi) ; sinon le palier est validé par la condition du journal.
- **Tests** : un test reproduit le cas (érable et frêne roux de même `ItemId`,
  l'érable dans la plus petite pile ou dans le sac) ; il échoue avec la v0.33
  et passe avec la v0.34.

**Non testé dans ESO** : validation hors jeu uniquement.

## 2026-11-13 - v0.33 (objets finis des commandes journalières sans établi)

**Problème** : à la banque de guilde, le chat affichait pour chaque guilde
« Retrait impossible de [Bâton de rétablissement] / [Bouclier] : niveau de
craft de référence indisponible ; recherche des matériaux à la place », et les
objets finis n'étaient jamais retirés. Les données de patron
(`GetSmithingPatternInfoForItemId` / `GetSmithingPatternResultLink`) ne sont
utilisées par l'interface du jeu qu'à un établi d'artisanat
([craftadvisor_manager.lua](https://github.com/esoui/esoui/blob/live/esoui/ingame/crafting/craftadvisor_manager.lua)) ;
l'hypothèse est qu'à la banque aucun lien de référence n'est disponible, donc
aucun niveau.

- **Repli sans niveau** : quand le lien de référence est vide ou que le patron
  est absent, le niveau exact n'est plus comparé et n'empêche plus le retrait.
  Le niveau n'est jamais deviné. Restent obligatoires : qualité blanche, aucun
  trait, retrait autorisé, et acceptation par la condition du journal de quêtes
  (`DoesItemLinkFulfillJournalQuestCondition`). Quand le niveau est connu (lien
  de référence disponible), le comportement v0.28 est inchangé : niveau et PC
  exacts.
- **Filtre de retrait** : nouvel indicateur `WritProduct` porté par l'étape
  banque/sac. La qualité blanche et l'absence de trait restent donc contrôlées
  dans `WG.FindItem` même sans niveau (auparavant, ce filtre n'existait que
  si un niveau était connu).
- **Message** : la ligne n'est plus formulée comme un blocage (« Retrait
  impossible ») mais comme une note : niveau de référence indisponible hors
  établi, niveau exact non comparé. Dédupliquée comme les autres messages.
- **Tests** : les deux tests « patron absent / lien vide → matériaux » sont
  remplacés par des tests de retrait sans niveau (qualité, trait, condition du
  journal, filtre du sac et de la banque).

**Limite** : le contrôle du niveau exact (v0.28) est perdu tant que le joueur
n'est pas à un établi ; un objet de bon palier mais de niveau différent que la
condition du journal accepterait quand même pourrait être retiré. **Non testé
dans ESO** : validation hors jeu uniquement (Lua 5.1, harnais simulé).

## 2026-11-13 - v0.32 (diagnostic et fiabilisation des retraits)

- **Messages de blocage** : nom de guilde, lien d'objet et motif pour
  FCOItemSaver, verrouillage joueur, droits de retrait, déplacement ou
  modification d'un slot. Les messages identiques sont dédupliqués
  pendant une même exécution. Les protections restent respectées.
- **Commandes journalières** : les équipements candidats sont contrôlés
  avant de remplacer les matériaux nécessaires. Le chat explique une
  qualité, un trait ou un niveau incompatible, un refus par la condition
  du journal, une référence ou une correspondance de matériaux absente,
  une option de récupération des objets finis désactivée ou l'absence
  d'exemplaire dans la banque sélectionnée. Les critères restent :
  qualité blanche, sans trait, tout style et niveau/PC exacts.
- **Parcours de banque** : remplacement de la plage `premier slot + 500`
  par l'itérateur natif `GetNextGuildBankSlotId(slotPrécédent)`, dans
  `FindItem` et les recherches de produits journaliers. Les identifiants
  d'emplacement non contigus et élevés ne sont plus ignorés. Le modèle
  est celui de l'[itérateur de l'interface ESOUI](https://github.com/esoui/esoui/blob/f819c808d57e237707c76e7b52518e2589c9e191/esoui/ingame/globals/commoninventoryfunctions.lua).
- **Chargement de banque** : mémorisation de l'état prêt même si
  `EVENT_GUILD_BANK_ITEMS_READY` précède l'affichage de la scène, en
  clavier/souris et gamepad. Une règle ne démarre qu'avec la guilde
  sélectionnée et chargée attendue. L'état est invalidé à l'ouverture,
  fermeture, sélection ou désélection ; une attente non confirmée est
  interrompue après 20 secondes avec un message.
- **Confirmation des retraits** : attente de l'accusé de retrait local
  pour le bon slot et de l'arrivée effective dans le sac à dos. Les
  événements des autres joueurs ne valident pas l'opération. Un refus
  serveur affiche son code et son libellé ; un transfert non confirmé
  expire après 10 secondes. Un changement de guilde pendant le transfert
  est signalé séparément. L'exécution s'arrête sans réessai automatique
  et restaure le réglage du sac d'artisan. La compensation existante des
  différences de niveau interne dans les liens banque/sac est conservée,
  avec contrôle explicite de la qualité, du trait et du niveau requis.
- **Empilement du sac** : les emplacements protégés ou verrouillés ne
  sont pas déplacés. Attente des quantités des deux côtés et délai de
  10 secondes avec message en cas de déplacement silencieusement annulé.
  Les callbacks périmés ne doivent pas relancer une session terminée.
- **Dépôts préservés** : le calcul du stock en banque pour `STORE_TO`
  ne dépend pas du droit de retrait ; ce droit est contrôlé au moment
  d'un retrait ou du regroupement. Les tests existants de regroupement,
  de règle LibCharacterKnowledge et de tri des menus restent exécutés.
- **API vérifiées** : signatures des événements et fonctions dans la
  [documentation ESOUI live](https://github.com/esoui/esoui/blob/f819c808d57e237707c76e7b52518e2589c9e191/ESOUIDocumentation.txt).
  Messages livrés en français, anglais et chinois ; version `0.32`
  dans Main.lua et WareGuild.addon, sans changement des dépendances.
- **Tests hors jeu** : huit fichiers compilés en Lua 5.1 et
  **376 assertions réussies** (92 + 284), en chargeant les fichiers
  effectivement livrés. Scénario de bâton de foudre en chêne de niveau 16
  (`itemId = 43559`) au slot 2456, guilde cible 44 simulant la troisième
  banque, ordres inversés des événements de chargement et de transfert,
  protections, critères du writ, erreurs, délais et fermeture/réouverture.

**Non testé dans ESO** : le cas réel signalé n'a pas été reproduit dans le
client. Les défauts de parcours et d'attente sont corrigés et couverts
par simulation ; cela ne prouve pas lequel explique le blocage observé.
Les nouveaux messages doivent permettre de préciser le diagnostic en jeu.

## 2026-11-13 - v0.31 (tri des objets du sac à dos)

- **Champ concerné** : « Sélectionner un objet du sac à dos pour créer
  des étapes », dans chacun des cinq menus de banque de guilde.
- **Ordre croissant** : qualité affichée d'abord, puis nom localisé
  formaté avec `SI_TOOLTIP_ITEM_NAME`, comparé sans tenir compte de la
  casse via `LocaleAwareToLower`. Le lien d'objet départage les noms et
  qualités identiques pour conserver un ordre déterministe.
- **Sélection conservée** : les choix restent les liens originaux ;
  les variantes ne sont pas fusionnées. Les liens en double sont
  toujours masqués, les slots vides ignorés et « / » reste en tête.
  Le même tri est recalculé par le bouton de rafraîchissement.
- **API vérifiées** : `GetItemLinkDisplayQuality`, `GetItemLinkName` et
  `LocaleAwareToLower` dans la
  [documentation ESOUI live](https://github.com/esoui/esoui/blob/f819c808d57e237707c76e7b52518e2589c9e191/ESOUIDocumentation.txt).
- **Version et manifeste** : version `0.31` dans Main.lua et
  WareGuild.addon ; AddOnVersion `20261113` inchangé.
- **Tests hors jeu** : huit fichiers compilés en Lua 5.1 et
  **318 assertions réussies**, dont 42 nouveaux contrôles sur les vrais
  menus : qualité prioritaire sur le nom, casse et suffixes grammaticaux,
  égalités, variantes, doublons, sac vide, sélection d'un lien et création
  de sa règle, ordre recalculé et sélection effacée au rafraîchissement.

**Non testé dans ESO** : les comparaisons et les callbacks du menu sont
simulés hors jeu ; le rendu et le classement des caractères accentués
restent à vérifier avec la langue du client.

## 2026-11-13 - v0.30 (ajustement du manifeste)

- **Nom du manifeste** : renommage de `WareGuild/WareGuild.txt` en
  `WareGuild/WareGuild.addon`, conformément au choix de format demandé
  pour cet addon compatible gamepad. L'ancien manifeste est supprimé,
  sans modifier l'ordre de chargement ni ajouter de restriction de mode.
- **Bibliothèques optionnelles** : la ligne devient
  `## OptionalDependsOn: LibLazyCrafting FCOItemSaver LibCharacterKnowledge`,
  sans contrainte de version. Les infobulles français, anglais et chinois
  sont alignées sur cette déclaration ; les vérifications d'API à
  l'exécution restent inchangées.
- **Vérifications hors jeu** : compilation des huit fichiers Lua en
  Lua 5.1, 276 assertions réussies et vérification de la présence des
  fichiers déclarés par le nouveau manifeste pour les langues livrées.
  Version `0.30` et AddOnVersion inchangés.

**Non testé dans ESO** : le chargement du manifeste et le mode gamepad
restent à valider dans le client.

## 2026-11-13 - v0.30 (dépôt des objets inconnus des autres personnages via LCK)

### Nouvelle règle

- **Destination par guilde** : bouton « Déposer les objets inconnus de mes
  autres personnages » dans chacun des cinq sous-menus de banque de guilde.
  Il ajoute une règle `WAREGUILD_STORE_UNKNOWN` (`Type = 23`) à cette banque
  uniquement, sans doublon si le bouton est pressé plusieurs fois. Aucun
  dépôt n'est activé par défaut.
- **Critère de connaissance** : au moins un autre personnage suivi du même
  compte, sur le serveur actuel, doit avoir l'état exact
  `LCK.KNOWLEDGE_UNKNOWN`. Le personnage connecté et les autres comptes
  importés sont exclus. Les réglages de suivi LCK sont respectés, sans
  forcer l'inclusion des personnages masqués. Un objet inconnu uniquement
  du personnage actif ne suffit pas.
- **Objets concernés** : tous les exemplaires non liés des recettes, plans
  de mobilier, motifs, grimoires et scripts que LCK reconnaît. Les
  équipements dotés d'un trait qu'un autre personnage doit encore
  rechercher sont aussi concernés via les API de recherche dédiées.
  Une recherche déjà en cours, même arrivée à terme sur un personnage
  déconnecté, ne réclame pas de nouvel exemplaire.
- **Absence de données** : `KNOWLEDGE_NODATA`, `KNOWLEDGE_INVALID`, liste
  vide ou bibliothèque non initialisée ne sont jamais interprétés comme
  « inconnu ». Les personnages doivent disposer de données enregistrées
  par LCK pour être pris en compte.

### Intégration et protections

- **Filtrage réel des slots** : `IsItemBound` exclut les objets liés, y
  compris les objets liés au compte. Sont aussi exclus les objets volés,
  verrouillés par le joueur et protégés par FCOItemSaver, sauf si l'option
  existante d'ignorance de FCOItemSaver est activée.
- **Regroupement et transferts** : les objets empilables réutilisent le
  regroupement banque/sac de la version 0.29. Les équipements non empilables
  utilisent la même transaction asynchrone sans retirer les équipements
  déjà en banque. Le filtre d'éligibilité accompagne la transaction afin
  de ne pas empiler ou déposer un exemplaire lié de lien identique ; les
  slots sont revérifiés avant l'exécution.
- **Règles existantes** : prise en charge de l'ouverture automatique, du
  libellé dans les étapes, de la copie des règles et du réglage
  `KeepCraft` qui suspend les dépôts pendant les commandes journalières.
- **Dépendance optionnelle** : `LibCharacterKnowledge>=301000` est ajouté
  à `OptionalDependsOn`. Sans bibliothèque compatible, le bouton est
  désactivé et une règle déjà enregistrée est ignorée avec un message dans
  le chat ; les autres fonctionnalités de WareGuild restent disponibles.
- **Langues et version** : libellés et aide en français, anglais et chinois ;
  version `0.30`, AddOnVersion `20261113`.

### API et tests

Contrat LCK vérifié dans la
[référence développeur LibCharacterKnowledge](http://eso.code65536.com/addons/libcharacterknowledge/) :
`GetItemKnowledgeList(itemLink, nil, nil, account)`,
`GetSmithingResearchFromItemLink` et
`GetSmithingResearchStatusForCharacters(craft, line, trait, nil, nil, account)`.
Les états de connaissance ne sont pas des booléens. Le paramètre serveur
omis désigne le serveur courant, et l'absence de `includedCharIds` préserve
les exclusions de suivi.

Signatures ESO vérifiées dans la
[documentation ESOUI live](https://github.com/esoui/esoui/blob/f819c808d57e237707c76e7b52518e2589c9e191/ESOUIDocumentation.txt) :
`IsItemBound`, `IsItemPlayerLocked`, `GetDisplayName` et
`GetCurrentCharacterId`.

Compilation des fichiers livrés en Lua 5.1 et **276 assertions hors jeu
réussies** : 92 tests historiques, 124 tests de dépôt/regroupement et 60
nouveaux contrôles LCK. Les tests chargent les vrais Data.lua, Main.lua et
Menu.lua, exécutent les boutons des cinq menus et les transferts différés.
Ils couvrent notamment le personnage actif, les comptes importés, les
données absentes, les recherches en cours, les doublons liés, les objets
protégés, le sac plein, l'absence de bibliothèque et les règles sauvegardées.

**Non testé dans ESO** : les états simulés ne remplacent pas la validation
avec les données réelles de LibCharacterKnowledge et la banque en jeu.

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

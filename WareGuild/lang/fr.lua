local WG = SDC_WareGuild

--[[
For translation, you have to copy this file and rename it in xx.lua, and translated the strings below. 
you can get the xx for your language by typing following line in game chat
/script d(GetCVar("language.2"))
]]

WG.Lang = {
  --Craft Type, No Need to Translate
  ["BLACKSMITH"] = GetString(SI_ITEMFILTERTYPE13),
  ["CLOTH"] = GetString(SI_ITEMFILTERTYPE14),
  ["ENCHANT"] = GetString(SI_ITEMFILTERTYPE17),
  ["ALCHEMY"] = GetString(SI_ITEMFILTERTYPE16),
  ["COOK"] = GetString(SI_ITEMFILTERTYPE18),
  ["WOOD"] = GetString(SI_ITEMFILTERTYPE15),
  ["JEWELRY"] = GetString(SI_ITEMFILTERTYPE25),
  
  ["STYLE"] = GetString(SI_ITEMFILTERTYPE19),
  ["TRAIT"] = GetString(SI_ITEMFILTERTYPE20),
  
  --Info Displayed in Chat Window, Need to Translate
  
  ["CHAT_FUZZY"] = " (correspondance approximative)", --Added to ItemName Matched by ItemId
  
  ["CHAT_TAKE_TO"] = "Garder <<1>> x <<2>>", -- <<1>> ItemName, <<2>> Quantity
  ["CHAT_TAKE_ALL"] = "Retirer tous les <<1>>", -- <<1>> ItemName
  
  ["CHAT_STORE_TO"] = "Garder <<1>> x <<2>>", -- <<1>> ItemName, <<2>> Quantity
  ["CHAT_STORE_ALL"] = "Déposer tous les <<1>>", -- <<1>> ItemName
  ["CHAT_STORE_UNKNOWN"] = "Déposer les objets non liés inconnus des autres personnages",
  ["CHAT_KNOWLEDGE_UNAVAILABLE"] = "Dépôt des connaissances ignoré : LibCharacterKnowledge absent ou incompatible.",
  ["GUILD_STORE_UNKNOWN"] = "Déposer les objets inconnus de mes autres personnages",
  ["GUILD_STORE_UNKNOWN_TOOLTIP"] = "Ajouter une règle de dépôt pour cette guilde. Déposer toutes les recettes, plans de mobilier, motifs, grimoires/scripts et équipements à rechercher non liés dont au moins un autre personnage suivi de votre compte, sur le serveur actuel, a besoin. Le personnage actif, les données absentes, les recherches en cours et les objets verrouillés, volés ou protégés sont exclus. Nécessite LibCharacterKnowledge. Les réglages de suivi et l'option de désactivation des dépôts pendant les commandes journalières s'appliquent.",
  ["CHAT_STORE_ALL_TYPE"] = "Déposer tous les matériaux <<1>>", -- <<1>> Craft Type
  
  ["CHAT_DAILY_WRITS"] = "Retirer les objets pour les commandes journalières",
  
  ["CHAT_NE_TAKE"] = "[<<1>>] Quantité insuffisante de <<2>> à retirer", -- <<1>> Guild Name, <<2>> ItemName
  ["CHAT_NE_STORE"] = "[<<1>>] Quantité insuffisante de <<2>> à déposer", -- <<1>> Guild Name, <<2>> ItemName
  
  ["CHAT_DONE"] = "Terminé !",
  ["CHAT_NO_WORK"] = "Rien à faire !",
  ["CHAT_STOP"] = "Arrêt !",
  ["CHAT_ERROR"] = "Une erreur s'est produite",
  
  ["CHAT_BACKBAG_FULL"] = "Sac à dos plein",
  ["CHAT_WITHDRAW_BLOCKED"] = "[<<1>>] Retrait impossible de <<2>> : <<3>>.",
  ["CHAT_WITHDRAW_FCOIS"] = "protection FCOItemSaver (FCOIS)",
  ["CHAT_WITHDRAW_LOCKED"] = "objet verrouillé par le joueur",
  ["CHAT_WITHDRAW_PERMISSION"] = "droits de retrait absents",
  ["CHAT_WITHDRAW_CHANGED"] = "objet déplacé ou modifié avant le retrait",
  ["CHAT_WITHDRAW_GUILD_CHANGED"] = "banque de guilde sélectionnée modifiée pendant le transfert",
  ["CHAT_WITHDRAW_ERROR"] = "erreur de transfert <<1>> : <<2>>",
  ["CHAT_WITHDRAW_TIMEOUT"] = "aucune confirmation après 10 secondes ; serveur ou autre addon susceptible de bloquer le transfert",
  ["CHAT_WITHDRAW_QUALITY"] = "qualité incompatible avec la commande journalière (qualité blanche requise)",
  ["CHAT_WITHDRAW_TRAIT"] = "trait incompatible avec la commande journalière (objet sans trait requis)",
  ["CHAT_WITHDRAW_LEVEL"] = "niveau incompatible : attendu <<1>> / PC <<2>>, trouvé <<3>> / PC <<4>>",
  ["CHAT_WITHDRAW_CONDITION"] = "objet non accepté par la condition du journal de quêtes",
  ["CHAT_WITHDRAW_NOTICE"] = "[<<1>>] <<2>> : <<3>>.",
  ["CHAT_WITHDRAW_REFERENCE"] = "niveau de craft de référence indisponible hors établi d'artisanat ; niveau exact non comparé, la condition du journal valide le palier du matériau",
  ["CHAT_WITHDRAW_DATA"] = "correspondance objet/matériau de craft absente des données WareGuild",
  ["CHAT_WITHDRAW_NOT_FOUND"] = "aucun exemplaire compatible trouvé dans cette banque ; vérifier la guilde choisie pour cette étape",
  ["CHAT_WITHDRAW_DISABLED"] = "option de récupération des objets finis désactivée ; recherche des matériaux à la place",
  ["CHAT_BANK_WAIT"] = "[<<1>>] Chargement de la banque de guilde en attente...",
  ["CHAT_BANK_TIMEOUT"] = "[<<1>>] Arrêt : chargement de la banque non confirmé après 20 secondes. Réouvrez la banque puis réessayez.",
  ["CHAT_BANK_ERROR"] = "[<<1>>] Ouverture de banque impossible : <<2>>",
  ["CHAT_STACK_TIMEOUT"] = "Empilement de <<1>> interrompu : aucune confirmation après 10 secondes ; serveur ou autre addon susceptible de bloquer le déplacement.",
  ["CHAT_GUILD_BANK_FULL"] = "Banque de guilde pleine",
  ["CHAT_REGROUP_NO_SPACE"] = "Regroupement de <<1>> ignoré : place insuffisante dans le sac à dos. Le dépôt habituel continue.",
  ["CHAT_REGROUP_SKIPPED"] = "Regroupement de <<1>> ignoré : droit de retrait absent ou contenu de banque modifié. Le dépôt continue.",
  ["CHAT_REGROUP_FAILED"] = "Transfert de <<1>> interrompu. Vérifiez les objets restants dans le sac à dos et en banque de guilde avant de relancer.",
  ["CHAT_REGROUP_MISMATCH"] = "Regroupement de <<1>> ignoré : la banque contient le même objet mais d'un autre niveau, qualité ou lien (sac : <<2>> niv <<3>> PC <<4>> qualité <<5>> ; banque : <<6>> niv <<7>> PC <<8>> qualité <<9>>).",
  ["CHAT_REGROUP_BORROW"] = "Regroupement de <<1>> : retrait de <<2>> pile(s) existante(s) de la banque (<<3>> au total) pour les empiler dans le sac à dos.",
  ["CHAT_REGROUP_DONE"] = "Regroupement de <<1>> terminé : <<2>> redéposé(s) en banque de guilde en une seule pile.",
  
  --Setting, Need to Translate
  
  ["SETTING_CHARACTER_CONFIG"] = "Configuration par personnage",
  ["SETTING_CHARACTER_CONFIG_TOOLTIP"] = "Par défaut, utilise la configuration du compte",
  
  ["SETTING_AUTO_OPEN_STORE"] = "Ouvrir automatiquement pour le stockage",
  ["SETTING_AUTO_OPEN_STORE_TOOLTIP"] = "Fonctionne uniquement quand WG trouve des objets à stocker.\r\nSans effet sur [Déposer jusqu'à x]", -- \r\n Line Feed
  
  ["SETTING_AUTO_OPEN_WRITS"] = "Ouvrir automatiquement pour les commandes journalières",
  ["SETTING_AUTO_OPEN_WRITS_TOOLTIP"] = "Fonctionne uniquement quand l'étape [Retirer pour commandes journalières] existe et que vous avez des commandes journalières",
  
  ["SETTING_AUTO_CLOSE"] = "Fermer automatiquement",
  ["SETTING_AUTO_CLOSE_TOOLTIP"] = "Fonctionne uniquement après que WG a réellement déplacé des objets",
  
  ["SETTING_STEPS_LOG"] = "Afficher le journal des opérations",
  ["SETTING_STEPS_LOG_TOOLTIP"] = "Affiche dans la fenêtre de discussion ce que WG a réellement fait à chaque étape",
  
  ["SETTING_BAN_STORE_WRITS"] = "Désactiver les dépôts si commandes journalières active",
  ["SETTING_BAN_STORE_WRITS_TOOLTIP"] = "Si vous utilisez les banques de guilde pour les commandes journalières, activez cette option",
  
  ["SETTING_IGNORE_INVENTORY"] = "[Retirer pour commandes journalières] Ignorer l'inventaire",
  ["SETTING_IGNORE_INVENTORY_TOOLTIP"] = "Quand activé, cette étape ignore les matériaux déjà présents dans votre sac à dos, votre banque personnelle et vos sacs d'artisanat pour fabriquer les productions requises. (Par exemple, 42 matériaux sont nécessaires et 30 sont déjà disponibles. Une fois activé, WG tentera de retirer 42 matériaux de la banque de guilde au lieu de 12)",
  
  ["SETTING_LAZYCRAFTING"] = "Utiliser la file d'attente LazyCrafting",
  ["SETTING_LAZYCRAFTING_TOOLTIP"] = "Quand activé, [Retirer pour commandes journalières] compte aussi les matériaux bruts (forge / couture / travail du bois) nécessaires aux objets en file d'attente dans LazyCrafting (LibLazyCrafting, utilisé par Lazy Writ Crafter et Lazy Set Crafter). Quand le même matériau est demandé à la fois par les commandes et par la file d'attente, seule la quantité la plus grande est retirée",

  ["SETTING_LAZYCRAFTING_PRODUCT"] = "Retirer les objets finis au lieu des matériaux",
  ["SETTING_LAZYCRAFTING_PRODUCT_TOOLTIP"] = "Quand activé, les objets à fabriquer (épée, casque, bâton, bouclier, glyphe, potion, nourriture...) sont d'abord recherchés dans votre sac à dos et les banques de guilde, aussi bien pour la file d'attente LazyCrafting que pour les commandes journalières de votre journal de quêtes : si l'objet fini s'y trouve déjà, il est retiré directement au lieu des matériaux bruts (la quantité de matériaux est réduite en conséquence). Les objets finis des commandes journalières sont appariés quel que soit le style, sans trait et de qualité blanche uniquement ; les demandes avec trait ou d'ensemble ne retirent que les matériaux. La joaillerie, l'enchantement, l'alchimie et la cuisine sont aussi pris en charge",

  ["SETTING_NE_TAKE"] = "En cas de quantité insuffisante, retirer le reste",
  ["SETTING_NE_TAKE_TOOLTIP"] = "Quand désactivé, les étapes de retrait sont ignorées en cas de manque d'objets",
  
  ["SETTING_NE_STORE"] = "En cas de quantité insuffisante, déposer le reste",
  ["SETTING_NE_STORE_TOOLTIP"] = "Quand désactivé, les étapes de dépôt sont complètement ignorées en cas de manque d'objets",
  
  ["SETTING_IGNORE_FCOIS"] = "Ignorer FCO ItemSaver",
  ["SETTING_IGNORE_FCOIS_TOOLTIP"] = "Ignore les restrictions de FCO ItemSaver sur le dépôt / le retrait d'objets de la banque de guilde",
  
  ["SETTING_HEADER_SELECT_GUILD"] = "Sélectionner les banques de guilde",
  ["SETTING_GUILD_TIPS"] = "Astuces :\r\nTraitement dans l'ordre, assurez-vous d'avoir accès aux banques de guilde\r\nL'interface doit être rechargée après avoir rejoint une nouvelle guilde", -- \r\n Line Feed
  
  ["GUILD_ITEM_SCROLL"] = "objet du sac à dos pour créer des étapes",
  
  ["GUILD_FUZZY"] = "Correspondance approximative",
  ["GUILD_FUZZY_TOOLTIP"] = "Correspondance par lien d'objet ou ItemId (mode approximatif). Activation déconseillée",
  
  ["GUILD_UPDATE_ITEM_LIST"] = "Mettre à jour la liste des objets",
  ["GUILD_TAKE_ALL"] = "Tout retirer",
  ["GUILD_STORE_ALL"] = "Tout déposer",
  
  ["GUILD_TAKE_TO_SLIDER"] = "Garder x ? objets dans le sac à dos",
  ["GUILD_TAKE_TO"] = "Retirer jusqu'à x",
  
  ["GUILD_STORE_TO_SLIDER"] = "Garder x ? objets dans la banque de guilde",
  ["GUILD_STORE_TO"] = "Déposer jusqu'à x",
  
  ["GUILD_STORE_ALL_TYPE_DROP"] = "Sélectionner le type de matériaux à déposer",
  ["GUILD_STORE_ALL_TYPE"] = "Déposer les matériaux d'artisanat",
  
  ["GUILD_TAKE_WRITS"] = "Retirer pour commandes journalières",
  ["GUILD_TAKE_WRITS_TOOLTIP"] = "Nécessite d'avoir accepté les commandes journalières au préalable !\nChaque guilde n'a besoin d'être ajoutée qu'une fois, les règles sont les suivantes :\nRetirer les matériaux bruts manquants pour la forge, la couture, le travail du bois, la joaillerie et l'enchantement\nRetirer les objets finis (blancs, sans trait, quel que soit le style) pour la forge, la couture, le travail du bois, la joaillerie et l'enchantement quand ils sont déjà en banque de guilde\nRetirer les objets finis pour la cuisine et l'alchimie\nRetirer les matériaux à remettre pour l'enchantement et l'alchimie\n*Les matériaux de style ne sont pas inclus",
  
  ["GUILD_HEADER_STEPS"] = "Étapes de fonctionnement",
  ["GUILD_STEPS_SLIDER"] = "Sélectionner la ligne de l'étape",
  ["GUILD_STEPS_EMPTY"] = "Étapes vides",
  ["GUILD_STEPS_DELETE"] = "Supprimer l'étape sélectionnée",
  
  ["CLIP"] = "Copier/Coller",
  ["CLIP_PASTE"] = "Coller",
  
  ["SETTING_BOTTOM_TIPS"] = "Il est recommandé de lire les instructions détaillées de WG sur ESOUI",
}

lang = "en";
Strings = {};
if ( Turbine.Shell.IsCommand("spielen") ) then
	lang = "de";
end
if ( Turbine.Shell.IsCommand("lire") ) then
	lang = "fr";
end
if ( lang == "en" ) then 
	Strings["cmd_music"] = "/music";
	Strings["cmd_play"] = "/play";
	Strings["cmd_ready"] = "/readycheck";
	Strings["cmd_start"] = "/playstart";
	Strings["cmd_sync"] = "sync";
	Strings["cmd_demo1_title"] = "Now playing";
	Strings["cmd_demo1_cmd"] = "/e is now playing %name";
	Strings["cmd_demo2_title"] = "Sync command to /f";
	Strings["cmd_demo2_cmd"] = "/f /play %file sync %part";
	Strings["cmd_demo3_title"] = "Paste filename";
	Strings["cmd_demo3_cmd"] = "/f %file";
	Strings["ui_dirs"] = "Directories";
	Strings["ui_songs"] = "Songs";
	Strings["ui_parts"] = "Parts";
	Strings["ui_instrs"] = "Instruments";
	Strings["ui_cmds"] = "Commands";
	Strings["ui_settings"] = "Settings";
	Strings["ui_search"] = "Search";
	Strings["ui_clear"] = "Clear";
	Strings["ui_general"] = "General settings";
	Strings["ui_custom"] = "Custom commands";
	Strings["ui_save"] = "Save";
	Strings["ui_ok"] = "Ok";
	Strings["ui_cancel"] = "Cancel";
	Strings["ui_icon"] = "Songbook button settings";
	Strings["ui_instr"] = "Instrument slots settings";
	Strings["cb_parts"] = "Song part list visible";
	Strings["cb_search"] = "Search enabled";
	Strings["cb_desc"] = "Show song list description";
	Strings["cb_descfirst"] = "In first";
	Strings["cb_windowvis"] = "Window visible on load";
	Strings["cb_iconvis"] = "Songbook button visible";
	Strings["cb_instrvis"] = "Show Instruments";
	Strings["cb_instrvisHForced"] = "Horizontal"; -- ZEDMOD
	Strings["ui_btn_opacity"] = "Songbook button opacity";
	-- Badgers
	Strings["title"] = ": The Badger Z Chapter";
	Strings["filters"] = "Filters";
	Strings["filterParts"] = "#Parts";
	Strings["filterArtist"] = "Artist";
	Strings["filterGenre"] = "Genre";
	Strings["filterMood"] = "Mood";
	Strings["filterAuthor"] = "Author";
	Strings["chat_playBegin"] = "playing is about to begin";
	Strings["chat_playBeginSelf"] = "You begin playing ";
	Strings["chat_playReadyMsg"] = "(%a+) is ready to play \"(.+).\".*";
	Strings["chat_playSelfReadyMsg"] = "You are ready to play \"(.+).\".*";
	Strings["chat_playerJoin"] = " has joined your";
	Strings["chat_playerJoinSelf"] = " have joined a"; -- ZEDMOD
	Strings["chat_playerLeave"] = " has left your";
	Strings["chat_playerLeaveSelf"] = " leave your"; -- ZEDMOD
	Strings["ui_badger"] = "Badger settings";
	Strings["cb_chief"] = "Chief mode";
	Strings["cb_timer"] = "Show timer";
	Strings["cb_timerDown"] = "Count down";
	Strings["cb_rdyCol"] = "Sync column";
	Strings["cb_rdyColHL"] = "Highlighting";
	Strings["instr"] = " required?";
	Strings["playerlist"] = "Players list"; -- ZEDMOD
	Strings["players"] = "Players";
	-- ZEDMOD: Add New Instruments ( Fiddle and Bassoon )
	-- doubling word fiddle because german got two word as fiedel and giese
	--aInstrumentsLoc = { "bagpipe", "clarinet", "cowbell", "drum", "flute", "harp", "horn", "lute", "pibgorn", "theorbo" }; -- Original
	aInstrumentsLoc = { "bagpipe", "bassoon", "clarinet", "cowbell", "drum", "fiddle", "fiddle", "flute", "harp", "horn", "lute", "pibgorn", "theorbo" };
	-- /ZEDMOD
	-- ZEDMOD: Additonnal Instruments to distinguish between basic and specifics
	aInstrumentsLocBassoon = { "basic bassoon", "lonely mountain bassoon", "brusque bassoon" };
	aInstrumentsLocFiddle = { "basic fiddle", "student's fiddle", "traveller's trusty fiddle", "sprightly fiddle", "lonely mountain fiddle", "bardic fiddle" };
	aInstrumentsLocHarp = { "basic harp", "misty mountain harp" };
	aInstrumentsLocLute = { "basic lute", "lute of ages" };
	aInstrumentsLocCowbell = { "basic cowbell", "moor cowbell"};
	-- /ZEDMOD
	-- /Badgers
	Strings["ui_clr_slots"] = "Clear slots";
	Strings["ui_add_slot"] = "Add";
	Strings["ui_del_slot"] = "Remove";
	Strings["ui_cus_add"] = "Add";
	Strings["ui_cus_edit"] = "Edit";
	Strings["ui_cus_del"] = "Remove";
	Strings["ui_cus_winadd"] = "Add Command";
	Strings["ui_cus_winedit"] = "Edit Command";
	Strings["ui_cus_title"] = "Title:";
	Strings["ui_cus_command"] = "Command:";
	Strings["ui_cus_help"] = "Command aliases:\n\n%name - song/part name\n%file - filename\n%part - part number";
	Strings["ui_cus_err"] = "Please enter Title and Command";
	Strings["tt_music"] = "Toggle music mode";
	Strings["tt_play"] = "Play song";
	Strings["tt_ready"] = "Make a ready check";
	Strings["tt_sync"] = "Play with sync";
	Strings["tt_start"] = "Start sync play";
	Strings["tt_parts"] = "Parts display on/off";
	Strings["sh_saved"] = "Songbook settings saved.";
	Strings["sh_notsaved"] = "Songbook failed to save settings";
	Strings["sh_show"] = "show";
	Strings["sh_hide"] = "hide";
	Strings["sh_toggle"] = "toggle";
	Strings["sh_help1"] = gPlugin .. " show: Display Songbook Window";
	Strings["sh_help2"] = gPlugin .. " hide: Hide Songbook Window";
	Strings["sh_help3"] = gPlugin .. " toggle: Toggle Songbook Window";
	Strings["err_nosongs"] = "The song library is empty. Make sure you have abc files in your Music directory and run the songbook.hta file to build the library. Then, reload the plugin.\n\nIf you upgraded from a previous version, run first the new songbook.hta before loading the plugin.";
elseif ( lang == "de" ) then
	--Turbine.Shell.WriteLine("2. SongbookLang.lua : lang = de");
	Strings["cmd_music"] = "/musik";
	Strings["cmd_play"] = "/spielen";
	Strings["cmd_ready"] = "/bereitschaftspr�fung";
	Strings["cmd_start"] = "/spielstart";
	Strings["cmd_sync"] = "sync";
	Strings["cmd_e"] = "/e";
	Strings["cmd_f"] = "/g";
	Strings["cmd_demo1_title"] = "Emote mit dem Liedtitel";
	Strings["cmd_demo1_cmd"] = "/e spielt %name";
	Strings["cmd_demo2_title"] = "Sync-Befehl an Gruppe senden";
	Strings["cmd_demo2_cmd"] = "/g /spielen %file sync %part";
	Strings["cmd_demo3_title"] = "Dateiname an Gruppe senden";
	Strings["cmd_demo3_cmd"] = "/g %file";
	Strings["ui_dirs"] = "Verzeichnisse";
	Strings["ui_songs"] = "Lieder";
	Strings["ui_parts"] = "Teile";
	Strings["ui_instrs"] = "Instrumenten";
	Strings["ui_cmds"] = "Befehle";
	Strings["ui_settings"] = "Einstellungen";
	Strings["ui_search"] = "Suchen";
	Strings["ui_clear"] = "Leeren";
	Strings["ui_general"] = "Allgemeine Einstellungen";
	Strings["ui_custom"] = "Benutzerdefinierte Befehle";
	Strings["ui_save"] = "Speichern";
	Strings["ui_ok"] = "Ok";
	Strings["ui_cancel"] = "Abbrechen";
	Strings["ui_icon"] = "Songbookknopf Einstellungen";
	Strings["ui_instr"] = "Instrumentenleiste Einstellungen";
	Strings["cb_parts"] = "Liste mit Liedteilen anzeigen";
	Strings["cb_search"] = "Suche erlauben";
	Strings["cb_desc"] = "Beschreibung Liedliste anzeigen";
	Strings["cb_descfirst"] = "Zuerst";
	Strings["cb_windowvis"] = "Fenster beim Start anzeigen";
	Strings["cb_iconvis"] = "Songbookknopf anzeigen";
	Strings["cb_instrvis"] = "Instrumente anzeigen";
	Strings["cb_instrvisHForced"] = "Horizontale"; -- ZEDMOD
	Strings["ui_btn_opacity"] = "Songbookknopf Sichtbarkeit";
	-- Badgers
	Strings["title"] = ": Das Z Badger-Kapitel";
	Strings["filters"] = "Filter";
	Strings["filterParts"] = "#Spieler";
	Strings["filterArtist"] = "K\195\188nstler";
	Strings["filterGenre"] = "Genre";
	Strings["filterMood"] = "Stimmung";
	Strings["filterAuthor"] = "Autor";
	Strings["chat_playBegin"] = "Synchronisiertes Spiel beginnt bald.";
	Strings["chat_playBeginSelf"] = "Du spielst ";
	Strings["chat_playReadyMsg"] = "(%a+) ist bereit \"(.+)\" zu spielen";
	Strings["chat_playSelfReadyMsg"] = "\"(.+)\" kann nun gespielt werden";
	Strings["chat_playerJoin"] = " hat sich Eure";
	Strings["chat_playerJoinSelf"] = " habt Euch einer Gruppe"; -- ZEDMOD
	Strings["chat_playerLeave"] = " hat Eure";
	Strings["chat_playerLeaveSelf"] = " verlasst Eure Gruppe"; -- ZEDMOD
	Strings["ui_badger"] = "Badger-Einstellungen";
	Strings["cb_chief"] = "Bandleader";
	Strings["cb_timer"] = "Laufzeit";
	Strings["cb_timerDown"] = "R\195\188ckw\195\164rts";
	Strings["cb_rdyCol"] = "Sync-Spalte";
	Strings["cb_rdyColHL"] = "Sync-Hervorhebung";
	Strings["instr"] = " ben\195\182tigt?";
	Strings["playerlist"] = "Spielerliste"; -- ZEDMOD
	Strings["players"] = "Spieler";
	-- ZEDMOD: Add New Instruments ( Fiddle and Bassoon )
	--aInstrumentsLoc = { "dudelsack", "klarinette", "glocke", "trommel", "fl\195\182te", "harfe", "horn", "laute", "pibgorn", "theorbe" }; -- Original
	aInstrumentsLoc = { "dudelsack", "fagott", "klarinette", "glocke", "trommel", "fiedel", "geige", "flote", "harfe", "horn", "laute", "pibgorn", "theorbe" };
	-- /ZEDMOD
	-- ZEDMOD: Additonnal Instruments to distinguish between basic and specifics
	aInstrumentsLocBassoon = { "standard-fagott", "fagott vom einsamen berg", "schroffes fagott" };
	aInstrumentsLocFiddle = { "standard-fiedel", "schulerfiedel", "geige des reisenden", "muntere geige", "geige vom einsamen berg", "barden geige" };
	aInstrumentsLocHarp = { "standard-harfe", "harfe des nebelgebirges" };
	aInstrumentsLocLute = { "standard-laute", "laute vergangener zeiten" };
	aInstrumentsLocCowbell = { "standard-glocke", "moorkuh glocke "};
	-- /ZEDMOD
	-- /Badgers
	Strings["ui_clr_slots"] = "Leiste leeren";
	Strings["ui_add_slot"] = "Hinzuf\195\188gen";
	Strings["ui_del_slot"] = "Entfernen";
	Strings["ui_cus_add"] = "Hinzuf\195\188gen";
	Strings["ui_cus_edit"] = "Editieren";
	Strings["ui_cus_del"] = "Entfernen";
	Strings["ui_cus_winadd"] = "Befehl einf\195\188gen";
	Strings["ui_cus_winedit"] = "Befehl editieren";
	Strings["ui_cus_title"] = "Titel:";
	Strings["ui_cus_command"] = "Befehl:";
	Strings["ui_cus_help"] = "Befehl aliase:\n\n%name - Lied/Liedteilname\n%file - Dateiname\n%part - Liedteilnummer";
	Strings["ui_cus_err"] = "Bitte Titel und Befehl eingeben";
	Strings["tt_music"] = "Musikmodusschalter";
	Strings["tt_play"] = "Lied abspielen";
	Strings["tt_ready"] = "Bereitschaftskontrolle";
	Strings["tt_sync"] = "Spielen mit sync";
	Strings["tt_start"] = "Spielstart";
	Strings["tt_parts"] = "Teile anzeigen an/aus";
	Strings["sh_saved"] = "Songbookeinstellungen gesichert.";
	Strings["sh_notsaved"] = "Songbook konnte die Einstellungen nicht sichern";
	Strings["sh_show"] = "anzeigen";
	Strings["sh_hide"] = "verstecken";
	Strings["sh_toggle"] = "umschalten";
	Strings["sh_help1"] = gPlugin .. " anzeigen: Songbookfenster anzeigen";
	Strings["sh_help2"] = gPlugin .. " verstecken: Songbookfenster verstecken";
	Strings["sh_help3"] = gPlugin .. " umschalten: Songbookfenster ein/aus";
	Strings["err_nosongs"] = "Keine Lieder gefunden. Du musst im '/music'-Ordner ABC-Dateien haben und mindestens einmal die songbook.hta ausf\195\188hren. Danach bitte Plugin neu laden.\n\nBei neuer Version des Plugins, starte die neue songbook.hta um die Datenbank neu zu erstellen.";
elseif ( lang == "fr" ) then
	--Turbine.Shell.WriteLine("2. SongbookLang.lua : lang = fr");
	Strings["cmd_music"] = "/musique";
	Strings["cmd_play"] = "/lire";
	Strings["cmd_ready"] = "/voirpr�t";
	Strings["cmd_start"] = "/d�butmusique";
	Strings["cmd_sync"] = "synchro";
	Strings["cmd_e"] = "/e";
	Strings["cmd_f"] = "/f";
	Strings["cmd_demo1_title"] = "Jou\195\169 actuellement";
	Strings["cmd_demo1_cmd"] = "/e joue actuellement %name";
	Strings["cmd_demo2_title"] = "Commande synchro vers /comm";
	Strings["cmd_demo2_cmd"] = "/comm /lire %file sync %part";
	Strings["cmd_demo3_title"] = "Coller nom du fichier";
	Strings["cmd_demo3_cmd"] = "/comm %file";
	Strings["ui_dirs"] = "R\195\169pertoires";
	Strings["ui_songs"] = "Chansons";
	Strings["ui_parts"] = "Partitions";
	Strings["ui_instrs"] = "Instruments";
	Strings["ui_cmds"] = "Commandes";
	Strings["ui_settings"] = "Param\195\168tres";
	Strings["ui_search"] = "Recherche";
	Strings["ui_clear"] = "Vider";
	Strings["ui_general"] = "Param\195\168tres G\195\169n\195\169raux";
	Strings["ui_custom"] = "Commandes Perso";
	Strings["ui_save"] = "Sauver";
	Strings["ui_ok"] = "Ok";
	Strings["ui_cancel"] = "Annuler";
	Strings["ui_icon"] = "Param\195\168tres Bouton SongBook";
	Strings["ui_instr"] = "Param\195\168tres Liste Instruments";
	Strings["cb_parts"] = "Liste Partitions Visible";
	Strings["cb_search"] = "Recherche activ\195\169e";
	Strings["cb_desc"] = "Description liste chansons";
	Strings["cb_descfirst"] = "En premier";
	Strings["cb_windowvis"] = "Fen\195\170tre visible au chargement";
	Strings["cb_iconvis"] = "Bouton SongBook visible";
	Strings["cb_instrvis"] = "Instruments Visibles";
	Strings["cb_instrvisHForced"] = "Horizontal"; -- ZEDMOD
	Strings["ui_btn_opacity"] = "Opacit\195\169 du bouton Songbook";
	-- Badgers
	Strings["title"] = ": The Badger Z Chapter";
	Strings["filters"] = "Filtres";
	Strings["filterParts"] = "#Joueurs";
	Strings["filterArtist"] = "Artiste";
	Strings["filterGenre"] = "Style";
	Strings["filterMood"] = "Ambiance";
	Strings["filterAuthor"] = "Auteur";
	Strings["chat_playBegin"] = "La lecture synchronis\195\169e va commencer";
	Strings["chat_playBeginSelf"] = "Vous commencez � jouer ";
	Strings["chat_playReadyMsg"] = "(%a+) va jouer \"(.+).\".*";
	Strings["chat_playSelfReadyMsg"] = "Vous allez jouer \"(.+).\".*";
	Strings["chat_playerJoin"] = " a rejoint votre ";
	Strings["chat_playerJoinSelf"] = " avez rejoint une"; -- ZEDMOD
	Strings["chat_playerLeave"] = " a quitt\195\169 votre ";
	Strings["chat_playerLeaveSelf"] = " quittez votre "; -- ZEDMOD
	Strings["ui_badger"] = "Param\195\168tres Badger";
	Strings["cb_chief"] = "Mode Chef";
	Strings["cb_timer"] = "Voir compteur";
	Strings["cb_timerDown"] = "D\195\169compter";
	Strings["cb_rdyCol"] = "Colonne Synch"; -- Note: This needs to be rather short (two checkboxes on the same line)
	Strings["cb_rdyColHL"] = "Surbrillance";
	Strings["instr"] = " requis?";
	Strings["playerlist"] = "Liste Musiciens"; -- ZEDMOD
	Strings["players"] = "Musiciens";
	-- ZEDMOD: Add New Instruments ( Fiddle and Bassoon )
	-- doubling word violon because german got two word as fiedel and giese
	-- aInstrumentsLoc = { "cornemuse", "clarinette", "cloche de vache", "tambour", "fl\195\187t", "harpe", "cor", "luth", "pibgorn", "th\195\169orbe" }; -- Original
	aInstrumentsLoc = { "cornemuse", "basson", "clarinette", "cloche", "tambour", "violon", "violon", "flute", "harpe", "cor", "luth", "pibgorn", "theorbe" };
	-- /ZEDMOD
	-- ZEDMOD: Additonnal Instruments to distinguish between basic and specifics
	aInstrumentsLocBassoon = { "basson de base", "basson du mont solitaire", "basson brusque" };
	aInstrumentsLocFiddle = { "violon de base", "violon d'etudiant", "fidele violon de voyageur", "violon alerte", "violon du mont solitaire", "violon de barde" };
	aInstrumentsLocHarp = { "harpe de base", "harpe du mont brumeux" };
	aInstrumentsLocLute = { "luth de base", "luth des siecles" };
	aInstrumentsLocCowbell = { "cloche de vache de base", "cloche de vache des landes"};
	-- /ZEDMOD
	-- /Badgers
	Strings["ui_clr_slots"] = "Vider";
	Strings["ui_add_slot"] = "Ajouter";
	Strings["ui_del_slot"] = "Retirer";
	Strings["ui_cus_add"] = "Ajouter";
	Strings["ui_cus_edit"] = "Editer";
	Strings["ui_cus_del"] = "Retirer";
	Strings["ui_cus_winadd"] = "Ajouter Commande";
	Strings["ui_cus_winedit"] = "Editer Commande";
	Strings["ui_cus_title"] = "Nom:";
	Strings["ui_cus_command"] = "Commande:";
	Strings["ui_cus_help"] = "Variables de commande:\n\n%name - Nom du morceau\n%file - Fichier\n%part - Num\195\169ro de la partition";
	Strings["ui_cus_err"] = "Veuillez entrer un Nom et une Commande";
	Strings["tt_music"] = "Passe en mode Musique";
	Strings["tt_play"] = "Jouer la chanson";
	Strings["tt_ready"] = "Faire un appel";
	Strings["tt_sync"] = "Jouer en mode Synchro";
	Strings["tt_start"] = "D\195\169buter le jeu synchro";
	Strings["tt_parts"] = "Montrer/Cacher les partitions";
	Strings["sh_saved"] = "Param\195\168tres Songbook sauvegard\195\169s";
	Strings["sh_notsaved"] = "Echec de la sauvegarde des param\195\168tres de Songbook";
	Strings["sh_show"] = "afficher";
	Strings["sh_hide"] = "cacher";
	Strings["sh_toggle"] = "basculer";
	Strings["sh_help1"] = gPlugin .. " afficher: Afficher l'interface de SongBook";
	Strings["sh_help2"] = gPlugin .. " cacher: Cacher l'interface de SongBook";
	Strings["sh_help3"] = gPlugin .. " basculer: Basculer entre visible et cach\195\169";
	Strings["err_nosongs"] = "Le livre de chansons est vide. V\195\169rifiez que vous avez des fichiers pr\195\169sents dans le r\195\169pertoire \music et executer le fichier songbook.hta (pr\195\169sent dans le r\195\169pertoire du plugin) pour g\195\169n\195\169rer la liste des chansons. Ensuite, recharger le plugin. \n\n Si vous avez mis \195\160 jour depuis une version pr\195\169c\195\169dente, ex\195\169cuter en premier le songbook.hta avant de charger le plugin.";
end
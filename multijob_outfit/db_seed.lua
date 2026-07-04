-- ============================================================
-- db_seed.lua – EINMALIGE Migrationsdaten (Legacy config.lua)
-- ============================================================
-- Dieser komplette Inhalt stammt 1:1 aus der alten config.lua, in der
-- Outfits/JobPeds/AllowedJobs noch hart im Script hinterlegt waren.
--
-- Diese Datei wird NUR beim allerersten Start nach dem Umstieg auf die
-- Datenbank benutzt (server.lua prueft: sind die DB-Tabellen leer? Falls ja,
-- werden die Daten hier importiert). Danach ist ausschliesslich die
-- Datenbank die Quelle der Wahrheit - diese Datei hat dann keinen Effekt
-- mehr und kann gefahrlos geloescht werden.
--
-- WICHTIG: Diese Datei ist bewusst NICHT in fxmanifest.lua eingebunden,
-- sondern wird per LoadResourceFile()+load() nur serverseitig zur
-- Migrationszeit eingelesen. Sie laeuft NIE auf dem Client.

local M = {}

M.AllowedJobs = {
    fire = true,
    police = true,
    ambulance = true,
    bka = true,
    uke = true,
    -- ils/mechanic/stadtwerke sind aktuell nur Platzhalter: Clothes({}) ohne echte
    -- Kleidungsdaten und ohne Default-Ped in Config.JobPeds. Aktiviert würden
    -- Spieler Outfits sehen, die beim Anklicken nur eine Fehlermeldung auslösen.
    -- Erst auf true setzen, wenn echte Kleidungsdaten + ein JobPeds-Eintrag existieren.
    ils = false,
    mechanic = false,
    stadtwerke = false
}

M.JobPeds = {
    fire = {
        enabled = true,
        model = 's_m_y_fireman_01',
        coords = { x = 1200.50, y = -1475.25, z = 34.85, w = 90.0 },
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        label = '[E] Feuerwehr Outfit-Menü öffnen'
    },

    police = {
        enabled = true,
        model = 's_m_y_cop_01',
        coords = { x = 441.20, y = -981.90, z = 30.69, w = 90.0 },
        scenario = 'WORLD_HUMAN_COP_IDLES',
        label = '[E] Police Outfit-Menü öffnen'
    },

    ambulance = {
        enabled = true,
        model = 's_m_m_paramedic_01',
        coords = { x = 306.30, y = -601.75, z = 43.28, w = 70.0 },
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        label = '[E] Ambulance Outfit-Menü öffnen'
    },

    bka = {
        enabled = true,
        model = 's_m_m_fibsec_01',
        coords = { x = 136.20, y = -761.80, z = 45.75, w = 160.0 },
        scenario = 'WORLD_HUMAN_GUARD_STAND',
        label = '[E] BKA Outfit-Menü öffnen'
    },

    uke = {
        enabled = true,
        model = 's_m_m_doctor_01',
        coords = { x = 339.50, y = -1394.10, z = 32.51, w = 50.0 },
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        label = '[E] UKE Outfit-Menü öffnen'
    }
}

local function Clothes(data)
    return data
end

M.Outfits = {
    fire = {
        [0] = {
                    {
                        label = 'Praktikant',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 65, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 38, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 59, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 38, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BMA Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 55, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 48, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 34, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [1] = {
                    {
                        label = 'Brandmeister-Anwärter',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [2] = {
                    {
                        label = 'Brandmeister',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [3] = {
                    {
                        label = 'Oberbrandmeister',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [4] = {
                    {
                        label = 'Hauptbrandmeister',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [5] = {
                    {
                        label = 'Brandinspektor-Anwärter',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [6] = {
                    {
                        label = 'Brandinspektor',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [7] = {
                    {
                        label = 'Brandoberinspektor',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [8] = {
                    {
                        label = 'Brandamtmann',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [9] = {
                    {
                        label = 'Brandoberamtmann',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [10] = {
                    {
                        label = 'Brandoberamtsrat',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [11] = {
                    {
                        label = 'Brandreferendar',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [12] = {
                    {
                        label = 'Brandrat',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [13] = {
                    {
                        label = 'Oberbrandrat',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [14] = {
                    {
                        label = 'Branddirektor',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [15] = {
                    {
                        label = 'Leitender Branddirektor',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [16] = {
                    {
                        label = 'Direktor der Berufsfeuerwehr',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 66, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 60, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 39, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'BM Wachkleidung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 56, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 36, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                }
    },

    police = {
        [0] = {
                    {
                        label = 'Streife Kurzarm',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'Streife Langarm',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 200, torso_2 = 3,
                            arms = 31,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'Streife Poloshirt',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 222, torso_2 = 0,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    },
        
                    {
                        label = 'Wache Innendienst',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 200, torso_2 = 3,
                            arms = 31,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [1] = {
                    {
                        label = 'Polizeimeister/in',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [2] = {
                    {
                        label = 'Polizeiobermeister/in',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [3] = {
                    {
                        label = 'Polizeihauptmeister/in',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [4] = {
                    {
                        label = 'Polizeihauptmeister/in MAZ',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [5] = {
                    {
                        label = 'Erste(r) Polizeihauptmeister/in',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [6] = {
                    {
                        label = 'Polizeikommissaranwärter/in',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [7] = {
                    {
                        label = 'Polizeikommissar/in',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [8] = {
                    {
                        label = 'Polizeioberkommissar/in',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [9] = {
                    {
                        label = 'Polizeihauptkommissar/in A11',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [10] = {
                    {
                        label = 'Polizeihauptkommissar/in A12',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [11] = {
                    {
                        label = 'Erste(r) Polizeihauptkommissar/in',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [12] = {
                    {
                        label = 'Polizeiratsanwärter/in',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [13] = {
                    {
                        label = 'Polizeirat/rätin',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [14] = {
                    {
                        label = 'Polizeioberrat/rätin',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [15] = {
                    {
                        label = 'Polizeidirektor/in',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [16] = {
                    {
                        label = 'Leitende(r) Polizeidirektor/in',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [17] = {
                    {
                        label = 'Leitende(r) Polizeidirektor/in B2',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [18] = {
                    {
                        label = 'Leitende(r) Polizeidirektor/in B3',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [19] = {
                    {
                        label = 'Landespolizeivizepräsident',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [20] = {
                    {
                        label = 'Landespolizeipräsident',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = 143, helmet_2 = 0,
                            tshirt_1 = 37, tshirt_2 = 0,
                            torso_1 = 190, torso_2 = 3,
                            arms = 30,
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 17, bproof_2 = 3,
                            chain_1 = 50, chain_2 = 0,
                            bags_1 = 57, bags_2 = 0,
                            pants_1 = 84, pants_2 = 2,
                            shoes_1 = 49, shoes_2 = 1,
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 49, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 35, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                }
    },

    ambulance = {
        [0] = {
                    {
                        label = 'Praktikant',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 250, torso_2 = 0,
                            arms = 85,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 96, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 258, torso_2 = 0,
                            arms = 101,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 99, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [1] = {
                    {
                        label = 'Azubi zum Sanitätshelfer',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 251, torso_2 = 0,
                            arms = 85,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 96, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 259, torso_2 = 0,
                            arms = 101,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 99, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [2] = {
                    {
                        label = 'Sanitätshelfer',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 251, torso_2 = 0,
                            arms = 85,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 96, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 259, torso_2 = 0,
                            arms = 101,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 99, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [3] = {
                    {
                        label = 'Azubi zum Rettungssanitäter',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 251, torso_2 = 0,
                            arms = 85,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 96, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 259, torso_2 = 0,
                            arms = 101,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 99, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [4] = {
                    {
                        label = 'Rettungssanitäter',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 251, torso_2 = 0,
                            arms = 85,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 96, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 259, torso_2 = 0,
                            arms = 101,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 99, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [5] = {
                    {
                        label = 'Azubi zum Notfallsanitäter',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 251, torso_2 = 0,
                            arms = 85,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 96, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 259, torso_2 = 0,
                            arms = 101,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 99, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [6] = {
                    {
                        label = 'Notfallsanitäter',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 251, torso_2 = 0,
                            arms = 85,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 96, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 259, torso_2 = 0,
                            arms = 101,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 99, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [7] = {
                    {
                        label = 'Medizinstudent',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 251, torso_2 = 0,
                            arms = 85,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 96, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 259, torso_2 = 0,
                            arms = 101,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 99, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [8] = {
                    {
                        label = 'Organisatorischer Leiter Rettungsdienst',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 251, torso_2 = 0,
                            arms = 85,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 96, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 259, torso_2 = 0,
                            arms = 101,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 99, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [9] = {
                    {
                        label = 'Notarzt',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 251, torso_2 = 0,
                            arms = 85,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 96, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 259, torso_2 = 0,
                            arms = 101,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 99, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [10] = {
                    {
                        label = 'Leitender Notarzt',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 251, torso_2 = 0,
                            arms = 85,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 96, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 259, torso_2 = 0,
                            arms = 101,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 99, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [11] = {
                    {
                        label = 'Ärztlicher Leiter Rettungsdienst',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 251, torso_2 = 0,
                            arms = 85,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 96, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 259, torso_2 = 0,
                            arms = 101,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 99, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                }
    },

    bka = {
        [0] = {
                    {
                        label = 'BKA-Anwärter',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 31, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 24, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 25, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 23, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [1] = {
                    {
                        label = 'Kriminalassistent',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [2] = {
                    {
                        label = 'Kriminaloberassistent',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [3] = {
                    {
                        label = 'Kriminalsekretär',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [4] = {
                    {
                        label = 'Kriminalobersekretär',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [5] = {
                    {
                        label = 'Kriminalhauptsekretär',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [6] = {
                    {
                        label = 'Kriminalkommissar',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [7] = {
                    {
                        label = 'Kriminaloberkommissar',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [8] = {
                    {
                        label = 'Kriminalhauptkommissar',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [9] = {
                    {
                        label = 'Erster Kriminalhauptkommissar',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [10] = {
                    {
                        label = 'Kriminalrat',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [11] = {
                    {
                        label = 'Kriminaloberrat',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [12] = {
                    {
                        label = 'Kriminaldirektor',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [13] = {
                    {
                        label = 'Leitender Kriminaldirektor',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [14] = {
                    {
                        label = 'Stv. BKA-Leitung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [15] = {
                    {
                        label = 'BKA-Leitung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 0,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 0,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 15, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 0,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                }
    },

    uke = {
        [0] = {
                    {
                        label = 'Praktikant',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 32, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 24, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 26, torso_2 = 0,
                            arms = 0,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 23, pants_2 = 0,
                            shoes_1 = 10, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [1] = {
                    {
                        label = 'Azubi',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 1,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 1,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [2] = {
                    {
                        label = 'Pfleger',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 1,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 1,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [3] = {
                    {
                        label = 'Krankenschwester',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 1,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 1,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [4] = {
                    {
                        label = 'Assistent Arzt',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 1,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 1,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [5] = {
                    {
                        label = 'Arzt Chirugie',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 1,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 1,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [6] = {
                    {
                        label = 'Arzt Allg. Medizin',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 1,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 1,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [7] = {
                    {
                        label = 'Arzt Änistiesist',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 1,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 1,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [8] = {
                    {
                        label = 'Arzt / Notarzt',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 1,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 1,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [9] = {
                    {
                        label = 'Oberarzt',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 1,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 1,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [10] = {
                    {
                        label = 'Facharzt',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 1,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 1,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [11] = {
                    {
                        label = 'Chefarzt',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 1,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 1,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [12] = {
                    {
                        label = 'Ärtzlicher Direktor',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 1,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 1,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                },
        [13] = {
                    {
                        label = 'Geschäftsführung',
        
                        male = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 53, torso_2 = 1,
                            arms = 17,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 31, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        }),
        
                        female = Clothes({
                            mask_1 = 0, mask_2 = 0,
                            helmet_1 = -1, helmet_2 = 0,
                            glasses_1 = 0, glasses_2 = 0,
                            ears_1 = -1, ears_2 = 0,
        
                            tshirt_1 = 15, tshirt_2 = 0,
                            torso_1 = 46, torso_2 = 1,
                            arms = 18,
        
                            decals_1 = 0, decals_2 = 0,
                            bproof_1 = 0, bproof_2 = 0,
                            chain_1 = 0, chain_2 = 0,
                            bags_1 = 0, bags_2 = 0,
        
                            pants_1 = 30, pants_2 = 1,
                            shoes_1 = 25, shoes_2 = 0,
        
                            watches_1 = -1, watches_2 = 0,
                            bracelets_1 = -1, bracelets_2 = 0
                        })
                    }
                }
    },

    ils = {
        [0] = {
                    {
                        label = 'Praktikant',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [1] = {
                    {
                        label = 'Aushilfe',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [2] = {
                    {
                        label = 'Auszubildener Disponent',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [3] = {
                    {
                        label = 'Disponent',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [4] = {
                    {
                        label = 'Praxisanleiter',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [5] = {
                    {
                        label = 'Ausbilder',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [6] = {
                    {
                        label = 'Personalabteilung',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [7] = {
                    {
                        label = 'Personalabteilung Leitung',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [8] = {
                    {
                        label = 'Stv. Geschäftsführung',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [9] = {
                    {
                        label = 'Geschäftsführung',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                }
    },

    mechanic = {
        [0] = {
                    {
                        label = 'Praktikant',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [1] = {
                    {
                        label = 'Einarbeiter',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [2] = {
                    {
                        label = 'Lehrling',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [3] = {
                    {
                        label = 'Jung Geselle',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [4] = {
                    {
                        label = 'Alt Geselle',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [5] = {
                    {
                        label = 'Werkstattsleiter/in',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [6] = {
                    {
                        label = 'Ausbilder',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [7] = {
                    {
                        label = 'Stv. Ausbildungsleitung',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [8] = {
                    {
                        label = 'Ausbildungsleitung',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [9] = {
                    {
                        label = 'Personalabteilung',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [10] = {
                    {
                        label = 'Leitung Personlabteilung',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [11] = {
                    {
                        label = 'Stv. Geschäftsführung',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [12] = {
                    {
                        label = 'Geschäftsführerung',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                }
    },

    stadtwerke = {
        [0] = {
                    {
                        label = 'VSBT︱Azubi/in',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [1] = {
                    {
                        label = 'VSBT︱Busfahrer/in',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [2] = {
                    {
                        label = 'VSBT︱Meister Busfahrer',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [3] = {
                    {
                        label = 'VSBT︱Berufskraftfahrer/in',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [4] = {
                    {
                        label = 'SW︱Auszubildender',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [5] = {
                    {
                        label = 'SW︱Straßenanwärter/in',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [6] = {
                    {
                        label = 'SW︱Straßenwärter/in',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [7] = {
                    {
                        label = 'SW︱Straßenmeister/in',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [8] = {
                    {
                        label = 'SW︱Ausbilder',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [9] = {
                    {
                        label = 'SW︱Bauingenieur/ Bauingenieurin',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [10] = {
                    {
                        label = 'SW︱Dienstaufsicht',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [11] = {
                    {
                        label = 'SW︱Personalabteilung',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [12] = {
                    {
                        label = 'SW︱Stv. Teamleiter',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [13] = {
                    {
                        label = 'SW︱Teamleiter',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [14] = {
                    {
                        label = 'SW︱Vorstandsvorsitzende',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [15] = {
                    {
                        label = 'SW︱Stv. Geschäftsführer',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                },
        [16] = {
                    {
                        label = 'SW︱Geschäftsführer',
                        male = Clothes({}),
                        female = Clothes({})
                    }
                }
    }
}

return M

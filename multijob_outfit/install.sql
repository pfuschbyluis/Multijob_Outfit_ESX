-- ============================================================
-- multijob_outfit – Datenbank-Schema
-- ============================================================
-- Diese Tabellen werden vom Script beim ersten Start automatisch
-- angelegt (CREATE TABLE IF NOT EXISTS), falls sie noch nicht existieren.
-- Diese Datei ist nur als Referenz / für manuellen Import gedacht,
-- falls du sie lieber vorab selbst per phpMyAdmin/HeidiSQL einspielst.

CREATE TABLE IF NOT EXISTS `multijob_outfit_jobs` (
    `job_name` VARCHAR(50) NOT NULL,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`job_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `multijob_outfit_peds` (
    `job_name` VARCHAR(50) NOT NULL,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    `model` VARCHAR(100) NOT NULL DEFAULT '',
    `coord_x` FLOAT NOT NULL DEFAULT 0,
    `coord_y` FLOAT NOT NULL DEFAULT 0,
    `coord_z` FLOAT NOT NULL DEFAULT 0,
    `heading` FLOAT NOT NULL DEFAULT 0,
    `scenario` VARCHAR(100) NOT NULL DEFAULT '',
    `label` VARCHAR(150) NOT NULL DEFAULT '[E] Outfit-Menü öffnen',
    PRIMARY KEY (`job_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- male_clothes/female_clothes speichern die Kleidungs-Slots (mask_1, torso_1, ...)
-- als JSON-String. LONGTEXT statt nativem JSON-Typ für maximale Kompatibilität
-- mit älteren MySQL/MariaDB-Versionen.
CREATE TABLE IF NOT EXISTS `multijob_outfit_outfits` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `job_name` VARCHAR(50) NOT NULL,
    `grade` INT NOT NULL DEFAULT 0,
    `label` VARCHAR(150) NOT NULL DEFAULT '',
    `sort_order` INT NOT NULL DEFAULT 0,
    `male_clothes` LONGTEXT NULL,
    `female_clothes` LONGTEXT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_job_grade` (`job_name`, `grade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

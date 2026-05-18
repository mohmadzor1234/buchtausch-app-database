-- ============================================================
-- Phase 2: Erarbeitungs-/Reflexionsphase
-- Projekt: Buchtausch-App Datenbank
-- Name: Mohamad Almoussa
-- Matrikelnummer: IU14121494
-- Kurs: DLBDSPBDM01_D
-- DBMS: MariaDB / XAMPP
-- ============================================================

-- Alte Datenbank löschen, falls sie bereits existiert.
-- Dadurch kann das Skript mehrfach fehlerfrei ausgeführt werden.
DROP DATABASE IF EXISTS buchtausch_app;

-- Neue Datenbank erstellen.
CREATE DATABASE buchtausch_app
CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;

-- Datenbank auswählen.
USE buchtausch_app;

-- ============================================================
-- 1. TABELLEN ERSTELLEN
-- ============================================================

-- Tabelle: benutzer
-- Diese Tabelle speichert alle Benutzer:innen der App.
CREATE TABLE benutzer (
    benutzer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    adresse VARCHAR(255),
    email VARCHAR(100) NOT NULL UNIQUE,
    telefon VARCHAR(30),
    rolle VARCHAR(50) NOT NULL
);

-- Tabelle: buch
-- Diese Tabelle speichert Informationen über Bücher.
CREATE TABLE buch (
    buch_id INT AUTO_INCREMENT PRIMARY KEY,
    titel VARCHAR(150) NOT NULL,
    autor VARCHAR(100),
    genre VARCHAR(80),
    verlag VARCHAR(100),
    jahr INT,
    sprache VARCHAR(50),
    zustand VARCHAR(50)
);

-- Tabelle: verfuegbarkeit
-- Diese Tabelle speichert, wann und wo ein Buch verfügbar ist.
CREATE TABLE verfuegbarkeit (
    verfuegbarkeit_id INT AUTO_INCREMENT PRIMARY KEY,
    buch_id INT NOT NULL,
    von_datum DATE NOT NULL,
    bis_datum DATE NOT NULL,
    ort VARCHAR(100),
    postversand BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (buch_id) REFERENCES buch(buch_id)
);

-- Tabelle: ausleihe
-- Diese Tabelle speichert Ausleihvorgänge.
CREATE TABLE ausleihe (
    ausleihe_id INT AUTO_INCREMENT PRIMARY KEY,
    buch_id INT NOT NULL,
    entleiher_id INT NOT NULL,
    verfuegbarkeit_id INT NOT NULL,
    von_datum DATE NOT NULL,
    bis_datum DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (buch_id) REFERENCES buch(buch_id),
    FOREIGN KEY (entleiher_id) REFERENCES benutzer(benutzer_id),
    FOREIGN KEY (verfuegbarkeit_id) REFERENCES verfuegbarkeit(verfuegbarkeit_id)
);

-- Tabelle: bewertung
-- Diese Tabelle speichert Bewertungen zu Büchern nach einer Ausleihe.
CREATE TABLE bewertung (
    bewertung_id INT AUTO_INCREMENT PRIMARY KEY,
    buch_id INT NOT NULL,
    benutzer_id INT NOT NULL,
    ausleihe_id INT NOT NULL,
    sterne INT NOT NULL,
    kommentar TEXT,
    datum DATE NOT NULL,
    FOREIGN KEY (buch_id) REFERENCES buch(buch_id),
    FOREIGN KEY (benutzer_id) REFERENCES benutzer(benutzer_id),
    FOREIGN KEY (ausleihe_id) REFERENCES ausleihe(ausleihe_id),
    CHECK (sterne BETWEEN 1 AND 5)
);

-- Tabelle: kategorie
-- Diese Tabelle speichert Buchkategorien.
CREATE TABLE kategorie (
    kategorie_id INT AUTO_INCREMENT PRIMARY KEY,
    bezeichnung VARCHAR(100) NOT NULL
);

-- Tabelle: buch_kategorie
-- Diese Zwischentabelle bildet die M:N-Beziehung zwischen Buch und Kategorie ab.
CREATE TABLE buch_kategorie (
    buch_id INT NOT NULL,
    kategorie_id INT NOT NULL,
    PRIMARY KEY (buch_id, kategorie_id),
    FOREIGN KEY (buch_id) REFERENCES buch(buch_id),
    FOREIGN KEY (kategorie_id) REFERENCES kategorie(kategorie_id)
);

-- Tabelle: nachricht
-- Diese Tabelle speichert Nachrichten zwischen Benutzer:innen zu einem Buch.
CREATE TABLE nachricht (
    nachricht_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    empfaenger_id INT NOT NULL,
    buch_id INT NOT NULL,
    inhalt TEXT NOT NULL,
    datum DATE NOT NULL,
    FOREIGN KEY (sender_id) REFERENCES benutzer(benutzer_id),
    FOREIGN KEY (empfaenger_id) REFERENCES benutzer(benutzer_id),
    FOREIGN KEY (buch_id) REFERENCES buch(buch_id)
);

-- Tabelle: standort
-- Diese Tabelle speichert Standortdaten für geografische Suche.
CREATE TABLE standort (
    standort_id INT AUTO_INCREMENT PRIMARY KEY,
    plz VARCHAR(10),
    stadt VARCHAR(100),
    breitengrad DECIMAL(10,7),
    laengengrad DECIMAL(10,7)
);

-- Tabelle: buch_standort
-- Diese Zwischentabelle verbindet Bücher mit Standorten.
CREATE TABLE buch_standort (
    buch_id INT NOT NULL,
    standort_id INT NOT NULL,
    PRIMARY KEY (buch_id, standort_id),
    FOREIGN KEY (buch_id) REFERENCES buch(buch_id),
    FOREIGN KEY (standort_id) REFERENCES standort(standort_id)
);

-- ============================================================
-- 2. TESTDATEN EINFÜGEN
-- Jede Tabelle enthält mindestens 10 Einträge.
-- ============================================================

-- Benutzer:innen einfügen.
INSERT INTO benutzer (name, adresse, email, telefon, rolle) VALUES
('Anna Müller', 'Hauptstraße 10, Berlin', 'anna.mueller@example.de', '01711111111', 'Anbieter'),
('Max Schmidt', 'Gartenweg 5, Hamburg', 'max.schmidt@example.de', '01722222222', 'Entleiher'),
('Sofia Weber', 'Bahnhofstraße 3, Köln', 'sofia.weber@example.de', '01733333333', 'Anbieter'),
('Lukas Fischer', 'Ringstraße 8, München', 'lukas.fischer@example.de', '01744444444', 'Entleiher'),
('Emma Wagner', 'Schulstraße 12, Essen', 'emma.wagner@example.de', '01755555555', 'Anbieter'),
('Noah Becker', 'Marktplatz 2, Dortmund', 'noah.becker@example.de', '01766666666', 'Entleiher'),
('Mia Hoffmann', 'Wiesenweg 7, Bochum', 'mia.hoffmann@example.de', '01777777777', 'Anbieter'),
('Leon Koch', 'Kirchstraße 4, Duisburg', 'leon.koch@example.de', '01788888888', 'Entleiher'),
('Clara Richter', 'Parkallee 9, Düsseldorf', 'clara.richter@example.de', '01799999999', 'Admin'),
('Paul Neumann', 'Bergstraße 6, Gelsenkirchen', 'paul.neumann@example.de', '01611111111', 'Anbieter');

-- Bücher einfügen.
INSERT INTO buch (titel, autor, genre, verlag, jahr, sprache, zustand) VALUES
('Der kleine Prinz', 'Antoine de Saint-Exupéry', 'Roman', 'Karl Rauch Verlag', 1943, 'Deutsch', 'gut'),
('Harry Potter und der Stein der Weisen', 'J. K. Rowling', 'Fantasy', 'Carlsen', 1998, 'Deutsch', 'sehr gut'),
('1984', 'George Orwell', 'Dystopie', 'Ullstein', 1949, 'Deutsch', 'gut'),
('Die Verwandlung', 'Franz Kafka', 'Erzählung', 'Reclam', 1915, 'Deutsch', 'gebraucht'),
('Clean Code', 'Robert C. Martin', 'Informatik', 'MITP', 2008, 'Englisch', 'sehr gut'),
('Datenbanken verstehen', 'Hans Müller', 'Fachbuch', 'Springer', 2020, 'Deutsch', 'gut'),
('Der Alchimist', 'Paulo Coelho', 'Roman', 'Diogenes', 1988, 'Deutsch', 'gut'),
('Sofies Welt', 'Jostein Gaarder', 'Philosophie', 'Hanser', 1991, 'Deutsch', 'gebraucht'),
('Java ist auch eine Insel', 'Christian Ullenboom', 'Informatik', 'Rheinwerk', 2022, 'Deutsch', 'sehr gut'),
('Effektives Lernen', 'Peter Brown', 'Sachbuch', 'Beltz', 2014, 'Deutsch', 'gut');

-- Kategorien einfügen.
INSERT INTO kategorie (bezeichnung) VALUES
('Roman'),
('Fantasy'),
('Dystopie'),
('Erzählung'),
('Informatik'),
('Fachbuch'),
('Philosophie'),
('Sachbuch'),
('Klassiker'),
('Lernen');

-- Standorte einfügen.
INSERT INTO standort (plz, stadt, breitengrad, laengengrad) VALUES
('10115', 'Berlin', 52.5320000, 13.3849000),
('20095', 'Hamburg', 53.5503000, 10.0006000),
('50667', 'Köln', 50.9375000, 6.9603000),
('80331', 'München', 48.1374000, 11.5755000),
('45127', 'Essen', 51.4556000, 7.0116000),
('44135', 'Dortmund', 51.5136000, 7.4653000),
('44787', 'Bochum', 51.4818000, 7.2162000),
('47051', 'Duisburg', 51.4344000, 6.7623000),
('40213', 'Düsseldorf', 51.2254000, 6.7763000),
('45879', 'Gelsenkirchen', 51.5177000, 7.0857000);

-- Verfügbarkeiten einfügen.
INSERT INTO verfuegbarkeit (buch_id, von_datum, bis_datum, ort, postversand) VALUES
(1, '2026-05-01', '2026-06-01', 'Berlin', TRUE),
(2, '2026-05-03', '2026-06-03', 'Hamburg', FALSE),
(3, '2026-05-05', '2026-06-05', 'Köln', TRUE),
(4, '2026-05-07', '2026-06-07', 'München', FALSE),
(5, '2026-05-09', '2026-06-09', 'Essen', TRUE),
(6, '2026-05-11', '2026-06-11', 'Dortmund', FALSE),
(7, '2026-05-13', '2026-06-13', 'Bochum', TRUE),
(8, '2026-05-15', '2026-06-15', 'Duisburg', FALSE),
(9, '2026-05-17', '2026-06-17', 'Düsseldorf', TRUE),
(10, '2026-05-19', '2026-06-19', 'Gelsenkirchen', FALSE);

-- Ausleihen einfügen.
INSERT INTO ausleihe (buch_id, entleiher_id, verfuegbarkeit_id, von_datum, bis_datum, status) VALUES
(1, 2, 1, '2026-05-02', '2026-05-20', 'aktiv'),
(2, 4, 2, '2026-05-04', '2026-05-22', 'aktiv'),
(3, 6, 3, '2026-05-06', '2026-05-24', 'zurückgegeben'),
(4, 8, 4, '2026-05-08', '2026-05-26', 'aktiv'),
(5, 2, 5, '2026-05-10', '2026-05-28', 'zurückgegeben'),
(6, 4, 6, '2026-05-12', '2026-05-30', 'aktiv'),
(7, 6, 7, '2026-05-14', '2026-06-01', 'aktiv'),
(8, 8, 8, '2026-05-16', '2026-06-03', 'zurückgegeben'),
(9, 2, 9, '2026-05-18', '2026-06-05', 'aktiv'),
(10, 4, 10, '2026-05-20', '2026-06-07', 'aktiv');

-- Bewertungen einfügen.
INSERT INTO bewertung (buch_id, benutzer_id, ausleihe_id, sterne, kommentar, datum) VALUES
(3, 6, 3, 5, 'Sehr gutes Buch und schnelle Übergabe.', '2026-05-25'),
(5, 2, 5, 4, 'Sehr hilfreich für Programmierung.', '2026-05-29'),
(8, 8, 8, 4, 'Interessantes Buch, Zustand war okay.', '2026-06-04'),
(1, 2, 1, 5, 'Schöne Geschichte und gutes Exemplar.', '2026-05-21'),
(2, 4, 2, 5, 'Sehr spannend und sauber.', '2026-05-23'),
(4, 8, 4, 3, 'Buch war lesbar, aber etwas alt.', '2026-05-27'),
(6, 4, 6, 4, 'Gutes Fachbuch für Datenbanken.', '2026-05-31'),
(7, 6, 7, 5, 'Sehr inspirierend.', '2026-06-02'),
(9, 2, 9, 5, 'Perfekt für Java-Lernen.', '2026-06-06'),
(10, 4, 10, 4, 'Guter Inhalt zum Lernen.', '2026-06-08');

-- Beziehungen zwischen Büchern und Kategorien einfügen.
INSERT INTO buch_kategorie (buch_id, kategorie_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 1),
(8, 7),
(9, 5),
(10, 10);

-- Nachrichten einfügen.
INSERT INTO nachricht (sender_id, empfaenger_id, buch_id, inhalt, datum) VALUES
(2, 1, 1, 'Hallo, ist das Buch noch verfügbar?', '2026-05-01'),
(4, 3, 2, 'Kann ich das Buch morgen abholen?', '2026-05-03'),
(6, 5, 3, 'Ist Postversand möglich?', '2026-05-05'),
(8, 7, 4, 'Wie ist der Zustand des Buches?', '2026-05-07'),
(2, 5, 5, 'Ich interessiere mich für Clean Code.', '2026-05-09'),
(4, 1, 6, 'Wann wäre eine Übergabe möglich?', '2026-05-11'),
(6, 3, 7, 'Ist das Buch auf Deutsch?', '2026-05-13'),
(8, 5, 8, 'Kann ich es für zwei Wochen ausleihen?', '2026-05-15'),
(2, 7, 9, 'Ich möchte Java lernen, ist das Buch geeignet?', '2026-05-17'),
(4, 10, 10, 'Ist das Buch noch in Gelsenkirchen verfügbar?', '2026-05-19');

-- Beziehungen zwischen Büchern und Standorten einfügen.
INSERT INTO buch_standort (buch_id, standort_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- ============================================================
-- 3. KONTROLLABFRAGE
-- Prüft, ob jede Tabelle mindestens 10 Einträge enthält.
-- ============================================================

SELECT 'benutzer' AS tabelle, COUNT(*) AS anzahl FROM benutzer
UNION ALL
SELECT 'buch', COUNT(*) FROM buch
UNION ALL
SELECT 'verfuegbarkeit', COUNT(*) FROM verfuegbarkeit
UNION ALL
SELECT 'ausleihe', COUNT(*) FROM ausleihe
UNION ALL
SELECT 'bewertung', COUNT(*) FROM bewertung
UNION ALL
SELECT 'kategorie', COUNT(*) FROM kategorie
UNION ALL
SELECT 'buch_kategorie', COUNT(*) FROM buch_kategorie
UNION ALL
SELECT 'nachricht', COUNT(*) FROM nachricht
UNION ALL
SELECT 'standort', COUNT(*) FROM standort
UNION ALL
SELECT 'buch_standort', COUNT(*) FROM buch_standort;

-- ============================================================
-- 4. TESTFÄLLE
-- Diese Abfragen prüfen die wichtigsten Funktionen der Datenbank.
-- ============================================================

-- Testfall 1: Bücher mit Verfügbarkeit anzeigen.
SELECT 
    b.buch_id,
    b.titel,
    b.autor,
    v.von_datum,
    v.bis_datum,
    v.ort,
    v.postversand
FROM buch b
JOIN verfuegbarkeit v ON b.buch_id = v.buch_id;

-- Testfall 2: Ausleihen mit Benutzer und Buch anzeigen.
SELECT 
    a.ausleihe_id,
    bu.name AS entleiher,
    b.titel AS buch,
    a.von_datum,
    a.bis_datum,
    a.status
FROM ausleihe a
JOIN benutzer bu ON a.entleiher_id = bu.benutzer_id
JOIN buch b ON a.buch_id = b.buch_id;

-- Testfall 3: Bewertungen mit Buch und Benutzer anzeigen.
SELECT 
    bw.bewertung_id,
    bu.name AS benutzer,
    b.titel AS buch,
    bw.sterne,
    bw.kommentar,
    bw.datum
FROM bewertung bw
JOIN benutzer bu ON bw.benutzer_id = bu.benutzer_id
JOIN buch b ON bw.buch_id = b.buch_id;

-- Testfall 4: Bücher nach Standort anzeigen.
SELECT 
    b.titel,
    s.stadt,
    s.plz,
    s.breitengrad,
    s.laengengrad
FROM buch b
JOIN buch_standort bs ON b.buch_id = bs.buch_id
JOIN standort s ON bs.standort_id = s.standort_id;

-- Testfall 5: Bücher nach Kategorie anzeigen.
SELECT 
    b.titel,
    k.bezeichnung AS kategorie
FROM buch b
JOIN buch_kategorie bk ON b.buch_id = bk.buch_id
JOIN kategorie k ON bk.kategorie_id = k.kategorie_id;

-- Testfall 6: Nachrichten mit Sender, Empfänger und Buch anzeigen.
SELECT 
    n.nachricht_id,
    sender.name AS sender,
    empfaenger.name AS empfaenger,
    b.titel AS buch,
    n.inhalt,
    n.datum
FROM nachricht n
JOIN benutzer sender ON n.sender_id = sender.benutzer_id
JOIN benutzer empfaenger ON n.empfaenger_id = empfaenger.benutzer_id
JOIN buch b ON n.buch_id = b.buch_id;

-- Testfall 7: Nur verfügbare Bücher mit Postversand anzeigen.
SELECT 
    b.titel,
    b.autor,
    v.ort,
    v.postversand
FROM buch b
JOIN verfuegbarkeit v ON b.buch_id = v.buch_id
WHERE v.postversand = TRUE;
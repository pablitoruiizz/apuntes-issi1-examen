DROP DATABASE if exists tenis;
CREATE DATABASE tenis; 
USE tenis;

DROP TABLE IF EXISTS Sets;
DROP TABLE IF EXISTS Partidos;
DROP TABLE IF EXISTS Arbitros;
DROP TABLE IF EXISTS Tenistas;
DROP TABLE IF EXISTS Personas;

CREATE TABLE Personas(
	personaId INT NOT NULL AUTO_INCREMENT,
	nombre VARCHAR(60) NOT NULL UNIQUE,
	edad INT NOT NULL,
	nacionalidad VARCHAR(100) NOT NULL,
	PRIMARY KEY (personaId),
	CONSTRAINT jugadorMayorEdad CHECK (edad >= 18)
);

CREATE TABLE Tenistas(
	tenistaId INT NOT NULL AUTO_INCREMENT,
	ranking INT NOT NULL,
	personaId INT NOT NULL,
	PRIMARY KEY (tenistaId),
	FOREIGN KEY (personaId) REFERENCES Personas(personaId),
	CONSTRAINT posicionRankingValida CHECK (ranking > 0 AND ranking <= 1000)
);

CREATE TABLE Arbitros(
	arbitroId INT NOT NULL AUTO_INCREMENT,
	licencia VARCHAR(100) NOT NULL,
	personaId INT NOT NULL,
	PRIMARY KEY (arbitroId),
	FOREIGN KEY (personaId) REFERENCES Personas(personaId)
);

CREATE TABLE Partidos(
	partidoId INT NOT NULL AUTO_INCREMENT,
	fechaPartido DATE NOT NULL,
	ronda VARCHAR(100) NOT NULL,
	duracion INT NOT NULL,
	torneo VARCHAR(100) NOT NULL,
	tenista1Id INT NOT NULL,
   tenista2Id INT NOT NULL,
   ganadorId INT NOT NULL,
   arbitroId INT NOT NULL,
	PRIMARY KEY (partidoId),
	FOREIGN KEY (tenista1Id) REFERENCES Tenistas(tenistaId),
	FOREIGN KEY (tenista2Id) REFERENCES Tenistas(tenistaId),
	FOREIGN KEY (ganadorId) REFERENCES Tenistas(tenistaId),
	FOREIGN KEY (arbitroId) REFERENCES Arbitros(arbitroId),
	CONSTRAINT rivalesDiferentes CHECK (tenista1Id != tenista2Id)
);

CREATE TABLE Sets(
	setId INT NOT NULL AUTO_INCREMENT,
	resultado VARCHAR (100) NOT NULL,
	numeroSet INT NOT NULL,
	partidoId INT NOT NULL,
	ganadorId INT NOT NULL,
	PRIMARY KEY (setId),
   FOREIGN KEY (partidoId) REFERENCES Partidos(partidoId) ON DELETE CASCADE,
   FOREIGN KEY (ganadorId) REFERENCES Tenistas(tenistaId),
   CONSTRAINT ordenSetValido CHECK (numeroSet >= 1 AND numeroSet <=5)
);


DELIMITER //

CREATE OR REPLACE TRIGGER rn06_limite_partidos_arbitro
BEFORE INSERT ON Partidos
FOR EACH ROW
BEGIN
    DECLARE partidos_del_dia INT;

    SELECT COUNT(*) INTO partidos_del_dia
    FROM Partidos
    WHERE arbitroId = new.arbitroId 
      AND fechaPartido = new.fechaPartido;

    IF partidos_del_dia >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'RN-06 Violada: Este árbitro ya tiene 3 partidos asignados en esta fecha.';
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER rn07_validar_nacionalidad
BEFORE INSERT ON Partidos
FOR EACH ROW
BEGIN
    DECLARE nac_arbitro VARCHAR(100);
    DECLARE nac_tenista1 VARCHAR(100);
    DECLARE nac_tenista2 VARCHAR(100);

    SELECT p.nacionalidad INTO nac_arbitro
    FROM Personas p
    INNER JOIN Arbitros a ON p.personaId = a.personaId
    WHERE a.arbitroId = NEW.arbitroId;
    
    SELECT p.nacionalidad INTO nac_tenista1
    FROM Personas p
    INNER JOIN Tenistas t ON p.personaId = t.personaId
    WHERE t.tenistaId = NEW.tenista1Id;

    SELECT p.nacionalidad INTO nac_tenista2
    FROM Personas p
    INNER JOIN Tenistas t ON p.personaId = t.personaId
    WHERE t.tenistaId = NEW.tenista2Id;

    IF (nac_arbitro = nac_tenista1) OR (nac_arbitro = nac_tenista2) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'RN-07 Violada: El árbitro tiene la misma nacionalidad que uno de los tenistas.';
    END IF;
END //

DELIMITER ;

DROP DATABASE if exists tenis_avanzado;
CREATE DATABASE tenis_avanzado; 
USE tenis_avanzado;

DROP TABLE IF EXISTS sets;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS trainers;
DROP TABLE IF EXISTS referees;
DROP TABLE IF EXISTS people;


CREATE TABLE people (
    person_id INT AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    PRIMARY KEY (person_id),
    CONSTRAINT rn_03_unique_name UNIQUE(name),
    CONSTRAINT rn_02_adult_age CHECK (age >= 18)
);
CREATE TABLE trainers (
	trainer_id INT PRIMARY KEY,
	experiencia INT NOT NULL,
	especialidad VARCHAR(30) NOT NULL,
	FOREIGN KEY (trainer_id) REFERENCES people(person_id) ON DELETE CASCADE,
	CONSTRAINT ra_01 CHECK (especialidad IN ('Individual' , 'Dobles'))
);
CREATE TABLE players (
    player_id INT,
    ranking INT NOT NULL,
    entrenador_id INT,
    PRIMARY KEY (player_id),
    FOREIGN KEY (player_id) REFERENCES people(person_id) ON DELETE CASCADE,
    FOREIGN KEY (entrenador_id) REFERENCES trainers(trainer_id),
    CONSTRAINT rn_04_ranking CHECK (ranking > 0 AND ranking <= 1000)
);

CREATE TABLE referees (
    referee_id INT,
    license VARCHAR(30) NOT NULL,
    PRIMARY KEY (referee_id),
    FOREIGN KEY (referee_id) REFERENCES people(person_id) ON DELETE CASCADE,
    CONSTRAINT rn_07_license CHECK (license IN ('Nacional', 'Internacional'))
);

CREATE TABLE matches (
    match_id INT AUTO_INCREMENT,
    referee_id INT NOT NULL,
    player1_id INT NOT NULL,
    player2_id INT NOT NULL,
    winner_id INT NOT NULL,
    tournament VARCHAR(100) NOT NULL,
    match_date DATE NOT NULL,
    round VARCHAR(30) NOT NULL,
    duration INT NOT NULL,
    PRIMARY KEY (match_id),
    FOREIGN KEY (referee_id) REFERENCES referees(referee_id),
    FOREIGN KEY (player1_id) REFERENCES players(player_id),
    FOREIGN KEY (player2_id) REFERENCES players(player_id),
    FOREIGN KEY (winner_id) REFERENCES players(player_id),  
    CONSTRAINT rn_05_different_players CHECK (player1_id <> player2_id),
    CONSTRAINT rn_xx_valid_winner CHECK (winner_id IN (player1_id, player2_id)),
    CONSTRAINT rn_xx_duration CHECK (duration > 0) -- Extra: positive duration
);

CREATE TABLE sets (
    set_id INT AUTO_INCREMENT,
    match_id INT NOT NULL,
    winner_id INT NOT NULL,
    set_order INT NOT NULL,
    score VARCHAR(20) NOT NULL,
    PRIMARY KEY (set_id),
    FOREIGN KEY (match_id) REFERENCES matches(match_id),
    FOREIGN KEY (winner_id) REFERENCES players(player_id),
    CONSTRAINT rn_03_set_order CHECK (set_order >= 1 AND set_order <= 5)
);

DELIMITER //
CREATE OR REPLACE TRIGGER ra_02
BEFORE INSERT ON players
FOR EACH ROW
BEGIN
	DECLARE num_alumnos INT;
	SELECT COUNT(*) INTO num_alumnos
	FROM players 
	WHERE entrenador_id = new.entrenador_id;
	IF num_alumnos = 2 THEN
		SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'RA-02 Error: Este entrenador ya tiene el máximo de 2 tenistas permitidos.';
   END IF;
END //

DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE prueba_trigger_ra02()
BEGIN
    -- 2. Intento de fallo: Crear un 3er tenista y asignarle el mismo entrenador (ID 3)
    -- Primero creamos la persona
    INSERT INTO people (NAME, age, nationality) VALUES ('Jose Perez', 22, 'Italiana');
    SET @new_id = LAST_INSERT_ID();
    
    -- Intentamos insertar como tenista con el entrenador saturado
    -- Esto debería fallar y saltar el error RA-02
    INSERT INTO players (player_id, ranking, entrenador_id) VALUES (@new_id, 3, 20);
END //
DELIMITER ;

CALL prueba_trigger_ra02()


DELIMITER //
CREATE OR REPLACE FUNCTION partido_tenista( p_player_id INT, p_match_id INT) RETURNS INT
BEGIN
	DECLARE v_set_won INT;
	
	
	SELECT COUNT(*) INTO v_set_won
	FROM sets s
	WHERE s.match_id = p_match_id AND winner_id = p_player_id;
	RETURN v_set_won;
END //

DELIMITER ;
SELECT partido_tenista(1,3)


SELECT m.match_date, m.duration
	FROM matches m
	JOIN sets s ON s.match_id = m.match_id
	GROUP BY m.match_date, m.duration
	HAVING COUNT(s.set_id) = 2;
	

SELECT 
    pe.name, 
    COUNT(m.match_id) AS matches_refereed
FROM referees r
JOIN people pe ON r.referee_id = pe.person_id
JOIN matches m ON r.referee_id = m.referee_id
GROUP BY r.referee_id, pe.name
ORDER BY matches_refereed DESC;

SELECT pe_p.name AS Jugador, pe_t.name AS Entrenador
	FROM players p
	JOIN people pe_p ON p.player_id = pe_p.person_id
	LEFT JOIN trainers t ON t.trainer_id = p.entrenador_id
	LEFT JOIN people pe_t ON t.trainer_id=pe_t.person_id

SELECT DISTINCT pe.name AS Jugador
	FROM players p
	JOIN sets s ON s.winner_id = p.player_id
	JOIN people pe ON pe.person_id = p.player_id
	WHERE s.score = '6-0'

SELECT m.tournament AS Torneo, AVG(m.duration) AS Duracion_media
FROM matches m
GROUP BY m.tournament

SELECT pe.name AS Nombre
FROM referees r
JOIN people pe ON pe.person_id = r.referee_id
JOIN matches m ON m.referee_id = r.referee_id
GROUP BY r.referee_id
HAVING COUNT(m.match_id) > 1

SELECT m.tournament AS Torneo, pe_1.name AS Jugador_1, pe_2.name AS Jugador_2
FROM matches m
JOIN people pe_1 ON (pe_1.person_id = m.player1_id)
JOIN people pe_2 ON pe_2.person_id = m.player2_id
WHERE pe_1.nationality = pe_2.nationality
	

DELIMITER //

CREATE OR REPLACE TRIGGER rn_imparcialidad
BEFORE INSERT ON matches -- No pongas alias aquí
FOR EACH ROW 
BEGIN
    -- 1. Declaramos variables para guardar las nacionalidades
    DECLARE nac_arbitro VARCHAR(50);
    DECLARE nac_p1 VARCHAR(50);
    DECLARE nac_p2 VARCHAR(50);

    -- 2. Buscamos la nacionalidad del ÁRBITRO usando el ID que entra (NEW.referee_id)
    SELECT nationality INTO nac_arbitro 
    FROM people 
    WHERE person_id = NEW.referee_id;

    -- 3. Buscamos la nacionalidad del JUGADOR 1
    SELECT nationality INTO nac_p1 
    FROM people 
    WHERE person_id = NEW.player1_id;

    -- 4. Buscamos la nacionalidad del JUGADOR 2
    SELECT nationality INTO nac_p2 
    FROM people 
    WHERE person_id = NEW.player2_id;

    -- 5. Comparamos
    IF (nac_arbitro = nac_p1 OR nac_arbitro = nac_p2) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error RN-Imparcialidad: El árbitro no puede tener la misma nacionalidad que los jugadores.';
    END IF;

END //
DELIMITER ;
-- Prueba de fallo (Debería saltar el error)
-- Árbitro ID 7 (España) vs Jugador ID 2 (España)
INSERT INTO matches (referee_id, player1_id, player2_id, winner_id, tournament, match_date, round, duration)
VALUES (7, 2, 4, 2, 'Prueba Error', CURDATE(), 'R1', 100);


DELIMITER //

CREATE OR REPLACE TRIGGER rn_arbitro_cansado
BEFORE INSERT ON matches 
FOR EACH ROW
BEGIN
	 DECLARE num_partidos INT;
	 SELECT COUNT(*) INTO num_partidos
	 FROM matches
	 WHERE referee_id = NEW.referee_id AND match_date = match_date;
	 IF (num_partidos >= 3) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error RN-árbitro cansado';
    END IF;

END //
DELIMITER ;



DELIMITER //
CREATE OR REPLACE TRIGGER rn_mayor
BEFORE INSERT ON players
FOR EACH ROW
BEGIN
	DECLARE edad_entrenador INT;
	DECLARE edad_jugador INT;
	IF NEW.entrenador_id IS NOT NULL THEN
		SELECT age INTO edad_jugador
		FROM people
		WHERE person_id = NEW.player_id;
		SELECT age INTO edad_entrenador
		FROM people
		WHERE person_id = NEW.entrenador_id;
		IF edad_entrenador <= edad_jugador THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error RN-Respeto: Un entrenador debe ser mayor que el tenista al que entrena.';
        END IF;
        
    END IF;
END //
DELIMITER ;



DELIMITER //
CREATE OR REPLACE TRIGGER rn_narcisista
BEFORE INSERT ON players
FOR EACH ROW
BEGIN 
	IF NEW.player_id = NEW.entrenador_id THEN
		SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error RN-narcisista';
    END IF;
END //
DELIMITER ;
	
DELIMITER //
CREATE OR REPLACE TRIGGER rn_set
BEFORE INSERT ON sets
FOR EACH ROW
BEGIN
	DECLARE jugador1 INT;
	DECLARE jugador2 INT;
	SELECT player1_id INTO jugador1
	FROM matches
	WHERE match_id = NEW.match_id;
	SELECT player2_id INTO jugador2
	FROM matches
	WHERE match_id = NEW.match_id;
	IF NEW.winner_id <> jugador1 AND NEW.winner_id <> jugador2 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El ganador del set no participa en este partido.';
   END IF;
END //

DELIMITER ;
	
	
	

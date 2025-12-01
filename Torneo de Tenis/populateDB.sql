USE tenis;

DELIMITER //

CREATE PROCEDURE p_populate_db()
BEGIN
    -- 1. Limpiar datos (Orden inverso para respetar las Foreign Keys)
    -- Si hay sets, se borran primero, luego partidos, luego roles, al final personas.
    DELETE FROM Sets;
    DELETE FROM Partidos;
    DELETE FROM Tenistas;
    DELETE FROM Arbitros;
    DELETE FROM Personas;

    -- 2. Insertar Personas
    -- Insertamos explícitamente el ID para controlar las relaciones posteriores
    INSERT INTO Personas (personaId, nombre, edad, nacionalidad) VALUES
        (1, 'Novak Djokovic', 38, 'Serbia'),
        (2, 'Carlos Alcaraz', 22, 'España'),
        (3, 'Jannik Sinner', 24, 'Italia'),
        (4, 'Daniil Medvedev', 29, 'Rusia'),
        (5, 'Rafael Nadal', 39, 'España'),
        (6, 'Roger Federer', 44, 'Suiza'),
        (7, 'Carlos Ramos', 53, 'España'), -- Árbitro
        (8, 'Mohamed Lahyani', 58, 'Suecia'), -- Árbitro
        (9, 'Eva Asderaki', 43, 'Grecia'), -- Árbitro
        (10, 'Roberto Bautista Agut', 36, 'España'),
        (11, 'Paula Badosa', 27, 'España'),
        (12, 'Taylor Fritz', 27, 'Estados Unidos'),
        (13, 'Andy Murray', 37, 'Reino Unido'),
        (14, 'Felix Auger-Aliassime', 25, 'Canadá'),
        (15, 'James Keothavong', 42, 'Reino Unido'), -- Árbitro
        (16, 'Aurelie Tourte', 41, 'Francia'), -- Árbitro
        (17, 'Carlos Bernardes', 58, 'Brasil'), -- Árbitro
        (18, 'Diego Fernandez', 50, 'Argentina'); -- Árbitro

    -- 3. Insertar Árbitros
    -- Nota: Hacemos que arbitroId coincida con personaId para facilitar el script
    INSERT INTO Arbitros (arbitroId, personaId, licencia) VALUES 
        (7, 7, 'Internacional'),
        (8, 8, 'Internacional'),
        (9, 9, 'Internacional'),
        (15, 15, 'Internacional'),
        (16, 16, 'Internacional'),
        (17, 17, 'Internacional'),
        (18, 18, 'Nacional');

    -- 4. Insertar Tenistas
    -- Nota: Hacemos que tenistaId coincida con personaId
    INSERT INTO Tenistas (tenistaId, personaId, ranking) VALUES 
        (1, 1, 1),
        (2, 2, 2),
        (3, 3, 4),
        (4, 4, 5),
        (5, 5, 9),
        (6, 6, 1000),
        (10, 10, 18),
        (11, 11, 25),
        (12, 12, 10),
        (13, 13, 22),
        (14, 14, 11);

    -- 5. Insertar Partidos y Sets
    -- Los triggers saltarán aquí para verificar reglas (Nacionalidad y Limite partidos)

    -- Partido 1: Wimbledon 2024 (Djokovic vs Alcaraz)
    INSERT INTO Partidos (partidoId, arbitroId, tenista1Id, tenista2Id, ganadorId, torneo, fechaPartido, ronda, duracion)
        VALUES (1, 8, 1, 2, 2, 'Wimbledon 2024', '2024-07-14', 'Final', 230);
    
    INSERT INTO Sets (partidoId, ganadorId, numeroSet, resultado) VALUES
        (1, 1, 1, '6-3'),
        (1, 2, 2, '7-6'),
        (1, 2, 3, '6-4');

    -- Partido 2: US Open 2024 (Sinner vs Medvedev)
    INSERT INTO Partidos (partidoId, arbitroId, tenista1Id, tenista2Id, ganadorId, torneo, fechaPartido, ronda, duracion)
        VALUES (2, 7, 3, 4, 3, 'US Open 2024', '2024-09-06', 'Semifinal', 195);
        
    INSERT INTO Sets (partidoId, ganadorId, numeroSet, resultado) VALUES
        (2, 3, 1, '6-4'),
        (2, 4, 2, '3-6'),
        (2, 3, 3, '7-5');

    -- Partido 3: Roland Garros 2024 (Nadal vs Djokovic)
    INSERT INTO Partidos (partidoId, arbitroId, tenista1Id, tenista2Id, ganadorId, torneo, fechaPartido, ronda, duracion)
        VALUES (3, 9, 5, 1, 1, 'Roland Garros 2024', '2024-06-04', 'Cuartos de final', 210);
        
    INSERT INTO Sets (partidoId, ganadorId, numeroSet, resultado) VALUES
        (3, 1, 1, '7-5'),
        (3, 5, 2, '4-6'),
        (3, 1, 3, '6-3');

    -- Partido 4: Indian Wells 2024
    INSERT INTO Partidos (partidoId, arbitroId, tenista1Id, tenista2Id, ganadorId, torneo, fechaPartido, ronda, duracion)
        VALUES (4, 9, 2, 4, 2, 'Indian Wells 2024', '2024-03-17', 'Final', 125);
        
    INSERT INTO Sets (partidoId, ganadorId, numeroSet, resultado) VALUES
        (4, 2, 1, '7-5'),
        (4, 2, 2, '6-2');

    -- Partido 5: Australian Open 2024
    INSERT INTO Partidos (partidoId, arbitroId, tenista1Id, tenista2Id, ganadorId, torneo, fechaPartido, ronda, duracion)
        VALUES (5, 7, 1, 3, 1, 'Australian Open 2024', '2024-01-28', 'Final', 180);
        
    INSERT INTO Sets (partidoId, ganadorId, numeroSet, resultado) VALUES
        (5, 1, 1, '6-4'),
        (5, 3, 2, '3-6'),
        (5, 1, 3, '6-3');

    -- Partido 6: Madrid 2024
    INSERT INTO Partidos (partidoId, arbitroId, tenista1Id, tenista2Id, ganadorId, torneo, fechaPartido, ronda, duracion)
        VALUES (6, 8, 2, 5, 2, 'Mutua Madrid Open 2024', '2024-05-03', 'Semifinal', 140);
        
    INSERT INTO Sets (partidoId, ganadorId, numeroSet, resultado) VALUES
        (6, 2, 1, '6-2'),
        (6, 2, 2, '6-4');

    -- Partido 7: ATP Finals 2024
    INSERT INTO Partidos (partidoId, arbitroId, tenista1Id, tenista2Id, ganadorId, torneo, fechaPartido, ronda, duracion)
        VALUES (7, 9, 4, 1, 4, 'ATP Finals 2024', '2024-11-12', 'Grupo', 115);
        
    INSERT INTO Sets (partidoId, ganadorId, numeroSet, resultado) VALUES
        (7, 4, 1, '7-6'),
        (7, 4, 2, '6-3');

    -- Partido 8: Monte-Carlo 2024
    INSERT INTO Partidos (partidoId, arbitroId, tenista1Id, tenista2Id, ganadorId, torneo, fechaPartido, ronda, duracion)
        VALUES (8, 9, 3, 5, 3, 'Monte-Carlo 2024', '2024-04-12', 'Cuartos de final', 150);
        
    INSERT INTO Sets (partidoId, ganadorId, numeroSet, resultado) VALUES
        (8, 3, 1, '6-3'),
        (8, 5, 2, '4-6'),
        (8, 3, 3, '6-4');

    -- Partido 9: Roland Garros 2025
    INSERT INTO Partidos (partidoId, arbitroId, tenista1Id, tenista2Id, ganadorId, torneo, fechaPartido, ronda, duracion)
        VALUES (9, 15, 2, 3, 2, 'Roland Garros 2025', '2025-06-08',
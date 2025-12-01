USE tenis;

-- Desactivamos comprobación de claves foráneas para limpiar las tablas sin errores de orden
SET FOREIGN_KEY_CHECKS = 0;

-- Limpiamos las tablas (TRUNCATE resetea los auto_increment a 1)
TRUNCATE TABLE `Sets`;
TRUNCATE TABLE `Partidos`;
TRUNCATE TABLE `Tenistas`;
TRUNCATE TABLE `Arbitros`;
TRUNCATE TABLE `Personas`;

-- Reactivamos claves foráneas
SET FOREIGN_KEY_CHECKS = 1;

-- -------------------------
-- 1. Insertar Personas
-- -------------------------
INSERT INTO `Personas` (`personaId`, `nombre`, `edad`, `nacionalidad`) VALUES
(1, 'Novak Djokovic', 38, 'Serbia'),
(2, 'Carlos Alcaraz', 22, 'España'),
(3, 'Jannik Sinner', 24, 'Italia'),
(4, 'Daniil Medvedev', 29, 'Rusia'),
(5, 'Rafael Nadal', 39, 'España'),
(6, 'Roger Federer', 44, 'Suiza'),
(7, 'Carlos Ramos', 53, 'España'),
(8, 'Mohamed Lahyani', 58, 'Suecia'),
(9, 'Eva Asderaki', 43, 'Grecia'),
(10, 'Roberto Bautista Agut', 36, 'España'),
(11, 'Paula Badosa', 27, 'España'),
(12, 'Taylor Fritz', 27, 'Estados Unidos'),
(13, 'Andy Murray', 37, 'Reino Unido'),
(14, 'Felix Auger-Aliassime', 25, 'Canadá'),
(15, 'James Keothavong', 42, 'Reino Unido'),
(16, 'Aurelie Tourte', 41, 'Francia'),
(17, 'Carlos Bernardes', 58, 'Brasil'),
(18, 'Diego Fernandez', 50, 'Argentina');

-- -------------------------
-- 2. Insertar Árbitros
-- -------------------------
INSERT INTO `Arbitros` (`arbitroId`, `personaId`, `licencia`) VALUES 
(7, 7, 'Internacional'),
(8, 8, 'Internacional'),
(9, 9, 'Internacional'),
(15, 15, 'Internacional'),
(16, 16, 'Internacional'),
(17, 17, 'Internacional'),
(18, 18, 'Nacional');

-- -------------------------
-- 3. Insertar Tenistas
-- -------------------------
INSERT INTO `Tenistas` (`tenistaId`, `personaId`, `ranking`) VALUES 
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

-- -------------------------
-- 4. Insertar Partidos y Sets
-- -------------------------

-- Partido 1
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (1, 8, 1, 2, 2, 'Wimbledon 2024', '2024-07-14', 'Final', 230);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(1, 1, 1, '6-3'),
(1, 2, 2, '7-6'),
(1, 2, 3, '6-4');

-- Partido 2
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (2, 7, 3, 4, 3, 'US Open 2024', '2024-09-06', 'Semifinal', 195);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(2, 3, 1, '6-4'),
(2, 4, 2, '3-6'),
(2, 3, 3, '7-5');

-- Partido 3
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (3, 9, 5, 1, 1, 'Roland Garros 2024', '2024-06-04', 'Cuartos de final', 210);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(3, 1, 1, '7-5'),
(3, 5, 2, '4-6'),
(3, 1, 3, '6-3');

-- Partido 4
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (4, 9, 2, 4, 2, 'Indian Wells 2024', '2024-03-17', 'Final', 125);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(4, 2, 1, '7-5'),
(4, 2, 2, '6-2');

-- Partido 5
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (5, 7, 1, 3, 1, 'Australian Open 2024', '2024-01-28', 'Final', 180);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(5, 1, 1, '6-4'),
(5, 3, 2, '3-6'),
(5, 1, 3, '6-3');

-- Partido 6
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (6, 8, 2, 5, 2, 'Mutua Madrid Open 2024', '2024-05-03', 'Semifinal', 140);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(6, 2, 1, '6-2'),
(6, 2, 2, '6-4');

-- Partido 7
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (7, 9, 4, 1, 4, 'ATP Finals 2024', '2024-11-12', 'Grupo', 115);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(7, 4, 1, '7-6'),
(7, 4, 2, '6-3');

-- Partido 8
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (8, 9, 3, 5, 3, 'Monte-Carlo 2024', '2024-04-12', 'Cuartos de final', 150);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(8, 3, 1, '6-3'),
(8, 5, 2, '4-6'),
(8, 3, 3, '6-4');

-- Partido 9
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (9, 15, 2, 3, 2, 'Roland Garros 2025', '2025-06-08', 'Final', 205);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(9, 3, 1, '6-4'),
(9, 2, 2, '7-5'),
(9, 2, 3, '6-0'),
(9, 2, 4, '6-2');

-- Partido 10
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (10, 16, 1, 2, 1, 'Wimbledon 2025', '2025-07-14', 'Final', 240);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(10, 1, 1, '6-4'),
(10, 2, 2, '4-6'),
(10, 1, 3, '7-6'),
(10, 2, 4, '3-6'),
(10, 1, 5, '6-3');

-- Partido 11
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (11, 17, 10, 12, 12, 'Wimbledon 2025', '2025-07-08', 'Cuartos de final', 180);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(11, 12, 1, '6-4'),
(11, 10, 2, '4-6'),
(11, 12, 3, '6-3'),
(11, 12, 4, '6-4');

-- Partido 12
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (12, 16, 10, 13, 10, 'Queens Club 2025', '2025-06-15', 'R32', 95);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(12, 10, 1, '7-6'),
(12, 10, 2, '6-4');

-- Partido 13
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (13, 16, 12, 14, 14, 'Queens Club 2025', '2025-06-15', 'R16', 88);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(13, 14, 1, '6-4'),
(13, 14, 2, '6-3');

-- Partido 14
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (14, 16, 1, 10, 10, 'Queens Club 2025', '2025-06-15', 'Cuartos de final', 105);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(14, 1, 1, '6-2'),
(14, 10, 2, '6-4'),
(14, 10, 3, '6-4');

-- Partido 15
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (15, 18, 5, 10, 5, 'Rio Open 2025', '2025-02-25', 'Final', 175);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(15, 5, 1, '6-3'),
(15, 10, 2, '4-6'),
(15, 5, 3, '6-4');

-- Partido 16
INSERT INTO `Partidos` (`partidoId`, `arbitroId`, `tenista1Id`, `tenista2Id`, `ganadorId`, `torneo`, `fechaPartido`, `ronda`, `duracion`)
VALUES (16, 17, 14, 13, 14, 'Laver Cup 2025', '2025-09-25', 'Exhibición', 120);

INSERT INTO `Sets` (`partidoId`, `ganadorId`, `numeroSet`, `resultado`) VALUES
(16, 14, 1, '6-4'),
(16, 14, 2, '7-5');
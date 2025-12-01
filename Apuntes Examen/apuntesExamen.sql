-- ==========================================
-- GUIA SQL SUPER SIMPLE (USA ESTO EN EL EXAMEN)
-- ==========================================

-- 0. COMO BORRAR TODO SIN LIARLA (DROP IF EXISTS)
--   a) Mira que depende de que: una tabla hija depende de su tabla padre.
--   b) Siempre borra primero lo que depende de otros (triggers, procedimientos,
--      funciones, tablas hijas) y deja las tablas base para el final.
--   c) Despues crea todo en el orden contrario: primero tablas base y al final el codigo extra.
--   d) Con DROP IF EXISTS evitas mensajes de error si el objeto ya no esta.

-- ORDEN DE DROP PARA ESTE EJEMPLO
DROP TRIGGER IF EXISTS dbo.trg_Pedido_ValidaTotal;
DROP PROCEDURE IF EXISTS dbo.Pedido_Crear;
DROP FUNCTION IF EXISTS dbo.fn_TotalPedidosCliente;
DROP TABLE IF EXISTS dbo.DetallePedido;
DROP TABLE IF EXISTS dbo.Pedido;
DROP TABLE IF EXISTS dbo.Producto;
DROP TABLE IF EXISTS dbo.Cliente;

-- 1. CREAR TABLAS (PIENSA EN PADRES -> HIJOS)
--   Paso 1: define columnas, tipos y reglas.
--   Paso 2: agrega PRIMARY KEY, UNIQUE, CHECK y DEFAULT.
--   Paso 3: crea FOREIGN KEY solo cuando ya existe la tabla padre.
--   Paso 4: mete datos de prueba para ver que todo funciona.

-- Tabla padre: Cliente
CREATE TABLE dbo.Cliente (
	ClienteID     INT IDENTITY(1,1) NOT NULL,
	Nombre        VARCHAR(60)       NOT NULL,
	Email         VARCHAR(120)      NOT NULL UNIQUE,
	LimiteCredito DECIMAL(10,2)     NOT NULL CHECK (LimiteCredito >= 0),
	Estado        CHAR(1)           NOT NULL DEFAULT ('A') CHECK (Estado IN ('A','B')),
	CONSTRAINT PK_Cliente PRIMARY KEY (ClienteID)
);

-- Tabla padre: Producto
CREATE TABLE dbo.Producto (
	ProductoID INT IDENTITY(1,1) NOT NULL,
	Nombre     VARCHAR(80)       NOT NULL,
	Precio     DECIMAL(10,2)     NOT NULL CHECK (Precio > 0),
	Stock      INT               NOT NULL CHECK (Stock >= 0),
	CONSTRAINT PK_Producto PRIMARY KEY (ProductoID)
);

-- Tabla intermedia: Pedido (depende de Cliente)
CREATE TABLE dbo.Pedido (
	PedidoID    INT IDENTITY(1,1) NOT NULL,
	ClienteID   INT               NOT NULL,
	FechaPedido DATETIME2         NOT NULL DEFAULT (SYSDATETIME()),
	Estado      CHAR(1)           NOT NULL DEFAULT ('P') CHECK (Estado IN ('P','F','A')),
	Total       DECIMAL(12,2)     NOT NULL CHECK (Total >= 0),
	CONSTRAINT PK_Pedido PRIMARY KEY (PedidoID),
	CONSTRAINT FK_Pedido_Cliente FOREIGN KEY (ClienteID)
		REFERENCES dbo.Cliente(ClienteID)
);

-- Tabla hija: DetallePedido (depende de Pedido y Producto)
CREATE TABLE dbo.DetallePedido (
	DetalleID  INT IDENTITY(1,1) NOT NULL,
	PedidoID   INT               NOT NULL,
	ProductoID INT               NOT NULL,
	Cantidad   INT               NOT NULL CHECK (Cantidad > 0),
	PrecioUnit DECIMAL(10,2)     NOT NULL CHECK (PrecioUnit >= 0),
	CONSTRAINT PK_Detalle PRIMARY KEY (DetalleID),
	CONSTRAINT UQ_Pedido_Producto UNIQUE (PedidoID, ProductoID),
	CONSTRAINT FK_Detalle_Pedido FOREIGN KEY (PedidoID)
		REFERENCES dbo.Pedido(PedidoID) ON DELETE CASCADE,
	CONSTRAINT FK_Detalle_Producto FOREIGN KEY (ProductoID)
		REFERENCES dbo.Producto(ProductoID)
);

-- Mini prueba para asegurar que todo acepta datos
INSERT INTO dbo.Cliente (Nombre, Email, LimiteCredito) VALUES ('Ana', 'ana@test.com', 500);
INSERT INTO dbo.Producto (Nombre, Precio, Stock) VALUES ('Libro', 20, 100);
INSERT INTO dbo.Pedido (ClienteID, Total) VALUES (1, 60);
INSERT INTO dbo.DetallePedido (PedidoID, ProductoID, Cantidad, PrecioUnit) VALUES (1, 1, 3, 20);

-- 2. TRIGGERS (REGLA AUTOMATICA)
--   Idea: cada vez que se inserta/actualiza un pedido se revisa que Total <= LimiteCredito.
--   Recuerda: inserted tiene los registros nuevos y deleted los viejos.
--   Si la regla se rompe, lanza un error y se cancela todo.
--   ¿Cuándo usar CHECK y cuándo un TRIGGER?
--      CHECK: regla sencilla que solo usa columnas de la misma fila
--             (ej. Total >= 0, Estado IN ('A','B')). Son mas rapidos y faciles de mantener.
--      TRIGGER: cuando la regla necesita datos de otra tabla, comparar antes/despues
--               o ejecutar acciones (registrar historial, recalcular totales).
--      Regla práctica: intenta primero un CHECK; si no alcanza porque necesitas consultar
--      otra tabla o varias filas a la vez, entonces diseña un trigger.

DROP TRIGGER IF EXISTS dbo.trg_Pedido_ValidaTotal;
GO
CREATE TRIGGER dbo.trg_Pedido_ValidaTotal
ON dbo.Pedido
AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (
		SELECT 1
		FROM inserted i
		JOIN dbo.Cliente c ON c.ClienteID = i.ClienteID
		WHERE i.Total > c.LimiteCredito
	)
	BEGIN
		THROW 50001, 'El pedido supera el limite de credito.', 1;
	END;
END;
GO

-- Probar el trigger rapidamente
UPDATE dbo.Cliente SET LimiteCredito = 50 WHERE ClienteID = 1;
BEGIN TRY
	UPDATE dbo.Pedido SET Total = 200 WHERE PedidoID = 1; -- deberia fallar
END TRY
BEGIN CATCH
	PRINT CONCAT('Trigger funcionando: ', ERROR_MESSAGE());
END CATCH;

-- 3. PROCEDIMIENTOS Y FUNCIONES (USA ESTOS PATRONES)
--   Procedimiento = bloque que puede escribir en tablas.
--   Funcion = bloque que solo devuelve datos; no puede modificar tablas.

-- Procedimiento: crea pedido nuevo a partir de lineas
DROP PROCEDURE IF EXISTS dbo.Pedido_Crear;
GO
CREATE OR ALTER PROCEDURE dbo.Pedido_Crear
	@ClienteID INT,
	@Total     DECIMAL(12,2),
	@PedidoID  INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRAN;

		INSERT INTO dbo.Pedido (ClienteID, Total)
		VALUES (@ClienteID, @Total);

		SET @PedidoID = SCOPE_IDENTITY();

		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		THROW;
	END CATCH;
END;
GO

-- Funcion escalar: suma los pedidos del cliente
DROP FUNCTION IF EXISTS dbo.fn_TotalPedidosCliente;
GO
CREATE OR ALTER FUNCTION dbo.fn_TotalPedidosCliente (@ClienteID INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
	RETURN (
		SELECT ISNULL(SUM(Total), 0)
		FROM dbo.Pedido
		WHERE ClienteID = @ClienteID
	);
END;
GO

-- Prueba rapida
DECLARE @NuevoPedido INT;
EXEC dbo.Pedido_Crear @ClienteID = 1, @Total = 40, @PedidoID = @NuevoPedido OUTPUT;
SELECT @NuevoPedido AS PedidoGenerado;
SELECT dbo.fn_TotalPedidosCliente(1) AS TotalCliente1;

-- 4. TRANSACCIONES (CONTROL TOTAL)
--   1) BEGIN TRAN para empezar.
--   2) Haz tus operaciones.
--   3) Si todo va bien -> COMMIT, si algo falla -> ROLLBACK.
--   4) TRY/CATCH evita que se quede una transaccion abierta.
--   5) XACT_ABORT ON hace rollback automatico en errores graves.

SET XACT_ABORT ON;
BEGIN TRY
	BEGIN TRAN;

	UPDATE dbo.Cliente
	SET LimiteCredito = LimiteCredito - 40
	WHERE ClienteID = 1;

	INSERT INTO dbo.Pedido (ClienteID, Total)
	VALUES (1, 40);

	COMMIT TRAN;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRAN;
	THROW; -- vuelve a lanzar el error para que se vea
END CATCH;

SELECT @@TRANCOUNT AS DebeSerCero;

-- 5. RECORDATORIOS EXPRESS
--   - sp_help 'dbo.Cliente' te muestra columnas y claves de la tabla.
--   - INFORMATION_SCHEMA.TABLES/COLUMNS sirve para listar tablas y columnas.
--   - Usa PRINT o SELECT para mostrar IDs nuevos y no perderte.
--   - Si algo falla, revisa primero los CHECK, luego el trigger, luego las FK.
--   - Antes de entregar, ejecuta todo desde arriba: gracias a DROP IF EXISTS
--     deberia correr sin interrupciones.

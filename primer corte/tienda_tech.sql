-- =====================================================
-- DDL: CREACION DE BASE DE DATOS Y TABLAS
-- =====================================================
DROP DATABASE IF EXISTS tienda_tech;
CREATE DATABASE tienda_tech CHARACTER SET utf8mb4;
USE tienda_tech;

CREATE TABLE clientes (
    cliente_id      INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    ciudad          VARCHAR(60),
    fecha_registro  DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE productos (
    producto_id  INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    categoria    VARCHAR(60),
    precio       DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock        INT DEFAULT 0
);

CREATE TABLE pedidos (
    pedido_id    INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id   INT NOT NULL,
    producto_id  INT NOT NULL,
    cantidad     INT NOT NULL CHECK (cantidad > 0),
    fecha_pedido DATE DEFAULT (CURRENT_DATE),
    estado       VARCHAR(20) DEFAULT "pendiente"
        CHECK (estado IN ("pendiente","entregado","cancelado")),
    FOREIGN KEY (cliente_id)  REFERENCES clientes(cliente_id),
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
);

-- =====================================================
-- DML: DATOS DE PRUEBA
-- =====================================================
INSERT INTO clientes VALUES
 (1,"Ana Lopez","ana@mail.com","Bogota","2023-01-15"),
 (2,"Carlos Ruiz","carlos@mail.com","Medellin","2023-03-22"),
 (3,"Maria Torres","maria@mail.com","Cali","2023-05-10"),
 (4,"Pedro Gomez","pedro@mail.com","Bogota","2023-07-08"),
 (5,"Sofia Herrera","sofia@mail.com","Barranquilla","2023-09-01"),
 (6,"Luis Martinez","luis@mail.com","Bogota","2024-01-20"),
 (7,"Camila Vargas","camila@mail.com","Cali","2024-02-14"),
 (8,"Diego Morales","diego@mail.com","Medellin","2024-03-30");

INSERT INTO productos VALUES
 (1,"Laptop Pro 15","Computadores",3500000.00,12),
 (2,"Mouse Inalambrico","Perifericos",85000.00,50),
 (3,"Teclado Mecanico","Perifericos",220000.00,30),
 (4,"Monitor 27","Pantallas",1200000.00,8),
 (5,"Auriculares BT","Audio",350000.00,25),
 (6,"Webcam HD","Perifericos",180000.00,20),
 (7,"Disco SSD 1TB","Almacenamiento",420000.00,40),
 (8,"Tablet 10","Moviles",1800000.00,6);

INSERT INTO pedidos VALUES
 (1,1,1,1,"2024-01-10","entregado"),(2,1,2,2,"2024-01-15","entregado"),
 (3,2,3,1,"2024-02-05","entregado"),(4,2,5,1,"2024-02-20","cancelado"),
 (5,3,4,1,"2024-03-01","entregado"),(6,3,7,2,"2024-03-15","pendiente"),
 (7,4,2,3,"2024-04-02","entregado"),(8,4,6,1,"2024-04-10","pendiente"),
 (9,5,8,1,"2024-04-18","entregado"),(10,6,1,2,"2024-05-05","entregado"),
 (11,6,3,1,"2024-05-12","pendiente"),(12,7,5,2,"2024-05-20","entregado"),
 (13,1,7,1,"2024-06-01","entregado"),(14,8,4,1,"2024-06-10","cancelado"),
 (15,5,2,4,"2024-06-15","entregado"),(16,3,1,1,"2024-07-01","pendiente");

-- =========================================================================
-- DDL y DML BÁSICO 
-- =========================================================================

-- Agregar columna total_valor e índice sobre estado
ALTER TABLE pedidos
ADD total_valor DECIMAL(12,2);

SET SQL_SAFE_UPDATES = 0;

-- Actualizar total_valor con JOIN entre pedidos y productos
UPDATE pedidos p
JOIN productos pr ON p.producto_id = pr.producto_id
SET p.total_valor = (p.cantidad * pr.precio);

SET SQL_SAFE_UPDATES = 1;

-- Índice sobre la columna estado
CREATE INDEX idx_estado ON pedidos(estado);

-- Tabla de auditoría de cambios de estado
CREATE TABLE log_cambios_estado (
    log_id          INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id       INT,
    estado_anterior VARCHAR(20),
    estado_nuevo    VARCHAR(20),
    fecha_cambio    DATETIME DEFAULT NOW(),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id)
);

-- Agregar columna descuento con restricción CHECK
ALTER TABLE productos
ADD descuento DECIMAL(5,2) DEFAULT 0 CHECK (descuento BETWEEN 0 AND 50);

-- Transacción DML múltiple en una sola sesión
START TRANSACTION;
    -- Insertar nuevo cliente
    INSERT INTO clientes (nombre, email, ciudad)
    VALUES ('Laura Rios', 'laura@mail.com', 'Manizales');

    SET @nuevo_cliente_id = LAST_INSERT_ID();

    -- Insertar pedido para ese cliente
    INSERT INTO pedidos (cliente_id, producto_id, cantidad, estado)
    VALUES (@nuevo_cliente_id, 3, 2, 'pendiente');

    -- Actualizar stock del producto_id = 3
    UPDATE productos
    SET stock = stock - 2
    WHERE producto_id = 3;

    -- Consultar con JOIN el pedido recién creado
    SELECT c.nombre AS nombre_cliente, pr.nombre AS nombre_producto, p.estado
    FROM pedidos p
    JOIN clientes c  ON p.cliente_id  = c.cliente_id
    JOIN productos pr ON p.producto_id = pr.producto_id
    WHERE c.cliente_id = @nuevo_cliente_id;
COMMIT;


-- =========================================================================
-- SUBCONSULTAS Y MULTITABLA 
-- =========================================================================

SET SQL_SAFE_UPDATES = 0;

-- UPDATE con subconsulta correlacionada — incrementar precio 8%
UPDATE productos p1
SET p1.precio = p1.precio * 1.08
WHERE p1.stock < (
    SELECT AVG(p2.stock)
    FROM (SELECT categoria, stock FROM productos) p2
    WHERE p1.categoria = p2.categoria
);

-- DELETE con NOT EXISTS — eliminar cancelados sin pedidos entregados
DELETE FROM pedidos
WHERE estado = 'cancelado'
AND NOT EXISTS (
    SELECT 1
    FROM (SELECT cliente_id, estado FROM pedidos) p2
    WHERE p2.cliente_id = pedidos.cliente_id
    AND p2.estado = 'entregado'
);

SET SQL_SAFE_UPDATES = 1;

-- SELECT con JOIN triple y subconsulta escalar AVG
SELECT c.nombre, c.ciudad, pr.nombre AS producto, p.cantidad, p.fecha_pedido
FROM pedidos p
JOIN clientes c   ON p.cliente_id  = c.cliente_id
JOIN productos pr ON p.producto_id = pr.producto_id
WHERE p.estado = 'entregado'
AND (p.cantidad * pr.precio) > (
    SELECT AVG(pe.cantidad * pro.precio)
    FROM pedidos pe
    JOIN productos pro ON pe.producto_id = pro.producto_id
    WHERE pe.estado = 'entregado'
)
ORDER BY (p.cantidad * pr.precio) DESC;


-- =========================================================================
-- FUNCIONES
-- NOTA: Las funciones van ANTES de las vistas porque vista_catalogo_clasificado
--       y otras dependen de fn_clasificar_producto y fn_precio_final.
-- =========================================================================

DROP FUNCTION IF EXISTS fn_ingreso_cliente;
DROP FUNCTION IF EXISTS fn_stock_suficiente;
DROP FUNCTION IF EXISTS fn_clasificar_producto;
DROP FUNCTION IF EXISTS fn_precio_final;

DELIMITER //

-- Función con JOIN — ingreso total acumulado de un cliente
CREATE FUNCTION fn_ingreso_cliente(p_cliente_id INT)
RETURNS DECIMAL(12,2) DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(12,2);

    SELECT COALESCE(SUM(p.cantidad * pr.precio), 0) INTO v_total
    FROM pedidos p
    JOIN productos pr ON p.producto_id = pr.producto_id
    WHERE p.cliente_id = p_cliente_id AND p.estado = 'entregado';

    RETURN v_total;
END //

-- Función de validación booleana — stock suficiente (1 o 0)
CREATE FUNCTION fn_stock_suficiente(p_producto_id INT, p_cantidad_solicitada INT)
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE v_stock INT;

    SELECT stock INTO v_stock FROM productos WHERE producto_id = p_producto_id;

    IF v_stock >= p_cantidad_solicitada THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END //

-- Función con IF/ELSEIF — clasificar producto por precio
CREATE FUNCTION fn_clasificar_producto(p_producto_id INT)
RETURNS VARCHAR(20) DETERMINISTIC
BEGIN
    DECLARE v_precio        DECIMAL(10,2);
    DECLARE v_clasificacion VARCHAR(20);

    SELECT precio INTO v_precio FROM productos WHERE producto_id = p_producto_id;

    IF v_precio > 1000000 THEN
        SET v_clasificacion = 'PREMIUM';
    ELSEIF v_precio BETWEEN 200000 AND 1000000 THEN
        SET v_clasificacion = 'ESTANDAR';
    ELSE
        SET v_clasificacion = 'BASICO';
    END IF;

    RETURN v_clasificacion;
END //

-- Función — precio final aplicando descuento
CREATE FUNCTION fn_precio_final(p_producto_id INT)
RETURNS DECIMAL(12,2) DETERMINISTIC
BEGIN
    DECLARE v_precio    DECIMAL(10,2);
    DECLARE v_descuento DECIMAL(5,2);

    SELECT precio, descuento INTO v_precio, v_descuento
    FROM productos WHERE producto_id = p_producto_id;

    RETURN v_precio * (1 - v_descuento / 100);
END //

DELIMITER ;

-- clientes ordenados por ingreso total
SELECT nombre, ciudad, fn_ingreso_cliente(cliente_id) AS ingreso_total
FROM clientes
ORDER BY ingreso_total DESC;

-- productos con stock insuficiente para 5 unidades
SELECT nombre, stock
FROM productos
WHERE fn_stock_suficiente(producto_id, 5) = 0;

-- TOP 3 productos por precio final
SELECT nombre, precio, descuento, fn_precio_final(producto_id) AS precio_final
FROM productos
ORDER BY precio_final DESC
LIMIT 3;


-- =========================================================================
-- VISTAS 
-- =========================================================================

-- Vista con los últimos 10 registros de log de cambios
CREATE OR REPLACE VIEW vista_log_reciente AS
SELECT * FROM log_cambios_estado
ORDER BY fecha_cambio DESC
LIMIT 10;

-- Vista con agrupamiento de ventas por ciudad
CREATE OR REPLACE VIEW vista_ventas_ciudad AS
SELECT
    c.ciudad,
    COUNT(p.pedido_id)          AS total_pedidos_entregados,
    SUM(p.cantidad * pr.precio) AS suma_ingresos,
    AVG(p.cantidad * pr.precio) AS promedio_ingreso_por_pedido
FROM clientes c
JOIN pedidos p   ON c.cliente_id   = p.cliente_id
JOIN productos pr ON p.producto_id = pr.producto_id
WHERE p.estado = 'entregado'
GROUP BY c.ciudad;

-- ciudades con ingresos mayores a 5,000,000
SELECT * FROM vista_ventas_ciudad
WHERE suma_ingresos > 5000000
ORDER BY suma_ingresos DESC;

-- Vista de productos pedidos por más de un cliente distinto
CREATE OR REPLACE VIEW vista_productos_populares AS
SELECT
    pr.producto_id,
    pr.nombre,
    pr.categoria,
    pr.precio,
    COUNT(DISTINCT p.cliente_id) AS total_clientes_distintos
FROM productos pr
JOIN pedidos p ON pr.producto_id = p.producto_id
WHERE p.estado = 'entregado'
GROUP BY pr.producto_id, pr.nombre, pr.categoria, pr.precio
HAVING COUNT(DISTINCT p.cliente_id) > 1;

-- productos populares en categoría Perifericos
SELECT * FROM vista_productos_populares
WHERE categoria = 'Perifericos';

-- Vista de pedidos pendientes con días de espera
CREATE OR REPLACE VIEW vista_pedidos_pendientes AS
SELECT
    p.pedido_id,
    c.nombre AS nombre_cliente,
    pr.nombre AS nombre_producto,
    p.cantidad,
    pr.precio AS precio_unitario,
    DATEDIFF(CURDATE(), p.fecha_pedido)  AS dias_espera
FROM pedidos p
JOIN clientes c   ON p.cliente_id  = c.cliente_id
JOIN productos pr ON p.producto_id = pr.producto_id
WHERE p.estado = 'pendiente';

-- Consulta de prueba 
SELECT * FROM vista_pedidos_pendientes;

-- Vista catálogo con clasificación usando fn_clasificar_producto
CREATE OR REPLACE VIEW vista_catalogo_clasificado AS
SELECT
    nombre,
    categoria,
    precio,
    fn_clasificar_producto(producto_id) AS clasificacion,
    stock
FROM productos;

-- solo productos PREMIUM con stock mayor a 5
SELECT * FROM vista_catalogo_clasificado
WHERE clasificacion = 'PREMIUM' AND stock > 5;

-- Vista clientes VIP (más pedidos entregados que el promedio)
CREATE OR REPLACE VIEW vista_clientes_vip AS
SELECT
    c.cliente_id,
    c.nombre,
    c.ciudad,
    COUNT(p.pedido_id) AS total_pedidos_entregados
FROM clientes c
JOIN pedidos p ON c.cliente_id = p.cliente_id
WHERE p.estado = 'entregado'
GROUP BY c.cliente_id, c.nombre, c.ciudad
HAVING COUNT(p.pedido_id) > (
    SELECT AVG(conteo) FROM (
        SELECT COUNT(pedido_id) AS conteo
        FROM pedidos
        WHERE estado = 'entregado'
        GROUP BY cliente_id
    ) sub
);

-- últimos 2 pedidos de cada cliente VIP
SELECT v.nombre AS nombre_cliente, pr.nombre AS nombre_producto, p.fecha_pedido
FROM vista_clientes_vip v
JOIN (
    SELECT p2.*,
           ROW_NUMBER() OVER (PARTITION BY p2.cliente_id ORDER BY p2.fecha_pedido DESC) AS rn
    FROM pedidos p2
) p  ON v.cliente_id = p.cliente_id AND p.rn <= 2
JOIN productos pr ON p.producto_id = pr.producto_id
ORDER BY v.nombre, p.fecha_pedido DESC;


-- =========================================================================
-- PROCEDIMIENTOS ALMACENADOS 
-- =========================================================================

DROP PROCEDURE IF EXISTS sp_actualizar_estado_pedido;
DROP PROCEDURE IF EXISTS sp_resumen_cliente;
DROP PROCEDURE IF EXISTS sp_alertar_retrasos;
DROP PROCEDURE IF EXISTS sp_registrar_pedido;

DELIMITER //

-- Procedimiento con auditoría, actualización y restauración de stock
CREATE PROCEDURE sp_actualizar_estado_pedido(
    IN p_pedido_id   INT,
    IN p_nuevo_estado VARCHAR(20)
)
BEGIN
    DECLARE v_estado_actual VARCHAR(20);
    DECLARE v_producto_id   INT;
    DECLARE v_cantidad      INT;

    -- Validar existencia y capturar datos del pedido
    SELECT estado, producto_id, cantidad
    INTO v_estado_actual, v_producto_id, v_cantidad
    FROM pedidos WHERE pedido_id = p_pedido_id;

    IF v_estado_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El pedido no existe';
    ELSE
        -- Insertar registro en log de auditoría
        INSERT INTO log_cambios_estado (pedido_id, estado_anterior, estado_nuevo)
        VALUES (p_pedido_id, v_estado_actual, p_nuevo_estado);

        -- Actualizar el estado del pedido
        UPDATE pedidos SET estado = p_nuevo_estado WHERE pedido_id = p_pedido_id;

        -- Restaurar stock si el nuevo estado es cancelado
        IF p_nuevo_estado = 'cancelado' AND v_estado_actual != 'cancelado' THEN
            UPDATE productos SET stock = stock + v_cantidad WHERE producto_id = v_producto_id;
        END IF;
    END IF;
END //

-- Reporte pivot de pedidos por estado e ingreso total del cliente
CREATE PROCEDURE sp_resumen_cliente(IN p_cliente_id INT)
BEGIN
    SELECT
        c.nombre,
        c.ciudad,
        SUM(CASE WHEN p.estado = 'entregado' THEN 1 ELSE 0 END) AS cant_entregados,
        SUM(CASE WHEN p.estado = 'pendiente' THEN 1 ELSE 0 END) AS cant_pendientes,
        SUM(CASE WHEN p.estado = 'cancelado' THEN 1 ELSE 0 END) AS cant_cancelados,
        COALESCE(SUM(CASE WHEN p.estado = 'entregado'
                     THEN (p.cantidad * pr.precio) ELSE 0 END), 0) AS ingreso_total
    FROM clientes c
    LEFT JOIN pedidos p   ON c.cliente_id   = p.cliente_id
    LEFT JOIN productos pr ON p.producto_id = pr.producto_id
    WHERE c.cliente_id = p_cliente_id
    GROUP BY c.cliente_id, c.nombre, c.ciudad;
END //

-- Procedimiento que alerta retrasos usando vista_pedidos_pendientes
CREATE PROCEDURE sp_alertar_retrasos(IN p_dias_limite INT)
BEGIN
    SELECT *
    FROM vista_pedidos_pendientes
    WHERE dias_espera > p_dias_limite;
END //

-- Procedimiento para registrar un pedido con validaciones
CREATE PROCEDURE sp_registrar_pedido(
    IN p_cliente_id  INT,
    IN p_producto_id INT,
    IN p_cantidad    INT
)
BEGIN
    DECLARE v_cliente_existe  INT;
    DECLARE v_stock           INT;
    DECLARE v_nuevo_pedido_id INT;

    -- Validar que el cliente exista
    SELECT COUNT(*) INTO v_cliente_existe
    FROM clientes WHERE cliente_id = p_cliente_id;

    IF v_cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El cliente no existe';
    ELSE
        -- Validar que el stock sea suficiente
        SELECT stock INTO v_stock
        FROM productos WHERE producto_id = p_producto_id;

        IF v_stock < p_cantidad THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Stock insuficiente';
        ELSE
            -- Insertar el pedido con estado pendiente
            INSERT INTO pedidos (cliente_id, producto_id, cantidad, estado)
            VALUES (p_cliente_id, p_producto_id, p_cantidad, 'pendiente');

            SET v_nuevo_pedido_id = LAST_INSERT_ID();

            -- Descontar la cantidad del stock
            UPDATE productos
            SET stock = stock - p_cantidad
            WHERE producto_id = p_producto_id;

            -- Retornar el pedido recién creado con JOIN
            SELECT p.pedido_id, c.nombre AS nombre_cliente,
                   pr.nombre AS nombre_producto, p.cantidad, p.estado, p.fecha_pedido
            FROM pedidos p
            JOIN clientes c   ON p.cliente_id  = c.cliente_id
            JOIN productos pr ON p.producto_id = pr.producto_id
            WHERE p.pedido_id = v_nuevo_pedido_id;
        END IF;
    END IF;
END //

DELIMITER ;

-- =====================================================
-- PRUEBAS DE PROCEDIMIENTOS
-- =====================================================

-- cambiar estado del pedido 8 a entregado
CALL sp_actualizar_estado_pedido(8, 'entregado');

-- resumen del cliente 1
CALL sp_resumen_cliente(1);

-- pedidos con más de 30 días de espera
CALL sp_alertar_retrasos(30);

-- registrar un nuevo pedido
CALL sp_registrar_pedido(2, 7, 1);

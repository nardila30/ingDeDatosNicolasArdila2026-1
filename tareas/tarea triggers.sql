-- SENTENCIAS DML: Lenguaje de Manipulacion de datos
-- 0. es crear la estructura de la BD (modelo físico-diccionario de datos)
-- 1. DATOS PUROS O LIMPIOS (ETL)
-- 2. Manipulacion de datos (hacer registros, consultar registros, modificar registros, eliminar registros)
-- un logica transaccional (sentencias) (indicacion orden una petición transacción) MySQL SQL
-- trabajar sobre el contenido
-- Transaccional: Crear-Insertar Agregar registros (insert)
-- Modificar actualizar (Update)
-- Consultas sobre la BD (Select)
-- Eliminar (Delete)

-- Insert (agregar crear registra insertar datos
-- consulta general select * from nombre_tabla
create database if not exists tiendaOnline;
use tiendaOnline;

create table if not exists clientes(
idCliente int primary key auto_increment,
nombreCliente varchar(100) not null,
emailCliente varchar(150) unique,
ciudad varchar(80) null,
creado_en datetime default now()
);

create table if not exists productos(
idProducto int primary key auto_increment,
nombreProducto varchar(120) not null,
precioProducto decimal(10,2),
stockProducto int default 0,
categoriaProducto varchar(60)
);

create table if not exists pedido(
idPedido int primary key auto_increment,
cantidadProducto int not null,
fechaPedido date,
idClienteFK int,
idProductoFK int,
foreign key (idClienteFK) references clientes(idCliente),
foreign key (idProductoFK) references productos(idProducto)
);

create table if not exists cliente_backup (
idClienBack int primary key auto_increment,
nombreCliente varchar(100),
emailCliente varchar(150),
copiado_en datetime default now()
);

create table if not exists historial_clientes(
idHistorial int primary key auto_increment,
idCliente int,
nombreAnterior varchar(100),
nombreNuevo varchar(100),
ciudadAnterior varchar(80),
ciudadNueva varchar(80),
fechaCambio datetime default now()
);

create table if not exists pedidos_eliminados(
idEliminado int primary key auto_increment,
idPedidoOriginal int,
cantidadProducto int,
fechaPedido date,
idClienteFK int,
idProductoFK int,
fechaEliminacion datetime default now()
);

-- select consulta general de las tablas 
select * from clientes;

select * from productos;

select * from pedido;


-- Inserciones insert into nombre_tabla (campos1,campo2,campo3,...) values (valor1,valor2,valor3,...)
-- si el campo es varchar va entre comillas
-- si el campo es autoincrement s debe enviar el campo sin valor ''
-- si el campo es una fecha debe revisar el formato

-- Agregar 1 registro
describe clientes;
insert ignore into clientes(idCliente,nombreCliente,emailCliente,ciudad) values ('','Ana Garcia','ana@mail.com','Madrid');
insert ignore into clientes(nombreCliente,emailCliente,ciudad) values ('Pedro Perez','pedro@mail.com','Barcelona');
select * from clientes;
-- Agregar Varios registros
describe productos;
insert ignore into productos (nombreProducto,precioProducto,stockProducto,categoriaProducto)
values ('Laptop Pro',1200000,15,'Electrónica'), 
('Mouse USB',50000,80,'Accesorios'),
('Monitor 32"',500000,20,'Electrónica'),
('Teclados',100000,35,'Accesorios');

select * from productos;

insert ignore into cliente_backup (nombreCliente,emailCliente)
select nombreCliente,emailCliente
from clientes
where creado_en<'2026-03-20';

select * from cliente_backup;

describe cliente_backup;

-- Update actualizar o modificar los registros en una tabla
-- update nombreTabla set columna1=valor1,columna2=valor2,.... where condicion
select * from clientes;
-- Actualizar un campo
update clientes
set ciudad='Valencia'
where idCliente=1;

-- Actualizar varios campos
select * from productos;

update productos
set
precioProducto=1099000,
stockProducto=10
where idProducto=1;

update productos
set precioProducto=precioProducto * 1.10
where categoriaProducto='Accesorios';

-- delete eliminar registro  Where 

-- investigar los metodos de tipo numericos y caracteres en MySQL
-- investigar si se puede o no revertir una eliminacion de registros pista rollback csi se puede como
-- delete from nombre_tabla where condicion

select * from clientes;
delete from clientes 
where idCliente=2;

select * from productos;
delete from productos
where stockProducto=0 AND categoriaProducto='Descatalogado';

/* NSERT
1. Inserta 3 clientes nuevos con nombre, email y ciudad
2. Inserta 2 productos con nombre, precio, stock y categoría
3. Inserta 1 pedido vinculando un cliente y un producto recién creados
UPDATE
4. Cambia la ciudad de uno de tus clientes insertados
5. Aumenta en 5 unidades el stock de uno de tus productos
6. Modifica el precio del segundo producto aplicando un descuento del 10%
DELETE
7. Elimina el pedido que creaste en el punto 3
8. Elimina el cliente cuya ciudad cambiaste en el punto 4
9. Elimina todos los productos con stock menor a 3

*/

SET SQL_SAFE_UPDATES = 1;
SET SQL_SAFE_UPDATES = 0;
use tiendaonline;
describe productos;
alter table productos change stockProducto stoProT int(11);

### Sentencia para consultas

select nombreProducto, stoProT from productos;

select nombreProducto as Nombre_Producto, stoProT as stock from productos;

select nombreProducto, stoProT from productos where idProducto=1 ;
select nombreProducto as Nombre_Producto, stoProT as stock from productos where stoProT>=15 and idProducto=1;

select nombreProducto as Nombre_Producto, stoProT as stock 
from productos 
where stoProT>=15 and nombreProducto='Laptop Pro';
### select campos from nombre_tabla order by campo_a_ordenar formaOrden(ASC DESC) 
select nombreProducto as Nombre_Producto, stoProT as stock 
from productos order by nombreProducto DESC;

select nombreProducto as Nombre_Producto, stoProT as stock 
from productos order by nombreProducto ASC;

select nombreProducto as Nombre_Producto, stoProT as stock from productos where stoProT>=25 OR idProducto=1;

## BETWEEN 
## SELECT * FROM NOMBRE_TABLA BETWEEN VALO1 AND VALOR2
select * from productos;
select nombreProducto as Nombre_Producto, precioProducto as precio
 from productos where precioProducto between 50000 and 100000 and stoProT>3 order by precioProducto asc;

##Like que inicien que terminen o que contenga caracteres
## que inicien
select * from productos where nombreProducto not like 'mon%';

## que contenga
select * from productos where nombreProducto not like '%o%';

#que termine
select * from productos where nombreProducto like '%os' order by precioProducto asc limit 10;
use tiendaonline;
## Carga de archivos

load data infile 'C:\ruta\clientes.csv'
into table clientes
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

set foreign_key_checks=0;
set foreign_key_checks=1;
/*Agrupar Group by select camposConsultar from nombreTabla group by campoAgrupar*/

describe productos;

select * from productos group by categoriaProducto;

select categoriaProducto,
 count(*) as Cantidad,
 avg(precioProducto) as promedioMedio
 from productos
 group by categoriaProducto
 having avg(precioProducto)>5000
 order by promedioMedio desc;
 
 select format (precioProducto,2,'es_CO') as precio 
 from productos;
 
 /*funciones calculadas*/
 describe productos;
 select
 count(*) as Total,
 avg(precioProducto) as PromedioPrecio,
 max(precioProducto) as PrecioMaximo,
 min(precioProducto) as PrecioMinimo,
 sum(stoProT) as StockTotal
 from productos;
 
 use tiendaonline;
 
 describe clientes;

select nombreCliente as nombre,
 upper(nombreCliente) as NombreMayuscula,
 concat('nombre Cliente: ',nombreCliente,' email cliente:',emailCliente) as concatenar,
 length(nombreCliente) as TamanioNombre
 from clientes;
 
 ##Subconsultas

/* disparadores Triggers
tipos
before insert, before update, 
before delete: se ejecutan antes de la operación.

after insert, after update, 
after delete: se ejecutan despues de la operación.

sintaxis
DELIMITER //
CREATE TRIGGER nombreTrigger
AFTER INSERT ON nombreTabla
FOR EACH ROW
BEGIN
-- INSTRUCCIONES SQL

END //
DELIMITER ;
*/

/*Trigger para validar que el precio de un producto no sea negativo*/
DROP TRIGGER IF EXISTS validar_precio_producto;
DELIMITER //
CREATE TRIGGER validar_precio_producto
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    IF NEW.precioProducto < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio del producto no puede ser negativo';
    END IF;
END //
DELIMITER ;

/*Trigger para validar que exista stock suficiente antes de registrar un pedido*/
DROP TRIGGER IF EXISTS validar_stock_pedido;
DELIMITER //
CREATE TRIGGER validar_stock_pedido
BEFORE INSERT ON pedido
FOR EACH ROW
BEGIN
    DECLARE stockActual INT;
    SELECT stoProT INTO stockActual FROM productos WHERE idProducto = NEW.idProductoFK;
    IF stockActual < NEW.cantidadProducto THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para realizar el pedido';
    END IF;
END //
DELIMITER ;

/*Trigger para descontar el stock del producto cuando se inserta un pedido*/
DROP TRIGGER IF EXISTS descontar_stock_pedido;
DELIMITER //
CREATE TRIGGER descontar_stock_pedido
AFTER INSERT ON pedido
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stoProT = stoProT - NEW.cantidadProducto
    WHERE idProducto = NEW.idProductoFK;
END //
DELIMITER ;

/*Trigger para ajustar el stock cuando se modifica la cantidad de un pedido*/
DROP TRIGGER IF EXISTS ajustar_stock_pedido;
DELIMITER //
CREATE TRIGGER ajustar_stock_pedido
AFTER UPDATE ON pedido
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stoProT = stoProT + OLD.cantidadProducto - NEW.cantidadProducto
    WHERE idProducto = NEW.idProductoFK;
END //
DELIMITER ;

/*Trigger para devolver el stock y registrar el pedido eliminado en la papelera*/
DROP TRIGGER IF EXISTS devolver_stock_pedido;
DELIMITER //
CREATE TRIGGER devolver_stock_pedido
AFTER DELETE ON pedido
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stoProT = stoProT + OLD.cantidadProducto
    WHERE idProducto = OLD.idProductoFK;
    
    INSERT INTO pedidos_eliminados (idPedidoOriginal, cantidadProducto, fechaPedido, idClienteFK, idProductoFK)
    VALUES (OLD.idPedido, OLD.cantidadProducto, OLD.fechaPedido, OLD.idClienteFK, OLD.idProductoFK);
END //
DELIMITER ;

/*Trigger para respaldar automáticamente al cliente cuando se inserta*/
DROP TRIGGER IF EXISTS backup_cliente_nuevo;
DELIMITER //
CREATE TRIGGER backup_cliente_nuevo
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO cliente_backup (nombreCliente, emailCliente)
    VALUES (NEW.nombreCliente, NEW.emailCliente);
END //
DELIMITER ;

/*Trigger para registrar en historial los cambios realizados a un cliente*/
DROP TRIGGER IF EXISTS registrar_cambio_cliente;
DELIMITER //
CREATE TRIGGER registrar_cambio_cliente
AFTER UPDATE ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO historial_clientes (idCliente, nombreAnterior, nombreNuevo, ciudadAnterior, ciudadNueva)
    VALUES (OLD.idCliente, OLD.nombreCliente, NEW.nombreCliente, OLD.ciudad, NEW.ciudad);
END //
DELIMITER ;

/*Trigger tipo papelera para guardar al cliente antes de ser eliminado*/
DROP TRIGGER IF EXISTS papelera_clientes;
DELIMITER //
CREATE TRIGGER papelera_clientes
BEFORE DELETE ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO cliente_backup (nombreCliente, emailCliente)
    VALUES (OLD.nombreCliente, OLD.emailCliente);
END //
DELIMITER ;
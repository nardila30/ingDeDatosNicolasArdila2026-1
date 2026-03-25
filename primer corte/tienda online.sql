create database if not exists tiendaOnline;
use tiendaOnline;

create table clientes(
idCliente int primary key auto_increment,
nombreCliente varchar(100) not null,
emailCliente varchar(150) unique,
ciudad varchar(80) null,
creado_en datetime default now()
);

create table productos(
idProducto int primary key auto_increment,
nombreProducto varchar(120) not null,
precioProducto decimal(10,2),
stockProducto int default 0,
categoriaProducto varchar(60)
);

create table pedido(
idPedido int primary key auto_increment,
cantidadProducto int not null,
fechaPedido date,
idClienteFK int,
idProductoFK int,
foreign key (idClienteFK) references clientes(idCliente),
foreign key (idProductoFK) references productos(idProducto)
);

create table cliente_cbackup (
idClienBack int primary key auto_increment,
nombreCliente varchar(100) ,
emailCliente varchar(150),
copiado_en datetime default now()
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
insert into clientes(idCliente,nombreCliente,emailCliente,ciudad) values ('','Ana Garcia','ana@mail.com','Madrid');
insert into clientes(nombreCliente,emailCliente,ciudad) values ('Pedro Perez','pedro@mail.com','Barcelona');
 select * from clientes;
-- Agregar Varios registros
describe productos;
insert into productos (nombreProducto,precioProducto,stockProducto,categoriaProducto)
values ('Laptop Pro',1200000,15,'Electrónica'), 
('Mouse USB',50000,80,'Accesorios'),
('Monitor 32"',500000,20,'Electrónica'),
('Teclados',100000,35,'Accesorios');

select * from productos;

insert into cliente_backup (nombreCliente,emailCliente)
select nombreCliente,emailCliente
from clientes
where creado_en<'2026-03-20';

rename table cliente_cbackup to cliente_backup;

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

-- 1.
insert into clientes(nombreCliente,emailCliente,ciudad)
values
('Carlos Lopez','carlos@mail.com','Sevilla'),
('Maria Torres','maria@mail.com','Bogota'),
('Luis Ramirez','luis@mail.com','Lima');

-- 2.
insert into productos(nombreProducto,precioProducto,stockProducto,categoriaProducto)
values
('Tablet Samsung',900000,12,'Electrónica'),
('Audifonos Bluetooth',150000,8,'Accesorios');

-- 3.
insert into pedido(cantidadProducto,fechaPedido,idClienteFK,idProductoFK)
values (1,'2026-03-25',3,5);

-- 4.
update clientes
set ciudad='Valencia'
where nombreCliente='Carlos Lopez';

-- 5.
update productos
set stockProducto = stockProducto + 5
where nombreProducto='Tablet Samsung';

-- 6. 
update productos
set precioProducto = precioProducto * 0.90
where nombreProducto='Audifonos Bluetooth';

-- 7.
delete from pedido
where idClienteFK=3 and idProductoFK=5;

-- 8.
delete from clientes
where nombreCliente='Carlos Lopez';

-- 9. 
delete from productos
where stockProducto < 3;


SET SQL_SAFE_UPDATES = 1;
SET SQL_SAFE_UPDATES = 0;

describe productos; 
alter table productos change stockProducto stoPrdT int; 

-- consulta general
select nombreProducto, stoPrdT from productos;
select nombreProducto as Nombre_Producto, stoPrdT as stock from productos;
select nombreProducto, stoPrdT from productos where idProducto=1 ;
select nombreProducto as Nombre_Producto, stoPrdT as stock from productos where stoPrdT>= 15;
select nombreProducto as Nombre_Producto, stoPrdT as stock from productos where stoPrdT>= 15 and idPRoducto='Laptop Pro';

### select campos from nombre_tabla order by campo_a_ordenar formaOrden (ACD DESC)

select nombreProducto as Nombre_Producto, stoPrdT as stock from productos order by stoPrdT ASC; 
select nombreProducto as Nombre_Producto, stoPrdT as stock from productos order by nombreProducto ASC; 
select nombreProducto as Nombre_Producto, stoPrdT as stock from productos where stoPrdT>=25 or idProducto=1 ;

### BETWEEN   
### SELECT * FROM NOMBRE_TABLA BETWEEN VALOR1 AND VALOR2
select nombreProducto as Nombre_Producto, precioProducto as precio 
from productos where precioProducto between 50000 and 100000 and stoPrdT>3 order by precioProducto asc;

## consulta LIKE: inicien, terminen o contengan caracteres 
-- que inicie 
select * from productos where nombreProducto like 'm%';

-- que contenga 
select * from productos where nombreProducto like '%o%';

-- que terminen 
select * from productos where nombreProducto like '%s';

-- para ordenar y limitar 
select * from productos where nombreProducto like '%s' order by precioProducto asc limit 10;


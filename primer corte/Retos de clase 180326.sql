# reto 1
create database tienda;
use tienda; 

# reto 2
create table producto(
idproducto int not null,
nomproducto varchar(20) not null,
precio decimal(20,1) not null,
stock int default 0,
fechaCreacion datetime not null CURRENT_TIMESTAMP
);

#reto 3
create table cientes(
idCliente int not null,
nomCliente varchar(50) not null,
emailClinete varchar(50) unique not null,
telefonoCliente varchar(20) 
);

create table pedidos(
idPedido int not null,
idClienteFK int,
fechaPedido date, 
totalPedido decimal(20,1)
);

-- establecer relaciones entre pedidos y cliente 

#reto 4

alter table producto add categrotia varchar(50);

alter table clientes modify column telefono varchar(15);

alter table pedidos change totalPedidos monto_total decimal(20,1);

alter table productos drop column fechaCreacion;


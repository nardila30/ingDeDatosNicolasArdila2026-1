create database companiaseguros;
use companiaseguros;

create table compania(
idCompania varchar (50) primary key,
nit varchar (20) unique not null,
nombreCompania varchar (50) not null,
fachaFundacion date null,
representanteLegal varchar (50)not null);

create table seguros(
idSeguro varchar (50) primary key,
estado varchar (50) not null,
costo double not null,
fechaInicio date not null,
fechaExpiracion date not null,
valorAsegurado double not null,
idCompaniaFK varchar(50) not null,
idAutomovilFK varchar(50) not null);

create table automovil(
idAutomovil varchar (50) primary key,
marca varchar (50) not null,
modelo varchar (50) not null,
placa varchar (20) unique not null,
tipos varchar (30) not null,
anioFabricacion int not null,
serialChasis varchar (50) unique not null,
pasajeros int not null,
cilindraje int not null);
 
create table accidente(
idAccidente varchar (50) primary key,
fechaAccidente date not null,
lugar varchar (100) not null,
automotores int not null,
heridos int not null,
fatalidades int not null);
 
create table automovil_accidente(
idAutomovilAccidente varchar (50) primary key,
idAutomovilFK varchar (50) not null,
idAccidenteFK varchar (50) not null);

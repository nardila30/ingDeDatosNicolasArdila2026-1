## Subconsultas
/* 
Consultas Anidadas (SubQuery)

select col1,col2
from tabla_Principal
where columna operador
    (select col1
     from tabla_Secundaria
     where condicion);

Tipos de subconsultas
Escalar: devuelve un único valor
De fila: devuelve una fila con varias columnas
De tabla: devuelve varias filas y varias columnas
Correlacional: depende de la consulta externa

RETO
1. Crear tablas:
   empleados (id, nombre, deptoId, salario)
   productos (id, nombre, precio, categoria)
   departamentos (id, nombre)

2. Registrar:
   5 empleados
   3 departamentos
   5 productos
*/

CREATE DATABASE IF NOT EXISTS empresa_db;
USE empresa_db;

CREATE TABLE departamentos (
    idDepto INT PRIMARY KEY,
    nombreDepto VARCHAR(50)
);

CREATE TABLE empleados (
    idEmpleado INT PRIMARY KEY,
    nombreEmpleado VARCHAR(50),
    depto_id INT,
    salarioEmpleado DECIMAL(10,2),
    FOREIGN KEY (depto_id) REFERENCES departamentos(idDepto)
);

CREATE TABLE productos (
    idProducto INT PRIMARY KEY,
    nombreProducto VARCHAR(60),
    precioProducto DECIMAL(10,2),
    categoriaProducto VARCHAR(40)
);

INSERT INTO departamentos (idDepto, nombreDepto) VALUES
(1, 'Recursos Humanos'),
(2, 'Tecnología'),
(3, 'Ventas');

INSERT INTO empleados (idEmpleado, nombreEmpleado, depto_id, salarioEmpleado) VALUES
(101, 'Carlos Pérez', 2, 3500000.00),
(102, 'Laura Gómez', 1, 2800000.00),
(103, 'Andrés Rodríguez', 3, 3000000.00),
(104, 'María López', 2, 4000000.00),
(105, 'Juan Martínez', 2, 3700000.00);

INSERT INTO productos (idProducto, nombreProducto, precioProducto, categoriaProducto) VALUES
(201, 'Laptop Lenovo', 2500000.00, 'Tecnología'),
(202, 'Mouse Inalámbrico', 80000.00, 'Accesorios'),
(203, 'Teclado Mecánico', 150000.00, 'Accesorios'),
(204, 'Monitor 24 pulgadas', 700000.00, 'Tecnología'),
(205, 'Silla Ergonómica', 900000.00, 'Oficina');

SELECT * FROM empleados;

SELECT nombreEmpleado, salarioEmpleado
FROM empleados
WHERE salarioEmpleado >
    (SELECT AVG(salarioEmpleado)
     FROM empleados);

SELECT nombreEmpleado, salarioEmpleado
FROM empleados
WHERE depto_id IN
    (SELECT idDepto
     FROM departamentos
     WHERE nombreDepto IN ('Ventas','Tecnología'));


SELECT depto_id, prom_salario
FROM
    (SELECT depto_id, AVG(salarioEmpleado) AS prom_salario
     FROM empleados
     GROUP BY depto_id) AS promedios
WHERE prom_salario > 2800000;


SELECT nombreProducto, precioProducto
FROM productos
WHERE precioProducto >
    (SELECT AVG(precioProducto)
     FROM productos)
ORDER BY precioProducto DESC;

USE classicmodels;

-- 1. Contactos de oficina: Tiene una tabla que contiene los códigos de oficina y sus números de teléfono asociados.
SELECT officeCode, phone
FROM offices;

-- 2. Detectives de correo electrónico: ¿Puede identificar a los empleados cuyas direcciones de correo electrónico terminan en “.es”?
SELECT employeeNumber, firstName, lastName, email
FROM employees
WHERE email LIKE '%.es';

-- 3. Estado de confusión: descubra qué clientes carecen de información estatal en sus registros.
SELECT customerNumber, customerName, city, country
FROM customers
WHERE state IS NULL OR state = '';

-- 4. Grandes gastadores: busquemos pagos que superen los $20.000.
SELECT customerNumber, amount
FROM payments
WHERE amount > 20000;

-- 5. Grandes gastadores de 2005: Ahora, acote la lista aún más y busque los pagos mayores a $20,000 que se realizaron en el año 2005.
SELECT customerNumber, paymentDate, amount
FROM payments
WHERE amount > 20000
  AND YEAR(paymentDate) = 2005;

-- 6. Detalles distintos: busque y muestre solo las filas únicas de la tabla “orderdetails” en función de la columna “productcode”.
SELECT DISTINCT productCode
FROM orderdetails;

-- 7. Estadísticas globales de compradores: por último, cree una tabla que muestre el recuento de compras realizadas por país.
SELECT c.country, COUNT(*) AS Número_Órdenes
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber
GROUP BY c.country;

-- 8. Descripción de línea de producto más larga: descubramos qué línea de producto tiene la descripción de texto más larga.
SELECT productLine, textDescription
FROM productlines
ORDER BY LENGTH(textDescription) DESC
LIMIT 1;


-- 9. Recuento de clientes de oficina: ¿Puede determinar el número de clientes asociados a cada oficina?
SELECT e.officeCode, o.city, COUNT(c.customerNumber) AS Cantidad_Cliente
FROM customers c
JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
JOIN offices o ON e.officeCode = o.officeCode
GROUP BY e.officeCode, o.city;

-- 10. Día de mayores ventas de automóviles: descubra qué día de la semana se registra el mayor número de ventas de automóviles.
SELECT DAYNAME(o.orderDate) AS dia_semana, COUNT(*) AS Núm_Órdenes
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY DAYNAME(o.orderDate)
ORDER BY Núm_Órdenes DESC
LIMIT 1;

-- 11. Corrección de datos territoriales faltantes: Hay algunos valores faltantes (NA) en la variable " territory " de la tabla " offices ". Podemos usar una instrucción "case when" para corregir estos valores y establecerlos en " USA".
SELECT officeCode, city, territory,
CASE
	WHEN territory IS NULL OR territory = '' THEN 'USA'
    ELSE territory
	END AS territory_corregido
FROM offices;

-- 12. Estadísticas de empleados de la familia Patterson: calcule el monto promedio del carrito y el total de artículos, año por mes, para las compras realizadas en los años 2004 y 2005 por clientes asistidos por empleados de la familia Patterson.
SELECT YEAR(o.orderDate) AS anio, MONTH(o.orderDate) AS mes, AVG(od.quantityOrdered * od.priceEach) AS Promedio_Carrito, SUM(od.quantityOrdered) AS Total_Artículos
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
WHERE e.lastName = 'Patterson'
AND YEAR(o.orderDate) IN (2004, 2005)
GROUP BY YEAR(o.orderDate), MONTH(o.orderDate)
ORDER BY anio, mes;

-- 13. Análisis de compras anuales: Analicemos algunos cálculos avanzados mediante subconsultas. Queremos encontrar el importe promedio del carrito y el total de artículos, desglosados por año y mes. Esto se aplica específicamente a las compras realizadas en los años 2004 y 2005, pero nos interesan los clientes atendidos por empleados de la familia Patterson.
SELECT YEAR(fecha) AS Anio, MONTH(fecha) AS Mes, AVG(total_carrito) AS Promedio_Carrito, SUM(total_items) AS Total_Artículos
FROM (
  SELECT o.orderDate AS Fecha, o.orderNumber, SUM(od.quantityOrdered * od.priceEach) AS Total_Carrito, SUM(od.quantityOrdered) AS Total_Items
  FROM orders o
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
  JOIN customers c ON o.customerNumber = c.customerNumber
  JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
  WHERE e.lastName = 'Patterson'
  AND YEAR(o.orderDate) IN (2004, 2005)
  GROUP BY o.orderNumber, o.orderDate
) AS Carrito_Detalles
GROUP BY YEAR(fecha), MONTH(fecha)
ORDER BY anio, mes;

-- 14. Viaje a la oficina: ¡Llegó una misión especial! Visitaremos algunas de nuestras oficinas personalmente. Queremos identificar cuáles tienen empleados que atienden a clientes con información estatal vacía. Visitaremos estas oficinas para charlar y asegurarnos de que todo esté en orden.
SELECT DISTINCT o.officeCode, o.city
FROM offices o
JOIN employees e ON o.officeCode = e.officeCode
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
WHERE c.state IS NULL OR c.state = '';


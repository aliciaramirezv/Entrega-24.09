USE restaurante;

-- ¿Cuál es la cantidad total que gastó cada cliente en el restaurante?
SELECT
    s.customer_id,
    SUM(m.price) AS total_gastado
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- ¿Cuántos días ha visitado cada cliente el restaurante?
SELECT customer_id,
COUNT(DISTINCT order_date) AS Días_visitados
FROM sales
GROUP BY customer_id
ORDER BY customer_id;

-- ¿Cuál fue el primer artículo del menú comprado por cada cliente?
SELECT s.customer_id, m.product_name
FROM sales s
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date = (
    SELECT MIN(order_date) 
    FROM sales 
    WHERE customer_id = s.customer_id
)
GROUP BY s.customer_id, m.product_name
ORDER BY s.customer_id;

-- ¿Cuál es el artículo más comprado en el menú y cuántas veces lo compraron todos los clientes?
SELECT m.product_name,
       COUNT(*) AS Total_comprado
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY Total_comprado DESC, m.product_name
LIMIT 1;

-- ¿Qué artículo fue el más popular para cada cliente?
SELECT customer_id, product_name
FROM (
    SELECT s.customer_id, m.product_name, COUNT(*) AS Compras,
           RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS Rnk
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
) t
WHERE Rnk = 1;

-- ¿Qué artículo compró primero el cliente después de convertirse en miembro?
SELECT s.customer_id, m.product_name, s.order_date
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date >= mb.join_date
  AND (s.customer_id, s.order_date) IN (
      SELECT customer_id, MIN(order_date)
      FROM sales
      WHERE order_date >= (SELECT join_date FROM members WHERE customer_id = sales.customer_id)
      GROUP BY customer_id
  );

-- ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?
SELECT s.customer_id, m.product_name, s.order_date
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
AND (s.customer_id, s.order_date) IN (
	SELECT customer_id, MAX(order_date)
	FROM sales
	WHERE order_date < (SELECT join_date FROM members WHERE customer_id = sales.customer_id)
	GROUP BY customer_id
  );


-- ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
SELECT s.customer_id, COUNT(*) AS Total_artículos,
SUM(m.price) AS Total_gasto
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id;


-- Si cada \$1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos 2x, ¿Cuántos puntos tendría cada cliente?
SELECT s.customer_id,
SUM(
	CASE
	WHEN m.product_name = 'sushi' THEN m.price * 10 * 2
	ELSE m.price * 10
	END
) AS Puntuación
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date >= mb.join_date
GROUP BY s.customer_id;


-- En la primera semana después de que un cliente se une al programa (incluida la fecha de ingreso), gana el doble de puntos en todos los artículos, no solo en sushi. ¿Cuántos puntos tienen los clientes A y B a fines de enero?
SELECT s.customer_id,
SUM(
	CASE
	WHEN s.order_date BETWEEN mb.join_date AND DATE_ADD(mb.join_date, INTERVAL 6 DAY)
	THEN m.price * 10 * 2
	WHEN m.product_name = 'sushi' AND s.order_date > DATE_ADD(mb.join_date, INTERVAL 6 DAY)
	THEN m.price * 10 * 2
	WHEN s.order_date > DATE_ADD(mb.join_date, INTERVAL 6 DAY)
	THEN m.price * 10
	ELSE 0
	END
) 
AS Puntuación
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.customer_id IN ('A','B')
AND s.order_date >= mb.join_date
AND s.order_date < '2021-02-01'
GROUP BY s.customer_id;


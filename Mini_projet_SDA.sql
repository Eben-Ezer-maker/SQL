
# MINI PROJET SQL

#PARTIE A — Exploration de la base Sakila 

--Nous allons utiliser la base de données sakila
USE sakila

1. Affichons la liste des films dont la durée est supérieure à 120 minutes, triés par durée 
décroissante. 
SELECT f.title, length
FROM film f
WHERE length>120
ORDER BY length DESC

la plus grande durée de film est de 185 min 

2. Calculez la durée moyenne des films et affichez uniquement ceux dont la durée 
dépasse cette moyenne. 
  a) durée moyenne des films
  
  SELECT AVG (f.length) AS duree_moyenne
  FROM film f
  
  La durée moyenne des films est: 115.2720
  
  b)films dont la durée dépasse la moyenne
SELECT  f.title, f.length 
FROM film f
WHERE f.length > (SELECT AVG (f.length)
                       FROM film f)


3. Affichons, pour chaque film, son titre, sa catégorie et la langue utilisée. 

SELECT f.title, c.name AS category, l.name AS film_language
FROM film f
JOIN language l
ON f.language_id= l.language_id
JOIN  film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id= c.category_id

	
la langue utilisée est : anglais quelque soit la categorie du film

4. Affichez les 5 films les plus loués avec leur titre et le nombre total de locations. 

SELECT f.title, count(r.rental_id) AS Total_locations
FROM film f
JOIN inventory i ON f.film_id=i.film_id
JOIN rental r ON i.inventory_id= r.inventory_id
GROUP BY f.title
ORDER BY Total_locations DESC
LIMIT 5




les films  5 les plus loués sont BUCKET BROTHERHOOD
ROCKETEER MOTHER
FORWARD TEMPLE
GRIT CLOCKWORK
JUGGLER HARDLY .



5. Calculons le revenu total généré par chaque film et affichez les 5 films les plus 
rentables. 

SELECT f.title, SUM(p.amount) AS Revenu_total
FROM film f
JOIN inventory i ON f.film_id=i.film_id
JOIN rental r ON i.inventory_id=r.inventory_id
JOIN payment p ON r.rental_id=p.rental_id
GROUP BY f.title 
ORDER BY Revenu_total DESC
LIMIT 5


6. Créez une vue nommée vip_clients contenant les clients ayant dépensé plus de 100 
dollars. 

CREATE VIEW Vip_clients AS
SELECT c.customer_id, c.first_name, c.last_name, sum(p.amount) AS depense_total
FROM customer c
JOIN payment p ON c.customer_id=p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING depense_total > 100



7. Insérons un nouvel acteur dans la table actor, puis supprimez-le en respectant les 
contraintes d’intégrité référentielle.

Notre nouvel acteur se nomme :first_name: Didier  , last_name: Drogba  
 
 INSERT INTO actor ( first_name, last_name)
 VALUES ('Didier', 'Drogba')
 
 SELECT actor_id FROM actor
WHERE first_name = 'Didier' AND last_name = 'Drogba'
 
 
 actor_id de Didier Drogba est 201
 
 supprimons les références liées
 
 DELETE FROM film_actor
 WHERE actor_id=201
 
 DELETE FROM actor
 WHERE actor_id=201
 
 je vérifie bien  que Didier Drogba a bien été supprimer:
 
SELECT a.first_name, a.last_name 
 FROM actor a
 WHERE a.last_name LIKE 'Dro%'
 
 Notre actor a bien été supprimé.
 
 
8. Affichez les clients dont le montant total payé est supérieur à la moyenne de tous les 
clients. 

SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  SUM(p.amount) AS montant_total_paye
FROM customer c
INNER JOIN payment p 
  ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(p.amount) > (
  SELECT AVG(total)
  FROM (
    SELECT SUM(amount) AS total
    FROM payment 
    GROUP BY customer_id
  ) AS t
);

PARTIE B — Étude de cas “Entreprise” et questions d’entretien 
Section 1 — Création de la base, des tables et insertion des données 

la table a été créé en utilisant les commandes  directement, ce qui a permit de définir les clés primaires,valeurs non null (pk, nn...)

#On utilise la base de donnée de notre entreprise nommée :entreprise_nye
use entreprise_nye

Section 2 — Analyse des données 
3. Affichons les 3 commandes générant le plus de revenu, avec le nom du client et le détail 
des produits commandés.

SELECT
  o.order_id,
  c.first_name, c.last_name,
  t.order_total,
  p.product_name,
  oi.quantity,
  oi.price,
  (oi.quantity * oi.price) AS line_amount
FROM (
  SELECT 
    oi.order_id,
    SUM(oi.quantity * oi.price) AS order_total
  FROM OrderItems oi
  GROUP BY oi.order_id
  ORDER BY order_total DESC
  LIMIT 3
) AS t
JOIN Orders o     ON o.order_id = t.order_id
JOIN Customers c  ON c.customer_id = o.customer_id
JOIN OrderItems oi ON oi.order_id = o.order_id
JOIN Products p   ON p.product_id = oi.product_id
ORDER BY t.order_total DESC, o.order_id, p.product_name;



 
4. Identifiez les clients ayant dépensé plus de 500 dans un même mois et affichez le mois, 
le client et le montant total. 
SELECT
  MONTH(o.order_date) AS mois,
  c.first_name,
  c.last_name,
  SUM(o.total) AS montant_total
FROM Orders o
JOIN Customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id, mois, c.first_name, c.last_name
HAVING montant_total > 500
ORDER BY mois, montant_total DESC;

Le mois où les clients ont depensé plus de 500 est le mois de octobre 





5. Calculez, pour chaque produit, le revenu total généré et la quantité vendue par 
catégorie. Affichez les 3 produits les plus rentables et le classement des catégories par 
revenu décroissant. 

SELECT
  tp.product_id,
  tp.product_name,
  tp.category,
  tp.total_quantity,
  tp.total_revenue,
  tp.rank_product,
  cr.category_revenue,
  cr.rank_category
FROM
(
  SELECT
    ps.product_id,
    ps.product_name,
    ps.category,
    ps.total_quantity,
    ps.total_revenue,
    RANK() OVER (ORDER BY ps.total_revenue DESC) AS rank_product
  FROM (
    SELECT
      p.product_id,
      p.product_name,
      p.category,
      SUM(oi.quantity) AS total_quantity,
      SUM(oi.quantity * oi.price) AS total_revenue
    FROM Products p
    JOIN OrderItems oi ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category
  ) AS ps
) AS tp
JOIN
(
  SELECT
    c.category,
    c.category_revenue,
    RANK() OVER (ORDER BY c.category_revenue DESC) AS rank_category
  FROM (
    SELECT
      p.category,
      SUM(oi.quantity * oi.price) AS category_revenue
    FROM Products p
    JOIN OrderItems oi ON oi.product_id = p.product_id
    GROUP BY p.category
  ) AS c
) AS cr
  ON tp.category = cr.category
WHERE tp.rank_product <= 3
ORDER BY tp.total_revenue DESC;





6. Créez une vue HighValueOrders contenant les commandes supérieures à 400 avec le 
nom du client, le montant total et le nombre de produits commandés. Proposez un ou 
plusieurs index pour accélérer les recherches dans la table Orders et expliquez l’impact 
attendu sur les performances des requêtes. 

CREATE VIEW HighValueOrders AS
SELECT
  ot.order_id,
  c.first_name,
  c.last_name,
  ot.total_amount,
  ot.total_items
FROM (
  SELECT
    o.order_id,
    o.customer_id,
    SUM(oi.quantity * oi.price) AS total_amount,
    SUM(oi.quantity) AS total_items
  FROM Orders o
  JOIN OrderItems oi ON oi.order_id = o.order_id
  GROUP BY o.order_id, o.customer_id
) AS ot
JOIN Customers c ON c.customer_id = ot.customer_id
WHERE ot.total_amount > 400;




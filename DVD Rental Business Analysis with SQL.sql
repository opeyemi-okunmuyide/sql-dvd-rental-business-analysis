/*
===========================================================
Maven Movies SQL Business Analysis

Author: Opeyemi Okunmuyide

Dataset: Maven Movies Sample Database
Source: Maven Analytics SQL Course

Description:
This project demonstrates SQL techniques by answering
business questions related to customer behavior,
inventory management, store operations, and revenue
analysis using the Maven Movies sample database. 
It demonstrates techniques including:
- Filtering
- Aggregation
- GROUP BY
- CASE statements
- Joins
- Business reporting
- Inventory analysis
- Customer analysis

===========================================================
*/

/*
-----------------------------------------------------------
SECTION 1 - BUSINESS & STORE OVERVIEW
-----------------------------------------------------------
*/

/*-----------------------------------------------------------
Analysis 1.1: Staff Directory

Objective: 
Generate a directory of all staff members and their 
assigned store locations.	
*/-----------------------------------------------------------

SELECT
	first_name,
    last_name,
    email,
    store_id
FROM staff;

/*---------------------------------------------------------
Analysis 1.2: Inventory Distribution

Objective:
Compare inventory levels across store locations.
---------------------------------------------------------*/

SELECT
	store_id,
    COUNT(inventory_id) as count_of_inventory
FROM inventory
GROUP BY
	store_id;

/*---------------------------------------------------------
Analysis 1.3: Active Customer Summary

Objective:
Measure the number of active customers at each store.
---------------------------------------------------------*/

SELECT 
	store_id,
    COUNT(customer_id) as count_of_active_customers
FROM customer
WHERE active = 1
GROUP BY
	store_id;

/*---------------------------------------------------------
Analysis 1.4: Customer Contact Coverage

Objective:
Count the number of customer email addresses stored.
---------------------------------------------------------*/

SELECT
	COUNT(email) AS emails
FROM customer;

/*---------------------------------------------------------
Analysis 1.5: Store Manager & Location Directory

Objective:
Retrieve store managers and complete store addresses.
---------------------------------------------------------*/

SELECT
	staff.first_name,
    staff.last_name,
    address.address,
    address.district,
    city.city,
    country.country
FROM store
	LEFT JOIN staff 
		ON store.manager_staff_id = staff.staff_id
	LEFT JOIN address 
		ON store.address_id = address.address_id
    LEFT JOIN city 
		ON address.city_id = city.city_id
    LEFT JOIN country 
		ON city.country_id = country.country_id;
    
/*
-----------------------------------------------------------
SECTION 2 - INVENTORY ANALYSIS
-----------------------------------------------------------
*/

/*---------------------------------------------------------
Analysis 2.1: Film Catalog Diversity

Objective:
Compare the diversity of each store's film inventory by
counting unique film titles and available film categories.
---------------------------------------------------------*/

SELECT 
	store_id,
    COUNT(DISTINCT film_id) AS unique_films
FROM inventory
GROUP BY store_id;

/*---------------------------------------------------------
Analysis 2.2: Replacement Cost Summary

Objective:
Analyze film replacement costs by calculating the minimum,
maximum, and average replacement cost across the inventory.
---------------------------------------------------------*/

SELECT
	MIN(replacement_cost) AS least_expensive_to_replace,
    MAX(replacement_cost) AS most_expensive_to_replace,
    AVG(replacement_cost) AS average_replacement_cost
FROM film;

/*---------------------------------------------------------
Analysis 2.3: Inventory Listing

Objective:
Generate a detailed inventory report including store,
film, rating, rental rate, and replacement cost.
---------------------------------------------------------*/

SELECT
	inventory.store_id,
    inventory.inventory_id,
    film.title,
    film.rating,
    film.rental_rate,
    film.replacement_cost
FROM inventory
    LEFT JOIN film 
		ON inventory.film_id = film.film_id;
    
/*---------------------------------------------------------
Analysis 2.4: Inventory Distribution by Rating

Objective:
Summarize inventory levels by store and film rating to
compare inventory distribution across locations.
---------------------------------------------------------*/

SELECT
	inventory.store_id,
    film.rating,
	COUNT(inventory_id) AS number_of_inventory
FROM inventory
    LEFT JOIN film 
		ON inventory.film_id = film.film_id
GROUP BY 
	inventory.store_id,
    film.rating;

/*---------------------------------------------------------
Analysis 2.5: Inventory Value by Category

Objective:
Analyze inventory by store and film category, including
film count, average replacement cost, and total value.
---------------------------------------------------------*/

SELECT
	store_id,
    category.name AS category,
	COUNT(inventory.inventory_id) AS number_of_films,
    AVG(film.replacement_cost) AS avg_replacement_cost,
    SUM(film.replacement_cost) AS total_replacement_cost    
FROM inventory
	LEFT JOIN film
		ON inventory.film_id = film.film_id
	LEFT JOIN film_category
		ON film.film_id = film_category.film_id
	LEFT JOIN category
		ON category.category_id = film_category.category_id
GROUP BY
	store_id,
    category.name;
    
/*
-----------------------------------------------------------
SECTION 3 - CUSTOMER & REVENUE ANALYSIS
-----------------------------------------------------------
*/

/*---------------------------------------------------------
Analysis 3.1: Payment Summary

Objective:
Summarize customer payment activity by calculating the
average and maximum payment amounts processed.
---------------------------------------------------------*/

SELECT 
	AVG(amount) AS average_payment,
    MAX(amount) AS maximum_payment
FROM payment;

/*---------------------------------------------------------
Analysis 3.2: Customer Rental Activity

Objective:
Evaluate customer engagement by counting each customer's
total lifetime rentals and ranking them by rental volume.
---------------------------------------------------------*/

SELECT
    customer_id,
    COUNT(rental_id) AS count_of_rentals
FROM rental
GROUP BY customer_id
ORDER BY count_of_rentals DESC;

/*---------------------------------------------------------
Analysis 3.3: Customer Directory

Objective:
Generate a customer directory including assigned store,
account status, and complete address information.
---------------------------------------------------------*/

SELECT
	first_name,
    last_name,
    store_id,
    CASE 
		WHEN active = 1 THEN 'active'
		WHEN active = 0 THEN 'inactive'
        ELSE 'null'
	END AS active,
    address.address,
    city.city,
    country.country
FROM customer
	LEFT JOIN address
		ON customer.address_id = address.address_id
	LEFT JOIN city
		ON address.city_id = city.city_id
	LEFT JOIN country
		ON city.country_id = country.country_id;

/*---------------------------------------------------------
Analysis 3.4: Customer Lifetime Value

Objective:
Measure customer value by calculating total rentals and
lifetime spending for each customer.
---------------------------------------------------------*/

SELECT
	first_name,
    last_name,
    COUNT(rental.rental_id) AS lifetime_rentals,
    SUM(payment.amount) AS total_payment
FROM customer
	LEFT JOIN rental
		ON customer.customer_id = rental.customer_id
	LEFT JOIN payment
		ON rental.rental_id = payment.rental_id
GROUP BY
	first_name,
    last_name
ORDER BY
	SUM(payment.amount) DESC;

/*
-----------------------------------------------------------
SECTION 4 - STAKEHOLDER ANALYSIS
-----------------------------------------------------------
*/

/*---------------------------------------------------------
Analysis 4.1: Advisors and Investors

Objective:
Create a consolidated directory of advisors and investors,
including investor company affiliations where available.
---------------------------------------------------------*/

SELECT
	'investor' AS type,
    first_name,
	last_name,
    company_name
FROM investor

UNION ALL

SELECT
	'advisor' AS type,
    first_name,
	last_name,
    NULL AS company_name
FROM advisor;

/*
-----------------------------------------------------------
SECTION 5 - ACTOR ANALYSIS
-----------------------------------------------------------
*/

/*---------------------------------------------------------
Analysis 5.1: Award-Winning Actor Coverage

Objective:
Measure the percentage of award-winning actors represented
in the film catalog based on their award classifications.
---------------------------------------------------------*/

SELECT
	CASE
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
        WHEN actor_award.awards IN ('Emmy, Oscar', 'Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
        ELSE '1 award'
	END AS number_of_awards,
    AVG(CASE WHEN actor_award.actor_id IS NULL THEN 0 ELSE 1 END) AS percent_of_film
FROM actor_award
GROUP BY
	CASE
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
        WHEN actor_award.awards IN ('Emmy, Oscar', 'Emmy, Tony', 'Oscar, Tony') THEN '2 awards'
        ELSE '1 award'
	END;

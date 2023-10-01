--							EASY

--Question 1: Who is the senior most employee based on job title?

select
	concat(first_name,
	last_name) as Name,
	title ,
	levels
from
	employee
order by
	levels desc
limit 1;

--Question 2: Which countries have the most Invoices?

select
	count(billing_address)as total_invoices,
	billing_country as total_invoices
from
	invoice i
group by
	billing_country
order by
	1 desc ;

--Question 3: What are top 3 values of total invoice?

select
	total
from
	invoice i
order by
	total desc
limit 3;

--Question 4: Which city has the best customers? We would like to throw a promotional Music 
--Festival in the city we made the most money. Write a query that returns one city that 
--has the highest sum of invoice totals. Return both the city name & sum of all invoice 
--totals

select
	billing_city ,
	sum(total) as total_sales_amount
from
	invoice i
group by
	billing_city
order by
	2 desc
limit 1;

--Question 5:. Who is the best customer? The customer who has spent the most money will be 
--declared the best customer. Write a query that returns the person who has spent the 
--most money

select
	concat(c.first_name,
	c.last_name) as Customer_name,
	sum(total) as total_amount_spent,
	c.customer_id
from
	invoice i
left join customer c
on
	i.customer_id = c.customer_id
group by
	c.customer_id
order by
	2 desc
limit 1;

--							MODERATE

--Question 6:  Write query to return the email, first name, last name, & Genre of all Rock Music 
--listeners. Return your list ordered alphabetically by email starting with A

select * from genre g ;
select
	distinct email,
	first_name,
	last_name,
	g.name as genre_name
from
	customer c
join invoice i on
	i.customer_id = c.customer_id
join invoice_line il on
	il.invoice_id = i.invoice_id
join track t on
	il.track_id = t.track_id
join genre g on
	t.genre_id = g.genre_id
where
	g."name" = 'Rock'
order by
	email;

--Question 7: Let's invite the artists who have written the most rock music in our dataset. Write a 
--query that returns the Artist name and total track count of the top 10 rock bands

select
	a."name" as artist_name ,
	count(*) as total_records_written
from
	artist a
join album al on
	a.artist_id = al.artist_id
join track t on
	al.album_id = t.album_id
where
	t.genre_id in 
(
	select
		g.genre_id
	from
		genre g
	where
		"name" = 'Rock')
group by
	1
order by
	2 desc
limit 10;

--Question 8: Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the 
--longest songs listed first

select
	t."name" ,
	t.milliseconds
from
	track t
where
	t.milliseconds > (
	select
		avg(t2.milliseconds) as avg_track_length
	from
		track t2)
order by
	2 desc;



--							ADVANCED

--Question 9:  Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent


select
	c.first_name,
	c.last_name,
	a2."name" as artist_name,
	sum(il.unit_price * il.quantity) as total_sales
from
	customer c
join invoice i on
	i.customer_id = c.customer_id
join invoice_line il on
	i.invoice_id = il.invoice_id
join track t on
	il.track_id = t.track_id
join album a on
	t.album_id = a.album_id
join artist a2 on
	a.artist_id = a2.artist_id
group by
	1,
	2,
	3
order by
	3
;

--Question 10:
--. We want to find out the most popular music Genre for each country. We determine the 
--most popular genre as the genre with the highest amount of purchases. Write a query 
--that returns each country along with the top Genre. For countries where the maximum 
--number of purchases is shared return all Genres

with popular_genre as 
(
select
	count(il.invoice_id) as purchase,
	c.country,
	g.genre_id,
	g."name",
	row_number() over(partition by c.country
order by
	count(il.invoice_id) desc) as RowNo
from
	invoice_line il
join invoice i on
	i.invoice_id = il.invoice_id
join customer c on
	c.customer_id = i.customer_id
join track t on
	t.track_id = il.track_id
join genre g on
	g.genre_id = t.genre_id
group by
	2,
	3,
	4
order by
	2 ,
	1 desc 
)
select
p.country,
p.name
from
	popular_genre p
where
	RowNo <= 1;

--Question 10:  Write a query that determines the customer that has spent the most on music for each 
--country. Write a query that returns the country along with the top customer and how
--much they spent. For countries where the top amount spent is shared, provide all 
--customers who spent this amount



with most_spent as 
(
	select c.customer_id ,
	c.first_name,
	c.last_name,
	i.billing_country,
	sum(i.total) as total_spent,
	row_number() over (partition by billing_country order by sum(total)) as rowNo
	from invoice i 
	join customer c on c.customer_id = i.customer_id
	group by 1,2,3,4
	order by 4,5
)
select * from most_spent where rowNo <=1;





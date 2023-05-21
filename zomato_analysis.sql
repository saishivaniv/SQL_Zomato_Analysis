-- creating database
create database zomato;
use zomato;
-- creating goldusers table
drop table goldusers_signup;
create table goldusers_signup(userid int primary key, signup_date date);
INSERT INTO goldusers_signup (userid, signup_date)
VALUES
  (1, '2022-08-15'),
  (2, '2022-07-01'),
  (3, '2022-06-10');

-- creating users table

CREATE TABLE users (userid INT PRIMARY KEY,name VARCHAR(100),email VARCHAR(100),signup_date DATE);
INSERT INTO users (userid, name, email, signup_date)
VALUES(1, 'John', 'john@gmail.com', '2022-01-01'),
(2, 'Smith', 'jane@gmail.com', '2021-11-01'), (3,'Radha', 'radha@gmail.com', '2022-05-05') ;

-- creating sales table

CREATE TABLE sales(userid int,order_date date,product_id int); 
INSERT INTO sales(userid,order_date,product_id) 
VALUES (1,'2022-04-19',2),
(3,'2022-12-18',1),
(2,'2021-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2020-12-20',2),
(1,'2017-11-09',1),
(1,'2020-05-20',3),
(2,'2017-09-24',1),
(1,'2018-03-11',2),
(1,'2019-03-11',1),
(3,'2021-11-10',1),
(3,'2022-12-07',2),
(3,'2017-12-15',2),
(2,'2021-11-08',2),
(2,'2020-09-1',3);

-- create product table
CREATE TABLE product(product_id int,product_name text,price int); 
INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

show tables;
select * from goldusers_signup;
select * from users;
select * from sales;
select * from product;

-- 1. count the number of golduser signup

select count(*) as gold_user_signup from goldusers_signup;

-- 2. average price of products

select avg(price) as average_product_price from product;

-- 3. Calculate the total sales amount

select sum(price) as total_sales from sales s 
inner join
product p
on s.product_id=p.product_id;

-- 4. what is total amount each customer spent on zomato?

select s.userid, sum(p.price) as total_amount from sales s 
inner join
product p
on s.product_id=p.product_id
group by s.userid;

-- 5. How many days has each customer visited zomato?

select s.userid, count(distinct s.order_date) as Total_days from sales s
group by s.userid;

-- 6. what was the first product purchased by each customer?

select * from (
select * ,rank() over (partition by userid order by order_date) rnk
from sales) A
where rnk=1;

-- 7.what is most purchased item on menu & how many times was it purchased by all customers ?

select userid, count(product_id) cnt  from sales where product_id = ( 
select product_id from sales group by product_id order by count(product_id) desc limit 1)
group by userid;

-- 8. Which item was the most popular for each customer?

select * from(
select *, rank() over (partition by userid order by cnt desc) rnk from
(select userid,product_id, count(product_id) cnt from sales group by userid, product_id)a
) b
where rnk =1;

-- 9. Which item was purchased first by the customer after they became a member?

select * from
(select c.*,rank() over (partition by userid order by order_date ) rnk from
(select a.userid,a.order_date,a.product_id,b.signup_date from sales a 
inner join goldusers_signup b 
on a.userid=b.userid and order_date>=signup_date) c
) d 
where rnk = 1;

-- 10. Which item was purchased just before the customer became a member?   

select * from
(
select c.*,rank() over (partition by userid order by order_date desc ) rnk from
(select a.userid,a.order_date,a.product_id,b.signup_date from sales a 
inner join goldusers_signup b 
on a.userid=b.userid and order_date>=signup_date) c
) d 
where rnk = 1;

-- 11. What is the total orders and amount spent for each member before they became member?

select * from
(
select c.*,rank() over (partition by userid order by created_date desc ) rnk from
(select a.userid,a.order_date,a.product_id,b.signup_date from sales a 
inner join goldusers_signup b 
on a.userid=b.userid and order_date<=signup_date) c
) d 
where rnk = 1;

--Simple Queries

--Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 


CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;

-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';

SELECT COUNT (*) FROM customer;

INSERT into special_operating_hours("75 Thomson Place #11-167 Singapore578281","JudsonComestiblesaccount",1,10:30:00,18:00:00);


SELECT fname FROM franchiseowner;
select * from customer where userid="LaceyKetcher71";

insert into franchiseowner values('Dantekirton52','Dante kirton');
insert into restaurant values('PES store','Frankfurt','DanteKirton52',100,'Nagar','9:00:00','21:00:00','wwww.pesstore.com');

--Complex Queries

With X (cuisine,num) AS (
SELECT Food.cuisine, count(DISTINCT Reservation.Location) as num
FROM Reservation
INNER JOIN
Food
ON Food.Location = Reservation.Location
AND Food.UserID = Reservation.Restaurant_UserID
WHERE Reservation.customer_userid = '${userid}'
GROUP BY
Food.cuisine
ORDER BY
num DESC
),
Y (Store_Name,Location,UserID,Capacity,Area,Opening_hours,Closing_hours,url,cuisine,num ) AS (
SELECT DISTINCT
r.Store_Name,r.Location,r.UserID,r.Capacity,r.Area,r.Opening_hours,r.Closing_hours,r.url,f.cuisine,num

FROM
Food as f
INNER JOIN
X as X
ON X.cuisine = f.cuisine
INNER JOIN
restaurant as r
ON f.location = r.location
and
f.UserID = r.userID
ORDER BY
r.location
)
SELECT ROUND(CAST(AVG(Food.Price) as numeric), 2) AS p
FROM Food
WHERE Food.Location = Y.Location
AND Food.UserID = Y.UserID
) AS price,
(
SELECT ROUND(CAST(AVG(Reservation.Rating) as numeric), 2) AS r
FROM Reservation
WHERE Reservation.Location = y.Location
AND Reservation.Restaurant_UserID = y.UserID

AND Reservation.Rating IS NOT NULL
) AS rating
FROM
Y
GROUP BY
Store_Name,Location,UserID,Capacity,Area,Opening_hours,Closing_hours,url,price,rating
ORDER BY
matchrate DESC,
location ASC


--2

With X AS(
SELECT DISTINCT rv.customer_userid, rv.Location,rv.Restaurant_UserID,
(
SELECT COUNT(*) FROM reservation as res
WHERE
res.customer_userid = rv.customer_userid
) as totalreservations,
(
SELECT COUNT(*) FROM
reservation as res
INNER JOIN Restaurant as rt
ON res.Location = rt.location
AND res.Restaurant_UserID = rt.userID
WHERE
res.customer_userid = rv.customer_userid
AND rt.url = '${name}'
) as thisres,
CAST((
SELECT COUNT(*) FROM reservation as res
INNER JOIN Restaurant as rt
ON res.Location = rt.location
AND res.Restaurant_UserID = rt.userID
WHERE
res.customer_userid = rv.customer_userid
AND rt.url ='${name}'
) AS decimal(8,2))
/
CAST((
SELECT COUNT(*) FROM reservation as res
WHERE
res.customer_userid = rv.customer_userid
) AS decimal(8,2)) as percent
FROM
Reservation as rv inner join Restaurant as rs

ON rv.Location = rs.Location
AND rv.Restaurant_UserID = rs.UserID
WHERE
rs.url ='${name}'
ORDER BY
rv.location
)
SELECT customer_userid, location, restaurant_userid, thisres, ROUND(percent,2)*100 as percent
FROM X
WHERE
x.percent * x.thisres >= ALL (
SELECT b.percent * b.thisres FROM X as b
)
LIMIT 1

--5

With Y(tablenum,capacity) AS (
SELECT Tables.tablenum,Tables.capacity FROM
Tables
WHERE Tables.userid = NEW.Restaurant_UserID
AND Tables.location = NEW.location
AND Tables.capacity >= NEW.pax
EXCEPT
SELECT Tables.tablenum,Tables.capacity FROM
Tables INNER JOIN Reservation
ON
Tables.tablenum = Reservation.tablenum
AND Tables.location = Reservation.location
AND Tables.userid = Reservation.Restaurant_UserID
WHERE
(bookingtimestart, bookingtimeend) OVERLAPS (Reservation.datetime, Reservation.datetime + interval '2 hours')
AND Tables.userid = NEW.Restaurant_UserID
AND Tables.location = NEW.location
ORDER BY
Tablenum
)
SELECT tablenum
from Y
ORDER BY
capacity
LIMIT 1

--Triggers
--1
CREATE FUNCTION public.capacityfortables() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE cap integer:=(
    SELECT coalesce(SUM(tables.capacity),0)
    FROM tables
    WHERE New.UserID = tables.UserID
    AND NEW.location= tables.location
);
BEGIN
UPDATE
Restaurant
SET capacity = cap
WHERE
Restaurant.userid = new.userid
AND Restaurant.location = new.location;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.capacityfortables() OWNER TO hungrilyapp;

--2
CREATE FUNCTION public.givepoints() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN 
IF OLD.rating IS NULL
THEN
UPDATE
customer
SET points = points + (
    SELECT ROUND(CAST(AVG(Food.Price) as numeric)) AS p
    FROM Food
    WHERE Food.Location = old.Location
    AND Food.UserID = old.Restaurant_UserID
    ) 
WHERE
old.customer_userid = customer.userid;
END IF;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.givepoints() OWNER TO hungrilyapp;

--3
CREATE FUNCTION public.noratings() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
bookingtimeend timestamp with time zone := date_trunc('minute', OLD.datetime) + interval '2 hour';
BEGIN
IF
bookingtimeend > now()
THEN
RAISE EXCEPTION 'cannot add' USING HINT = 'OnlyCanRateAfter';
END IF;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.noratings() OWNER TO hungrilyapp;

--4
-- Name: user_customer_constraint(); Type: FUNCTION; Schema: public; Owner: hungrilyapp
--

CREATE FUNCTION public.user_customer_constraint() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE count integer:=(
    SELECT COUNT(*)
    FROM FranchiseOwner 
    WHERE NEW.UserID = FranchiseOwner.UserID
);
BEGIN 
IF count > 0 THEN 
    RAISE EXCEPTION 'UserID already used as FranchiseOwner' USING HINT = 'UserID already used as FranchiseOwner';
ELSE 
    RETURN NEW;
END IF; 
END;
$$;


ALTER FUNCTION public.user_customer_constraint() OWNER TO hungrilyapp;


--Stored Procedures contains transaction whcih is for Assigned for assignment 4.

-- Declare cursors










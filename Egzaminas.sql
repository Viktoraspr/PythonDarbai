-- 1
select first_name, last_name
from customer
where first_name like 'Jessica'
order by first_name asc, last_name asc;

-- 2

select *
from actor
where first_name like 'S%' or last_name like '%ca%'
order by actor_id desc;

-- 3

select country, count(rental_id) as Nuoma_kartai
from country
inner join city using (country_id)
inner join address using (city_id)
inner join customer using (address_id)
inner join rental using (customer_id)
group by country_id 
order by Nuoma_kartai desc;

-- 3.1 Suraskite kokia išviso buvo pinigu suma uždirbta iš nuomos kiekvienoje šalyje ir
--  tuomet kiek vidutiniškai buvo uždirbta per customer/vartotoją. Išrikiuokite pagal sumą didėjimo tvarka.

select country, sum(amount) as Suma, sum(amount)/count(customer.customer_id) as Suma_Per_Vartotoja
from country
inner join city using (country_id)
inner join address using (city_id)
inner join customer using (address_id)
inner join payment using (customer_id)
group by country_id
order by Suma asc;

-- Suraskite kokia buvo didžiausia ir mažiausia nuomos kaina. Išfiltruokite nulines [0] kainas.
-- (Raskite mažiausią kainą kuri nėra nulis)
-- 4 
select min(amount) Minimali, Max(amount) Maximali
from payment
where amount > 0;

-- 4.1 4.1 Išveskite tai per filmą(title), 
-- bet rodykite tik tuos filmus kurių kategorija yra Family, Comedy arba Action. Išrikiuokite pagal filmo ID’ą.


select category.name, film.title, min(payment.amount) Minimali, Max(payment.amount) Maximali
from payment
left join rental using(rental_id)
left join inventory using(inventory_id)
left join film using(film_id)
left join film_category using(film_id)
left join category using(category_id)
where payment.amount > 0 and category.name in ('Family', 'Comedy', 'Action')
group by film_id;

-- Išveskite filmų id ir pavadinimus ir kelias kopijas rasime inventoriuje. 
-- Išveskite ir tuos filmus kurių nėra inventoriuje. Išrikiuokite pagal kopijų kiekį didėjimo tvarka.

select film.film_id, film.title, count(inventory.inventory_id) as Kopiju_skaicius
from film
left join inventory using(film_id)
group by film.film_id with rollup
order by Kopiju_skaicius asc;

-- 6. Išveskite Filmo kategoriją ir filmą viename stulpelyje per brūkšnelį. 
-- Išrikiuokite duomenis pagal šio junginio ilgumą.

select concat(film.title,'-',category.name) as Filmas_Kategorija
from film
inner join film_category using (film_id)
inner join category using(category_id)
order by length(Filmas_Kategorija);

-- 7 Suraskite miestus kurių Vidutinis mokestis yra didesnis negu bendras vidutinis mokestis.
-- [Panaudokite Subquery]. Išrikiuokite pagal miesto ID.

select city.city_id, city.city, avg(amount) as Miesto_vidurkis, (select avg(amount) from payment) Bendras_Vidurkis
from city
left join address using(city_id)
left join customer using(address_id)
left join payment using(customer_id)
group by city.city_id
having Miesto_vidurkis > Bendras_Vidurkis
order by city.city_id;

create or replace view Miestai_virs_vidurkio as
select city.city_id, city.city, avg(amount) as Miesto_vidurkis, (select avg(amount) from payment) Bendras_Vidurkis
from city
left join address using(city_id)
left join customer using(address_id)
left join payment using(customer_id)
group by city.city_id
having Miesto_vidurkis > Bendras_Vidurkis
order by city.city_id;

-- 7.1 7.1 Naudodami šį select’ą , kaip subquery arba view, patikrinkite kurios kategorijos yra populiariausios (nuomos kartai)  tarp šių miestų  klientų.
--  Išrikiuokite pagal nuomos kartus. 

select category.name as Kategorija, count(distinct rental.rental_id) as Nuomos_kartai
from city
inner join Miestai_virs_vidurkio using(city_id)
inner join address using (city_id)
inner join customer using (address_id)
inner join rental using (customer_id)
inner join inventory using (inventory_id)
inner join film using (film_id)
inner join film_category using(film_id)
inner join category using(category_id)
group by Kategorija
order by Nuomos_kartai desc;

-- 8 8. Jeigu filmas žiūrint pagal nuomos kartus buvo išnuomuotas daugiau negu 20 kartų, 
-- tuomet priskirkite jį segmentui: “Populiariausi” , jeigu filmas buvo išnuomuotas mažiau negu 20,
--  bet daugiau negu 10 , priskirkite vidutinis. Visiems kitiems priskirkite “Nepopuliarus”.
-- Išsiveskite Filmų ID, title, Nuomos Kartus, bei priskirtą segmentą.
--  Išveskite pagal filmų ID

select film.film_id, film.title, count(rental_id) as Nuomos_karta, 
   case
	when count(rental_id) > 20 then 'Populiariausi'
    when count(rental_id) > 10 then 'Vidutinis'
    else 'Nepopuliarus'
   end Segmentai
from film
left join inventory using (film_id)
left join rental using (inventory_id)
group by film_id with rollup;

-- 9. Išveskite kiek buvo išviso uždirbta kiekviename mieste. Mus domina specifiškai Amerikos miestai.
-- Išrikiuokite miestus didėjančia tvarka pagal tai kiek jie uždirbo.

select city.city, sum(payment.amount) as Suma
from city
inner join country using(country_id)
left join address using(city_id)
left join customer using(address_id)
left join payment using (customer_id)
where country.country = 'United States'
group by city_id
order by Suma asc;

-- 9.1 Replacement cost turi būti didesnė negu vidutinė replacement cost.
-- Išrikiuokite pagal replacement cost didėjančia tvarka.

select city.city, sum(payment.amount) as Suma, avg(film.replacement_cost) as Vidurkis_mieste
from city
inner join country using(country_id)
left join address using(city_id)
left join customer using(address_id)
left join payment using (customer_id)
left join rental using (rental_id)
left join inventory using (inventory_id)
left join film using (film_id)
where country.country = 'United States'
group by city_id
having Vidurkis_mieste > (select avg(replacement_cost) from film)
order by Vidurkis_mieste asc;

-- 9.2 Imti tik tuos vartotojus kurie turėjo vardo ir pavardės junginį ilgesnį negu vidutinis vardo ir pavardės junginio ilgumas. (išfiltruoti visus vartotojus kurie neatitinka kriterijaus). 
-- Išrikiuokite pagal vardo ir pavardės junginio ilgumą didėjančia tvarka.

select city.city, sum(payment.amount) as Suma, avg(film.replacement_cost) as Vidurkis_mieste,
   length(concat(first_name, last_name)) as Vardo_pavardes_ilgis
from city
inner join country using(country_id)
left join address using(city_id)
left join customer using(address_id)
left join payment using (customer_id)
left join rental using (rental_id)
left join inventory using (inventory_id)
left join film using (film_id)
where country.country = 'United States' 
	and (select avg(length(concat(first_name, last_name))) from customer) < length(concat(first_name, last_name))
group by city_id
having Vidurkis_mieste > (select avg(replacement_cost) from film)
order by Vardo_pavardes_ilgis asc;

-- 9.3 Imti tik tuos nuomos aktus kurie nebuvo atlikti August/rugpjūčio mėnesį ir yra vėlesnio mėnesio negu einamasis.
--  Išrikiuokite pagal Nuomos Datą mažėjančia tvarka. 

select city.city, sum(payment.amount) as Suma, avg(film.replacement_cost) as Vidurkis_mieste,
   length(concat(first_name, last_name)) as Vardo_pavardes_ilgis, payment.payment_date as Nuomos_data
from city
inner join country using(country_id)
left join address using(city_id)
left join customer using(address_id)
left join payment using (customer_id)
left join rental using (rental_id)
left join inventory using (inventory_id)
left join film using (film_id)
where country.country = 'United States' 
	and (select avg(length(concat(first_name, last_name))) from customer) < length(concat(first_name, last_name))
group by city_id
having Vidurkis_mieste > (select avg(replacement_cost) from film) and month(payment_date) <> 8 and month(payment.payment_date) > month(current_date())
order by Nuomos_data desc;

-- 10 10. Išveskite filmus ir kiek jie uždirbo.  
-- Filmai kurie mus domina yra tie kurių replacement_cost / rental_rate ratio yra 
-- 3 arba daugiau kartų didesnis negu einamas geriausias santykis. Kuo santykio skaičius 
-- yra mažesnis, tuo filmas skaitosi geresnis. 
-- Tuomet atfiltruokime filmus, kurie uždirbo 4 kartus mažiau negu daugiausiai uždirbęs filmas. 
-- Kitaip sakant mes norime pasidaryti sąrašą filmų, kurie ir uždirba mažai, ir lyginant su jų nuomos kaina -  pakeisti kainuotų labai brangiai. Blogiausius iš blogiausių. Išveskite pagal  replacement_cost / rental_rate ratio didėjančia tvarka. 
 
 select film_id, title, replacement_cost/rental_rate as Santykis
 from film
 inner join inventory using (film_id)
 inner join rental using (inventory_id)
 inner join payment using (rental_id)
 group by film_id
 having Santykis * 3 > (select min(replacement_cost/rental_rate) from film) and sum(amount) < (select max(amount) from payment) / 4
 order by Santykis asc;


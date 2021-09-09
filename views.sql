--1.Компоненты конкретного заказа конкретного (использующего представление) пользователя my_order_parts - s
CREATE OR REPLACE VIEW my_order_parts
AS SELECT prod_dish, d_name, i_weight, i_num
FROM order_items JOIN production ON i_dish=prod_id JOIN dishes ON prod_dish=d_id
WHERE i_order IN (SELECT ord_id
					FROM orders
					WHERE ord_client = 1 AND ord_id IN (SELECT so_id
														FROM stat_orders 
														WHERE so_status = 'Обработка') )
--Это представление показывает пользователю, что лежит у него в корзине. Если человек хочет изменить что-то в своей корзине, то он делает это напрямую через таблицу компоненты заказов. Это реализуется в интерфейсе. Нажатие кнопки "Изменить заказ" отправило бы его к компонентам его заказа (пользователь всегда видит только свои заказы и работает только с ними)

--2.Номер телефона клиента, его имя и/или адрес  work_ifo - s

CREATE OR REPLACE VIEW work_ifo
AS SELECT so_emp_c, ord_address, cl_id, cl_fname, cl_lname, cl_patronymic, cl_phone, cl_address
FROM stat_orders so, clients cl, orders ord
WHERE so_emp_c = 3 AND so_id = 1 AND so.so_id = ord.ord_id AND cl.cl_id = ord.ord_client;

--3.Итоговый заказ конкретного пользователя + столбец с итоговой ценой для каждого блюда final_order - s

CREATE OR REPLACE VIEW final_order
AS SELECT d_name, (1-d.d_discount*0.01)*oi.i_num*pr.prod_price*oi.i_weight*0.01*(1-cl_rating*0.02) цена блюда
FROM clients cl JOIN orders o ON cl_id=ord_client JOIN order_items oi ON ord_id=i_order JOIN production pr ON i_dish=prod_id 
				JOIN dishes d ON prod_dish=d_id
WHERE i_order IN (SELECT ord_id
					FROM orders
					WHERE ord_client = 1 AND ord_id IN (SELECT so_id
														FROM stat_orders 
														WHERE so_status = 'Сборка' OR so_status = 'Передан курьеру') )

--4.Информация о личных контактных данных my_data - isud

CREATE OR REPLACE VIEW my_data
AS SELECT *
FROM clients cl
WHERE cl_id = 1;

--5.Список товаров и ресторанов, из которых можно заказать еду (без подробностей)  all_menu - s

CREATE OR REPLACE VIEW all_menu
AS SELECT d_name, d_weight, d_type, d_diet, d_caus, d_rating оценка_блюда, r_name, r_rating оценка_ресторана 
FROM restaurants JOIN production ON r_id=prod_rest JOIN dishes ON prod_dish=d_id
ORDER BY 8 DESC
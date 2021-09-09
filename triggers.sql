--1.Триггер, добавляющий новую строку в таблицу “Выполнение заказов” после появления новой строки в таблице “Заказы”.

CREATE OR REPLACE FUNCTION fn_add_status() RETURNS TRIGGER AS $$
BEGIN
INSERT INTO stat_orders VALUES( NEW.ord_id, 'Обработка', current_time, NULL, NULL, 500);
RETURN NEW;
END;
$$ LANGUAGE plpgsql
RETURNS NULL ON NULL INPUT;

CREATE TRIGGER tr_add_status
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION fn_add_status();

--2.Триггер, находящий сборщика и свободного курьера. В зависимости от статуса заказа устанавливающий сотруднику статус “занят” или “не занят”. Изменение происходит  при изменении строки в таблице “Выполнение заказов”.

CREATE OR REPLACE FUNCTION fn_add_emp() RETURNS TRIGGER AS $$
DECLARE 
       collector NUMERIC(3);
       courier NUMERIC(3);
BEGIN
     IF (NEW.so_status = 'Сборка')
     THEN
         collector := (SELECT em_id from employees WHERE em_post = 'Сборщик' LIMIT 1 OFFSET 0);
		 NEW.so_emp_s = collector;
	 END IF;
	 
     IF (NEW.so_status = 'Передан курьеру')
     THEN
         courier = (SELECT em_id from employees WHERE em_post = 'Курьер' AND em_status = 'не занят' LIMIT 1 OFFSET 0);
         NEW.so_emp_c = courier;	 
	     UPDATE employees
	     SET em_status = 'занят'
	     WHERE em_id = courier;
	 END IF;
	 
	 IF (NEW.so_status = 'Доставлен')
     THEN
         courier = (SELECT so_emp_c from stat_orders so WHERE so.so_id = NEW.so_id);
		 UPDATE employees
	     SET em_status = 'не занят'
	     WHERE em_id = courier; 
	 END IF;
     RETURN NEW;
END;
$$ LANGUAGE plpgsql
RETURNS NULL ON NULL INPUT;

CREATE TRIGGER tr_add_emp
BEFORE UPDATE ON stat_orders
FOR EACH ROW
EXECUTE FUNCTION fn_add_emp();
--При реализации интерфейса было бы предусмотрено, что как только пользователь нажимает кнопку " купить", то это автоматически меняет статус его заказа на "Сборка". Пользователь взаимодействует только с теми заказами, которые находятся в статусе "Обработка". Для остальных он может видеть только итоговый заказ.
--Для сборщика ситуация была бы похожей. Как только он собирает заказ, он отмечает это в приложении переводя статус в "Передано курьеру". После этого триггер начинает искать свободного человека

--3.Триггер, добавляющий к рейтингу клиента 0,05 после совершения заказа (после установки статуса заказа “Доставлен”).

CREATE OR REPLACE FUNCTION f_update_rating() RETURNS TRIGGER AS $$
BEGIN  
     IF (NEW.so_status = 'Доставлен')
	 THEN
	     UPDATE clients cl
		 SET cl_rating = cl_rating + 0.05
		 WHERE cl_rating < 10 and cl.cl_id = 
		 (select ord_client from orders o 
		  WHERE NEW.so_id = o.ord_id);
     END IF;		 
     RETURN NEW;
END;
$$ LANGUAGE plpgsql
RETURNS NULL ON NULL INPUT;

CREATE TRIGGER tr_update_rating
AFTER UPDATE ON stat_orders
FOR EACH ROW
EXECUTE FUNCTION f_update_rating();

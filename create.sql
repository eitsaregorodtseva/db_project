CREATE TABLE contacts (
	cont_name VARCHAR(20) CONSTRAINT contacts_pk PRIMARY KEY
);

CREATE TABLE posts (
	p_post VARCHAR(20) CONSTRAINT posts_pk PRIMARY KEY,
	p_salary NUMERIC(6) NOT NULL CONSTRAINT p_salary_check CHECK(p_salary > 12792) 
);

CREATE TABLE causines (
	caus_name VARCHAR(20) CONSTRAINT causines_pk PRIMARY KEY
);

CREATE TABLE statuses (
	stat_name VARCHAR(20) CONSTRAINT statuses_pk PRIMARY KEY
);

CREATE TABLE dish_types (
	t_name VARCHAR(20) CONSTRAINT dish_types_pk PRIMARY KEY
);

CREATE TABLE diets (
	td_name VARCHAR(20) CONSTRAINT diets_pk PRIMARY KEY
);

CREATE TABLE clients (
	cl_id NUMERIC(5) CONSTRAINT clients_pk PRIMARY KEY,
	cl_fname VARCHAR(20) NOT NULL,
	cl_lname VARCHAR(20) NOT NULL, 
	cl_patronymic VARCHAR(20),
	cl_born DATE NOT NULL,
	cl_phone VARCHAR(30) NOT NULL,
	cl_address VARCHAR(60),
	cl_rating NUMERIC(4,2) DEFAULT 0 CONSTRAINT rating_check CHECK(cl_rating >= 0 AND cl_rating <= 10)
);

CREATE TABLE employees (
	em_id NUMERIC(3) CONSTRAINT employees_pk PRIMARY KEY,
	em_fname VARCHAR(20) NOT NULL,
	em_lname VARCHAR(20) NOT NULL,
	em_patronymic VARCHAR(20),
	em_passport CHAR(10) NOT NULL UNIQUE,
	em_date DATE NOT NULL,
	em_given VARCHAR(40) NOT NULL,
	em_born DATE NOT NULL,
	em_gender CHAR(1) NOT NULL CONSTRAINT em_gender_check CHECK(em_gender IN('м', 'ж')),
	em_inn CHAR(12) NOT NULL UNIQUE, 
	em_snils CHAR(14) NOT NULL UNIQUE,
	em_address VARCHAR(60) NOT NULL,
	em_post VARCHAR(20) CONSTRAINT posts_fk REFERENCES posts, 
	em_status VARCHAR(8) DEFAULT NULL CONSTRAINT em_status_check CHECK(em_status IN('занят', 'не занят'))
);

CREATE TABLE emp_contacts (
	ec_id NUMERIC(3) CONSTRAINT employees_fk REFERENCES employees,
	ec_type VARCHAR(20) CONSTRAINT contacts_fk REFERENCES contacts,
	ec_phone VARCHAR(60) NOT NULL
);

CREATE TABLE restaurants (
	r_id NUMERIC(3) CONSTRAINT restaurants_pk PRIMARY KEY,
	r_name VARCHAR(30) NOT NULL,
	r_min NUMERIC(3) NOT NULL CONSTRAINT r_min_check CHECK(r_min >= 0),
	r_time VARCHAR(10) NOT NULL,
	r_rating NUMERIC(4, 2) CONSTRAINT r_rating_check CHECK(r_rating >= 0 AND r_rating <= 10) 
);

CREATE TABLE orders (
	ord_id NUMERIC(5) CONSTRAINT orders_pk PRIMARY KEY,
	ord_date DATE NOT NULL,
	ord_persons NUMERIC(2) NOT NULL CONSTRAINT ord_persons_check CHECK(ord_persons > 0),
	ord_address VARCHAR(60) NOT NULL,
	ord_client NUMERIC(5) CONSTRAINT clients_fk REFERENCES clients
);

CREATE TABLE stat_orders (
	so_id NUMERIC(5) CONSTRAINT stat_orders_fk REFERENCES orders,
	so_status VARCHAR(15) CONSTRAINT statuses_fk REFERENCES statuses,
	so_stat_tm TIME NOT NULL DEFAULT current_time,
	so_emp_s NUMERIC(3) CONSTRAINT employees_s_fk REFERENCES employees,
	so_emp_c NUMERIC(3) CONSTRAINT employees_c_fk REFERENCES employees,
	so_delivery NUMERIC(5) NOT NULL CONSTRAINT so_delivery CHECK(so_delivery >= 0)
);

CREATE TABLE dishes (
	d_id NUMERIC(5) CONSTRAINT dishes_pk PRIMARY KEY,
	d_name VARCHAR(30) NOT NULL,
	d_weight NUMERIC(4) NOT NULL CONSTRAINT d_weight_check CHECK(d_weight > 0),
	d_type VARCHAR(20) CONSTRAINT dish_types_fk REFERENCES dish_types,
	d_diet VARCHAR(20) CONSTRAINT diets_fk REFERENCES diets,
	d_caus VARCHAR(20) CONSTRAINT causines_fk REFERENCES causines,
	d_cal NUMERIC(4) NOT NULL CONSTRAINT d_cal_check CHECK(d_cal > 0),
	d_prot NUMERIC(4) NOT NULL CONSTRAINT d_prot_check CHECK(d_prot >= 0),
	d_fats NUMERIC(4) NOT NULL CONSTRAINT d_fats_check CHECK(d_fats >= 0),
	d_carb NUMERIC(4) NOT NULL CONSTRAINT d_carb_check CHECK(d_carb >= 0),
	d_ingred VARCHAR(200) NOT NULL,
	d_shelflife VARCHAR(10) NOT NULL,
	d_discount NUMERIC(3) NOT NULL CONSTRAINT d_discount_check CHECK(d_discount >= 0 AND d_discount <= 100),
	d_rating NUMERIC(4, 2) NOT NULL CONSTRAINT d_rating_check CHECK(d_rating >= 0 AND d_rating <= 10) 
);

CREATE TABLE production (
	prod_id NUMERIC(5)  CONSTRAINT production_pk PRIMARY KEY,
	prod_dish NUMERIC(5) CONSTRAINT dishes_fk REFERENCES dishes,
	prod_rest NUMERIC(3) CONSTRAINT restaurants_fk REFERENCES restaurants,
	prod_price NUMERIC(4) NOT NULL CONSTRAINT prod_price_check CHECK(prod_price > 0)
);

CREATE TABLE order_items (
	i_dish NUMERIC(5) CONSTRAINT production_fk REFERENCES production,
	i_order NUMERIC(5) CONSTRAINT orders_fk REFERENCES orders,
	i_weight NUMERIC(4) NOT NULL CONSTRAINT i_weight_check CHECK(i_weight > 0 AND i_weight <= 500),
	i_num NUMERIC(2) NOT NULL  CONSTRAINT i_num_check CHECK(i_num >=1 AND i_num <= 10),
	UNIQUE (i_dish, i_order) 
);
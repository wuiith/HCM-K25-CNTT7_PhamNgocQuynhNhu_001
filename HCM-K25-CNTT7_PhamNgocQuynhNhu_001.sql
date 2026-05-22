create database Logistics;
use Logistics;

-- PHẦN 1

-- tạo bản 1: shippers
create table shippers (
	driver_id int primary key,
    full_name varchar(100) not null,
    phone_number varchar(10) unique,
    license_type varchar(10),
    rating float default 5.0 check (rating between 0.0 and 5.0)
);

-- tạo bản 2: vehicle_details
create table vehicle_details (
	vehicle_id varchar(5) primary key,
    driver_id int,
    license_plate varchar(10) unique,
    vehicle_type varchar(20),
    max_payload int check (max_payload > 0),
    foreign key (driver_id) references shippers(driver_id)
);

-- tạo bảng 3: shipments
create table shipments (
	shipment_id varchar(5) primary key,
    product_name varchar(100),
    actual_weight decimal(10,1) check (actual_weight > 0),
    shipment_value int,
    shipment_status enum('In Transit', 'Delivered', 'Returned')
);

-- tạo bảng 4: delivery_orders
create table delivery_orders (
	order_id int primary key,
    shipment_id varchar(5),
    driver_id int,
    vehicle_id varchar(5),
    assigned_time timestamp default current_timestamp,
    shipping_fee int,
    order_status enum ('Pendind', 'Processing', 'Finished', 'Cancelled'),
    foreign key (driver_id) references shippers(driver_id),
    foreign key (vehicle_id) references vehicle_details(vehicle_id),
    foreign key (shipment_id) references shipments(shipment_id)
);

-- tạo bảng 5: delivery_log
create table delivery_log (
	log_id int primary key auto_increment,
    order_id int,
    current_location varchar(100),
    log_time timestamp default current_timestamp,
    note varchar(50),
    foreign key (order_id) references delivery_orders(order_id)
); 

-- thêm dữ liệu bảng shippers
insert into shippers
values
(1,'Nguyen Van An', '0901234567', 'C', 4.8),
(2,'Tran Thi Binh', '0912345678', 'A2', 5.0),
(3,'Le Hoang Nam', '0983456789', 'FC', 4.2),
(4,'Pham Minh Duc', '035456789', 'B2', 4.9),
(5,'Hoang Quoc Viet', '0775678901', 'C', 4.7);

-- thêm dữ liệu bảng vehicle_details
insert into vehicle_details
values
(101, 1, '29C-123.45', 'Truck', 3500),
(102, 2, '59A-888.88', 'Motorbike', 500),
(103, 3, '15R-999.99', 'Container', 32000),
(104, 4, '30F-111.22', 'Truck', 1500),
(105, 5, '43C-444.55', 'Truck', 5000);

-- thêm dữ liệu bảng shipments
insert into shipments
values
(5001, 'Smart TV Samsung 55 inch', 25.5, 15000000, 'In Transit'),
(5002, 'Laptop Dell XPS', 2.0, 35000000, 'Delivered'),
(5003, 'Máy nén khí công nghiệp', 450.0, 120000000, 'In Transit'),
(5004, 'Thùng trái cây nhập khẩu', 115.0, 2500000, 'Returned'),
(5005, 'Máy giặt LG Inverter', 70.0, 9500000, 'In Transit');

-- thêm dữ liệu bảng delivery_orders
insert into delivery_orders
values 
(9001, 5001, 1, 101, '2024-05-20 08:00:00', 2000000, 'Processing'),
(9002, 5002, 2, 102, '2024-05-20 09:30:00', 3500000, 'Finished'),
(9003, 5003, 3, 103, '2024-05-20 10:15:00', 2500000, 'Processing'),
(9004, 5004, 5, 105, '2024-05-21 07:00:00', 1500000, 'Finished'),
(9005, 5005, 4, 104, '2024-05-21 08:45:00', 2500000, 'Pendind');

-- thêm dữ liệu bảng delivery_log
insert into delivery_log
values
(1, 9001, 'Kho tổng (Hà Nội)', '2024-05-20 08:15:00','Rời kho'),
(2, 9001, 'Trạm thu phí Phủ Lý', '2024-05-20 10:00:00','Đang giao'),
(3, 9002, 'Quận 1, TP.HCM', '2024-05-20 10:30:00','Đã đến điểm đích'),
(4, 9003, 'Cảng Hải Phòng', '2024-05-21 11:00:00','Rời kho'),
(5, 9004, 'Kho hoàn hàng (Đà Nẵng)', '2024-05-21 14:00:00','Đã nhập kho trả hàng');

set sql_safe_updates = 0;

-- 1.1
update delivery_orders deoreders
join shipments s on deoreders.shipment_id = s.shipment_id
set deoreders.shipping_fee = deoreders.shipping_fee * 1.1
where deoreders.order_status = 'Finished' and s.actual_weight > 100;

-- 1.2
delete from delivery_log
where log_time < '2024-05-21';

-- PHẦN 2

-- 2.1
select license_plate, vehicle_type, max_payload 
from vehicle_details
where max_payload > 5000 or vehicle_type = 'Container';

-- 2.2
select full_name, phone_number 
from shippers
where (rating >= 4.5 and rating <= 5.0) and phone_number like '090%';

-- 2.3
select * from shipments
order by shipment_value desc
limit 2 offset 2;

-- PHẦN 3

-- 3.1
select 	s.full_name, 
		delorders.shipment_id, 
		sm.product_name, 
		delorders.shipping_fee, 
		delorders.assigned_time
from shippers s
join delivery_orders delorders on s.driver_id = delorders.driver_id
join shipments sm on delorders.shipment_id = sm.shipment_id;

-- 3.2
select 	s.*, 
		sum(delorders.shipping_fee)
from shippers s 
join delivery_orders delorders on s.driver_id = delorders.driver_id
group by s.full_name, s.driver_id
having sum(delorders.shipping_fee) > 3000000;

-- 3.3 
select * from shippers 
where rating = (select max(rating) from shippers);

-- PHẦN 4

-- 4.1
create index idx_shipment_status_value
on shipments(shipment_status, shipment_value);

-- 4.2
create view vw_driver_performance as
select s.full_name, count(delorders.shipment_id) total_orders, sum(delorders.shipping_fee) total_shipping_fee
from shippers s
join delivery_orders delorders on s.driver_id = delorders.driver_id
group by s.full_name;

-- PHẦN 5

-- 5.1
drop trigger if exists trg_after_delivery_finish;
delimiter //
create trigger trg_after_delivery_finish
after update on delivery_orders
for each row
begin

insert into delivery_log (order_id, current_location, log_time, note)
values (new.order_id, 'Destination Point', now(), 'Delivery Completed Successfully');

end //
delimiter ;

-- test trigger trg_after_delivery_finish
update delivery_orders
set order_status = 'Finished'
where order_id = 9003;

-- 5.2
drop trigger if exists trg_update_driver_rating;
delimiter //
create trigger trg_update_driver_rating
after update on delivery_orders
for each row
begin
		update shippers s
        join delivery_orders deoreders on s.driver_id = deoreders.driver_id
		set s.rating = s.rating + 0.1
		where deoreders.order_status = 'Finished';
end //
delimiter ;

-- test trigger trg_update_driver_rating
update delivery_orders
set order_status = 'Finished'
where order_id = 9001;

-- PHẦN 6

-- 6.1
drop procedure if exists sp_check_payload_status;
delimiter //
create procedure sp_check_payload_status (order_id int)
begin

end //
delimiter ;

-- 6.2
drop procedure if exists sp_reassign_driver;
delimiter //
create procedure sp_reassign_driver ()
begin
	start transaction;
    

end //
delimiter ;

















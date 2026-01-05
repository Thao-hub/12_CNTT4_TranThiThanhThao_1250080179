create user BT1 identified by 123;
grant connect, resource to BT1;

CREATE USER is01 IDENTIFIED BY password123;
CREATE USER is02 IDENTIFIED BY password123;
GRANT CONNECT, RESOURCE TO is01, is02;
ALTER USER is01 QUOTA UNLIMITED ON USERS;
ALTER USER is02 QUOTA UNLIMITED ON USERS;

CREATE TABLE SanPham (ID INT PRIMARY KEY, TenSP VARCHAR2(50));
INSERT INTO SanPham VALUES (1, 'Laptop');
COMMIT;
GRANT SELECT, INSERT, UPDATE ON SanPham TO is02;

SELECT * FROM is01.SanPham;
INSERT INTO is01.SanPham VALUES (2, 'Mouse');


create table HANGHANGKHONG (
    MAHANG varchar2(10) primary key,
    TENHANG varchar2(50),
    NGTL date,
    DUONGBAY number
);

create table CHUYENBAY (
    MACB varchar2(10) primary key,
    MAHANG varchar2(10),
    XUATPHAT varchar2(50),
    DIEMDEN varchar2(50),
    BATDAU date,
    TGBAY number(5,2),
    foreign key (MAHANG) references HANGHANGKHONG(MAHANG)
);

create table NHANVIEN (
    MANV varchar2(10) primary key,
    HOTEN varchar2(50),
    GIOITINH varchar2(10),
    NGSINH date,
    NGVL date,
    CHUYENMON varchar2(50)
);

create table PHANCONG (
    MACB varchar2(10),
    MANV varchar2(10),
    NHIEMVU varchar2(50),
    primary key (MACB, MANV),
    foreign key (MACB) references CHUYENBAY(MACB),
    foreign key (MANV) references NHANVIEN(MANV)
);

insert into HANGHANGKHONG values ('VN', 'Vietnam Airlines', to_date('15/01/1956', 'dd/mm/yyyy'), 52);
insert into HANGHANGKHONG values ('VJ', 'Vietjet Air', to_date('25/12/2011', 'dd/mm/yyyy'), 33);
insert into HANGHANGKHONG values ('BL', 'Jetstar Pacific Airlines', to_date('01/12/1990', 'dd/mm/yyyy'), 13);

insert into CHUYENBAY values ('VN550', 'VN', 'TP.HCM', 'Singapore', to_date('13:15 20/12/2025', 'hh24:mi dd/mm/yyyy'), 2);
insert into CHUYENBAY values ('VJ331', 'VJ', 'Đà Nẵng', 'Vinh', to_date('22:30 28/12/2025', 'hh24:mi dd/mm/yyyy'), 1);
insert into CHUYENBAY values ('BL696', 'BL', 'TP. HCM', 'Đà Lạt', to_date('06:00 24/12/2025', 'hh24:mi dd/mm/yyyy'), 0.5);

insert into NHANVIEN values ('NV01', 'Lâm Văn Bên', 'Nam', to_date('10/09/1991', 'dd/mm/yyyy'), to_date('05/06/2021', 'dd/mm/yyyy'), 'Phi công');
insert into NHANVIEN values ('NV02', 'Dương Thị Lục', 'Nữ', to_date('22/03/1989', 'dd/mm/yyyy'), to_date('12/11/2020', 'dd/mm/yyyy'), 'Tiếp viên');
insert into NHANVIEN values ('NV03', 'Hoàng Thanh Tùng', 'Nam', to_date('29/07/1995', 'dd/mm/yyyy'), to_date('11/04/2022', 'dd/mm/yyyy'), 'Tiếp viên');

insert into PHANCONG values ('VN550', 'NV01', 'Cơ trưởng');
insert into PHANCONG values ('VN550', 'NV02', 'Tiếp viên');
insert into PHANCONG values ('BL696', 'NV03', 'Tiếp viên trưởng');

alter table NHANVIEN add constraint ck_chuyenmon check (CHUYENMON in ('Phi công', 'Tiếp viên'));

create or replace trigger trg_check_date
before insert or update on CHUYENBAY
for each row
declare
    v_ngtl date;
begin
    select NGTL into v_ngtl from HANGHANGKHONG where MAHANG = :new.MAHANG;
    if :new.BATDAU <= v_ngtl then
        raise_application_error(-20001, 'Ngay bay phai sau ngay thanh lap hang');
    end if;
end;
/

select * from NHANVIEN where extract(month from NGSINH) = 7;

select MACB from PHANCONG group by MACB having count(MANV) = (
    select max(count(MANV)) from PHANCONG group by MACB
);

select h.MAHANG, h.TENHANG, count(c.MACB) as SO_CHUYEN
from HANGHANGKHONG h
join CHUYENBAY c on h.MAHANG = c.MAHANG
left join PHANCONG p on c.MACB = p.MACB
where c.XUATPHAT = 'Đà Nẵng'
group by h.MAHANG, h.TENHANG
having count(p.MANV) < 2;

select * from NHANVIEN nv
where not exists (
    select * from CHUYENBAY cb where not exists (
        select * from PHANCONG pc where pc.MANV = nv.MANV and pc.MACB = cb.MACB
    )
);


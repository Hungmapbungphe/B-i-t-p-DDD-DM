--1. tao table
CREATE TABLE A6_LoaiSach(
LoaiId int PRIMARY KEY identity(1,1),
Ten nvarchar(255) NOT NULL
);
CREATE TABLE A6_NhaXuatBan(
NxbId int PRIMARY KEY identity(1,1),
Ten nvarchar(255) NOT NULL,
Diachi ntext
);
CREATE TABLE A6_TacGia(
TgId int PRIMARY KEY identity(1,1),
Ten nvarchar(255) NOT NULL
);
CREATE TABLE A6_Sach(
Masach char(30) PRIMARY KEY,
Tensach nvarchar(255) NOT NULL,
Gia decimal(16,0) NOT NULL check(Gia >=0),
Tomtat ntext,
Lanxb int not null check(Lanxb >0) default 1,
Namxb int not null check(Namxb > 1900 and Namxb < 3000),
Soluong int not null check(Soluong >=0) default 0,
LoaiId int not null foreign key references
A6_LoaiSach(LoaiId),
NxbId int not null foreign key references A6_NhaXuatBan(NxbId)
);
CREATE table A6_SachTacgia(
Masach char(30) not null foreign key references
A6_Sach(Masach),
TgId int not null foreign key references A6_TacGia(TgId)
);
--2. viet sql tao du lieu
insert into A6_LoaiSach(Ten) values(N'Khoa h?c xã h?i');
insert into A6_NhaXuatBan(Ten,Diachi)
values(N'Tri Th?c',N'53 Nguy?n Du, Hai Bà Tr?ng, Hà N?i');
insert into A6_TacGia(Ten) values(N'Eran Katz');
insert into A6_Sach(Masach,Tensach,Gia,Tomtat,Lanxb,
Namxb,Soluong,LoaiId,NxbId)
values('B001',N'Trí tu? Do Thái',79000,N'B?n có mu?n bi?t: Ng??i Do
Thái sáng t?o ra cái gì và ngu?n g?c
trí tu? c?a h? xu?t phát t? ?âu không? Cu?n sách này s? d?n hé l?
nh?ng bí ?n v? s? thông thái c?a ng??i Do Thái, c?a m?t dân t?c
thông tu? v?i nh?ng ph??ng pháp và k? thu?t phát tri?n t?ng l?p trí
th?c ?ã ???c gi? kín hàng nghìn n?m nh? m?t bí ?n m?t mang tính
v?n hóa.',1,2010,100,1,1);
insert into A6_SachTacgia(Masach,TgId) values('B001',1);
-- 3.liet ke
select * from A6_Sach where Namxb >=2008;
-- 4. liet ke 10 sach
select top 10 * from A6_Sach order by Gia desc;
-- 5. Tim sach 'tin hoc'
select * from A6_Sach where Tensach like '%tin hoc%';
--6. tim & sap xep
select * from A6_Sach where Tensach like 'T%' order by Gia desc;
--7. liet ke sach cua nxbselect * from A6_Sach where NxbId in
(select NxbId from A6_NhaXuatBan where Ten like N'Tri Th?c');
--8. tim nxb tu sach
select * from A6_NhaXuatBan where NxbId in
(select NxbId from A6_Sach where Tensach like N'Trí tu? Do Thái');
--9. hien thi thong tin sach
select Masach,Tensach,Namxb,c.Ten as NhaXuatBan,b.Ten as LoaiSach
from A6_Sach a
left join A6_LoaiSach b on a.LoaiId = b.LoaiId
left join A6_NhaXuatBan c on a.NxbId = c.NxbId ;
--10.tim sach dat nhat
select top 1 * from A6_Sach order by Gia desc;
--11. tim sach sl nhieu nhat
select top 1 * from A6_Sach order by Soluong desc;
--12. tim sach theo tg
select * from A6_Sach where Masach IN
(select Masach from A6_SachTacgia where TgId in
(select TgId from A6_TacGia where Ten like 'Eran Katz')
);
--13. giam gia sach
update A6_Sach set Gia = (Gia * 90 /100) where Namxb <=2008;
--14. thong ke dau sach nxb
select NxbId,count(*) as tongdausach from A6_Sach group by NxbId ;
---
select * from A6_NhaXuatBan a
left join (select NxbId,count(*) as tongdausach
from A6_Sach group by NxbId) b
on a.NxbId = b.NxbId;
--15. thong ke dau sach loai sach
select LoaiId ,count(*) as tongdausach from A6_Sach
group by LoaiId;
--16. dat chi muc(index)
create index tensach_index on A6_Sach(Tensach);
--17. viet view
create view thongtinsach as
select a.Masach,Tensach,b.Ten as Nxb,d.Ten as Tacgia from A6_Sach a
left join A6_NhaXuatBan b on a.NxbId = b.NxbId
left join A6_SachTacgia c on a.Masach = c.Masach
left join A6_TacGia d on c.TgId = d.TgId ;
--18. viet procedure
--18.a
create procedure SP_Them_Sach @ms char(30),@ts nvarchar(255),
@g decimal(16,0),@tt ntext,@lxb int,@nxb int,@sl int,
@lId int,@nxbId int
AS
insert into A6_Sach(Masach,Tensach,Gia,Tomtat,Lanxb,
Namxb,Soluong,LoaiId,NxbId)
values(@ms,@ts,@g,@tt,@lxb,@nxb,@sl,@lId,@nxbId);
--18b
create procedure SP_Tim_Sach @k nvarchar(255)
as
select * from A6_Sach where Tensach like '%'+@k+'%';
--18c
create procedure SP_Sach_ChuyenMuc @mcm int
as
select * from A6_Sach where LoaiId = @mcm ;
--19.triggercreate trigger ko_xoa_sach
on A6_Sach
after DELETE
as
if exists (select * from deleted where Soluong >0)
rollback transaction;
--20. trigger
create trigger ko_xoa_chuyenmuc
on A6_LoaiSach
after delete
as
if exists (select * from A6_Sach where LoaiId IN
(select LoaiId from deleted ))
rollback transaction;
create procedure kh_dh as
select * from Customer;
select * from Orders;
exec kh_dh;
create procedure them_kh @ten nvarchar(150),@dc ntext,@tel char(20)
as
insert into Customer(CustomerName,CustomerAddress,PhoneNumber)
values(@ten ,@dc,@tel);
select * from Customer;
EXEC them_kh @ten=N'nguyen van an',@dc=N'12 hang chieu, ha noi',
@tel='092277711';
drop procedure them_kh;
create procedure them_kh2 @ten nvarchar(150),@dc ntext,@tel char(20)
as
if(len(@tel)>11)
begin
insert into Customer(CustomerName,CustomerAddress,PhoneNumber)
values(@ten ,@dc,@tel);
select * from Customer;
end
create procedure SP_Them_LoaiSP @ma char(20),@ten nvarchar(255) as
insert into LoaiSanPham(MaLoai,TenLoai)
values(@ma,@ten);
select * from LoaiSanPham;
-- trigger
create trigger trigger_them_kh
on Customer
after INSERT
AS
select * from Customer;
insert into Customer(CustomerName,CustomerAddress,PhoneNumber)
values(N'An',N'11 duy tan','0988222111');
-- tao trigger ko cho xoa khach hang
create trigger ko_xoa_kh
on Customer
after DELETE
as
rollback transaction;
drop trigger trigger_them_kh;
create trigger trigger_them_kh
on Customer
after INSERT
AS
if exists (select * from inserted where PhoneNumber like '099%')BEGIN
ROLLBACK TRANSACTION;
END
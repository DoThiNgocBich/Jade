---Cau1---
CREATE PROCEDURE sp_ThemMoiNhanVien
    @manv INT,
    @tennv NVARCHAR(50),
    @gioitinh NVARCHAR(10),
    @diachi NVARCHAR(100),
    @sodt VARCHAR(20),
    @email VARCHAR(50),
    @phong NVARCHAR(50),
    @Flag INT
AS
BEGIN
    SET NOCOUNT ON;
    
    --Kiểm tra giới tính
    IF @gioitinh NOT IN ('Nam', 'Nữ')
    BEGIN
        RETURN 1;
    END
    
    --Kiểm tra Flag để xác định là thêm mới hay cập nhật thông tin nhân viên
    IF @Flag = 0 
    BEGIN
        INSERT INTO Nhanvien(manv, tennv, gioitinh, diachi, sodt, email, phong)
        VALUES(@manv, @tennv, @gioitinh, @diachi, @sodt, @email, @phong);
    END
    ELSE
    BEGIN
        UPDATE Nhanvien
        SET tennv = @tennv,
            gioitinh = @gioitinh,
            diachi = @diachi,
            sodt = @sodt,
            email = @email,
            phong = @phong
        WHERE manv = @manv;
    END
    
    RETURN 0;
END

---Cau2---
CREATE PROCEDURE ThemMoiSanPham @masp int, @tenhang varchar(50), @tensp varchar(50), @soluong int, @mausac varchar(20), @giaban float, @donvitinh varchar(20), @mota varchar(100), @Flag int
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra tên hãng sản xuất
    IF NOT EXISTS(SELECT * FROM Hangsx WHERE tenhang = @tenhang)
    BEGIN
        SELECT 1 AS 'MaLoi', 'Không tìm thấy tên hãng sản xuất' AS 'MoTaLoi'
        RETURN
    END

    -- Kiểm tra số lượng sản phẩm
    IF @soluong < 0
    BEGIN
        SELECT 2 AS 'MaLoi', 'Số lượng sản phẩm phải lớn hơn hoặc bằng 0' AS 'MoTaLoi'
        RETURN
    END

    -- Nếu là chế độ thêm mới sản phẩm
    IF @Flag = 0
    BEGIN
        INSERT INTO Sanpham (masp, mahangsx, tensp, soluong, mausac, giaban, donvitinh, mota)
        VALUES (@masp, (SELECT mahangsx FROM Hangsx WHERE tenhang = @tenhang), @tensp, @soluong, @mausac, @giaban, @donvitinh, @mota)

        SELECT 0 AS 'MaLoi', 'Thêm mới sản phẩm thành công' AS 'MoTaLoi'
    END
    ELSE -- Nếu là chế độ cập nhật sản phẩm
    BEGIN
        UPDATE Sanpham
        SET mahangsx = (SELECT mahangsx FROM Hangsx WHERE tenhang = @tenhang), 
            tensp = @tensp, 
            soluong = @soluong, 
            mausac = @mausac, 
            giaban = @giaban, 
            donvitinh = @donvitinh, 
            mota = @mota
        WHERE masp = @masp

        SELECT 0 AS 'MaLoi', 'Cập nhật sản phẩm thành công' AS 'MoTaLoi'
    END
END

---cau3---
CREATE PROCEDURE XoaNhanVien 
    @manv int
AS
BEGIN
    -- Kiểm tra xem manv đã tồn tại trong bảng nhanvien hay chưa
    IF NOT EXISTS (SELECT * FROM nhanvien WHERE manv = @manv)
    BEGIN
        RETURN 1; -- Trả về 1 nếu manv chưa tồn tại trong bảng nhanvien
    END

    BEGIN TRANSACTION; -- Bắt đầu transaction để đảm bảo tính toàn vẹn của dữ liệu

    -- Xóa dữ liệu trong bảng Nhap
    DELETE FROM Nhap WHERE manv = @manv;

    -- Xóa dữ liệu trong bảng Xuat
    DELETE FROM Xuat WHERE manv = @manv;

    -- Xóa dữ liệu trong bảng nhanvien
    DELETE FROM nhanvien WHERE manv = @manv;

    COMMIT TRANSACTION; -- Kết thúc transaction và lưu các thay đổi vào database

    RETURN 0; -- Trả về 0 nếu xóa thành công
END


---cau4---
CREATE PROCEDURE XoaSanPham
    @masp varchar(10),
    @errorCode int OUTPUT
AS
BEGIN
    -- Kiểm tra xem masp đã tồn tại trong bảng sanpham chưa
    IF NOT EXISTS (SELECT * FROM sanpham WHERE masp = @masp)
    BEGIN
        SET @errorCode = 1;
        RETURN;
    END
    
    -- Thực hiện xóa sản phẩm đó khỏi bảng sanpham
    DELETE FROM sanpham WHERE masp = @masp;
    
    -- Thực hiện xóa các bản ghi trong bảng Nhap và Xuat mà sản phẩm này đã tham gia
    DELETE FROM Nhap WHERE masp = @masp;
    DELETE FROM Xuat WHERE masp = @masp;
    
    SET @errorCode = 0;
END

---cau5---

CREATE PROCEDURE XoaNhanVien 
    @manv int
AS
BEGIN
    -- Kiểm tra xem manv đã tồn tại trong bảng nhanvien hay chưa
    IF NOT EXISTS (SELECT * FROM nhanvien WHERE manv = @manv)
    BEGIN
        RETURN 1; -- Trả về 1 nếu manv chưa tồn tại trong bảng nhanvien
    END

    BEGIN TRANSACTION; -- Bắt đầu transaction để đảm bảo tính toàn vẹn của dữ liệu

    -- Xóa dữ liệu trong bảng Nhap
    DELETE FROM Nhap WHERE manv = @manv;

    -- Xóa dữ liệu trong bảng Xuat
    DELETE FROM Xuat WHERE manv = @manv;

    -- Xóa dữ liệu trong bảng nhanvien
    DELETE FROM nhanvien WHERE manv = @manv;

    COMMIT TRANSACTION; -- Kết thúc transaction và lưu các thay đổi vào database

    RETURN 0; -- Trả về 0 nếu xóa thành công
END

---cau6----
CREATE PROCEDURE ThemCapNhatNhap
    @sohdn int,
    @masp varchar(10),
    @manv varchar(10),
    @ngaynhap date,
    @soluongN int,
    @dongiaN float,
    @errorCode int OUTPUT
AS
BEGIN
    -- Kiểm tra masp có tồn tại trong bảng Sanpham hay không
    IF NOT EXISTS (SELECT * FROM Sanpham WHERE masp = @masp)
    BEGIN
        SET @errorCode = 1
        RETURN
    END

    -- Kiểm tra manv có tồn tại trong bảng Nhanvien hay không
    IF NOT EXISTS (SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        SET @errorCode = 2
        RETURN
    END

    -- Kiểm tra soluongN <= Soluong trong bảng Sanpham
    IF @soluongN > (SELECT soluong FROM Sanpham WHERE masp = @masp)
    BEGIN
        SET @errorCode = 3
        RETURN
    END

    -- Kiểm tra nếu số hóa đơn đã tồn tại thì cập nhật, ngược lại thêm mới
    IF EXISTS (SELECT * FROM Nhap WHERE sohdn = @sohdn)
    BEGIN
        UPDATE Nhap
        SET masp = @masp,
            manv = @manv,
            ngaynhap = @ngaynhap,
            soluongN = @soluongN,
            dongiaN = @dongiaN
        WHERE sohdn = @sohdn
    END
    ELSE
    BEGIN
        INSERT INTO Nhap (sohdn, masp, manv, ngaynhap, soluongN, dongiaN)
        VALUES (@sohdn, @masp, @manv, @ngaynhap, @soluongN, @dongiaN)
    END

    SET @errorCode = 0
END

---cau 7---
CREATE PROCEDURE InsertXuat 
    @sohdx INT,
    @masp INT,
    @manv INT,
    @ngayxuat DATE,
    @soluongX INT
AS
BEGIN
    DECLARE @checkMasp INT, @checkManv INT, @checkSoluong INT

    -- Kiểm tra masp có tồn tại trong bảng Sanpham hay không
    SELECT @checkMasp = COUNT(*) FROM Sanpham WHERE masp = @masp
    IF (@checkMasp = 0)
    BEGIN
        SELECT 1 AS 'Error'
        RETURN
    END

    -- Kiểm tra manv có tồn tại trong bảng Nhanvien hay không
    SELECT @checkManv = COUNT(*) FROM Nhanvien WHERE manv = @manv
    IF (@checkManv = 0)
    BEGIN
        SELECT 2 AS 'Error'
        RETURN
    END

    -- Kiểm tra soluongX không vượt quá soluong trong bảng Sanpham
    SELECT @checkSoluong = soluong FROM Sanpham WHERE masp = @masp
    IF (@soluongX > @checkSoluong)
    BEGIN
        SELECT 3 AS 'Error'
        RETURN
    END

    -- Kiểm tra sohdx đã tồn tại trong bảng Xuat hay chưa
    IF EXISTS(SELECT 1 FROM Xuat WHERE sohdx = @sohdx)
    BEGIN
        UPDATE Xuat SET masp = @masp, manv = @manv, ngayxuat = @ngayxuat, soluongX = @soluongX WHERE sohdx = @sohdx
    END
    ELSE
    BEGIN
        INSERT INTO Xuat(sohdx, masp, manv, ngayxuat, soluongX) VALUES(@sohdx, @masp, @manv, @ngayxuat, @soluongX)
    END

    SELECT 0 AS 'Error'
END
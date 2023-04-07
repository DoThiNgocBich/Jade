------Cau1---------------------------
INSERT INTO GiaoVien(MaGV,TenGV)
VALUES
('01', 'Pham Trong Huynh'),
('02', 'Tran Van Dinh'),
('03', 'Ngo Tan Khai');

select * from GiaoVien 

INSERT INTO Lop (MaLop, TenLop, Phong, SiSo, MaGV)
VALUES
('01', '09CNPM1', '305', '31', '01'),
('02', '09CNPM2', '304', '35', '02'),
('03', '09CNPM3', '202', '33', '03');

select * from lop

INSERT INTO SinhVien (MaSV, TenSV, GioiTinh, quequan, MaLop)
VALUES
('01', 'Do Thi Ngoc Bich', 'Nu', 'Dak Nong', '01'),
('02', 'Nguyen Van Dung', 'Nam', 'HCM', '01'),
('03', 'Vo Van Khuong', 'Nam', 'HCM', '01'),
('04', 'Nguyen Van Tu', 'Nam', 'HCM', '02'),
('05', 'Pham Quynh Giang', 'Nu', 'Dong Nai', '03');

select * from SinhVien

----Cau2--------------------------
SELECT SinhVien.MaSV, SinhVien.TenSV, Lop.TenLop, GiaoVien.TenGV
FROM SinhVien
INNER JOIN Lop ON SinhVien.MaLop = Lop.MaLop
INNER JOIN GiaoVien ON Lop.MaGV = GiaoVien.MaGV
WHERE Lop.TenLop = 'ten_lop' AND GiaoVien.TenGV = 'ten_gv';

---Cau3---------------------------
CREATE PROCEDURE InsertSinhVien
    @MaSV varchar(10),
    @TenSV nvarchar(50),
    @GioiTinh nvarchar(3),
    @quequan nvarchar(50),
    @TenLop nvarchar(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaLop varchar(10)
    SET @MaLop = (SELECT MaLop FROM Lop WHERE TenLop = @TenLop)

    IF (@MaLop IS NULL)
    BEGIN
        PRINT 'Khong ton tai lop hoc'
        RETURN
    END

    INSERT INTO SinhVien (MaSV, TenSV, GioiTinh, quequan, MaLop)
    VALUES (@MaSV, @TenSV, @GioiTinh, @quequan, @MaLop)
END

---Cau4---------------------------
CREATE TRIGGER trg_UpdateMaLop
AFTER UPDATE OF MaLop ON SinhVien
FOR EACH ROW
BEGIN
  DECLARE oldSiSo INT;
  DECLARE newSiSo INT;
  
  -- Lấy số lượng sinh viên trong lớp cũ
  SELECT SiSo INTO oldSiSo FROM Lop WHERE MaLop = OLD.MaLop;
  
  -- Lấy số lượng sinh viên trong lớp mới
  SELECT SiSo INTO newSiSo FROM Lop WHERE MaLop = NEW.MaLop;
  
  -- Cập nhật lại SiSo trong bảng Lop
  UPDATE Lop SET SiSo = oldSiSo - 1 WHERE MaLop = OLD.MaLop;
  UPDATE Lop SET SiSo = newSiSo + 1 WHERE MaLop = NEW.MaLop;
  
  -- Cập nhật lại mã lớp cho sinh viên
  UPDATE SinhVien SET MaLop = NEW.MaLop WHERE MaSV = OLD.MaSV;
END;
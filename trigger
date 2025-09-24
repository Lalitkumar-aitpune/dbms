-- Main Library table
CREATE TABLE Library (
    BookID INT PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Year INT
);

-- Audit table to keep track of old values
CREATE TABLE Library_Audit (
    AuditID INT AUTO_INCREMENT PRIMARY KEY,
    BookID INT,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Year INT,
    Action_Type VARCHAR(20),
    Action_Time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample Data
INSERT INTO Library VALUES
(1, 'DBMS Concepts', 'Navathe', 2019),
(2, 'Operating System', 'Galvin', 2020),
(3, 'C Programming', 'Kernighan', 2018);

DELIMITER $$

CREATE TRIGGER trg_Library_AfterUpdate
AFTER UPDATE ON Library
FOR EACH ROW
BEGIN
    INSERT INTO Library_Audit(BookID, Title, Author, Year, Action_Type)
    VALUES(OLD.BookID, OLD.Title, OLD.Author, OLD.Year, 'UPDATED');
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_Library_AfterDelete
AFTER DELETE ON Library
FOR EACH ROW
BEGIN
    INSERT INTO Library_Audit(BookID, Title, Author, Year, Action_Type)
    VALUES(OLD.BookID, OLD.Title, OLD.Author, OLD.Year, 'DELETED');
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_Library_BeforeUpdate
BEFORE UPDATE ON Library
FOR EACH ROW
BEGIN
    -- Example: Ensure year cannot be in the future
    IF NEW.Year > YEAR(CURDATE()) THEN
        SET NEW.Year = YEAR(CURDATE());
    END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER trg_Library_StmtUpdate
AFTER UPDATE ON Library
FOR EACH ROW
BEGIN
    -- Row-level by default, but we can insert same marker each time
    INSERT INTO Library_Audit(BookID, Title, Author, Year, Action_Type)
    VALUES(OLD.BookID, OLD.Title, OLD.Author, OLD.Year, 'UPDATE_STATEMENT');
END$$

DELIMITER ;



-- Update a row
UPDATE Library SET Year = 2025 WHERE BookID = 1;

-- Delete a row
DELETE FROM Library WHERE BookID = 2;

-- Check Audit
SELECT * FROM Library_Audit;

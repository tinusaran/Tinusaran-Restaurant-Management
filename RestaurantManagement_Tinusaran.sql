--TABLE CREATION
CREATE TABLE Restaurant (
    restaurantId NUMBER PRIMARY KEY,
    restaurantName VARCHAR2(30),
    city VARCHAR2(30),
    email VARCHAR2(30),
    mobile VARCHAR2(15),
    rating NUMBER(9,2)
);

CREATE TABLE RestaurantBackup (
    RbId NUMBER PRIMARY KEY,
    restaurantId NUMBER,
    restaurantName VARCHAR2(30),
    city VARCHAR2(30),
    email VARCHAR2(30),
    mobile VARCHAR2(15),
    rating NUMBER(9,2),
    operation VARCHAR2(30),
    activityOn DATE DEFAULT SYSDATE
);

CREATE SEQUENCE RestaurantBackup_seq START WITH 1 INCREMENT BY 1;

--PROCEDURES
-- Add Restaurant
CREATE OR REPLACE PROCEDURE Add_Restaurant (
    p_rid IN NUMBER,
    p_rname IN VARCHAR2,
    p_rcity IN VARCHAR2,
    p_remail IN VARCHAR2,
    p_rmobile IN VARCHAR2,
    p_rrating IN NUMBER
) AS
BEGIN
    INSERT INTO Restaurant VALUES (p_rid, p_rname, p_rcity, p_remail, p_rmobile, p_rrating);
END;
/

--Search by ID
CREATE OR REPLACE PROCEDURE Search_Restaurant_ById (
    p_rid IN NUMBER
) AS
    v_row Restaurant%ROWTYPE;
BEGIN
    SELECT * INTO v_row FROM Restaurant WHERE restaurantId = p_rid;
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_row.restaurantId);
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_row.restaurantName);
    DBMS_OUTPUT.PUT_LINE('City: ' || v_row.city);
    DBMS_OUTPUT.PUT_LINE('Email: ' || v_row.email);
    DBMS_OUTPUT.PUT_LINE('Mobile: ' || v_row.mobile);
    DBMS_OUTPUT.PUT_LINE('Rating: ' || v_row.rating);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Restaurant not found.');
END;
/

--Update Restaurant
CREATE OR REPLACE PROCEDURE Update_Restaurant (
    p_rid IN NUMBER,
    p_rname IN VARCHAR2,
    p_rcity IN VARCHAR2,
    p_remail IN VARCHAR2,
    p_rmobile IN VARCHAR2,
    p_rrating IN NUMBER
) AS
BEGIN
    UPDATE Restaurant
    SET restaurantName = p_rname,
        city = p_rcity,
        email = p_remail,
        mobile = p_rmobile,
        rating = p_rrating
    WHERE restaurantId = p_rid;
END;
/

-- Delete Restaurant
CREATE OR REPLACE PROCEDURE Delete_Restaurant_ById (
    p_rid IN NUMBER
) AS
BEGIN
    DELETE FROM Restaurant WHERE restaurantId = p_rid;
END;
/

--Cursor
BEGIN
    FOR r IN (SELECT * FROM Restaurant) LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || r.restaurantId || ', Name: ' || r.restaurantName || ', City: ' || r.city || ', Rating: ' || r.rating);
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE Fetch_Restaurant_ById (
    p_rid IN NUMBER,
    p_rname OUT VARCHAR2,
    p_rcity OUT VARCHAR2,
    p_remail OUT VARCHAR2,
    p_rmobile OUT VARCHAR2,
    p_rrating OUT NUMBER
) AS
BEGIN
    SELECT restaurantName, city, email, mobile, rating
    INTO p_rname, p_rcity, p_remail, p_rmobile, p_rrating
    FROM Restaurant
    WHERE restaurantId = p_rid;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_rname := NULL;
        p_rcity := NULL;
        p_remail := NULL;
        p_rmobile := NULL;
        p_rrating := NULL;
END;
/

--Triggers
--Insert
CREATE OR REPLACE TRIGGER trg_restaurant_insert
AFTER INSERT ON Restaurant
FOR EACH ROW
BEGIN
    INSERT INTO RestaurantBackup
    VALUES (RestaurantBackup_seq.NEXTVAL, :NEW.restaurantId, :NEW.restaurantName,
            :NEW.city, :NEW.email, :NEW.mobile, :NEW.rating, 'INSERT', SYSDATE);
END;
/

--Update
CREATE OR REPLACE TRIGGER trg_restaurant_update
BEFORE UPDATE ON Restaurant
FOR EACH ROW
BEGIN
    INSERT INTO RestaurantBackup
    VALUES (RestaurantBackup_seq.NEXTVAL, :OLD.restaurantId, :OLD.restaurantName,
            :OLD.city, :OLD.email, :OLD.mobile, :OLD.rating, 'UPDATE', SYSDATE);
END;
/

--Delete
CREATE OR REPLACE TRIGGER trg_restaurant_delete
BEFORE DELETE ON Restaurant
FOR EACH ROW
BEGIN
    INSERT INTO RestaurantBackup
    VALUES (RestaurantBackup_seq.NEXTVAL, :OLD.restaurantId, :OLD.restaurantName,
            :OLD.city, :OLD.email, :OLD.mobile, :OLD.rating, 'DELETE', SYSDATE);
END;
/
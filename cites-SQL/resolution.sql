/*
 *   ISEL-DEETC-SisInf
 *   ND 2022-2025
 *
 *   
 *   Information Systems Project - Active Databases
 *   
 */

/* ### DO NOT REMOVE THE QUESTION MARKERS ### */


-- region Question 1.a 
CREATE OR REPLACE FUNCTION check_scooter_in_dock() RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM DOCK
        WHERE scooter = NEW.scooter AND state = 'occupy'
    ) THEN
        RAISE EXCEPTION 'The scooter is not in a dock available for use';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_check_scooter_in_dock
BEFORE INSERT ON TRAVEL
FOR EACH ROW
EXECUTE FUNCTION check_scooter_in_dock();
-- endregion


-- region Question 1.b
CREATE OR REPLACE FUNCTION check_ongoing_trip() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM TRAVEL
        WHERE scooter = NEW.scooter AND dfinal IS NULL
    ) THEN
        RAISE EXCEPTION 'This scooter is already in use on another trip';
END IF;
    IF EXISTS (
        SELECT 1 FROM TRAVEL
        WHERE client = NEW.client AND dfinal IS NULL
    ) THEN
        RAISE EXCEPTION 'This user already has a trip in progress';
END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_check_ongoing_trip
BEFORE INSERT ON TRAVEL
FOR EACH ROW
EXECUTE FUNCTION check_ongoing_trip();
-- endregion






-- region Question 2
CREATE OR REPLACE FUNCTION fx_dock_occupancy(station_id integer)
RETURNS DECIMAL(3,2) AS $$
DECLARE
total_docks INTEGER;
    occupied_docks INTEGER;
    occupancy_rate DECIMAL(3,2);
BEGIN
SELECT COUNT(*) INTO total_docks
FROM DOCK
WHERE station = station_id;

SELECT COUNT(*) INTO occupied_docks
FROM DOCK
WHERE station = station_id
  AND state = 'occupy';

IF total_docks = 0 THEN
        RETURN 0;
ELSE
        occupancy_rate := occupied_docks::DECIMAL / total_docks;
RETURN occupancy_rate;
END IF;
END;
$$ LANGUAGE plpgsql;
-- endregion
 
-- region Question 3
CREATE OR REPLACE VIEW RIDER
AS
SELECT p.*,c.dtregister,cd.id AS cardid,cd.credit,cd.typeofcard
FROM CLIENT c
    INNER JOIN PERSON p ON (c.person=p.id)
	INNER JOIN CARD cd ON (cd.client = c.person);


CREATE OR REPLACE FUNCTION rider_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN

    IF EXISTS (SELECT 1 FROM PERSON WHERE email = NEW.email) THEN
        RAISE EXCEPTION 'Email already exists: %', NEW.email;
END IF;

    IF EXISTS (SELECT 1 FROM PERSON WHERE taxnumber = NEW.taxnumber) THEN
        RAISE EXCEPTION 'Nif already exists: %', NEW.taxnumber;
END IF;

INSERT INTO PERSON (email, taxnumber, name)
VALUES (NEW.email, NEW.taxnumber, NEW.name)
    RETURNING id INTO NEW.id;

INSERT INTO CLIENT (person, dtregister)
VALUES (NEW.id, COALESCE(NEW.dtregister, CURRENT_TIMESTAMP));

IF NOT EXISTS (SELECT 1 FROM TYPEOFCARD WHERE reference = NEW.typeofcard) THEN
        RAISE EXCEPTION 'Invalid pass type: %', NEW.typeofcard;
END IF;

INSERT INTO CARD (credit, typeofcard, client)
VALUES (COALESCE(NEW.credit, 0.00), NEW.typeofcard, NEW.id)
    RETURNING id INTO NEW.cardid;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rider_insert
    INSTEAD OF INSERT ON RIDER
    FOR EACH ROW EXECUTE FUNCTION rider_insert_trigger();

CREATE OR REPLACE FUNCTION rider_update_trigger()
RETURNS TRIGGER AS $$
BEGIN

UPDATE PERSON SET
                  email = NEW.email,
                  taxnumber = NEW.taxnumber,
                  name = NEW.name
WHERE id = OLD.id;

UPDATE CLIENT SET
    dtregister = NEW.dtregister
WHERE person = OLD.id;

UPDATE CARD SET
                credit = NEW.credit,
                typeofcard = NEW.typeofcard
WHERE id = OLD.cardid AND client = OLD.id;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rider_update
    INSTEAD OF UPDATE ON RIDER
    FOR EACH ROW EXECUTE FUNCTION rider_update_trigger();
-- endregion

-- region Question 4
CREATE OR REPLACE PROCEDURE startTrip(dockid INTEGER, clientid INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
v_scooter_id INTEGER;
    v_card_id INTEGER;
    v_unlock NUMERIC(3,2);
BEGIN

SELECT scooter INTO v_scooter_id
FROM DOCK
WHERE number = dockid AND state = 'occupy';

IF v_scooter_id IS NULL THEN
        RAISE EXCEPTION 'Dock % is not occupied or does not exist.', dockid;
END IF;

SELECT id, credit INTO v_card_id, v_unlock
FROM CARD, SERVICECOST
WHERE client = clientid AND credit >= SERVICECOST.unlock
    LIMIT 1;

IF v_card_id IS NULL THEN
        RAISE EXCEPTION 'Client % does not have a card with enough credit.', clientid;
END IF;

INSERT INTO TRAVEL (dinitial, client, scooter, stinitial)
VALUES (now(), clientid, v_scooter_id, dockid);

UPDATE DOCK
SET state = 'free',
    scooter = NULL
WHERE number = dockid;

UPDATE CARD
SET credit = credit - (SELECT unlock FROM SERVICECOST)
WHERE id = v_card_id;
END;
$$;
-- endregion

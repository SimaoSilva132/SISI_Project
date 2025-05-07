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
    -- Verifica se a trotineta está numa doca com estado 'occupy'
    IF NOT EXISTS (
        SELECT 1 FROM DOCK
        WHERE scooter = NEW.scooter AND state = 'occupy'
    ) THEN
        RAISE EXCEPTION 'A trotineta não está numa doca disponível para uso';
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
    -- Verifica se a trotineta já está numa viagem em curso (dfinal IS NULL)
    IF EXISTS (
        SELECT 1 FROM TRAVEL
        WHERE scooter = NEW.scooter AND dfinal IS NULL
    ) THEN
        RAISE EXCEPTION 'Esta trotineta já está em uso noutra viagem';
END IF;

    -- Verifica se o utilizador já está numa viagem em curso (dfinal IS NULL)
    IF EXISTS (
        SELECT 1 FROM TRAVEL
        WHERE client = NEW.client AND dfinal IS NULL
    ) THEN
        RAISE EXCEPTION 'Este utilizador já tem uma viagem em curso';
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
CREATE OR REPLACE FUCTION fx-dock-occupancy(dockid integer) RETURNS ...
--TODO
-- endregion
 
-- region Question 3
CREATE OR REPLACE VIEW RIDER
AS
SELECT p.*,c.dtregister,cd.id AS cardid,cd.credit,cd.typeofcard
FROM CLIENT c INNER JOIN PERSON p ON (c.person=p.id)
	INNER JOIN CARD cd ON (cd.client = c.person);
--TODO
-- endregion

-- region Question 4
CREATE OR REPLACE PROCEDURE startTrip(dockid integer, clientid  integer) ...
--TODO
-- endregion
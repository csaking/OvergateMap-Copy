-- MySQL Script generated by MySQL Workbench
-- Mon Oct  1 09:58:28 2018
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema 18indteam5db
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `18indteam5db` ;

-- -----------------------------------------------------
-- Schema 18indteam5db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `18indteam5db` DEFAULT CHARACTER SET utf8 ;
USE `18indteam5db` ;

-- -----------------------------------------------------
-- Table `18indteam5db`.`stores`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `18indteam5db`.`stores` ;

CREATE TABLE IF NOT EXISTS `18indteam5db`.`stores` (
  `StoreID` INT(11) NOT NULL AUTO_INCREMENT,
  `StoreName` VARCHAR(50) NOT NULL,
  `UpDown` INT(11) NOT NULL COMMENT '0 = DOWNSTAIRS, 1 = UPPER FLOOR, 2 = TOP FLOOR (only Debenhams extends to the top floor)',
  `Area` INT(11) NOT NULL DEFAULT '0' COMMENT 'Area will be represented as a square unit, just work with the integer assuming it was m^2',
  `CurrentPopulation` INT(11) NOT NULL DEFAULT '0',
  `TotalPopulation` INT(11) NOT NULL DEFAULT '0',
  `PopulationDensity` FLOAT NOT NULL DEFAULT '0',
  PRIMARY KEY (`StoreID`))
ENGINE = InnoDB
AUTO_INCREMENT = 69
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `18indteam5db`.`storehistory`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `18indteam5db`.`storehistory` ;

CREATE TABLE IF NOT EXISTS `18indteam5db`.`storehistory` (
  `HistoryID` INT(11) NOT NULL AUTO_INCREMENT,
  `StoreID` INT(11) NOT NULL,
  `Date` DATE NOT NULL,
  `TotalPeopleIn` INT(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`HistoryID`),
  INDEX `StoreID_idx` (`StoreID` ASC),
  CONSTRAINT `StoreID`
    FOREIGN KEY (`StoreID`)
    REFERENCES `18indteam5db`.`stores` (`StoreID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 273
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `18indteam5db`.`storetracker`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `18indteam5db`.`storetracker` ;

CREATE TABLE IF NOT EXISTS `18indteam5db`.`storetracker` (
  `TrackerID` INT(11) NOT NULL AUTO_INCREMENT,
  `Timestamp` TIME NOT NULL,
  `Date` DATE NOT NULL,
  `InOut` INT(11) NOT NULL COMMENT '0 = OUT, 1 = IN',
  `Stores_StoreID` INT(11) NOT NULL,
  PRIMARY KEY (`TrackerID`),
  INDEX `fk_StoreTracker_Stores_idx` (`Stores_StoreID` ASC),
  CONSTRAINT `fk_StoreTracker_Stores`
    FOREIGN KEY (`Stores_StoreID`)
    REFERENCES `18indteam5db`.`stores` (`StoreID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 2187
DEFAULT CHARACTER SET = utf8;

USE `18indteam5db` ;

-- -----------------------------------------------------
-- Placeholder table for view `18indteam5db`.`storeandweekhistory`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `18indteam5db`.`storeandweekhistory` (`StoreID` INT, `StoreName` INT, `UpDown` INT, `Area` INT, `CurrentPopulation` INT, `TotalPopulation` INT, `PopulationDensity` INT);

-- -----------------------------------------------------
-- function calculatePeopleDensity
-- -----------------------------------------------------

USE `18indteam5db`;
DROP function IF EXISTS `18indteam5db`.`calculatePeopleDensity`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` FUNCTION `calculatePeopleDensity`(storeID INT) RETURNS int(11)
BEGIN
DECLARE tempArea, popNumber INT;
DECLARE popDensity FLOAT;

SELECT stores.Area INTO tempArea
FROM stores
WHERE stores.StoreID = storeID;

SELECT 18indteam5db.getCurrentPop(storeID) INTO popNumber;

SET popDensity = tempArea/popNumber;
RETURN popDensity;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function getCurrentPop
-- -----------------------------------------------------

USE `18indteam5db`;
DROP function IF EXISTS `18indteam5db`.`getCurrentPop`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` FUNCTION `getCurrentPop`(storeID INT) RETURNS int(11)
BEGIN
DECLARE currentPop, temp INT;
SELECT 18indteam5db.getTotalPop(storeID) INTO currentPop;

SELECT COUNT(storeTracker.`InOut`) INTO temp
FROM storeTracker 
WHERE storetracker.`Stores_StoreID` = storeID 
AND storeTracker.`InOut` =  0;

SET currentPop = currentPop - temp;

RETURN currentPop;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getStoreHistory
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`getStoreHistory`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `getStoreHistory`(in StoreID INT, IN searchDate date)
Begin
Select TotalPeopleIn
FROM storehistory
where storehistory.StoreID = StoreID
AND storehistory.Date = searchDate;
End$$

DELIMITER ;

-- -----------------------------------------------------
-- function getTotalPop
-- -----------------------------------------------------

USE `18indteam5db`;
DROP function IF EXISTS `18indteam5db`.`getTotalPop`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` FUNCTION `getTotalPop`(storeID INT) RETURNS int(11)
BEGIN
DECLARE totalPop INT;
SELECT COUNT(storeTracker.`InOut`) INTO totalPop
FROM storeTracker 
WHERE storetracker.`Stores_StoreID` = storeID 
AND storeTracker.`InOut` =  1;
RETURN totalPop;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure overgateComplexClear
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`overgateComplexClear`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `overgateComplexClear`()
BEGIN
TRUNCATE overgatecomplex;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure overgateComplexCreate
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`overgateComplexCreate`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `overgateComplexCreate`(IN timeboy Time, IN `date` date, inoutboi int)
BEGIN
	INSERT INTO overgatecomplex(`Timestamp`,`Date`,  `InOut`)
    VALUES (timeboy, `date`, inoutboi);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure overgateComplexDeleteByID
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`overgateComplexDeleteByID`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `overgateComplexDeleteByID`(IN overgateID INT)
BEGIN
	DELETE FROM overgatecomplex
    WHERE overgatecomplex.ID = overgateID;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure overgateComplexEnterRecord
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`overgateComplexEnterRecord`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `overgateComplexEnterRecord`(IN InOrOut INT)
BEGIN
INSERT INTO overgatecomplex(`Timestamp`, `Date`, `InOut`)
VALUES(current_time(), current_date(), InOrOut);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure overgateComplexGetInTotal
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`overgateComplexGetInTotal`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `overgateComplexGetInTotal`()
BEGIN
SELECT COUNT(overgatecomplex.`InOut`) AS NumberOfIn
FROM overgatecomplex
WHERE overgatecomplex.`InOut` = 1;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure overgateComplexGetOutTotal
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`overgateComplexGetOutTotal`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `overgateComplexGetOutTotal`()
BEGIN
SELECT COUNT(overgatecomplex.`InOut`) AS NumberOfOut
FROM overgatecomplex
WHERE overgatecomplex.`InOut` = 0;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure overgateComplexSelect
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`overgateComplexSelect`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `overgateComplexSelect`(IN OvergateID int)
BEGIN
	Select *
	From overgatecomplex
    where ID = OvergateID;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure overgateGetInForDay
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`overgateGetInForDay`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `overgateGetInForDay`(IN searchDate date)
BEGIN
SELECT COUNT(overgatecomplex.`InOut`) AS NumberOfIn
FROM overgatecomplex
WHERE overgatecomplex.`InOut` = 1
AND overgatecomplex.`Date` = searchDate;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure overgateGetOutForDay
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`overgateGetOutForDay`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `overgateGetOutForDay`(IN searchDate date)
BEGIN
SELECT COUNT(overgatecomplex.`InOut`) AS NumberOfOut
FROM overgatecomplex
WHERE overgatecomplex.`InOut` = 0
AND overgatecomplex.`Date` = searchDate;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storeHistoryBatchUpdate
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storeHistoryBatchUpdate`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storeHistoryBatchUpdate`()
BEGIN
DECLARE x INT;
DECLARE peopleIn INT;
SET x = 1;
SET peopleIn = 0;
WHILE x != 69 DO
 SET peopleIn = (SELECT stores.TotalPopulation FROM stores WHERE stores.StoreID = x);
 CALL storeHistoryCreate(x, peopleIn);
 SET x = x + 1;
END WHILE;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storeHistoryClear
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storeHistoryClear`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storeHistoryClear`()
BEGIN
TRUNCATE storehistory;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storeHistoryCreate
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storeHistoryCreate`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storeHistoryCreate`(IN storeID INT, IN peopleIn INT)
BEGIN
INSERT INTO storehistory(StoreID, `Date`, TotalPeopleIn)
VALUES (storeID, current_date(), peopleIn);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storeHistoryDeleteByID
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storeHistoryDeleteByID`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storeHistoryDeleteByID`(IN historyID INT)
BEGIN
DELETE FROM storehistory
WHERE storehistory.HistoryID = historyID;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storeTrackerClear
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storeTrackerClear`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storeTrackerClear`()
BEGIN
TRUNCATE storeTracker;
CALL storesResetPopulations();
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storeTrackerCreate
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storeTrackerCreate`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storeTrackerCreate`(IN timeboi time, IN `date` date, IN inandout int, In StoreID int)
BEGIN
	INSERT INTO storetracker(`Timestamp`, `Date`, `InOut`, Stores_StoreID)
    VALUES (timeboi, `date`, inandout, StoreID);
    CALL storesUpdatePopulations(StoreID);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storeTrackerDelete
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storeTrackerDelete`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storeTrackerDelete`(IN trackerID int)
BEGIN
	DELETE FROM storeTracker
	WHERE TrackerID = trackerID;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storeTrackerEnterRecord
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storeTrackerEnterRecord`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storeTrackerEnterRecord`(IN InOrOut INT, IN storeID INT)
BEGIN
INSERT INTO storetracker(`Timestamp`, `Date`, `InOut`, Stores_StoreID)
VALUES(current_time(), current_date(), InOrOut, storeID);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storeTrackerGetInForDay
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storeTrackerGetInForDay`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storeTrackerGetInForDay`(IN storeID INT, IN searchDate date)
BEGIN
SELECT COUNT(storetracker.`InOut`) AS totalNumberInForDay
FROM storetracker
WHERE storetracker.Stores_StoreID = storeID
AND storetracker.`InOut` = 1
AND storetracker.`Date` = searchDate;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storeTrackerGetInTotal
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storeTrackerGetInTotal`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storeTrackerGetInTotal`(IN storeID INT)
BEGIN
SELECT COUNT(storetracker.`InOut`) AS totalNumberIn
FROM storetracker
WHERE storetracker.Stores_StoreID = storeID
AND storetracker.`InOut` = 1;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storeTrackerGetOutForDay
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storeTrackerGetOutForDay`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storeTrackerGetOutForDay`(IN storeID INT, IN searchDate date)
BEGIN
SELECT COUNT(storetracker.`InOut`) AS totalNumberOutForDay
FROM storetracker
WHERE storetracker.Stores_StoreID = storeID
AND storetracker.`InOut` = 0
AND storetracker.`Date` = searchDate;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storeTrackerGetOutTotal
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storeTrackerGetOutTotal`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storeTrackerGetOutTotal`(IN storeID INT)
BEGIN
SELECT COUNT(storetracker.`InOut`) AS totalNumberOut
FROM storetracker
WHERE storetracker.Stores_StoreID = storeID
AND storetracker.`InOut` = 0;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storeTrackerSelect
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storeTrackerSelect`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storeTrackerSelect`(in trackerID int)
BEGIN
	Select *
	From storetracker
    where TrackerID = trackerID;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storesClear
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storesClear`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storesClear`()
BEGIN
TRUNCATE stores;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storesCreate
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storesCreate`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storesCreate`(IN storeName VARCHAR(50), IN upDown INT, IN storeArea INT)
BEGIN
	INSERT INTO stores(StoreName, UpDown, Area)
    VALUES(storeName, upDown, storeArea);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storesDeleteByID
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storesDeleteByID`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storesDeleteByID`(IN storeID INT)
Begin
DELETE FROM stores
WHERE stores.StoreID = storeID;
End$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storesDeleteByName
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storesDeleteByName`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storesDeleteByName`(IN storeName VARCHAR(50))
Begin
DELETE FROM stores
WHERE stores.StoreName = storeName;
End$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storesGetArea
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storesGetArea`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storesGetArea`(IN storeID INT)
BEGIN
SELECT stores.Area
FROM stores
WHERE stores.StoreID = storeID;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storesGetIDByName
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storesGetIDByName`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storesGetIDByName`(in storeName VARCHAR(50), IN floor INT)
Begin
Select StoreID
FROM stores
where stores.StoreName = storeName
AND stores.UpDown = floor;
End$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storesGetNumberOf
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storesGetNumberOf`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storesGetNumberOf`()
BEGIN
SELECT COUNT(DISTINCT(StoreName)) AS NumberOfStores
FROM stores;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storesResetPopulations
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storesResetPopulations`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storesResetPopulations`()
BEGIN
DECLARE x INT;
SET x = 1;
WHILE x < 69 DO
UPDATE stores
SET stores.CurrentPopulation = 0, stores.TotalPopulation = 0, stores.PopulationDensity = 0
WHERE stores.StoreID = x;
SET x = x + 1;
END WHILE;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storesSelectByFloor
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storesSelectByFloor`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storesSelectByFloor`(IN floorInt INT)
BEGIN
SELECT *
FROM stores
WHERE stores.UpDown = floorInt;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storesSelectByID
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storesSelectByID`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storesSelectByID`(in storeID INT)
Begin
Select *
FROM stores
where stores.StoreID = storeID;
End$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storesSelectByName
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storesSelectByName`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storesSelectByName`(in storeName VARCHAR(50))
Begin
Select *
FROM stores
where stores.StoreName = storeName;
End$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure storesUpdatePopulations
-- -----------------------------------------------------

USE `18indteam5db`;
DROP procedure IF EXISTS `18indteam5db`.`storesUpdatePopulations`;

DELIMITER $$
USE `18indteam5db`$$
CREATE DEFINER=`18indteam5`@`%` PROCEDURE `storesUpdatePopulations`(IN storeID INT)
BEGIN
DECLARE x, y INT;
DECLARE z FLOAT;

SELECT 18indteam5db.getCurrentPop(storeID) INTO x;
SELECT 18indteam5db.getTotalPop(storeID) INTO y;
SELECT 18indteam5db.calculatePeopleDensity(storeID) INTO z;

UPDATE stores
SET
CurrentPopulation = x,
TotalPopulation = y,
PopulationDensity = z
WHERE stores.StoreID = storeID;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `18indteam5db`.`storeandweekhistory`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `18indteam5db`.`storeandweekhistory`;
DROP VIEW IF EXISTS `18indteam5db`.`storeandweekhistory` ;
USE `18indteam5db`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`18indteam5`@`%` SQL SECURITY DEFINER VIEW `18indteam5db`.`storeandweekhistory` AS select `s`.`StoreID` AS `StoreID`,`s`.`StoreName` AS `StoreName`,`s`.`UpDown` AS `UpDown`,`s`.`Area` AS `Area`,`s`.`CurrentPopulation` AS `CurrentPopulation`,`s`.`TotalPopulation` AS `TotalPopulation`,`s`.`PopulationDensity` AS `PopulationDensity` from (`18indteam5db`.`stores` `s` join `18indteam5db`.`storehistory` `sh` on((`s`.`StoreID` = `sh`.`StoreID`)));

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

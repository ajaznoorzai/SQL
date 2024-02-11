

-- @@1

CREATE TABLE MoSpo_HallOfFame(
hoFdriverId INTEGER UNSIGNED NOT NULL,
hoFYear YEAR,
hoFSeries ENUM('BritishGT','Formula1','FormulaE','SuperGT') NOT NULL,
hoFImage VARCHAR(200),
hoFWiNTEGEMoSpo_HallOfFameR(2) DEFAULT(0) check ( hoFWins < 100 ), 
hoFBestRaceName VARCHAR(50), hoFBestRaceDate date, PRIMARY KEY(hoFdriverId,hoFYear), 
FOREIGN KEY (hoFBestRaceName,hoFBestRaceDate) references MoSpo_Race(raceName,raceDate) ON DELETE SET NULL, 
CONSTRAINT FK_100 FOREIGN KEY (hoFdriverId) references MoSpo_Driver (driverId) ON DELETE CASCADE
);
 
-- @@2

ALTER TABLE MoSpo_Driver
ADD driverWeight FLOAT(3,1)
CONSTRAINT min_max_weight
CHECK (0.0<= driveriWeight <= 99.9);


-- @@3

UPDATE MoSpo_RacingTeam
SET MoSpo_RacingTeam.teamPostcode = 'HP135PN'
WHERE MoSpo_RacingTeam.teamName ='Beechdean Motorsport ';

-- @@4


DELETE FROM MoSpo_Driver
where MoSpo_Driver.driverLastname='Senna' AND MoSpo_Driver.driverFirstname='Ayrton';

-- @@5

SELECT COUNT(MoSpo_RacingTeam.teamName) as 'numberTeams' FROM MoSpo_RacingTeam;


-- @@6

SELECT driverId, concat(left(driverFirstname,1),' ',driverLastname) as driverName,driverDOB
FROM MoSpo_Driver WHERE left(driverLastname,1) = left(driverFirstname,1);

-- @@7

SELECT teamName,COUNT(driverId) as numberOfDriver
FROM MoSpo_RacingTeam AS MoRaceTeam
inner join 
MoSpo_Driver as MoRaceDriver on MoRaceTeam.teamName = MoRaceDriver.driverTeam
GROUP BY teamName
HAVING count(driverId)>1;


-- @@8

SELECT  DISTINCT mli.lapInfoRaceName AS raceName, mli.lapInfoRaceDate AS raceDate,min(mli.lapInfoTime) AS lapTime
FROM MoSpo_LapInfo AS mli
INNER JOIN 
MoSpo_Lap AS ml on  mli.lapInfoRaceName = ml.lapRaceName and mli.lapInfoRaceDate = ml.lapRaceDate
WHERE lapInfoTime IS NOT NULL
GROUP BY raceName,raceDate;


-- @@9

SELECT pitStopRaceName AS 'raceName', COUNT(pitStopDuration)/COUNT(DISTINCT Year(pitStopRaceDate)) AS 'avgStops'
FROM MoSpo_PitStop
GROUP BY pitStopRaceName;

-- @@10


SELECT DISTINCT carMake
FROM MoSpo_Car, MoSpo_RaceEntry,MoSpo_LapInfo
WHERE lapInfoCompleted = 0 AND YEAR(lapInfoRaceDate)=2018 AND raceEntryNumber = lapInfoRaceNumber AND raceEntryCarId = carId
GROUP BY carMake

-- @@11

SELECT raceEntryRaceName AS raceName, raceEntryRaceDate AS raceDate, IFNULL(COUNT(pitStopDuration),0) AS mostPitStops
FROM MoSpo_RaceEntry LEFT OUTER JOIN MoSpo_PitStop
ON raceEntryNumber = pitstopRaceNumber AND 
raceEntryRaceName = pitStopRaceName AND
raceEntryRaceDate = pitstopRaceDate GROUP BY
raceName,raceDate;

-- @@12



DELIMITER $$
CREATE FUNCTION totalRaceTime(raceNumber TINYINT UNSIGNED,nameOfRace CHAR(30), dateOfRace DATE)
RETURNS INTEGER 
BEGIN 
DECLARE raceTime INT;
DECLARE errorSpotter INT;
SELECT SUM(lapInfoTime) INTO raceTime
FROM MoSpo_LapInfo 
WHERE lapInfoRaceName = nameOfRace AND lapInfoRaceDate = dateOfRace AND lapInfoRaceNumber=raceNumber;
IF raceTime IS NULL 
THEN 
SELECT COUNT(*) INTO errorSpotter FROM MoSpo_LapInfo WHERE lapInfoRaceDate = dateOfRace;
IF errorSpotter = 0
THEN
SIGNAL SQLSTATE'45000'
	SET MESSAGE_TEXT ='Race does not exist for the given Date';
END IF;
SELECT COUNT(*) INTO errorSpotter FROM MoSpo_LapInfo WHERE lapInfoRaceNumber = raceNumber;
IF errorSpotter = 0
THEN 
SIGNAL SQLSTATE'45000'
SET MESSAGE_TEXT = ' RaceEntry does not exist';
END IF;
SELECT COUNT(*) INTO errorSpotter FROM MoSpo_LapInfo  WHERE lapInfoRaceName = nameOfRace;
 IF errorSpotter = 0
THEN 
SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT ='Race does not exist';
   SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT='TimeForAllLaps does not exist';
END IF;
END IF;
RETURN raceTime;
END 
$$

SELECT totalRaceTime(4, 'German Grand Prix', '2016-07-06');



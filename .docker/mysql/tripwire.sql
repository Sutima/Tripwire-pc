-- tripwire.sql
-- Updated for MySQL 5.7+ / MySQL 8
-- Converted MyISAM tables to InnoDB, removed DEFINER lines, removed old sql_mode references.

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES UTF8MB4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `_history_login`
--

DROP TABLE IF EXISTS `_history_login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `_history_login` (
  `ip` varchar(42) NOT NULL,
  `username` varchar(25) CHARACTER SET UTF8MB4 COLLATE UTF8MB4_unicode_ci DEFAULT NULL,
  `method` enum('user','api','cookie','sso') NOT NULL,
  `result` enum('success','fail') NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ip`,`time`),
  KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `_history_signatures`
--

DROP TABLE IF EXISTS `_history_signatures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `_history_signatures` (
  `historyID` int NOT NULL AUTO_INCREMENT,
  `id` int NOT NULL,
  `signatureID` char(6) DEFAULT NULL,
  `systemID` int DEFAULT NULL,
  `type` enum('unknown','combat','data','relic','ore','gas','wormhole') NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `bookmark` varchar(100) DEFAULT NULL,
  `lifeTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lifeLeft` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lifeLength` int NOT NULL,
  `createdByID` int NOT NULL,
  `createdByName` varchar(100) NOT NULL,
  `modifiedByID` int NOT NULL,
  `modifiedByName` varchar(100) NOT NULL,
  `modifiedTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `maskID` decimal(12,1) NOT NULL,
  `status` enum('add','update','delete','undo:add','undo:update','undo:delete') NOT NULL,
  PRIMARY KEY (`historyID`),
  KEY `systemID` (`systemID`),
  KEY `id` (`id`),
  KEY `maskID` (`maskID`),
  KEY `status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=UTF8MB4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `_history_wormholes`
--

DROP TABLE IF EXISTS `_history_wormholes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `_history_wormholes` (
  `historyID` int NOT NULL AUTO_INCREMENT,
  `id` int NOT NULL,
  `initialID` int NOT NULL,
  `secondaryID` int NOT NULL,
  `type` char(4) DEFAULT NULL,
  `parent` char(9) DEFAULT NULL,
  `life` enum('stable','critical') NOT NULL,
  `mass` enum('stable','destab','critical') NOT NULL,
  `maskID` decimal(12,1) NOT NULL,
  `status` enum('add','update','delete','undo:add','undo:update','undo:delete') NOT NULL,
  PRIMARY KEY (`historyID`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=UTF8MB4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `accounts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(25) CHARACTER SET UTF8MB4 COLLATE UTF8MB4_unicode_ci NOT NULL,
  `password` char(60) CHARACTER SET UTF8MB4 COLLATE UTF8MB4_bin NOT NULL,
  `ban` tinyint NOT NULL DEFAULT '0',
  `super` tinyint NOT NULL DEFAULT '0',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `logins` int NOT NULL DEFAULT '0',
  `lastLogin` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `ban` (`ban`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=UTF8MB4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `active`
--

DROP TABLE IF EXISTS `active`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `active` (
  `ip` char(42) NOT NULL,
  `instance` decimal(13,3) NOT NULL DEFAULT '0.000',
  `session` char(50) NOT NULL,
  `userID` mediumint NOT NULL,
  `maskID` decimal(12,1) NOT NULL,
  `systemID` int DEFAULT NULL,
  `systemName` char(50) DEFAULT NULL,
  `activity` char(25) DEFAULT NULL,
  `notify` char(150) DEFAULT NULL,
  `version` varchar(100) DEFAULT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ip`,`instance`,`session`,`userID`),
  KEY `notify` (`notify`),
  KEY `activity` (`activity`),
  KEY `instance` (`instance`),
  KEY `maskID` (`maskID`),
  KEY `time` (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `characters`
--

DROP TABLE IF EXISTS `characters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `characters` (
  `userID` int NOT NULL,
  `characterID` int NOT NULL,
  `characterName` varchar(50) CHARACTER SET UTF8MB4 COLLATE UTF8MB4_bin NOT NULL,
  `corporationID` int NOT NULL,
  `corporationName` varchar(60) CHARACTER SET UTF8MB4 COLLATE UTF8MB4_bin NOT NULL,
  `admin` tinyint NOT NULL DEFAULT '0',
  `ban` tinyint NOT NULL DEFAULT '0',
  `added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`userID`),
  UNIQUE KEY `characterID` (`characterID`),
  KEY `ban` (`ban`),
  KEY `admin` (`admin`),
  KEY `corporationID` (`corporationID`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `comments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `systemID` int NOT NULL,
  `comment` text NOT NULL,
  `created` datetime NOT NULL,
  `createdByID` int NOT NULL,
  `createdByName` varchar(100) NOT NULL,
  `modified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modifiedByID` int NOT NULL,
  `modifiedByName` varchar(100) NOT NULL,
  `maskID` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `maskID` (`maskID`),
  KEY `systemID, maskID` (`maskID`,`systemID`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=UTF8MB4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `esi`
--

DROP TABLE IF EXISTS `esi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `esi` (
  `userID` int NOT NULL,
  `characterID` int NOT NULL,
  `characterName` varchar(100) NOT NULL,
  `accessToken` varchar(3000) NOT NULL,
  `refreshToken` varchar(1000) NOT NULL,
  `tokenExpire` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`userID`,`characterID`),
  KEY `characterID` (`characterID`),
  KEY `userID` (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Trigger: trackingRemove (Remove DEFINER, use plain CREATE TRIGGER)
--

DELIMITER ;;
CREATE TRIGGER `trackingRemove`
AFTER DELETE ON `esi`
FOR EACH ROW
BEGIN
    DELETE FROM tracking WHERE characterID = OLD.characterID;
END;;
DELIMITER ;

--
-- Table structure for table `flares`
--

DROP TABLE IF EXISTS `flares`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `flares` (
  `maskID` decimal(12,1) NOT NULL,
  `systemID` int NOT NULL,
  `flare` enum('red','yellow','green') CHARACTER SET latin1 NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`maskID`,`systemID`),
  KEY `time` (`time`),
  KEY `maskID` (`maskID`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `groups` (
  `maskID` decimal(12,1) NOT NULL,
  `joined` tinyint NOT NULL DEFAULT '0',
  `eveID` int NOT NULL,
  `eveType` smallint NOT NULL,
  PRIMARY KEY (`maskID`,`eveType`,`eveID`),
  KEY `joined` (`joined`),
  KEY `eveType` (`eveType`),
  KEY `eveID` (`eveID`),
  KEY `maskID` (`maskID`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `jumps`
--

DROP TABLE IF EXISTS `jumps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `jumps` (
  `wormholeID` int NOT NULL,
  `characterID` int NOT NULL,
  `characterName` varchar(50) NOT NULL,
  `fromID` int NOT NULL,
  `fromName` varchar(20) DEFAULT NULL,
  `toID` int NOT NULL,
  `toName` varchar(20) DEFAULT NULL,
  `shipTypeID` int DEFAULT NULL,
  `shipType` varchar(50) DEFAULT NULL,
  `maskID` decimal(12,1) NOT NULL DEFAULT '0.0',
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `shipTypeID` (`shipTypeID`),
  KEY `maskID` (`maskID`),
  KEY `wormholeID` (`wormholeID`),
  KEY `time` (`time`),
  KEY `massSearch` (`maskID`,`wormholeID`,`time`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `masks`
--

DROP TABLE IF EXISTS `masks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `masks` (
  `maskID` decimal(12,1) NOT NULL,
  `name` varchar(100) NOT NULL,
  `ownerID` int NOT NULL,
  `ownerType` smallint NOT NULL,
  PRIMARY KEY (`maskID`),
  UNIQUE KEY `name` (`name`,`ownerID`,`ownerType`),
  KEY `ownerID` (`ownerID`),
  KEY `ownerType` (`ownerType`),
  KEY `maskSearch` (`maskID`,`ownerType`,`ownerID`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `preferences`
--

DROP TABLE IF EXISTS `preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `preferences` (
  `userID` int NOT NULL,
  `options` text,
  PRIMARY KEY (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `signatures`
--

DROP TABLE IF EXISTS `signatures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `signatures` (
  `id` int NOT NULL AUTO_INCREMENT,
  `signatureID` char(6) DEFAULT NULL,
  `systemID` int DEFAULT NULL,
  `type` enum('unknown','combat','data','relic','ore','gas','wormhole') NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 DEFAULT NULL,
  `bookmark` varchar(100) DEFAULT NULL,
  `lifeTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lifeLeft` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lifeLength` int NOT NULL,
  `createdByID` int NOT NULL,
  `createdByName` varchar(100) NOT NULL,
  `modifiedByID` int NOT NULL,
  `modifiedByName` varchar(100) NOT NULL,
  `modifiedTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `maskID` decimal(12,1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `systemID, maskID` (`systemID`,`maskID`),
  KEY `modifiedTime` (`modifiedTime`),
  KEY `maskID` (`maskID`),
  KEY `lifeLeft, lifeLength` (`lifeLeft`,`lifeLength`),
  KEY `type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `statistics`
--

DROP TABLE IF EXISTS `statistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `statistics` (
  `userID` int NOT NULL,
  `characterID` int NOT NULL,
  `maskID` decimal(12,1) NOT NULL,
  `signatures_added` int NOT NULL DEFAULT '0',
  `signatures_updated` int NOT NULL DEFAULT '0',
  `signatures_deleted` int NOT NULL DEFAULT '0',
  `wormholes_added` int NOT NULL DEFAULT '0',
  `wormholes_updated` int NOT NULL DEFAULT '0',
  `wormholes_deleted` int NOT NULL DEFAULT '0',
  `comments_added` int NOT NULL DEFAULT '0',
  `comments_updated` int NOT NULL DEFAULT '0',
  `comments_deleted` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`userID`,`characterID`,`maskID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_activity`
--

DROP TABLE IF EXISTS `system_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `system_activity` (
  `systemID` int NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `shipJumps` mediumint NOT NULL DEFAULT '0',
  `shipKills` mediumint NOT NULL DEFAULT '0',
  `podKills` mediumint NOT NULL DEFAULT '0',
  `npcKills` mediumint NOT NULL DEFAULT '0',
  PRIMARY KEY (`systemID`,`time`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 PACK_KEYS=0;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_visits`
--

DROP TABLE IF EXISTS `system_visits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `system_visits` (
  `userID` int NOT NULL,
  `characterID` int NOT NULL,
  `systemID` int NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`userID`,`characterID`,`systemID`,`date`)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4 ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tokens`
--

DROP TABLE IF EXISTS `tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `tokens` (
  `userID` int NOT NULL,
  `token` varchar(400) NOT NULL,
  PRIMARY KEY (`userID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tracking`
--

DROP TABLE IF EXISTS `tracking`;
/*!40101 SET @saved_cs_client      = @@character_set_client */;
/*!40101 SET character_set_client  = UTF8MB4 */;
CREATE TABLE `tracking` (
  `userID` int NOT NULL,
  `characterID` int NOT NULL,
  `characterName` varchar(100) NOT NULL,
  `systemID` int NOT NULL,
  `systemName` varchar(100) NOT NULL,
  `stationID` int DEFAULT NULL,
  `stationName` varchar(100) DEFAULT NULL,
  `shipID` bigint DEFAULT NULL,
  `shipName` varchar(100) DEFAULT NULL,
  `shipTypeID` int DEFAULT NULL,
  `shipTypeName` varchar(100) DEFAULT NULL,
  `maskID` decimal(12,1) NOT NULL,
  PRIMARY KEY (`maskID`,`characterID`),
  KEY `systemID` (`systemID`),
  KEY `occupantSearch` (`maskID`,`systemID`),
  KEY `characterID` (`characterID`),
  KEY `maskID` (`maskID`),
  KEY `userID` (`userID`),
  KEY `maskID, systemID` (`maskID`,`systemID`)
) ENGINE=MEMORY DEFAULT CHARSET=UTF8MB4 DELAY_KEY_WRITE=1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Trigger: systemVisits (Remove DEFINER, plain CREATE TRIGGER)
--

DELIMITER ;;
CREATE TRIGGER `systemVisits`
AFTER UPDATE ON `tracking`
FOR EACH ROW
BEGIN
    IF NEW.systemID <> OLD.systemID THEN
        INSERT INTO system_visits (userID, characterID, systemID, date)
        VALUES (NEW.userID, NEW.characterID, NEW.systemID, NOW());
    END IF;
END;;
DELIMITER ;

--
-- Trigger: jumpHistory (Remove DEFINER, plain CREATE TRIGGER)
--

DELIMITER ;;
CREATE TRIGGER `jumpHistory`
AFTER UPDATE ON `tracking`
FOR EACH ROW
BEGIN
    IF NEW.systemID <> OLD.systemID THEN
        SET @wormholeID = (
          SELECT w.id
          FROM wormholes w
          INNER JOIN signatures a ON initialID = a.id
          INNER JOIN signatures b ON secondaryID = b.id
          WHERE (a.systemID = NEW.systemID OR b.systemID = NEW.systemID)
            AND (a.systemID = OLD.systemID OR b.systemID = OLD.systemID)
        );
        IF @wormholeID IS NOT NULL THEN
            INSERT INTO jumps (
              wormholeID, characterID, characterName,
              toID, toName, fromID, fromName,
              shipTypeID, shipType, maskID
            ) VALUES (
              @wormholeID, NEW.characterID, NEW.characterName,
              NEW.systemID, NEW.systemName,
              OLD.systemID, OLD.systemName,
              NEW.shipTypeID, NEW.shipTypeName, NEW.maskID
            );
        END IF;
    END IF;
END;;
DELIMITER ;

--
-- Table structure for table `wormholes`
--

DROP TABLE IF EXISTS `wormholes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = UTF8MB4 */;
CREATE TABLE `wormholes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `initialID` int NOT NULL,
  `secondaryID` int NOT NULL,
  `type` char(4) DEFAULT NULL,
  `parent` char(9) DEFAULT NULL,
  `life` enum('stable','critical') NOT NULL,
  `mass` enum('stable','destab','critical') NOT NULL,
  `maskID` decimal(12,1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `maskID` (`maskID`),
  KEY `initialID` (`initialID`),
  KEY `secondaryID` (`secondaryID`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Event: activeClean, flaresClean, etc. (Remove DEFINER, use CREATE EVENT)
-- If needed, rename or keep them as is if MySQL 5.7+ allows them to run.

DROP EVENT IF EXISTS `activeClean`;
DELIMITER ;;
CREATE EVENT `activeClean`
ON SCHEDULE EVERY 15 SECOND
STARTS '2014-09-27 23:42:27'
ON COMPLETION NOT PRESERVE
ENABLE
DO
  DELETE FROM active WHERE DATE_ADD(time, INTERVAL 15 SECOND) < NOW();
;;
DELIMITER ;

DROP EVENT IF EXISTS `flaresClean`;
DELIMITER ;;
CREATE EVENT `flaresClean`
ON SCHEDULE EVERY 1 HOUR
STARTS '2014-08-21 03:15:55'
ON COMPLETION NOT PRESERVE
ENABLE
DO
  DELETE FROM flares WHERE DATE_ADD(time, INTERVAL 24 HOUR) < NOW();
;;
DELIMITER ;

DROP EVENT IF EXISTS `jumpsClean`;
DELIMITER ;;
CREATE EVENT `jumpsClean`
ON SCHEDULE EVERY 1 HOUR
STARTS '2017-01-27 04:24:28'
ON COMPLETION NOT PRESERVE
ENABLE
DO
  DELETE FROM `jumps`
   WHERE wormholeID NOT IN (
     SELECT id FROM wormholes WHERE type <> 'GATE'
   );
;;
DELIMITER ;

DROP EVENT IF EXISTS `signatureClean`;
DELIMITER ;;
CREATE EVENT `signatureClean`
ON SCHEDULE EVERY 1 MINUTE
STARTS '2018-05-11 15:57:18'
ON COMPLETION NOT PRESERVE
ENABLE
DO
BEGIN
    UPDATE signatures
      SET modifiedByID = 0, modifiedByName = "Tripwire"
      WHERE lifeLeft < NOW()
        AND lifeLength <> '0'
        AND type <> 'wormhole';

    DELETE FROM signatures
      WHERE lifeLeft < NOW()
        AND lifeLength <> '0'
        AND type <> 'wormhole';
END;;
DELIMITER ;

DROP EVENT IF EXISTS `trackingClean`;
DELIMITER ;;
CREATE EVENT `trackingClean`
ON SCHEDULE EVERY 15 SECOND
STARTS '2017-01-30 17:34:38'
ON COMPLETION NOT PRESERVE
ENABLE
DO
  DELETE FROM tracking WHERE userID NOT IN (SELECT userID FROM active);
;;
DELIMITER ;

DROP EVENT IF EXISTS `wormholeClean`;
DELIMITER ;;
CREATE EVENT `wormholeClean`
ON SCHEDULE EVERY 1 MINUTE
STARTS '2018-05-12 02:24:17'
ON COMPLETION NOT PRESERVE
ENABLE
DO
BEGIN
    UPDATE signatures s
    INNER JOIN wormholes w ON (s.id = initialID OR s.id = secondaryID)
      AND life = 'stable'
      SET modifiedByID = 0,
          modifiedByName = "Tripwire",
          modifiedTime = NOW()
      WHERE s.type = 'wormhole'
        AND lifeLength <> '0'
        AND DATE_SUB(lifeLeft, INTERVAL 4 HOUR) < NOW();

    UPDATE wormholes w
    INNER JOIN signatures s ON (s.id = initialID OR s.id = secondaryID)
      AND (s.type = 'wormhole'
           AND life = 'stable'
           AND lifeLength <> '0'
           AND DATE_SUB(lifeLeft, INTERVAL 4 HOUR) < NOW())
      SET life = 'critical';

    DELETE FROM signatures
      WHERE DATE_ADD(lifeLeft, INTERVAL 0.1 * lifeLength SECOND) < NOW()
        AND lifeLength <> 0
        AND type = 'wormhole';

    DELETE FROM wormholes
      WHERE  NOT EXISTS (
               SELECT id
               FROM signatures s
               WHERE s.id = wormholes.secondaryID
             )
         OR NOT EXISTS (
               SELECT id
               FROM signatures s
               WHERE s.id = wormholes.initialID
             );
END;;
DELIMITER ;

DROP EVENT IF EXISTS `wormholeCritical`;
DELIMITER ;;
CREATE EVENT `wormholeCritical`
ON SCHEDULE EVERY 1 MINUTE
STARTS '2014-08-21 03:16:46'
ON COMPLETION NOT PRESERVE
ENABLE
DO
BEGIN
    UPDATE signatures s
    INNER JOIN wormholes w
       ON (s.id = initialID OR s.id = secondaryID)
       AND life = 'stable'
      SET modifiedByID = 0,
          modifiedByName = 'Tripwire',
          modifiedTime = NOW()
      WHERE s.type = 'wormhole'
        AND lifeLength <> '0'
        AND DATE_SUB(lifeLeft, INTERVAL 4 HOUR) < NOW();

    UPDATE wormholes w
    INNER JOIN signatures s
       ON (s.id = initialID OR s.id = secondaryID)
       AND s.type = 'wormhole'
       AND life = 'stable'
       AND lifeLength <> '0'
       AND DATE_SUB(lifeLeft, INTERVAL 4 HOUR) < NOW()
      SET life = 'critical';
END;;
DELIMITER ;

--
-- Cleanup
--

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-09-25 16:46:59

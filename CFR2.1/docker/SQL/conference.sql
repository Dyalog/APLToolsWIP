-- MySQL dump 10.13  Distrib 5.7.15, for Linux (x86_64)
--
-- Host: localhost    Database: conference
-- ------------------------------------------------------
-- Server version	5.7.15

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Bookings`
--

DROP TABLE IF EXISTS `Bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Bookings` (
  `OrderNumber` int(11) NOT NULL AUTO_INCREMENT,
  `TransactionId` char(16) DEFAULT NULL,
  `Status` char(1) DEFAULT NULL,
  `InvoiceAmount` decimal(6,2) DEFAULT NULL,
  `TotalGross` decimal(6,2) DEFAULT NULL,
  `TotalNet` decimal(6,2) DEFAULT NULL,
  `ConferenceGross` decimal(6,2) DEFAULT NULL,
  `ConferenceNet` decimal(6,2) DEFAULT NULL,
  `SpouseGross` decimal(6,2) DEFAULT NULL,
  `SpouseNet` decimal(6,2) DEFAULT NULL,
  `Accomodation` decimal(6,2) DEFAULT NULL,
  `SpecialDiscount` decimal(6,2) DEFAULT NULL,
  `YEarlyBird` char(1) DEFAULT NULL,
  `InvoiceNo` int(6) DEFAULT NULL,
  `YDays` char(6) DEFAULT NULL,
  `YHotel` char(6) DEFAULT NULL,
  `YBanquet` char(1) DEFAULT NULL,
  `Courses` varchar(12) DEFAULT NULL,
  `Name` varchar(40) DEFAULT NULL,
  `EMail` varchar(80) DEFAULT NULL,
  `Company` varchar(64) DEFAULT NULL,
  `Address` varchar(84) DEFAULT NULL,
  `Town` varchar(30) DEFAULT NULL,
  `Region` varchar(30) DEFAULT NULL,
  `Postcode` varchar(12) DEFAULT NULL,
  `CountryCode` char(2) DEFAULT NULL,
  `SecondName` varchar(40) DEFAULT NULL,
  `SecondEmail` varchar(80) DEFAULT NULL,
  `RoomType` char(52) DEFAULT NULL,
  `SpouseMealPlan` char(36) DEFAULT NULL,
  `Notes` varchar(256) DEFAULT NULL,
  `AuthAmount` decimal(6,2) DEFAULT NULL,
  `AuthCurrency` char(3) DEFAULT NULL,
  `EUVat` char(2) DEFAULT '',
  `VatNumber` char(14) DEFAULT NULL,
  `Conference_VAT` decimal(6,2) NOT NULL DEFAULT '0.00',
  `Accommodation_VAT` decimal(6,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`OrderNumber`)
) ENGINE=MyISAM AUTO_INCREMENT=747 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Bookings`
--

LOCK TABLES `Bookings` WRITE;
/*!40000 ALTER TABLE `Bookings` DISABLE KEYS */;
/*!40000 ALTER TABLE `Bookings` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-03-24 15:00:56

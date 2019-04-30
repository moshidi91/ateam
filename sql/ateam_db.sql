-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Mar 27, 2019 at 09:18 AM
-- Server version: 10.2.23-MariaDB
-- PHP Version: 7.2.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ateam_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_addApps` (IN `_name` VARCHAR(50), IN `_description` LONGTEXT, IN `_compatibility` VARCHAR(255), IN `_developer` VARCHAR(255), IN `_icon` VARCHAR(500), IN `_apk` VARCHAR(255), IN `_userID` INT(11), IN `_categoryID` INT(11), IN `_active` INT(11), IN `_privatekey` VARCHAR(255), IN `_publickey` VARCHAR(255), IN `_url` VARCHAR(255), IN `_platform` VARCHAR(255))  NO SQL
BEGIN

DECLARE appId int DEFAULT -1;

INSERT INTO `Application` (`id`, `name`, `description`, `compatibility`, `developer`,`icon`,`apk`,`privatekey`,`publickey`,`url`, `UserID`,`dateCreated`, `dateUpdated`, `active`, `platform`) VALUES (NULL, _name , _description, _compatibility, _developer,_icon,_apk ,_privatekey, _publickey,_url, _userID ,now(), now(), _active, _platform);


SELECT LAST_INSERT_ID() INTO appId;

INSERT INTO Appcat(AppID , CatID) VALUES ((SELECT LAST_INSERT_ID()),_categoryID);

SELECT appId;

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_addCategory` (IN `_name` VARCHAR(255), IN `_icon` VARCHAR(255))  NO SQL
BEGIN

INSERT INTO `Category` (`ID`, `Name`, `icon`) VALUES (NULL, _name, _icon);

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_addImage` (IN `_image` VARCHAR(500), IN `_appID` INT)  NO SQL
BEGIN

INSERT INTO `AppImage` (`ID`, `Image`, `AppID`) VALUES (NULL,_image, _appID);

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_addRating` (IN `_userID` INT, IN `_appID` INT, IN `_rate` INT)  MODIFIES SQL DATA
BEGIN

DECLARE rated int DEFAULT -1;

SELECT `ID` INTO rated from Rating WHERE `UserID` = _userID AND `AppID` = _appID;

    IF rated = -1 THEN
        INSERT INTO Rating (`ID`, `UserID`, `AppID`, `Rate`) VALUES  	  (NULL, _userID,_appID,_rate);
ELSE 
	UPDATE `Rating`
    SET `Rate` = _rate 
    WHERE `Rating`.`ID` = rated;

END IF;

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_addUser` (IN `_name` VARCHAR(50), IN `_surname` VARCHAR(50), IN `_email` VARCHAR(50), IN `_password` VARCHAR(100), IN `_userType` VARCHAR(10), IN `_img` VARCHAR(50), IN `_occupation` VARCHAR(50), IN `_company` VARCHAR(50), IN `_active` INT)  MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN

INSERT INTO `User` (`id`,`Name`,`Surname`,`Email`,`Password`,`typeID`,`Img`,`Occupation`,`Company`,`active`) VALUES (NULL, _name,_surname,_email,_password,_userType,_img,_occupation,_company,_active);

SELECT * FROM `User` WHERE `id` = (SELECT LAST_INSERT_ID());

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_creatingSalt` (IN `_email` VARCHAR(50), IN `_salt` VARCHAR(50))  NO SQL
    SQL SECURITY INVOKER
BEGIN

UPDATE `User`
SET `Salt` = _salt
WHERE 
`Email`= _email;
END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_deleteApp` (IN `_id` INT(15))  NO SQL
BEGIN

UPDATE `Application` SET `active` = '0' WHERE `Application`.`id` = _id;

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_deleteNonActive` (IN `_id` INT)  NO SQL
    SQL SECURITY INVOKER
BEGIN

DELETE FROM

`User` WHERE
`User`.`id` = _id
AND active = '0';

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_deleteUser` (IN `_id` INT)  MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN

UPDATE `User` SET `active` = '0' WHERE `User`.`id` = _id;

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_get` ()  READS SQL DATA
SELECT * FROM Category$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_getAmin` ()  READS SQL DATA
    SQL SECURITY INVOKER
BEGIN

SELECT * FROM `User` WHERE typeID = '1';

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_getApps` ()  NO SQL
BEGIN

SELECT a.* , c.*
FROM Application a , Category c , Appcat ap
WHERE a.id = ap.AppID 
AND c.ID = ap.CatID
AND a.active ='1';


END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_getCategory` ()  READS SQL DATA
    SQL SECURITY INVOKER
BEGIN

SELECT * FROM Category;


END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_getImages` (IN `_appID` INT)  READS SQL DATA
    SQL SECURITY INVOKER
SELECT * FROM AppImage 
WHERE AppID = _appID$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_getNewAppsDesc` ()  READS SQL DATA
    SQL SECURITY INVOKER
BEGIN

SELECT * FROM Application ORDER BY Application.dateUpdated DESC;

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_getNonActiveUsers` ()  NO SQL
BEGIN

SELECT  id,Email, Name,Surname FROM `User` WHERE typeID = '2'
AND active = '0';

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_getOneUser` (IN `_id` INT)  NO SQL
BEGIN

SELECT Name, Surname,Email,Occupation,Company FROM `User`
WHERE id = _id AND
typeID = '2'
AND active = '1';

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_getRating` ()  NO SQL
BEGIN

SELECT `b`.*, (sum(`a`.`Rate`) / count(`a`.`Rate`)) as `ratings` FROM Rating as `a`, Application as `b` WHERE `a`.`AppID` = `b`.`ID`AND `b`.`active` = 1 GROUP BY `a`.`AppID` DESC;

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_getSearch` (IN `_name` VARCHAR(50))  NO SQL
    SQL SECURITY INVOKER
BEGIN

SELECT * FROM `ateam_db`.`Application` WHERE (CONVERT(`name` USING utf8) LIKE _name );

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_getSingleApp` (IN `_id` INT)  NO SQL
BEGIN

SELECT * FROM Application WHERE id = _id;

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_getSingleCat` (IN `category_id` INT)  READS SQL DATA
    SQL SECURITY INVOKER
BEGIN

SELECT a.*, c.*
FROM Application a , Category c , Appcat ap 
WHERE a.id = ap.AppID 
AND c.ID = ap.CatID
AND ap.CatID =category_id
AND a.active = 1;


END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_getUser` ()  READS SQL DATA
    SQL SECURITY INVOKER
BEGIN

SELECT id, Name, Surname,Email,Occupation,Company FROM `User` WHERE typeID = '2'
AND active = '1';

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_login` (IN `_email` VARCHAR(225), IN `_password` VARCHAR(200))  READS SQL DATA
    SQL SECURITY INVOKER
BEGIN

SELECT * FROM User 
WHERE email = _email AND password = _password;

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_nonActive` ()  READS SQL DATA
    SQL SECURITY INVOKER
BEGIN

SELECT COUNT(active) FROM `User` WHERE active = 0 AND typeID = 2;

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_resetPassword` (IN `_salt` VARCHAR(50), IN `_password` VARCHAR(50))  NO SQL
    SQL SECURITY INVOKER
BEGIN

UPDATE `User` SET
`Password` = _password
WHERE `Salt` =_salt;

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_updateApp` (IN `_name` VARCHAR(255), IN `_description` VARCHAR(255), IN `_compatibility` VARCHAR(255), IN `_developer` VARCHAR(255), IN `_catID` INT, IN `_id` INT(225))  MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN


UPDATE `Application` SET `name` = _name, `description` = _description, `compatibility` = _compatibility,`developer` = _developer,  `dateUpdated` = now() WHERE `Application`.`id` = _id;

UPDATE `Appcat` SET `CatID`= _catID WHERE AppID = _id;

END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_updateCategory` (IN `_name` VARCHAR(255), IN `_icon` VARCHAR(255), IN `_id` INT(255))  NO SQL
BEGIN

UPDATE `Category` 
SET `Name` = _name,
	`Icon` = _icon
WHERE `Category`.`ID` = _id;
END$$

CREATE DEFINER=`ateam`@`localhost` PROCEDURE `sp_updateUser` (IN `_name` VARCHAR(50), IN `_surname` VARCHAR(50), IN `_email` VARCHAR(50), IN `_occupation` VARCHAR(50), IN `_company` VARCHAR(50), IN `_id` INT)  MODIFIES SQL DATA
    SQL SECURITY INVOKER
UPDATE User
SET Name = _name,
Surname = _surname,
Email = _email,
Occupation = _occupation,
Company = _company,
active = '1'
WHERE id = _id$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Appcat`
--

CREATE TABLE `Appcat` (
  `AppID` int(11) NOT NULL,
  `CatID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Appcat`
--

INSERT INTO `Appcat` (`AppID`, `CatID`) VALUES
(7, 6),
(8, 4),
(9, 4),
(10, 7),
(11, 7),
(12, 5),
(13, 5),
(14, 5),
(15, 9),
(16, 9),
(17, 3),
(18, 3),
(19, 2),
(20, 1),
(21, 8),
(22, 8),
(23, 8),
(24, 8),
(25, 8),
(26, 1),
(28, 8),
(29, 8),
(30, 4),
(31, 8),
(32, 8),
(33, 1),
(34, 1),
(35, 1),
(36, 4),
(37, 1),
(38, 4),
(39, 8),
(40, 1),
(41, 1),
(42, 1),
(43, 8),
(44, 6),
(45, 8),
(46, 8),
(47, 1),
(48, 1),
(49, 1),
(50, 1),
(51, 1),
(52, 1),
(53, 1),
(54, 5),
(55, 1),
(56, 1),
(57, 1),
(58, 1),
(59, 1),
(60, 1),
(61, 1),
(62, 1),
(63, 1),
(64, 1),
(65, 1),
(66, 8),
(67, 9),
(68, 9),
(69, 9),
(70, 9),
(71, 5),
(72, 4),
(73, 4),
(74, 4),
(75, 3),
(76, 5);

-- --------------------------------------------------------

--
-- Table structure for table `AppImage`
--

CREATE TABLE `AppImage` (
  `ID` int(11) NOT NULL,
  `Image` varchar(500) NOT NULL,
  `AppID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `AppImage`
--

INSERT INTO `AppImage` (`ID`, `Image`, `AppID`) VALUES
(1, '3d-headphones.jpg', 1),
(2, '3d-headphones.jpg', 1),
(3, 'Music-icon.png', 7),
(4, 'Music-icon.png', 7),
(5, 'library-icon-21.png', 8),
(6, 'library-icon-21.png', 8),
(7, '11524405261176826350.png', 9),
(8, '11524405261176826350.png', 9),
(9, 'Hadezign-Hobbies-Movies.ico', 10),
(10, 'Hadezign-Hobbies-Movies.ico', 10),
(11, 'ndygzbetyvyflycjuknw.png', 11),
(12, 'ndygzbetyvyflycjuknw.png', 11),
(13, 'heart-airplane-set-travel-icons-love-to-concept-58420221.jpg', 13),
(14, 'heart-airplane-set-travel-icons-love-to-concept-58420221.jpg', 13),
(15, '1342931.png', 14),
(16, '1342931.png', 14),
(17, 'images.png', 15),
(18, 'images.png', 15),
(19, '15-olympic-sport-icons-2.png', 16),
(20, '15-olympic-sport-icons-2.png', 16),
(21, '512.png', 17),
(22, '512.png', 17),
(23, 'sun.rays.small.cloud.dark.png', 18),
(24, 'sun.rays.small.cloud.dark.png', 18),
(25, 'Games_2.png', 19),
(26, 'Games_2.png', 19),
(27, 'currency-icon.png', 20),
(28, 'currency-icon.png', 20),
(29, 'nelson-msn-buddy-icons-msn-messenger-2.ico', 21),
(30, 'nelson-msn-buddy-icons-msn-messenger-2.ico', 21),
(31, 'facebook_messenger-512.png', 22),
(32, 'facebook_messenger-512.png', 22),
(33, 'facebook_messenger-512.png', 25),
(34, 'bitcoin-currency-icon-9.png', 26),
(35, 'desktop1.png', 28),
(36, 'IM2.png', 28),
(37, 'md_5a9797d574aa7.png', 29),
(38, 'wa.clck-img.src.png', 29),
(39, '764261.jpg', 30),
(40, '764262.jpg', 30),
(41, 'facebook_logos_PNG19751.png', 31),
(42, 'new-instagram-logo-png-transparent.png', 31),
(43, 'facebook_logos_PNG19751.png', 32),
(44, 'Twitter-Download-PNG.png', 32),
(45, 'Games_2.png', 33),
(46, 'Games_2.png', 34),
(47, 'Games_2.png', 35),
(48, 'Screen Shot 2019-03-13 at 11.05.43 AM.png', 36),
(49, 'Screen Shot 2019-03-13 at 11.08.10 AM.png', 36),
(50, 'Screen Shot 2019-03-13 at 11.09.01 AM.png', 36),
(51, 'Screen Shot 2019-03-13 at 11.09.09 AM.png', 36),
(52, 'Games_2.png', 37),
(53, 'images (1).jpeg', 38),
(54, 'images (2).jpeg', 38),
(55, 'images (3).jpeg', 38),
(56, 'images.jpeg', 38),
(57, '5b87dfc56046d970646795.jpeg', 39),
(58, '550629-teamviewer-browser-interface.png', 39),
(59, 'article.jpg', 39),
(60, 'desktop_app_login.png', 39),
(61, 'desktop1.png', 39),
(62, 'DesktopPage_Image64.png', 39),
(63, 'download.jpeg', 39),
(64, 'file-transfer_send-file.jpg', 39),
(65, '5b87dfc56046d970646795.jpeg', 39),
(66, '550629-teamviewer-browser-interface.png', 39),
(67, 'file-transfer_send-file.jpg', 39),
(68, 'hero-devices-en.png', 39),
(69, 'teamviewer-14-638.jpg', 39),
(70, 'teamviewer-login-details.jpeg', 39),
(71, 'Games_2.png', 40),
(72, 'Games_2.png', 41),
(73, 'Games_2.png', 42),
(74, 'image.png', 43),
(75, 'image4-34.png', 43),
(76, 'images (1).jpeg', 43),
(77, 'images (2).jpeg', 43),
(78, 'images (3).jpeg', 43),
(79, 'images (4).jpeg', 43),
(80, 'images (5).jpeg', 43),
(81, 'images.jpeg', 43),
(82, 'kisspng-teamviewer-logo-remote-support-computer-software-t-teamviewer-5b39bf437c7e85.4041979615305111715099.jpg', 43),
(83, 'RoundCube_Login.png', 43),
(84, 'roundcube-png-.png', 43),
(85, 'image.png', 43),
(86, 'image4-34.png', 43),
(87, 'RoundCube_Login.png', 43),
(88, 'beats-logo-hd-image-collections-wallpaper-and-free-download-26633.png', 44),
(89, 'images.jpeg', 44),
(90, 'Microphone-PNG-HD-Quality.png', 44),
(91, 'Teamviewer-13-client.png', 45),
(92, 'teamviewer-14-638.jpg', 45),
(93, '3ZWdFk7p_400x400.jpg', 46),
(94, '550629-teamviewer-browser-interface.png', 46),
(95, '3ZWdFk7p_400x400.jpg', 47),
(96, '3ZWdFk7p_400x400.jpg', 48),
(97, '3ZWdFk7p_400x400.jpg', 49),
(98, '3ZWdFk7p_400x400.jpg', 50),
(99, '3ZWdFk7p_400x400.jpg', 51),
(100, '3ZWdFk7p_400x400.jpg', 52),
(101, '3ZWdFk7p_400x400.jpg', 53),
(102, '509fd4bae28712cef0408220673426e1f1585511.jpeg', 54),
(103, 'electric-motorbikes-main.jpg', 54),
(104, 'motorcycle-3147278__340.jpg', 54),
(105, '3ZWdFk7p_400x400.jpg', 55),
(106, '3ZWdFk7p_400x400.jpg', 56),
(107, '3ZWdFk7p_400x400.jpg', 57),
(108, '3ZWdFk7p_400x400.jpg', 58),
(109, '3ZWdFk7p_400x400.jpg', 59),
(110, '3ZWdFk7p_400x400.jpg', 60),
(111, '3ZWdFk7p_400x400.jpg', 61),
(112, '3ZWdFk7p_400x400.jpg', 62),
(113, '3ZWdFk7p_400x400.jpg', 63),
(114, '3ZWdFk7p_400x400.jpg', 64),
(115, '3ZWdFk7p_400x400.jpg', 65),
(116, '550629-teamviewer-browser-interface.png', 66),
(117, 'desktop1.png', 67),
(118, 'DesktopPage_Image64.png', 68),
(119, 'DesktopPage_Image64.png', 69),
(120, '3ZWdFk7p_400x400.jpg', 70),
(121, 'electric-motorbikes-main.jpg', 71),
(122, 'image-1.jpg', 71),
(123, 'images.jpeg', 71),
(124, 'UTorrent_(logo).png', 72),
(125, '550629-teamviewer-browser-interface.png', 73),
(126, '550629-teamviewer-browser-interface.png', 74),
(127, 'TTK1281-2.png', 75),
(128, 'TTK1281.png', 75),
(129, 'beats-logo-hd-image-collections-wallpaper-and-free-download-26633.png', 76),
(130, 'candy_red_convertible_005.jpg', 76),
(131, 'electric-motorbikes-main.jpg', 76),
(132, 'image-1.jpg', 76);

-- --------------------------------------------------------

--
-- Table structure for table `Application`
--

CREATE TABLE `Application` (
  `id` int(11) NOT NULL,
  `name` varchar(225) NOT NULL,
  `description` longtext NOT NULL,
  `compatibility` varchar(225) NOT NULL,
  `developer` varchar(225) NOT NULL,
  `icon` varchar(500) NOT NULL,
  `apk` varchar(225) NOT NULL,
  `privateKey` varchar(255) NOT NULL,
  `publicKey` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `UserID` int(11) NOT NULL,
  `dateCreated` date NOT NULL,
  `dateUpdated` date NOT NULL,
  `active` int(11) NOT NULL,
  `platform` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Application`
--

INSERT INTO `Application` (`id`, `name`, `description`, `compatibility`, `developer`, `icon`, `apk`, `privateKey`, `publicKey`, `url`, `UserID`, `dateCreated`, `dateUpdated`, `active`, `platform`) VALUES
(1, 'Music World', 'SoundCloud offers a great way to enjoy and discover new music.', 'SoundCloud has millions of tracks.', 'The A Team', '3d-headphones.jpg', '2XL MX Offroad Apk Mod Unlock All.apk', 'private_2cgfc2btpu3vf27843813mvj1w', '0fhjd3y3ncd7hg1341cdamzuk8', 'https://appetize.io/embed/0fhjd3y3ncd7hg1341cdamzuk8', 6, '2019-03-05', '2019-03-05', 1, 'android'),
(7, 'Spotify', 'Spotify is one of the most extensive music streaming services in the world with over 30 million tracks in its library and over 83 million paying users', 'Flexible', 'digital academy', 'Music-icon.png', '', '', '', 'https://www.howtogeek.com/368464/best-free-music-apps-for-android-and-iphone/', 6, '2019-03-06', '2019-03-06', 1, 'web'),
(8, 'Lessonly', 'Lessonly is powerfully simple learning management software that helps teams learn, practice and do better work.', 'sales support teams', 'digital academy', 'library-icon-21.png', '', '', '', 'https://www.howtogeek.com/368464/best-free-music-apps-for-android-and-iphone/', 6, '2019-03-06', '2019-03-06', 1, 'web'),
(9, 'Book Crawler', 'Book Crawler takes book cataloging to new heights with cool features like reviews and local library availability when you scan the barcode', 'Most Powerful Book Database App!', 'The A Team', '11524405261176826350.png', '', '', '', 'https://www.howtogeek.com/368464/best-free-music-apps-for-android-and-iphone/', 6, '2019-03-06', '2019-03-06', 1, 'web'),
(10, 'Showbox', 'Showbox’s large movie library makes it one of the best free movie streaming apps for android. You just need to install the app and you’re good to go.', 'Large library', 'The A Team', 'Hadezign-Hobbies-Movies.ico', '3D Bowling Apk Mod No Ads.apk', 'private_e719885v8q3e7p3zq47zquu3q8', '5jqzbuv3fxe9x73yqtbgerazz0', 'https://appetize.io/embed/5jqzbuv3fxe9x73yqtbgerazz0', 6, '2019-03-06', '2019-03-06', 1, 'android'),
(11, 'CINEMABOX HD', 'Cinemabox HD is a free movie app with loads of high definition movies and TV shows for you to watch', 'Cinemabox HD allows the user to hide adult content', 'The A Team', 'ndygzbetyvyflycjuknw.png', '3D Bowling Apk Mod No Ads.apk', 'private_5cg44p44nxq86u1ek970zej7fg', 'enf39hxq7hvqbgjzdmd953d6hc', 'https://appetize.io/embed/enf39hxq7hvqbgjzdmd953d6hc', 6, '2019-03-06', '2019-03-06', 1, 'android'),
(12, 'TripAdvisor ', 'TripAdvisor gives blunt, often brutal, reviews of accommodation, restaurants and other facilities, without the travel sunny brochures’ perspective', 'flexible', 'The A Team', 'heart-airplane-set-travel-icons-love-to-concept-58420221.jpg', '', '', '', 'https://tourismedition.com/10-travel-apps-ba/', 6, '2019-03-06', '2019-03-06', 1, 'web'),
(13, 'TripAdvisor ', 'TripAdvisor gives blunt, often brutal, reviews of accommodation, restaurants and other facilities, without the travel sunny brochures’ perspective', 'flexible', 'The A Team', 'heart-airplane-set-travel-icons-love-to-concept-58420221.jpg', '', '', '', 'https://tourismedition.com/10-travel-apps-ba/', 6, '2019-03-06', '2019-03-06', 0, 'web'),
(14, 'Jetlag Genie ', 'helps you to adjust your sleep patterns to your long-haul destination before you leave', 'TEDxSanFrancisco talk', 'The A Team', '1342931.png', '3D Bowling Apk Mod No Ads (1).apk', 'private_che77jqvfbju4c6ndb016a94gm', '99hha4dpurvwqcwndvyubmvx1c', 'https://appetize.io/embed/99hha4dpurvwqcwndvyubmvx1c', 6, '2019-03-06', '2019-03-20', 1, 'ios'),
(15, 'TheScore', 'theScore is popular for delivering instant game updates, analysis and scores along with breaking sports news.', 'offer detailed breakdowns for statistic seekers for each play.', 'The A Team', 'images.png', '3D Bowling Apk Mod No Ads (1).apk', 'private_594v2w7mma4rx6v8yve5ep0cfm', 'hb8dzqzvv802emfhw5g2yxydb4', 'https://appetize.io/embed/hb8dzqzvv802emfhw5g2yxydb4', 6, '2019-03-06', '2019-03-18', 1, 'ios'),
(16, 'Fox Sports ', 'Fox Sports GO is for all Fox Sports subscribers who want to take every game with them on the road', 'flexible', 'The A Team', '15-olympic-sport-icons-2.png', '3D Bowling Apk Mod No Ads (1).apk', 'private_f6pgzv6grnucnruyeuaaawudg8', '3gw2k1pdknrnt532m3qmrdfnar', 'https://appetize.io/embed/3gw2k1pdknrnt532m3qmrdfnar', 6, '2019-03-06', '2019-03-06', 0, 'ios'),
(17, 'Weather Timeline  ', 'It’s one of the most beautifully designed weather apps in the Play Store. Whether you just want to get a quick glimpse of the current conditions or a deep dive into the radar and extended forecasts, Weather Timeline has all the tools you need', 'highly customizable', 'The A Team', '512.png', '3D Bowling Apk Mod No Ads (1).apk', 'private_r9cj89ba76ewpdxcyc2hkbzf0c', 'bn0t6keywnfjgcufcpuwnqj5c4', 'https://appetize.io/embed/bn0t6keywnfjgcufcpuwnqj5c4', 6, '2019-03-06', '2019-03-25', 1, 'android'),
(18, 'Dark Sky', 'A paragraph is a series of sentences that are organized and coherent, and are all related to a single topic. Almost every piece of writing you do that is longer than a few sentences should be organized into paragraphs. This is because paragraphs show a reader where the subdivisions of an essay begin and end, and thus help the reader see the organization of the essay and grasp its main points.\r\n\r\nParagraphs can contain many different kinds of information. A paragraph could contain a series of brief examples or a single long illustration of a general point. It might describe a place, character, or process; narrate a series of events; compare or contrast two or more things; classify items into categories; or describe causes and effects. Regardless of the kind of information they contain, all paragraphs share certain characteristics. One of the most important of these is a topic sentence.', 'simple weather solution', 'The A Team', 'sun.rays.small.cloud.dark.png', '3D Bowling Apk Mod No Ads (1).apk', 'private_rm5e768bzhezcuk2a6r9n6hh0r', 'wrhdc6a6yv62t7wk5jfn750jzg', 'https://appetize.io/embed/wrhdc6a6yv62t7wk5jfn750jzg', 6, '2019-03-06', '2019-03-06', 1, 'android'),
(19, 'Noodlecake Studios', 'They have a ton of games. That includes fun puzzlers like Lumino City and FRAMED 1 and 2 along with shooters like Island Delta', 'flexible', 'The A Team', 'Games_2.png', '3D Bowling Apk Mod No Ads (1).apk', 'private_ymeh8w58a8wp9uf7agt1qk1mwg', '5exmauaguj2k6crqu4w61dqv7c', 'https://appetize.io/embed/5exmauaguj2k6crqu4w61dqv7c', 6, '2019-03-06', '2019-03-12', 0, 'android'),
(20, 'XE Currency', 'Convert 180+ currencies on your Android device with the world\'s most downloaded foreign exchange app- XE Currency.', 'FREE and simple currency calculator', 'Rocco', 'currency-icon.png', '3D Bowling Apk Mod No Ads (1).apk', 'private_8mu4emrfwkazuvwmgv874hxn7m', '5vrhm3ammz9f0fpf946wnmbddr', 'https://appetize.io/embed/5vrhm3ammz9f0fpf946wnmbddr', 6, '2019-03-06', '2019-03-22', 0, 'android'),
(21, 'Line', 'Line is a multi-purpose social messaging app that allows users to message, share stickers, play games, make payments, request for taxis, and shop online', 'flexible', 'The A Team', 'nelson-msn-buddy-icons-msn-messenger-2.ico', 'nelson-msn-buddy-icons-msn-messenger-2.ico', 'private_pe6dhd3mxvy39mjv4xv7d9xxj0', 'jvgk1665kfjyru4rxurfbfzjmm', 'https://appetize.io/embed/jvgk1665kfjyru4rxurfbfzjmm', 6, '2019-03-06', '2019-03-06', 1, 'android'),
(22, 'Messenger', 'Users can send messages and exchange photos, videos, stickers, audio, and files, as well as react to other users\' messages and interact with bots', 'flexible', 'The A Team', 'facebook_messenger-512.png', '3D Bowling Apk Mod No Ads (1).apk', 'private_jr327cruk8mq9kckxeccvx1bvg', '4rm924w8qubca2j6g341bpmwn8', 'https://appetize.io/embed/4rm924w8qubca2j6g341bpmwn8', 6, '2019-03-06', '2019-03-06', 0, 'android'),
(23, 'Messenger', 'Users can send messages and exchange photos, videos, stickers, audio, and files, as well as react to other users\' messages and interact with bots', 'flexible', 'The A Team', 'facebook_messenger-512.png', '3D Bowling Apk Mod No Ads (1).apk', 'private_4tffcnvcbe10aupj4q42dexkcr', 'em2twn3mdt7aqc0jy6akj55hdm', 'https://appetize.io/embed/em2twn3mdt7aqc0jy6akj55hdm', 6, '2019-03-06', '2019-03-06', 0, 'android'),
(24, 'Messenger', 'Users can send messages and exchange photos, videos, stickers, audio, and files, as well as react to other users\' messages and interact with bots', 'flexible', 'The A Team', 'facebook_messenger-512.png', '', '', '', 'dfgfygygyegtgftergtftrtfetftf', 6, '2019-03-06', '2019-03-07', 1, 'web'),
(25, 'instagram', 'Users can send messages and exchange photos, videos, stickers, audio, and files, as well as react to other users\' messages and interact with bots', 'flexible', 'The A Team', 'facebook_messenger-512.png', '', '', '', 'dfgfygygyegtgftergtftrtfetftf', 6, '2019-03-06', '2019-03-06', 0, 'web'),
(26, 'Bitcoin', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'Flexible', 'Rocco', 'bitcoin-currency-icon-9.png', '', '', '', 'dfgfygygyegtgftergtftrtfetftf', 6, '2019-03-06', '2019-03-26', 0, 'web'),
(28, 'Bitrix show', 'Bitrix24 is a collaboration platform launched in 2012', 'Flexibility', 'Sergey Rizhikov', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://www.bitrix24.com/', 18, '2019-03-07', '2019-03-07', 1, 'web'),
(29, 'Whatsapp', 'Advanced social media platform', 'Ios', 'Da A-Team', 'whatsapp_PNG21.png', '', '', '', 'www.twitter.com', 18, '2019-03-07', '2019-03-07', 1, 'web'),
(30, 'Presentaion', 'All everything', 'All devices', 'A-Team', '764261.jpg', '', '', '', 'www.google.co.za', 18, '2019-03-07', '2019-03-07', 0, 'web'),
(31, 'Instagram', 'advanced video audio text social', 'Flexible', 'The A-Team', 'Twitter-Download-PNG.png', '', '', '', 'http://www.google.co.za', 18, '2019-03-08', '2019-03-22', 1, 'web'),
(32, 'Presentation 200', 'Showing you update', 'Flexible', 'The A-team', 'new-instagram-logo-png-transparent.png', '', '', '', 'http://www.google.co.za', 18, '2019-03-08', '2019-03-08', 1, 'web'),
(33, 'Zarka', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'The A Team', 'music_512.png', '', '', '', 'dfgfygygyegtgftergtftrtfetftf', 6, '2019-03-11', '2019-03-12', 0, 'web'),
(34, 'Guitar', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'Flexible', 'The A-team', 'music_512.png', '', '', '', 'dfgfygygyegtgftergtftrtfetftf', 6, '2019-03-11', '2019-03-18', 0, 'web'),
(35, 'Musical', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', 'music_512.png', '', '', '', 'dfgfygygyegtgftergtftrtfetftf', 6, '2019-03-11', '2019-03-12', 1, 'web'),
(36, 'Moodle', 'Introducing Moodle Desktop - experience powerful functionality while accessing your Moodle courses on desktop and Surface tablets.', 'Flexibility', 'Martin Dougiamas', 'Screen Shot 2019-03-13 at 11.09.01 AM.png', '', '', '', 'https://moodle.com/desktop-app/', 18, '2019-03-13', '2019-03-13', 1, 'web'),
(37, 'duplicate', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', 'music_512.png', '', '', '', 'dfgfygygyegtgftergtftrtfetftf', 6, '2019-03-13', '2019-03-13', 0, 'web'),
(38, 'uTorrent', 'uTorrent, also known as µTorrent (pronounced \"mu-torrent\") is a free BitTorrent client first released in 2005.', 'Flexible', 'BitTorrent', 'download.jpeg', '', '', '', 'https://www.utorrent.com/', 18, '2019-03-13', '2019-03-13', 1, 'web'),
(39, 'Team Viewer', 'TeamViewer is proprietary software for remote control, desktop sharing, online meetings, web conferencing and file transfer between computers.', 'connect to higher version', 'Tilo Rossmanith', 'kisspng-teamviewer-logo-remote-support-computer-software-t-teamviewer-5b39bf437c7e85.4041979615305111715099.jpg', '', '', '', 'https://www.teamviewer.com/en/', 18, '2019-03-14', '2019-03-25', 0, 'web'),
(40, 'testing', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', 'music_512.png', '3D Bowling Apk Mod No Ads.apk', 'private_uxkvg6rfxype0g55jpjdpuh84r', 'fn7f98xyprgejwj17hjy23dbmg', 'https://appetize.io/embed/fn7f98xyprgejwj17hjy23dbmg', 6, '2019-03-18', '2019-03-18', 0, 'android'),
(41, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', 'music_512.png', '3D Bowling Apk Mod No Ads.apk', 'private_xc15yg9821z7v3y9e46hxkbb4c', 'cumbt9ea40qn6akfb70nkah310', 'https://appetize.io/embed/cumbt9ea40qn6akfb70nkah310', 6, '2019-03-18', '2019-03-18', 0, 'android'),
(42, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', 'music_512.png', '3D Bowling Apk Mod No Ads.apk', 'private_wt71fjc8vrw3kf2r175ec8kqjc', 'wu3fr55ytjqaz03nkxma62az3c', 'https://appetize.io/embed/wu3fr55ytjqaz03nkxma62az3c', 6, '2019-03-18', '2019-03-18', 0, 'android'),
(43, 'Round Cube', 'Roundcube is a web-based IMAP email client. Roundcube\'s most prominent feature is the pervasive use of Ajax technology.', 'Apache, Lighttpd, Cherokee, Hiawatha or Nginx web server', 'The Roundcube Team', 'roundcube-png-.png', '', '', '', 'https://roundcube.net/', 18, '2019-03-20', '2019-03-20', 1, 'web'),
(44, 'R&B music', 'Soulful jams', 'All devices', 'Producer', 'r&b.png', '', '', '', 'https://www.google.com', 18, '2019-03-22', '2019-03-22', 0, 'web'),
(45, 'Team Viewer', 'yglbhj,c', 'hbj,n', 'gyubh', 'teamviewer-logo-big.svg', '', '', '', 'https://www.teamviewer.com', 18, '2019-03-22', '2019-03-22', 0, 'web'),
(46, 'Round Cube Duplicate', 'yglhbj,', 'ghmbn', 'yguhj,b', 'roundcube-png-.png', '', '', '', 'https://roundcube.net/', 18, '2019-03-22', '2019-03-22', 0, 'web'),
(47, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(48, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(49, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(50, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(51, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(52, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(53, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(54, 'Bikers', 'Motor cycles', 'Flexible', 'BikerBoys', 'electric-motorbikes-main.jpg', '', '', '', 'https://www.w3schools.com', 18, '2019-03-22', '2019-03-22', 0, 'web'),
(55, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(56, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(57, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(58, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(59, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(60, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(61, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(62, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(63, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(64, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(65, 'tester', 'Bitcoin is a cryptocurrency, a form of electronic cash', 'flexible', 'a', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://web.whatsapp.com/', 6, '2019-03-22', '2019-03-22', 0, 'web'),
(66, 'Bitrix Duplicate', 'ygukhbj,', 'uhjb,n', 'ukjhb', '3ZWdFk7p_400x400.jpg', '', '', '', 'https://roundcube.net/', 18, '2019-03-22', '2019-03-22', 0, 'web'),
(67, 'Moodley', 'dd', 'd', 'dd', 'DesktopPage_Image64.png', '', '', '', 'dsd', 18, '2019-03-22', '2019-03-25', 0, 'web'),
(68, 'Viber', 'dd', 'd', 'd', 'article.jpg', '', '', '', 'd', 18, '2019-03-22', '2019-03-25', 0, 'web'),
(69, 'm', 'm', 'm', 'm', 'download (1).jpeg', '', '', '', 'm', 18, '2019-03-22', '2019-03-22', 0, 'web'),
(70, 'gerthrjyktlrkejsthgarerhn', 'dfbgehjryehtwgr', 'wert', 'sdfg', '5b87dfc56046d970646795.jpeg', '', '', '', 'https://dzone.com/articles/understanding-output-and-eventemitter-in-angular', 18, '2019-03-22', '2019-03-22', 0, 'web'),
(71, 'Bentley', 'Top gear most expensive cars', 'Flexible', 'Bentley', '2019-bentley-continental-gt-convertible.jpg', '', '', '', 'https://www.binary.com', 18, '2019-03-25', '2019-03-25', 0, 'web'),
(72, 'Visual Studio', 'hbj', 'yuhj,b', ',jghb', 'Visual-Studio-Icon-PNG-Image.png', '', '', '', 'https://www.tutorialsteacher.com/typescript/typescript-array', 18, '2019-03-25', '2019-03-25', 1, 'web'),
(73, 'ygjh', 'ghv b', 'yghbn', '7yuhj', 'article.jpg', '', '', '', 'https://www.tutorialsteacher.com/typescript/typescript-array', 18, '2019-03-25', '2019-03-25', 0, 'web'),
(74, 'yugmh', 'tyfghvb', 'tyfghv', 'tfmhgv', 'article.jpg', '', '', '', 'https://www.tutorialsteacher.com/typescript/typescript-array', 18, '2019-03-25', '2019-03-25', 0, 'web'),
(75, 'Present', 'App working properly', 'All devices', 'A-team', 'TTK1281-2.png', '', '', '', 'http://www.google.co.za', 18, '2019-03-26', '2019-03-26', 0, 'web'),
(76, 'Lambo', 'Spinner', 'Flexible', 'A team', 'image-1.jpg', '', '', '', 'http://www.google.co.za', 18, '2019-03-26', '2019-03-26', 1, 'web');

-- --------------------------------------------------------

--
-- Table structure for table `Category`
--

CREATE TABLE `Category` (
  `ID` int(11) NOT NULL,
  `Name` varchar(50) NOT NULL,
  `Icon` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Category`
--

INSERT INTO `Category` (`ID`, `Name`, `Icon`) VALUES
(1, 'Currency', '164554_folder_512x512.png'),
(2, 'Games', 'indie_game_folder_by_largent2005-d4d2gt4.png'),
(3, 'Weather', 'Hopstarter-Mac-Folders-2-Folder-Cloud.ico'),
(4, 'Learning', 'Applications_Black_Alt.png'),
(5, 'Travel', '0d5c636aa3bee61826bdc727f4a2d446.jpg'),
(6, 'Music', 'music_512.png'),
(7, 'Movies', 'movie-folder-films-spool-d-icon-white-background-33504012.jpg'),
(8, 'Social', 'Chat-Folder-icon.png'),
(9, 'Sports', 'Sports2alt2.png');

-- --------------------------------------------------------

--
-- Table structure for table `Rating`
--

CREATE TABLE `Rating` (
  `ID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `Rate` int(11) NOT NULL,
  `AppID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Rating`
--

INSERT INTO `Rating` (`ID`, `UserID`, `Rate`, `AppID`) VALUES
(5, 6, 1, 7),
(6, 6, 3, 8),
(7, 82, 4, 8),
(8, 82, 3, 20),
(9, 6, 3, 20),
(10, 6, 5, 26),
(11, 6, 5, 36),
(12, 82, 4, 36),
(13, 6, 4, 18);

-- --------------------------------------------------------

--
-- Table structure for table `User`
--

CREATE TABLE `User` (
  `id` int(11) NOT NULL,
  `Name` varchar(50) NOT NULL,
  `Surname` varchar(50) NOT NULL,
  `Email` varchar(50) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `typeID` int(11) NOT NULL,
  `Img` varchar(50) NOT NULL,
  `Occupation` varchar(50) NOT NULL,
  `Company` varchar(100) NOT NULL,
  `active` tinyint(1) NOT NULL,
  `Salt` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `User`
--

INSERT INTO `User` (`id`, `Name`, `Surname`, `Email`, `Password`, `typeID`, `Img`, `Occupation`, `Company`, `active`, `Salt`) VALUES
(6, 'Lethabo', 'Mampana', 'moshidi@gmail.com', '123yey', 2, '27173934_1718729654887496_976708881173834421_o.jpg', 'general manager', 'DA', 0, ''),
(8, 'Elton', 'Setuki', 'moshidi2gmail.com', '1452', 2, 'uyfbdhj.jpg', 'Manager', 'IBM', 0, ''),
(9, 'Moshidi', 'Setuki', 'moshidi@89gmail.com', '1452', 2, 'uyfbdhj.jpg', 'Manager', 'IBM', 0, ''),
(16, 'Moshidi', 'Setuki', 'moshidi2gmail.com', '1452', 2, 'uyfbdhj.jpg', 'Manager', 'IBM', 0, ''),
(17, 'Moshidi', 'Setuki', 'moshidi2gmail.com', '1452', 2, 'uyfbdhj.jpg', 'Manager', 'IBM', 0, ''),
(18, 'Oratile', 'Semelane', 'moshidi2gmail.com', '6790hey', 1, 'hannah-joshua-644247-unsplash.jpg', 'Manager', 'undefined', 1, ''),
(19, 'Oratile', 'Semelane', 'moshidi2gmail.com', '6790hey', 1, 'hannah-joshua-644247-unsplash.jpg', 'Manager', 'undefined', 1, ''),
(20, 'Silverster', 'Smith', 'moshidi2gmail.com', '9090hey', 1, 'alexandru-acea-725744-unsplash.jpg', 'CEO', 'undefined', 1, ''),
(21, 'Leeto', 'leeto@thedigitalacademy.co.za', 'Moroke', '5678siwe', 1, 'samuel-zeller-158996-unsplash.jpg', 'Manager', 'Reserve Bank', 1, ''),
(22, 'Elton', 'Nhlana', 'moshidi2gmail.com', 'elton123', 1, 'malte-wingen-381967-unsplash.jpg', 'Director', 'undefined', 1, ''),
(26, 'Rethabile', 'retha@gmail.com', 'moshidi2gmail.com', '123yey', 1, '27173934_1718729654887496_976708881173834421_o.jpg', 'CEO', 'BCX', 1, ''),
(27, 'John', 'Justin', 'figojoe90@gmail.com', 'jaque7889', 2, 'rawpixel-1055776-unsplash.jpg', 'General Manager', 'Software Hub', 0, ''),
(28, 'Jaque', 'Smith', 'moshidi2gmail.com', 'jaque7889', 2, 'rawpixel-1055776-unsplash.jpg', 'General manager', 'SAXT', 0, ''),
(29, 'Oratile', 'Onthatile', 'onthatile@gmail.com', 'rene7788', 2, 'brian-kostiuk-brikost-252865-unsplash.jpg', 'Manager', 'Coach Tribe\n', 0, ''),
(42, 'Legodi', 'Madisha', 'moshidi2gmail.com', '123yes', 2, '27173934_1718729654887496_976708881173834421_o.jpg', 'Manager', 'MGT', 1, ''),
(44, 'lebohang', 'madisha', 'moshidi2gmail.com', '123yes', 2, '27173934_1718729654887496_976708881173834421_o.jpg', 'manager', 'kpmg', 1, ''),
(47, 'lebohang', 'madisha', 'moshidi2gmail.com', '123yes', 2, '27173934_1718729654887496_976708881173834421_o.jpg', 'manager', 'kpmg', 1, ''),
(54, 'Extension', 'Tlhasereng', 'moshidi@gmail.com', 'ex789', 2, 'EMUI--ICON-PACK-3.jpg', 'Manager', 'IBM', 1, ''),
(56, 'Silvester', 'Monamoreng', 'moshidi2gmail.com', 'silver778', 1, 'malte-wingen-381967-unsplash.jpg', 'Supervisor', 'Pick n Pay', 1, ''),
(57, 'Lebohang', 'madisha', 'moshidi2gmail.com', 'Yzg_7', 2, '', 'J. Dev', 'The Digital Academy', 1, ''),
(58, 'Lerato', 'Mthombeni', 'moshidi2gmail.com', 'ZU0am', 2, '', 'COO', 'WRKS', 1, ''),
(59, 'Sol', 'Goodman', 'moshidi2gmail.com', 'B?))v', 2, '', 'Senior Attorney', 'Goodman Attorneys', 0, ''),
(62, 'omphile', 'Molefe', 'moshidi2gmail.com', 'lebo', 2, '', '', '', 1, ''),
(63, 'Omphile', 'Molefe', 'moshidi@gmail.com', 'lebo', 2, '', 'MD', 'Coca cola', 1, ''),
(64, 'omphile', 'Molefe', 'moshidi2gmail.com', 'hhhhhhhh', 2, '', '', '', 1, ''),
(65, 'Lala', 'Molefe', 'moshidi2gmail.com', 'hhhhhhhhjj', 2, '', '', '', 1, ''),
(66, 'hardy', 'dylut', 'moshidi2gmail.com', '1234567', 1, 'jjj', 'jjj', 'jkjj', 1, ''),
(67, 'malebo', 'thibedi', 'moshidi2gmail.com', 'hhhh', 1, 'hhhhhh', 'developer', 'bcx', 1, ''),
(68, 'omphile', 'Molefe', 'moshidi2gmail.com', '$2b$10$KzjlcFFvpD2MrMlN.WQHk.apgkJo0vSJOLMby/bVeMDnK3Mla4OeW', 2, '', '', '', 1, ''),
(69, 'Ryan', 'Leslie', 'moshidi2gmail.com', '$2b$10$F9c1bs35cDyEvXaZznHr3Oh9Hk2/9Q0hol3b0yY5JB7HzST.U1FBi', 2, '', '', '', 1, ''),
(70, 'Julius', 'Malema', 'moshidi2gmail.com', '$2b$10$t4mvEQilbCqJmNNtKYjQOObATdiHeiYIFPS2GB2qY3V2gUdGoF.Si', 2, '', '', '', 1, ''),
(71, 'Jane', 'Clerck', 'moshidi@gmail.com', '$2b$10$eJWOJfD48iKmIavcBQROLe/BUD7AcD2QHGaH2Si4ffYmSh3Fi7ny2', 2, '', '', '', 1, ''),
(72, 'Testing', 'FInish routing', 'moshidi2gmail.com', '$2b$10$Sg4lufcT24X/Z3P4huOeLuhaJ/jd4EwQNVGThCFORENLLfGgNoO7.', 2, '', '', '', 1, ''),
(74, 'Moshidi', 'Setuki', 'moshidis@thedigitalacademy.co.za', '90876', 2, 'hjndc', 'Assistance', 'Telkom', 1, 'd9c23b1ad0b9cfa3e0e67966fb312ea8'),
(76, 'Bontle', 'Lubbe', 'nhlana.2@gmail.com', '94523122764e7ffa3f2644b10dec302d', 2, '', 'G.M.', 'Westgate', 1, NULL),
(79, 'Jason', 'Senzo', 'extension@thedigitalacademy.co.za', 'd3eb9a9233e52948740d7eb8c3062d14', 2, '', 'G.M.', 'AST', 1, '0d516bef5abe09b4db3f0aa2bd840250'),
(80, 'Moshidi', 'Oratile', 'extension@thedigitalacademy.co.za', 'd3eb9a9233e52948740d7eb8c3062d14', 2, '', '', '', 1, '0d516bef5abe09b4db3f0aa2bd840250'),
(82, 'Kwazi', 'Setuki', 'setukiseta90@gmail.com', '79f091d928bafb7348c14c002ca29316', 2, '', 'Developer', 'RMB', 1, 'af4b483ed20bd415ea12509dce3b82ec'),
(83, 'Johnny', 'Depp', 'johnny@gmail.com', '79bc202f0ebe47f2a387dd8aaddc42d5', 2, '', 'Actor', 'Hoolywood', 1, NULL),
(84, 'Omphile', 'Lesabe', 'omphile@gmail.com', 'f5a7556c713408d23fcb40f57cf3e488', 2, '', 'Player', 'LouiVille', 1, NULL),
(90, 'Patience', 'Madisha', 'lebomadisha@thedigitalacademy.co.za', 'ac0ac7165f1202b4b1f37583ae836c5b', 2, '', 'C. M.', 'Spotify', 1, '616f9947a76d4bdb0c38fd9150155ef3'),
(91, 'Joe ', 'Joa', 'extension@thedigitalacademy.co.za', 'd3eb9a9233e52948740d7eb8c3062d14', 2, '', '', '', 1, '0d516bef5abe09b4db3f0aa2bd840250'),
(92, 'Joe', 'Jack', 'extension@thedigitalacademy.co.za', 'd3eb9a9233e52948740d7eb8c3062d14', 2, '', '', '', 1, '0d516bef5abe09b4db3f0aa2bd840250'),
(98, 'Malebo', 'madisha', 'lebomadis@gmail.com', '0d88b3ca964b8ad7a78959be99c03661', 2, '', '', '', 1, NULL),
(99, 'malebo', 'madisha', 'lebomadisha28@gmail.com', '4f4513ff9b698273d0c2c17f22346d59', 1, '', 'Administrator', 'The A-Team', 1, NULL),
(100, 'Old', 'User', 'extensiontlhareseng@gmail.com', 'c9907dd24324a87e7d2712dbdc62fc1f', 2, '', 'Broker', 'FTXM', 1, NULL),
(101, 'erty', 'cghj', 'gg', '', 1, '', '', '', 1, NULL),
(103, 'name', 'surname', 'email', 'hash', 1, 'img', 'occupation', 'company', 1, NULL),
(104, 'Reneilwe', 'madisha', 'nhlana.2@gmail.com', 'a8d00bf5f268f338867153fb656feb58', 2, '', '', '', 1, NULL),
(105, 'Extee', 'K-mog', 'extensiontlhareseng@gmail.com', 'b8e8234b72873458d38f04244aef0cca', 2, '', 'Director', 'EM Music', 1, NULL),
(106, 'Tomas', 'Mashaba', 'extension@thedigitalacademy.co.za', 'd3eb9a9233e52948740d7eb8c3062d14', 2, '', '', '', 1, '0d516bef5abe09b4db3f0aa2bd840250'),
(108, 'Jimmy', 'Hendricks', 'extension@thedigitalacademy.co.za', 'd3eb9a9233e52948740d7eb8c3062d14', 2, '', '', '', 1, '0d516bef5abe09b4db3f0aa2bd840250'),
(110, 'Jack ', 'Roudy', 'extension@thedigitalacademy.co.za', 'd3eb9a9233e52948740d7eb8c3062d14', 2, '', '', '', 1, '0d516bef5abe09b4db3f0aa2bd840250'),
(111, 'Chris', 'Brown', 'extensiontlhareseng@gmail.com', '6fad46addaa412bd882bbc7a23c72596', 2, '', 'G.M', 'ATXS', 1, NULL),
(112, 'Edit', 'James', 'extensiontlhareseng@gmail.com', '9b19004e0b47f940b7293f59ec32611a', 2, '', 'General Manager', 'ASCT', 1, NULL),
(113, 'Louis', 'Vuiton', 'extensiontlhareseng@gmail.com', '2841ae098ead69946d676ec50cb46195', 2, '', '', '', 1, NULL),
(114, 'Sibahle', 'Mvubu', 'sibahleimvubu@gmail.com', '45247673d27daf38c4becdd9ca3d8b46', 2, '', '', '', 1, NULL),
(115, 'John', 'Doe', 'extensionthareseng@gmail.com', '091aa4011208ee58040ad86e2ee83384', 2, '', '', '', 1, NULL),
(116, 'John', 'Doe', 'extension@thedigitalacademy.co.za', '34d953e9929b2cd0935e6bc6c1c21fb2', 2, '', '', '', 1, NULL),
(117, 'John ', 'Sam', 'extensiontlhareseng@gmail.com', '2c164b2b786f83f2ace14a38c4b971b2', 2, '', '', '', 1, NULL),
(118, 'sam', 'smith', 'extension@thedigitalacademy.co.za', '93682481ab4a7341c3e5bfca7bb8043b', 2, '', '', '', 1, NULL),
(132, 'Sharon', 'Setuki', 'moshidis@thedigitalacademy.co.za', '79f091d928bafb7348c14c002ca29316', 1, 'Slack_Icon.png', 'Developer', 'BBD', 1, NULL),
(133, 'jack', 'smalling', 'extension@gmail.com', 'b55afb0afc5e0250691417198c2a338b', 2, '', '', '', 1, NULL),
(134, 'Sean', 'John', 'john@gmail.com', '0ed6acd6e8346547dad5f05ac5208c7a', 2, '', '', '', 1, NULL),
(135, 'Shane', 'Small', 'shane@gmail.com', '6de95ba0fdaa01dd3d274781590a2549', 2, '', 'GM', 'Mol', 1, NULL),
(136, 'Snowie', 'werty', 'wertyu@gmail.com', '01284544915900d3354b17df8b7b2e0d', 2, '', '', '', 1, NULL),
(137, 'elton', 'John cena', 'nhlana.2@gmail.com', '1626f13902bd7f7f11a529fad48c848c', 2, '', '', '', 1, NULL),
(138, 'mk', 'koko', 'nhlana.@gmail.com', '3ae303de6dfd1955c1e83b729af30384', 2, '', '', '', 0, NULL),
(139, 'l', 'm', 'nhlana.@gmail.com', '6a6bf0f46fd58545754a777fb2b496b8', 2, '', '', '', 0, NULL),
(140, 'd', 'd', 'nhlana.2@gmail.com', '026ed31eb26b492e3b77de38b7b2ffc9', 2, '', '', '', 0, NULL),
(141, 'Thabo', 'Billy', 'gontsegift.setuki@gmail.com', 'bf884c433cd0b3e597ce61953df3b57b', 2, '', '', '', 1, NULL),
(142, 'tg', 's', 'moshidis@gvbn ', 'bd89e54a0ad4617f041e56538337c470', 2, '', '', '', 0, NULL),
(144, 'ghjk', 'sdf', 'swdef@sdfg', '56454e2b7ab36a0238421c8ae04c4b03', 2, '', '', '', 0, NULL),
(145, 'hjk', 'wer', 'we@ertg', '5738cfbe84d412a244e1138df04df3da', 2, '', '', '', 0, NULL),
(146, 'j', 'k', 'h@fg', 'a9fa9e4b650d34dc3c221567455f0c04', 2, '', '', '', 0, NULL),
(147, 'ghjk', 'dfgh', 'ff@gg', '6bb47efcfd72d91315e5c131a7e56249', 2, '', '', '', 0, NULL),
(148, 'girlly', 'dudu', 'd@ss', '92afea0581e14ce00c3afa392077e2c0', 2, '', '', '', 0, NULL),
(149, 'Orapeleng', 'Jones', 'jones@gmail.com', 'd38d9cdde5ee810376701ab339e64356', 2, '', 'Gen Man', 'AXTS', 1, NULL),
(150, 'jh', 'jh', 'jh@fgh', '21e7f71c906c0e95a21e9f45f89f7419', 2, '', '', '', 0, NULL),
(151, 'kh', 'kh', 'khj@gfhjk', '655daeadd422d77d942771b8ee608b24', 2, '', '', '', 0, NULL),
(152, 'bghjkm,', 'bhjk', 'bhnjk@dfghj', '97327a005421608226ac4f0fccd2c3ca', 2, '', '', '', 0, NULL),
(153, 'dd', 'dd', 'dd@dd', '5eefa51612022b9916404d89690ca4c6', 2, '', '', '', 0, NULL),
(154, 'x', 'x', 'x@ed', 'a494e95b309ef93b3eae7fd85a88c574', 2, '', '', '', 0, NULL),
(155, 's', 's', 's@s', '44ce9755fa0d17e0d400279b2efaeb48', 2, '', '', '', 0, NULL),
(156, 'x', 'x', 'x@d', '725b97a011e29a918d3ea6d21d53711b', 2, '', '', '', 0, NULL),
(157, 'd', 'd', 'd@d', '8499507638cc3f65916c2725aee638af', 2, '', '', '', 0, NULL),
(160, 'sss', 'aca', 'ggg@gmail.com', '9f1a22b58adee06e997a55f7fbea8186', 2, '', '', '', 0, NULL),
(161, 'moshidi', 'moshidi', 'moshidi@gmail', '5532cc44ad09481b678d7895724eeb9f', 2, '', '', '', 1, NULL),
(162, 'moshidi', 'moshidi', 'moshidi@gmail', '41314bd65834df28c9990936456402ea', 2, '', '', '', 1, NULL),
(163, 'fghjk', 'ghjkl', 'moshidi@gmail.com', 'e453cb5a9f54ff2a2741e46cdeede9dd', 2, '', '', '', 0, NULL),
(164, 'fghjk', 'hardylutula', 'moshidilutula@gmail.com', '908d605d746b99404f84d6b341a4832b', 2, '', '', '', 0, NULL),
(165, 'fghjk', 'hardylutula', 'r123456lutula@gmail.com', '80d30c97e859e7cc5d40a212d1a1770b', 2, '', '', '', 0, NULL),
(167, 'moshidi', 'moshido', 'moshidi@gmail', '79e12cde91b9a13d0262e007068f8c8a', 2, '', '', '', 1, NULL),
(168, 'moshidi', 'moshidi', 'moshidi@gmail', '5f997b5068589e37a3bb17f1df657763', 2, '', '', '', 1, NULL),
(171, 'Tebogo', 'juju', 'fghjk@dcfghjk.com', '939594c28de7e008170f2f7036b0c8a4', 2, '', '', '', 0, NULL),
(172, 'fghjk', 'fghjkl', 'fghj@dfghj.com', '19eb9f4890dac94cd7b03621a56596b1', 2, '', '', '', 0, NULL),
(174, 'dfghjk', 'fghjkl', 'ghgkjkj@ghjhkjlk.com', '0bf8c34ac5ac92e0b51c8f1ae4002bde', 2, '', '', '', 0, NULL),
(175, 'dfghjk', 'fghjkl', 'ghgkjkj@ghjhkjlk.com', 'cbb729efd3cc9552a142bb3319b5e0f0', 2, '', '', '', 0, NULL),
(176, 'tgyuio', 'fghjk', 'fghjk@gmail.com', '8e5d3d86d9028e735ec46fca2856cf68', 2, '', '', '', 0, NULL),
(177, 'uyh', 'iyh', 'u9oiuyt@fghj.com', '46a281d389dc7acff8e5ca5011856a4c', 2, '', '', '', 0, NULL),
(178, 'uyh', 'iyh', 'u9oiyuuuiuyuuyt@fghj.com', '3a76fa964a28f32b763c86cab91957c6', 2, '', '', '', 0, NULL),
(179, 'rtyui', 'tyui', 'tyuiop@dfghj.com', '9f651bf42ab7749c8fc622be42c963ae', 2, '', '', '', 0, NULL),
(181, 'Elisa', 'Setuki', 'elisa@gmail.com', 'c220e11a625095ae865b9bfae819f4e5', 2, '', '', '', 1, NULL),
(182, 'ex', 'ex', 'exten@gmail.com', '715d4877a8096bc2b4dfde7e70cd7c3d', 2, '', '', '', 0, NULL),
(183, 'tyuiui', 'wert', 'wer@gmail.com', 'd1f20a9b9fd6b3818075ef2af033d713', 2, '', '', '', 0, NULL),
(184, 'yghjb', 'yughjb', 'hbj@gmail.com', '6f32338cbd469b10aa7f0203c04f87f8', 2, '', '', '', 0, NULL),
(185, 'Solomon', 'setuki', 'solomon@gmail.com', '20674e9f28dddae6df1416f3c3126643', 2, '', '', '', 1, NULL),
(186, 'Solomon', 'Kgaswayo', 'solo@gmail.com', '875e7bf9ac28343274c50adb440a7fed', 2, '', '', '', 1, NULL),
(187, 'Eric', 'Bheringer', 'eric@gmail.com', '805e81b3c3ccb8be6247ba02308bc8b1', 2, '', '', '', 1, NULL),
(188, 'sx', 'saxz', 'saz@gmail.com', '3d1fbe261c4bc284278b477bae24ebd2', 2, '', '', '', 0, NULL),
(189, 'Jojo', 'Koko', 'saxz@gmail.com', 'bdd3596c09ff98f0ae181ab870d0c16a', 2, '', '', '', 1, NULL),
(190, 'Kitso', 'Sikwa', 'asxz@gmail.com', '0eace78a97016decb9737eacaa555c44', 2, '', '', '', 1, NULL),
(191, 'Fusion ', 'Juice', 'fusion@sxzjn.com', '426a97ecba44e730a2b6e1dc8adf21c3', 2, '', '', '', 1, NULL),
(192, 'Tau', 'kgaboesele', 'tau@gmail.com', '0163620b4a5bc2f29f9cc5f7eee7a59f', 2, '', '', '', 1, NULL),
(193, 'given', 'Maoto', 'given@gmail.com', '0d0642925c1e50f650acf7e8ec2ff763', 2, '', '', '', 1, NULL),
(194, 'Sasa', 'Kgosi', 'kele@gmail.com', 'e6511d2976193972a2bff4522e23a434', 2, '', '', '', 1, NULL),
(195, 'Sliza', 'Mbirwa', 'sliza@gmail.com', '26f16359422e96b82f81c832d1ef5bc8', 2, '', 'General Manager', 'MSX', 1, NULL),
(196, 'Meme', 'Sese', 'meme@gmail.com', '8ab3282d0ffa670851088ebae6a7b8a0', 2, '', 'Manager', 'BMW', 1, NULL),
(197, 'oooo', 'me', 'testme@gmail.com', '7590640316215efd1c824a3cf34a4a0f', 2, '', '', '', 0, NULL),
(198, 'show', 'me', 'show@gmail.com', '74a3b61771156ad2e4584d038048c36c', 2, '', '', '', 1, NULL),
(199, 'retrt', 'fhjfkg', 'tret@gmail.com', '0a12c1300ea874335e269e9ae5f48e3f', 2, '', '', '', 0, NULL),
(200, 'yoyo', 'Hola', 'ora@gmail.com', '64928374c1ce56c70f8ac90068e8e22a', 2, '', '', '', 0, NULL),
(201, 'leeto', 'leeto', 'leeto@thedigitalacademy.co.za', 'c643758843790d7926a6416522ab4c97', 2, '', '', '', 0, NULL),
(202, 'elton', 'Nhlana', 'elton@gmail.com', '880a52fa35af5ee709dfc60faecce748', 2, '', '', '', 1, NULL),
(204, 'Sitney', 'gogo', 'Sitney@gmail.com', '33747d263f973994cf99076b950204bf', 2, '', '', '', 1, NULL),
(205, 'silver', 'Lemon', 'silver@gmail.com', '24fa9faa96b429fc06d2cfbaeb07c7c6', 2, '', '', '', 1, NULL),
(206, 'Kwazi', 'kubheka', 'kwazikubheka777@gmail.com', '73cb50a5abc0e17e3929209e60e9b8a1', 2, '', '', '', 1, NULL),
(207, 'Cece', 'Tryry', 'cece@gmail.com', '889e22782186c063360047e30e73fe03', 2, '', '', '', 0, NULL),
(208, 'Zuzu', 'Jojo', 'zuzu@gmail.com', '9a1ebc35dff624c51d6bee16947fc3e0', 2, '', '', '', 0, NULL),
(209, 'Lolo', 'senta', 'Lolo@gmail.com', 'b4ba3543c505a661ad996a5f32ddb052', 2, '', '', '', 0, NULL),
(210, 'Kop', 'Sweet', 'kop@gmail.com', 'af31d71cc7ed0ade39bbe26463c24353', 2, '', '', '', 0, NULL),
(211, 'dlton', 'hnlhla', 'nhlana.2@gmail.com', 'fa8c0719752b55adfc0c67f283600606', 2, '', '', '', 0, NULL),
(212, 'asd', 'dff', '99999', '', 1, '', '', '', 0, NULL),
(213, 'Steve', 'Jobs', 'steve@gmail.com', 'f30d909689b57ea8618baa4be89bb48b', 2, '', '', '', 0, NULL),
(214, 'jjj', 'hhhh', 'fffff@ms.com', '13e2c2ef8fcc78686f6d3729f4cf2b26', 2, '', '', '', 0, NULL),
(215, 'ssss', 'ssss', 'sss@ddddd.com', 'b8585cf0fd945f6b8679359273f1ff74', 2, '', '', '', 0, NULL),
(216, 'd', 'k', 'k@gmail.com', 'd2660a9b8fb760034e3c0cbf9835b955', 2, '', '', '', 0, NULL),
(217, 'd', 'kdd', 'k2@gmail.com', '2d645d6f4548e4d7d0a935b7b2732b7d', 2, '', '', '', 0, NULL),
(218, 'dd', 'kk', 'kkk@gmail.com', 'affee665e6cbb7d9ec7e664367e52730', 2, '', '', '', 0, NULL),
(219, 'nana', 'ibiu', 'nana@gmail.com', '856e1f3b3d66df606475c5a2f1e510db', 2, '', '', '', 0, NULL),
(220, 'lebo', 'test', 'lebo@gmail.com', 'ee88044d597742b3d3f603055ea9a4bb', 2, '', '', '', 0, NULL),
(221, 'Oray', 'Tile', 'ora@gmail.com', '767b513cfc3268b209fd87b028ce75b0', 2, '', '', '', 1, NULL),
(222, 'El', 'Ton', 'extension@thedigitalacademy.co.za', 'afd3c347ba5a03fc5267500a46ba9ba0', 2, '', 'MD', 'DA', 1, NULL),
(223, 'Gary', 'B', 'extension@thedigitalacaedemy.co.za', '9d96ac0ebde442b515b95697442fd935', 2, '', '', '', 0, NULL),
(224, 'hh', 'yghj', 'hh@gmail.com', '3d202128a663812d709e7c659a970b63', 2, '', '', '', 0, NULL),
(225, 'Moshidi', 'Sibhm ac', 'Moshidi@gmail.com', '73d0e78632bbe2e652f4f9956451fb4b', 2, '', '', '', 1, NULL),
(226, 'lolo', 'mthembu', 'mthembu@gmail.com', '4b92ba7eed340fc52b61d2b319e7d6a1', 2, '', '', '', 1, NULL),
(227, 'Alicia', 'Keys', 'alicia@gmail.com', '88a40375c0ff2be4d3b3d438ab1cde9b', 2, '', '', '', 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `Usertype`
--

CREATE TABLE `Usertype` (
  `ID` int(11) NOT NULL,
  `Description` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `Usertype`
--

INSERT INTO `Usertype` (`ID`, `Description`) VALUES
(1, 'admin'),
(2, 'user');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Appcat`
--
ALTER TABLE `Appcat`
  ADD KEY `appcat_ibfk_1` (`CatID`),
  ADD KEY `AppID` (`AppID`);

--
-- Indexes for table `AppImage`
--
ALTER TABLE `AppImage`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `AppID` (`AppID`);

--
-- Indexes for table `Application`
--
ALTER TABLE `Application`
  ADD PRIMARY KEY (`id`),
  ADD KEY `UserID` (`UserID`);

--
-- Indexes for table `Category`
--
ALTER TABLE `Category`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `Rating`
--
ALTER TABLE `Rating`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `UserID` (`UserID`),
  ADD KEY `AppID` (`AppID`);

--
-- Indexes for table `User`
--
ALTER TABLE `User`
  ADD PRIMARY KEY (`id`),
  ADD KEY `typeID` (`typeID`);

--
-- Indexes for table `Usertype`
--
ALTER TABLE `Usertype`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `AppImage`
--
ALTER TABLE `AppImage`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- AUTO_INCREMENT for table `Application`
--
ALTER TABLE `Application`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=77;

--
-- AUTO_INCREMENT for table `Category`
--
ALTER TABLE `Category`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `Rating`
--
ALTER TABLE `Rating`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `User`
--
ALTER TABLE `User`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=228;

--
-- AUTO_INCREMENT for table `Usertype`
--
ALTER TABLE `Usertype`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Appcat`
--
ALTER TABLE `Appcat`
  ADD CONSTRAINT `Appcat_ibfk_1` FOREIGN KEY (`AppID`) REFERENCES `Application` (`id`),
  ADD CONSTRAINT `Appcat_ibfk_2` FOREIGN KEY (`CatID`) REFERENCES `Category` (`ID`);

--
-- Constraints for table `AppImage`
--
ALTER TABLE `AppImage`
  ADD CONSTRAINT `AppImage_ibfk_1` FOREIGN KEY (`AppID`) REFERENCES `Application` (`id`);

--
-- Constraints for table `Application`
--
ALTER TABLE `Application`
  ADD CONSTRAINT `Application_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `User` (`id`);

--
-- Constraints for table `Rating`
--
ALTER TABLE `Rating`
  ADD CONSTRAINT `Rating_ibfk_1` FOREIGN KEY (`AppID`) REFERENCES `Application` (`id`);

--
-- Constraints for table `User`
--
ALTER TABLE `User`
  ADD CONSTRAINT `user_ibfk_1` FOREIGN KEY (`typeID`) REFERENCES `Usertype` (`ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

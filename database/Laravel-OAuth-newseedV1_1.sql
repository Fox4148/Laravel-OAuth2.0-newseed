-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : Dim 14 mars 2021 à 17:37
-- Version du serveur :  5.7.31
-- Version de PHP : 7.3.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- Base de données : `OAuth-newseed`
--
CREATE DATABASE IF NOT EXISTS `OAuth-newseed` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `OAuth-newseed`;

DELIMITER $$
--
-- Procédures
--

DROP PROCEDURE IF EXISTS `CreateScopeForUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateScopeForUser` (IN `userId` BIGINT(20) UNSIGNED, IN `scopeName` VARCHAR(255), IN `createdBy` INT)  NO SQL
INSERT INTO `users_scopes`(
    `users_id`, 
    `scopes_id`, 
    `created_by`) 
VALUES (
    userId,
    (SELECT id FROM scopes
    WHERE scopes.name=scopeName),
    createdBy)$$


DROP PROCEDURE IF EXISTS `GetScopesForUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetScopesForUser` (IN `userId` BIGINT(20) UNSIGNED, IN `userName` VARCHAR(255))  NO SQL
SELECT scopes.name 
FROM users
INNER JOIN users_scopes 
on users_scopes.users_id = users.id
INNER JOIN scopes 
ON scopes.id = users_scopes.scopes_id
WHERE users.id = userId
AND users_scopes.active = 1
AND users.name=userName$$

DROP PROCEDURE IF EXISTS `Logout`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Logout` (IN `userId` BIGINT(20), IN `userName` VARCHAR(195))  NO SQL
UPDATE oauth_access_tokens
SET revoked = 1
WHERE oauth_access_tokens.user_id = userId
AND oauth_access_tokens.name=userName$$

DROP PROCEDURE IF EXISTS `NoAuth_AddressCreate`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `NoAuth_AddressCreate` (IN `cpName` VARCHAR(255), IN `fn` VARCHAR(255), IN `add1` VARCHAR(255), IN `add2` VARCHAR(255), IN `pc` VARCHAR(255), IN `city` VARCHAR(255), IN `state` VARCHAR(255), IN `cId` INT)  NO SQL
    DETERMINISTIC
BEGIN
INSERT INTO `address_book`(
    `company_name`, 
    `first_name`, 
    `address1`, 
    `address2`, 
    `postal_code`, 
    `city`, 
    `state`, 
    `countries_id`) 
VALUES (
    cpName,
    fn,
    add1,
    add2,
    pc,
    city,
    state,
    cId);
SELECT LAST_INSERT_ID() as id FROM address_book LIMIT 1;
END$$

DROP PROCEDURE IF EXISTS `ResetUserScopes`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ResetUserScopes` (IN `userId` INT)  NO SQL
UPDATE users_scopes
SET active = 0
WHERE users_scopes.users_id = userId$$

DROP PROCEDURE IF EXISTS `UpdateScopeForCustomer`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateScopeForCustomer` (IN `activeValue` BOOLEAN, IN `customerId` INT, IN `scopeName` VARCHAR(255))  NO SQL
UPDATE customers_scopes
SET active = activeValue
WHERE customers_scopes.users_id = customerId
AND customers_scopes.scopes_id = (
	SELECT id FROM scopes
    WHERE scopes.name = scopeName
)$$

DROP PROCEDURE IF EXISTS `UpdateScopeForUser`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateScopeForUser` (IN `scopeName` VARCHAR(255), IN `activeValue` BOOLEAN, IN `userId` BIGINT(20) UNSIGNED)  NO SQL
UPDATE users_scopes
SET active = activeValue
WHERE users_scopes.users_id = userId
AND users_scopes.scopes_id = (
	SELECT id FROM scopes
    WHERE scopes.name = scopeName
)$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `address_book`
--

DROP TABLE IF EXISTS `address_book`;
CREATE TABLE IF NOT EXISTS `address_book` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_name` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `first_name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address1` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address2` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `postal_code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `city` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `state` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `countries_id` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `countries_id` (`countries_id`)
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `countries`
--

DROP TABLE IF EXISTS `countries`;
CREATE TABLE IF NOT EXISTS `countries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `alpha2Code` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `alpha3Code` char(3) COLLATE utf8mb4_unicode_ci NOT NULL,
  `flag` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cioc` char(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=251 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `countries`
--

INSERT INTO `countries` (`id`, `name`, `alpha2Code`, `alpha3Code`, `flag`, `cioc`) VALUES
(1, 'Afghanistan', 'AF', 'AFG', 'https://restcountries.eu/data/afg.svg', 'AFG'),
(2, 'Åland Islands', 'AX', 'ALA', 'https://restcountries.eu/data/ala.svg', NULL),
(3, 'Albania', 'AL', 'ALB', 'https://restcountries.eu/data/alb.svg', 'ALB'),
(4, 'Algeria', 'DZ', 'DZA', 'https://restcountries.eu/data/dza.svg', 'ALG'),
(5, 'American Samoa', 'AS', 'ASM', 'https://restcountries.eu/data/asm.svg', 'ASA'),
(6, 'Andorra', 'AD', 'AND', 'https://restcountries.eu/data/and.svg', 'AND'),
(7, 'Angola', 'AO', 'AGO', 'https://restcountries.eu/data/ago.svg', 'ANG'),
(8, 'Anguilla', 'AI', 'AIA', 'https://restcountries.eu/data/aia.svg', NULL),
(9, 'Antarctica', 'AQ', 'ATA', 'https://restcountries.eu/data/ata.svg', NULL),
(10, 'Antigua and Barbuda', 'AG', 'ATG', 'https://restcountries.eu/data/atg.svg', 'ANT'),
(11, 'Argentina', 'AR', 'ARG', 'https://restcountries.eu/data/arg.svg', 'ARG'),
(12, 'Armenia', 'AM', 'ARM', 'https://restcountries.eu/data/arm.svg', 'ARM'),
(13, 'Aruba', 'AW', 'ABW', 'https://restcountries.eu/data/abw.svg', 'ARU'),
(14, 'Australia', 'AU', 'AUS', 'https://restcountries.eu/data/aus.svg', 'AUS'),
(15, 'Austria', 'AT', 'AUT', 'https://restcountries.eu/data/aut.svg', 'AUT'),
(16, 'Azerbaijan', 'AZ', 'AZE', 'https://restcountries.eu/data/aze.svg', 'AZE'),
(17, 'Bahamas', 'BS', 'BHS', 'https://restcountries.eu/data/bhs.svg', 'BAH'),
(18, 'Bahrain', 'BH', 'BHR', 'https://restcountries.eu/data/bhr.svg', 'BRN'),
(19, 'Bangladesh', 'BD', 'BGD', 'https://restcountries.eu/data/bgd.svg', 'BAN'),
(20, 'Barbados', 'BB', 'BRB', 'https://restcountries.eu/data/brb.svg', 'BAR'),
(21, 'Belarus', 'BY', 'BLR', 'https://restcountries.eu/data/blr.svg', 'BLR'),
(22, 'Belgium', 'BE', 'BEL', 'https://restcountries.eu/data/bel.svg', 'BEL'),
(23, 'Belize', 'BZ', 'BLZ', 'https://restcountries.eu/data/blz.svg', 'BIZ'),
(24, 'Benin', 'BJ', 'BEN', 'https://restcountries.eu/data/ben.svg', 'BEN'),
(25, 'Bermuda', 'BM', 'BMU', 'https://restcountries.eu/data/bmu.svg', 'BER'),
(26, 'Bhutan', 'BT', 'BTN', 'https://restcountries.eu/data/btn.svg', 'BHU'),
(27, 'Bolivia (Plurinational State of)', 'BO', 'BOL', 'https://restcountries.eu/data/bol.svg', 'BOL'),
(28, 'Bonaire, Sint Eustatius and Saba', 'BQ', 'BES', 'https://restcountries.eu/data/bes.svg', NULL),
(29, 'Bosnia and Herzegovina', 'BA', 'BIH', 'https://restcountries.eu/data/bih.svg', 'BIH'),
(30, 'Botswana', 'BW', 'BWA', 'https://restcountries.eu/data/bwa.svg', 'BOT'),
(31, 'Bouvet Island', 'BV', 'BVT', 'https://restcountries.eu/data/bvt.svg', NULL),
(32, 'Brazil', 'BR', 'BRA', 'https://restcountries.eu/data/bra.svg', 'BRA'),
(33, 'British Indian Ocean Territory', 'IO', 'IOT', 'https://restcountries.eu/data/iot.svg', NULL),
(34, 'United States Minor Outlying Islands', 'UM', 'UMI', 'https://restcountries.eu/data/umi.svg', NULL),
(35, 'Virgin Islands (British)', 'VG', 'VGB', 'https://restcountries.eu/data/vgb.svg', 'IVB'),
(36, 'Virgin Islands (U.S.)', 'VI', 'VIR', 'https://restcountries.eu/data/vir.svg', 'ISV'),
(37, 'Brunei Darussalam', 'BN', 'BRN', 'https://restcountries.eu/data/brn.svg', 'BRU'),
(38, 'Bulgaria', 'BG', 'BGR', 'https://restcountries.eu/data/bgr.svg', 'BUL'),
(39, 'Burkina Faso', 'BF', 'BFA', 'https://restcountries.eu/data/bfa.svg', 'BUR'),
(40, 'Burundi', 'BI', 'BDI', 'https://restcountries.eu/data/bdi.svg', 'BDI'),
(41, 'Cambodia', 'KH', 'KHM', 'https://restcountries.eu/data/khm.svg', 'CAM'),
(42, 'Cameroon', 'CM', 'CMR', 'https://restcountries.eu/data/cmr.svg', 'CMR'),
(43, 'Canada', 'CA', 'CAN', 'https://restcountries.eu/data/can.svg', 'CAN'),
(44, 'Cabo Verde', 'CV', 'CPV', 'https://restcountries.eu/data/cpv.svg', 'CPV'),
(45, 'Cayman Islands', 'KY', 'CYM', 'https://restcountries.eu/data/cym.svg', 'CAY'),
(46, 'Central African Republic', 'CF', 'CAF', 'https://restcountries.eu/data/caf.svg', 'CAF'),
(47, 'Chad', 'TD', 'TCD', 'https://restcountries.eu/data/tcd.svg', 'CHA'),
(48, 'Chile', 'CL', 'CHL', 'https://restcountries.eu/data/chl.svg', 'CHI'),
(49, 'China', 'CN', 'CHN', 'https://restcountries.eu/data/chn.svg', 'CHN'),
(50, 'Christmas Island', 'CX', 'CXR', 'https://restcountries.eu/data/cxr.svg', NULL),
(51, 'Cocos (Keeling) Islands', 'CC', 'CCK', 'https://restcountries.eu/data/cck.svg', NULL),
(52, 'Colombia', 'CO', 'COL', 'https://restcountries.eu/data/col.svg', 'COL'),
(53, 'Comoros', 'KM', 'COM', 'https://restcountries.eu/data/com.svg', 'COM'),
(54, 'Congo', 'CG', 'COG', 'https://restcountries.eu/data/cog.svg', 'CGO'),
(55, 'Congo (Democratic Republic of the)', 'CD', 'COD', 'https://restcountries.eu/data/cod.svg', 'COD'),
(56, 'Cook Islands', 'CK', 'COK', 'https://restcountries.eu/data/cok.svg', 'COK'),
(57, 'Costa Rica', 'CR', 'CRI', 'https://restcountries.eu/data/cri.svg', 'CRC'),
(58, 'Croatia', 'HR', 'HRV', 'https://restcountries.eu/data/hrv.svg', 'CRO'),
(59, 'Cuba', 'CU', 'CUB', 'https://restcountries.eu/data/cub.svg', 'CUB'),
(60, 'Curaçao', 'CW', 'CUW', 'https://restcountries.eu/data/cuw.svg', NULL),
(61, 'Cyprus', 'CY', 'CYP', 'https://restcountries.eu/data/cyp.svg', 'CYP'),
(62, 'Czech Republic', 'CZ', 'CZE', 'https://restcountries.eu/data/cze.svg', 'CZE'),
(63, 'Denmark', 'DK', 'DNK', 'https://restcountries.eu/data/dnk.svg', 'DEN'),
(64, 'Djibouti', 'DJ', 'DJI', 'https://restcountries.eu/data/dji.svg', 'DJI'),
(65, 'Dominica', 'DM', 'DMA', 'https://restcountries.eu/data/dma.svg', 'DMA'),
(66, 'Dominican Republic', 'DO', 'DOM', 'https://restcountries.eu/data/dom.svg', 'DOM'),
(67, 'Ecuador', 'EC', 'ECU', 'https://restcountries.eu/data/ecu.svg', 'ECU'),
(68, 'Egypt', 'EG', 'EGY', 'https://restcountries.eu/data/egy.svg', 'EGY'),
(69, 'El Salvador', 'SV', 'SLV', 'https://restcountries.eu/data/slv.svg', 'ESA'),
(70, 'Equatorial Guinea', 'GQ', 'GNQ', 'https://restcountries.eu/data/gnq.svg', 'GEQ'),
(71, 'Eritrea', 'ER', 'ERI', 'https://restcountries.eu/data/eri.svg', 'ERI'),
(72, 'Estonia', 'EE', 'EST', 'https://restcountries.eu/data/est.svg', 'EST'),
(73, 'Ethiopia', 'ET', 'ETH', 'https://restcountries.eu/data/eth.svg', 'ETH'),
(74, 'Falkland Islands (Malvinas)', 'FK', 'FLK', 'https://restcountries.eu/data/flk.svg', NULL),
(75, 'Faroe Islands', 'FO', 'FRO', 'https://restcountries.eu/data/fro.svg', NULL),
(76, 'Fiji', 'FJ', 'FJI', 'https://restcountries.eu/data/fji.svg', 'FIJ'),
(77, 'Finland', 'FI', 'FIN', 'https://restcountries.eu/data/fin.svg', 'FIN'),
(78, 'France', 'FR', 'FRA', 'https://restcountries.eu/data/fra.svg', 'FRA'),
(79, 'French Guiana', 'GF', 'GUF', 'https://restcountries.eu/data/guf.svg', NULL),
(80, 'French Polynesia', 'PF', 'PYF', 'https://restcountries.eu/data/pyf.svg', NULL),
(81, 'French Southern Territories', 'TF', 'ATF', 'https://restcountries.eu/data/atf.svg', NULL),
(82, 'Gabon', 'GA', 'GAB', 'https://restcountries.eu/data/gab.svg', 'GAB'),
(83, 'Gambia', 'GM', 'GMB', 'https://restcountries.eu/data/gmb.svg', 'GAM'),
(84, 'Georgia', 'GE', 'GEO', 'https://restcountries.eu/data/geo.svg', 'GEO'),
(85, 'Germany', 'DE', 'DEU', 'https://restcountries.eu/data/deu.svg', 'GER'),
(86, 'Ghana', 'GH', 'GHA', 'https://restcountries.eu/data/gha.svg', 'GHA'),
(87, 'Gibraltar', 'GI', 'GIB', 'https://restcountries.eu/data/gib.svg', NULL),
(88, 'Greece', 'GR', 'GRC', 'https://restcountries.eu/data/grc.svg', 'GRE'),
(89, 'Greenland', 'GL', 'GRL', 'https://restcountries.eu/data/grl.svg', NULL),
(90, 'Grenada', 'GD', 'GRD', 'https://restcountries.eu/data/grd.svg', 'GRN'),
(91, 'Guadeloupe', 'GP', 'GLP', 'https://restcountries.eu/data/glp.svg', NULL),
(92, 'Guam', 'GU', 'GUM', 'https://restcountries.eu/data/gum.svg', 'GUM'),
(93, 'Guatemala', 'GT', 'GTM', 'https://restcountries.eu/data/gtm.svg', 'GUA'),
(94, 'Guernsey', 'GG', 'GGY', 'https://restcountries.eu/data/ggy.svg', NULL),
(95, 'Guinea', 'GN', 'GIN', 'https://restcountries.eu/data/gin.svg', 'GUI'),
(96, 'Guinea-Bissau', 'GW', 'GNB', 'https://restcountries.eu/data/gnb.svg', 'GBS'),
(97, 'Guyana', 'GY', 'GUY', 'https://restcountries.eu/data/guy.svg', 'GUY'),
(98, 'Haiti', 'HT', 'HTI', 'https://restcountries.eu/data/hti.svg', 'HAI'),
(99, 'Heard Island and McDonald Islands', 'HM', 'HMD', 'https://restcountries.eu/data/hmd.svg', NULL),
(100, 'Holy See', 'VA', 'VAT', 'https://restcountries.eu/data/vat.svg', NULL),
(101, 'Honduras', 'HN', 'HND', 'https://restcountries.eu/data/hnd.svg', 'HON'),
(102, 'Hong Kong', 'HK', 'HKG', 'https://restcountries.eu/data/hkg.svg', 'HKG'),
(103, 'Hungary', 'HU', 'HUN', 'https://restcountries.eu/data/hun.svg', 'HUN'),
(104, 'Iceland', 'IS', 'ISL', 'https://restcountries.eu/data/isl.svg', 'ISL'),
(105, 'India', 'IN', 'IND', 'https://restcountries.eu/data/ind.svg', 'IND'),
(106, 'Indonesia', 'ID', 'IDN', 'https://restcountries.eu/data/idn.svg', 'INA'),
(107, 'Côte d\'Ivoire', 'CI', 'CIV', 'https://restcountries.eu/data/civ.svg', 'CIV'),
(108, 'Iran (Islamic Republic of)', 'IR', 'IRN', 'https://restcountries.eu/data/irn.svg', 'IRI'),
(109, 'Iraq', 'IQ', 'IRQ', 'https://restcountries.eu/data/irq.svg', 'IRQ'),
(110, 'Ireland', 'IE', 'IRL', 'https://restcountries.eu/data/irl.svg', 'IRL'),
(111, 'Isle of Man', 'IM', 'IMN', 'https://restcountries.eu/data/imn.svg', NULL),
(112, 'Israel', 'IL', 'ISR', 'https://restcountries.eu/data/isr.svg', 'ISR'),
(113, 'Italy', 'IT', 'ITA', 'https://restcountries.eu/data/ita.svg', 'ITA'),
(114, 'Jamaica', 'JM', 'JAM', 'https://restcountries.eu/data/jam.svg', 'JAM'),
(115, 'Japan', 'JP', 'JPN', 'https://restcountries.eu/data/jpn.svg', 'JPN'),
(116, 'Jersey', 'JE', 'JEY', 'https://restcountries.eu/data/jey.svg', NULL),
(117, 'Jordan', 'JO', 'JOR', 'https://restcountries.eu/data/jor.svg', 'JOR'),
(118, 'Kazakhstan', 'KZ', 'KAZ', 'https://restcountries.eu/data/kaz.svg', 'KAZ'),
(119, 'Kenya', 'KE', 'KEN', 'https://restcountries.eu/data/ken.svg', 'KEN'),
(120, 'Kiribati', 'KI', 'KIR', 'https://restcountries.eu/data/kir.svg', 'KIR'),
(121, 'Kuwait', 'KW', 'KWT', 'https://restcountries.eu/data/kwt.svg', 'KUW'),
(122, 'Kyrgyzstan', 'KG', 'KGZ', 'https://restcountries.eu/data/kgz.svg', 'KGZ'),
(123, 'Lao People\'s Democratic Republic', 'LA', 'LAO', 'https://restcountries.eu/data/lao.svg', 'LAO'),
(124, 'Latvia', 'LV', 'LVA', 'https://restcountries.eu/data/lva.svg', 'LAT'),
(125, 'Lebanon', 'LB', 'LBN', 'https://restcountries.eu/data/lbn.svg', 'LIB'),
(126, 'Lesotho', 'LS', 'LSO', 'https://restcountries.eu/data/lso.svg', 'LES'),
(127, 'Liberia', 'LR', 'LBR', 'https://restcountries.eu/data/lbr.svg', 'LBR'),
(128, 'Libya', 'LY', 'LBY', 'https://restcountries.eu/data/lby.svg', 'LBA'),
(129, 'Liechtenstein', 'LI', 'LIE', 'https://restcountries.eu/data/lie.svg', 'LIE'),
(130, 'Lithuania', 'LT', 'LTU', 'https://restcountries.eu/data/ltu.svg', 'LTU'),
(131, 'Luxembourg', 'LU', 'LUX', 'https://restcountries.eu/data/lux.svg', 'LUX'),
(132, 'Macao', 'MO', 'MAC', 'https://restcountries.eu/data/mac.svg', NULL),
(133, 'Macedonia (the former Yugoslav Republic of)', 'MK', 'MKD', 'https://restcountries.eu/data/mkd.svg', 'MKD'),
(134, 'Madagascar', 'MG', 'MDG', 'https://restcountries.eu/data/mdg.svg', 'MAD'),
(135, 'Malawi', 'MW', 'MWI', 'https://restcountries.eu/data/mwi.svg', 'MAW'),
(136, 'Malaysia', 'MY', 'MYS', 'https://restcountries.eu/data/mys.svg', 'MAS'),
(137, 'Maldives', 'MV', 'MDV', 'https://restcountries.eu/data/mdv.svg', 'MDV'),
(138, 'Mali', 'ML', 'MLI', 'https://restcountries.eu/data/mli.svg', 'MLI'),
(139, 'Malta', 'MT', 'MLT', 'https://restcountries.eu/data/mlt.svg', 'MLT'),
(140, 'Marshall Islands', 'MH', 'MHL', 'https://restcountries.eu/data/mhl.svg', 'MHL'),
(141, 'Martinique', 'MQ', 'MTQ', 'https://restcountries.eu/data/mtq.svg', NULL),
(142, 'Mauritania', 'MR', 'MRT', 'https://restcountries.eu/data/mrt.svg', 'MTN'),
(143, 'Mauritius', 'MU', 'MUS', 'https://restcountries.eu/data/mus.svg', 'MRI'),
(144, 'Mayotte', 'YT', 'MYT', 'https://restcountries.eu/data/myt.svg', NULL),
(145, 'Mexico', 'MX', 'MEX', 'https://restcountries.eu/data/mex.svg', 'MEX'),
(146, 'Micronesia (Federated States of)', 'FM', 'FSM', 'https://restcountries.eu/data/fsm.svg', 'FSM'),
(147, 'Moldova (Republic of)', 'MD', 'MDA', 'https://restcountries.eu/data/mda.svg', 'MDA'),
(148, 'Monaco', 'MC', 'MCO', 'https://restcountries.eu/data/mco.svg', 'MON'),
(149, 'Mongolia', 'MN', 'MNG', 'https://restcountries.eu/data/mng.svg', 'MGL'),
(150, 'Montenegro', 'ME', 'MNE', 'https://restcountries.eu/data/mne.svg', 'MNE'),
(151, 'Montserrat', 'MS', 'MSR', 'https://restcountries.eu/data/msr.svg', NULL),
(152, 'Morocco', 'MA', 'MAR', 'https://restcountries.eu/data/mar.svg', 'MAR'),
(153, 'Mozambique', 'MZ', 'MOZ', 'https://restcountries.eu/data/moz.svg', 'MOZ'),
(154, 'Myanmar', 'MM', 'MMR', 'https://restcountries.eu/data/mmr.svg', 'MYA'),
(155, 'Namibia', 'NA', 'NAM', 'https://restcountries.eu/data/nam.svg', 'NAM'),
(156, 'Nauru', 'NR', 'NRU', 'https://restcountries.eu/data/nru.svg', 'NRU'),
(157, 'Nepal', 'NP', 'NPL', 'https://restcountries.eu/data/npl.svg', 'NEP'),
(158, 'Netherlands', 'NL', 'NLD', 'https://restcountries.eu/data/nld.svg', 'NED'),
(159, 'New Caledonia', 'NC', 'NCL', 'https://restcountries.eu/data/ncl.svg', NULL),
(160, 'New Zealand', 'NZ', 'NZL', 'https://restcountries.eu/data/nzl.svg', 'NZL'),
(161, 'Nicaragua', 'NI', 'NIC', 'https://restcountries.eu/data/nic.svg', 'NCA'),
(162, 'Niger', 'NE', 'NER', 'https://restcountries.eu/data/ner.svg', 'NIG'),
(163, 'Nigeria', 'NG', 'NGA', 'https://restcountries.eu/data/nga.svg', 'NGR'),
(164, 'Niue', 'NU', 'NIU', 'https://restcountries.eu/data/niu.svg', NULL),
(165, 'Norfolk Island', 'NF', 'NFK', 'https://restcountries.eu/data/nfk.svg', NULL),
(166, 'Korea (Democratic People\'s Republic of)', 'KP', 'PRK', 'https://restcountries.eu/data/prk.svg', 'PRK'),
(167, 'Northern Mariana Islands', 'MP', 'MNP', 'https://restcountries.eu/data/mnp.svg', NULL),
(168, 'Norway', 'NO', 'NOR', 'https://restcountries.eu/data/nor.svg', 'NOR'),
(169, 'Oman', 'OM', 'OMN', 'https://restcountries.eu/data/omn.svg', 'OMA'),
(170, 'Pakistan', 'PK', 'PAK', 'https://restcountries.eu/data/pak.svg', 'PAK'),
(171, 'Palau', 'PW', 'PLW', 'https://restcountries.eu/data/plw.svg', 'PLW'),
(172, 'Palestine, State of', 'PS', 'PSE', 'https://restcountries.eu/data/pse.svg', 'PLE'),
(173, 'Panama', 'PA', 'PAN', 'https://restcountries.eu/data/pan.svg', 'PAN'),
(174, 'Papua New Guinea', 'PG', 'PNG', 'https://restcountries.eu/data/png.svg', 'PNG'),
(175, 'Paraguay', 'PY', 'PRY', 'https://restcountries.eu/data/pry.svg', 'PAR'),
(176, 'Peru', 'PE', 'PER', 'https://restcountries.eu/data/per.svg', 'PER'),
(177, 'Philippines', 'PH', 'PHL', 'https://restcountries.eu/data/phl.svg', 'PHI'),
(178, 'Pitcairn', 'PN', 'PCN', 'https://restcountries.eu/data/pcn.svg', NULL),
(179, 'Poland', 'PL', 'POL', 'https://restcountries.eu/data/pol.svg', 'POL'),
(180, 'Portugal', 'PT', 'PRT', 'https://restcountries.eu/data/prt.svg', 'POR'),
(181, 'Puerto Rico', 'PR', 'PRI', 'https://restcountries.eu/data/pri.svg', 'PUR'),
(182, 'Qatar', 'QA', 'QAT', 'https://restcountries.eu/data/qat.svg', 'QAT'),
(183, 'Republic of Kosovo', 'XK', 'KOS', 'https://restcountries.eu/data/kos.svg', NULL),
(184, 'Réunion', 'RE', 'REU', 'https://restcountries.eu/data/reu.svg', NULL),
(185, 'Romania', 'RO', 'ROU', 'https://restcountries.eu/data/rou.svg', 'ROU'),
(186, 'Russian Federation', 'RU', 'RUS', 'https://restcountries.eu/data/rus.svg', 'RUS'),
(187, 'Rwanda', 'RW', 'RWA', 'https://restcountries.eu/data/rwa.svg', 'RWA'),
(188, 'Saint Barthélemy', 'BL', 'BLM', 'https://restcountries.eu/data/blm.svg', NULL),
(189, 'Saint Helena, Ascension and Tristan da Cunha', 'SH', 'SHN', 'https://restcountries.eu/data/shn.svg', NULL),
(190, 'Saint Kitts and Nevis', 'KN', 'KNA', 'https://restcountries.eu/data/kna.svg', 'SKN'),
(191, 'Saint Lucia', 'LC', 'LCA', 'https://restcountries.eu/data/lca.svg', 'LCA'),
(192, 'Saint Martin (French part)', 'MF', 'MAF', 'https://restcountries.eu/data/maf.svg', NULL),
(193, 'Saint Pierre and Miquelon', 'PM', 'SPM', 'https://restcountries.eu/data/spm.svg', NULL),
(194, 'Saint Vincent and the Grenadines', 'VC', 'VCT', 'https://restcountries.eu/data/vct.svg', 'VIN'),
(195, 'Samoa', 'WS', 'WSM', 'https://restcountries.eu/data/wsm.svg', 'SAM'),
(196, 'San Marino', 'SM', 'SMR', 'https://restcountries.eu/data/smr.svg', 'SMR'),
(197, 'Sao Tome and Principe', 'ST', 'STP', 'https://restcountries.eu/data/stp.svg', 'STP'),
(198, 'Saudi Arabia', 'SA', 'SAU', 'https://restcountries.eu/data/sau.svg', 'KSA'),
(199, 'Senegal', 'SN', 'SEN', 'https://restcountries.eu/data/sen.svg', 'SEN'),
(200, 'Serbia', 'RS', 'SRB', 'https://restcountries.eu/data/srb.svg', 'SRB'),
(201, 'Seychelles', 'SC', 'SYC', 'https://restcountries.eu/data/syc.svg', 'SEY'),
(202, 'Sierra Leone', 'SL', 'SLE', 'https://restcountries.eu/data/sle.svg', 'SLE'),
(203, 'Singapore', 'SG', 'SGP', 'https://restcountries.eu/data/sgp.svg', 'SIN'),
(204, 'Sint Maarten (Dutch part)', 'SX', 'SXM', 'https://restcountries.eu/data/sxm.svg', NULL),
(205, 'Slovakia', 'SK', 'SVK', 'https://restcountries.eu/data/svk.svg', 'SVK'),
(206, 'Slovenia', 'SI', 'SVN', 'https://restcountries.eu/data/svn.svg', 'SLO'),
(207, 'Solomon Islands', 'SB', 'SLB', 'https://restcountries.eu/data/slb.svg', 'SOL'),
(208, 'Somalia', 'SO', 'SOM', 'https://restcountries.eu/data/som.svg', 'SOM'),
(209, 'South Africa', 'ZA', 'ZAF', 'https://restcountries.eu/data/zaf.svg', 'RSA'),
(210, 'South Georgia and the South Sandwich Islands', 'GS', 'SGS', 'https://restcountries.eu/data/sgs.svg', NULL),
(211, 'Korea (Republic of)', 'KR', 'KOR', 'https://restcountries.eu/data/kor.svg', 'KOR'),
(212, 'South Sudan', 'SS', 'SSD', 'https://restcountries.eu/data/ssd.svg', NULL),
(213, 'Spain', 'ES', 'ESP', 'https://restcountries.eu/data/esp.svg', 'ESP'),
(214, 'Sri Lanka', 'LK', 'LKA', 'https://restcountries.eu/data/lka.svg', 'SRI'),
(215, 'Sudan', 'SD', 'SDN', 'https://restcountries.eu/data/sdn.svg', 'SUD'),
(216, 'Suriname', 'SR', 'SUR', 'https://restcountries.eu/data/sur.svg', 'SUR'),
(217, 'Svalbard and Jan Mayen', 'SJ', 'SJM', 'https://restcountries.eu/data/sjm.svg', NULL),
(218, 'Swaziland', 'SZ', 'SWZ', 'https://restcountries.eu/data/swz.svg', 'SWZ'),
(219, 'Sweden', 'SE', 'SWE', 'https://restcountries.eu/data/swe.svg', 'SWE'),
(220, 'Switzerland', 'CH', 'CHE', 'https://restcountries.eu/data/che.svg', 'SUI'),
(221, 'Syrian Arab Republic', 'SY', 'SYR', 'https://restcountries.eu/data/syr.svg', 'SYR'),
(222, 'Taiwan', 'TW', 'TWN', 'https://restcountries.eu/data/twn.svg', 'TPE'),
(223, 'Tajikistan', 'TJ', 'TJK', 'https://restcountries.eu/data/tjk.svg', 'TJK'),
(224, 'Tanzania, United Republic of', 'TZ', 'TZA', 'https://restcountries.eu/data/tza.svg', 'TAN'),
(225, 'Thailand', 'TH', 'THA', 'https://restcountries.eu/data/tha.svg', 'THA'),
(226, 'Timor-Leste', 'TL', 'TLS', 'https://restcountries.eu/data/tls.svg', 'TLS'),
(227, 'Togo', 'TG', 'TGO', 'https://restcountries.eu/data/tgo.svg', 'TOG'),
(228, 'Tokelau', 'TK', 'TKL', 'https://restcountries.eu/data/tkl.svg', NULL),
(229, 'Tonga', 'TO', 'TON', 'https://restcountries.eu/data/ton.svg', 'TGA'),
(230, 'Trinidad and Tobago', 'TT', 'TTO', 'https://restcountries.eu/data/tto.svg', 'TTO'),
(231, 'Tunisia', 'TN', 'TUN', 'https://restcountries.eu/data/tun.svg', 'TUN'),
(232, 'Turkey', 'TR', 'TUR', 'https://restcountries.eu/data/tur.svg', 'TUR'),
(233, 'Turkmenistan', 'TM', 'TKM', 'https://restcountries.eu/data/tkm.svg', 'TKM'),
(234, 'Turks and Caicos Islands', 'TC', 'TCA', 'https://restcountries.eu/data/tca.svg', NULL),
(235, 'Tuvalu', 'TV', 'TUV', 'https://restcountries.eu/data/tuv.svg', 'TUV'),
(236, 'Uganda', 'UG', 'UGA', 'https://restcountries.eu/data/uga.svg', 'UGA'),
(237, 'Ukraine', 'UA', 'UKR', 'https://restcountries.eu/data/ukr.svg', 'UKR'),
(238, 'United Arab Emirates', 'AE', 'ARE', 'https://restcountries.eu/data/are.svg', 'UAE'),
(239, 'United Kingdom of Great Britain and Northern Ireland', 'GB', 'GBR', 'https://restcountries.eu/data/gbr.svg', 'GBR'),
(240, 'United States of America', 'US', 'USA', 'https://restcountries.eu/data/usa.svg', 'USA'),
(241, 'Uruguay', 'UY', 'URY', 'https://restcountries.eu/data/ury.svg', 'URU'),
(242, 'Uzbekistan', 'UZ', 'UZB', 'https://restcountries.eu/data/uzb.svg', 'UZB'),
(243, 'Vanuatu', 'VU', 'VUT', 'https://restcountries.eu/data/vut.svg', 'VAN'),
(244, 'Venezuela (Bolivarian Republic of)', 'VE', 'VEN', 'https://restcountries.eu/data/ven.svg', 'VEN'),
(245, 'Viet Nam', 'VN', 'VNM', 'https://restcountries.eu/data/vnm.svg', 'VIE'),
(246, 'Wallis and Futuna', 'WF', 'WLF', 'https://restcountries.eu/data/wlf.svg', NULL),
(247, 'Western Sahara', 'EH', 'ESH', 'https://restcountries.eu/data/esh.svg', NULL),
(248, 'Yemen', 'YE', 'YEM', 'https://restcountries.eu/data/yem.svg', 'YEM'),
(249, 'Zambia', 'ZM', 'ZMB', 'https://restcountries.eu/data/zmb.svg', 'ZAM'),
(250, 'Zimbabwe', 'ZW', 'ZWE', 'https://restcountries.eu/data/zwe.svg', 'ZIM');

-- --------------------------------------------------------

--
-- Structure de la table `languages`
--

DROP TABLE IF EXISTS `languages`;
CREATE TABLE IF NOT EXISTS `languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `alpha2` char(2) COLLATE utf8mb4_bin NOT NULL,
  `alpha3b` char(3) COLLATE utf8mb4_bin NOT NULL,
  `image` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL,
  `directory` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL,
  `sort_order` int(3) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=185 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

--
-- Déchargement des données de la table `languages`
--

INSERT INTO `languages` (`id`, `name`, `alpha2`, `alpha3b`, `image`, `directory`, `sort_order`) VALUES
(1, 'Afar', 'aa', 'aar', NULL, NULL, NULL),
(2, 'Abkhazian', 'ab', 'abk', NULL, NULL, NULL),
(3, 'Afrikaans', 'af', 'afr', NULL, NULL, NULL),
(4, 'Akan', 'ak', 'aka', NULL, NULL, NULL),
(5, 'Albanian', 'sq', 'alb', NULL, NULL, NULL),
(6, 'Amharic', 'am', 'amh', NULL, NULL, NULL),
(7, 'Arabic', 'ar', 'ara', NULL, NULL, NULL),
(8, 'Aragonese', 'an', 'arg', NULL, NULL, NULL),
(9, 'Armenian', 'hy', 'arm', NULL, NULL, NULL),
(10, 'Assamese', 'as', 'asm', NULL, NULL, NULL),
(11, 'Avaric', 'av', 'ava', NULL, NULL, NULL),
(12, 'Avestan', 'ae', 'ave', NULL, NULL, NULL),
(13, 'Aymara', 'ay', 'aym', NULL, NULL, NULL),
(14, 'Azerbaijani', 'az', 'aze', NULL, NULL, NULL),
(15, 'Bashkir', 'ba', 'bak', NULL, NULL, NULL),
(16, 'Bambara', 'bm', 'bam', NULL, NULL, NULL),
(17, 'Basque', 'eu', 'baq', NULL, NULL, NULL),
(18, 'Belarusian', 'be', 'bel', NULL, NULL, NULL),
(19, 'Bengali', 'bn', 'ben', NULL, NULL, NULL),
(20, 'Bihari languages', 'bh', 'bih', NULL, NULL, NULL),
(21, 'Bislama', 'bi', 'bis', NULL, NULL, NULL),
(22, 'Bosnian', 'bs', 'bos', NULL, NULL, NULL),
(23, 'Breton', 'br', 'bre', NULL, NULL, NULL),
(24, 'Bulgarian', 'bg', 'bul', NULL, NULL, NULL),
(25, 'Burmese', 'my', 'bur', NULL, NULL, NULL),
(26, 'Catalan; Valencian', 'ca', 'cat', NULL, NULL, NULL),
(27, 'Chamorro', 'ch', 'cha', NULL, NULL, NULL),
(28, 'Chechen', 'ce', 'che', NULL, NULL, NULL),
(29, 'Chinese', 'zh', 'chi', NULL, NULL, NULL),
(30, 'Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic', 'cu', 'chu', NULL, NULL, NULL),
(31, 'Chuvash', 'cv', 'chv', NULL, NULL, NULL),
(32, 'Cornish', 'kw', 'cor', NULL, NULL, NULL),
(33, 'Corsican', 'co', 'cos', NULL, NULL, NULL),
(34, 'Cree', 'cr', 'cre', NULL, NULL, NULL),
(35, 'Czech', 'cs', 'cze', NULL, NULL, NULL),
(36, 'Danish', 'da', 'dan', NULL, NULL, NULL),
(37, 'Divehi; Dhivehi; Maldivian', 'dv', 'div', NULL, NULL, NULL),
(38, 'Dutch; Flemish', 'nl', 'dut', NULL, NULL, NULL),
(39, 'Dzongkha', 'dz', 'dzo', NULL, NULL, NULL),
(40, 'English', 'en', 'eng', NULL, NULL, NULL),
(41, 'Esperanto', 'eo', 'epo', NULL, NULL, NULL),
(42, 'Estonian', 'et', 'est', NULL, NULL, NULL),
(43, 'Ewe', 'ee', 'ewe', NULL, NULL, NULL),
(44, 'Faroese', 'fo', 'fao', NULL, NULL, NULL),
(45, 'Fijian', 'fj', 'fij', NULL, NULL, NULL),
(46, 'Finnish', 'fi', 'fin', NULL, NULL, NULL),
(47, 'French', 'fr', 'fre', NULL, NULL, NULL),
(48, 'Western Frisian', 'fy', 'fry', NULL, NULL, NULL),
(49, 'Fulah', 'ff', 'ful', NULL, NULL, NULL),
(50, 'Georgian', 'ka', 'geo', NULL, NULL, NULL),
(51, 'German', 'de', 'ger', NULL, NULL, NULL),
(52, 'Gaelic; Scottish Gaelic', 'gd', 'gla', NULL, NULL, NULL),
(53, 'Irish', 'ga', 'gle', NULL, NULL, NULL),
(54, 'Galician', 'gl', 'glg', NULL, NULL, NULL),
(55, 'Manx', 'gv', 'glv', NULL, NULL, NULL),
(56, 'Greek, Modern (1453-)', 'el', 'gre', NULL, NULL, NULL),
(57, 'Guarani', 'gn', 'grn', NULL, NULL, NULL),
(58, 'Gujarati', 'gu', 'guj', NULL, NULL, NULL),
(59, 'Haitian; Haitian Creole', 'ht', 'hat', NULL, NULL, NULL),
(60, 'Hausa', 'ha', 'hau', NULL, NULL, NULL),
(61, 'Hebrew', 'he', 'heb', NULL, NULL, NULL),
(62, 'Herero', 'hz', 'her', NULL, NULL, NULL),
(63, 'Hindi', 'hi', 'hin', NULL, NULL, NULL),
(64, 'Hiri Motu', 'ho', 'hmo', NULL, NULL, NULL),
(65, 'Croatian', 'hr', 'hrv', NULL, NULL, NULL),
(66, 'Hungarian', 'hu', 'hun', NULL, NULL, NULL),
(67, 'Igbo', 'ig', 'ibo', NULL, NULL, NULL),
(68, 'Icelandic', 'is', 'ice', NULL, NULL, NULL),
(69, 'Ido', 'io', 'ido', NULL, NULL, NULL),
(70, 'Sichuan Yi; Nuosu', 'ii', 'iii', NULL, NULL, NULL),
(71, 'Inuktitut', 'iu', 'iku', NULL, NULL, NULL),
(72, 'Interlingue; Occidental', 'ie', 'ile', NULL, NULL, NULL),
(73, 'Interlingua (International Auxiliary Language Association)', 'ia', 'ina', NULL, NULL, NULL),
(74, 'Indonesian', 'id', 'ind', NULL, NULL, NULL),
(75, 'Inupiaq', 'ik', 'ipk', NULL, NULL, NULL),
(76, 'Italian', 'it', 'ita', NULL, NULL, NULL),
(77, 'Javanese', 'jv', 'jav', NULL, NULL, NULL),
(78, 'Japanese', 'ja', 'jpn', NULL, NULL, NULL),
(79, 'Kalaallisut; Greenlandic', 'kl', 'kal', NULL, NULL, NULL),
(80, 'Kannada', 'kn', 'kan', NULL, NULL, NULL),
(81, 'Kashmiri', 'ks', 'kas', NULL, NULL, NULL),
(82, 'Kanuri', 'kr', 'kau', NULL, NULL, NULL),
(83, 'Kazakh', 'kk', 'kaz', NULL, NULL, NULL),
(84, 'Central Khmer', 'km', 'khm', NULL, NULL, NULL),
(85, 'Kikuyu; Gikuyu', 'ki', 'kik', NULL, NULL, NULL),
(86, 'Kinyarwanda', 'rw', 'kin', NULL, NULL, NULL),
(87, 'Kirghiz; Kyrgyz', 'ky', 'kir', NULL, NULL, NULL),
(88, 'Komi', 'kv', 'kom', NULL, NULL, NULL),
(89, 'Kongo', 'kg', 'kon', NULL, NULL, NULL),
(90, 'Korean', 'ko', 'kor', NULL, NULL, NULL),
(91, 'Kuanyama; Kwanyama', 'kj', 'kua', NULL, NULL, NULL),
(92, 'Kurdish', 'ku', 'kur', NULL, NULL, NULL),
(93, 'Lao', 'lo', 'lao', NULL, NULL, NULL),
(94, 'Latin', 'la', 'lat', NULL, NULL, NULL),
(95, 'Latvian', 'lv', 'lav', NULL, NULL, NULL),
(96, 'Limburgan; Limburger; Limburgish', 'li', 'lim', NULL, NULL, NULL),
(97, 'Lingala', 'ln', 'lin', NULL, NULL, NULL),
(98, 'Lithuanian', 'lt', 'lit', NULL, NULL, NULL),
(99, 'Luxembourgish; Letzeburgesch', 'lb', 'ltz', NULL, NULL, NULL),
(100, 'Luba-Katanga', 'lu', 'lub', NULL, NULL, NULL),
(101, 'Ganda', 'lg', 'lug', NULL, NULL, NULL),
(102, 'Macedonian', 'mk', 'mac', NULL, NULL, NULL),
(103, 'Marshallese', 'mh', 'mah', NULL, NULL, NULL),
(104, 'Malayalam', 'ml', 'mal', NULL, NULL, NULL),
(105, 'Maori', 'mi', 'mao', NULL, NULL, NULL),
(106, 'Marathi', 'mr', 'mar', NULL, NULL, NULL),
(107, 'Malay', 'ms', 'may', NULL, NULL, NULL),
(108, 'Malagasy', 'mg', 'mlg', NULL, NULL, NULL),
(109, 'Maltese', 'mt', 'mlt', NULL, NULL, NULL),
(110, 'Mongolian', 'mn', 'mon', NULL, NULL, NULL),
(111, 'Nauru', 'na', 'nau', NULL, NULL, NULL),
(112, 'Navajo; Navaho', 'nv', 'nav', NULL, NULL, NULL),
(113, 'Ndebele, South; South Ndebele', 'nr', 'nbl', NULL, NULL, NULL),
(114, 'Ndebele, North; North Ndebele', 'nd', 'nde', NULL, NULL, NULL),
(115, 'Ndonga', 'ng', 'ndo', NULL, NULL, NULL),
(116, 'Nepali', 'ne', 'nep', NULL, NULL, NULL),
(117, 'Norwegian Nynorsk; Nynorsk, Norwegian', 'nn', 'nno', NULL, NULL, NULL),
(118, 'Bokmål, Norwegian; Norwegian Bokmål', 'nb', 'nob', NULL, NULL, NULL),
(119, 'Norwegian', 'no', 'nor', NULL, NULL, NULL),
(120, 'Chichewa; Chewa; Nyanja', 'ny', 'nya', NULL, NULL, NULL),
(121, 'Occitan (post 1500)', 'oc', 'oci', NULL, NULL, NULL),
(122, 'Ojibwa', 'oj', 'oji', NULL, NULL, NULL),
(123, 'Oriya', 'or', 'ori', NULL, NULL, NULL),
(124, 'Oromo', 'om', 'orm', NULL, NULL, NULL),
(125, 'Ossetian; Ossetic', 'os', 'oss', NULL, NULL, NULL),
(126, 'Panjabi; Punjabi', 'pa', 'pan', NULL, NULL, NULL),
(127, 'Persian', 'fa', 'per', NULL, NULL, NULL),
(128, 'Pali', 'pi', 'pli', NULL, NULL, NULL),
(129, 'Polish', 'pl', 'pol', NULL, NULL, NULL),
(130, 'Portuguese', 'pt', 'por', NULL, NULL, NULL),
(131, 'Pushto; Pashto', 'ps', 'pus', NULL, NULL, NULL),
(132, 'Quechua', 'qu', 'que', NULL, NULL, NULL),
(133, 'Romansh', 'rm', 'roh', NULL, NULL, NULL),
(134, 'Romanian; Moldavian; Moldovan', 'ro', 'rum', NULL, NULL, NULL),
(135, 'Rundi', 'rn', 'run', NULL, NULL, NULL),
(136, 'Russian', 'ru', 'rus', NULL, NULL, NULL),
(137, 'Sango', 'sg', 'sag', NULL, NULL, NULL),
(138, 'Sanskrit', 'sa', 'san', NULL, NULL, NULL),
(139, 'Sinhala; Sinhalese', 'si', 'sin', NULL, NULL, NULL),
(140, 'Slovak', 'sk', 'slo', NULL, NULL, NULL),
(141, 'Slovenian', 'sl', 'slv', NULL, NULL, NULL),
(142, 'Northern Sami', 'se', 'sme', NULL, NULL, NULL),
(143, 'Samoan', 'sm', 'smo', NULL, NULL, NULL),
(144, 'Shona', 'sn', 'sna', NULL, NULL, NULL),
(145, 'Sindhi', 'sd', 'snd', NULL, NULL, NULL),
(146, 'Somali', 'so', 'som', NULL, NULL, NULL),
(147, 'Sotho, Southern', 'st', 'sot', NULL, NULL, NULL),
(148, 'Spanish; Castilian', 'es', 'spa', NULL, NULL, NULL),
(149, 'Sardinian', 'sc', 'srd', NULL, NULL, NULL),
(150, 'Serbian', 'sr', 'srp', NULL, NULL, NULL),
(151, 'Swati', 'ss', 'ssw', NULL, NULL, NULL),
(152, 'Sundanese', 'su', 'sun', NULL, NULL, NULL),
(153, 'Swahili', 'sw', 'swa', NULL, NULL, NULL),
(154, 'Swedish', 'sv', 'swe', NULL, NULL, NULL),
(155, 'Tahitian', 'ty', 'tah', NULL, NULL, NULL),
(156, 'Tamil', 'ta', 'tam', NULL, NULL, NULL),
(157, 'Tatar', 'tt', 'tat', NULL, NULL, NULL),
(158, 'Telugu', 'te', 'tel', NULL, NULL, NULL),
(159, 'Tajik', 'tg', 'tgk', NULL, NULL, NULL),
(160, 'Tagalog', 'tl', 'tgl', NULL, NULL, NULL),
(161, 'Thai', 'th', 'tha', NULL, NULL, NULL),
(162, 'Tibetan', 'bo', 'tib', NULL, NULL, NULL),
(163, 'Tigrinya', 'ti', 'tir', NULL, NULL, NULL),
(164, 'Tonga (Tonga Islands)', 'to', 'ton', NULL, NULL, NULL),
(165, 'Tswana', 'tn', 'tsn', NULL, NULL, NULL),
(166, 'Tsonga', 'ts', 'tso', NULL, NULL, NULL),
(167, 'Turkmen', 'tk', 'tuk', NULL, NULL, NULL),
(168, 'Turkish', 'tr', 'tur', NULL, NULL, NULL),
(169, 'Twi', 'tw', 'twi', NULL, NULL, NULL),
(170, 'Uighur; Uyghur', 'ug', 'uig', NULL, NULL, NULL),
(171, 'Ukrainian', 'uk', 'ukr', NULL, NULL, NULL),
(172, 'Urdu', 'ur', 'urd', NULL, NULL, NULL),
(173, 'Uzbek', 'uz', 'uzb', NULL, NULL, NULL),
(174, 'Venda', 've', 'ven', NULL, NULL, NULL),
(175, 'Vietnamese', 'vi', 'vie', NULL, NULL, NULL),
(176, 'Volapük', 'vo', 'vol', NULL, NULL, NULL),
(177, 'Welsh', 'cy', 'wel', NULL, NULL, NULL),
(178, 'Walloon', 'wa', 'wln', NULL, NULL, NULL),
(179, 'Wolof', 'wo', 'wol', NULL, NULL, NULL),
(180, 'Xhosa', 'xh', 'xho', NULL, NULL, NULL),
(181, 'Yiddish', 'yi', 'yid', NULL, NULL, NULL),
(182, 'Yoruba', 'yo', 'yor', NULL, NULL, NULL),
(183, 'Zhuang; Chuang', 'za', 'zha', NULL, NULL, NULL),
(184, 'Zulu', 'zu', 'zul', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `oauth_access_tokens`
--

DROP TABLE IF EXISTS `oauth_access_tokens`;
CREATE TABLE IF NOT EXISTS `oauth_access_tokens` (
  `id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `client_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `scopes` text COLLATE utf8mb4_unicode_ci,
  `revoked` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `oauth_access_tokens_user_id_index` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `oauth_auth_codes`
--

DROP TABLE IF EXISTS `oauth_auth_codes`;
CREATE TABLE IF NOT EXISTS `oauth_auth_codes` (
  `id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `client_id` bigint(20) UNSIGNED NOT NULL,
  `scopes` text COLLATE utf8mb4_unicode_ci,
  `revoked` tinyint(1) NOT NULL,
  `expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `oauth_auth_codes_user_id_index` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `oauth_clients`
--

DROP TABLE IF EXISTS `oauth_clients`;
CREATE TABLE IF NOT EXISTS `oauth_clients` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `secret` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `provider` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `redirect` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `personal_access_client` tinyint(1) NOT NULL,
  `password_client` tinyint(1) NOT NULL,
  `revoked` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `oauth_clients_user_id_index` (`user_id`)
) ENGINE=MyISAM AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `oauth_personal_access_clients`
--

DROP TABLE IF EXISTS `oauth_personal_access_clients`;
CREATE TABLE IF NOT EXISTS `oauth_personal_access_clients` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `client_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `oauth_refresh_tokens`
--

DROP TABLE IF EXISTS `oauth_refresh_tokens`;
CREATE TABLE IF NOT EXISTS `oauth_refresh_tokens` (
  `id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `access_token_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `revoked` tinyint(1) NOT NULL,
  `expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `oauth_refresh_tokens_access_token_id_index` (`access_token_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
CREATE TABLE IF NOT EXISTS `password_resets` (
  `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  KEY `password_resets_email_index` (`email`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `scopes`
--

DROP TABLE IF EXISTS `scopes`;
CREATE TABLE IF NOT EXISTS `scopes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `users_info`
--

DROP TABLE IF EXISTS `users_info`;
CREATE TABLE IF NOT EXISTS `users_info` (
  `users_id` bigint(20) UNSIGNED NOT NULL,
  `logon_count` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`users_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `users_scopes`
--

DROP TABLE IF EXISTS `users_scopes`;
CREATE TABLE IF NOT EXISTS `users_scopes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `users_id` bigint(20) UNSIGNED NOT NULL,
  `scopes_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`),
  KEY `users_id` (`users_id`),
  KEY `scopes_id` (`scopes_id`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `address_book`
--
ALTER TABLE `address_book`
  ADD CONSTRAINT `address_book_ibfk_2` FOREIGN KEY (`countries_id`) REFERENCES `countries` (`id`);

--
-- Contraintes pour la table `users_info`
--
ALTER TABLE `users_info`
  ADD CONSTRAINT `users_info_ibfk_1` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `users_scopes`
--
ALTER TABLE `users_scopes`
  ADD CONSTRAINT `users_scopes_ibfk_1` FOREIGN KEY (`scopes_id`) REFERENCES `scopes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `users_scopes_ibfk_2` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `users_scopes_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

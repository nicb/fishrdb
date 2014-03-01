-- --------------------------------------------------------
-- $Id: container_types.sql 2 2007-09-26 11:54:11Z nicb $
-- --------------------------------------------------------

-- 
-- Table structure for table `container_types`
-- 

DROP TABLE IF EXISTS container_types;
CREATE TABLE `container_types` (
  id int(11) NOT NULL auto_increment,
  container_type varchar(64) collate utf8_unicode_ci NOT NULL UNIQUE,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Type of containers';

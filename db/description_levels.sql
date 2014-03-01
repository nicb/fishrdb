--
-- $Id: description_levels.sql 2 2007-09-26 11:54:11Z nicb $
--
-- phpMyAdmin SQL Dump
-- version 2.9.1.1-Debian-2ubuntu1
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Jul 01, 2007 at 08:04 PM
-- Server version: 5.0.38
-- PHP Version: 5.2.1
-- 
-- Database: `fishrdb_development`
-- 

-- --------------------------------------------------------

-- 
-- Table structure for table `description_levels`
-- 

DROP TABLE IF EXISTS description_levels;
CREATE TABLE `description_levels` (
  id 		int(11) NOT NULL,
  level 	varchar(128) collate utf8_unicode_ci UNIQUE NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Description Level';

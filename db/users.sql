/*
 * $Id: users.sql 58 2007-11-13 00:07:10Z nicb $
 */
CREATE TABLE IF NOT EXISTS users (
  id			int(11) NOT NULL auto_increment,
  login			varchar(40) NOT NULL,
  name			varchar(256) default NULL,
  password		varchar(41) default NULL,
  user_type		enum('public','specialist','staff','admin') NOT NULL default 'public',
  email			varchar(1024) NOT NULL,
  clipboard_id  int(11) NULL,
  PRIMARY KEY  (id),
  UNIQUE KEY login (login)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

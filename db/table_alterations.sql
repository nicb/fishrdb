/*
 * $Id: table_alterations.sql 32 2007-10-24 17:46:50Z nicb $
 *
 * This is needed to avoid recursion while creating the database
 */

ALTER TABLE users ADD CONSTRAINT fk_user_clipb FOREIGN KEY	(clipboard_id) REFERENCES documents(id);

CREATE TABLE IF NOT EXISTS `settings` (
	`key`           TEXT     PRIMARY KEY,
	`value`         TEXT
);

CREATE TABLE IF NOT EXISTS building (id INTEGER PRIMARY KEY, location TEXT, street TEXT, number TEXT, first_period INTEGER NOT NULL, last_period INTEGER NOT NULL, lock_period INTEGER);

CREATE TABLE IF NOT EXISTS `accounts` (
	`id`            INTEGER  PRIMARY KEY AUTOINCREMENT   NOT NULL,
	`number`        TEXT                                 NOT NULL,
	`apartment`     TEXT                                 NOT NULL,
	`area`          REAL                                 NOT NULL
);

CREATE TABLE IF NOT EXISTS `people` (
	`id`            INTEGER  PRIMARY KEY AUTOINCREMENT  NOT NULL,
	`year`          INTEGER                             NOT NULL,
	`month`         INTEGER                             NOT NULL,
	`account`       INTEGER                             NOT NULL,
	`name`          TEXT                                NOT NULL,
	`birthday`      TEXT                                NOT NULL,
	`relationship`  TEXT
);

CREATE TABLE IF NOT EXISTS `services` (
	`id`            INTEGER  PRIMARY KEY AUTOINCREMENT  NOT NULL,
	`name`          TEXT                                NOT NULL,
	`unit`          TEXT                                NOT NULL
);

CREATE TABLE IF NOT EXISTS `taxes` (
	`id`            INTEGER  PRIMARY KEY AUTOINCREMENT  NOT NULL,
	`month`         INTEGER                             NOT NULL,
	`year`          INTEGER                             NOT NULL,
	`account`       INTEGER                             NOT NULL,
	`service`       INTEGER                             NOT NULL,
	`total`         INTEGER                             NOT NULL
);

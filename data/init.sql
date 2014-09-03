CREATE TABLE IF NOT EXISTS `buildings` (
	`id`         INTEGER  PRIMARY KEY AUTOINCREMENT  NOT NULL,
	`location`   TEXT                                NOT NULL,
	`street`     TEXT                                NOT NULL,
	`building`   TEXT                                NOT NULL
);

CREATE TABLE IF NOT EXISTS `accounts` (
	`id`         INTEGER  PRIMARY KEY AUTOINCREMENT  NOT NULL,
	`number`     TEXT                                NOT NULL,
	`apartment`  TEXT                                NOT NULL,
	`area`       REAL                                NOT NULL
);

CREATE TABLE IF NOT EXISTS `people` (
	`id`        INTEGER   PRIMARY KEY AUTOINCREMENT  NOT NULL,
	`name`      TEXT                                 NOT NULL,
	`birthday`  TEXT                                 NOT NULL
);

CREATE TABLE IF NOT EXISTS `services` (
	`id`        INTEGER   PRIMARY KEY AUTOINCREMENT  NOT NULL,
	`name`      TEXT                                 NOT NULL,
	`unit`      TEXT                                 NOT NULL
);

CREATE TABLE IF NOT EXISTS `tenants` (
	`month`     INTEGER                              NOT NULL,
	`year`      INTEGER                              NOT NULL,
	`account`   INTEGER                              NOT NULL,
	`person`    INTEGER                              NOT NULL,
	PRIMARY KEY (`month`, `year`, `account`, `person`)
);

CREATE TABLE IF NOT EXISTS `taxes` (
	`month`     INTEGER                              NOT NULL,
	`year`      INTEGER                              NOT NULL,
	`account`   INTEGER                              NOT NULL,
	`service`   INTEGER                              NOT NULL,
	PRIMARY KEY (`month`, `year`, `account`, `service`)
);

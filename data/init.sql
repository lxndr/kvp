CREATE TABLE IF NOT EXISTS lodging (
	id         INTEGER  PRIMARY KEY AUTOINCREMENT  NOT NULL,
	account    TEXT                                NOT NULL,
	apartment  TEXT                                NOT NULL
);

CREATE TABLE IF NOT EXISTS people (
	id        INTEGER   PRIMARY KEY AUTOINCREMENT  NOT NULL,
	name      TEXT                                 NOT NULL,
	birthday  TEXT                                 NOT NULL
);

CREATE TABLE IF NOT EXISTS service (
	id        INTEGER   PRIMARY KEY AUTOINCREMENT  NOT NULL,
	name      TEXT                                 NOT NULL
);

CREATE TABLE IF NOT EXISTS taxes (
	month     INTEGER                              NOT NULL,
	year      INTEGER                              NOT NULL,
	account   INTEGER                              NOT NULL,
	service   INTEGER                              NOT NULL,
	PRIMARY KEY (month, year, account, service)
);

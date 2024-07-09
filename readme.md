A simple blacklist system, I wrote this a while ago for a friend but they didn't use it. I have tweaked it a little bit but here you go

- Stops players from signing on to jobs, Sets them straight back to unemployed.
- Stops players from getting in blacklisted vehicles.
- Added a feature where is `DrivingBan` is set to true / 1 in db, the player cannot drive any vehicle at all, if set to false they only are restricted to whatever is set in the config.lua
- Using default qb-input and menu.

- Will not be maintaining this myself, if you want to do anything with it fork it and do whatever or push a pr.


Import this db


CREATE TABLE IF NOT EXISTS `blacklisted_citizens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `DrivingBan` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
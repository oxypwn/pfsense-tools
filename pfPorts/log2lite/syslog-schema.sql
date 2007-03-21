CREATE TABLE syslog (
    date date,
    "time" time without time zone,
    host character varying(30),
    facility character varying(15),
    priority character varying(15),
    program character varying(30),
    "level" character varying(10),
    msg text
);


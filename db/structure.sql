--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: route_shapes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE route_shapes (
    id integer NOT NULL,
    route_id character varying(255),
    service_id character varying(255),
    trip_id character varying(255),
    headsign character varying(255),
    shape_id character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: route_shapes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE route_shapes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: route_shapes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE route_shapes_id_seq OWNED BY route_shapes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: stops; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stops (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    trip_id integer,
    stop_id character varying(255),
    arrival_time integer,
    departure_time integer
);


--
-- Name: trips; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trips (
    id integer NOT NULL,
    mta_trip_id character varying(255),
    stops_remaining integer,
    mta_timestamp integer,
    route character varying(255),
    direction character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    start_time integer
);


--
-- Name: stops_by_trip; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW stops_by_trip AS
 SELECT trips.id,
    trips.route,
    trips.direction,
    trips.mta_timestamp,
    stops.stop_id,
    stops.departure_time,
    stops.arrival_time
   FROM (trips
     JOIN stops ON ((stops.trip_id = trips.id)));


--
-- Name: stops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stops_id_seq OWNED BY stops.id;


--
-- Name: trips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trips_id_seq OWNED BY trips.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY route_shapes ALTER COLUMN id SET DEFAULT nextval('route_shapes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stops ALTER COLUMN id SET DEFAULT nextval('stops_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trips ALTER COLUMN id SET DEFAULT nextval('trips_id_seq'::regclass);


--
-- Name: route_shapes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY route_shapes
    ADD CONSTRAINT route_shapes_pkey PRIMARY KEY (id);


--
-- Name: stops_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stops
    ADD CONSTRAINT stops_pkey PRIMARY KEY (id);


--
-- Name: trips_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trips
    ADD CONSTRAINT trips_pkey PRIMARY KEY (id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20141206204614');

INSERT INTO schema_migrations (version) VALUES ('20141206204859');

INSERT INTO schema_migrations (version) VALUES ('20141206213100');

INSERT INTO schema_migrations (version) VALUES ('20141207210656');

INSERT INTO schema_migrations (version) VALUES ('20141216003400');

INSERT INTO schema_migrations (version) VALUES ('20141216004759');

INSERT INTO schema_migrations (version) VALUES ('20141217202405');

INSERT INTO schema_migrations (version) VALUES ('20141217214255');

INSERT INTO schema_migrations (version) VALUES ('20141226024524');

INSERT INTO schema_migrations (version) VALUES ('20141226155713');

INSERT INTO schema_migrations (version) VALUES ('20141226155759');

INSERT INTO schema_migrations (version) VALUES ('20150111212038');

INSERT INTO schema_migrations (version) VALUES ('20150126225917');


--
-- PostgreSQL database dump
--

-- Dumped from database version 10.4
-- Dumped by pg_dump version 10.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: route_shapes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.route_shapes (
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

CREATE SEQUENCE public.route_shapes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: route_shapes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.route_shapes_id_seq OWNED BY public.route_shapes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: stops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stops (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    trip_id integer,
    stop_id character varying(255),
    arrival_time integer,
    departure_time integer
);


--
-- Name: trips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trips (
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

CREATE VIEW public.stops_by_trip AS
 SELECT trips.id,
    trips.route,
    trips.direction,
    trips.mta_timestamp,
    stops.stop_id,
    stops.departure_time,
    stops.arrival_time
   FROM (public.trips
     JOIN public.stops ON ((stops.trip_id = trips.id)));


--
-- Name: stops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stops_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stops_id_seq OWNED BY public.stops.id;


--
-- Name: trips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trips_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trips_id_seq OWNED BY public.trips.id;


--
-- Name: route_shapes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.route_shapes ALTER COLUMN id SET DEFAULT nextval('public.route_shapes_id_seq'::regclass);


--
-- Name: stops id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stops ALTER COLUMN id SET DEFAULT nextval('public.stops_id_seq'::regclass);


--
-- Name: trips id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trips ALTER COLUMN id SET DEFAULT nextval('public.trips_id_seq'::regclass);


--
-- Name: route_shapes route_shapes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.route_shapes
    ADD CONSTRAINT route_shapes_pkey PRIMARY KEY (id);


--
-- Name: stops stops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stops
    ADD CONSTRAINT stops_pkey PRIMARY KEY (id);


--
-- Name: trips trips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_pkey PRIMARY KEY (id);


--
-- Name: index_stops_on_trip_id_and_departure_time_and_arrival_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stops_on_trip_id_and_departure_time_and_arrival_time ON public.stops USING btree (trip_id, departure_time, arrival_time);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

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

INSERT INTO schema_migrations (version) VALUES ('20180623135649');


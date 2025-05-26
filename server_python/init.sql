--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1+b1)
-- Dumped by pg_dump version 17.0 (Debian 17.0-1+b2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activities (
    id integer NOT NULL,
    source_id integer NOT NULL,
    status_id integer NOT NULL,
    person_id integer,
    sensor_id integer
);


ALTER TABLE public.activities OWNER TO postgres;

--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.activities_id_seq OWNER TO postgres;

--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.activities_id_seq OWNED BY public.activities.id;


--
-- Name: authentication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.authentication (
    login character varying(50)[] NOT NULL,
    pswd character varying(50)[] NOT NULL,
    user_id integer NOT NULL
);


ALTER TABLE public.authentication OWNER TO postgres;

--
-- Name: floors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.floors (
    id integer NOT NULL,
    num integer NOT NULL,
    description text
);


ALTER TABLE public.floors OWNER TO postgres;

--
-- Name: floors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.floors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.floors_id_seq OWNER TO postgres;

--
-- Name: floors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.floors_id_seq OWNED BY public.floors.id;


--
-- Name: floors_schema; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.floors_schema (
    id integer NOT NULL,
    floor_id integer NOT NULL,
    schema bytea NOT NULL
);


ALTER TABLE public.floors_schema OWNER TO postgres;

--
-- Name: floors_schema_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.floors_schema_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.floors_schema_id_seq OWNER TO postgres;

--
-- Name: floors_schema_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.floors_schema_id_seq OWNED BY public.floors_schema.id;


--
-- Name: sensors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sensors (
    id integer NOT NULL,
    name character varying(60)[] NOT NULL,
    radius double precision NOT NULL,
    status_id integer NOT NULL,
    floor_id integer NOT NULL,
    pos_x integer NOT NULL,
    pos_y integer NOT NULL
);


ALTER TABLE public.sensors OWNER TO postgres;

--
-- Name: sensors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sensors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sensors_id_seq OWNER TO postgres;

--
-- Name: sensors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sensors_id_seq OWNED BY public.sensors.id;


--
-- Name: source_activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.source_activities (
    id integer NOT NULL,
    name character varying(50)[] NOT NULL
);


ALTER TABLE public.source_activities OWNER TO postgres;

--
-- Name: source_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.source_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.source_activities_id_seq OWNER TO postgres;

--
-- Name: source_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.source_activities_id_seq OWNED BY public.source_activities.id;


--
-- Name: status_activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.status_activities (
    id integer NOT NULL,
    name character varying(50)[] NOT NULL
);


ALTER TABLE public.status_activities OWNER TO postgres;

--
-- Name: status_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.status_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.status_activities_id_seq OWNER TO postgres;

--
-- Name: status_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.status_activities_id_seq OWNED BY public.status_activities.id;


--
-- Name: status_sensors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.status_sensors (
    id integer NOT NULL,
    name character varying(50)[] NOT NULL
);


ALTER TABLE public.status_sensors OWNER TO postgres;

--
-- Name: status_sensors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.status_sensors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.status_sensors_id_seq OWNER TO postgres;

--
-- Name: status_sensors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.status_sensors_id_seq OWNED BY public.status_sensors.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    surname character varying(30)[] NOT NULL,
    name character varying(30)[] NOT NULL,
    patronymic character varying(30)[]
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: activities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities ALTER COLUMN id SET DEFAULT nextval('public.activities_id_seq'::regclass);


--
-- Name: floors id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floors ALTER COLUMN id SET DEFAULT nextval('public.floors_id_seq'::regclass);


--
-- Name: floors_schema id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floors_schema ALTER COLUMN id SET DEFAULT nextval('public.floors_schema_id_seq'::regclass);


--
-- Name: sensors id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensors ALTER COLUMN id SET DEFAULT nextval('public.sensors_id_seq'::regclass);


--
-- Name: source_activities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_activities ALTER COLUMN id SET DEFAULT nextval('public.source_activities_id_seq'::regclass);


--
-- Name: status_activities id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_activities ALTER COLUMN id SET DEFAULT nextval('public.status_activities_id_seq'::regclass);


--
-- Name: status_sensors id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_sensors ALTER COLUMN id SET DEFAULT nextval('public.status_sensors_id_seq'::regclass);


--
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activities (id, source_id, status_id, person_id, sensor_id) FROM stdin;
\.


--
-- Data for Name: authentication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.authentication (login, pswd, user_id) FROM stdin;
\.


--
-- Data for Name: floors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.floors (id, num, description) FROM stdin;
\.


--
-- Data for Name: floors_schema; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.floors_schema (id, floor_id, schema) FROM stdin;
\.


--
-- Data for Name: sensors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sensors (id, name, radius, status_id, floor_id, pos_x, pos_y) FROM stdin;
\.


--
-- Data for Name: source_activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.source_activities (id, name) FROM stdin;
\.


--
-- Data for Name: status_activities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.status_activities (id, name) FROM stdin;
\.


--
-- Data for Name: status_sensors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.status_sensors (id, name) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, surname, name, patronymic) FROM stdin;
\.


--
-- Name: activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.activities_id_seq', 1, false);


--
-- Name: floors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.floors_id_seq', 1, false);


--
-- Name: floors_schema_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.floors_schema_id_seq', 1, false);


--
-- Name: sensors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sensors_id_seq', 1, false);


--
-- Name: source_activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.source_activities_id_seq', 1, false);


--
-- Name: status_activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.status_activities_id_seq', 1, false);


--
-- Name: status_sensors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.status_sensors_id_seq', 1, false);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: authentication authentication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authentication
    ADD CONSTRAINT authentication_pkey PRIMARY KEY (login);


--
-- Name: floors floors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floors
    ADD CONSTRAINT floors_pkey PRIMARY KEY (id);


--
-- Name: floors_schema floors_schema_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floors_schema
    ADD CONSTRAINT floors_schema_pkey PRIMARY KEY (id);


--
-- Name: sensors sensors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensors
    ADD CONSTRAINT sensors_pkey PRIMARY KEY (id);


--
-- Name: source_activities source_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.source_activities
    ADD CONSTRAINT source_activities_pkey PRIMARY KEY (id);


--
-- Name: status_activities status_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_activities
    ADD CONSTRAINT status_activities_pkey PRIMARY KEY (id);


--
-- Name: status_sensors status_sensors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_sensors
    ADD CONSTRAINT status_sensors_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: floors_schema floor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floors_schema
    ADD CONSTRAINT floor_id_fk FOREIGN KEY (floor_id) REFERENCES public.floors(id) NOT VALID;


--
-- Name: sensors floor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensors
    ADD CONSTRAINT floor_id_fk FOREIGN KEY (floor_id) REFERENCES public.floors(id) NOT VALID;


--
-- Name: activities person_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT person_id_fk FOREIGN KEY (person_id) REFERENCES public.users(id) NOT VALID;


--
-- Name: activities sensor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT sensor_id_fk FOREIGN KEY (sensor_id) REFERENCES public.sensors(id) NOT VALID;


--
-- Name: activities source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT source_id_fk FOREIGN KEY (source_id) REFERENCES public.source_activities(id) NOT VALID;


--
-- Name: activities status_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT status_id_fk FOREIGN KEY (status_id) REFERENCES public.status_activities(id) NOT VALID;


--
-- Name: sensors status_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensors
    ADD CONSTRAINT status_id_fk FOREIGN KEY (status_id) REFERENCES public.status_sensors(id) NOT VALID;


--
-- Name: authentication user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authentication
    ADD CONSTRAINT user_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) NOT VALID;


--
-- PostgreSQL database dump complete
--


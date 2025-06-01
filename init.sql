--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1+b1)
-- Dumped by pg_dump version 17.0 (Debian 17.0-1+b2)

-- Started on 2025-06-01 21:43:19 +07

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
-- TOC entry 219 (class 1259 OID 25600)
-- Name: authentication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.authentication (
    login character varying(60) NOT NULL,
    pswd character varying(256) NOT NULL
);


ALTER TABLE public.authentication OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 25676)
-- Name: events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.events (
    event_id integer NOT NULL,
    date timestamp with time zone NOT NULL,
    type_id integer NOT NULL,
    user_id character varying(60) NOT NULL
);


ALTER TABLE public.events OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 25675)
-- Name: events_event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.events_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.events_event_id_seq OWNER TO postgres;

--
-- TOC entry 3418 (class 0 OID 0)
-- Dependencies: 224
-- Name: events_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.events_event_id_seq OWNED BY public.events.event_id;


--
-- TOC entry 227 (class 1259 OID 25696)
-- Name: maps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.maps (
    map_id integer NOT NULL,
    room_id integer NOT NULL,
    file_path text NOT NULL
);


ALTER TABLE public.maps OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 25695)
-- Name: maps_map_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.maps_map_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.maps_map_id_seq OWNER TO postgres;

--
-- TOC entry 3419 (class 0 OID 0)
-- Dependencies: 226
-- Name: maps_map_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.maps_map_id_seq OWNED BY public.maps.map_id;


--
-- TOC entry 218 (class 1259 OID 25592)
-- Name: rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rooms (
    room_id integer NOT NULL,
    name character varying(60) NOT NULL,
    description text
);


ALTER TABLE public.rooms OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 25591)
-- Name: rooms_room_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rooms_room_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rooms_room_id_seq OWNER TO postgres;

--
-- TOC entry 3420 (class 0 OID 0)
-- Dependencies: 217
-- Name: rooms_room_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rooms_room_id_seq OWNED BY public.rooms.room_id;


--
-- TOC entry 223 (class 1259 OID 25615)
-- Name: sensors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sensors (
    sens_id integer NOT NULL,
    name character varying(60) NOT NULL,
    type_id integer NOT NULL,
    radius double precision NOT NULL,
    room_id integer NOT NULL,
    pos_x double precision NOT NULL,
    pos_y double precision NOT NULL,
    is_alert boolean NOT NULL
);


ALTER TABLE public.sensors OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 25614)
-- Name: sensors_sens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sensors_sens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sensors_sens_id_seq OWNER TO postgres;

--
-- TOC entry 3421 (class 0 OID 0)
-- Dependencies: 222
-- Name: sensors_sens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sensors_sens_id_seq OWNED BY public.sensors.sens_id;


--
-- TOC entry 221 (class 1259 OID 25606)
-- Name: type_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.type_events (
    type_event_id integer NOT NULL,
    name character varying(60) NOT NULL
);


ALTER TABLE public.type_events OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 25605)
-- Name: type_events_type_event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.type_events_type_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.type_events_type_event_id_seq OWNER TO postgres;

--
-- TOC entry 3422 (class 0 OID 0)
-- Dependencies: 220
-- Name: type_events_type_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.type_events_type_event_id_seq OWNED BY public.type_events.type_event_id;


--
-- TOC entry 216 (class 1259 OID 25583)
-- Name: type_sensors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.type_sensors (
    type_sens_id integer NOT NULL,
    name character varying(60) NOT NULL
);


ALTER TABLE public.type_sensors OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 25582)
-- Name: type_sensors_type_sens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.type_sensors_type_sens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.type_sensors_type_sens_id_seq OWNER TO postgres;

--
-- TOC entry 3423 (class 0 OID 0)
-- Dependencies: 215
-- Name: type_sensors_type_sens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.type_sensors_type_sens_id_seq OWNED BY public.type_sensors.type_sens_id;


--
-- TOC entry 3236 (class 2604 OID 25679)
-- Name: events event_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events ALTER COLUMN event_id SET DEFAULT nextval('public.events_event_id_seq'::regclass);


--
-- TOC entry 3237 (class 2604 OID 25699)
-- Name: maps map_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maps ALTER COLUMN map_id SET DEFAULT nextval('public.maps_map_id_seq'::regclass);


--
-- TOC entry 3233 (class 2604 OID 25595)
-- Name: rooms room_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms ALTER COLUMN room_id SET DEFAULT nextval('public.rooms_room_id_seq'::regclass);


--
-- TOC entry 3235 (class 2604 OID 25618)
-- Name: sensors sens_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensors ALTER COLUMN sens_id SET DEFAULT nextval('public.sensors_sens_id_seq'::regclass);


--
-- TOC entry 3234 (class 2604 OID 25609)
-- Name: type_events type_event_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_events ALTER COLUMN type_event_id SET DEFAULT nextval('public.type_events_type_event_id_seq'::regclass);


--
-- TOC entry 3232 (class 2604 OID 25586)
-- Name: type_sensors type_sens_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_sensors ALTER COLUMN type_sens_id SET DEFAULT nextval('public.type_sensors_type_sens_id_seq'::regclass);


--
-- TOC entry 3404 (class 0 OID 25600)
-- Dependencies: 219
-- Data for Name: authentication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.authentication (login, pswd) FROM stdin;
123	a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3
\.


--
-- TOC entry 3410 (class 0 OID 25676)
-- Dependencies: 225
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.events (event_id, date, type_id, user_id) FROM stdin;
\.


--
-- TOC entry 3412 (class 0 OID 25696)
-- Dependencies: 227
-- Data for Name: maps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maps (map_id, room_id, file_path) FROM stdin;
\.


--
-- TOC entry 3403 (class 0 OID 25592)
-- Dependencies: 218
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rooms (room_id, name, description) FROM stdin;
\.


--
-- TOC entry 3408 (class 0 OID 25615)
-- Dependencies: 223
-- Data for Name: sensors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sensors (sens_id, name, type_id, radius, room_id, pos_x, pos_y, is_alert) FROM stdin;
\.


--
-- TOC entry 3406 (class 0 OID 25606)
-- Dependencies: 221
-- Data for Name: type_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.type_events (type_event_id, name) FROM stdin;
\.


--
-- TOC entry 3401 (class 0 OID 25583)
-- Dependencies: 216
-- Data for Name: type_sensors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.type_sensors (type_sens_id, name) FROM stdin;
1	дымовой
2	движение
\.


--
-- TOC entry 3424 (class 0 OID 0)
-- Dependencies: 224
-- Name: events_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.events_event_id_seq', 1, false);


--
-- TOC entry 3425 (class 0 OID 0)
-- Dependencies: 226
-- Name: maps_map_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.maps_map_id_seq', 6, true);


--
-- TOC entry 3426 (class 0 OID 0)
-- Dependencies: 217
-- Name: rooms_room_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.rooms_room_id_seq', 12, true);


--
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 222
-- Name: sensors_sens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sensors_sens_id_seq', 12, true);


--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 220
-- Name: type_events_type_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.type_events_type_event_id_seq', 1, false);


--
-- TOC entry 3429 (class 0 OID 0)
-- Dependencies: 215
-- Name: type_sensors_type_sens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.type_sensors_type_sens_id_seq', 2, true);


--
-- TOC entry 3243 (class 2606 OID 25716)
-- Name: authentication authentication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authentication
    ADD CONSTRAINT authentication_pkey PRIMARY KEY (login);


--
-- TOC entry 3249 (class 2606 OID 25683)
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (event_id);


--
-- TOC entry 3251 (class 2606 OID 25703)
-- Name: maps maps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (map_id);


--
-- TOC entry 3241 (class 2606 OID 25599)
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (room_id);


--
-- TOC entry 3247 (class 2606 OID 25622)
-- Name: sensors sensors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensors
    ADD CONSTRAINT sensors_pkey PRIMARY KEY (sens_id);


--
-- TOC entry 3245 (class 2606 OID 25613)
-- Name: type_events type_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_events
    ADD CONSTRAINT type_events_pkey PRIMARY KEY (type_event_id);


--
-- TOC entry 3239 (class 2606 OID 25590)
-- Name: type_sensors type_sensors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_sensors
    ADD CONSTRAINT type_sensors_pkey PRIMARY KEY (type_sens_id);


--
-- TOC entry 3256 (class 2606 OID 25750)
-- Name: maps room_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maps
    ADD CONSTRAINT room_fk FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON DELETE CASCADE;


--
-- TOC entry 3252 (class 2606 OID 25755)
-- Name: sensors room_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensors
    ADD CONSTRAINT room_id_fk FOREIGN KEY (room_id) REFERENCES public.rooms(room_id) ON DELETE CASCADE;


--
-- TOC entry 3253 (class 2606 OID 25623)
-- Name: sensors type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sensors
    ADD CONSTRAINT type_id_fk FOREIGN KEY (type_id) REFERENCES public.type_sensors(type_sens_id);


--
-- TOC entry 3254 (class 2606 OID 25684)
-- Name: events type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT type_id_fk FOREIGN KEY (type_id) REFERENCES public.type_events(type_event_id);


--
-- TOC entry 3255 (class 2606 OID 25723)
-- Name: events user_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT user_fk FOREIGN KEY (user_id) REFERENCES public.authentication(login) NOT VALID;


-- Completed on 2025-06-01 21:43:21 +07

--
-- PostgreSQL database dump complete
--


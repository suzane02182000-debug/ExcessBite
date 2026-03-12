--
-- PostgreSQL database dump
--

\restrict t13Y9fpZc7wAJuzJ4ganWlkVhfsphGvqgX8Lr8AjmiDO9fq6WrffYvqWVvlCaGR

-- Dumped from database version 15.15
-- Dumped by pg_dump version 15.15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id integer NOT NULL,
    admin_id integer NOT NULL,
    action character varying(200) NOT NULL,
    entity_type character varying(100),
    entity_id integer,
    old_values json,
    new_values json,
    created_at timestamp without time zone
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.audit_logs_id_seq OWNER TO postgres;

--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: contact_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contact_messages (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    email character varying(120) NOT NULL,
    message text NOT NULL,
    is_read boolean,
    created_at timestamp without time zone
);


ALTER TABLE public.contact_messages OWNER TO postgres;

--
-- Name: contact_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contact_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.contact_messages_id_seq OWNER TO postgres;

--
-- Name: contact_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contact_messages_id_seq OWNED BY public.contact_messages.id;


--
-- Name: deliveries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deliveries (
    id integer NOT NULL,
    donation_id integer NOT NULL,
    ngo_id integer NOT NULL,
    logistics_id integer,
    status character varying(50),
    pickup_confirmation_image character varying(500),
    delivery_confirmation_image character varying(500),
    pickup_time timestamp without time zone,
    delivery_time timestamp without time zone,
    notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.deliveries OWNER TO postgres;

--
-- Name: deliveries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.deliveries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.deliveries_id_seq OWNER TO postgres;

--
-- Name: deliveries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.deliveries_id_seq OWNED BY public.deliveries.id;


--
-- Name: donations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.donations (
    id integer NOT NULL,
    donor_id integer NOT NULL,
    food_type character varying(200) NOT NULL,
    description text,
    quantity integer NOT NULL,
    unit character varying(50),
    expiry_time timestamp without time zone NOT NULL,
    pickup_date date NOT NULL,
    pickup_start_time time without time zone NOT NULL,
    pickup_end_time time without time zone NOT NULL,
    pickup_address text NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    city character varying(100),
    contact_number character varying(20) NOT NULL,
    status character varying(50),
    admin_notes text,
    image_url character varying(500),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    approved_at timestamp without time zone
);


ALTER TABLE public.donations OWNER TO postgres;

--
-- Name: donations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.donations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.donations_id_seq OWNER TO postgres;

--
-- Name: donations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.donations_id_seq OWNED BY public.donations.id;


--
-- Name: feedback; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feedback (
    id integer NOT NULL,
    delivery_id integer NOT NULL,
    donation_id integer NOT NULL,
    from_user_id integer NOT NULL,
    to_user_id integer NOT NULL,
    feedback_type character varying(50) NOT NULL,
    rating integer NOT NULL,
    comment text,
    created_at timestamp without time zone
);


ALTER TABLE public.feedback OWNER TO postgres;

--
-- Name: feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.feedback_id_seq OWNER TO postgres;

--
-- Name: feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feedback_id_seq OWNED BY public.feedback.id;


--
-- Name: food_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.food_requests (
    id integer NOT NULL,
    donation_id integer NOT NULL,
    ngo_id integer NOT NULL,
    requested_quantity integer NOT NULL,
    special_requirements text,
    status character varying(50),
    admin_notes text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    approved_at timestamp without time zone
);


ALTER TABLE public.food_requests OWNER TO postgres;

--
-- Name: food_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.food_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.food_requests_id_seq OWNER TO postgres;

--
-- Name: food_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.food_requests_id_seq OWNED BY public.food_requests.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    title character varying(200) NOT NULL,
    message text NOT NULL,
    notification_type character varying(50),
    related_id integer,
    is_read boolean,
    created_at timestamp without time zone
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(80) NOT NULL,
    email character varying(120) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role character varying(20) NOT NULL,
    full_name character varying(120) NOT NULL,
    phone character varying(20) NOT NULL,
    address text,
    city character varying(100),
    latitude double precision,
    longitude double precision,
    organization_name character varying(200),
    organization_type character varying(100),
    registration_number character varying(100),
    is_active boolean,
    is_verified boolean,
    verification_date timestamp without time zone,
    deactivation_reason text,
    deactivation_date timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: contact_messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_messages ALTER COLUMN id SET DEFAULT nextval('public.contact_messages_id_seq'::regclass);


--
-- Name: deliveries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries ALTER COLUMN id SET DEFAULT nextval('public.deliveries_id_seq'::regclass);


--
-- Name: donations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donations ALTER COLUMN id SET DEFAULT nextval('public.donations_id_seq'::regclass);


--
-- Name: feedback id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback ALTER COLUMN id SET DEFAULT nextval('public.feedback_id_seq'::regclass);


--
-- Name: food_requests id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food_requests ALTER COLUMN id SET DEFAULT nextval('public.food_requests_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, admin_id, action, entity_type, entity_id, old_values, new_values, created_at) FROM stdin;
\.


--
-- Data for Name: contact_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contact_messages (id, name, email, message, is_read, created_at) FROM stdin;
\.


--
-- Data for Name: deliveries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.deliveries (id, donation_id, ngo_id, logistics_id, status, pickup_confirmation_image, delivery_confirmation_image, pickup_time, delivery_time, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: donations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.donations (id, donor_id, food_type, description, quantity, unit, expiry_time, pickup_date, pickup_start_time, pickup_end_time, pickup_address, latitude, longitude, city, contact_number, status, admin_notes, image_url, created_at, updated_at, approved_at) FROM stdin;
\.


--
-- Data for Name: feedback; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.feedback (id, delivery_id, donation_id, from_user_id, to_user_id, feedback_type, rating, comment, created_at) FROM stdin;
\.


--
-- Data for Name: food_requests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.food_requests (id, donation_id, ngo_id, requested_quantity, special_requirements, status, admin_notes, created_at, updated_at, approved_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, title, message, notification_type, related_id, is_read, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, password_hash, role, full_name, phone, address, city, latitude, longitude, organization_name, organization_type, registration_number, is_active, is_verified, verification_date, deactivation_reason, deactivation_date, created_at, updated_at) FROM stdin;
1	Shruthi	shruthi@gmail.com	$2b$12$hZX0BW1Mb8IJ3QpB9Pdk.eIFSmQKqGwzzTtdjshloW.fqqLDtWRNC	ngo	Shruthi	7656894567			17.42346	78.294136	NGO		\N	t	f	\N	\N	\N	2026-03-12 16:07:42.714944	2026-03-12 16:07:42.714975
2	Krishna	krishna@gmail.com	$2b$12$D4Um2iHVbbm1K0EzCN7.jusI44oqqwuw6/hJuyaQh/kvcJKCaPczi	donor	Krishna	7656894568	Goshamahal Road, Habeeb Nagar, Hyderabad, Telangana, 500023	Hyderabad	17.423391	78.293984			\N	t	t	2026-03-12 16:10:32.854966	\N	\N	2026-03-12 16:10:32.863131	2026-03-12 16:10:32.863154
\.


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 1, false);


--
-- Name: contact_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contact_messages_id_seq', 1, false);


--
-- Name: deliveries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.deliveries_id_seq', 1, false);


--
-- Name: donations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.donations_id_seq', 1, false);


--
-- Name: feedback_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.feedback_id_seq', 1, false);


--
-- Name: food_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.food_requests_id_seq', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 2, true);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: contact_messages contact_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_messages
    ADD CONSTRAINT contact_messages_pkey PRIMARY KEY (id);


--
-- Name: deliveries deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_pkey PRIMARY KEY (id);


--
-- Name: donations donations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_pkey PRIMARY KEY (id);


--
-- Name: feedback feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_pkey PRIMARY KEY (id);


--
-- Name: food_requests food_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food_requests
    ADD CONSTRAINT food_requests_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: feedback unique_delivery_feedback; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT unique_delivery_feedback UNIQUE (delivery_id, from_user_id, to_user_id);


--
-- Name: food_requests unique_donation_ngo_request; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food_requests
    ADD CONSTRAINT unique_donation_ngo_request UNIQUE (donation_id, ngo_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_audit_logs_admin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_audit_logs_admin_id ON public.audit_logs USING btree (admin_id);


--
-- Name: ix_audit_logs_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_audit_logs_created_at ON public.audit_logs USING btree (created_at);


--
-- Name: ix_contact_messages_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_contact_messages_created_at ON public.contact_messages USING btree (created_at);


--
-- Name: ix_contact_messages_is_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_contact_messages_is_read ON public.contact_messages USING btree (is_read);


--
-- Name: ix_deliveries_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_deliveries_created_at ON public.deliveries USING btree (created_at);


--
-- Name: ix_deliveries_donation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_deliveries_donation_id ON public.deliveries USING btree (donation_id);


--
-- Name: ix_deliveries_logistics_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_deliveries_logistics_id ON public.deliveries USING btree (logistics_id);


--
-- Name: ix_deliveries_ngo_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_deliveries_ngo_id ON public.deliveries USING btree (ngo_id);


--
-- Name: ix_deliveries_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_deliveries_status ON public.deliveries USING btree (status);


--
-- Name: ix_donations_city; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_donations_city ON public.donations USING btree (city);


--
-- Name: ix_donations_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_donations_created_at ON public.donations USING btree (created_at);


--
-- Name: ix_donations_donor_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_donations_donor_id ON public.donations USING btree (donor_id);


--
-- Name: ix_donations_pickup_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_donations_pickup_date ON public.donations USING btree (pickup_date);


--
-- Name: ix_donations_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_donations_status ON public.donations USING btree (status);


--
-- Name: ix_feedback_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_feedback_created_at ON public.feedback USING btree (created_at);


--
-- Name: ix_feedback_delivery_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_feedback_delivery_id ON public.feedback USING btree (delivery_id);


--
-- Name: ix_feedback_donation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_feedback_donation_id ON public.feedback USING btree (donation_id);


--
-- Name: ix_feedback_from_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_feedback_from_user_id ON public.feedback USING btree (from_user_id);


--
-- Name: ix_feedback_to_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_feedback_to_user_id ON public.feedback USING btree (to_user_id);


--
-- Name: ix_food_requests_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_food_requests_created_at ON public.food_requests USING btree (created_at);


--
-- Name: ix_food_requests_donation_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_food_requests_donation_id ON public.food_requests USING btree (donation_id);


--
-- Name: ix_food_requests_ngo_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_food_requests_ngo_id ON public.food_requests USING btree (ngo_id);


--
-- Name: ix_food_requests_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_food_requests_status ON public.food_requests USING btree (status);


--
-- Name: ix_notifications_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_notifications_created_at ON public.notifications USING btree (created_at);


--
-- Name: ix_notifications_is_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_notifications_is_read ON public.notifications USING btree (is_read);


--
-- Name: ix_notifications_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_notifications_user_id ON public.notifications USING btree (user_id);


--
-- Name: ix_users_city; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_city ON public.users USING btree (city);


--
-- Name: ix_users_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_created_at ON public.users USING btree (created_at);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_is_active ON public.users USING btree (is_active);


--
-- Name: ix_users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_username ON public.users USING btree (username);


--
-- Name: audit_logs audit_logs_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.users(id);


--
-- Name: deliveries deliveries_donation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_donation_id_fkey FOREIGN KEY (donation_id) REFERENCES public.donations(id);


--
-- Name: deliveries deliveries_logistics_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_logistics_id_fkey FOREIGN KEY (logistics_id) REFERENCES public.users(id);


--
-- Name: deliveries deliveries_ngo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_ngo_id_fkey FOREIGN KEY (ngo_id) REFERENCES public.users(id);


--
-- Name: deliveries deliveries_ngo_id_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_ngo_id_fkey1 FOREIGN KEY (ngo_id) REFERENCES public.users(id);


--
-- Name: donations donations_donor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donations
    ADD CONSTRAINT donations_donor_id_fkey FOREIGN KEY (donor_id) REFERENCES public.users(id);


--
-- Name: feedback feedback_delivery_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_delivery_id_fkey FOREIGN KEY (delivery_id) REFERENCES public.deliveries(id);


--
-- Name: feedback feedback_donation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_donation_id_fkey FOREIGN KEY (donation_id) REFERENCES public.donations(id);


--
-- Name: feedback feedback_from_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_from_user_id_fkey FOREIGN KEY (from_user_id) REFERENCES public.users(id);


--
-- Name: feedback feedback_to_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_to_user_id_fkey FOREIGN KEY (to_user_id) REFERENCES public.users(id);


--
-- Name: food_requests food_requests_donation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food_requests
    ADD CONSTRAINT food_requests_donation_id_fkey FOREIGN KEY (donation_id) REFERENCES public.donations(id);


--
-- Name: food_requests food_requests_ngo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.food_requests
    ADD CONSTRAINT food_requests_ngo_id_fkey FOREIGN KEY (ngo_id) REFERENCES public.users(id);


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict t13Y9fpZc7wAJuzJ4ganWlkVhfsphGvqgX8Lr8AjmiDO9fq6WrffYvqWVvlCaGR


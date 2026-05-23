--
-- PostgreSQL database dump
--

restrict cpQa39grjgrKozwgDQ3GOb8MMHUw8aWtRLIsRoNZlHEBxO30TNmlfI53FKucZot

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-05-23 15:29:49

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

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 5063 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 859 (class 1247 OID 16630)
-- Name: AccessType; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."AccessType" AS ENUM (
    'IN',
    'OUT'
);


ALTER TYPE public."AccessType" OWNER TO postgres;

--
-- TOC entry 856 (class 1247 OID 16625)
-- Name: IdentityProvider; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."IdentityProvider" AS ENUM (
    'LOCAL',
    'THAID'
);


ALTER TYPE public."IdentityProvider" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 16676)
-- Name: access_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.access_logs (
    id text NOT NULL,
    student_id text NOT NULL,
    access_time timestamp(3) without time zone NOT NULL,
    type public."AccessType" NOT NULL,
    gate_name text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.access_logs OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16690)
-- Name: devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices (
    id text NOT NULL,
    parent_id text NOT NULL,
    fcm_token text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.devices OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16666)
-- Name: parent_student_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parent_student_mapping (
    id text NOT NULL,
    parent_id text NOT NULL,
    student_id text NOT NULL
);


ALTER TABLE public.parent_student_mapping OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16635)
-- Name: parents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parents (
    id text NOT NULL,
    name text NOT NULL,
    phone text NOT NULL,
    email text NOT NULL,
    password_hash text,
    thaid_sub text,
    identity_provider public."IdentityProvider" DEFAULT 'LOCAL'::public."IdentityProvider" NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.parents OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16653)
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    id text NOT NULL,
    external_student_id text NOT NULL,
    student_code text NOT NULL,
    name text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    dormitory text,
    room_number text
);


ALTER TABLE public.students OWNER TO postgres;

--
-- TOC entry 5056 (class 0 OID 16676)
-- Dependencies: 222
-- Data for Name: access_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.access_logs (id, student_id, access_time, type, gate_name, created_at) FROM stdin;
4d88b174-cda5-4e1d-82d8-2b34b9673e33	051d442b-6927-4a35-9f80-9d94a0c524cc	2026-05-20 05:55:00	IN	Main Entrance	2026-05-20 15:35:49.957
30e9a35a-87b8-4c87-bb16-52193de740de	051d442b-6927-4a35-9f80-9d94a0c524cc	2026-05-20 16:55:00	IN	Main Entrance	2026-05-20 15:54:14.988
84e7a781-9f3a-485d-b45a-f0a1f0d75290	051d442b-6927-4a35-9f80-9d94a0c524cc	2026-05-23 05:55:00	IN	Main Entrance	2026-05-23 06:32:31.484
\.


--
-- TOC entry 5057 (class 0 OID 16690)
-- Dependencies: 223
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.devices (id, parent_id, fcm_token, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5055 (class 0 OID 16666)
-- Dependencies: 221
-- Data for Name: parent_student_mapping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parent_student_mapping (id, parent_id, student_id) FROM stdin;
4366aff4-0f7b-4ee1-8cfe-48a9b9dd22d8	438c1324-c3bc-472d-895d-f1fde526a064	051d442b-6927-4a35-9f80-9d94a0c524cc
e6812313-fef0-4c8f-909b-20e61e668ee9	438c1324-c3bc-472d-895d-f1fde526a064	7e1aa157-6c06-4c54-9fd2-25b5f6008e83
\.


--
-- TOC entry 5053 (class 0 OID 16635)
-- Dependencies: 219
-- Data for Name: parents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parents (id, name, phone, email, password_hash, thaid_sub, identity_provider, is_verified, created_at, updated_at) FROM stdin;
438c1324-c3bc-472d-895d-f1fde526a064	Test2 Parent	0822222222	test2@2.com	$2b$12$vVQST9xlUMzR0uhYtEkcX.2.ib3UdReIo5e/exAePFEZN/U2TXSqe	\N	LOCAL	f	2026-05-20 15:30:36.379	2026-05-20 15:30:36.379
03197304-4407-4dbf-b566-f49c601f0719	Test3 Parent	0811111113	test3@3.com	$2b$12$/o6NaVRGFtQ/W5qK6ByrvOU.2UUF4cou5bWE9zaJEUEkB1SNjuCAC	\N	LOCAL	f	2026-05-22 11:04:01.375	2026-05-22 11:04:01.375
\.


--
-- TOC entry 5054 (class 0 OID 16653)
-- Dependencies: 220
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number) FROM stdin;
051d442b-6927-4a35-9f80-9d94a0c524cc	T002	6631501026	Araya Logniyom	2026-05-20 15:29:27.118	Saktong3	217
7e1aa157-6c06-4c54-9fd2-25b5f6008e83	T001	6631501163	Parichat Phojan	2026-05-22 11:05:26.362	Saktong3	127
\.


--
-- TOC entry 4896 (class 2606 OID 16689)
-- Name: access_logs access_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.access_logs
    ADD CONSTRAINT access_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 4901 (class 2606 OID 16702)
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- TOC entry 4894 (class 2606 OID 16675)
-- Name: parent_student_mapping parent_student_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parent_student_mapping
    ADD CONSTRAINT parent_student_mapping_pkey PRIMARY KEY (id);


--
-- TOC entry 4886 (class 2606 OID 16652)
-- Name: parents parents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_pkey PRIMARY KEY (id);


--
-- TOC entry 4890 (class 2606 OID 16665)
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- TOC entry 4897 (class 1259 OID 16709)
-- Name: access_logs_student_id_access_time_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX access_logs_student_id_access_time_idx ON public.access_logs USING btree (student_id, access_time DESC);


--
-- TOC entry 4898 (class 1259 OID 16710)
-- Name: access_logs_student_id_access_time_type_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX access_logs_student_id_access_time_type_key ON public.access_logs USING btree (student_id, access_time, type);


--
-- TOC entry 4899 (class 1259 OID 16711)
-- Name: devices_fcm_token_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX devices_fcm_token_key ON public.devices USING btree (fcm_token);


--
-- TOC entry 4892 (class 1259 OID 16708)
-- Name: parent_student_mapping_parent_id_student_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX parent_student_mapping_parent_id_student_id_key ON public.parent_student_mapping USING btree (parent_id, student_id);


--
-- TOC entry 4883 (class 1259 OID 16704)
-- Name: parents_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX parents_email_key ON public.parents USING btree (email);


--
-- TOC entry 4884 (class 1259 OID 16703)
-- Name: parents_phone_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX parents_phone_key ON public.parents USING btree (phone);


--
-- TOC entry 4887 (class 1259 OID 16705)
-- Name: parents_thaid_sub_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX parents_thaid_sub_key ON public.parents USING btree (thaid_sub);


--
-- TOC entry 4888 (class 1259 OID 16706)
-- Name: students_external_student_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX students_external_student_id_key ON public.students USING btree (external_student_id);


--
-- TOC entry 4891 (class 1259 OID 16707)
-- Name: students_student_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX students_student_code_key ON public.students USING btree (student_code);


--
-- TOC entry 4904 (class 2606 OID 16722)
-- Name: access_logs access_logs_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.access_logs
    ADD CONSTRAINT access_logs_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4905 (class 2606 OID 16727)
-- Name: devices devices_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parents(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4902 (class 2606 OID 16712)
-- Name: parent_student_mapping parent_student_mapping_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parent_student_mapping
    ADD CONSTRAINT parent_student_mapping_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parents(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4903 (class 2606 OID 16717)
-- Name: parent_student_mapping parent_student_mapping_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parent_student_mapping
    ADD CONSTRAINT parent_student_mapping_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2026-05-23 15:29:49

--
-- PostgreSQL database dump complete
--

\unrestrict cpQa39grjgrKozwgDQ3GOb8MMHUw8aWtRLIsRoNZlHEBxO30TNmlfI53FKucZot


--
-- PostgreSQL database dump
--


-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

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

ALTER TABLE IF EXISTS ONLY public.parent_student_registry DROP CONSTRAINT IF EXISTS parent_student_registry_student_id_fkey;
ALTER TABLE IF EXISTS ONLY public.devices DROP CONSTRAINT IF EXISTS devices_parent_id_fkey;
ALTER TABLE IF EXISTS ONLY public.auth_logs DROP CONSTRAINT IF EXISTS auth_logs_parent_id_fkey;
ALTER TABLE IF EXISTS ONLY public.access_logs DROP CONSTRAINT IF EXISTS access_logs_student_id_fkey;
DROP INDEX IF EXISTS public.students_student_code_key;
DROP INDEX IF EXISTS public.students_external_student_id_key;
DROP INDEX IF EXISTS public.parents_thaid_sub_key;
DROP INDEX IF EXISTS public.parents_citizen_id_key;
DROP INDEX IF EXISTS public.parent_student_registry_parent_citizen_id_student_id_key;
DROP INDEX IF EXISTS public.parent_student_registry_parent_citizen_id_idx;
DROP INDEX IF EXISTS public.devices_fcm_token_key;
DROP INDEX IF EXISTS public.auth_logs_parent_id_created_at_idx;
DROP INDEX IF EXISTS public.access_logs_student_id_access_time_type_key;
DROP INDEX IF EXISTS public.access_logs_student_id_access_time_idx;
ALTER TABLE IF EXISTS ONLY public.students DROP CONSTRAINT IF EXISTS students_pkey;
ALTER TABLE IF EXISTS ONLY public.parents DROP CONSTRAINT IF EXISTS parents_pkey;
ALTER TABLE IF EXISTS ONLY public.parent_student_registry DROP CONSTRAINT IF EXISTS parent_student_registry_pkey;
ALTER TABLE IF EXISTS ONLY public.devices DROP CONSTRAINT IF EXISTS devices_pkey;
ALTER TABLE IF EXISTS ONLY public.auth_logs DROP CONSTRAINT IF EXISTS auth_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.access_logs DROP CONSTRAINT IF EXISTS access_logs_pkey;
ALTER TABLE IF EXISTS ONLY public._prisma_migrations DROP CONSTRAINT IF EXISTS _prisma_migrations_pkey;
DROP TABLE IF EXISTS public.students;
DROP TABLE IF EXISTS public.parents;
DROP TABLE IF EXISTS public.parent_student_registry;
DROP TABLE IF EXISTS public.devices;
DROP TABLE IF EXISTS public.auth_logs;
DROP TABLE IF EXISTS public.access_logs;
DROP TABLE IF EXISTS public._prisma_migrations;
DROP TYPE IF EXISTS public."StudentStatus";
DROP TYPE IF EXISTS public."Relationship";
DROP TYPE IF EXISTS public."IdentityProvider";
DROP TYPE IF EXISTS public."AuthEvent";
DROP TYPE IF EXISTS public."AccessType";
--
-- Name: AccessType; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."AccessType" AS ENUM (
    'IN',
    'OUT'
);


--
-- Name: AuthEvent; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."AuthEvent" AS ENUM (
    'LOGIN',
    'LOGOUT',
    'DENIED'
);


--
-- Name: IdentityProvider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."IdentityProvider" AS ENUM (
    'LOCAL',
    'THAID'
);


--
-- Name: Relationship; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."Relationship" AS ENUM (
    'FATHER',
    'MOTHER',
    'GUARDIAN',
    'OTHER'
);


--
-- Name: StudentStatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."StudentStatus" AS ENUM (
    'ACTIVE',
    'GRADUATED',
    'MOVED_OUT'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


--
-- Name: access_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.access_logs (
    id text NOT NULL,
    student_id text NOT NULL,
    access_time timestamp(3) without time zone NOT NULL,
    type public."AccessType" NOT NULL,
    gate_name text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: auth_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_logs (
    id text NOT NULL,
    parent_id text,
    event public."AuthEvent" NOT NULL,
    ip_address text,
    user_agent text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    citizen_id text
);


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.devices (
    id text NOT NULL,
    parent_id text NOT NULL,
    fcm_token text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: parent_student_registry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parent_student_registry (
    id text NOT NULL,
    parent_citizen_id text NOT NULL,
    student_id text NOT NULL,
    relationship public."Relationship" DEFAULT 'GUARDIAN'::public."Relationship" NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Name: parents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parents (
    id text NOT NULL,
    name text NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL,
    thaid_sub text,
    identity_provider public."IdentityProvider" DEFAULT 'THAID'::public."IdentityProvider" NOT NULL,
    citizen_id text NOT NULL
);


--
-- Name: students; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.students (
    id text NOT NULL,
    external_student_id text NOT NULL,
    student_code text NOT NULL,
    name text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    dormitory text,
    room_number text,
    left_at timestamp(3) without time zone,
    status public."StudentStatus" DEFAULT 'ACTIVE'::public."StudentStatus" NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('fd8600e2-8e53-47b2-9724-cae51a468fac', '1ecad857993dade27aecf175a695d982fec17152527c1b70bbb8b6131684d58d', '2026-06-26 23:21:31.433761-07', '20260418050346_init', '', NULL, '2026-06-26 23:21:31.433761-07', 0);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('93a78d05-77bb-4dba-b5e6-7e8fb35c129b', '5ea903cd0b672aa092d1e1c5e0efa52ba81ba7b562ded5538799f8645b0e8e7d', '2026-06-27 00:15:08.225205-07', '20260627141456_thaid_only_auth', NULL, NULL, '2026-06-27 00:15:08.199621-07', 1);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('63d2eff3-5b51-4e6d-9803-26a7638a03f1', '0e715ca874fea2fc8fa15edee0ee43ad7092d85c7d9d6e84a17383caaebc2d99', '2026-06-27 00:26:04.398708-07', '20260627142600_add_auth_logs', NULL, NULL, '2026-06-27 00:26:04.364189-07', 1);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('f7e19154-b0de-4f1a-b826-6d0f40ef5f98', '330b31031ff2c2865b8c6d2c5c525b7b36db7feffa281a4419e3b207c478cb57', '2026-06-30 02:36:22.515619-07', '20260630163618_registry_status_relationship', NULL, NULL, '2026-06-30 02:36:22.378568-07', 1);


--
-- Data for Name: access_logs; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at) VALUES ('0eefe8f0-dfc3-44cc-a574-fbd41747f493', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-06-30 00:30:00', 'IN', 'F1 Main Gate', '2026-06-30 09:42:25.184');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at) VALUES ('bd257f27-7171-4861-aad0-f2581bfcb5ad', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-06-30 10:45:00', 'OUT', 'F1 Main Gate', '2026-06-30 09:42:25.192');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at) VALUES ('66edfe13-67cb-4446-bb6b-3b58cf6d7958', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-06-29 01:00:00', 'IN', 'F1 Main Gate', '2026-06-30 09:42:25.194');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at) VALUES ('ce24b7da-32db-4a04-b702-1042d2feef69', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-06-29 15:50:00', 'IN', 'F1 Main Gate', '2026-06-30 09:42:25.197');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at) VALUES ('5addd05b-b64c-48c4-974e-b5b7f9f69bad', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-06-28 11:00:00', 'OUT', 'F1 Main Gate', '2026-06-30 09:42:25.199');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at) VALUES ('8ad415f6-a880-4d75-996c-105446c13e15', 'd6760e2e-5eb3-4bc9-9d33-507774b3a7bd', '2026-06-30 01:15:00', 'IN', 'F1 Main Gate', '2026-06-30 09:42:25.201');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at) VALUES ('8078bd1a-7ba5-4b6d-b094-ba351e4b4df0', 'd6760e2e-5eb3-4bc9-9d33-507774b3a7bd', '2026-06-30 12:00:00', 'OUT', 'F1 Main Gate', '2026-06-30 09:42:25.204');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at) VALUES ('e3ad846c-d94c-40b9-bf75-86205a2554c8', 'd6760e2e-5eb3-4bc9-9d33-507774b3a7bd', '2026-06-29 02:05:00', 'IN', 'F1 Main Gate', '2026-06-30 09:42:25.206');


--
-- Data for Name: auth_logs; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: parent_student_registry; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('afaad28e-5e0f-44bd-9cd1-899391c75578', '1149900859119', '4cf6f324-9736-408c-9315-93fe9a37692d', 'FATHER', '2026-06-30 09:42:25.169', '2026-06-30 09:42:25.169');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('0c30b760-8337-4e46-a2bf-3c65567d4291', '1149900859119', 'd6760e2e-5eb3-4bc9-9d33-507774b3a7bd', 'FATHER', '2026-06-30 09:42:25.175', '2026-06-30 09:42:25.175');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('53b09dde-abb3-44b7-9594-c74df6549c4e', '1100200300400', '4cf6f324-9736-408c-9315-93fe9a37692d', 'MOTHER', '2026-06-30 09:42:25.176', '2026-06-30 09:42:25.176');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('21487962-c535-4d2b-950f-79aad052756f', '3301201232653', '1542dfaf-961a-45fa-8919-8cee743affdc', 'MOTHER', '2026-06-30 09:42:25.178', '2026-06-30 09:42:25.178');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('93980407-311f-4520-84cf-e330cc091add', '3640400263229', '9ac11cfd-0e8e-4bcd-a10d-f3f51fead82c', 'FATHER', '2026-06-30 09:42:25.179', '2026-06-30 09:42:25.179');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('85fa7e25-8b4e-45f1-9f29-d452d3cd02de', '3101401511876', '1ecb27a8-9e4b-420e-8c73-a3092564d2c3', 'GUARDIAN', '2026-06-30 09:42:25.181', '2026-06-30 09:42:25.181');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('6c07b1f8-01d9-4022-a267-cb508a69a60e', '3400700708503', 'c1546821-929b-4bab-bafd-25ec9f63f587', 'FATHER', '2026-06-30 09:42:25.183', '2026-06-30 09:42:25.183');


--
-- Data for Name: parents; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at) VALUES ('4cf6f324-9736-408c-9315-93fe9a37692d', 'T001', '6631501163', 'Parichat Phojan', '2026-06-30 09:42:25.145', 'F1', '127', NULL, 'ACTIVE', '2026-06-30 09:42:25.145');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at) VALUES ('1542dfaf-961a-45fa-8919-8cee743affdc', 'T002', '6631501126', 'Araya Logniyom', '2026-06-30 09:42:25.158', 'F1', '201', NULL, 'ACTIVE', '2026-06-30 09:42:25.158');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at) VALUES ('9ac11cfd-0e8e-4bcd-a10d-f3f51fead82c', 'T003', '6631501064', 'Nawamol Nuanyai', '2026-06-30 09:42:25.161', 'F2', '305', NULL, 'ACTIVE', '2026-06-30 09:42:25.161');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at) VALUES ('1ecb27a8-9e4b-420e-8c73-a3092564d2c3', 'T004', '6631509004', 'Kittipong Jaidee', '2026-06-30 09:42:25.164', 'F1', '110', '2026-06-30 09:42:25.161', 'GRADUATED', '2026-06-30 09:42:25.164');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at) VALUES ('c1546821-929b-4bab-bafd-25ec9f63f587', 'T005', '6631509005', 'Suda Manalai', '2026-06-30 09:42:25.165', 'F2', '410', '2026-06-30 09:42:25.164', 'MOVED_OUT', '2026-06-30 09:42:25.165');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at) VALUES ('d6760e2e-5eb3-4bc9-9d33-507774b3a7bd', 'T006', '6631501003', 'Phailin Phojan', '2026-06-30 09:42:25.167', 'F1', '128', NULL, 'ACTIVE', '2026-06-30 09:42:25.167');


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: access_logs access_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_logs
    ADD CONSTRAINT access_logs_pkey PRIMARY KEY (id);


--
-- Name: auth_logs auth_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_logs
    ADD CONSTRAINT auth_logs_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: parent_student_registry parent_student_registry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_student_registry
    ADD CONSTRAINT parent_student_registry_pkey PRIMARY KEY (id);


--
-- Name: parents parents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_pkey PRIMARY KEY (id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: access_logs_student_id_access_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX access_logs_student_id_access_time_idx ON public.access_logs USING btree (student_id, access_time DESC);


--
-- Name: access_logs_student_id_access_time_type_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX access_logs_student_id_access_time_type_key ON public.access_logs USING btree (student_id, access_time, type);


--
-- Name: auth_logs_parent_id_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_logs_parent_id_created_at_idx ON public.auth_logs USING btree (parent_id, created_at DESC);


--
-- Name: devices_fcm_token_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX devices_fcm_token_key ON public.devices USING btree (fcm_token);


--
-- Name: parent_student_registry_parent_citizen_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX parent_student_registry_parent_citizen_id_idx ON public.parent_student_registry USING btree (parent_citizen_id);


--
-- Name: parent_student_registry_parent_citizen_id_student_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX parent_student_registry_parent_citizen_id_student_id_key ON public.parent_student_registry USING btree (parent_citizen_id, student_id);


--
-- Name: parents_citizen_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX parents_citizen_id_key ON public.parents USING btree (citizen_id);


--
-- Name: parents_thaid_sub_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX parents_thaid_sub_key ON public.parents USING btree (thaid_sub);


--
-- Name: students_external_student_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX students_external_student_id_key ON public.students USING btree (external_student_id);


--
-- Name: students_student_code_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX students_student_code_key ON public.students USING btree (student_code);


--
-- Name: access_logs access_logs_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_logs
    ADD CONSTRAINT access_logs_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: auth_logs auth_logs_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_logs
    ADD CONSTRAINT auth_logs_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parents(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: devices devices_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parents(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: parent_student_registry parent_student_registry_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_student_registry
    ADD CONSTRAINT parent_student_registry_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--



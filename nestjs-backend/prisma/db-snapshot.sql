--
-- PostgreSQL database dump
--

\restrict frQxkBnVBu5KTFjbcHUEnObaervedshZj92ceqZCMORg85eCyOCbwjoyQJgec3J

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

ALTER TABLE IF EXISTS ONLY public.parent_student_mapping DROP CONSTRAINT IF EXISTS parent_student_mapping_student_id_fkey;
ALTER TABLE IF EXISTS ONLY public.parent_student_mapping DROP CONSTRAINT IF EXISTS parent_student_mapping_parent_id_fkey;
ALTER TABLE IF EXISTS ONLY public.devices DROP CONSTRAINT IF EXISTS devices_parent_id_fkey;
ALTER TABLE IF EXISTS ONLY public.auth_logs DROP CONSTRAINT IF EXISTS auth_logs_parent_id_fkey;
ALTER TABLE IF EXISTS ONLY public.access_logs DROP CONSTRAINT IF EXISTS access_logs_student_id_fkey;
DROP INDEX IF EXISTS public.students_student_code_key;
DROP INDEX IF EXISTS public.students_external_student_id_key;
DROP INDEX IF EXISTS public.parents_thaid_sub_key;
DROP INDEX IF EXISTS public.parents_citizen_id_key;
DROP INDEX IF EXISTS public.parent_student_mapping_parent_id_student_id_key;
DROP INDEX IF EXISTS public.devices_fcm_token_key;
DROP INDEX IF EXISTS public.auth_logs_parent_id_created_at_idx;
DROP INDEX IF EXISTS public.access_logs_student_id_access_time_type_key;
DROP INDEX IF EXISTS public.access_logs_student_id_access_time_idx;
ALTER TABLE IF EXISTS ONLY public.students DROP CONSTRAINT IF EXISTS students_pkey;
ALTER TABLE IF EXISTS ONLY public.parents DROP CONSTRAINT IF EXISTS parents_pkey;
ALTER TABLE IF EXISTS ONLY public.parent_student_mapping DROP CONSTRAINT IF EXISTS parent_student_mapping_pkey;
ALTER TABLE IF EXISTS ONLY public.devices DROP CONSTRAINT IF EXISTS devices_pkey;
ALTER TABLE IF EXISTS ONLY public.auth_logs DROP CONSTRAINT IF EXISTS auth_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.access_logs DROP CONSTRAINT IF EXISTS access_logs_pkey;
ALTER TABLE IF EXISTS ONLY public._prisma_migrations DROP CONSTRAINT IF EXISTS _prisma_migrations_pkey;
DROP TABLE IF EXISTS public.students;
DROP TABLE IF EXISTS public.parents;
DROP TABLE IF EXISTS public.parent_student_mapping;
DROP TABLE IF EXISTS public.devices;
DROP TABLE IF EXISTS public.auth_logs;
DROP TABLE IF EXISTS public.access_logs;
DROP TABLE IF EXISTS public._prisma_migrations;
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
    'LOGOUT'
);


--
-- Name: IdentityProvider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public."IdentityProvider" AS ENUM (
    'LOCAL',
    'THAID'
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
    parent_id text NOT NULL,
    event public."AuthEvent" NOT NULL,
    ip_address text,
    user_agent text,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
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
-- Name: parent_student_mapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parent_student_mapping (
    id text NOT NULL,
    parent_id text NOT NULL,
    student_id text NOT NULL
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
    room_number text
);


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
fd8600e2-8e53-47b2-9724-cae51a468fac	1ecad857993dade27aecf175a695d982fec17152527c1b70bbb8b6131684d58d	2026-06-26 23:21:31.433761-07	20260418050346_init		\N	2026-06-26 23:21:31.433761-07	0
93a78d05-77bb-4dba-b5e6-7e8fb35c129b	5ea903cd0b672aa092d1e1c5e0efa52ba81ba7b562ded5538799f8645b0e8e7d	2026-06-27 00:15:08.225205-07	20260627141456_thaid_only_auth	\N	\N	2026-06-27 00:15:08.199621-07	1
63d2eff3-5b51-4e6d-9803-26a7638a03f1	0e715ca874fea2fc8fa15edee0ee43ad7092d85c7d9d6e84a17383caaebc2d99	2026-06-27 00:26:04.398708-07	20260627142600_add_auth_logs	\N	\N	2026-06-27 00:26:04.364189-07	1
\.


--
-- Data for Name: access_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.access_logs (id, student_id, access_time, type, gate_name, created_at) FROM stdin;
4d88b174-cda5-4e1d-82d8-2b34b9673e33	051d442b-6927-4a35-9f80-9d94a0c524cc	2026-05-20 05:55:00	IN	Main Entrance	2026-05-20 15:35:49.957
30e9a35a-87b8-4c87-bb16-52193de740de	051d442b-6927-4a35-9f80-9d94a0c524cc	2026-05-20 16:55:00	IN	Main Entrance	2026-05-20 15:54:14.988
84e7a781-9f3a-485d-b45a-f0a1f0d75290	051d442b-6927-4a35-9f80-9d94a0c524cc	2026-05-23 05:55:00	IN	Main Entrance	2026-05-23 06:32:31.484
d91c249c-c8cf-483d-b31a-ecc08199da15	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-05-23 10:40:19	IN	Main Gate	2026-05-23 10:40:19.119
4dd2abf0-b445-4a4c-81da-fcbeeca2fc9a	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-05-23 10:41:20	OUT	Main Gate	2026-05-23 10:41:20.35
4b6819b6-1588-4b45-9167-9db63cf58677	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-05-23 10:46:38	IN	Main Gate	2026-05-23 10:46:38.901
4108fabc-3b1d-42ff-b876-d5c79ca55d50	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-05-23 11:00:55	IN	Main Gate	2026-05-23 11:00:55.309
a65af08c-3d02-4ddb-9b0f-98ddbce3ff00	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-05-24 07:21:32	IN	Main Gate	2026-05-24 07:21:32.536
62dc7f25-40dc-4f4a-89cb-2a1865495500	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-05-24 07:22:33	OUT	Main Gate	2026-05-24 07:22:33.392
bbf295fe-f724-4105-a529-23c8f54a91e0	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-05-24 07:23:33	IN	Main Gate	2026-05-24 07:23:33.883
54afe9f1-af11-4799-99fc-4ff5f817b1d7	412c85e6-b25b-4759-9bee-87995b5d918b	2026-05-27 07:58:21	IN	Main Gate	2026-05-27 07:58:22.024
9d569c89-03c6-4d41-8bcd-256425989f60	412c85e6-b25b-4759-9bee-87995b5d918b	2026-05-27 07:59:25	OUT	Main Gate	2026-05-27 07:59:25.126
b4595b81-0c9a-4c46-9a44-5fa59f83749c	051d442b-6927-4a35-9f80-9d94a0c524cc	2026-05-27 07:59:29	IN	Main Gate	2026-05-27 07:59:29.124
dfe5d61d-9ac5-41d9-bc8f-eeddd42a7a10	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-05-28 05:55:00	IN	Main Entrance	2026-05-28 10:39:57.807
2df36325-f052-4154-9fb7-30a8186056f1	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-05-29 04:50:00	IN	Main Entrance	2026-05-29 08:15:43.346
deeed719-69f0-49fc-8777-fab8a2483e6e	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-05-29 11:32:00	IN	Main Entrance	2026-05-29 13:07:45.367
e3576e7e-4e13-43a0-b472-83386241796e	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-05-29 16:32:00	IN	Main Entrance	2026-05-29 13:51:56.359
176e9906-9915-4dfd-94f3-e7a86f0871ba	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-05-29 16:34:00	IN	Main Entrance	2026-05-29 14:24:57.722
77f6ed93-b5e4-4bc5-806c-9bedf02a6827	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-05-29 16:35:00	IN	Main Entrance	2026-05-29 14:33:44.521
da97288f-002c-48f1-acbf-7e33d460eee0	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-05-29 15:02:59	IN	Main Gate	2026-05-29 15:02:59.688
e0245280-befa-425b-aba6-83e7da1b9799	956df20d-3784-4e47-a10d-0dd85bc7c9e7	2026-06-17 05:55:00	IN	Main Entrance	2026-06-17 08:09:27.783
643dbcd6-3d89-4fbb-a237-cdcbe535785a	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-06-18 05:55:00	IN	Main Entrance	2026-06-18 02:32:20.789
902d15e6-ee1f-4f97-8cc3-029b38faa493	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-06-27 05:55:00	IN	Main Entrance	2026-06-27 12:33:35.562
b8b7b566-2610-44e4-a9aa-52def4a2d6e9	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-06-21 05:55:00	IN	Main Entrance	2026-06-27 12:35:34.443
70eda661-1de9-4688-a55f-3f84cd3a9abb	7e1aa157-6c06-4c54-9fd2-25b5f6008e83	2026-06-20 05:55:00	IN	Main Entrance	2026-06-27 12:35:52.875
\.


--
-- Data for Name: auth_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at) FROM stdin;
db800821-28f8-4859-855b-1ae04a9b66d3	c3d7a169-2ef5-40a1-b731-43b8170ef2f7	LOGIN	::ffff:127.0.0.1	Dart/3.11 (dart:io)	2026-06-27 12:30:44.036
771675cf-df33-4b6c-8db6-920be7d5192d	c3d7a169-2ef5-40a1-b731-43b8170ef2f7	LOGOUT	::ffff:127.0.0.1	Dart/3.11 (dart:io)	2026-06-27 12:33:50.447
f7a04d69-6a1b-4dfa-b626-a00beca53503	c3d7a169-2ef5-40a1-b731-43b8170ef2f7	LOGIN	::ffff:127.0.0.1	Dart/3.11 (dart:io)	2026-06-27 12:35:00.79
23541cdd-74bd-4fa1-8b1e-85a8dd149057	c3d7a169-2ef5-40a1-b731-43b8170ef2f7	LOGOUT	::ffff:127.0.0.1	Dart/3.11 (dart:io)	2026-06-27 12:49:52.12
cd2002aa-8bf6-4675-a5c7-455abf7c0642	c3d7a169-2ef5-40a1-b731-43b8170ef2f7	LOGIN	::ffff:127.0.0.1	Dart/3.11 (dart:io)	2026-06-27 12:50:00.663
\.


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.devices (id, parent_id, fcm_token, created_at, updated_at) FROM stdin;
97552ee3-1d4b-491b-912c-96f85320acc1	c3d7a169-2ef5-40a1-b731-43b8170ef2f7	epPlQ_O_TKWsdiEaXBSMG8:APA91bFU2qF2ihuleHmjkPmIX4BWwD36obrJmrQn1rOj9mfFwPZzisLz0CStFeMkzwEuBCCxSxv_Ikql7kgdaasSF-_RPtKnIyG3quhHgbJ3TRAtBF76k8s	2026-06-27 12:30:44.826	2026-06-27 12:49:19.928
\.


--
-- Data for Name: parent_student_mapping; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.parent_student_mapping (id, parent_id, student_id) FROM stdin;
25de0138-5697-4e51-bcac-541355cfb63c	c3d7a169-2ef5-40a1-b731-43b8170ef2f7	7e1aa157-6c06-4c54-9fd2-25b5f6008e83
\.


--
-- Data for Name: parents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.parents (id, name, is_verified, created_at, updated_at, thaid_sub, identity_provider, citizen_id) FROM stdin;
c3d7a169-2ef5-40a1-b731-43b8170ef2f7	ชื่อตัว ชื่อกลาง ชื่อสกุล	t	2026-06-27 12:30:43.875	2026-06-27 12:50:00.659	1149900859119	THAID	1149900859119
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number) FROM stdin;
7e1aa157-6c06-4c54-9fd2-25b5f6008e83	T001	6631501163	Parichat Phojan	2026-05-22 11:05:26.362	Saktong3	127
412c85e6-b25b-4759-9bee-87995b5d918b	T003	6631501064	Nawamol Nuanyai	2026-05-23 10:58:34.912	Saktong3	712
051d442b-6927-4a35-9f80-9d94a0c524cc	T002	6631501126	Araya Logniyom	2026-05-20 15:29:27.118	Saktong3	217
956df20d-3784-4e47-a10d-0dd85bc7c9e7	T004	6631501111	Arai Wa	2026-06-17 08:05:58.443	Saktong3	153
dac09103-59ed-4839-b110-5a30bcee6ae5	T005	6631501005	test5 student	2026-06-18 01:56:44.67	Saktong3	222
\.


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
-- Name: parent_student_mapping parent_student_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_student_mapping
    ADD CONSTRAINT parent_student_mapping_pkey PRIMARY KEY (id);


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
-- Name: parent_student_mapping_parent_id_student_id_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX parent_student_mapping_parent_id_student_id_key ON public.parent_student_mapping USING btree (parent_id, student_id);


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
-- Name: parent_student_mapping parent_student_mapping_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_student_mapping
    ADD CONSTRAINT parent_student_mapping_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parents(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: parent_student_mapping parent_student_mapping_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parent_student_mapping
    ADD CONSTRAINT parent_student_mapping_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict frQxkBnVBu5KTFjbcHUEnObaervedshZj92ceqZCMORg85eCyOCbwjoyQJgec3J


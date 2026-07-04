--
-- PostgreSQL database dump
--

\restrict Pf6Rrb8yMjbdSi4ilEP74NvwgH18QMqL24TOrxrmxplntCaYCy0XjtwM2oSGLM5

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
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    photo_url text,
    scan_photo_url text
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

INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('7d471b4f-1363-4d1e-a99a-b764ab80b8eb', '8d44bac69aa7bc0a3f5743f045dc9af6bea5d064129c6b023899fc0744bcf874', '2026-07-04 06:06:12.560517-07', '20260704000000_init', '', NULL, '2026-07-04 06:06:12.560517-07', 0);


--
-- Data for Name: access_logs; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('66edfe13-67cb-4446-bb6b-3b58cf6d7958', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-06-29 01:00:00', 'IN', 'F1 Main Gate', '2026-06-30 09:42:25.194', 'https://loremflickr.com/150/150/chicken?lock=22', 'https://loremflickr.com/150/150/chicken,face?lock=23');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('5addd05b-b64c-48c4-974e-b5b7f9f69bad', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-06-28 11:00:00', 'OUT', 'F1 Main Gate', '2026-06-30 09:42:25.199', 'https://loremflickr.com/150/150/cat?lock=24', 'https://loremflickr.com/150/150/cat,face?lock=25');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('d2d8ed3d-f8e7-4441-a5fa-1deadcc80e3a', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-07-04 01:15:00', 'IN', 'Main Entrance', '2026-07-03 17:56:03.609', NULL, NULL);
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('b690306b-6b7c-4fd9-a1f2-c669a6c230c7', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-07-04 02:45:00', 'IN', 'Main Entrance', '2026-07-03 17:56:10.203', NULL, NULL);
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('4f722357-4fc4-418a-91ba-a1c86a558c15', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-07-01 02:45:00', 'IN', 'Main Entrance', '2026-07-03 17:56:16.051', NULL, NULL);
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('b62c4de7-7e65-4d03-9d3d-d9d52f43c0e9', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-07-04 00:25:00', 'IN', 'Main Entrance', '2026-07-03 17:25:43.047', 'https://loremflickr.com/150/150/pig?lock=0', 'https://loremflickr.com/150/150/pig,face?lock=1');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('7b5d3ca7-60f0-430b-937a-5a8bff689c24', '9ac11cfd-0e8e-4bcd-a10d-f3f51fead82c', '2026-06-30 16:59:00', 'IN', 'Main Entrance', '2026-06-30 15:11:33.89', 'https://loremflickr.com/150/150/dog?lock=2', 'https://loremflickr.com/150/150/dog,face?lock=3');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('d6ad2709-5b4f-4fdd-b11e-74022dc94f4e', '9ac11cfd-0e8e-4bcd-a10d-f3f51fead82c', '2026-06-30 16:35:00', 'IN', 'Main Entrance', '2026-06-30 14:36:57.955', 'https://loremflickr.com/150/150/rooster?lock=4', 'https://loremflickr.com/150/150/rooster,face?lock=5');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('267c829a-9699-4c6c-a525-e6c5a5a1ab2c', 'd6760e2e-5eb3-4bc9-9d33-507774b3a7bd', '2026-06-30 15:29:00', 'IN', 'Main Entrance', '2026-06-30 15:12:18.588', 'https://loremflickr.com/150/150/chicken?lock=6', 'https://loremflickr.com/150/150/chicken,face?lock=7');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('b948548b-b2ba-40c6-b499-1a57be6c0164', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-06-30 14:25:00', 'IN', 'Main Entrance', '2026-06-30 15:12:57.465', 'https://loremflickr.com/150/150/cat?lock=8', 'https://loremflickr.com/150/150/cat,face?lock=9');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('8078bd1a-7ba5-4b6d-b094-ba351e4b4df0', 'd6760e2e-5eb3-4bc9-9d33-507774b3a7bd', '2026-06-30 12:00:00', 'OUT', 'F1 Main Gate', '2026-06-30 09:42:25.204', 'https://loremflickr.com/150/150/duck?lock=10', 'https://loremflickr.com/150/150/duck,face?lock=11');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('bd257f27-7171-4861-aad0-f2581bfcb5ad', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-06-30 10:45:00', 'OUT', 'F1 Main Gate', '2026-06-30 09:42:25.192', 'https://loremflickr.com/150/150/cow?lock=12', 'https://loremflickr.com/150/150/cow,face?lock=13');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('8ad415f6-a880-4d75-996c-105446c13e15', 'd6760e2e-5eb3-4bc9-9d33-507774b3a7bd', '2026-06-30 01:15:00', 'IN', 'F1 Main Gate', '2026-06-30 09:42:25.201', 'https://loremflickr.com/150/150/goat?lock=14', 'https://loremflickr.com/150/150/goat,face?lock=15');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('0eefe8f0-dfc3-44cc-a574-fbd41747f493', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-06-30 00:30:00', 'IN', 'F1 Main Gate', '2026-06-30 09:42:25.184', 'https://loremflickr.com/150/150/pig?lock=16', 'https://loremflickr.com/150/150/pig,face?lock=17');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('ce24b7da-32db-4a04-b702-1042d2feef69', '4cf6f324-9736-408c-9315-93fe9a37692d', '2026-06-29 15:50:00', 'IN', 'F1 Main Gate', '2026-06-30 09:42:25.197', 'https://loremflickr.com/150/150/dog?lock=18', 'https://loremflickr.com/150/150/dog,face?lock=19');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url) VALUES ('e3ad846c-d94c-40b9-bf75-86205a2554c8', 'd6760e2e-5eb3-4bc9-9d33-507774b3a7bd', '2026-06-29 02:05:00', 'IN', 'F1 Main Gate', '2026-06-30 09:42:25.206', 'https://loremflickr.com/150/150/rooster?lock=20', 'https://loremflickr.com/150/150/rooster,face?lock=21');


--
-- Data for Name: auth_logs; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('51c107eb-30bd-443e-ac9e-38c4bfde0376', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 14:30:54.832', '1149900859119');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('f2eb66d0-aa3b-4183-bd71-056e4963c13e', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 14:33:51.991', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('ad4098dc-2d8f-45b6-b574-b1f5df9060ea', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 14:54:19.97', '1149900859119');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('382fd89b-84ed-412c-8ab1-5ded89fd110c', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 14:54:41.65', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('247504b0-47f7-4e10-8eea-042659cfa3cb', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 14:54:46.822', '1149900859119');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('8e367fea-a0db-4855-90ed-db055f9344b1', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 15:10:07.808', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('b8d0fe4e-2bfe-49e7-b947-581fcca8c0f7', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 15:11:07.145', '1149900859119');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('18ce944f-ec60-45f4-8766-c6f90c2cd9dc', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 15:13:29.952', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('d65c040e-34f9-4f89-bf08-cf8d403aa508', NULL, 'DENIED', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 15:13:40.613', '3400700708503');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('15be4b8c-5a82-412f-8876-0fac27849e89', NULL, 'DENIED', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 15:13:46.709', '3400700708503');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('34e16c6c-e9db-42eb-8d11-c27d4e1682f2', NULL, 'DENIED', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 15:14:43.285', '3101401511876');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('f34e5a9f-806a-4513-bada-446dbf467d51', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 15:22:49.23', '1149900859119');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('105a750d-4d9a-4918-99b1-a8e4ab4c90f2', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 15:23:05.76', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('191ed825-f145-4d4f-974b-d7ef40200f90', NULL, 'DENIED', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 15:23:30.176', '3101401511876');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('72c0becc-0470-4bea-966d-84cbc9bb7c96', NULL, 'DENIED', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 15:24:16.887', '3400700708503');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('465df647-cb2f-4c33-9753-fae87b68ce99', NULL, 'DENIED', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 15:25:24.12', '1141400113455');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('6d94f485-8a0f-4829-8952-c9d5550f6241', '0769db6b-3fe7-4286-93c7-067d364259b9', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 16:49:20.104', '3640400263229');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('d35da569-2ba4-408e-bd97-db22ddc80335', '0769db6b-3fe7-4286-93c7-067d364259b9', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-06-30 16:49:38.392', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('455f5749-0f8b-4920-8e18-aadc76006bf5', '0769db6b-3fe7-4286-93c7-067d364259b9', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-03 12:45:07.3', '3640400263229');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('85052a12-8576-435a-bbc2-63ce38332b37', '0769db6b-3fe7-4286-93c7-067d364259b9', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-03 12:45:17.685', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('3e60efff-0271-4ec4-bc53-9fe0e7fe4080', NULL, 'DENIED', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-03 12:46:01.983', '3101401511876');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('0d29e59c-fe9a-4b6f-b012-94ad4ee3b2f5', NULL, 'DENIED', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-03 12:47:12.99', '1141400113455');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('e25d20ad-b0ec-4ebe-956c-3e872a1312ac', '0769db6b-3fe7-4286-93c7-067d364259b9', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-03 12:48:52.003', '3640400263229');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('4b1813c2-bac5-49dc-9f30-dd1ed290c06e', '0769db6b-3fe7-4286-93c7-067d364259b9', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-03 12:48:59.501', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('9e068d05-894d-4e9b-82f1-59edc8ff2ba8', '8bb210f9-9a7d-45e2-a8ad-171e22ef6fa0', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-03 12:49:40.738', '3301201232653');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('2fe06375-3548-41e9-ab4f-5c13bdac177a', '8bb210f9-9a7d-45e2-a8ad-171e22ef6fa0', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-03 17:22:56.122', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('edf05fbb-0183-45f4-8d48-f17a997fc5a1', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-03 17:23:13.565', '1149900859119');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('36d7a140-e096-4d69-86a5-706402ddb1fe', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-03 17:39:28.815', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('ee432318-95dc-448a-bedd-acef4ac62b3c', NULL, 'DENIED', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-03 17:40:24.803', '3400700708503');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('a0f148cc-a8df-46bc-a002-8b7b999595cd', NULL, 'DENIED', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-03 17:45:46.625', '3400700708503');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('46a05916-4ca5-4d6a-8b64-23bb7ff15d90', NULL, 'DENIED', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-03 17:55:13.081', '3400700708503');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('eb1796ea-f51c-40f7-bbc4-8212b73de1ef', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-03 17:55:33.591', '1149900859119');


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.devices (id, parent_id, fcm_token, created_at, updated_at) VALUES ('ebab07c0-1290-43a5-9130-279a8d09f308', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'epPlQ_O_TKWsdiEaXBSMG8:APA91bFU2qF2ihuleHmjkPmIX4BWwD36obrJmrQn1rOj9mfFwPZzisLz0CStFeMkzwEuBCCxSxv_Ikql7kgdaasSF-_RPtKnIyG3quhHgbJ3TRAtBF76k8s', '2026-06-30 14:33:33.071', '2026-07-03 17:55:34.438');


--
-- Data for Name: parent_student_registry; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('afaad28e-5e0f-44bd-9cd1-899391c75578', '1149900859119', '4cf6f324-9736-408c-9315-93fe9a37692d', 'FATHER', '2026-06-30 09:42:25.169', '2026-06-30 14:26:43.089');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('0c30b760-8337-4e46-a2bf-3c65567d4291', '1149900859119', 'd6760e2e-5eb3-4bc9-9d33-507774b3a7bd', 'FATHER', '2026-06-30 09:42:25.175', '2026-06-30 14:26:43.093');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('53b09dde-abb3-44b7-9594-c74df6549c4e', '1100200300400', '4cf6f324-9736-408c-9315-93fe9a37692d', 'MOTHER', '2026-06-30 09:42:25.176', '2026-06-30 14:26:43.096');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('21487962-c535-4d2b-950f-79aad052756f', '3301201232653', '1542dfaf-961a-45fa-8919-8cee743affdc', 'MOTHER', '2026-06-30 09:42:25.178', '2026-06-30 14:26:43.099');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('93980407-311f-4520-84cf-e330cc091add', '3640400263229', '9ac11cfd-0e8e-4bcd-a10d-f3f51fead82c', 'FATHER', '2026-06-30 09:42:25.179', '2026-06-30 14:26:43.101');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('85fa7e25-8b4e-45f1-9f29-d452d3cd02de', '3101401511876', '1ecb27a8-9e4b-420e-8c73-a3092564d2c3', 'GUARDIAN', '2026-06-30 09:42:25.181', '2026-06-30 14:26:43.104');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('6c07b1f8-01d9-4022-a267-cb508a69a60e', '3400700708503', 'c1546821-929b-4bab-bafd-25ec9f63f587', 'FATHER', '2026-06-30 09:42:25.183', '2026-06-30 14:26:43.106');


--
-- Data for Name: parents; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.parents (id, name, is_verified, created_at, updated_at, thaid_sub, identity_provider, citizen_id) VALUES ('0769db6b-3fe7-4286-93c7-067d364259b9', 'ชื่อตัว ชื่อกลาง ชื่อสกุล', true, '2026-06-30 16:49:20.078', '2026-07-03 12:48:52', '3640400263229', 'THAID', '3640400263229');
INSERT INTO public.parents (id, name, is_verified, created_at, updated_at, thaid_sub, identity_provider, citizen_id) VALUES ('8bb210f9-9a7d-45e2-a8ad-171e22ef6fa0', 'ชื่อตัว ชื่อกลาง ชื่อสกุล', true, '2026-07-03 12:49:40.732', '2026-07-03 12:49:40.732', '3301201232653', 'THAID', '3301201232653');
INSERT INTO public.parents (id, name, is_verified, created_at, updated_at, thaid_sub, identity_provider, citizen_id) VALUES ('0b689281-ea71-4a2f-8734-d1aea51a0e73', 'ชื่อตัว ชื่อกลาง ชื่อสกุล', true, '2026-06-30 14:30:54.823', '2026-07-03 17:55:33.572', '1149900859119', 'THAID', '1149900859119');


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at) VALUES ('4cf6f324-9736-408c-9315-93fe9a37692d', 'T001', '6631501163', 'Parichat Phojan', '2026-06-30 09:42:25.145', 'F1', '127', NULL, 'ACTIVE', '2026-06-30 14:26:43.027');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at) VALUES ('1542dfaf-961a-45fa-8919-8cee743affdc', 'T002', '6631501126', 'Araya Logniyom', '2026-06-30 09:42:25.158', 'F1', '201', NULL, 'ACTIVE', '2026-06-30 14:26:43.074');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at) VALUES ('9ac11cfd-0e8e-4bcd-a10d-f3f51fead82c', 'T003', '6631501064', 'Nawamol Nuanyai', '2026-06-30 09:42:25.161', 'F2', '305', NULL, 'ACTIVE', '2026-06-30 14:26:43.076');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at) VALUES ('1ecb27a8-9e4b-420e-8c73-a3092564d2c3', 'T004', '6631509004', 'Kittipong Jaidee', '2026-06-30 09:42:25.164', 'F1', '110', '2026-06-30 14:26:43.076', 'GRADUATED', '2026-06-30 14:26:43.078');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at) VALUES ('c1546821-929b-4bab-bafd-25ec9f63f587', 'T005', '6631509005', 'Suda Manalai', '2026-06-30 09:42:25.165', 'F2', '410', '2026-06-30 14:26:43.078', 'MOVED_OUT', '2026-06-30 14:26:43.08');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at) VALUES ('d6760e2e-5eb3-4bc9-9d33-507774b3a7bd', 'T006', '6631501003', 'Phailin Phojan', '2026-06-30 09:42:25.167', 'F1', '128', NULL, 'ACTIVE', '2026-06-30 14:26:43.081');


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

\unrestrict Pf6Rrb8yMjbdSi4ilEP74NvwgH18QMqL24TOrxrmxplntCaYCy0XjtwM2oSGLM5


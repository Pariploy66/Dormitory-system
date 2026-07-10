--
-- PostgreSQL database dump
--

\restrict ERn0fWYOeRssuHvM2nMpYgzb5l7TP5A32iS0nagrdEcg8iVN5Pc2SeXIHIuJxZ7

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
    scan_photo_url text,
    gate_name_en text
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
    updated_at timestamp(3) without time zone NOT NULL,
    photo_url text,
    name_en text,
    dormitory_en text
);


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('2f5736a7-2f52-49ee-a444-72c62b09db67', '1ecad857993dade27aecf175a695d982fec17152527c1b70bbb8b6131684d58d', '2026-07-04 06:11:14.779938-07', '20260418050346_init', '', NULL, '2026-07-04 06:11:14.779938-07', 0);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('df7ec974-d9e4-4beb-8cf4-dc6747c4f245', '859e4bbf59fb4dcd48c002bff54907f3988a9073d2d5c6220e02b3240cb07746', '2026-07-04 06:11:17.194295-07', '20260627141456_thaid_only_auth', '', NULL, '2026-07-04 06:11:17.194295-07', 0);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('0b829b23-0e93-493f-b30a-65be3ae89f1c', 'e257aa783015c43abb0811522a919411dc815f178a7eeb4f5fddf1719fb8d2c2', '2026-07-04 06:11:19.463971-07', '20260627142600_add_auth_logs', '', NULL, '2026-07-04 06:11:19.463971-07', 0);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('4a7763bb-8647-4d4a-a892-31e6050e3f18', 'a87ce652e00eb43756ba83af4f77e4e518cf4d0315ab0ce7034557a0d557b304', '2026-07-04 06:11:21.761218-07', '20260630163618_registry_status_relationship', '', NULL, '2026-07-04 06:11:21.761218-07', 0);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('fa9b0fcf-8cfe-439d-84dd-432bfb732211', 'daba54c0a48d6cfaec2ee88e605149577418d3e290acc3d5020375cced757024', '2026-07-04 06:11:24.00004-07', '20260703000000_access_log_photos', '', NULL, '2026-07-04 06:11:24.00004-07', 0);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('8e44bcc1-618d-40b1-a7bf-2cfed27a1624', '036c260915500794387d7421c2d444a1fa46f65235e5fd4361ff7b0617c84560', '2026-07-06 07:16:54.420349-07', '20260705000000_student_photo', NULL, NULL, '2026-07-06 07:16:54.397172-07', 1);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('0d6bfa0a-27df-4fda-8a63-bf0198de4738', '732e030ab3d3f43e65fd13164a2bad60adc64dad9e6d614454c9ceec4b858de3', '2026-07-08 06:35:56.847318-07', '20260707000000_bilingual_names', NULL, NULL, '2026-07-08 06:35:56.821228-07', 1);


--
-- Data for Name: access_logs; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('74665e22-7a28-4fe4-bf53-6d2347cfe118', 'f3f77a33-f77d-47a5-aae4-6caa23ba045f', '2026-07-03 03:48:12', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.432', 'https://i.pravatar.cc/150?img=7', 'https://i.pravatar.cc/150?img=7', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('d2108d08-eeff-4a30-bbb4-1ae5ce5a728a', '7cb85572-55c0-4d07-8325-d8b6e50c8d19', '2026-07-03 03:28:31', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.434', 'https://i.pravatar.cc/150?img=8', 'https://i.pravatar.cc/150?img=8', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('1c013ab2-05dc-4f25-a378-ebba7569e1aa', '37a9e1d1-0c23-461a-bd85-e1605465f146', '2026-07-03 06:51:43', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.406', 'https://i.pravatar.cc/150?img=1', 'https://i.pravatar.cc/150?img=1', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('5e95c093-77ef-494b-9b2d-90a28612e37b', '37a9e1d1-0c23-461a-bd85-e1605465f146', '2026-07-03 06:32:29', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.416', 'https://i.pravatar.cc/150?img=1', 'https://i.pravatar.cc/150?img=1', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('e69a9e72-bb35-4551-809c-d506a310bef5', '17a7d442-98ad-4d40-b7fc-e982ee038900', '2026-07-03 06:00:00', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.419', 'https://i.pravatar.cc/150?img=3', 'https://i.pravatar.cc/150?img=3', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('8e06cd22-dbf8-41a7-b3d0-368b583a0180', '2935b97a-ac1b-4006-95e4-9d0d83c82269', '2026-07-03 02:58:57', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.437', 'https://i.pravatar.cc/150?img=5', 'https://i.pravatar.cc/150?img=5', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('83a2ef05-2ceb-461c-abb1-45766ad96deb', '2935b97a-ac1b-4006-95e4-9d0d83c82269', '2026-07-03 02:29:32', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.439', 'https://i.pravatar.cc/150?img=5', 'https://i.pravatar.cc/150?img=5', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('4afb510a-ccd2-4427-942f-2b762b8c4f22', '1f741933-1757-4eaa-8924-5c63cb513553', '2026-07-02 22:51:55', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.441', 'https://i.pravatar.cc/150?img=6', 'https://i.pravatar.cc/150?img=6', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('dd378672-fe69-4d2f-b3c6-4b94bd55ff8a', '26213892-50e2-422a-8f25-37863c6d27ba', '2026-07-02 17:16:51', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.444', 'https://i.pravatar.cc/150?img=10', 'https://i.pravatar.cc/150?img=10', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('acc88dde-79f0-4c85-98d1-36f3f2577bd0', '1f741933-1757-4eaa-8924-5c63cb513553', '2026-07-02 17:03:30', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.447', 'https://i.pravatar.cc/150?img=6', 'https://i.pravatar.cc/150?img=6', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('4d9755e0-dc69-4e3f-bad1-5cd613d53255', '27fecc44-36e9-4122-90a5-45acc7b1f0cf', '2026-07-02 15:59:30', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.449', 'https://i.pravatar.cc/150?img=11', 'https://i.pravatar.cc/150?img=11', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('5a02e7b5-e7bd-477a-8f90-9a2260949fc2', '827f1406-2c94-4298-833e-0a5994eedc3a', '2026-07-02 15:52:54', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.452', 'https://i.pravatar.cc/150?img=12', 'https://i.pravatar.cc/150?img=12', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('a96b219c-7014-4c52-9c4c-0d4c6c853063', 'ddd9e728-05e4-4b4c-a06a-0910f2453d9a', '2026-07-02 15:39:44', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.454', 'https://i.pravatar.cc/150?img=13', 'https://i.pravatar.cc/150?img=13', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('2cafe7a4-3e81-4d32-9b0e-5a65e6b567aa', '935a4b5d-3593-4fad-b490-e2c368fae820', '2026-07-02 14:00:03', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.456', 'https://i.pravatar.cc/150?img=14', 'https://i.pravatar.cc/150?img=14', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('f54125df-25d2-4daa-8467-43da9d8164bc', 'b528b432-c5aa-428c-ab46-557819a78397', '2026-07-02 13:07:50', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.458', 'https://i.pravatar.cc/150?img=16', 'https://i.pravatar.cc/150?img=16', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('0d5d04e9-040a-4ac8-af4f-58fa0ee437f1', '935a4b5d-3593-4fad-b490-e2c368fae820', '2026-07-02 12:36:25', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.46', 'https://i.pravatar.cc/150?img=14', 'https://i.pravatar.cc/150?img=14', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('fbacd1d5-8801-41f9-b250-a0924493fc13', '4dd818f5-9553-4840-b273-52fe39d2f082', '2026-07-02 12:21:21', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.461', 'https://i.pravatar.cc/150?img=17', 'https://i.pravatar.cc/150?img=17', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('00ce190c-6394-4e52-94f3-c548a7933270', '80b9d8b4-314d-4f92-901a-153aed109e21', '2026-07-02 11:56:19', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.463', 'https://i.pravatar.cc/150?img=18', 'https://i.pravatar.cc/150?img=18', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('3851f51b-eda8-4b26-88a2-3dce6b73d9fb', '633f493a-ff64-47ae-a5bb-ea7498ad446a', '2026-07-03 05:59:34', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.423', 'https://i.pravatar.cc/150?img=4', 'https://i.pravatar.cc/150?img=4', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('caec8f5f-9146-47fb-babb-798cdebccc66', '2935b97a-ac1b-4006-95e4-9d0d83c82269', '2026-07-03 05:50:46', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.426', 'https://i.pravatar.cc/150?img=5', 'https://i.pravatar.cc/150?img=5', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('0f223629-353e-412d-a406-b792ee088222', '1f741933-1757-4eaa-8924-5c63cb513553', '2026-07-03 04:51:28', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.429', 'https://i.pravatar.cc/150?img=6', 'https://i.pravatar.cc/150?img=6', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('46e3321a-b4a8-4225-adc2-507f2c445845', '2935b97a-ac1b-4006-95e4-9d0d83c82269', '2026-07-02 11:55:31', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.466', 'https://i.pravatar.cc/150?img=5', 'https://i.pravatar.cc/150?img=5', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('be0436db-cd12-4617-b9ef-5c11953ff1f2', '2935b97a-ac1b-4006-95e4-9d0d83c82269', '2026-07-02 11:46:34', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.467', 'https://i.pravatar.cc/150?img=5', 'https://i.pravatar.cc/150?img=5', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('2d33d0ea-b37c-417d-be3f-1b5bcc21e0fb', '645ac7c3-8e8b-4a96-9f48-f6de9d8906b4', '2026-07-02 11:14:47', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.469', 'https://i.pravatar.cc/150?img=19', 'https://i.pravatar.cc/150?img=19', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('f76916c3-7de0-4515-8541-ab833c77358d', '827f1406-2c94-4298-833e-0a5994eedc3a', '2026-07-02 06:49:32', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.472', 'https://i.pravatar.cc/150?img=12', 'https://i.pravatar.cc/150?img=12', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('dd25ae06-c21d-45aa-9ac5-cc376af61904', '144354f7-4cfd-4248-a080-900c24abf337', '2026-07-02 04:46:44', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.474', 'https://i.pravatar.cc/150?img=21', 'https://i.pravatar.cc/150?img=21', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('fb0b13dd-c46f-49b4-8856-305a49500e57', '1f741933-1757-4eaa-8924-5c63cb513553', '2026-07-02 03:37:16', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.476', 'https://i.pravatar.cc/150?img=6', 'https://i.pravatar.cc/150?img=6', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('ae62def1-c798-41fb-a0bd-1a21a42e6193', '144354f7-4cfd-4248-a080-900c24abf337', '2026-07-02 02:46:34', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.477', 'https://i.pravatar.cc/150?img=21', 'https://i.pravatar.cc/150?img=21', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('08f10dc1-df62-42de-b7d8-f260a8fd4bbe', '827f1406-2c94-4298-833e-0a5994eedc3a', '2026-07-01 17:14:24', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.48', 'https://i.pravatar.cc/150?img=12', 'https://i.pravatar.cc/150?img=12', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('159881c3-7195-43a7-94d9-ecc117e82a15', '12d96e80-232d-4af0-b102-263dc9b2b56c', '2026-07-01 13:49:33', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.482', 'https://i.pravatar.cc/150?img=22', 'https://i.pravatar.cc/150?img=22', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('426e4e6f-d2d1-4b3d-84a9-11aaa31558de', '9ae62db5-7db1-46e1-ba35-1ce7ccdccfa7', '2026-07-01 13:39:26', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.484', 'https://i.pravatar.cc/150?img=23', 'https://i.pravatar.cc/150?img=23', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('796f725f-a015-40ea-8aff-ebc38b3e13c7', '827f1406-2c94-4298-833e-0a5994eedc3a', '2026-07-01 13:32:11', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.486', 'https://i.pravatar.cc/150?img=12', 'https://i.pravatar.cc/150?img=12', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('66fd3f60-6928-48a0-824c-0709a74ea68b', '65f27863-557b-480d-852c-f643942eedf1', '2026-07-01 13:21:18', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.489', 'https://i.pravatar.cc/150?img=24', 'https://i.pravatar.cc/150?img=24', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('70127ae1-2785-4633-add6-f1e06264dc69', '1f741933-1757-4eaa-8924-5c63cb513553', '2026-07-01 12:49:59', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.49', 'https://i.pravatar.cc/150?img=6', 'https://i.pravatar.cc/150?img=6', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('aab10aa5-e85f-4e97-a149-09ab752acb1b', '80b9d8b4-314d-4f92-901a-153aed109e21', '2026-07-01 12:28:41', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.493', 'https://i.pravatar.cc/150?img=18', 'https://i.pravatar.cc/150?img=18', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('f86dc34b-d938-4fe6-94ca-3a1a3eab8549', '1f741933-1757-4eaa-8924-5c63cb513553', '2026-07-01 12:10:51', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.494', 'https://i.pravatar.cc/150?img=6', 'https://i.pravatar.cc/150?img=6', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('8ab49a1e-1202-409c-b691-6045fe6195af', '1f741933-1757-4eaa-8924-5c63cb513553', '2026-07-01 11:55:09', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.496', 'https://i.pravatar.cc/150?img=6', 'https://i.pravatar.cc/150?img=6', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('2c129278-496c-4e9b-9389-50e8e34f79d8', '645ac7c3-8e8b-4a96-9f48-f6de9d8906b4', '2026-07-01 11:39:59', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.498', 'https://i.pravatar.cc/150?img=19', 'https://i.pravatar.cc/150?img=19', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('a78c9305-7c65-4f8e-94c0-453a9f4895ea', 'd4be9216-33a4-4c31-bcd6-adac3e1d1c9d', '2026-07-01 11:14:15', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.5', 'https://i.pravatar.cc/150?img=25', 'https://i.pravatar.cc/150?img=25', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('b6e36f91-434a-4ea9-8c5f-cc618f7387de', '8639522e-c105-4659-a0b0-8498fb5eae74', '2026-07-01 11:01:51', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.502', 'https://i.pravatar.cc/150?img=26', 'https://i.pravatar.cc/150?img=26', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('af1f68b7-b4a1-4278-8ecb-bb565c20fbcc', 'b528b432-c5aa-428c-ab46-557819a78397', '2026-07-01 10:43:48', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.504', 'https://i.pravatar.cc/150?img=16', 'https://i.pravatar.cc/150?img=16', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('c1728909-4202-4e27-a23f-aa9bfe6d7a9b', 'b528b432-c5aa-428c-ab46-557819a78397', '2026-07-01 08:47:23', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.506', 'https://i.pravatar.cc/150?img=16', 'https://i.pravatar.cc/150?img=16', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('43366337-18a4-4e78-ad7d-9f2e286aae4d', '80b9d8b4-314d-4f92-901a-153aed109e21', '2026-07-01 04:32:17', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.508', 'https://i.pravatar.cc/150?img=18', 'https://i.pravatar.cc/150?img=18', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('67abd694-fd0c-4954-8786-919b0a64c81a', 'f3f77a33-f77d-47a5-aae4-6caa23ba045f', '2026-07-01 04:23:09', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.509', 'https://i.pravatar.cc/150?img=7', 'https://i.pravatar.cc/150?img=7', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('39c99db5-7162-40ae-9b44-545efaf3493a', 'f3f77a33-f77d-47a5-aae4-6caa23ba045f', '2026-07-01 04:20:04', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.511', 'https://i.pravatar.cc/150?img=7', 'https://i.pravatar.cc/150?img=7', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('1344c42e-6823-47fd-acc9-7e573339d497', 'f3f77a33-f77d-47a5-aae4-6caa23ba045f', '2026-07-01 04:08:23', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.513', 'https://i.pravatar.cc/150?img=7', 'https://i.pravatar.cc/150?img=7', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('29d4111a-e426-4602-84be-bb67da6b5883', 'f3f77a33-f77d-47a5-aae4-6caa23ba045f', '2026-07-01 03:52:59', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.515', 'https://i.pravatar.cc/150?img=7', 'https://i.pravatar.cc/150?img=7', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('fd0b8e2a-c654-4f75-aa0a-525d7a693c33', '41acd095-c8f8-48ac-9827-457c55d91b55', '2026-07-01 01:03:56', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.516', 'https://i.pravatar.cc/150?img=27', 'https://i.pravatar.cc/150?img=27', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('10199c3d-4531-41b0-bde1-756b46dea565', '1f741933-1757-4eaa-8924-5c63cb513553', '2026-07-01 01:03:32', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.518', 'https://i.pravatar.cc/150?img=6', 'https://i.pravatar.cc/150?img=6', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('0dd10968-64aa-4306-8d1c-3d5d76946134', '1f741933-1757-4eaa-8924-5c63cb513553', '2026-06-30 23:54:40', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.52', 'https://i.pravatar.cc/150?img=6', 'https://i.pravatar.cc/150?img=6', 'Lamduan 3 Dormitory');
INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at, photo_url, scan_photo_url, gate_name_en) VALUES ('6f2fada4-3de6-4a8a-9b1a-c7e60dbf308d', '1f741933-1757-4eaa-8924-5c63cb513553', '2026-06-30 17:02:12', 'IN', 'หอพักลำดวน 3', '2026-07-08 13:38:52.522', 'https://i.pravatar.cc/150?img=6', 'https://i.pravatar.cc/150?img=6', 'Lamduan 3 Dormitory');


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
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('356eaaba-11ec-43fc-af48-35071abf8639', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-05 05:57:12.7', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('93ad7964-75da-4aee-b168-a0d320732a37', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-05 06:00:46.755', '1149900859119');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('a3bafeb8-85c2-4ab7-9f5b-68808e0bf1f8', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-06 15:01:32.099', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('59cc020d-7411-4695-ba23-b5a573a93f90', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-06 15:01:46.534', '1149900859119');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('fae8e81f-7dc1-49d6-84d2-6175fb37fb05', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-06 16:54:27.61', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('95b09c05-2d42-4e8e-862d-cf2ded9882e3', NULL, 'DENIED', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-06 16:55:27.676', '3101401511876');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('2dcbe64b-d3ca-4993-8627-af67c342b823', '8bb210f9-9a7d-45e2-a8ad-171e22ef6fa0', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-06 16:55:48.937', '3301201232653');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('cdc512db-876b-43b2-92bb-bc622afefdc8', '8bb210f9-9a7d-45e2-a8ad-171e22ef6fa0', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-06 16:56:14.905', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('145eb554-f364-4cf6-9e5e-97dfecf579e8', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-06 16:56:28.471', '1149900859119');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('4c12a8a3-2242-4b8f-bc04-b23991f1249b', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGOUT', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-08 09:05:15.593', NULL);
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('f63e9569-b1a9-4d45-b53e-5e16654ada5b', NULL, 'DENIED', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-10 15:38:41.253', '1234567890121');
INSERT INTO public.auth_logs (id, parent_id, event, ip_address, user_agent, created_at, citizen_id) VALUES ('89e3457a-e6e3-4f5f-b0ea-4885b95759d9', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'LOGIN', '::ffff:127.0.0.1', 'Dart/3.11 (dart:io)', '2026-07-10 15:39:04.578', '1149900859119');


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.devices (id, parent_id, fcm_token, created_at, updated_at) VALUES ('ebab07c0-1290-43a5-9130-279a8d09f308', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'epPlQ_O_TKWsdiEaXBSMG8:APA91bFU2qF2ihuleHmjkPmIX4BWwD36obrJmrQn1rOj9mfFwPZzisLz0CStFeMkzwEuBCCxSxv_Ikql7kgdaasSF-_RPtKnIyG3quhHgbJ3TRAtBF76k8s', '2026-06-30 14:33:33.071', '2026-07-06 14:43:32.395');
INSERT INTO public.devices (id, parent_id, fcm_token, created_at, updated_at) VALUES ('b340a6f2-d88a-42bf-8710-96c9ca371dec', '0b689281-ea71-4a2f-8734-d1aea51a0e73', 'cynCP2oCR7aFEN44UoDEuE:APA91bH33w6qORF6_uF0lrT5Ao3ZFEySKMrXFUIN067rZZEEF3v00_qqWojZIhVHUxALEIbAmFuNLQ9HO6S7q5sosj41uGH_tQM4MSdZY3iBRPobHBOGIMw', '2026-07-10 15:39:10.704', '2026-07-10 15:39:10.704');


--
-- Data for Name: parent_student_registry; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('342af411-3e47-40f2-b05f-f9f06d261a25', '1149900859119', '827f1406-2c94-4298-833e-0a5994eedc3a', 'FATHER', '2026-07-08 13:38:52.524', '2026-07-08 13:38:52.524');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('80472563-ba3e-4823-8794-cbc6dca9f024', '1149900859119', 'ddd9e728-05e4-4b4c-a06a-0910f2453d9a', 'FATHER', '2026-07-08 13:38:52.527', '2026-07-08 13:38:52.527');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('f6554ac4-d26d-4cf5-9118-46bb279b0e2f', '3301201232653', '935a4b5d-3593-4fad-b490-e2c368fae820', 'MOTHER', '2026-07-08 13:38:52.529', '2026-07-08 13:38:52.529');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('67b33675-6d1c-4423-a796-fd9a50841a82', '3640400263229', '645ac7c3-8e8b-4a96-9f48-f6de9d8906b4', 'FATHER', '2026-07-08 13:38:52.53', '2026-07-08 13:38:52.53');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('dc7588bd-3659-4da0-98d6-3f13686929c2', '3101401511876', '1f741933-1757-4eaa-8924-5c63cb513553', 'GUARDIAN', '2026-07-08 13:38:52.53', '2026-07-08 13:38:52.53');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('93838dc3-c39d-4405-a524-c44657bbfcee', '3400700708503', '2935b97a-ac1b-4006-95e4-9d0d83c82269', 'FATHER', '2026-07-08 13:38:52.531', '2026-07-08 13:38:52.531');
INSERT INTO public.parent_student_registry (id, parent_citizen_id, student_id, relationship, created_at, updated_at) VALUES ('288da1da-39f3-4b2e-a5d1-b99be75b4f01', '1141400113455', '633f493a-ff64-47ae-a5bb-ea7498ad446a', 'MOTHER', '2026-07-08 13:38:52.532', '2026-07-08 13:38:52.532');


--
-- Data for Name: parents; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.parents (id, name, is_verified, created_at, updated_at, thaid_sub, identity_provider, citizen_id) VALUES ('0769db6b-3fe7-4286-93c7-067d364259b9', 'ชื่อตัว ชื่อกลาง ชื่อสกุล', true, '2026-06-30 16:49:20.078', '2026-07-03 12:48:52', '3640400263229', 'THAID', '3640400263229');
INSERT INTO public.parents (id, name, is_verified, created_at, updated_at, thaid_sub, identity_provider, citizen_id) VALUES ('8bb210f9-9a7d-45e2-a8ad-171e22ef6fa0', 'ชื่อตัว ชื่อกลาง ชื่อสกุล', true, '2026-07-03 12:49:40.732', '2026-07-06 16:55:48.933', '3301201232653', 'THAID', '3301201232653');
INSERT INTO public.parents (id, name, is_verified, created_at, updated_at, thaid_sub, identity_provider, citizen_id) VALUES ('0b689281-ea71-4a2f-8734-d1aea51a0e73', 'ชื่อตัว ชื่อกลาง ชื่อสกุล', true, '2026-06-30 14:30:54.823', '2026-07-10 15:39:04.556', '1149900859119', 'THAID', '1149900859119');


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('1f741933-1757-4eaa-8924-5c63cb513553', '6632714510', '6632714510', 'เฉิน เจ๋อหย่วน', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3102', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632714510', 'Chen Zheyuan', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('580e48c6-23fa-415e-a5c9-db9d9581d243', '6533912099', '6533912099', 'ภูริณัฐ บุญมาก', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3103', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533912099', 'Phurinat Boonmak', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('b528b432-c5aa-428c-ab46-557819a78397', '6332517021', '6332517021', 'ต้วน เจียซวี่', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3104', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6332517021', 'Duan Jiaxu', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('856d28b5-03cc-4801-aff6-27298b16d2ad', '6433112650', '6433112650', 'สุพิชญา มูลใจ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3104', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6433112650', 'Supichaya Moonjai', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('41acd095-c8f8-48ac-9827-457c55d91b55', '6632712138', '6632712138', 'นายกรัฐมนตรี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3105', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632712138', 'Nayok Ratthamontri', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('60c156a5-45e8-4e93-8fa5-d300c54fee16', '6632714141', '6632714141', 'โจวจื่อฮ่าว', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3105', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632714141', 'Zhou Zihao', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('84485a84-778f-4b07-8de2-ab773d734d65', '6632714145', '6632714145', 'ณิชาภัทร ธรรมโชติ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3105', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632714145', 'Nichaphat Thammachot', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('86e01337-484e-4e90-a8b1-03b973095bf8', '6633317079', '6633317079', 'วริศรา สุขสวัสดิ์', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3105', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633317079', 'Waritsara Suksawat', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('a5e58fd5-684a-493c-9734-2c2067712a65', '6632817059', '6632817059', 'ธมลวรรณ ศรีสุวรรณ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3108', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632817059', 'Thamonwan Srisuwan', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('51c74202-43cd-4c6e-852f-2e7e0971dc7e', '6532721139', '6532721139', 'ภูริณัฐ คำแสน', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3109', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6532721139', 'Phurinat Khamsaen', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('aeb31c7c-6511-4a3e-896a-0724aaae0157', '6533014154', '6533014154', 'จางเหวินเจี๋ย', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3109', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533014154', 'Zhang Wenjie', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('0e9e2f06-5ac7-45f6-be22-a1509956661a', '6533012236', '6533012236', 'รัชชานนท์ ใจดี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3110', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533012236', 'Ratchanon Jaidee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('827f1406-2c94-4298-833e-0a5994eedc3a', '6632714529', '6632714529', 'ติ้งหวัง', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3110', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632714529', 'Ding Wang', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('17a7d442-98ad-4d40-b7fc-e982ee038900', '6633315067', '6633315067', 'หยางหยาง', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3110', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633315067', 'Yang Yang', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('50ec20d0-b301-4fa0-bca4-f4269a79e2e9', '6632714056', '6632714056', 'ชาลิสา อินทร์ตา', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3111', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632714056', 'Chalisa Inta', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('37a9e1d1-0c23-461a-bd85-e1605465f146', '6632718057', '6632718057', 'หวังเฮ่อตี้', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3111', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632718057', 'Wang Hedi', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('2935b97a-ac1b-4006-95e4-9d0d83c82269', '6433112453', '6433112453', 'หวังซิงเยว่', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3112', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6433112453', 'Wang Xingyue', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('c0ddd1f4-96cd-43fb-87c8-5f719563f827', '6533014124', '6533014124', 'หลินเสี่ยวหมิ่น', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3112', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533014124', 'Lin Xiaomin', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('27427124-a741-4dac-a39f-731c399a7b59', '6632517077', '6632517077', 'สุพิชญา เชียงแขก', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3113', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632517077', 'Supichaya Chiangkhaek', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('12d96e80-232d-4af0-b102-263dc9b2b56c', '6633913033', '6633913033', 'หลินอี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3113', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633913033', 'Lin Yi', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('65f27863-557b-480d-852c-f643942eedf1', '6432721020', '6432721020', 'Jackson ma', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3114', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6432721020', 'Jackson Ma', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('935a4b5d-3593-4fad-b490-e2c368fae820', '6632716037', '6632716037', 'จางหลิงเฮ่อ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3114', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632716037', 'Zhang Linghe', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('025dcb9b-2115-443d-b35a-9f8a3e05daa3', '6633812028', '6633812028', 'ณิชาภัทร ปัญญาดี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3114', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633812028', 'Nichaphat Panyadee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('7cb85572-55c0-4d07-8325-d8b6e50c8d19', '6633812034', '6633812034', 'น้ำไม่ไหล ไฟไม่มา', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3114', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633812034', 'Nam Mailai Faimaima', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('27fecc44-36e9-4122-90a5-45acc7b1f0cf', '6532817079', '6532817079', 'พิซซ่า หน้าตลาด', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3115', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6532817079', 'Pizza Natalad', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('ddd9e728-05e4-4b4c-a06a-0910f2453d9a', '6532817089', '6532817089', 'ฝนตก ตามฤดู', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3115', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6532817089', 'Fontok Tamruedu', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('26213892-50e2-422a-8f25-37863c6d27ba', '6532817091', '6532817091', 'ฝนตก ตามฤดู', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3115', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6532817091', 'Fontok Tamruedu', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('633f493a-ff64-47ae-a5bb-ea7498ad446a', '6533412057', '6533412057', 'หวังฉู่หรัน', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3115', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533412057', 'Wang Churan', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('f3f77a33-f77d-47a5-aae4-6caa23ba045f', '6432716110', '6432716110', 'ตี้เร่อปา', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3117', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6432716110', 'Dilraba', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('645ac7c3-8e8b-4a96-9f48-f6de9d8906b4', '6633013031', '6633013031', 'จ้าวลู่ซือ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3118', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633013031', 'Zhao Lusi', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('144354f7-4cfd-4248-a080-900c24abf337', '6633014028', '6633014028', 'ไป๋จิ้งถิง', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3118', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633014028', 'Bai Jingting', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('4dd818f5-9553-4840-b273-52fe39d2f082', '6632713079', '6632713079', 'หวงจิ่งอวี๋', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3119', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632713079', 'Huang Jingyu', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('9ae62db5-7db1-46e1-ba35-1ce7ccdccfa7', '6633915034', '6633915034', 'เฉิอเข่อจิง', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3119', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633915034', 'Chen Kejing', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('8639522e-c105-4659-a0b0-8498fb5eae74', '6633915074', '6633915074', 'จวีจิ้งอี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3119', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633915074', 'Ju Jingyi', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('d4be9216-33a4-4c31-bcd6-adac3e1d1c9d', '6633915115', '6633915115', 'จางรั่วหนาน', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3119', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633915115', 'Zhang Ruonan', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('80b9d8b4-314d-4f92-901a-153aed109e21', '6632517120', '6632517120', 'ไป๋ลู่', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3120', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632517120', 'Bai Lu', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('d3699d98-4c69-471e-a306-9a06c5ac46d3', '6633412119', '6633412119', 'พิมพ์ชนก เชียงแขก', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3120', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633412119', 'Pimchanok Chiangkhaek', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('c348a3cc-cddc-4534-851b-62c78daf3595', '6532812144', '6532812144', 'ศุภกร ธรรมโชติ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3121', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6532812144', 'Supakorn Thammachot', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('64071844-b668-4796-8e44-a3e14528b09d', '6533112397', '6533112397', 'เตชินท์ บุญมาก', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3121', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533112397', 'Techin Boonmak', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('d7e52ca4-727b-485c-8fe2-f5666299ac63', '6433014011', '6433014011', 'ปุณณวิช แก้วมณี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3201', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6433014011', 'Punnawich Kaewmanee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('ffac4c9b-79a6-46dd-b56f-e82780a2464e', '6433014051', '6433014051', 'ณิชาภัทร แก้วมณี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3201', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6433014051', 'Nichaphat Kaewmanee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('6c8f91eb-557a-4780-a398-136e430b3a20', '6433014127', '6433014127', 'หลี่เจียหมิง', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3201', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6433014127', 'Li Jiaming', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('23d5db1b-80cb-4549-b6f9-abcdf6f7a525', '6433014136', '6433014136', 'อริสรา คำแสน', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3201', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6433014136', 'Arisara Khamsaen', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('9b6dfce3-cdcc-4eb7-b942-81f9d7d1d5ef', '6534013010', '6534013010', 'รัชชานนท์ สุขสวัสดิ์', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3202', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6534013010', 'Ratchanon Suksawat', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('2f952291-16d7-4fa8-9f09-0a3e0fcbd0f6', '6533014193', '6533014193', 'ณิชาภัทร บุญมาก', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3203', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533014193', 'Nichaphat Boonmak', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('7bd93be6-a08c-4756-a417-27bfb28d8b1a', '6632714531', '6632714531', 'ณิชาภัทร นามวงศ์', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3203', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632714531', 'Nichaphat Namwong', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('f476cff2-f75e-4089-b164-e9fc62d4deef', '6633317032', '6633317032', 'วริศรา อินทร์ตา', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3203', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633317032', 'Waritsara Inta', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('83837cec-a64e-4ccf-b45e-2392b49f577f', '6634012045', '6634012045', 'พชร มูลใจ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3203', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6634012045', 'Phachara Moonjai', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('a170b31d-0367-4b40-b12e-fd8b0df66fa1', '6534012011', '6534012011', 'ชาลิสา คำแสน', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3204', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6534012011', 'Chalisa Khamsaen', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('284c5d14-90aa-4bf7-92a5-ba83de9605e0', '6534012016', '6534012016', 'กิตติพศ นามวงศ์', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3204', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6534012016', 'Kittiphot Namwong', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('75653061-f650-4cd9-b8d6-543e86c7c29a', '6633317012', '6633317012', 'สุพิชญา พรมมา', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3204', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633317012', 'Supichaya Promma', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('bdce0832-3f36-4717-8cef-1941a43a4266', '6633112276', '6633112276', 'นภัสสร แก้วมณี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3206', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633112276', 'Napatsorn Kaewmanee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('da54c311-0456-4eef-b627-6101fbc072e9', '6634013062', '6634013062', 'อริสรา อินทร์ตา', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3206', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6634013062', 'Arisara Inta', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('e840a406-c4c9-48cf-aadd-e104c7fa22b3', '6532714157', '6532714157', 'ปุณณวิช มูลใจ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3207', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6532714157', 'Punnawich Moonjai', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('052b0843-442c-4716-81d8-6dd728238093', '6633014025', '6633014025', 'รัชชานนท์ ธรรมโชติ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3207', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633014025', 'Ratchanon Thammachot', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('9d81030d-a48c-4541-aaaf-5f5c5ee6fbdf', '6532718062', '6532718062', 'ธมลวรรณ สุขสวัสดิ์', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3208', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6532718062', 'Thamonwan Suksawat', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('0e1c3edb-be39-4d5e-a4bc-e01c413b70e7', '6533012122', '6533012122', 'เฉินซือหยู', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3208', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533012122', 'Chen Siyu', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('a167eb15-c30f-43da-a70a-3b31dfc00ec0', '6633112198', '6633112198', 'ณิชาภัทร คำแสน', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3208', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633112198', 'Nichaphat Khamsaen', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('553b214c-aecd-4c34-b71d-23bf35fad228', '6433112370', '6433112370', 'อริสรา แก้วมณี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3209', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6433112370', 'Arisara Kaewmanee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('62dbbd28-1bdf-4307-84d7-55741223b2e7', '6433112487', '6433112487', 'ศศิกานต์ เชียงแขก', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3209', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6433112487', 'Sasikan Chiangkhaek', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('4764fda6-0aff-496d-bdee-745f9e4e5263', '6532720085', '6532720085', 'พิมพ์ชนก พรมมา', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3210', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6532720085', 'Pimchanok Promma', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('095c7b24-5a8b-42e1-9eba-d1fdee07f75e', '6532817123', '6532817123', 'เหอเหม่ยหลิง', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3210', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6532817123', 'He Meiling', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('8f1f4966-52b4-4938-827b-080fd1338e5e', '6533012130', '6533012130', 'อริสรา ทาคำ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3210', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533012130', 'Arisara Thakham', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('cecf1aef-b4ec-4e28-8e4b-f0d61e91f29f', '6533112011', '6533112011', 'กัญญาณัฐ คำแสน', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3210', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533112011', 'Kanyanat Khamsaen', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('4ddf1334-8340-494f-8d40-44f746926890', '6533014072', '6533014072', 'สวี่จิงอี้', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3211', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533014072', 'Xu Jingyi', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('09baf941-3d6f-4f99-9f98-0236d4f92022', '6633014047', '6633014047', 'พชร ศรีสุวรรณ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3211', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633014047', 'Phachara Srisuwan', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('acadfc39-78f2-4fa7-af4c-0c99f66c2724', '6432613040', '6432613040', 'สุพิชญา บุญมาก', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3212', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6432613040', 'Supichaya Boonmak', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('8dbbe093-a66a-431c-8666-a8c0af92dfd3', '6532817039', '6532817039', 'ธนกฤต ธรรมโชติ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3212', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6532817039', 'Thanakrit Thammachot', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('0477726c-13dc-43d2-8498-beb958f7d6e5', '6633117043', '6633117043', 'นภัสสร มูลใจ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3212', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633117043', 'Napatsorn Moonjai', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('ae532c10-2790-4e5a-a530-964533f8a323', '6633012183', '6633012183', 'ปุณณวิช ใจดี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3213', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633012183', 'Punnawich Jaidee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('b4858f48-d401-412e-81d3-282c125fa9b3', '6633012185', '6633012185', 'รัชชานนท์ บุญมาก', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3213', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633012185', 'Ratchanon Boonmak', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('3fa5941b-77bc-488c-8945-826bba5d3978', '6633012194', '6633012194', 'ชาลิสา สุขสวัสดิ์', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3213', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633012194', 'Chalisa Suksawat', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('4b36ecda-76ec-464c-aaa5-c1f5da511c70', '6533112165', '6533112165', 'ธมลวรรณ บุญมาก', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3214', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533112165', 'Thamonwan Boonmak', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('d3cb50e8-b689-4fdc-ba30-a4bf66654a14', '6632817049', '6632817049', 'พชร แก้วมณี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3214', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632817049', 'Phachara Kaewmanee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('97c62353-3f22-4f63-9190-a3c46ce0b3aa', '6532616017', '6532616017', 'ศุภกร นามวงศ์', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3215', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6532616017', 'Supakorn Namwong', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('d4517ef3-a68e-41fc-a98d-37511ad8a1f1', '6533112324', '6533112324', 'ภูริณัฐ แก้วมณี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3216', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533112324', 'Phurinat Kaewmanee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('19a02e9e-1424-464a-9959-907f8000a5f0', '6533317054', '6533317054', 'กิตติพศ ใจดี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3216', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533317054', 'Kittiphot Jaidee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('ffea9bc1-3250-49dd-a8a4-768b17db0155', '6433012126', '6433012126', 'ณัฐภัทร ปัญญาดี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3217', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6433012126', 'Natthaphat Panyadee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('b383f1c3-4830-4804-b0d0-8581a3aa9fe0', '6632718011', '6632718011', 'พชร ทาคำ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3217', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632718011', 'Phachara Thakham', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('6f2c3890-fad8-44e0-8986-90bd047cfda7', '6633913076', '6633913076', 'เกาเทียนอวี่', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3217', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633913076', 'Gao Tianyu', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('0d0a5fb3-827c-42b5-abbe-676d76f35023', '6632517055', '6632517055', 'ภูริณัฐ อินทร์ตา', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3218', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632517055', 'Phurinat Inta', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('ee1f9f7c-1848-4ef6-87be-83c3f7d7361b', '6632720024', '6632720024', 'สุพิชญา ใจดี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3218', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632720024', 'Supichaya Jaidee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('c9e9d8a7-05fe-454f-9bdb-7f9da8f9da0d', '6632812046', '6632812046', 'ปุณณวิช ศรีสุวรรณ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3218', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632812046', 'Punnawich Srisuwan', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('8611675b-469e-4d9f-90dc-1061459d92c3', '6632817126', '6632817126', 'ศศิกานต์ ศรีสุวรรณ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3218', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632817126', 'Sasikan Srisuwan', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('2a61d4e5-9f55-461b-badb-82c2f42708ab', '6633112221', '6633112221', 'จิรายุ คำแสน', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3219', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633112221', 'Jirayu Khamsaen', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('d90dd46d-d81b-421b-afb4-c8ea1070506f', '6432718073', '6432718073', 'ณัฐภัทร พรมมา', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3220', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6432718073', 'Natthaphat Promma', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('ed6198d6-ea1a-47ef-9305-433bebf287d2', '6633112331', '6633112331', 'เตชินท์ แก้วมณี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3220', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633112331', 'Techin Kaewmanee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('028c0545-ee65-4279-bb51-a43802a897e9', '6633912043', '6633912043', 'กิตติพศ วงศ์ษา', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3220', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633912043', 'Kittiphot Wongsa', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('d6e68f85-1abb-443a-b790-1f98f755ed59', '6534013029', '6534013029', 'ธมลวรรณ วงศ์ษา', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3221', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6534013029', 'Thamonwan Wongsa', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('ada5fe3e-cee9-4195-bdd4-32b1ac3b4932', '6632720071', '6632720071', 'ธมลวรรณ พรมมา', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3222', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632720071', 'Thamonwan Promma', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('6444d92d-fcca-4905-b2e5-5a436b1da882', '6633012120', '6633012120', 'ชาลิสา พรมมา', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3222', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633012120', 'Chalisa Promma', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('6f247ee9-6434-4f36-a953-9ec075615c18', '6633012188', '6633012188', 'ภูริณัฐ ใจดี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3222', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633012188', 'Phurinat Jaidee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('e57da9e6-a588-4853-b63a-5111a0f7987f', '6633014053', '6633014053', 'จิรายุ มูลใจ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3222', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633014053', 'Jirayu Moonjai', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('18026507-abac-4570-b57b-d8fb022bb6e7', '6533319514', '6533319514', 'กัญญาณัฐ อินทร์ตา', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3223', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533319514', 'Kanyanat Inta', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('d434585c-54d3-4239-99c2-cd0ff4e96999', '6433915070', '6433915070', 'กิตติพศ บุญมาก', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3224', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6433915070', 'Kittiphot Boonmak', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('8e9c07eb-8fee-4a39-ae95-747cbdbfb41f', '6433915168', '6433915168', 'ภูริณัฐ มูลใจ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3224', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6433915168', 'Phurinat Moonjai', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('9f81b269-2c93-413c-b42b-6c3e24f4cfc2', '6633117036', '6633117036', 'ศศิกานต์ ทาคำ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3224', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633117036', 'Sasikan Thakham', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('dd1ccd66-908d-4489-b42f-451d711fcc96', '6533317071', '6533317071', 'ธมลวรรณ ใจดี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3226', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533317071', 'Thamonwan Jaidee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('9674d5e0-061b-4534-9d3a-e0fbdbbc88aa', '6533317094', '6533317094', 'สุพิชญา นามวงศ์', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3226', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533317094', 'Supichaya Namwong', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('f6f4277e-2631-4312-aa6c-6d8b80a44510', '6332718081', '6332718081', 'ศุภกร ปัญญาดี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3301', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6332718081', 'Supakorn Panyadee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('e27f55f3-481d-4e7e-a367-ab4f70a5e00a', '6633012197', '6633012197', 'เตชินท์ ปัญญาดี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3306', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633012197', 'Techin Panyadee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('0f54d2cb-ea78-4d6c-ac62-f9253c7f70ca', '6632714191', '6632714191', 'ศุภกร แก้วมณี', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3321', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632714191', 'Supakorn Kaewmanee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('6f5f2321-a931-4322-810a-ecc371195876', '6633318031', '6633318031', 'พิมพ์ชนก ศรีสุวรรณ', '2026-07-08 13:38:52.378', 'ลำดวน 3', '3321', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633318031', 'Pimchanok Srisuwan', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('e8f79859-83c2-45db-9312-50bef87b0e7b', '6632718073', '6632718073', 'ชาลิสา มูลใจ', '2026-07-08 13:38:52.378', 'ลำดวน 3', 'L3 3102', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632718073', 'Chalisa Moonjai', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('99033565-e35c-468e-af5a-5afa1850c519', '6433112041', '6433112041', 'หลิวหย่าถิง', '2026-07-08 13:38:52.378', 'ลำดวน 3', 'L3 3103', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6433112041', 'Liu Yating', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('758d943b-8e52-433d-b463-8d7bfe164a54', '6432517113', '6432517113', 'นภัสสร สุขสวัสดิ์', '2026-07-08 13:38:52.378', 'ลำดวน 3', 'L3 3117', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6432517113', 'Napatsorn Suksawat', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('df54e404-6226-4503-ad35-7d742da2050f', '6633112119', '6633112119', 'ศุภกร ใจดี', '2026-07-08 13:38:52.378', 'ลำดวน 3', 'L3 3118', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633112119', 'Supakorn Jaidee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('9ef58ebd-5844-4883-acf1-d530b171aa6a', '6632517097', '6632517097', 'พิมพ์ชนก ใจดี', '2026-07-08 13:38:52.378', 'ลำดวน 3', 'L3 3202', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6632517097', 'Pimchanok Jaidee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('3512b7e6-3f13-4dac-ba68-141738e81054', '6633112177', '6633112177', 'ธมลวรรณ ทาคำ', '2026-07-08 13:38:52.378', 'ลำดวน 3', 'L3 3202', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633112177', 'Thamonwan Thakham', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('e672bd52-931b-46c4-9a8f-272129e21b64', '6433315018', '6433315018', 'รัชชานนท์ เชียงแขก', '2026-07-08 13:38:52.378', 'ลำดวน 3', 'L3 3207', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6433315018', 'Ratchanon Chiangkhaek', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('3b614e4a-0982-423c-8c4a-28e7aa70f7b3', '6633812011', '6633812011', 'วริศรา แก้วมณี', '2026-07-08 13:38:52.378', 'ลำดวน 3', 'L3 3209', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633812011', 'Waritsara Kaewmanee', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('d2546041-110e-4bc0-af68-3d33b4a3599c', '6633812099', '6633812099', 'หวังอี้ห่าน', '2026-07-08 13:38:52.378', 'ลำดวน 3', 'L3 3209', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633812099', 'Wang Yihan', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('ed04d26f-8343-4743-903e-d59840b9f5ff', '6633012196', '6633012196', 'พิมพ์ชนก ธรรมโชติ', '2026-07-08 13:38:52.378', 'ลำดวน 3', 'L3 3213', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633012196', 'Pimchanok Thammachot', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('aef793a9-564e-4e53-8e55-b6450497d4cd', '6533014163', '6533014163', 'ณิชาภัทร เชียงแขก', '2026-07-08 13:38:52.378', 'ลำดวน 3', 'L3 3214', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533014163', 'Nichaphat Chiangkhaek', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('17373262-e038-4df6-8ca6-2b464e592dd4', '6533812081', '6533812081', 'รัชชานนท์ วงศ์ษา', '2026-07-08 13:38:52.378', 'ลำดวน 3', 'L3 3220', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6533812081', 'Ratchanon Wongsa', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('95270ee5-d558-429c-8abb-509dd2f91270', '6434013037', '6434013037', 'ศุภกร คำแสน', '2026-07-08 13:38:52.378', 'ลำดวน 3', 'L3 3221', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6434013037', 'Supakorn Khamsaen', 'Lamduan 3');
INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number, left_at, status, updated_at, photo_url, name_en, dormitory_en) VALUES ('24cd3bdd-d8bd-48c5-8d55-52f5fefa677b', '6633014138', '6633014138', 'รัชชานนท์ ทาคำ', '2026-07-08 13:38:52.378', 'ลำดวน 3', 'L3 3306', NULL, 'ACTIVE', '2026-07-08 13:38:52.378', 'https://api.dicebear.com/9.x/adventurer/png?size=150&seed=6633014138', 'Ratchanon Thakham', 'Lamduan 3');


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

\unrestrict ERn0fWYOeRssuHvM2nMpYgzb5l7TP5A32iS0nagrdEcg8iVN5Pc2SeXIHIuJxZ7


-- 1. ล้างข้อมูลเก่า (หากมีตารางชื่อเดียวกันอยู่ก่อนแล้ว เพื่อป้องกันตารางซ้ำ)
DROP TABLE IF EXISTS public.devices CASCADE;
DROP TABLE IF EXISTS public.access_logs CASCADE;
DROP TABLE IF EXISTS public.parent_student_mapping CASCADE;
DROP TABLE IF EXISTS public.parents CASCADE;
DROP TABLE IF EXISTS public.students CASCADE;

DROP TYPE IF EXISTS public."AccessType" CASCADE;
DROP TYPE IF EXISTS public."IdentityProvider" CASCADE;

-- 2. สร้างโครงสร้างพื้นฐาน (Enums และ การตั้งค่าระบบ)
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

CREATE TYPE public."AccessType" AS ENUM ('IN', 'OUT');
ALTER TYPE public."AccessType" OWNER TO postgres;

CREATE TYPE public."IdentityProvider" AS ENUM ('LOCAL', 'THAID');
ALTER TYPE public."IdentityProvider" OWNER TO postgres;

SET default_tablespace = '';
SET default_table_access_method = heap;

-- 3. สร้างตารางทั้งหมด (Tables)
CREATE TABLE public.access_logs (
    id text NOT NULL,
    student_id text NOT NULL,
    access_time timestamp(3) without time zone NOT NULL,
    type public."AccessType" NOT NULL,
    gate_name text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
ALTER TABLE public.access_logs OWNER TO postgres;

CREATE TABLE public.devices (
    id text NOT NULL,
    parent_id text NOT NULL,
    fcm_token text NOT NULL,
    created_at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp(3) without time zone NOT NULL
);
ALTER TABLE public.devices OWNER TO postgres;

CREATE TABLE public.parent_student_mapping (
    id text NOT NULL,
    parent_id text NOT NULL,
    student_id text NOT NULL
);
ALTER TABLE public.parent_student_mapping OWNER TO postgres;

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

-- 4. ยัดข้อมูลตัวอย่างทั้งหมดเข้าตาราง (Insert Data)
INSERT INTO public.parents (id, name, phone, email, password_hash, thaid_sub, identity_provider, is_verified, created_at, updated_at) VALUES
('c6ca1b19-81fc-4fad-8f32-82a8bac641a3', 'Test1 Parent', '0811111111', 'test1@1.com', '$2b$12$Eh87LFeFMRziNj4983F7BObff4f8JWt0Z8BH2OYNLFZxT4jMBLdk2', NULL, 'LOCAL', false, '2026-05-23 10:58:57.182', '2026-05-23 10:58:57.182'),
('212f7cfa-a658-4c2a-9d1c-60a4c5fc76e1', 'Test2 Parent', '0811111112', 'test2@2.com', '$2b$12$18LNLDQxkR/hnip3S5vK9eFl4ykqcRa7na6PsOFsrcqft4N.0v9TK', NULL, 'LOCAL', false, '2026-05-23 10:59:09.848', '2026-05-23 10:59:09.848'),
('2ddc5c67-4ddf-41bb-9fc2-197ca1e4e44a', 'Test3 Parent', '0811111113', 'test3@3.com', '$2b$12$zPmjyxHbl2arLm3lPN.3YOnSvRYfiEOUKxXRj8h80iLPFr8hL9i6e', NULL, 'LOCAL', false, '2026-05-23 10:59:21.909', '2026-05-23 10:59:21.909');

INSERT INTO public.students (id, external_student_id, student_code, name, created_at, dormitory, room_number) VALUES
('051d442b-6927-4a35-9f80-9d94a0c524cc', 'T002', '6631501026', 'Araya Logniyom', '2026-05-20 15:29:27.118', 'Saktong3', '217'),
('7e1aa157-6c06-4c54-9fd2-25b5f6008e83', 'T001', '6631501163', 'Parichat Phojan', '2026-05-22 11:05:26.362', 'Saktong3', '127'),
('412c85e6-b25b-4759-9bee-87995b5d918b', 'T003', '6631501064', 'Nawamol Nuanyai', '2026-05-23 10:58:34.912', 'Saktong3', '712');

INSERT INTO public.parent_student_mapping (id, parent_id, student_id) VALUES
('c566f105-daf9-4e08-bb3a-138f3e977ee3', 'c6ca1b19-81fc-4fad-8f32-82a8bac641a3', '7e1aa157-6c06-4c54-9fd2-25b5f6008e83'),
('03d831a3-2a09-4f37-966e-371aa420ccca', '212f7cfa-a658-4c2a-9d1c-60a4c5fc76e1', '051d442b-6927-4a35-9f80-9d94a0c524cc'),
('dd90692b-ecd5-4cd7-8497-e57dba6b52fc', '2ddc5c67-4ddf-41bb-9fc2-197ca1e4e44a', '412c85e6-b25b-4759-9bee-87995b5d918b');

INSERT INTO public.access_logs (id, student_id, access_time, type, gate_name, created_at) VALUES
('4d88b174-cda5-4e1d-82d8-2b34b9673e33', '051d442b-6927-4a35-9f80-9d94a0c524cc', '2026-05-20 05:55:00', 'IN', 'Main Entrance', '2026-05-20 15:35:49.957'),
('30e9a35a-87b8-4c87-bb16-52193de740de', '051d442b-6927-4a35-9f80-9d94a0c524cc', '2026-05-20 16:55:00', 'IN', 'Main Entrance', '2026-05-20 15:54:14.988'),
('84e7a781-9f3a-485d-b45a-f0a1f0d75290', '051d442b-6927-4a35-9f80-9d94a0c524cc', '2026-05-23 05:55:00', 'IN', 'Main Entrance', '2026-05-23 06:32:31.484'),
('d91c249c-c8cf-483d-b31a-ecc08199da15', '7e1aa157-6c06-4c54-9fd2-25b5f6008e83', '2026-05-23 10:40:19', 'IN', 'Main Gate', '2026-05-23 10:40:19.119'),
('4dd2abf0-b445-4a4c-81da-fcbeeca2fc9a', '7e1aa157-6c06-4c54-9fd2-25b5f6008e83', '2026-05-23 10:41:20', 'OUT', 'Main Gate', '2026-05-23 10:41:20.35'),
('4b6819b6-1588-4b45-9167-9db63cf58677', '7e1aa157-6c06-4c54-9fd2-25b5f6008e83', '2026-05-23 10:46:38', 'IN', 'Main Gate', '2026-05-23 10:46:38.901'),
('4108fabc-3b1d-42ff-b876-d5c79ca55d50', '7e1aa157-6c06-4c54-9fd2-25b5f6008e83', '2026-05-23 11:00:55', 'IN', 'Main Gate', '2026-05-23 11:00:55.309');

-- 5. ผูก Keys, Constraints และสร้าาง Indexes (เพื่อความถูกต้องของฐานข้อมูล)
ALTER TABLE ONLY public.access_logs ADD CONSTRAINT access_logs_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.devices ADD CONSTRAINT devices_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.parent_student_mapping ADD CONSTRAINT parent_student_mapping_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.parents ADD CONSTRAINT parents_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.students ADD CONSTRAINT students_pkey PRIMARY KEY (id);

CREATE INDEX access_logs_student_id_access_time_idx ON public.access_logs USING btree (student_id, access_time DESC);
CREATE UNIQUE INDEX access_logs_student_id_access_time_type_key ON public.access_logs USING btree (student_id, access_time, type);
CREATE UNIQUE INDEX devices_fcm_token_key ON public.devices USING btree (fcm_token);
CREATE UNIQUE INDEX parent_student_mapping_parent_id_student_id_key ON public.parent_student_mapping USING btree (parent_id, student_id);
CREATE UNIQUE INDEX parents_email_key ON public.parents USING btree (email);
CREATE UNIQUE INDEX parents_phone_key ON public.parents USING btree (phone);
CREATE UNIQUE INDEX parents_thaid_sub_key ON public.parents USING btree (thaid_sub);
CREATE UNIQUE INDEX students_external_student_id_key ON public.students USING btree (external_student_id);
CREATE UNIQUE INDEX students_student_code_key ON public.students USING btree (student_code);

ALTER TABLE ONLY public.access_logs ADD CONSTRAINT access_logs_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE ONLY public.devices ADD CONSTRAINT devices_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parents(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.parent_student_mapping ADD CONSTRAINT parent_student_mapping_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parents(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public.parent_student_mapping ADD CONSTRAINT parent_student_mapping_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;

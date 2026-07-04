-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "IdentityProvider" AS ENUM ('LOCAL', 'THAID');

-- CreateEnum
CREATE TYPE "AuthEvent" AS ENUM ('LOGIN', 'LOGOUT', 'DENIED');

-- CreateEnum
CREATE TYPE "AccessType" AS ENUM ('IN', 'OUT');

-- CreateEnum
CREATE TYPE "StudentStatus" AS ENUM ('ACTIVE', 'GRADUATED', 'MOVED_OUT');

-- CreateEnum
CREATE TYPE "Relationship" AS ENUM ('FATHER', 'MOTHER', 'GUARDIAN', 'OTHER');

-- CreateTable
CREATE TABLE "parents" (
    "id" TEXT NOT NULL,
    "citizen_id" TEXT NOT NULL,
    "thaid_sub" TEXT,
    "name" TEXT NOT NULL,
    "identity_provider" "IdentityProvider" NOT NULL DEFAULT 'THAID',
    "is_verified" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "parents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "students" (
    "id" TEXT NOT NULL,
    "external_student_id" TEXT NOT NULL,
    "student_code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "dormitory" TEXT,
    "room_number" TEXT,
    "status" "StudentStatus" NOT NULL DEFAULT 'ACTIVE',
    "left_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "students_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "parent_student_registry" (
    "id" TEXT NOT NULL,
    "parent_citizen_id" TEXT NOT NULL,
    "student_id" TEXT NOT NULL,
    "relationship" "Relationship" NOT NULL DEFAULT 'GUARDIAN',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "parent_student_registry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "access_logs" (
    "id" TEXT NOT NULL,
    "student_id" TEXT NOT NULL,
    "access_time" TIMESTAMP(3) NOT NULL,
    "type" "AccessType" NOT NULL,
    "gate_name" TEXT NOT NULL,
    "photo_url" TEXT,
    "scan_photo_url" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "access_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "devices" (
    "id" TEXT NOT NULL,
    "parent_id" TEXT NOT NULL,
    "fcm_token" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "devices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_logs" (
    "id" TEXT NOT NULL,
    "parent_id" TEXT,
    "citizen_id" TEXT,
    "event" "AuthEvent" NOT NULL,
    "ip_address" TEXT,
    "user_agent" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "parents_citizen_id_key" ON "parents"("citizen_id");

-- CreateIndex
CREATE UNIQUE INDEX "parents_thaid_sub_key" ON "parents"("thaid_sub");

-- CreateIndex
CREATE UNIQUE INDEX "students_external_student_id_key" ON "students"("external_student_id");

-- CreateIndex
CREATE UNIQUE INDEX "students_student_code_key" ON "students"("student_code");

-- CreateIndex
CREATE INDEX "parent_student_registry_parent_citizen_id_idx" ON "parent_student_registry"("parent_citizen_id");

-- CreateIndex
CREATE UNIQUE INDEX "parent_student_registry_parent_citizen_id_student_id_key" ON "parent_student_registry"("parent_citizen_id", "student_id");

-- CreateIndex
CREATE INDEX "access_logs_student_id_access_time_idx" ON "access_logs"("student_id", "access_time" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "access_logs_student_id_access_time_type_key" ON "access_logs"("student_id", "access_time", "type");

-- CreateIndex
CREATE UNIQUE INDEX "devices_fcm_token_key" ON "devices"("fcm_token");

-- CreateIndex
CREATE INDEX "auth_logs_parent_id_created_at_idx" ON "auth_logs"("parent_id", "created_at" DESC);

-- AddForeignKey
ALTER TABLE "parent_student_registry" ADD CONSTRAINT "parent_student_registry_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "access_logs" ADD CONSTRAINT "access_logs_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "devices" ADD CONSTRAINT "devices_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "parents"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth_logs" ADD CONSTRAINT "auth_logs_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "parents"("id") ON DELETE CASCADE ON UPDATE CASCADE;


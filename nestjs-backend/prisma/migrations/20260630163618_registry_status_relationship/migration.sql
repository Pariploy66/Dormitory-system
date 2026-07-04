-- CreateEnum
CREATE TYPE "StudentStatus" AS ENUM ('ACTIVE', 'GRADUATED', 'MOVED_OUT');

-- CreateEnum
CREATE TYPE "Relationship" AS ENUM ('FATHER', 'MOTHER', 'GUARDIAN', 'OTHER');

-- AlterEnum
ALTER TYPE "AuthEvent" ADD VALUE 'DENIED';

-- DropForeignKey
ALTER TABLE "parent_student_mapping" DROP CONSTRAINT "parent_student_mapping_parent_id_fkey";

-- DropForeignKey
ALTER TABLE "parent_student_mapping" DROP CONSTRAINT "parent_student_mapping_student_id_fkey";

-- AlterTable
ALTER TABLE "auth_logs" ADD COLUMN     "citizen_id" TEXT,
ALTER COLUMN "parent_id" DROP NOT NULL;

-- AlterTable
ALTER TABLE "students" ADD COLUMN     "left_at" TIMESTAMP(3),
ADD COLUMN     "status" "StudentStatus" NOT NULL DEFAULT 'ACTIVE',
ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL;

-- DropTable
DROP TABLE "parent_student_mapping";

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

-- CreateIndex
CREATE INDEX "parent_student_registry_parent_citizen_id_idx" ON "parent_student_registry"("parent_citizen_id");

-- CreateIndex
CREATE UNIQUE INDEX "parent_student_registry_parent_citizen_id_student_id_key" ON "parent_student_registry"("parent_citizen_id", "student_id");

-- AddForeignKey
ALTER TABLE "parent_student_registry" ADD CONSTRAINT "parent_student_registry_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;


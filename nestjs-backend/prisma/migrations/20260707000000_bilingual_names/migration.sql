-- Bilingual display fields: Thai stays Thai, English stays English.
ALTER TABLE "students" ADD COLUMN "name_en" TEXT;
ALTER TABLE "students" ADD COLUMN "dormitory_en" TEXT;
ALTER TABLE "access_logs" ADD COLUMN "gate_name_en" TEXT;

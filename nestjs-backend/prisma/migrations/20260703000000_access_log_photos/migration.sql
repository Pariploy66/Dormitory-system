-- AlterTable: add gate Access-Control photos to access logs
ALTER TABLE "access_logs" ADD COLUMN "photo_url" TEXT;
ALTER TABLE "access_logs" ADD COLUMN "scan_photo_url" TEXT;

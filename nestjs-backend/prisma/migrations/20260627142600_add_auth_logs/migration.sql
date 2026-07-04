-- CreateEnum
CREATE TYPE "AuthEvent" AS ENUM ('LOGIN', 'LOGOUT');

-- CreateTable
CREATE TABLE "auth_logs" (
    "id" TEXT NOT NULL,
    "parent_id" TEXT NOT NULL,
    "event" "AuthEvent" NOT NULL,
    "ip_address" TEXT,
    "user_agent" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "auth_logs_parent_id_created_at_idx" ON "auth_logs"("parent_id", "created_at" DESC);

-- AddForeignKey
ALTER TABLE "auth_logs" ADD CONSTRAINT "auth_logs_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "parents"("id") ON DELETE CASCADE ON UPDATE CASCADE;

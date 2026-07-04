-- DropIndex
DROP INDEX "parents_email_key";

-- DropIndex
DROP INDEX "parents_phone_key";

-- AlterTable
ALTER TABLE "parents" DROP COLUMN "email",
DROP COLUMN "password_hash",
DROP COLUMN "phone",
ADD COLUMN     "citizen_id" TEXT NOT NULL,
ALTER COLUMN "identity_provider" SET DEFAULT 'THAID';

-- CreateIndex
CREATE UNIQUE INDEX "parents_citizen_id_key" ON "parents"("citizen_id");

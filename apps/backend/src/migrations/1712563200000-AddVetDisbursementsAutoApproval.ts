import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddVetDisbursementsAutoApproval1712563200000 implements MigrationInterface {
  name = 'AddVetDisbursementsAutoApproval1712563200000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // --- Enums ---
    await queryRunner.query(`
      CREATE TYPE "procedure_type_enum" AS ENUM (
        'STERILIZATION', 'VACCINATION', 'EMERGENCY', 'SURGERY',
        'CONSULTATION', 'DEWORMING', 'OTHER'
      )
    `);

    await queryRunner.query(`
      CREATE TYPE "auto_approval_rule_type_enum" AS ENUM (
        'VERIFIED_RESCUER', 'REGISTERED_ANIMAL', 'WITHIN_BUDGET',
        'AUTHORIZED_VET', 'NO_DUPLICATE'
      )
    `);

    await queryRunner.query(`
      CREATE TYPE "audit_action_enum" AS ENUM (
        'AUTO_APPROVED', 'MANUAL_APPROVED', 'REJECTED',
        'SENT_TO_REVIEW', 'EXPIRED'
      )
    `);

    // --- Extend subsidy_requests with 7 new columns ---
    await queryRunner.query(`
      ALTER TABLE "subsidy_requests"
      ADD COLUMN IF NOT EXISTS "vetProfileId" uuid,
      ADD COLUMN IF NOT EXISTS "reviewedById" uuid,
      ADD COLUMN IF NOT EXISTS "reviewedAt" TIMESTAMP,
      ADD COLUMN IF NOT EXISTS "autoApproved" boolean,
      ADD COLUMN IF NOT EXISTS "rejectionReason" text,
      ADD COLUMN IF NOT EXISTS "procedureType" "procedure_type_enum",
      ADD COLUMN IF NOT EXISTS "trackingCode" varchar(20) UNIQUE
    `);

    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS "IDX_subsidy_requests_vetProfileId"
      ON "subsidy_requests" ("vetProfileId")
    `);

    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS "IDX_subsidy_requests_trackingCode"
      ON "subsidy_requests" ("trackingCode")
    `);

    await queryRunner.query(`
      ALTER TABLE "subsidy_requests"
      ADD CONSTRAINT "FK_subsidy_requests_vetProfile"
      FOREIGN KEY ("vetProfileId") REFERENCES "vet_profiles"("id") ON DELETE SET NULL
    `);

    await queryRunner.query(`
      ALTER TABLE "subsidy_requests"
      ADD CONSTRAINT "FK_subsidy_requests_reviewedBy"
      FOREIGN KEY ("reviewedById") REFERENCES "users"("id") ON DELETE SET NULL
    `);

    // --- Create auto_approval_rules table ---
    await queryRunner.query(`
      CREATE TABLE "auto_approval_rules" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "municipalityId" uuid NOT NULL,
        "ruleType" "auto_approval_rule_type_enum" NOT NULL,
        "isEnabled" boolean NOT NULL DEFAULT true,
        "parameters" jsonb,
        "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
        "updatedAt" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_auto_approval_rules" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_auto_approval_rules_municipality_rule"
          UNIQUE ("municipalityId", "ruleType"),
        CONSTRAINT "FK_auto_approval_rules_municipality"
          FOREIGN KEY ("municipalityId") REFERENCES "organizations"("id") ON DELETE CASCADE
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_auto_approval_rules_municipalityId"
      ON "auto_approval_rules" ("municipalityId")
    `);

    // --- Create approval_audit_log table ---
    await queryRunner.query(`
      CREATE TABLE "approval_audit_log" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "subsidyRequestId" uuid NOT NULL,
        "actorId" uuid,
        "action" "audit_action_enum" NOT NULL,
        "ruleResults" jsonb,
        "previousStatus" "subsidy_request_status_enum",
        "newStatus" "subsidy_request_status_enum",
        "notes" text,
        "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_approval_audit_log" PRIMARY KEY ("id"),
        CONSTRAINT "FK_approval_audit_log_subsidyRequest"
          FOREIGN KEY ("subsidyRequestId") REFERENCES "subsidy_requests"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_approval_audit_log_actor"
          FOREIGN KEY ("actorId") REFERENCES "users"("id") ON DELETE SET NULL
      )
    `);

    await queryRunner.query(`
      CREATE INDEX "IDX_approval_audit_log_subsidyRequestId"
      ON "approval_audit_log" ("subsidyRequestId")
    `);

    // --- Add IN_REVIEW to subsidy_request_status_enum if not already present ---
    await queryRunner.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_enum
          WHERE enumlabel = 'IN_REVIEW'
          AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'subsidy_request_status_enum')
        ) THEN
          ALTER TYPE "subsidy_request_status_enum" ADD VALUE 'IN_REVIEW';
        END IF;
      END
      $$
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop audit log table
    await queryRunner.query(`DROP TABLE IF EXISTS "approval_audit_log"`);

    // Drop auto-approval rules table
    await queryRunner.query(`DROP TABLE IF EXISTS "auto_approval_rules"`);

    // Remove foreign keys and indexes from subsidy_requests
    await queryRunner.query(`
      ALTER TABLE "subsidy_requests"
      DROP CONSTRAINT IF EXISTS "FK_subsidy_requests_reviewedBy"
    `);
    await queryRunner.query(`
      ALTER TABLE "subsidy_requests"
      DROP CONSTRAINT IF EXISTS "FK_subsidy_requests_vetProfile"
    `);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_subsidy_requests_trackingCode"`);
    await queryRunner.query(`DROP INDEX IF EXISTS "IDX_subsidy_requests_vetProfileId"`);

    // Remove new columns from subsidy_requests
    await queryRunner.query(`
      ALTER TABLE "subsidy_requests"
      DROP COLUMN IF EXISTS "trackingCode",
      DROP COLUMN IF EXISTS "procedureType",
      DROP COLUMN IF EXISTS "rejectionReason",
      DROP COLUMN IF EXISTS "autoApproved",
      DROP COLUMN IF EXISTS "reviewedAt",
      DROP COLUMN IF EXISTS "reviewedById",
      DROP COLUMN IF EXISTS "vetProfileId"
    `);

    // Drop enums
    await queryRunner.query(`DROP TYPE IF EXISTS "audit_action_enum"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "auto_approval_rule_type_enum"`);
    await queryRunner.query(`DROP TYPE IF EXISTS "procedure_type_enum"`);
  }
}

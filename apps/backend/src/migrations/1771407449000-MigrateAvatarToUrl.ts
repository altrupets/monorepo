import { MigrationInterface, QueryRunner } from 'typeorm';

export class MigrateAvatarToUrl1771407449000 implements MigrationInterface {
  name = 'MigrateAvatarToUrl1771407449000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Add new column for avatar URL
    await queryRunner.query(`
      ALTER TABLE "users"
      ADD COLUMN IF NOT EXISTS "avatarUrl" character varying
    `);

    // Add column to track storage provider
    await queryRunner.query(`
      ALTER TABLE "users"
      ADD COLUMN IF NOT EXISTS "avatarStorageProvider" character varying DEFAULT 'local'
    `);

    // Note: Existing avatarImage data in bytea should be migrated manually
    // or via a background job to object storage before removing the column

    // Create index for avatar URL lookups
    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS "IDX_users_avatarUrl" ON "users" ("avatarUrl")
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Remove index
    await queryRunner.query(`
      DROP INDEX IF EXISTS "IDX_users_avatarUrl"
    `);

    // Remove new columns
    await queryRunner.query(`
      ALTER TABLE "users"
      DROP COLUMN IF EXISTS "avatarStorageProvider"
    `);

    await queryRunner.query(`
      ALTER TABLE "users"
      DROP COLUMN IF EXISTS "avatarUrl"
    `);
  }
}

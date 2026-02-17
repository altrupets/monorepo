import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddUserFields1708152000000 implements MigrationInterface {
  name = 'AddUserFields1708152000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Add email column
    await queryRunner.query(
      `ALTER TABLE "users" ADD "email" character varying`,
    );
    await queryRunner.query(
      `CREATE UNIQUE INDEX "IDX_users_email" ON "users" ("email") WHERE "email" IS NOT NULL`,
    );

    // Add bio column
    await queryRunner.query(
      `ALTER TABLE "users" ADD "bio" character varying`,
    );

    // Add organizationId column
    await queryRunner.query(
      `ALTER TABLE "users" ADD "organizationId" uuid`,
    );

    // Add geolocation columns
    await queryRunner.query(
      `ALTER TABLE "users" ADD "latitude" decimal(10,7)`,
    );
    await queryRunner.query(
      `ALTER TABLE "users" ADD "longitude" decimal(10,7)`,
    );

    // Add status columns
    await queryRunner.query(
      `ALTER TABLE "users" ADD "isActive" boolean NOT NULL DEFAULT true`,
    );
    await queryRunner.query(
      `ALTER TABLE "users" ADD "isVerified" boolean NOT NULL DEFAULT false`,
    );

    // Add index on username for performance
    await queryRunner.query(
      `CREATE INDEX "IDX_users_username" ON "users" ("username")`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop indexes
    await queryRunner.query(`DROP INDEX "IDX_users_username"`);
    await queryRunner.query(`DROP INDEX "IDX_users_email"`);

    // Drop columns
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "isVerified"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "isActive"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "longitude"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "latitude"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "organizationId"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "bio"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "email"`);
  }
}

import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddUniqueLicenseNumberToVetProfile1741610400000 implements MigrationInterface {
  name = 'AddUniqueLicenseNumberToVetProfile1741610400000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE UNIQUE INDEX "UQ_vet_profiles_licenseNumber" ON "vet_profiles" ("licenseNumber") WHERE "licenseNumber" IS NOT NULL`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX "UQ_vet_profiles_licenseNumber"`);
  }
}

import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddDonorFields1708153000000 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Add occupation field for donors
    await queryRunner.query(
      `ALTER TABLE "users" ADD "occupation" character varying`,
    );

    // Add income source field for donors
    await queryRunner.query(
      `ALTER TABLE "users" ADD "incomeSource" character varying`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "incomeSource"`);
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "occupation"`);
  }
}

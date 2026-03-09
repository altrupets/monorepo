import { MigrationInterface, QueryRunner } from 'typeorm';

export class EnablePostGIS1709750000000 implements MigrationInterface {
  name = 'EnablePostGIS1709750000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS postgis`);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS "jurisdictions" (
        "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        "name" varchar(255) NOT NULL,
        "level" varchar(50) NOT NULL,
        "parentId" uuid REFERENCES "jurisdictions"(id),
        "province" varchar(100),
        "canton" varchar(100),
        "district" varchar(100),
        "geometry" geometry(MULTIPOLYGON, 4326),
        "centerPoint" geometry(POINT, 4326),
        "createdAt" TIMESTAMP NOT NULL DEFAULT now(),
        "updatedAt" TIMESTAMP NOT NULL DEFAULT now()
      )
    `);

    await queryRunner.query(`
      CREATE INDEX idx_jurisdictions_level ON "jurisdictions"("level")
    `);

    await queryRunner.query(`
      CREATE INDEX idx_jurisdictions_parent ON "jurisdictions"("parentId")
    `);

    await queryRunner.query(`
      CREATE INDEX idx_jurisdictions_geom ON "jurisdictions" USING GIST("geometry")
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS "jurisdictions"`);
    await queryRunner.query(`DROP EXTENSION IF EXISTS postgis CASCADE`);
  }
}

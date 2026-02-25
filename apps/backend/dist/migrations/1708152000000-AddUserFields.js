"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AddUserFields1708152000000 = void 0;
class AddUserFields1708152000000 {
    name = 'AddUserFields1708152000000';
    async up(queryRunner) {
        await queryRunner.query(`ALTER TABLE "users" ADD "email" character varying`);
        await queryRunner.query(`CREATE UNIQUE INDEX "IDX_users_email" ON "users" ("email") WHERE "email" IS NOT NULL`);
        await queryRunner.query(`ALTER TABLE "users" ADD "bio" character varying`);
        await queryRunner.query(`ALTER TABLE "users" ADD "organizationId" uuid`);
        await queryRunner.query(`ALTER TABLE "users" ADD "latitude" decimal(10,7)`);
        await queryRunner.query(`ALTER TABLE "users" ADD "longitude" decimal(10,7)`);
        await queryRunner.query(`ALTER TABLE "users" ADD "isActive" boolean NOT NULL DEFAULT true`);
        await queryRunner.query(`ALTER TABLE "users" ADD "isVerified" boolean NOT NULL DEFAULT false`);
        await queryRunner.query(`CREATE INDEX "IDX_users_username" ON "users" ("username")`);
    }
    async down(queryRunner) {
        await queryRunner.query(`DROP INDEX "IDX_users_username"`);
        await queryRunner.query(`DROP INDEX "IDX_users_email"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "isVerified"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "isActive"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "longitude"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "latitude"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "organizationId"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "bio"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "email"`);
    }
}
exports.AddUserFields1708152000000 = AddUserFields1708152000000;
//# sourceMappingURL=1708152000000-AddUserFields.js.map

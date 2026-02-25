"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AddDonorFields1708153000000 = void 0;
class AddDonorFields1708153000000 {
    async up(queryRunner) {
        await queryRunner.query(`ALTER TABLE "users" ADD "occupation" character varying`);
        await queryRunner.query(`ALTER TABLE "users" ADD "incomeSource" character varying`);
    }
    async down(queryRunner) {
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "incomeSource"`);
        await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "occupation"`);
    }
}
exports.AddDonorFields1708153000000 = AddDonorFields1708153000000;
//# sourceMappingURL=1708153000000-AddDonorFields.js.map

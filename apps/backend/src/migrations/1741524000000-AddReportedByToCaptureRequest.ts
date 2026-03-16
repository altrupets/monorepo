import { MigrationInterface, QueryRunner, TableColumn, TableForeignKey } from 'typeorm';

export class AddReportedByToCaptureRequest1741524000000
  implements MigrationInterface
{
  name = 'AddReportedByToCaptureRequest1741524000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Add the reportedById column
    await queryRunner.addColumn(
      'capture_requests',
      new TableColumn({
        name: 'reportedById',
        type: 'uuid',
        isNullable: true,
      }),
    );

    // Add the foreign key constraint
    await queryRunner.createForeignKey(
      'capture_requests',
      new TableForeignKey({
        columnNames: ['reportedById'],
        referencedColumnNames: ['id'],
        referencedTableName: 'users',
        onDelete: 'SET NULL',
        name: 'FK_capture_requests_reportedById',
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop foreign key first
    await queryRunner.dropForeignKey(
      'capture_requests',
      'FK_capture_requests_reportedById',
    );

    // Then drop the column
    await queryRunner.dropColumn('capture_requests', 'reportedById');
  }
}

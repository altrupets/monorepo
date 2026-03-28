import { Module } from '@nestjs/common';
import { McpService } from './mcp.service';
import { McpController } from './mcp.controller';
import { AnimalsModule } from '../animals/animals.module';
import { SubsidiesModule } from '../subsidies/subsidies.module';
import { CapturesModule } from '../captures/captures.module';
import { AbuseReportsModule } from '../abuse-reports/abuse-reports.module';
import { JurisdictionsModule } from '../jurisdictions/jurisdictions.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    AnimalsModule,
    SubsidiesModule,
    CapturesModule,
    AbuseReportsModule,
    JurisdictionsModule,
    AuthModule,
  ],
  controllers: [McpController],
  providers: [McpService],
})
export class McpModule {}

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JurisdictionsService } from './jurisdictions.service';
import { JurisdictionsResolver } from './jurisdictions.resolver';
import { Jurisdiction } from './entities/jurisdiction.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Jurisdiction])],
  providers: [JurisdictionsService, JurisdictionsResolver],
  exports: [JurisdictionsService],
})
export class JurisdictionsModule {}

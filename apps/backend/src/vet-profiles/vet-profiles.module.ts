import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VetProfilesService } from './vet-profiles.service';
import { VetProfilesResolver } from './vet-profiles.resolver';
import { VetProfile } from './entities/vet-profile.entity';

@Module({
  imports: [TypeOrmModule.forFeature([VetProfile])],
  providers: [VetProfilesService, VetProfilesResolver],
  exports: [VetProfilesService],
})
export class VetProfilesModule {}

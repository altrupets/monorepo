import { Resolver, Query, Mutation, Args, ID } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { AbuseReport, AbuseReportStatus, AbuseReportType } from './entities/abuse-report.entity';
import { AbuseReportsService } from './abuse-reports.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GqlUser } from '../auth/gql-user.decorator';
import { User } from '../users/entities/user.entity';

@Resolver(() => AbuseReport)
export class AbuseReportsResolver {
  constructor(private readonly abuseReportsService: AbuseReportsService) {}

  @Mutation(() => AbuseReport)
  @UseGuards(JwtAuthGuard)
  async createAbuseReport(
    @GqlUser() user: User,
    @Args('type', { type: () => AbuseReportType }) type: AbuseReportType,
    @Args('latitude') latitude: number,
    @Args('longitude') longitude: number,
    @Args('description', { nullable: true }) description?: string,
    @Args('photos', { type: () => [String], nullable: true }) photos?: string[],
  ): Promise<AbuseReport> {
    return this.abuseReportsService.create({
      type,
      description,
      latitude,
      longitude,
      photos,
      reporterId: user.id,
    });
  }

  @Query(() => AbuseReport, { name: 'abuseReportByTrackingCode' })
  async getAbuseReportByTrackingCode(
    @Args('code') code: string,
  ): Promise<AbuseReport> {
    return this.abuseReportsService.findByTrackingCode(code);
  }

  @Query(() => [AbuseReport], { name: 'abuseReportsByMunicipality' })
  @UseGuards(JwtAuthGuard)
  async getAbuseReportsByMunicipality(
    @Args('municipalityId', { type: () => ID }) municipalityId: string,
  ): Promise<AbuseReport[]> {
    return this.abuseReportsService.findAllByMunicipality(municipalityId);
  }

  @Mutation(() => AbuseReport)
  @UseGuards(JwtAuthGuard)
  async updateAbuseReportStatus(
    @Args('id', { type: () => ID }) id: string,
    @Args('status', { type: () => AbuseReportStatus }) status: AbuseReportStatus,
  ): Promise<AbuseReport> {
    return this.abuseReportsService.updateStatus(id, status);
  }
}

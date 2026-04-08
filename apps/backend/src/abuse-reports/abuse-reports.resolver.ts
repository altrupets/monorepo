import { Resolver, Query, Mutation, Args, ID } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { AbuseReport } from './entities/abuse-report.entity';
import { AbuseReportsService } from './abuse-reports.service';
import { AbuseReportStatus } from './enums/abuse-report-status.enum';
import { FileAbuseReportInput } from './dto/file-abuse-report.input';
import { ClassifyReportInput } from './dto/classify-report.input';
import { ResolveReportInput } from './dto/resolve-report.input';
import { ReportMetrics } from './dto/report-metrics.output';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles/roles.guard';
import { Roles } from '../auth/roles/roles.decorator';
import { UserRole } from '../auth/roles/user-role.enum';

@Resolver(() => AbuseReport)
export class AbuseReportsResolver {
  constructor(private readonly abuseReportsService: AbuseReportsService) {}

  // ─── Public mutations (NO auth required) ───────────────────────

  @Mutation(() => AbuseReport, {
    description: 'File a new abuse report — PUBLIC, no auth required',
  })
  async fileAbuseReport(
    @Args('input') input: FileAbuseReportInput,
  ): Promise<AbuseReport> {
    return this.abuseReportsService.fileReport(input);
  }

  // ─── Government admin mutations ────────────────────────────────

  @Mutation(() => AbuseReport, {
    description: 'Classify a filed report (GOVERNMENT_ADMIN only)',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async classifyReport(
    @Args('input') input: ClassifyReportInput,
  ): Promise<AbuseReport> {
    return this.abuseReportsService.classifyReport(input);
  }

  @Mutation(() => AbuseReport, {
    description: 'Assign an inspector to investigate a report (GOVERNMENT_ADMIN only)',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async assignInvestigator(
    @Args('id', { type: () => ID }) id: string,
    @Args('assignedToId', { type: () => ID }) assignedToId: string,
  ): Promise<AbuseReport> {
    return this.abuseReportsService.assignInvestigator(id, assignedToId);
  }

  @Mutation(() => AbuseReport, {
    description: 'Mark a report as resolved with notes (GOVERNMENT_ADMIN only)',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async resolveReport(
    @Args('input') input: ResolveReportInput,
  ): Promise<AbuseReport> {
    return this.abuseReportsService.resolveReport(input);
  }

  // ─── Public queries (NO auth required) ─────────────────────────

  @Query(() => AbuseReport, {
    name: 'trackAbuseReport',
    description: 'Track a report by its code — PUBLIC, returns status only',
  })
  async trackAbuseReport(
    @Args('trackingCode') trackingCode: string,
  ): Promise<AbuseReport> {
    return this.abuseReportsService.trackReport(trackingCode);
  }

  // ─── Government admin queries ──────────────────────────────────

  @Query(() => [AbuseReport], {
    name: 'pendingReports',
    description: 'List reports pending classification (GOVERNMENT_ADMIN only)',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async getPendingReports(
    @Args('municipalityId', { type: () => ID }) municipalityId: string,
  ): Promise<AbuseReport[]> {
    return this.abuseReportsService.findPendingReports(municipalityId);
  }

  @Query(() => [AbuseReport], {
    name: 'reportsByStatus',
    description: 'List reports filtered by status (GOVERNMENT_ADMIN only)',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async getReportsByStatus(
    @Args('municipalityId', { type: () => ID }) municipalityId: string,
    @Args('status', { type: () => AbuseReportStatus }) status: AbuseReportStatus,
  ): Promise<AbuseReport[]> {
    return this.abuseReportsService.findByStatus(municipalityId, status);
  }

  @Query(() => ReportMetrics, {
    name: 'reportMetrics',
    description: 'Aggregate report metrics for a municipality',
  })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN, UserRole.SUPER_USER)
  async getReportMetrics(
    @Args('municipalityId', { type: () => ID }) municipalityId: string,
  ): Promise<ReportMetrics> {
    return this.abuseReportsService.getReportMetrics(municipalityId);
  }
}

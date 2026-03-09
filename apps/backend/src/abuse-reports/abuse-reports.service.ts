import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { nanoid } from 'nanoid';
import { AbuseReport, AbuseReportStatus } from './entities/abuse-report.entity';
import { JurisdictionsService } from '../jurisdictions/jurisdictions.service';

@Injectable()
export class AbuseReportsService {
  constructor(
    @InjectRepository(AbuseReport)
    private readonly abuseReportRepository: Repository<AbuseReport>,
    private readonly jurisdictionsService: JurisdictionsService,
  ) {}

  async create(data: {
    type: string;
    description?: string;
    latitude: number;
    longitude: number;
    photos?: string[];
    reporterId: string;
  }): Promise<AbuseReport> {
    // 1. Generate tracking code
    const trackingCode = nanoid(10).toUpperCase();

    // 2. Find municipality by GPS
    const jurisdiction = await this.jurisdictionsService.findByCoordinates(
      data.latitude,
      data.longitude,
    );

    // 3. Create report
    const report = this.abuseReportRepository.create({
      type: data.type as any,
      description: data.description,
      location: {
        type: 'Point',
        coordinates: [data.longitude, data.latitude],
      },
      photos: data.photos || [],
      trackingCode,
      reporterId: data.reporterId,
      municipalityId: jurisdiction?.organizationId, // Ensure Jurisdiction has organizationId or mapping
      status: AbuseReportStatus.SUBMITTED,
    });

    return this.abuseReportRepository.save(report);
  }

  async findByTrackingCode(code: string): Promise<AbuseReport> {
    const report = await this.abuseReportRepository.findOne({
      where: { trackingCode: code.toUpperCase() },
      relations: ['reporter', 'municipality'],
    });

    if (!report) {
      throw new NotFoundException(`Report with tracking code ${code} not found`);
    }

    return report;
  }

  async findAllByMunicipality(municipalityId: string): Promise<AbuseReport[]> {
    return this.abuseReportRepository.find({
      where: { municipalityId },
      order: { createdAt: 'DESC' },
    });
  }

  async updateStatus(
    id: string,
    status: AbuseReportStatus,
  ): Promise<AbuseReport> {
    const report = await this.abuseReportRepository.findOne({ where: { id } });
    if (!report) {
      throw new NotFoundException(`Report with ID ${id} not found`);
    }

    report.status = status;
    return this.abuseReportRepository.save(report);
  }
}

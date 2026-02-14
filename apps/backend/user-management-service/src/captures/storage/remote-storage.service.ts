import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { v4 as uuid } from 'uuid';
import { IStorageWrapper, CreateCaptureDto } from '../interfaces/storage-wrapper.interface';
import { CaptureRequest } from '../entities/capture-request.entity';

@Injectable()
export class RemoteStorageService implements IStorageWrapper {
    private readonly logger = new Logger(RemoteStorageService.name);

    constructor(
        @InjectRepository(CaptureRequest)
        private readonly repository: Repository<CaptureRequest>,
        private readonly configService: ConfigService,
    ) { }

    async saveCapture(data: CreateCaptureDto, image: Buffer): Promise<CaptureRequest> {
        this.logger.log('Saving capture to OVH S3 (not fully implemented in this step)...');

        // Placeholder for S3 upload logic
        const imageUrl = `https://s3.ovh.net/bucket/${uuid()}.jpg`;

        const capture = this.repository.create({
            ...data,
            imageUrl,
            status: 'PENDING',
        });

        return this.repository.save(capture);
    }

    async getCaptures(): Promise<CaptureRequest[]> {
        return this.repository.find({ order: { createdAt: 'DESC' } });
    }
}

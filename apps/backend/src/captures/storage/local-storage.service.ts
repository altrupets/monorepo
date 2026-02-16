import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { writeFile, mkdir } from 'fs/promises';
import { join } from 'path';
import { v4 as uuid } from 'uuid';
import { IStorageWrapper, CreateCaptureDto } from '../interfaces/storage-wrapper.interface';
import { CaptureRequest } from '../entities/capture-request.entity';

@Injectable()
export class LocalStorageService implements IStorageWrapper {
    private readonly uploadPath = join(process.cwd(), 'uploads');

    constructor(
        @InjectRepository(CaptureRequest)
        private readonly repository: Repository<CaptureRequest>,
    ) {
        this.ensureUploadPath();
    }

    private async ensureUploadPath() {
        try {
            await mkdir(this.uploadPath, { recursive: true });
        } catch (err) {
            // Ignore if exists
        }
    }

    async saveCapture(data: CreateCaptureDto, image: Buffer): Promise<CaptureRequest> {
        const fileName = `${uuid()}.jpg`;
        const filePath = join(this.uploadPath, fileName);

        // Save to disk
        await writeFile(filePath, image);

        // Save to database
        const capture = this.repository.create({
            ...data,
            imageUrl: `/uploads/${fileName}`,
            status: 'PENDING',
        });

        return this.repository.save(capture);
    }

    async getCaptures(): Promise<CaptureRequest[]> {
        return this.repository.find({ order: { createdAt: 'DESC' } });
    }
}

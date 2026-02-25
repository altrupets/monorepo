import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { writeFile, mkdir } from 'fs/promises';
import { join } from 'path';
import { v4 as uuid } from 'uuid';

export interface AvatarUploadResult {
  url: string;
  storageProvider: string;
}

@Injectable()
export class AvatarStorageService {
  private readonly logger = new Logger(AvatarStorageService.name);
  private readonly localUploadPath: string;
  private readonly useRemoteStorage: boolean;
  private readonly remoteEndpoint?: string;
  private readonly remoteBucket?: string;

  constructor(private readonly configService: ConfigService) {
    this.localUploadPath = join(process.cwd(), 'uploads', 'avatars');
    this.useRemoteStorage = configService.get<string>('AVATAR_STORAGE_TYPE') === 's3';
    this.remoteEndpoint = configService.get<string>('S3_ENDPOINT');
    this.remoteBucket = configService.get<string>('S3_BUCKET_NAME');

    if (!this.useRemoteStorage) {
      this.ensureLocalUploadPath();
    }
  }

  private async ensureLocalUploadPath() {
    try {
      await mkdir(this.localUploadPath, { recursive: true });
    } catch (err) {
      // Ignore if exists
    }
  }

  async uploadAvatar(userId: string, imageBuffer: Buffer): Promise<AvatarUploadResult> {
    const fileName = `${userId}-${uuid()}.jpg`;

    if (this.useRemoteStorage && this.remoteEndpoint && this.remoteBucket) {
      return this.uploadToS3(fileName, imageBuffer);
    } else {
      return this.uploadToLocal(fileName, imageBuffer);
    }
  }

  private async uploadToLocal(fileName: string, imageBuffer: Buffer): Promise<AvatarUploadResult> {
    const filePath = join(this.localUploadPath, fileName);
    await writeFile(filePath, imageBuffer);

    return {
      url: `/uploads/avatars/${fileName}`,
      storageProvider: 'local',
    };
  }

  private async uploadToS3(fileName: string, imageBuffer: Buffer): Promise<AvatarUploadResult> {
    this.logger.log(`Uploading avatar to S3: ${fileName}`);

    // Placeholder for S3 upload implementation
    // TODO: Implement actual S3 upload using @aws-sdk/client-s3
    const url = `${this.remoteEndpoint}/${this.remoteBucket}/avatars/${fileName}`;

    return {
      url,
      storageProvider: 's3',
    };
  }

  async deleteAvatar(url: string, storageProvider: string): Promise<void> {
    if (storageProvider === 'local') {
      // TODO: Implement local file deletion
      this.logger.log(`Deleting local avatar: ${url}`);
    } else if (storageProvider === 's3') {
      // TODO: Implement S3 deletion
      this.logger.log(`Deleting S3 avatar: ${url}`);
    }
  }
}

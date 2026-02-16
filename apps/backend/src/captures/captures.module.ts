import { Module, Provider } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { CaptureRequest } from './entities/capture-request.entity';
import { CapturesResolver } from './captures.resolver';
import { STORAGE_WRAPPER } from './interfaces/storage-wrapper.interface';
import { LocalStorageService } from './storage/local-storage.service';
import { RemoteStorageService } from './storage/remote-storage.service';

const StorageProvider: Provider = {
    provide: STORAGE_WRAPPER,
    useFactory: (
        configService: ConfigService,
        local: LocalStorageService,
        remote: RemoteStorageService,
    ) => {
        const type = configService.get<string>('STORAGE_TYPE', 'local');
        return type === 'remote' ? remote : local;
    },
    inject: [ConfigService, LocalStorageService, RemoteStorageService],
};

@Module({
    imports: [TypeOrmModule.forFeature([CaptureRequest]), ConfigModule],
    providers: [
        CapturesResolver,
        LocalStorageService,
        RemoteStorageService,
        StorageProvider,
    ],
    exports: [STORAGE_WRAPPER],
})
export class CapturesModule { }

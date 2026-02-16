import { CaptureRequest } from './entities/capture-request.entity';
import { CreateCaptureInput } from './dto/create-capture.input';
import type { IStorageWrapper } from './interfaces/storage-wrapper.interface';
export declare class CapturesResolver {
    private readonly storage;
    constructor(storage: IStorageWrapper);
    getCaptures(): Promise<CaptureRequest[]>;
    createCaptureRequest(input: CreateCaptureInput): Promise<CaptureRequest>;
}

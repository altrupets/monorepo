import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { Inject } from '@nestjs/common';
import { CaptureRequest } from './entities/capture-request.entity';
import { CreateCaptureInput } from './dto/create-capture.input';
import type { IStorageWrapper } from './interfaces/storage-wrapper.interface';
import { STORAGE_WRAPPER } from './interfaces/storage-wrapper.interface';

@Resolver(() => CaptureRequest)
export class CapturesResolver {
    constructor(
        @Inject(STORAGE_WRAPPER)
        private readonly storage: IStorageWrapper,
    ) { }

    @Query(() => [CaptureRequest], { name: 'getCaptureRequests' })
    async getCaptures() {
        return this.storage.getCaptures();
    }

    @Mutation(() => CaptureRequest)
    async createCaptureRequest(
        @Args('input') input: CreateCaptureInput,
    ) {
        // Process image buffer from base64 (common for mobile-to-graphql)
        const imageBuffer = Buffer.from(input.imageBase64, 'base64');

        const { imageBase64, ...data } = input;
        return this.storage.saveCapture(data, imageBuffer);
    }
}

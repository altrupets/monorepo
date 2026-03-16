import { Resolver, Query, Mutation, Args } from '@nestjs/graphql';
import { Inject, UseGuards } from '@nestjs/common';
import { CaptureRequest } from './entities/capture-request.entity';
import { CreateCaptureInput } from './dto/create-capture.input';
import type { IStorageWrapper } from './interfaces/storage-wrapper.interface';
import { STORAGE_WRAPPER } from './interfaces/storage-wrapper.interface';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GqlUser } from '../auth/gql-user.decorator';
import { User } from '../users/entities/user.entity';
import { RolesGuard } from '../auth/roles/roles.guard';
import { Roles } from '../auth/roles/roles.decorator';
import { CAPTURE_VIEWER_ROLES } from '../auth/roles/rbac-constants';

@Resolver(() => CaptureRequest)
export class CapturesResolver {
    constructor(
        @Inject(STORAGE_WRAPPER)
        private readonly storage: IStorageWrapper,
    ) { }

    @Query(() => [CaptureRequest], { name: 'getCaptureRequests' })
    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(...CAPTURE_VIEWER_ROLES)
    async getCaptures() {
        return this.storage.getCaptures();
    }

    @Mutation(() => CaptureRequest)
    @UseGuards(JwtAuthGuard)
    async createCaptureRequest(
        @Args('input') input: CreateCaptureInput,
        @GqlUser() user: User,
    ) {
        // Process image buffer from base64 (common for mobile-to-graphql)
        const imageBuffer = Buffer.from(input.imageBase64, 'base64');

        const { imageBase64, ...data } = input;
        return this.storage.saveCapture(data, imageBuffer, user.id);
    }
}

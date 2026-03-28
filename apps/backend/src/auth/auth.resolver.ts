import { Resolver, Mutation, Args, Query, registerEnumType } from '@nestjs/graphql';
import { User } from '../users/entities/user.entity';
import { UseGuards, HttpException, HttpStatus } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { AuthService } from './auth.service';
import { AuthPayload, UserProfile, RefreshTokenInput } from './dto/auth.types';
import { LoginInput } from './dto/login.input';
import { RegisterInput } from './dto/register.input';
import { ResetPasswordInput } from './dto/reset-password.input';
import { GqlUser } from './gql-user.decorator';
import { GqlThrottlerGuard } from './guards/gql-throttler.guard';
import { JwtAuthGuard } from './jwt-auth.guard';
import { RolesGuard } from './roles/roles.guard';
import { Roles } from './roles/roles.decorator';
import { UserRole } from './roles/user-role.enum';

export enum LoginError {
  USER_NOT_FOUND = 'USER_NOT_FOUND',
  INVALID_PASSWORD = 'INVALID_PASSWORD',
  ACCOUNT_LOCKED = 'ACCOUNT_LOCKED',
}

registerEnumType(LoginError, { name: 'LoginError' });

@Resolver()
export class AuthResolver {
  constructor(private authService: AuthService) { }

  @Mutation(() => User)
  async register(@Args('registerInput') registerInput: RegisterInput) {
    return this.authService.register(registerInput);
  }

  @Mutation(() => AuthPayload)
  async login(@Args('loginInput') loginInput: LoginInput) {
    try {
      const user = await this.authService.validateUser(
        loginInput.username,
        loginInput.password,
      );
      return this.authService.login(user);
    } catch (error) {
      const message = error.message;

      if (message.includes('USER_NOT_FOUND')) {
        throw new HttpException(
          'El usuario no existe o fue eliminado de nuestra base de datos.',
          HttpStatus.UNAUTHORIZED,
        );
      }

      if (message.includes('INVALID_PASSWORD')) {
        throw new HttpException(
          'La contraseña es incorrecta. Por favor intenta de nuevo.',
          HttpStatus.UNAUTHORIZED,
        );
      }

      if (message.includes('ACCOUNT_LOCKED')) {
        throw new HttpException(
          message, // Contains the locked message with time remaining
          HttpStatus.LOCKED,
        );
      }

      throw new HttpException(
        'Error de autenticación. Por favor intenta de nuevo.',
        HttpStatus.UNAUTHORIZED,
      );
    }
  }

  @Mutation(() => AuthPayload)
  async refreshToken(@Args('refreshTokenInput') refreshTokenInput: RefreshTokenInput) {
    try {
      return await this.authService.refreshToken(refreshTokenInput.refresh_token);
    } catch (error) {
      throw new HttpException(
        error.message,
        HttpStatus.UNAUTHORIZED,
      );
    }
  }

  @Query(() => UserProfile)
  @UseGuards(JwtAuthGuard)
  profile(@GqlUser() user: User) {
    return user;
  }

  @Query(() => String)
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.GOVERNMENT_ADMIN)
  adminOnlyData() {
    return 'This is restricted to GOVERNMENT_ADMIN only';
  }

  // -- Email Verification --

  @Mutation(() => Boolean)
  @UseGuards(JwtAuthGuard, GqlThrottlerGuard)
  @Throttle({ short: { ttl: 1000, limit: 3 } })
  async requestEmailVerification(@GqlUser() user: User) {
    return this.authService.sendVerificationEmail(user.id);
  }

  // -- Password Reset --

  @Mutation(() => Boolean)
  @UseGuards(GqlThrottlerGuard)
  @Throttle({ short: { ttl: 1000, limit: 3 } })
  async requestPasswordReset(@Args('email') email: string) {
    return this.authService.requestPasswordReset(email);
  }

  @Mutation(() => Boolean)
  @UseGuards(GqlThrottlerGuard)
  @Throttle({ short: { ttl: 1000, limit: 3 } })
  async resetPassword(
    @Args('input') input: ResetPasswordInput,
  ) {
    return this.authService.resetPasswordWithToken(input.token, input.newPassword);
  }
}

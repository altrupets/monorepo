import { Resolver, Mutation, Args, Query, registerEnumType } from '@nestjs/graphql';
import { User } from '../users/entities/user.entity';
import { UseGuards, HttpException, HttpStatus } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthPayload, UserProfile } from './dto/auth.types';
import { LoginInput } from './dto/login.input';
import { RegisterInput } from './dto/register.input';
import { JwtAuthGuard } from './jwt-auth.guard';
import { RolesGuard } from './roles/roles.guard';
import { Roles } from './roles/roles.decorator';
import { UserRole } from './roles/user-role.enum';
import { GqlUser } from './gql-user.decorator';

export enum LoginError {
  USER_NOT_FOUND = 'USER_NOT_FOUND',
  INVALID_PASSWORD = 'INVALID_PASSWORD',
  ACCOUNT_LOCKED = 'ACCOUNT_LOCKED',
}

registerEnumType(LoginError, { name: 'LoginError' });

@Resolver()
export class AuthResolver {
  constructor(private authService: AuthService) {}

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
}

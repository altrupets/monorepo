import { Resolver, Mutation, Args, Query } from '@nestjs/graphql';
import { User } from '../users/entities/user.entity';
import { UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthPayload, UserProfile } from './dto/auth.types';
import { LoginInput } from './dto/login.input';
import { JwtAuthGuard } from './jwt-auth.guard';
import { RolesGuard } from './roles/roles.guard';
import { Roles } from './roles/roles.decorator';
import { UserRole } from './roles/user-role.enum';
import { GqlUser } from './gql-user.decorator';

@Resolver()
export class AuthResolver {
  constructor(private authService: AuthService) {}

  @Mutation(() => AuthPayload)
  async login(@Args('loginInput') loginInput: LoginInput) {
    const user = await this.authService.validateUser(
      loginInput.username,
      loginInput.password,
    );
    if (!user) {
      throw new Error('Invalid credentials');
    }
    return this.authService.login(user);
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

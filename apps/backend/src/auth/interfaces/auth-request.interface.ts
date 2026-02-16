import { User } from '../../users/entities/user.entity';

export interface AuthRequest {
  req: {
    user: User;
  };
}

export interface GqlContext {
  req: {
    user: User;
  };
}

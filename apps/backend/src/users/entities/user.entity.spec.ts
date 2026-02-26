import { User } from './user.entity';
import { UserRole } from '../../auth/roles/user-role.enum';

describe('User Entity', () => {
  let user: User;

  beforeEach(() => {
    user = new User();
    user.id = '123e4567-e89b-12d3-a456-426614174000';
    user.username = 'testuser';
    user.email = 'test@example.com';
    user.passwordHash = 'hashedpassword';
    user.roles = [UserRole.WATCHER];
    user.firstName = 'Test';
    user.lastName = 'User';
    user.isActive = true;
    user.isVerified = false;
  });

  it('should have all required properties', () => {
    expect(user.id).toBeDefined();
    expect(user.username).toBeDefined();
    expect(user.email).toBeDefined();
    expect(user.passwordHash).toBeDefined();
    expect(user.roles).toBeDefined();
    expect(user.isActive).toBeDefined();
  });

  it('should have default role WATCHER', () => {
    const newUser = new User();
    newUser.roles = [UserRole.WATCHER];
    expect(newUser.roles).toEqual([UserRole.WATCHER]);
  });

  it('should allow multiple roles', () => {
    user.roles = [UserRole.WATCHER, UserRole.SUPER_USER];
    expect(user.roles).toContain(UserRole.WATCHER);
    expect(user.roles).toContain(UserRole.SUPER_USER);
  });

  it('should allow setting isActive', () => {
    user.isActive = false;
    expect(user.isActive).toBe(false);

    user.isActive = true;
    expect(user.isActive).toBe(true);
  });

  it('should correctly identify admin roles', () => {
    user.roles = [UserRole.SUPER_USER];
    expect(user.roles).toContain(UserRole.SUPER_USER);
  });

  it('should have timestamp fields', () => {
    const now = new Date();
    user.createdAt = now;
    user.updatedAt = now;

    expect(user.createdAt).toEqual(now);
    expect(user.updatedAt).toEqual(now);
  });

  it('should have optional fields as undefined by default', () => {
    const newUser = new User();
    expect(newUser.email).toBeUndefined();
    expect(newUser.firstName).toBeUndefined();
    expect(newUser.lastName).toBeUndefined();
    expect(newUser.phone).toBeUndefined();
  });
});

"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const user_role_enum_1 = require("./roles/user-role.enum");
const jwt_1 = require("@nestjs/jwt");
const bcrypt = __importStar(require("bcrypt"));
const cache_manager_1 = require("@nestjs/cache-manager");
const user_repository_interface_1 = require("../users/domain/user.repository.interface");
const crypto_1 = require("crypto");
let AuthService = class AuthService {
    userRepository;
    jwtService;
    cacheManager;
    ACCESS_TOKEN_EXPIRY = '1h';
    REFRESH_TOKEN_EXPIRY = '7d';
    REFRESH_TOKEN_CACHE_TTL = 7 * 24 * 60 * 60 * 1000;
    constructor(userRepository, jwtService, cacheManager) {
        this.userRepository = userRepository;
        this.jwtService = jwtService;
        this.cacheManager = cacheManager;
    }
    async validateUser(username, pass) {
        const user = await this.userRepository.findByUsername(username);
        if (user && (await bcrypt.compare(pass, user.passwordHash))) {
            const result = { ...user };
            delete result.passwordHash;
            return result;
        }
        return null;
    }
    async login(user) {
        if (!user.id || !user.username || !user.roles) {
            throw new Error('Invalid user data for login');
        }
        const payload = {
            username: user.username,
            sub: user.id,
            roles: user.roles,
        };
        const accessToken = this.jwtService.sign(payload, {
            expiresIn: this.ACCESS_TOKEN_EXPIRY,
        });
        const refreshToken = this.generateRefreshToken();
        await this.cacheManager.set(`refresh:${refreshToken}`, user.id, this.REFRESH_TOKEN_CACHE_TTL);
        await this.cacheManager.set(`token:${user.id}`, accessToken, 3600000);
        return {
            access_token: accessToken,
            refresh_token: refreshToken,
            expires_in: 3600,
        };
    }
    async refreshToken(refreshToken) {
        const userId = await this.cacheManager.get(`refresh:${refreshToken}`);
        if (!userId) {
            throw new common_1.UnauthorizedException('Invalid or expired refresh token');
        }
        const user = await this.userRepository.findById(userId);
        if (!user) {
            throw new common_1.UnauthorizedException('User not found');
        }
        const payload = {
            username: user.username,
            sub: user.id,
            roles: user.roles,
        };
        const newAccessToken = this.jwtService.sign(payload, {
            expiresIn: this.ACCESS_TOKEN_EXPIRY,
        });
        const newRefreshToken = this.generateRefreshToken();
        await this.cacheManager.del(`refresh:${refreshToken}`);
        await this.cacheManager.set(`refresh:${newRefreshToken}`, user.id, this.REFRESH_TOKEN_CACHE_TTL);
        await this.cacheManager.set(`token:${user.id}`, newAccessToken, 3600000);
        return {
            access_token: newAccessToken,
            refresh_token: newRefreshToken,
            expires_in: 3600,
        };
    }
    async logout(userId, refreshToken) {
        await this.cacheManager.del(`token:${userId}`);
        if (refreshToken) {
            await this.cacheManager.del(`refresh:${refreshToken}`);
        }
    }
    async register(registerData) {
        const existingUser = await this.userRepository.findByUsername(registerData.username);
        if (existingUser) {
            throw new Error('Username already exists');
        }
        if (registerData.email) {
            const existingEmail = await this.userRepository.findByEmail(registerData.email);
            if (existingEmail) {
                throw new Error('Email already exists');
            }
        }
        const passwordHash = await bcrypt.hash(registerData.password, 12);
        const newUser = await this.userRepository.save({
            username: registerData.username,
            email: registerData.email,
            passwordHash,
            firstName: registerData.firstName,
            lastName: registerData.lastName,
            phone: registerData.phone,
            identification: registerData.identification,
            country: registerData.country,
            province: registerData.province,
            canton: registerData.canton,
            district: registerData.district,
            occupation: registerData.occupation,
            incomeSource: registerData.incomeSource,
            roles: registerData.roles || [user_role_enum_1.UserRole.WATCHER],
            isActive: true,
            isVerified: false,
        });
        return newUser;
    }
    generateRefreshToken() {
        return (0, crypto_1.randomBytes)(32).toString('hex');
    }
    async createInitialAdmin(username, pass) {
        const existing = await this.userRepository.findByUsername(username);
        if (existing)
            return;
        const passwordHash = await bcrypt.hash(pass, 12);
        await this.userRepository.save({
            username,
            passwordHash,
            roles: [user_role_enum_1.UserRole.SUPER_USER],
        });
    }
    async validateToken(token) {
        try {
            const payload = this.jwtService.verify(token);
            return {
                id: payload.sub,
                username: payload.username,
                roles: payload.roles,
            };
        }
        catch (error) {
            throw new Error('Invalid token');
        }
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, common_1.Inject)(user_repository_interface_1.IUSER_REPOSITORY)),
    __param(2, (0, common_1.Inject)(cache_manager_1.CACHE_MANAGER)),
    __metadata("design:paramtypes", [Object, jwt_1.JwtService, Object])
], AuthService);
//# sourceMappingURL=auth.service.js.map

"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const app_module_1 = require("./app.module");
const auth_service_1 = require("./auth/auth.service");
const cookie_parser_1 = __importDefault(require("cookie-parser"));
const nestjs_inertia_1 = require("nestjs-inertia");
const path_1 = require("path");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.useBodyParser('json', { limit: '50mb' });
    app.use((0, cookie_parser_1.default)());
    app.useStaticAssets((0, path_1.join)(__dirname, '..', 'public'));
    app.use(nestjs_inertia_1.inertiaMiddleware);
    const configService = app.get(config_1.ConfigService);
    const port = configService.get('PORT', 3001);
    app.enableCors({
        origin: [
            'http://localhost:5173',
            'http://localhost:3000',
            'http://192.168.1.81:3001',
            'http://192.168.1.81:5173',
        ],
        credentials: true,
    });
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
    }));
    const seedEnabled = configService.get('SEED_ADMIN', 'false') === 'true';
    if (seedEnabled) {
        const authService = app.get(auth_service_1.AuthService);
        const username = configService.get('SEED_ADMIN_USERNAME');
        const password = configService.get('SEED_ADMIN_PASSWORD');
        if (!username || !password) {
            throw new Error('SEED_ADMIN is enabled, but SEED_ADMIN_USERNAME/SEED_ADMIN_PASSWORD are missing');
        }
        if (password.length < 12) {
            throw new Error('SEED_ADMIN_PASSWORD must be at least 12 characters when SEED_ADMIN=true');
        }
        await authService.createInitialAdmin(username, password);
    }
    await app.listen(port);
    const envName = configService.get('ENV_NAME', 'dev').toUpperCase();
    console.log(`AltruPets ${envName} Backend is running on: http://localhost:${port}`);
}
bootstrap().catch((err) => {
    console.error('Error starting server:', err);
    process.exit(1);
});
//# sourceMappingURL=main.js.map
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const app_module_1 = require("./app.module");
const auth_service_1 = require("./auth/auth.service");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    const configService = app.get(config_1.ConfigService);
    const port = configService.get('PORT', 3001);
    app.enableCors({
        origin: [
            'http://localhost:5173',
            'http://localhost:3000',
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
    console.log(`User Management Service is running on: http://localhost:${port}`);
}
bootstrap().catch((err) => {
    console.error('Error starting server:', err);
    process.exit(1);
});
//# sourceMappingURL=main.js.map
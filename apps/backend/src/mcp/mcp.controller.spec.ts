import { Test, TestingModule } from '@nestjs/testing';
import { McpController } from './mcp.controller';
import { McpService } from './mcp.service';
import { AuthService } from '../auth/auth.service';

describe('McpController', () => {
  let controller: McpController;
  let authService: { validateToken: jest.Mock };
  let mcpService: { getServer: jest.Mock };

  beforeEach(async () => {
    authService = {
      validateToken: jest.fn(),
    };

    mcpService = {
      getServer: jest.fn().mockReturnValue({
        connect: jest.fn().mockResolvedValue(undefined),
      }),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [McpController],
      providers: [
        { provide: McpService, useValue: mcpService },
        { provide: AuthService, useValue: authService },
      ],
    }).compile();

    controller = module.get<McpController>(McpController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('POST /mcp', () => {
    it('should return 401 when no Authorization header is provided', async () => {
      const req = {
        headers: {},
        body: {},
      } as any;

      const statusMock = jest.fn().mockReturnThis();
      const jsonMock = jest.fn();
      const res = {
        status: statusMock,
        json: jsonMock,
        headersSent: false,
      } as any;

      await controller.handleMcp(req, res);

      expect(statusMock).toHaveBeenCalledWith(401);
      expect(jsonMock).toHaveBeenCalledWith(
        expect.objectContaining({
          jsonrpc: '2.0',
          error: expect.objectContaining({
            code: -32001,
            message: expect.stringContaining('Authentication required'),
          }),
        }),
      );
    });

    it('should return 401 when Authorization header has no Bearer prefix', async () => {
      const req = {
        headers: { authorization: 'Basic some-token' },
        body: {},
      } as any;

      const statusMock = jest.fn().mockReturnThis();
      const jsonMock = jest.fn();
      const res = {
        status: statusMock,
        json: jsonMock,
        headersSent: false,
      } as any;

      await controller.handleMcp(req, res);

      expect(statusMock).toHaveBeenCalledWith(401);
    });

    it('should return 401 when token validation fails', async () => {
      authService.validateToken.mockRejectedValue(new Error('Invalid token'));

      const req = {
        headers: { authorization: 'Bearer invalid-token' },
        body: {},
      } as any;

      const statusMock = jest.fn().mockReturnThis();
      const jsonMock = jest.fn();
      const res = {
        status: statusMock,
        json: jsonMock,
        headersSent: false,
      } as any;

      await controller.handleMcp(req, res);

      expect(authService.validateToken).toHaveBeenCalledWith('invalid-token');
      expect(statusMock).toHaveBeenCalledWith(401);
      expect(jsonMock).toHaveBeenCalledWith(
        expect.objectContaining({
          jsonrpc: '2.0',
          error: expect.objectContaining({
            code: -32001,
            message: expect.stringContaining('Invalid or expired token'),
          }),
        }),
      );
    });
  });

  describe('GET /mcp', () => {
    it('should return 405 for GET requests in stateless mode', async () => {
      const req = { headers: {} } as any;
      const statusMock = jest.fn().mockReturnThis();
      const jsonMock = jest.fn();
      const res = { status: statusMock, json: jsonMock } as any;

      await controller.handleMcpGet(req, res);

      expect(statusMock).toHaveBeenCalledWith(405);
    });
  });

  describe('DELETE /mcp', () => {
    it('should return 405 for DELETE requests in stateless mode', async () => {
      const req = { headers: {} } as any;
      const statusMock = jest.fn().mockReturnThis();
      const jsonMock = jest.fn();
      const res = { status: statusMock, json: jsonMock } as any;

      await controller.handleMcpDelete(req, res);

      expect(statusMock).toHaveBeenCalledWith(405);
    });
  });
});

import {
  Controller,
  Post,
  Req,
  Res,
  Logger,
  Get,
  Delete,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { StreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/streamableHttp.js';
import { McpService, setCurrentRequestUser } from './mcp.service';
import { AuthService } from '../auth/auth.service';

@Controller('mcp')
export class McpController {
  private readonly logger = new Logger(McpController.name);

  constructor(
    private readonly mcpService: McpService,
    private readonly authService: AuthService,
  ) {}

  @Post()
  async handleMcp(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    // Extract and validate JWT from Authorization header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({
        jsonrpc: '2.0',
        error: {
          code: -32001,
          message: 'Authentication required. Provide a valid Bearer token.',
        },
        id: null,
      });
      return;
    }

    const token = authHeader.slice(7);
    let user;
    try {
      user = await this.authService.validateToken(token);
    } catch {
      res.status(401).json({
        jsonrpc: '2.0',
        error: {
          code: -32001,
          message: 'Invalid or expired token.',
        },
        id: null,
      });
      return;
    }

    // Set user context for tool handlers
    setCurrentRequestUser({
      id: user.id,
      username: user.username,
      roles: user.roles,
    });

    try {
      // Create a stateless transport per request
      const transport = new StreamableHTTPServerTransport({
        sessionIdGenerator: undefined,
      });

      // Connect the MCP server to this transport
      await this.mcpService.getServer().connect(transport);

      // Handle the request using the raw Node.js req/res
      // NestJS Express wraps the native IncomingMessage/ServerResponse
      const nodeReq = req as any;
      const nodeRes = res as any;
      await transport.handleRequest(nodeReq, nodeRes, req.body);
    } catch (error) {
      this.logger.error('MCP request handling failed', error);
      if (!res.headersSent) {
        res.status(500).json({
          jsonrpc: '2.0',
          error: {
            code: -32603,
            message: 'Internal server error',
          },
          id: null,
        });
      }
    } finally {
      setCurrentRequestUser(null);
    }
  }

  @Get()
  async handleMcpGet(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    // GET endpoint for SSE streams (required by Streamable HTTP spec)
    // For stateless mode, GET is not supported
    res.status(405).json({
      jsonrpc: '2.0',
      error: {
        code: -32000,
        message: 'GET not supported in stateless mode. Use POST.',
      },
      id: null,
    });
  }

  @Delete()
  async handleMcpDelete(
    @Req() req: Request,
    @Res() res: Response,
  ): Promise<void> {
    // DELETE endpoint for session termination (required by Streamable HTTP spec)
    // For stateless mode, DELETE is not supported
    res.status(405).json({
      jsonrpc: '2.0',
      error: {
        code: -32000,
        message: 'Session termination not supported in stateless mode.',
      },
      id: null,
    });
  }
}

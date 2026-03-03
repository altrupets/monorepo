# PASO 5: Integración LangGraph + Zep + Langfuse en Agent

## 5.1 Memory Module (Zep + FalkorDB)

### src/memory/memory.module.ts

```ts
import { Module, Global } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { MemoryService } from './memory.service';

@Global()
@Module({
  imports: [ConfigModule],
  providers: [MemoryService],
  exports: [MemoryService],
})
export class MemoryModule {}
```

### src/memory/memory.service.ts

```ts
import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

@Injectable()
export class MemoryService implements OnModuleInit {
  private redis: Redis;

  constructor(private config: ConfigService) {}

  onModuleInit() {
    this.redis = new Redis({
      host: this.config.get('FALKORDB_HOST', 'falkordb-service.altrupets-dev.svc.cluster.local'),
      port: this.config.get<number>('FALKORDB_PORT', 6379),
      password: this.config.get('FALKORDB_PASSWORD', ''),
      retryStrategy: (times) => Math.min(times * 100, 3000),
    });
  }

  getRedisClient(): Redis {
    return this.redis;
  }

  async saveConversationTurn(userId: string, sessionId: string, role: string, content: string) {
    const key = `conversation:${userId}:${sessionId}`;
    const turn = JSON.stringify({ role, content, timestamp: Date.now() });
    await this.redis.rpush(key, turn);
    await this.redis.ltrim(key, -50, -1);
    await this.redis.expire(key, 86400);
  }

  async getConversationHistory(userId: string, sessionId: string): Promise<Array<{ role: string; content: string }>> {
    const key = `conversation:${userId}:${sessionId}`;
    const turns = await this.redis.lrange(key, 0, -1);
    return turns.map((t) => JSON.parse(t));
  }

  // FalkorDB graph queries para relaciones rescatista-animal-ubicacion
  async queryGraph(cypher: string): Promise<unknown> {
    return this.redis.call('GRAPH.QUERY', 'altrupets', cypher);
  }
}
```

## 5.2 Observability Module (Langfuse)

### src/observability/observability.module.ts

```ts
import { Module, Global } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { LangfuseService } from './langfuse.service';

@Global()
@Module({
  imports: [ConfigModule],
  providers: [LangfuseService],
  exports: [LangfuseService],
})
export class ObservabilityModule {}
```

### src/observability/langfuse.service.ts

```ts
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Langfuse } from 'langfuse';

@Injectable()
export class LangfuseService implements OnModuleInit, OnModuleDestroy {
  private langfuse: Langfuse;

  constructor(private config: ConfigService) {}

  onModuleInit() {
    const publicKey = this.config.get<string>('LANGFUSE_PUBLIC_KEY');
    const secretKey = this.config.get<string>('LANGFUSE_SECRET_KEY');

    if (publicKey && secretKey) {
      this.langfuse = new Langfuse({
        publicKey,
        secretKey,
        baseUrl: this.config.get('LANGFUSE_BASE_URL', 'https://cloud.langfuse.com'),
      });
    }
  }

  async onModuleDestroy() {
    if (this.langfuse) {
      await this.langfuse.shutdownAsync();
    }
  }

  createTrace(name: string, metadata?: Record<string, unknown>) {
    if (!this.langfuse) return null;
    return this.langfuse.trace({ name, metadata });
  }

  getLangfuse(): Langfuse | null {
    return this.langfuse ?? null;
  }
}
```

## 5.3 Agent Module

### src/agent/agent.module.ts

```ts
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AgentService } from './agent.service';
import { AgentResolver } from './agent.resolver';
import { RescuerGraphService } from '../graph/rescuer-graph.service';

@Module({
  imports: [ConfigModule],
  providers: [AgentService, AgentResolver, RescuerGraphService],
})
export class AgentModule {}
```

### src/agent/dto/rescuer-recommendation.dto.ts

```ts
import { ObjectType, Field, Float, ID } from '@nestjs/graphql';

@ObjectType()
export class RescuerRecommendation {
  @Field(() => ID)
  userId: string;

  @Field()
  username: string;

  @Field(() => [String])
  roles: string[];

  @Field(() => Float)
  distanceKm: number;

  @Field(() => Float)
  score: number;

  @Field()
  reasoning: string;
}

@ObjectType()
export class AgentResponse {
  @Field()
  sessionId: string;

  @Field()
  message: string;

  @Field(() => [RescuerRecommendation], { nullable: true })
  recommendations?: RescuerRecommendation[];
}
```

### src/agent/agent.resolver.ts

```ts
import { Resolver, Query, Mutation, Args, Context } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { AgentService } from './agent.service';
import { AgentResponse } from './dto/rescuer-recommendation.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

@Resolver()
export class AgentResolver {
  constructor(private agentService: AgentService) {}

  @Query(() => String)
  agentHealth(): string {
    return 'Agent AI is operational';
  }

  @Mutation(() => AgentResponse)
  @UseGuards(JwtAuthGuard)
  async recommendRescuers(
    @Args('captureRequestId') captureRequestId: string,
    @Args('latitude', { type: () => Number }) latitude: number,
    @Args('longitude', { type: () => Number }) longitude: number,
    @Args('animalType') animalType: string,
    @Context() ctx: { req: { user: { sub: string; username: string } } },
  ): Promise<AgentResponse> {
    const userId = ctx.req.user.sub;
    return this.agentService.recommendRescuers({
      captureRequestId,
      latitude,
      longitude,
      animalType,
      requestedBy: userId,
    });
  }

  @Mutation(() => AgentResponse)
  @UseGuards(JwtAuthGuard)
  async chat(
    @Args('message') message: string,
    @Args('sessionId', { nullable: true }) sessionId: string,
    @Context() ctx: { req: { user: { sub: string } } },
  ): Promise<AgentResponse> {
    return this.agentService.chat({
      userId: ctx.req.user.sub,
      message,
      sessionId,
    });
  }
}
```

### src/agent/guards/jwt-auth.guard.ts

```ts
import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { GqlExecutionContext } from '@nestjs/graphql';
import { ConfigService } from '@nestjs/config';
import * as jwt from 'jsonwebtoken';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private config: ConfigService) {}

  canActivate(context: ExecutionContext): boolean {
    const ctx = GqlExecutionContext.create(context);
    const req = ctx.getContext().req;
    const authHeader = req.headers.authorization;

    if (!authHeader?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing or invalid token');
    }

    const token = authHeader.substring(7);
    try {
      const secret = this.config.get<string>('JWT_SECRET', 'super-secret-altrupets-key-2026');
      const payload = jwt.verify(token, secret);
      req.user = payload;
      return true;
    } catch {
      throw new UnauthorizedException('Invalid or expired token');
    }
  }
}
```

## 5.4 LangGraph: Rescuer Matching Graph

### src/graph/rescuer-graph.service.ts

```ts
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { StateGraph, Annotation, END, START } from '@langchain/langgraph';
import { ChatOpenAI } from '@langchain/openai';
import { MemoryService } from '../memory/memory.service';
import { LangfuseService } from '../observability/langfuse.service';

const RescuerState = Annotation.Root({
  captureRequestId: Annotation<string>,
  latitude: Annotation<number>,
  longitude: Annotation<number>,
  animalType: Annotation<string>,
  requestedBy: Annotation<string>,
  nearbyRescuers: Annotation<Array<{
    userId: string;
    username: string;
    roles: string[];
    lat: number;
    lng: number;
    distanceKm: number;
  }>>,
  rankedRescuers: Annotation<Array<{
    userId: string;
    username: string;
    roles: string[];
    distanceKm: number;
    score: number;
    reasoning: string;
  }>>,
  finalMessage: Annotation<string>,
});

type RescuerStateType = typeof RescuerState.State;

@Injectable()
export class RescuerGraphService {
  private llm: ChatOpenAI;

  constructor(
    private config: ConfigService,
    private memory: MemoryService,
    private langfuse: LangfuseService,
  ) {
    this.llm = new ChatOpenAI({
      modelName: this.config.get('LLM_MODEL', 'gpt-4o'),
      openAIApiKey: this.config.get('OPENAI_API_KEY'),
      temperature: 0.3,
    });
  }

  async buildGraph() {
    const graph = new StateGraph(RescuerState);

    // Nodo 1: Buscar rescatistas cercanos via FalkorDB graph
    graph.addNode('fetchNearby', async (state: RescuerStateType) => {
      const trace = this.langfuse.createTrace('fetchNearby', {
        captureId: state.captureRequestId,
      });

      const cypher = `
        MATCH (u:User)-[:HAS_ROLE]->(r:Role {name: 'RESCATISTA'})
        WHERE u.latitude IS NOT NULL AND u.longitude IS NOT NULL
        WITH u,
             point.distance(
               point({latitude: u.latitude, longitude: u.longitude}),
               point({latitude: ${state.latitude}, longitude: ${state.longitude}})
             ) / 1000.0 AS distKm
        WHERE distKm < 50
        RETURN u.id AS userId, u.username AS username,
               collect(r.name) AS roles,
               u.latitude AS lat, u.longitude AS lng,
               distKm
        ORDER BY distKm ASC
        LIMIT 20
      `;

      try {
        const result = await this.memory.queryGraph(cypher);
        const rescuers = Array.isArray(result) ? result : [];
        return { nearbyRescuers: rescuers };
      } catch {
        return { nearbyRescuers: [] };
      }
    });

    // Nodo 2: Ranquear rescatistas usando LLM
    graph.addNode('rankRescuers', async (state: RescuerStateType) => {
      if (!state.nearbyRescuers.length) {
        return {
          rankedRescuers: [],
          finalMessage: 'No se encontraron rescatistas cercanos. Intenta ampliar el area.',
        };
      }

      const prompt = `Eres un asistente de rescate animal en Costa Rica.
Dado un reporte de animal tipo "${state.animalType}" en coordenadas (${state.latitude}, ${state.longitude}),
ranquea estos rescatistas por idoneidad. Considera distancia, roles y disponibilidad.

Rescatistas disponibles:
${JSON.stringify(state.nearbyRescuers, null, 2)}

Responde en JSON: [{ "userId": "...", "score": 0-100, "reasoning": "..." }]`;

      const response = await this.llm.invoke(prompt);
      const content = typeof response.content === 'string' ? response.content : '';

      try {
        const rankings = JSON.parse(content);
        const ranked = state.nearbyRescuers.map((r) => {
          const rank = rankings.find((rk: { userId: string }) => rk.userId === r.userId);
          return {
            userId: r.userId,
            username: r.username,
            roles: r.roles,
            distanceKm: r.distanceKm,
            score: rank?.score ?? 50,
            reasoning: rank?.reasoning ?? 'Sin evaluacion detallada',
          };
        });
        ranked.sort((a, b) => b.score - a.score);

        return {
          rankedRescuers: ranked.slice(0, 5),
          finalMessage: `Se encontraron ${ranked.length} rescatistas. Top ${Math.min(5, ranked.length)} recomendados.`,
        };
      } catch {
        return {
          rankedRescuers: state.nearbyRescuers.slice(0, 5).map((r) => ({
            ...r,
            score: 100 - r.distanceKm,
            reasoning: 'Ranqueado por distancia (fallback)',
          })),
          finalMessage: 'Recomendaciones basadas en distancia.',
        };
      }
    });

    graph.addEdge(START, 'fetchNearby');
    graph.addEdge('fetchNearby', 'rankRescuers');
    graph.addEdge('rankRescuers', END);

    return graph.compile();
  }
}
```

### src/agent/agent.service.ts

```ts
import { Injectable } from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';
import { RescuerGraphService } from '../graph/rescuer-graph.service';
import { MemoryService } from '../memory/memory.service';
import { LangfuseService } from '../observability/langfuse.service';
import { AgentResponse } from './dto/rescuer-recommendation.dto';

@Injectable()
export class AgentService {
  constructor(
    private rescuerGraph: RescuerGraphService,
    private memory: MemoryService,
    private langfuse: LangfuseService,
  ) {}

  async recommendRescuers(input: {
    captureRequestId: string;
    latitude: number;
    longitude: number;
    animalType: string;
    requestedBy: string;
  }): Promise<AgentResponse> {
    const sessionId = uuidv4();
    const trace = this.langfuse.createTrace('recommendRescuers', {
      captureRequestId: input.captureRequestId,
      userId: input.requestedBy,
    });

    const graph = await this.rescuerGraph.buildGraph();
    const result = await graph.invoke({
      captureRequestId: input.captureRequestId,
      latitude: input.latitude,
      longitude: input.longitude,
      animalType: input.animalType,
      requestedBy: input.requestedBy,
      nearbyRescuers: [],
      rankedRescuers: [],
      finalMessage: '',
    });

    await this.memory.saveConversationTurn(
      input.requestedBy,
      sessionId,
      'system',
      `Recomendacion de rescatistas para ${input.animalType}: ${result.finalMessage}`,
    );

    return {
      sessionId,
      message: result.finalMessage,
      recommendations: result.rankedRescuers,
    };
  }

  async chat(input: { userId: string; message: string; sessionId?: string }): Promise<AgentResponse> {
    const sessionId = input.sessionId || uuidv4();

    await this.memory.saveConversationTurn(input.userId, sessionId, 'user', input.message);

    const history = await this.memory.getConversationHistory(input.userId, sessionId);

    const response = `Recibido: "${input.message}". Historial: ${history.length} turnos.`;
    await this.memory.saveConversationTurn(input.userId, sessionId, 'assistant', response);

    return { sessionId, message: response };
  }
}
```

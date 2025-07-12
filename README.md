# Enterprise Financial Management API

> **Sistema completo de gestão financeira empresarial** desenvolvido com Spring Boot, autenticação JWT, auditoria e arquitetura enterprise-ready.

[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.0-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue.svg)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Enabled-blue.svg)](https://www.docker.com/)
[![Swagger](https://img.shields.io/badge/API-Documented-green.svg)](https://swagger.io/)

## Demo & Links

- **API Live**: [https://api-finance-s8rh.onrender.com](https://api-finance-s8rh.onrender.com)
- **Documentação Interativa**: [https://api-finance-s8rh.onrender.com/swagger-ui.html](https://api-finance-s8rh.onrender.com/swagger-ui.html)
- **Health Check**: [https://api-finance-s8rh.onrender.com/actuator/health](https://api-finance-s8rh.onrender.com/actuator/health)
- **Repositório**: [GitHub](https://github.com/PedroAbreu017/api-finance)

---

## Sobre o Projeto

Sistema empresarial de **gestão financeira** com recursos avançados de segurança, auditoria e monitoramento. Desenvolvido seguindo **boas práticas enterprise** e **arquitetura escalável**.

### Principais Diferenciais

- **Autenticação JWT** completa com refresh tokens
- **Autorização baseada em roles** (RBAC)
- **Sistema de auditoria** completo
- **Gestão de contas e transações** financeiras
- **Transferências** entre contas
- **Monitoramento** com Spring Actuator
- **Documentação automática** com Swagger
- **Cache Redis** para performance
- **Containerização** completa

---

## Arquitetura & Tecnologias

### Backend Stack
Java 17 + Spring Boot 3.2.0
PostgreSQL (Produção) | H2 (Desenvolvimento)
Spring Security + JWT
Redis (Cache)
Spring Actuator (Monitoring)
JUnit + Spring Boot Test
Swagger/OpenAPI 3
Docker + Docker Compose

### Funcionalidades Principais

#### Sistema de Autenticação
- Registro de usuários com validação
- Login/logout com JWT
- Refresh token automático
- Autorização baseada em roles (USER, ADMIN)
- Gerenciamento de perfis

#### Gestão Financeira
- **Contas**: Criação, consulta e gerenciamento
- **Transações**: Depósitos, saques e consultas
- **Transferências**: Entre contas com validação
- **Histórico**: Consulta paginada de transações
- **Auditoria**: Log completo de todas as operações

#### Gestão de Produtos (Módulo Adicional)
- CRUD completo de produtos
- Estatísticas e relatórios
- Controle de estoque
- Auditoria de alterações

---

## Começando

### Pré-requisitos
- Java 17+
- Maven 3.8+
- Docker & Docker Compose (opcional)

### Desenvolvimento Local

```bash
# 1. Clone o repositório
git clone https://github.com/PedroAbreu017/api-finance.git
cd api-finance

# 2. Execute com perfil local (H2)
mvn spring-boot:run

# 3. Acesse a aplicação
# API: http://localhost:8080
# Swagger: http://localhost:8080/swagger-ui.html
# H2 Console: http://localhost:8080/h2-console
Execução com Docker
bash# Desenvolvimento com PostgreSQL + Redis
docker-compose up -d

# Produção
docker-compose -f docker-compose.prod.yml up -d

Endpoints da API
Autenticação
httpPOST   /api/auth/register    # Registro de usuário
POST   /api/auth/login       # Login
POST   /api/auth/refresh     # Refresh token
POST   /api/auth/logout      # Logout
Usuários
httpGET    /api/users           # Listar usuários (Admin)
GET    /api/users/profile   # Perfil do usuário
PUT    /api/users/profile   # Atualizar perfil
POST   /api/users/change-password  # Alterar senha
Contas Financeiras
httpGET    /api/accounts        # Listar contas do usuário
POST   /api/accounts        # Criar nova conta
GET    /api/accounts/{id}   # Detalhes da conta
POST   /api/accounts/{id}/deposit   # Depósito
POST   /api/accounts/{id}/withdraw  # Saque
Transações
httpGET    /api/transactions    # Histórico de transações
POST   /api/transactions    # Nova transação
POST   /api/transactions/transfer  # Transferência entre contas
GET    /api/transactions/{id}      # Detalhes da transação
Produtos
httpGET    /api/products        # Listar produtos
POST   /api/products        # Criar produto (Admin)
PUT    /api/products/{id}   # Atualizar produto (Admin)
DELETE /api/products/{id}   # Excluir produto (Admin)
GET    /api/products/stats  # Estatísticas (Admin)
Administração
httpPOST   /api/admin/load-sample-data     # Carregar dados de teste
DELETE /api/admin/clear-data          # Limpar dados
GET    /actuator/health              # Health check
GET    /actuator/metrics             # Métricas

Segurança
Autenticação JWT

Tokens com expiração configurável
Refresh tokens para sessões longas
Headers de autorização padrão

Autorização RBAC

USER: Acesso às próprias contas e transações
ADMIN: Acesso completo + gerenciamento de produtos

Exemplo de Uso
bash# 1. Registrar usuário
curl -X POST https://api-finance-s8rh.onrender.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"pedro","email":"pedro@email.com","password":"123456"}'

# 2. Fazer login
curl -X POST https://api-finance-s8rh.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"pedro","password":"123456"}'

# 3. Usar token para acessar recursos protegidos
curl -X GET https://api-finance-s8rh.onrender.com/api/accounts \
  -H "Authorization: Bearer SEU_JWT_TOKEN"

Banco de Dados
Modelo de Dados Principal
User (Usuários)
├── Account (Contas)
│   └── FinancialTransaction (Transações)
├── Product (Produtos)  
└── AuditLog (Auditoria)
Configurações por Ambiente

Local: H2 in-memory (desenvolvimento rápido)
Produção: PostgreSQL (persistência real)
Docker: PostgreSQL + Redis


Monitoramento
Spring Actuator Endpoints
GET /actuator/health     # Status da aplicação
GET /actuator/metrics    # Métricas de performance
GET /actuator/info       # Informações da aplicação
Logs de Auditoria

Todas as transações financeiras são auditadas
Logs incluem: usuário, ação, timestamp, valores
Rastreabilidade completa para compliance


Testes
bash# Executar todos os testes
mvn test

# Testes com cobertura
mvn test jacoco:report

# Testes de integração
mvn verify

Deploy
Variáveis de Ambiente (Produção)
env# Database
DATABASE_URL=postgresql://user:pass@host:5432/db
POSTGRES_USER=seu_usuario
POSTGRES_PASSWORD=sua_senha
POSTGRES_DB=nome_do_banco

# JWT
JWT_SECRET=sua_chave_secreta_jwt_muito_segura

# Redis (opcional)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=sua_senha_redis

# Server
PORT=8080
ENVIRONMENT=production
Deploy Automático

Render: Deploy automático via GitHub
Railway: Suporte nativo a PostgreSQL
Docker: Container pronto para qualquer cloud


Roadmap

 Testes automatizados (JUnit + TestContainers)
 Dashboard administrativo
 Notificações de transações
 Multi-moedas
 API para mobile
 CI/CD com GitHub Actions


Desenvolvedor
Pedro Marschhausen

Email: pedroabreu6497@gmail.com
LinkedIn: linkedin.com/in/pedro-marschhausen-2756891b3
GitHub: github.com/PedroAbreu017


Licença
Este projeto está licenciado sob a MIT License.

<div align="center">
⭐ Se este projeto foi útil, deixe uma estrela! ⭐
🚀 Desenvolvido com Java + Spring Boot + ❤️
</div>
```

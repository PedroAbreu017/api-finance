🏦 Enterprise Financial Management API
Sistema completo de gestão financeira empresarial, desenvolvido com Spring Boot, autenticação JWT, auditoria e arquitetura escalável.







🌐 Demo & Links
🚀 API Live: https://api-finance-xxx.onrender.com

📚 Documentação Swagger: https://api-finance-xxx.onrender.com/swagger-ui.html

📈 Health Check: https://api-finance-xxx.onrender.com/actuator/health

📂 Repositório GitHub: PedroAbreu017/api-finance

🎯 Sobre o Projeto
Sistema de gestão financeira com foco em segurança, auditoria, escalabilidade e monitoramento, seguindo padrões de desenvolvimento corporativo.

💡 Diferenciais
🔐 Autenticação JWT com refresh tokens

🛡️ Autorização RBAC (User/Admin)

📋 Auditoria de todas as operações

💰 Gestão de contas e transações

🔄 Transferências entre contas

📊 Monitoramento com Spring Actuator

⚡ Cache Redis para performance

🐳 Totalmente containerizado com Docker

🏗️ Arquitetura & Tecnologias
text
Copy
Edit
Java 17 + Spring Boot 3.2
PostgreSQL (produção) | H2 (dev)
Spring Security + JWT
Redis (cache)
Spring Actuator (monitoramento)
JUnit + TestContainers
Swagger/OpenAPI 3
Docker + Docker Compose
🔧 Desenvolvimento Local
Pré-requisitos
Java 17+

Maven 3.8+

Docker & Docker Compose

bash
Copy
Edit
# 1. Clone o projeto
git clone https://github.com/PedroAbreu017/api-finance.git
cd api-finance

# 2. Execute em modo dev (H2 embutido)
mvn spring-boot:run

# Acesse:
# http://localhost:8080/swagger-ui.html
# http://localhost:8080/h2-console
🐳 Com Docker
bash
Copy
Edit
# Ambiente dev com PostgreSQL + Redis
docker-compose up -d

# Para produção:
docker-compose -f docker-compose.prod.yml up -d
🔐 Autenticação
Método	Endpoint	Descrição
POST	/api/auth/register	Registro
POST	/api/auth/login	Login
POST	/api/auth/refresh	Refresh token
POST	/api/auth/logout	Logout

💰 Gestão de Contas
Método	Endpoint	Descrição
GET	/api/accounts	Listar contas
POST	/api/accounts	Criar conta
GET	/api/accounts/{id}	Ver detalhes
POST	/api/accounts/{id}/deposit	Depositar
POST	/api/accounts/{id}/withdraw	Sacar

🔄 Transações
Método	Endpoint	Descrição
GET	/api/transactions	Histórico paginado
POST	/api/transactions	Criar transação
POST	/api/transactions/transfer	Transferência entre contas
GET	/api/transactions/{id}	Detalhes da transação

🛍️ Produtos (Admin)
Método	Endpoint	Descrição
GET	/api/products	Listar produtos
POST	/api/products	Criar produto
PUT	/api/products/{id}	Atualizar
DELETE	/api/products/{id}	Excluir
GET	/api/products/stats	Estatísticas

⚙️ Administração e Monitoramento
Método	Endpoint	Descrição
POST	/api/admin/load-sample-data	Popular base de dados
DELETE	/api/admin/clear-data	Limpar dados
GET	/actuator/health	Status da aplicação
GET	/actuator/metrics	Métricas de sistema

🔒 Segurança
JWT com expiração e refresh

RBAC:

USER: acesso limitado

ADMIN: acesso completo

Exemplo de uso via curl
bash
Copy
Edit
# Registro
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"pedro","email":"pedro@email.com","password":"123456"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"pedro","password":"123456"}'

# Usar token JWT
curl -X GET http://localhost:8080/api/accounts \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
🗄️ Banco de Dados
Diagrama simplificado
sql
Copy
Edit
User
├── Account
│   └── FinancialTransaction
├── Product
└── AuditLog
🧪 Testes
bash
Copy
Edit
# Executar testes unitários
mvn test

# Com cobertura
mvn test jacoco:report

# Testes de integração
mvn verify
🚀 Deploy
Variáveis de ambiente
env
Copy
Edit
# Banco de Dados
DATABASE_URL=jdbc:postgresql://host:5432/db
POSTGRES_USER=usuario
POSTGRES_PASSWORD=senha
POSTGRES_DB=nome_do_banco

# JWT
JWT_SECRET=sua_chave_super_secreta

# Redis (opcional)
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=senha_redis

# Configuração geral
PORT=8080
ENVIRONMENT=production
📈 Roadmap
 Testes com TestContainers

 Painel Admin (UI)

 Notificações de transações

 Suporte a múltiplas moedas

 API para mobile

 CI/CD com GitHub Actions

👨‍💻 Desenvolvedor
Pedro Abreu
📧 seu.email@example.com
🔗 linkedin.com/in/pedroabreu
🐙 github.com/PedroAbreu017

📄 Licença
Distribuído sob a MIT License.

<div align="center">
⭐ Se este projeto te ajudou, deixe uma estrela!
🚀 Desenvolvido com Java + Spring Boot + ❤️

</div>

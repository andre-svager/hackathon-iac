1. Infraestrutura como Código (Terraform)

IAC para provisionar toda a infraestrutura do
🚀 SolidaryTech — Hackathon Fase 5

Projeto Terraform usando módulos que provisiona:

1. Networking: VPC, Subnets (Públicas e Privadas), Internet Gateway e Route Tables.
2. Cluster EKS: O cluster Kubernetes e seus Node Groups.
3. Bancos de Dados:
o 2 instâncias RDS (PostgreSQL).
o 1 Tabela DynamoDB (ToggleMasterAnalytics).
4. Mensageria: 1 Fila SQS.
5. Repositórios: 3 repositórios no ECR 
6. terraform.tfstate não pode ficar local. Configure o Backend Remoto usando um Bucket S3

O que sera provisionado de acordo com os Services:

## 1️⃣ NGO Service — Cadastro de ONGs

| Item | Valor |
|---|---|
| Linguagem | Python 3.9+ |
| Framework | Flask |
| Banco de Dados | PostgreSQL |
| Porta Local | `8081` |

---

## 2️⃣ Donation Service — Processamento de Doações

| Item | Valor |
|---|---|
| Linguagem | Go 1.21+ |
| Banco de Dados | PostgreSQL |
| Mensageria | Publish AWS SQS |
| Porta Local | `8082` |

---

## 3️⃣ Volunteer Service — Gestão de Voluntários

| Item | Valor |
|---|---|
| Linguagem | Python 3.9+ |
| Framework | Flask |
| Banco de Dados | AWS DynamoDB |
| Porta Local | `8083` |


# 🛠️ Preparação da Infraestrutura

## PostgreSQL

Crie dois bancos de dados independentes:

### Banco `ngo_db`

Execute:

```sql
ngo-service/db/init.sql
```

### Banco `donation_db`

Execute:

```sql
donation-service/db/init.sql
```

---

## AWS DynamoDB

Crie a tabela:

| Configuração | Valor |
|---|---|
| Nome da Tabela | `SolidaryTechVolunteers` |
| Partition Key | `volunteer_id` |
| Tipo | `String` |

---

## AWS SQS

Crie uma fila do tipo **Standard Queue**.

Exemplo:

```text
https://sqs.us-east-1.amazonaws.com/1234567890/solidary-donations
```

Guarde a URL da fila para utilizar nas variáveis de ambiente.

---

# ⚙️ Passo 2 — Variáveis de Ambiente

Crie um arquivo `.env` dentro de cada microsserviço.

---

## 📄 ngo-service/.env

```env
PORT=8081
DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/ngo_db"
```

---

## 📄 donation-service/.env

```env
PORT=8082
DATABASE_URL="postgres://SEU_USUARIO:SUA_SENHA@localhost:5432/donation_db"

AWS_REGION="us-east-1"
AWS_SQS_URL="SUA_URL_DA_FILA_SQS"
```

---

## 📄 volunteer-service/.env

```env
PORT=8083

AWS_REGION="us-east-1"
AWS_DYNAMODB_TABLE="SolidaryTechVolunteers"
```

---

# ▶️ Passo 3 — Inicializando os Serviços

Abra **3 terminais separados**.

---

## 🟣 Terminal 1 — NGO Service

```bash
cd ngo-service

pip install -r requirements.txt

gunicorn --bind 0.0.0.0:8081 app:app
```

---

## 🟠 Terminal 2 — Donation Service

```bash
cd donation-service

go mod tidy

go run .
```

---

## 🔵 Terminal 3 — Volunteer Service

```bash
cd volunteer-service

pip install -r requirements.txt

gunicorn --bind 0.0.0.0:8083 app:app
```

---

# 🌐 Portas Locais

| Serviço | URL |
|---|---|
| NGO Service | http://localhost:8081 |
| Donation Service | http://localhost:8082 |
| Volunteer Service | http://localhost:8083 |

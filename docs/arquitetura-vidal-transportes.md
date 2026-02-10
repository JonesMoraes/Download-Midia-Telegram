# Arquitetura de Referência — Vidal Transportes

## 1) Visão Geral

O **Vidal Transportes** é uma plataforma de transporte com operação regional em **Minas Gerais, Brasil**, projetada para alta disponibilidade, segurança por padrão e evolução contínua. A arquitetura utiliza **Google Cloud Platform (GCP)** e **Firebase** como base, com foco em:

- baixa latência para usuários e motoristas na região alvo,
- proteção de dados sensíveis,
- rastreabilidade operacional,
- escalabilidade elástica para variações de demanda,
- governança de custos e ambientes.

### Escopo geográfico

- **Área de operação:** Minas Gerais, Brasil.
- **Região primária GCP:** `southamerica-east1` (São Paulo), para otimizar latência e conformidade regional.

---

## 2) Arquitetura principal

### 2.1 Aplicativo móvel (Flutter)

- **Stack:** Flutter (base única para Android e iOS).
- **Integrações principais:**
  - Firebase SDKs (Auth, Firestore, Storage, Crashlytics),
  - APIs backend expostas via Load Balancer.
- **Objetivo funcional:** unificar a experiência operacional de motoristas e usuários finais com tempo de resposta consistente.

### 2.2 Ecossistema Firebase

#### a) Firebase Authentication

- Login com múltiplos provedores:
  - telefone,
  - Google,
  - Apple,
  - Facebook.
- **Account linking** para consolidar múltiplas identidades de um mesmo usuário.

#### b) Cloud Firestore

- Banco NoSQL transacional principal.
- Entidades alvo:
  - rotas,
  - paradas,
  - templates de rota,
  - eventos de entrega,
  - perfis de usuário.
- Regras de segurança granulares com isolamento por UID:
  - `users/{uid}/...`,
  - `routes/{uid}/{routeId}/...`.

#### c) Cloud Storage (via Firebase SDK)

- Armazenamento de binários (ex.: Provas de Entrega — POD).
- Estrutura recomendada:
  - `proofs/{uid}/{routeId}/{stopId}/...`.
- Regras de acesso estritas com base em autenticação e UID.

#### d) Firebase Crashlytics

- Monitoramento de falhas e erros em tempo real.
- Suporte a triagem, priorização e melhoria contínua do app móvel.

### 2.3 Microsserviços em Cloud Run (`southamerica-east1`)

#### `vidal-transportes-places-proxy`

- Proxy seguro para Google Places (Autocomplete e Details).
- Controles:
  - cache de respostas em Redis,
  - rate limiting via Redis,
  - validação de entrada,
  - normalização/padronização de saída.

#### `vidal-transportes-ai-proxy`

- Proxy seguro para OpenAI API.
- Controles:
  - validação de JSON Schema (entrada/saída),
  - rate limiting via Redis,
  - sanitização de saída,
  - estratégias de fallback para resiliência.

#### `vidal-transportes-tracking`

- Geração, revogação e consulta de links públicos de rastreamento.
- Características:
  - acesso sem autenticação para link público,
  - filtragem de dados sensíveis,
  - expiração e revogação de links,
  - rate limiting para contenção de abuso.

### 2.4 Load Balancer Regional

- **Região:** `southamerica-east1`.
- **Função:** ponto de entrada único para os microsserviços Cloud Run.
- **Capacidades:**
  - domínio customizado (ex.: `api.vidaltransportes.com.br`),
  - HTTPS gerenciado,
  - roteamento por caminho para serviços Cloud Run por Serverless NEGs.

### 2.5 Secret Manager

- Cofre central de segredos e chaves sensíveis (Google Places, OpenAI e outras credenciais).
- Acesso por identidades de serviço com princípio de menor privilégio.

### 2.6 Cloud Memorystore for Redis

- Camada compartilhada para:
  - cache,
  - contadores de rate limiting,
  - mitigação de custo e latência em serviços proxy.

---

## 3) Segurança e Governança

### 3.1 IAM

- Contas de serviço dedicadas por workload.
- Permissões mínimas necessárias (least privilege).
- Segmentação de papéis por função organizacional:
  - desenvolvimento,
  - QA,
  - operações,
  - administração.

### 3.2 Proteção de rede e workloads

- **VPC Service Controls:** perímetro para reduzir risco de exfiltração.
- **Cloud Armor:** proteção DDoS e políticas WAF no edge.
- **Binary Authorization:** apenas imagens autorizadas em produção.
- **Segurança de aplicação:** validação de entrada e sanitização de saída em todos os serviços.

### 3.3 Auditoria e postura de segurança

- **Cloud Audit Logs:** trilha completa de atividades administrativas e acesso.
- **Security Command Center:** consolidação de vulnerabilidades, achados e postura de segurança.

---

## 4) DevOps e Ambientes

### 4.1 Estrutura de projetos GCP

- `vidal-transportes-dev`
- `vidal-transportes-staging`
- `vidal-transportes-prod`
- `vidal-transportes-ci` (opcional)

### 4.2 CI/CD

#### App Flutter

- CI:
  - build,
  - testes,
  - análise estática.
- CD:
  - Firebase App Distribution (testes),
  - lojas (produção).

#### Cloud Run

- CI:
  - testes unitários/integração,
  - build Docker,
  - varredura de segurança,
  - push no Artifact Registry.
- CD:
  - deploy em staging e produção,
  - aprovação manual em ambientes críticos.

#### Infraestrutura (Terraform)

- CI com `validate` e `plan`.
- CD com `apply` controlado (staging/prod) e estado remoto em Cloud Storage.

#### Regras de segurança Firebase

- Testes automatizados de regras.
- Deploy versionado via Firebase CLI.

---

## 5) Observabilidade e Sustentabilidade

### 5.1 Observabilidade

- **Cloud Monitoring / Logging / Trace** para métricas, logs e rastreamento distribuído.
- Métricas recomendadas:
  - latência e taxa de erro por serviço,
  - consumo de CPU/memória,
  - crash rate do app,
  - uso de APIs externas.
- Alertas proativos para:
  - aumento de erro,
  - degradação de latência,
  - consumo de quota,
  - anomalias de custo.

### 5.2 Custos

- Orçamentos por ambiente com alertas progressivos.
- Revisão contínua de eficiência:
  - tuning de autoscaling,
  - políticas de cache,
  - classes de armazenamento,
  - otimização de consultas Firestore.

### 5.3 Documentação operacional

- Documentos vivos de:
  - arquitetura,
  - runbooks,
  - políticas de segurança,
  - padrões de desenvolvimento.
- Objetivo: reduzir risco operacional e acelerar onboarding.

---

## 6) Fluxo resumido de requisições

1. App Flutter chama endpoint externo em `api.vidaltransportes.com.br`.
2. Load Balancer roteia por caminho para o serviço Cloud Run correspondente.
3. Serviço valida entrada, aplica rate limit em Redis e processa requisição.
4. Serviço consulta Firestore/Storage/APIs externas conforme necessidade.
5. Resposta sanitizada retorna ao app ou ao usuário final (tracking público).

---

## 7) Diretrizes de implementação inicial (MVP seguro)

1. Provisionar `dev` com base Terraform e políticas IAM mínimas.
2. Subir `places-proxy` e `tracking` como primeiros serviços em Cloud Run.
3. Configurar Redis para cache e rate limiting centralizado.
4. Aplicar regras de Firestore e Storage com testes automatizados.
5. Conectar Crashlytics e dashboards de SLO/erro/latência.
6. Definir orçamento com alertas e rotina mensal de revisão de custos.

---

## 8) Resultado esperado da arquitetura

- Operação regional com baixa latência em Minas Gerais.
- Segurança multicamada desde borda até dados.
- Escalabilidade previsível para crescimento da demanda.
- Governança clara entre ambientes e responsabilidades.
- Base sólida para evolução com IA e novas integrações.
